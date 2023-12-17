----------------------------------------------------------------------------------
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

entity ZORRO2RAM is

PORT
(

	ram_base_address0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	ram_base_address1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	ram_base_address2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	ram_base_address3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	cpuspace : IN STD_LOGIC;
	ram2configed : IN STD_LOGIC;
	
	RnW : IN STD_LOGIC; --680x0 READ/WRITE
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	A : IN STD_LOGIC_VECTOR (23 DOWNTO 0); --680x0 ADDRESS LINES, ZORRO 2 ADDRESS SPACE
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	nRESET : IN STD_LOGIC; --AMIGA RESET SIGNAL
	nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
	nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE
	SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
	nMEMZ3 : IN STD_LOGIC; --ZORRO 3 RAM IS RESPONDING TO THE ADDRESS
	CLK7 : IN STD_LOGIC; --AMIGA 7MHZ CLOCK
	
	nMEMZ2 : INOUT STD_LOGIC; --ARE WE ACCESSING ZORRO 2 RAM ADDRESS SPACE
	cpuaccess : INOUT STD_LOGIC;
	
	dsacken : OUT STD_LOGIC;	
	ZBANK0 : OUT STD_LOGIC; --BANK0 SIGNAL
	ZBANK1 : OUT STD_LOGIC; --BANK1 SIGNAL
	CLKE : OUT STD_LOGIC; --SDRAM CLOCK ENABLE
	ZMA : OUT STD_LOGIC_VECTOR (12 downto 0); --Z2 SDRAM ADDRESS BUS
	nZCS : OUT STD_LOGIC; --SDRAM CHIP SELECT
	nZWE : OUT STD_LOGIC; --SDRAM WRITE ENABLE
	nZCAS : OUT STD_LOGIC; --SDRAM CAS
	nZRAS : OUT STD_LOGIC; --SDRAM RAS
	nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
	nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
	nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
	nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
	nDTACK : OUT STD_LOGIC; --68000 DTACK FOR DMA
	nOVR : OUT STD_LOGIC; --DTACK OVERRIDE
	EMDDIR : OUT STD_LOGIC; --DIRECTION OF MEMORY DATA BUS BUFFERS
	nEMENA : OUT STD_LOGIC --ENABLE THE MEMORY DATA BUS BUFFERS
	
);


end ZORRO2RAM;

architecture Behavioral of ZORRO2RAM is

	--MEMORY ACCESS SIGNALS
	SIGNAL dmaaccess : STD_LOGIC; --ARE WE IN A DMA MEMORY CYCLE?
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL dmastatefour : STD_LOGIC; --DMA STATE COUNTER
	SIGNAL dtacken : STD_LOGIC;	
	SIGNAL ramaccess : STD_LOGIC;
	SIGNAL uu_enable : STD_LOGIC;
	SIGNAL um_enable : STD_LOGIC;
	SIGNAL lm_enable : STD_LOGIC;
	SIGNAL ll_enable : STD_LOGIC;
	
	--THE SDRAM COMMAND CONSTANTS ARE: _CS, _RAS, _CAS, _WE
	CONSTANT ramstate_NOP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111"; --SDRAM NOP
	CONSTANT ramstate_PRECHARGE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; --SDRAM PRECHARGE ALL;
	CONSTANT ramstate_BANKACTIVATE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ramstate_READ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ramstate_WRITE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ramstate_AUTOREFRESH : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
	CONSTANT ramstate_MODEREGISTER : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";

	--DEFINE THE SDRAM STATE MACHINE 
	TYPE SDRAM_STATE IS ( PRESTART, POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, RAS_STATE, CAS_STATE ); --AUTO_REFRESH_PRECHARGE, 
	SIGNAL CURRENT_STATE : SDRAM_STATE; --CURRENT SDRAM STATE
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC := '0'; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL COUNT : INTEGER RANGE 0 TO 2; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 255 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER

