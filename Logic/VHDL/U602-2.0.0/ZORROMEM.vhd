--This work is shared under the Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) License
--https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
	
--You are free to:
--Share - copy and redistribute the material in any medium or format
--Adapt - remix, transform, and build upon the material

--Under the following terms:

--Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. 
--You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

--NonCommercial - You may not use the material for commercial purposes.

--ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the 
--same license as the original.

--No additional restrictions - You may not apply legal terms or technological measures that legally restrict others 
--from doing anything the license permits.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ZORROMEM is

    Port ( 
		A : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		RnW : IN STD_LOGIC; --READ/WRITE SIGNAL FROM 680x0
		nAS : IN STD_LOGIC; --ADDRESS STROBE
		CPUCLK : IN STD_LOGIC; --25MHz CPU CLOCK
		A7M : IN STD_LOGIC; --7MHz AMIGA CLOCK
		nRESET : IN STD_LOGIC; --RESET SIGNAL
		CPU_SPACE : IN STD_LOGIC;
		SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 TRANSFER SIZE SIGNALS
		RAMSIZE : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE JUMPERS
		nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
		
		nMEMZ3 : INOUT STD_LOGIC;
		BURST_CYCLE : INOUT STD_LOGIC;
		
		DSACK : OUT STD_LOGIC;
		nUUBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nUMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nLMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nLLBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		EMA : OUT STD_LOGIC_VECTOR (12 DOWNTO 0); --ZORRO 3 MEMORY BUS
		BANK0 : OUT STD_LOGIC; --SDRAM BANK0
		BANK1 : OUT STD_LOGIC; --SDRAM BANK1
		nEMCAS : OUT STD_LOGIC; --CAS
		nEMRAS : OUT STD_LOGIC; --RAS
		nEMWE : OUT STD_LOGIC; --WRITE ENABLE
		EMCLKE : OUT STD_LOGIC; --CLOCK ENABLE
		nEMCS0 : OUT STD_LOGIC; --CHIP SELECT LOW BANK
		nEMCS1 : OUT STD_LOGIC --CHIP SELECT HIGH BANK
	);

end ZORROMEM;

architecture Behavioral of ZORROMEM is

	--MEMORY SIGNALS
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 127 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	
	--THE SDRAM COMMAND CONSTANTS ARE: _CS, _RAS, _CAS, _WE
	CONSTANT ramstate_NOP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111"; --SDRAM NOP
	CONSTANT ramstate_PRECHARGE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; --SDRAM PRECHARGE ALL;
	CONSTANT ramstate_BANKACTIVATE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ramstate_READ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ramstate_WRITE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ramstate_AUTOREFRESH : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
	CONSTANT ramstate_MODEREGISTER : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	
	SIGNAL RAM_COUNTER : INTEGER RANGE 0 TO 12;
	SIGNAL RAM_CONFIGURED : STD_LOGIC;
	SIGNAL REFRESH_CYCLE : STD_LOGIC;
	SIGNAL MEMORY_CYCLE : STD_LOGIC;
	SIGNAL SDRAM_CS0 : STD_LOGIC;
	SIGNAL SDRAM_CS1 : STD_LOGIC;	

