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
		nGRESET : IN STD_LOGIC; --68030 ONLY RESET SIGNAL
		--nDS : IN STD_LOGIC; --68030 DATA STROBE
		--FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --68030 FUNCTION CODES
		CPU_SPACE : IN STD_LOGIC;
		SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 TRANSFER SIZE SIGNALS
		RAMSIZE : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE JUMPERS
		--nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
		
		nMEMZ3 : INOUT STD_LOGIC;
		
		DSACK : OUT STD_LOGIC;
		--nDSACK : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
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
		--nSTERM : INOUT STD_LOGIC --68030 SYNCRONOUS TERMINATION SIGNAL
		--nCBACK : OUT STD_LOGIC --68030 CACHE BURST ACK
		--nBERR : OUT STD_LOGIC; --BUS ERROR FOR BURST MODE
	);

end ZORROMEM;

architecture Behavioral of ZORROMEM is

	--MEMORY SIGNALS
	SIGNAL memsel : STD_LOGIC; --ARE WE IN THE ZORRO 3 MEMORY SPACE?
	SIGNAL cs_mem : STD_LOGIC; --ARE WE IN THE UPPER SDRAM PAIR?
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 127 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	SIGNAL dsacken : STD_LOGIC;
	SIGNAL chipselected : STD_LOGIC;
	--SIGNAL cpuspace : STD_LOGIC;
	
	--THE SDRAM COMMAND CONSTANTS ARE: _CS, _RAS, _CAS, _WE
	CONSTANT ramstate_NOP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111"; --SDRAM NOP
	CONSTANT ramstate_PRECHARGE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; --SDRAM PRECHARGE ALL;
	CONSTANT ramstate_BANKACTIVATE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ramstate_READ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ramstate_WRITE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ramstate_AUTOREFRESH : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
	CONSTANT ramstate_MODEREGISTER : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	
	--DEFINE THE SDRAM STATE MACHINE STATES
	TYPE SDRAM_STATE IS ( PRESTART, POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, RAS_STATE, CAS_STATE );	
	SIGNAL CURRENT_STATE : SDRAM_STATE;
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL sdramstartup : STD_LOGIC;

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
	
	refreset <= '1' WHEN CURRENT_STATE = AUTO_REFRESH ELSE '0';
	
	PROCESS (A7M, refreset) BEGIN
	
		IF refreset = '1' THEN
		
			REFRESH_COUNTER <= 0;			
			
		ELSIF RISING_EDGE (A7M) THEN
		
			REFRESH_COUNTER <= REFRESH_COUNTER + 1;
			
		END IF;
		
	END PROCESS;
	
	
	PROCESS (CPUCLK, nGRESET) BEGIN
	
		IF nGRESET = '0' THEN
		
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
			
	--THIS LOGIC SUPPORTS UP TO 256MB IN THE ZORRO 3 EXPANSION SPACE.	
	--BOTH BANKS MUST BE POPULATED TO ACHIEVE 256MB.
	--EXPANSION.LIBRARY IGNORES CARDS FROM $10000000 - $3FFFFFFF, SO
	--WE START AT $40000000 TO SUPPORT AUTOCONFIG.
	
	--$40000000 - $400FFFFF = 8MB
	--$40000000 - $40FFFFFF = 16MB
	--$40000000 - $41FFFFFF = 32MB
	--$40000000 - $43FFFFFF = 64MB
	--$40000000 - $47FFFFFF = 128MB
	--$40000000 - $4FFFFFFF = 256MB
	
	--cpuspace <= '1' WHEN FC(2 DOWNTO 0) = "111" ELSE '0';

	nMEMZ3 <= '0'
		WHEN
			CPU_SPACE = '0' AND A(31 DOWNTO 28) = "0100"
		ELSE 			 
			'1';
	
	memsel <= '1' WHEN nMEMZ3 = '0' AND nAS = '0' ELSE '0';
	
	cs_mem <= 
			'0' WHEN RAMSIZE (2 DOWNTO 0) = "010" AND A(24) = '0' ELSE '1' WHEN RAMSIZE (2 DOWNTO 0) = "010" AND A(24) = '1' 
		ELSE
			'0' WHEN RAMSIZE (2 DOWNTO 0) = "100" AND A(25) = '0' ELSE '1' WHEN RAMSIZE (2 DOWNTO 0) = "100" AND A(25) = '1' 
		ELSE
			'0' WHEN RAMSIZE (2 DOWNTO 0) = "000" AND A(26) = '0' ELSE '1' WHEN RAMSIZE (2 DOWNTO 0) = "000" AND A(26) = '1' 
		ELSE
			'0' WHEN RAMSIZE (2 DOWNTO 0) = "110" AND A(27) = '0' ELSE '1' WHEN RAMSIZE (2 DOWNTO 0) = "111" AND A(27) = '1' 
		ELSE
			'0';
	
	-----------------------------
	-- SDRAM DATA MASK ACTIONS --
	-----------------------------		
		
	nUUBE <= datamask(3);
	nUMBE <= datamask(2);
	nLMBE <= datamask(1);
	nLLBE <= datamask(0);	
	
	PROCESS ( CPUCLK, nGRESET ) BEGIN
	
		IF nGRESET = '0' THEN 
		
			datamask <= "1111";
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN

			IF (memsel = '1') THEN		

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
	
	---------------------------
	-- SDRAM COMMAND ACTIONS --
	---------------------------
	
	--SDRAM COMMANDS ARE SAMPLED ON THE RISING EDGE. WE ARE SETTING COMMANDS ON THE 
	--FALLING EDGE SO THE COMMANDS ARE STABLE AT THE MOMENT THE SDRAM LATCHES THE COMMAND.
	
	--BECAUSE WE ALLOW ONE OR TWO BANKS OF 32-BIT SDRAM, WE MUST DIRECT THE CHIP
	--SELECT SIGNAL TO THE CORRECT BANK, OR BOTH BANKS, DEPENDING ON THE DESIRED FUNCTION.
	--BOTH BANKS ARE SELECTED FOR PROGRAMMING AND REFRESHING.
	--DURING MEMORY ACCESS BY THE CPU, ONLY ONE BANK IS SELECTED.	
		
	--THE NUMBER OF ADDRESS PINS AVAILABLE FOR THE ROW ADDRESS IS AS FOLLOWS:
	-- 4Mx16 - A11-A0 (16MB PER PAIR)
	-- 8Mx16 - A11-A0 (32MB PER PAIR)
	--16Mx16 - A12-A0 (64MB PER PAIR)
	--32Mx16 - A12-A0 (128MB PER PAIR)
	
	--THE NUMBER OF ADDRESS PINS AVAILABLE FOR THE COLUMN ADDRESS IS AS FOLLOWS:
	-- 4Mx16 - A7-A0 (16MB PER PAIR)
	-- 8Mx16 - A8-A0 (32MB PER PAIR)
	--16Mx16 - A8-A0 (64MB PER PAIR)
	--32Mx16 - A9-A0 (128MB PER PAIR)
	
	chipselected <= '1' WHEN sdramstartup = '1' OR CURRENT_STATE = AUTO_REFRESH ELSE '0';
	
	nEMCS0 <= '0' WHEN (cs_mem = '0' AND sdramcom(3) = '0') OR chipselected = '1' ELSE '1';
	nEMCS1 <= '0' WHEN (cs_mem = '1' AND sdramcom(3) = '0') OR chipselected = '1' ELSE '1';
	
	nEMRAS <= sdramcom(2);
	nEMCAS <= sdramcom(1);	
	nEMWE <= sdramcom(0);	
	
	PROCESS ( CPUCLK, nGRESET ) BEGIN
	
		IF (nGRESET = '0') THEN 
		
				--THE AMIGA HAS BEEN RESET OR JUST POWERED UP.
				CURRENT_STATE <= PRESTART;				
				sdramcom <= ramstate_NOP;				
				SDRAM_START_REFRESH_COUNT <= '0';
				sdramstartup <= '1';
				
				EMCLKE <= '0';
				COUNT <= 0;
				dsacken <= '0';
				
				EMA(12 DOWNTO 0) <= (OTHERS => '0');
				BANK0 <= '0';
				BANK1 <= '0';
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN	

			-- ^^^^^ FOR 25MHz, THIS IS FALLING_EDGE. FOR 50MHz, THIS IS RISING_EDGE.
		
			--PROCEED WITH SDRAM STATE MACHINE.
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO.
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF nMEMZ3 IS ASSERTED.
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED AND WE ARE IN THE ZORRO 3 ADDRESS SPACE.
			
			CASE CURRENT_STATE IS
			
				WHEN PRESTART =>
					--SET THE POWERUP SETTINGS SO THEY ARE LATCHED ON THE NEXT CLOCK EDGE
				
					CURRENT_STATE <= POWERUP;
					sdramcom <= ramstate_NOP;				
			
				WHEN POWERUP =>
					--COLD OR WARM STARTUP. WE RELY ON THE SYSTEM RESET SIGNAL
					--TO PROVIDE THE 200 microsecond NEEDED TO STABALIZE THE SDRAM.

					CURRENT_STATE <= POWERUP_PRECHARGE;
					EMA(12 downto 0) <= ("0010000000000"); --PRECHARGE ALL			
					sdramcom <= ramstate_PRECHARGE;
					EMCLKE <= '1';
					
				WHEN POWERUP_PRECHARGE =>
				
					CURRENT_STATE <= MODE_REGISTER;
					EMA(12 downto 0) <= "0001000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2
					sdramcom <= ramstate_MODEREGISTER;
				
				WHEN MODE_REGISTER =>
				
					--TWO CLOCK CYCLES ARE NEEDED FOR THE REGISTER TO, WELL, REGISTER
					
					IF (COUNT = 0) THEN
						--NOP ON THE SECOND CLOCK DURING MODE REGISTER
						sdramcom <= ramstate_NOP;
					ELSE
						--NOW NEED TO REFRESH TWICE
						CURRENT_STATE <= AUTO_REFRESH;
						sdramcom <= ramstate_AUTOREFRESH;
						sdramstartup <= '0'; --SDRAM IS PROGRAMMED.
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh minimum time is 60ns. We must NOP enough clock cycles to meet this requirement.
					--50MHz IS 20ns PER CYCLE, 40MHz IS 24ns, 33 IS 30ns, 25MHz IS 40ns.
					--SO, 3 CLOCK CYCLES FOR 50 AND 40 MHz AND 2 CLOCK CYCLES FOR 33 AND 25 MHz.					
					
					--ADD A CLOCK CYCLE TO ACHIEVE THE MINIMIM REFRESH TIME OF 60ns
					--THIS IS REALLY ONLY NEEDED AT 40MHz AND GREATER, BUT WE COMPROMISE HERE
					--AND APPLY TO EVERYTHING.
					COUNT <= 0;
					
					CURRENT_STATE <= AUTO_REFRESH_CYCLE;
					sdramcom <= ramstate_NOP;
					
				WHEN AUTO_REFRESH_CYCLE =>
					
					IF (COUNT = 1) THEN 
						--ENOUGH CLOCK CYCLES HAVE PASSED. WE CAN PROCEED.
						
						IF (SDRAM_START_REFRESH_COUNT = '0') THEN		
							--DO WE NEED TO REFRESH AGAIN (STARTUP)?
						
							CURRENT_STATE <= AUTO_REFRESH;
							sdramcom <= ramstate_AUTOREFRESH;
							
							SDRAM_START_REFRESH_COUNT <= '1';
							
						ELSE
						
							--GO TO OUR IDLE STATE AND WAIT.
							CURRENT_STATE <= RUN_STATE;
							sdramcom <= ramstate_NOP;							
							
						END IF;
						
					END IF;		

					COUNT <= COUNT + 1;						
				
				WHEN RUN_STATE =>
				
					IF (refresh = '1') THEN
				
						--TIME TO REFRESH THE SDRAM, WHICH TAKES PRIORITY.	
						CURRENT_STATE <= AUTO_REFRESH;					
						sdramcom <= ramstate_AUTOREFRESH;							
					
					ELSIF memsel = '1' THEN 
						
						--WE ARE IN THE Z3 MEMORY SPACE WITH THE ADDRESS STROBE ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND. 
						
						CURRENT_STATE <= RAS_STATE;
						
						EMA(12 downto 0) <= A(25) & A(21 DOWNTO 10);
						BANK0 <= A(22);
						BANK1 <= A(23);
						
						sdramcom <= ramstate_BANKACTIVATE;							
						
						IF RnW = '0' THEN
						
							--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY ASSERT _DSACKx.
							dsacken <= '1';
							
						END IF;
						
					END IF;
					
				WHEN RAS_STATE =>	
					
					--SET CAS STATE VALUES SO THEY LATCH ON THE NEXT CLOCK EDGE
					CURRENT_STATE <= CAS_STATE;					
					
					EMA(12 downto 0) <= "001" & A(26) & A(24) & A(9 downto 2);
					
					IF RnW = '0' THEN
						--WRITE STATE
						sdramcom <= ramstate_WRITE;
					ELSE
						--READ STATE
						sdramcom <= ramstate_READ;
					END IF;	
					
					COUNT <= 0;
					
				WHEN CAS_STATE =>
					
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES.
					
					--WE NOP FOR THE REMAINING CYCLES.
					sdramcom <= ramstate_NOP;
					
					--IF _DSACKx IS NOT ENABLED FROM A 68030 WRITE CYCLE, ENABLE IT NOW.	
					IF count = 1 THEN
						dsacken <= '1';		
					END IF;
					
					--IF WE ARE NO LONGER IN THE ZORRO 3 MEM SPACE, GO BACK TO START.
					IF memsel = '0' THEN					
										
						dsacken <= '0';
						CURRENT_STATE <= RUN_STATE;		
						
					END IF;	
					
					COUNT <= 1;
				
			END CASE;
				
		END IF;
		
	END PROCESS;
	
	-----------------------------
	-- 68030 DATA TRANSFER ACK --
	-----------------------------	

	DSACK <= '1' WHEN dsacken = '1' ELSE '0';

end Behavioral;