begin

	---------------------
	-- ADDRESS DECODES --
	---------------------
	
	ramaccess <= '1' 
		WHEN 
			A(23 DOWNTO 21) = ram_base_address0 OR 
			A(23 DOWNTO 21) = ram_base_address1 OR 
			A(23 DOWNTO 21) = ram_base_address2 OR 
			A(23 DOWNTO 21) = ram_base_address3
		ELSE
			'0';
			
	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--THIS SETS THE DIRECTION OF THE LVC DATA BUFFERS BETWEEN THE 680X0 AND THE SDRAM.
	--EMDDIR <= NOT RnW;
	EMDDIR <= '0' WHEN RnW = '1' ELSE '1';
	
	--ENABLE/DISABLE THE SDRAM BUFFERS
	nEMENA <= '0' WHEN nMEMZ3 = '0' OR nMEMZ2 = '0' ELSE '1';
			
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
	
	PROCESS (CLK7, refreset) BEGIN
	
		IF refreset = '1' THEN
		
			REFRESH_COUNTER <= 0;			
			
		ELSIF RISING_EDGE (CLK7) THEN
		
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
	
	---------------
	-- RAM STUFF --
	---------------

	--EITHER THE 68030 OR DMA FROM THE ZORRO 2 BUS CAN ACCESS ZORRO 2 RAM ON OUR CARD.
	
	--THIS DETECTS A 68030 MEMORY ACCESS.
	cpuaccess <= '1' 
		WHEN
			ramaccess = '1' AND			  
			ram2configed = '1' AND
			nBGACK = '1' AND 
			nMEMZ3 = '1' AND
			cpuspace = '0'
		ELSE
			'0';
	
	--THIS DETECTS A DMA MEMORY ACCESS. REMEMBER THE AMIGA 
	--ADDRESS STROBE IS CONNECTED TO _AS WHEN IN DMA MODE.
	dmaaccess <= '1'
		WHEN
			ramaccess = '1' AND
			ram2configed = '1' AND 
			nBGACK = '0'
		ELSE
			'0';
			
	--QUALIFY THE ZORRO 2 MEM SPACE ACCESS WITH _MEMZ3 TO PREVENT ERRONEOUS ACCESS.
	nMEMZ2 <= '0' 
		WHEN
			nAS = '0' AND (cpuaccess = '1' OR dmaaccess = '1')
		ELSE
			'1';
			
	--DURING A DMA CYCLE, WE NEED TO STOP GARY'S _DTACK SIGNAL SO 
	--WE CAN CREATE OUR OWN.
	nOVR <= '0' 
		WHEN 
			dmaaccess = '1' 
		ELSE 
			'Z';	
			
	--dmasattefour IS TO TRACK WHERE WE ARE IN THE DMA (MC68000) STATES.
	--SINCE THE AMIGA ADDRESS STROBE (_AAS) FALLS ON THE RISING EDGE OF 
	--STATE 2, WE CAN'T DETECT IT UNTIL THE NEXT 7MHz RISING EDGE, WHICH IS STATE 4.
	--THIS WORKS WELL AS STATE 4 IS THE ONE WE REALLY CARE ABOUT.
	--THE SIGNAL ONLY ASSERTS WHEN _AS (_AAS) IS ASSERTED AND THE CURRENT
	--SDRAM STATE IS RUN_STATE. THIS STOPS IT FROM ASSERTING 
	--DURING A REFRESH CYCLE.
		
	PROCESS (CLK7, nRESET, nAS) BEGIN
	
		IF nRESET = '0' OR nAS = '1' THEN
		
			dmastatefour <= '0';
			
		ELSIF RISING_EDGE (CLK7) THEN
			
			--DETECT STATE FOUR
			IF nAS = '0' AND dmaaccess = '1' THEN
			
				dmastatefour <= '1';
				
			END IF;
			
			--dmastatefour <= !nAS AND dmaaccess;
			
		END IF;
		
	END PROCESS;	
	
	-----------------------------
	-- SDRAM DATA MASK ACTIONS --
	-----------------------------		
		
	--FOR WRITES, WE ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING 
	--ON WHAT THE ACCESSING DEVICE IS ASKING FOR. DISCUSSION OF PORT 
	--SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL.
	
	nUUBE <= datamask(3);
	nUMBE <= datamask(2);
	nLMBE <= datamask(1);
	nLLBE <= datamask(0);	
	
	uu_enable <= 
			'1' WHEN A(1 downto 0) = "00" 
		ELSE 
			'0';	
	
	um_enable <= 
			'1' WHEN A(1 downto 0) = "01" 
			    OR (A(1) = '0' AND SIZ(0) = '0') 
				 OR (A(1) = '0' AND SIZ(1) = '1') 
		ELSE 
			'0';
	
	lm_enable <= 
			'1' WHEN A(1 downto 0) = "10" 
			    OR (A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0')
				 OR (A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1')
				 OR (A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0')
		ELSE 
			'0';	
	
	ll_enable <= 
			'1' WHEN A(1 downto 0) = "11" 
			    OR (A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1') 
				 OR (SIZ(0) = '0' AND SIZ(1) = '0')
				 OR (A(1) = '1' AND SIZ(1) ='1')
		ELSE
			'0'; 
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF nRESET = '0' THEN 
		
			datamask <= "1111";
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN

			IF (nMEMZ2 = '0') THEN		

				IF RnW = '0' THEN			
				
					--THIS IS A WRITE EVENT. ENABLE THE DATA MASKS ON THE SDRAM.
					--WE ALSO INCLUDE BYTE SELECTION (DATA MASKS) FOR DMA EVENTS.
					
					--UPPER UPPER BYTE ENABLE (D31..24)
					IF 
						(nBGACK = '1' AND uu_enable = '1') OR
						(nBGACK = '0' AND nUDS = '0' AND A(1) = '1')
					THEN			
						datamask(3) <= '0'; 
					ELSE 
						datamask(3) <= '1';
					END IF;

					--UPPER MIDDLE BYTE (D23..16)
					IF 
						(nBGACK = '1' AND um_enable = '1') OR
						(nBGACK = '0' AND nLDS = '0' AND A(1) = '1') 
					THEN
						datamask(2) <= '0';
					ELSE
						datamask(2) <= '1';
					END IF;

					--LOWER MIDDLE BYTE (D15..8)
					IF 
						(nBGACK = '1' AND lm_enable = '1') OR
						(nBGACK = '0' AND nUDS = '0' AND A(1) = '0')
					THEN
						datamask(1) <= '0';
					ELSE
						datamask(1) <= '1';
					END IF;

					--LOWER LOWER BYTE (D7..0)
					IF 
						(nBGACK = '1' AND ll_enable = '1') OR
						(nBGACK = '0' AND nLDS = '0' AND A(1) = '0')
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
	
	--THE N2630 IS WIRED TO ACCEPT UP TO 13 SDRAM ADDRESS LINES, BUT WE ONLY
	--USE 11 FOR THE ROW ADDRESS. THIS IS BECAUASE ZORRO 2 IS LIMITED TO 
	--8MB OF RAM. WIRING IT LIKE THIS ALLOWS US TO USE A VARIETY OF SDRAMs.
	--THE BOM CALLS OUT A PAIR 4Mx16 SDRAMS, BUT SDRAMS WITH GREATER CAPACITY
	--COULD BE USED, IF DESIRED.
	
	--MEMORY MAP 
	--3210987654321098765432 10 ADDRESS BITS
	
	--0010000000000000000000 00 $200000-$3FFFFF
	--0011111111111111111111 11

	--0100000000000000000000 00 $400000-$5FFFFF
	--0101111111111111111111 11

	--0110000000000000000000 00 $600000-$7FFFFF
	--0110111111111111111111 11

	--1000000000000000000000 00 $800000-$9FFFFF
	--1001111111111111111111 11
	
	nZCS <= sdramcom(3);
	nZRAS <= sdramcom(2);
	nZCAS <= sdramcom(1);	
	nZWE <= sdramcom(0);	
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF (nRESET = '0') THEN 
		
				--THE AMIGA HAS BEEN RESET OR JUST POWERED UP
				CURRENT_STATE <= PRESTART;				
				sdramcom <= ramstate_NOP;				
				SDRAM_START_REFRESH_COUNT <= '0';					
				CLKE <= '0';
				COUNT <= 0;
				dsacken <= '0';
				dtacken <= '0';
				
				ZMA(12 DOWNTO 0) <= (OTHERS => '0');
				ZBANK0 <= '0';
				ZBANK1 <= '0';
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN
			
			CASE CURRENT_STATE IS
			
				WHEN PRESTART =>
					--SET THE POWERUP SETTINGS SO THEY ARE LATCHED ON THE NEXT CLOCK EDGE
				
					CURRENT_STATE <= POWERUP;
					sdramcom <= ramstate_NOP;				
			
				WHEN POWERUP =>

					CURRENT_STATE <= POWERUP_PRECHARGE;
					ZMA(10 downto 0) <= ("10000000000"); --PRECHARGE ALL			
					sdramcom <= ramstate_PRECHARGE;
					CLKE <= '1';
					
				WHEN POWERUP_PRECHARGE =>
				
					CURRENT_STATE <= MODE_REGISTER;
					ZMA(10 downto 0) <= "01000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2
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
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh minimum time is 60ns. We must NOP enough clock cycles to meet this requirement.
					--50MHz IS 20ns PER CYCLE, 40MHz IS 24ns, 33 IS 30ns, 25MHz IS 40ns.
					--SO, 3 CLOCK CYCLES FOR 50 AND 40 MHz AND 2 CLOCK CYCLES FOR 33 AND 25 MHz.
					
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
				
						--TIME TO REFRESH THE SDRAM, WHICH ALWAYS TAKES PRIORITY.	
						CURRENT_STATE <= AUTO_REFRESH;					
						sdramcom <= ramstate_AUTOREFRESH;							
					
					ELSIF nMEMZ2 = '0' THEN 
					
						--WE ARE IN THE ZORRO 2 MEM SPACE WITH THE ADDRESS STROBE ASSERTED.
						
						IF cpuaccess = '1' THEN
						
							--THIS IS AN ACCESS BY THE MC68030. PROCEED RIGHT AWAY.
						
							CURRENT_STATE <= RAS_STATE;
							sdramcom <= ramstate_BANKACTIVATE;
							
							ZMA(10 downto 0) <= A(20 downto 10);
							ZBANK0 <= A(21);
							ZBANK1 <= A(22);
							
							IF RnW = '0' THEN
							
								dsacken <= '1';
								
							END IF;
						
						ELSIF dmaaccess = '1' AND dmastatefour = '1' THEN
						
							--THIS IS A DMA ACCESS. WAIT UNTIL OUR DATA MASKS ARE ASSERTED BEFORE PROCEEDING.
						
							IF datamask(3) = '0' OR datamask(2) = '0' OR datamask(1) = '0' OR datamask(0) = '0' THEN
							
								CURRENT_STATE <= RAS_STATE;
								sdramcom <= ramstate_BANKACTIVATE;
								
								ZMA(10 downto 0) <= A(20 downto 10);
								ZBANK0 <= A(21);
								ZBANK1 <= A(22);								
							
							END IF;
							
							dtacken <= '1';
							
						END IF;
						
					END IF;
					
				WHEN RAS_STATE =>	
					
					CURRENT_STATE <= CAS_STATE;
					
					--A7 IS THE MAX ADDRESS BIT FOR THE COLUMN SELECTION.
					--WE USE THE AUTO PRECHARGE COMMAND.
					ZMA(10 downto 0) <= "100" & A(9 downto 2);	
					
					IF RnW = '0' THEN
						sdramcom <= ramstate_WRITE;
					ELSE
						sdramcom <= ramstate_READ;
					END IF;	
					
					COUNT <= 0;
					
				WHEN CAS_STATE =>
					
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES.
					
					--WE NOP FOR THE REMAINING CYCLES.
					sdramcom <= ramstate_NOP;
					
					--IF _DSACKx IS NOT ENABLED FROM A 68030 WRITE CYCLE, ENABLE IT NOW.
					IF COUNT = 1 AND cpuaccess = '1' THEN
					
						dsacken <= '1';	
						
					END IF;					
					
					--FOR DMA READ CYCLES, WE NEGATE THE SDRAM CLOCK ENABLE SIGNAL.
					--THIS HOLDS THE DATA OUTPUT ON THE BUS UNTIL THE DMA DEVICE
					--HAS LATCHED IT (NEGATED _AS). WRITE EVENTS HAPPEN IMMEDIATELY, SO THERE IS 
					--NO NEED TO STOP THE CLOCK FOR THAT CASE.
					
					IF RnW = '1' AND dmaaccess = '1' THEN
					
						CLKE <= '0';
						
					END IF;
					
					--IF WE ARE NO LONGER IN THE ZORRO 2 MEM SPACE, GO BACK TO START.
					IF nMEMZ2 = '1' THEN					
											
						CURRENT_STATE <= RUN_STATE;
						CLKE <= '1';
						dsacken <= '0';
						dtacken <= '0';
						
					END IF;	
					
					COUNT <= 1;
				
			END CASE;
				
		END IF;
	END PROCESS;


	---------------------------
	-- DMA DATA TRANSFER ACK --
	---------------------------
	
	nDTACK <= '0' WHEN dmaaccess = '1' AND dtacken = '1' AND dmastatefour = '1' ELSE '1' WHEN dmaaccess = '1' ELSE 'Z';

end Behavioral;