begin

	---------------------------
	-- SDRAM REFRESH COUNTER --
	---------------------------
	
	--THE REFRESH OPERATION MUST BE PERFORMED 8192 TIMES EACH 64ms.
	--SO...8192 TIMES IN 64,000,000ns. THATS ONCE EVERY 7812.5ns.
	--7812.5ns IS EQUAL TO APPROX...
	
	--56 7.16MHz CLOCK CYCLES
	--185 25MHz CLOCK CYCLES
	--244 33MHz CLOCK CYCLES
	--296 40MHz CLOCK CYCLES
	--370 50MHz CLOCK CYCLES
	
	--WE USE THE 7MHz CLOCK TO DRIVE THE REFRESH COUNTER BECAUSE THAT 
	--WILL ALWAYS BE AVAILABLE NO MATTER OUR N2630 CONFIGURATION.
	--SINCE WE ARE JUMPING BETWEEN CLOCK DOMAINS, WE NEED TO HAVE
	--TWO PROCESSES TO ACCOMODATE THE JUMP.
	
	--refreset <= '1' WHEN CURRENT_STATE = AUTO_REFRESH ELSE '0';
	refreset <= '1' WHEN sdramcom = ramstate_AUTOREFRESH ELSE '0';
	
	PROCESS (A7M, refreset) BEGIN
	
		IF refreset = '1' THEN
		
			REFRESH_COUNTER <= 0;			
			
		ELSIF RISING_EDGE (A7M) THEN
		
			REFRESH_COUNTER <= REFRESH_COUNTER + 1;
			
		END IF;
		
	END PROCESS;
	
	
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			refresh <= '0';
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF REFRESH_COUNTER >= REFRESH_DEFAULT THEN
			
				refresh <= '1';
				
			ELSE
			
				refresh <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	-------------------------------
	-- ZORRO 3 MEMORY ADDRESSING --
	-------------------------------
			
	--EXPANSION.LIBRARY IGNORES CARDS FROM $10000000 - $3FFFFFFF, SO
	--WE START AT $40000000 TO SUPPORT AUTOCONFIG.
	
	--$40000000 - $400FFFFF = 8MB
	--$40000000 - $40FFFFFF = 16MB
	--$40000000 - $41FFFFFF = 32MB
	--$40000000 - $43FFFFFF = 64MB
	--$40000000 - $47FFFFFF = 128MB
	--$40000000 - $4FFFFFFF = 256MB

	nMEMZ3 <= '0'
		WHEN
			CPU_SPACE = '0' AND A(31 DOWNTO 28) = "0100"
		ELSE 			 
			'1';
	
	-----------------------------
	-- SDRAM DATA MASK ACTIONS --
	-----------------------------		
		
	nUUBE <= datamask(3);
	nUMBE <= datamask(2);
	nLMBE <= datamask(1);
	nLLBE <= datamask(0);	
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF nRESET = '0' THEN 
		
			datamask <= "1111";
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN

			IF (nMEMZ3 = '0' AND nAS = '0') THEN		

				IF RnW = '0' THEN
				
					--FOR WRITES, WE ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING 
					--ON WHAT THE ACCESSING DEVICE IS ASKING FOR. DISCUSSION OF PORT 
					--SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL
					
					--UPPER UPPER BYTE ENABLE (D31..24)
					IF 
						A(1 downto 0) = "00"
					THEN			
						datamask(3) <= '0'; 
					ELSE 
						datamask(3) <= '1';
					END IF;

					--UPPER MIDDLE BYTE (D23..16)
					IF 
						(A(1 downto 0) = "01") OR
						(A(1) = '0' AND SIZ(0) = '0') OR
						(A(1) = '0' AND SIZ(1) = '1')
					THEN
						datamask(2) <= '0';
					ELSE
						datamask(2) <= '1';
					END IF;

					--LOWER MIDDLE BYTE (D15..8)
					IF 
						(A(1 downto 0) = "10") OR
						(A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0') OR
						(A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1') OR
						(A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0')
					THEN
						datamask(1) <= '0';
					ELSE
						datamask(1) <= '1';
					END IF;

					--LOWER LOWER BYTE (D7..0)
					IF 
						(A(1 downto 0) = "11") OR
						(A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1') OR
						(SIZ(0) = '0' AND SIZ(1) = '0') OR
						(A(1) = '1' AND SIZ(1) ='1')
					THEN
						datamask(0) <= '0';
					ELSE
						datamask(0) <= '1';
					END IF;	
				
				ELSE
				
					--FOR READS, WE RETURN ALL 32 BITS
					datamask <= "0000";
					
				END IF;
				
			ELSE
			
				datamask <= "1111";

			END IF;	
			
		END IF;
		
	END PROCESS;
	
	
	-------------------
	-- SDRAM PROCESS --
	-------------------
	
	--THIS LOGIC SUPPORTS UP TO 256MB IN THE ZORRO 3 EXPANSION SPACE.	
	--BOTH BANKS MUST BE POPULATED TO ACHIEVE 256MB.

	PROCESS (CPUCLK, nRESET) BEGIN

		IF nRESET = '0' THEN

			nEMCS0 <= '1';
			nEMCS1 <= '1';
			nEMRAS <= '1';
			nEMCAS <= '1';	
			nEMWE <= '1';
			EMCLKE <= '0';
			BANK0 <= '0';
			BANK1 <= '0';
			EMA <= (OTHERS => '0');
			sdramcom <= ramstate_NOP;

			RAM_COUNTER <= 0;
			RAM_CONFIGURED <= '0';
			REFRESH_CYCLE <= '0';
			MEMORY_CYCLE <= '0';
			BURST_CYCLE <= '0';
			SDRAM_CS0 <= '0';
			SDRAM_CS1 <= '0';			

		ELSIF RISING_EDGE(CPUCLK) THEN

			IF RAM_COUNTER /= 0 THEN RAM_COUNTER <= RAM_COUNTER + 1; END IF;

			EMCLKE <= '1';
			nEMCS0 <= NOT ((SDRAM_CS0 OR NOT RAM_CONFIGURED OR REFRESH_CYCLE) AND NOT sdramcom(3));
			nEMCS1 <= NOT ((SDRAM_CS1 OR NOT RAM_CONFIGURED OR REFRESH_CYCLE) AND NOT sdramcom(3));
			nEMRAS <= sdramcom(2);
			nEMCAS <= sdramcom(1);	
			nEMWE <= sdramcom(0);

			CASE sdramcom IS

				WHEN ramstate_PRECHARGE => EMA <= "0010000000000";
				WHEN ramstate_MODEREGISTER => EMA <= "0001000100010";
				WHEN ramstate_BANKACTIVATE => EMA <= A(25) & A(21 DOWNTO 10);
				WHEN ramstate_READ | ramstate_WRITE => EMA <= "000" & A(26) & A(24) & A(9 downto 2);
				WHEN OTHERS => EMA <= (OTHERS => '0');

			END CASE;
			

			IF RAM_CONFIGURED = '0' THEN

				CASE RAM_COUNTER IS

					WHEN 0 => sdramcom <= ramstate_PRECHARGE; RAM_COUNTER <= 1;
					WHEN 1 => sdramcom <= ramstate_MODEREGISTER;
					WHEN 3 | 6 => sdramcom <= ramstate_AUTOREFRESH;
					WHEN 8 => RAM_CONFIGURED <= '1'; RAM_COUNTER <= 0;
					WHEN OTHERS => sdramcom <= ramstate_NOP;

				END CASE;

			ELSIF MEMORY_CYCLE = '0' AND (refresh = '1' OR REFRESH_CYCLE = '1') THEN

				CASE RAM_COUNTER IS 

					WHEN 0 => sdramcom <= ramstate_AUTOREFRESH; REFRESH_CYCLE <= '1'; RAM_COUNTER <= 1;
					WHEN 2 => REFRESH_CYCLE <= '0'; RAM_COUNTER <= 0;
					WHEN OTHERS => sdramcom <= ramstate_NOP;

				END CASE;

			ELSIF (nMEMZ3 = '0' AND nAS = '0') OR MEMORY_CYCLE = '1' THEN

				CASE RAM_COUNTER IS

					WHEN 0 =>

						CASE RAMSIZE IS
							WHEN "010" => SDRAM_CS0 <= NOT A(24); SDRAM_CS1 <= A(24);
							WHEN "100" => SDRAM_CS0 <= NOT A(25); SDRAM_CS1 <= A(25);
							WHEN "000" => SDRAM_CS0 <= NOT A(26); SDRAM_CS1 <= A(26);
							WHEN "110" => SDRAM_CS0 <= NOT A(27); SDRAM_CS1 <= A(27);
							WHEN OTHERS => SDRAM_CS0 <= '1'; SDRAM_CS1 <= '0';
						END CASE;

						BANK0 <= A(22);
						BANK1 <= A(23);

						sdramcom <= ramstate_BANKACTIVATE;
						RAM_COUNTER <= 1;
						MEMORY_CYCLE <= '1';
						BURST_CYCLE <= NOT nCBREQ;

					WHEN 1 =>
						
						IF RnW = '1' THEN
							sdramcom <= ramstate_READ;
						ELSE
							sdramcom <= ramstate_WRITE;
							DSACK <= '1';
						END IF;
						
					WHEN 2 =>
					
						IF BURST_CYCLE = '0' THEN sdramcom <= ramstate_PRECHARGE; ELSE sdramcom <= ramstate_NOP; END IF;

					WHEN 3 =>
					
						sdramcom <= ramstate_NOP;
						
						IF RnW = '1' THEN
							DSACK <= '1';
							EMCLKE <= NOT BURST_CYCLE;
						END IF;
						
					WHEN 4 =>
					
						EMCLKE <= '1';						
						
						IF RnW = '0' THEN --END OF WRITE CYCLE
							DSACK <= '0';
							RAM_COUNTER <= 0;
							MEMORY_CYCLE <= '0';			
						END IF;
						
					WHEN 5 =>
					
						EMCLKE <= NOT BURST_CYCLE;
						
					WHEN 6 =>
					
						EMCLKE <= '1';
						
						IF BURST_CYCLE = '0' THEN --END A NON-BURST READ CYCLE.
							DSACK <= '0';
							RAM_COUNTER <= 0;
							MEMORY_CYCLE <= '0';
						END IF;
						
					WHEN 7 =>
					
						EMCLKE <= '0';
						
					WHEN 8 =>
					
						EMCLKE <= '1';
						
					WHEN 9 =>
					
						EMCLKE <= '0';
						
					WHEN 10 =>
					
						EMCLKE <= '1';
						sdramcom <= ramstate_PRECHARGE;
						
					WHEN 11 =>
						
						sdramcom <= ramstate_NOP;
						
					WHEN 12 => --9
					
						DSACK <= '0'; --END OF BURST CYCLE
						RAM_COUNTER <= 0;
						MEMORY_CYCLE <= '0';
						BURST_CYCLE <= '0';


				END CASE;
				
			ELSE
			
				sdramcom <= ramstate_NOP;

			END IF;

		END IF;

	END PROCESS;

end Behavioral;

