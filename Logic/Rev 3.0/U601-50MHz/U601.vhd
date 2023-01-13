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
-- Engineer:       JASON NEUS
-- 
-- Create Date:    JANUARY 12, 2023 
-- Design Name:    N2630 U601 CPLD
-- Project Name:   N2630 https://github.com/jasonsbeer/Amiga-N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES 50MHz LOGIC FOR AUTOCONFIG, ZORRO2 SDRAM CONTROLLER, AND GENERAL GLUE LOGIC
--
-- Hardware Revision: 3.x
-- Revision History:
-- 	Initial Production Release xx-JAN-23
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

entity U601 is

PORT
(

	RnW : IN STD_LOGIC; --680x0 READ/WRITE
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	A : IN STD_LOGIC_VECTOR (23 DOWNTO 0); --680x0 ADDRESS LINES, ZORRO 2 ADDRESS SPACE
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	nDS : IN STD_LOGIC; --68030 DATA STROBE
	nRESET : IN STD_LOGIC; --AMIGA RESET SIGNAL
	nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
	nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE
	SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
	FC : IN STD_LOGIC_VECTOR (2 downto 0); --68030 FUNCTION CODES
	OSMODE : IN STD_LOGIC; --J304 UNIX/AMIGA OS
	nCPURESET : IN STD_LOGIC; --68030 RESET SIGNAL
	nHALT : IN STD_LOGIC; --68030 HALT
	nZ2DIS : IN STD_LOGIC; --ZORRO 2 RAM DISABLE
	nZ3DIS : IN STD_LOGIC; --ZORRO 3 RAM AUTOCONFIG DISABLE
	DROM : IN STD_LOGIC_VECTOR (20 DOWNTO 16); --THIS IS FOR THE ROM SPECIAL REGISTER
	nMEMZ3 : IN STD_LOGIC; --ZORRO 3 RAM IS RESPONDING TO THE ADDRESS
	nSENSE : IN STD_LOGIC; --68882 SENSE
	nIDEACCESS : IN STD_LOGIC; --IDE IS RESPONDING TO THE ADDRESS SPACE
	nBOSS : IN STD_LOGIC; --BOSS SIGNAL
	A7M : IN STD_LOGIC; --AMIGA 7MHZ CLOCK
	nRAM8 : IN STD_LOGIC; --8/4MB RAM SELECTION JUMPER
	
	nMEMZ2 : INOUT STD_LOGIC; --ARE WE ACCESSING ZORRO 2 RAM ADDRESS SPACE
	CONFIGED : INOUT STD_LOGIC; --ARE WE AUTOCONFIGED?
	D : INOUT STD_LOGIC_VECTOR (31 DOWNTO 28); --68030 DATA BUS
	nCSROM : INOUT STD_LOGIC; --ROM CHIP SELECT	
	SMDIS : INOUT STD_LOGIC; --STATE MACHINE DISABLE 
	
	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
	nBERR : OUT STD_LOGIC; --BUS ERROR
	nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
	nAVEC : OUT STD_LOGIC; --AUTO VECTORING
	MODE68K : INOUT STD_LOGIC; --ARE WE IN 68000 MODE?	
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
	nDTACK : INOUT STD_LOGIC; --68000 DTACK FOR DMA
	nDSACK : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); --_DSACK1, _DSACK0
	nOVR : OUT STD_LOGIC; --DTACK OVERRIDE
	EMDDIR : OUT STD_LOGIC; --DIRECTION OF MEMORY DATA BUS BUFFERS
	nEMENA : OUT STD_LOGIC; --ENABLE THE MEMORY DATA BUS BUFFERS
	AADIR : OUT STD_LOGIC; --ADDRESS BUS BUFFER DIRECTION
	nAAENA : OUT STD_LOGIC --ADDRESS BUS BUFFER ENABLE

);

end U601;

architecture Behavioral of U601 is
	
	--MEMORY ACCESS SIGNALS
	SIGNAL dmaaccess : STD_LOGIC; --ARE WE IN A DMA MEMORY CYCLE?
	SIGNAL cpuaccess : STD_LOGIC; --ARE WE IN A CPU MEMORY CYCLE?
	SIGNAL dsacken : STD_LOGIC; --FEEDS THE 68030 DSACK SIGNALS
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL dmastatefour : STD_LOGIC; --DMA STATE COUNTER
	SIGNAL dtacken : STD_LOGIC;	
	SIGNAL ramaccess : STD_LOGIC;
	
	--THE SDRAM COMMAND CONSTANTS ARE: _CS, _RAS, _CAS, _WE
	CONSTANT ramstate_NOP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111"; --SDRAM NOP
	CONSTANT ramstate_PRECHARGE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; --SDRAM PRECHARGE ALL;
	CONSTANT ramstate_BANKACTIVATE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ramstate_READ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ramstate_WRITE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ramstate_AUTOREFRESH : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
	CONSTANT ramstate_MODEREGISTER : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	
	--ADDRESS SPACES
	SIGNAL memaccess : STD_LOGIC := '0';
	SIGNAL onboard : STD_LOGIC := '0';
	
	--FPU SIGNALS
	SIGNAL cpuspace : STD_LOGIC;
	SIGNAL fpuspace : STD_LOGIC;
	
	--DEFINE THE SDRAM STATE MACHINE 
	TYPE SDRAM_STATE IS ( PRESTART, POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, RAS_STATE, CAS_STATE ); --AUTO_REFRESH_PRECHARGE, 
	SIGNAL CURRENT_STATE : SDRAM_STATE; --CURRENT SDRAM STATE
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC := '0'; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL COUNT : INTEGER RANGE 0 TO 2; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 255 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER

	--AUTOCONFIG SIGNALS
	SIGNAL autoconfigspace : STD_LOGIC; --AUTOCONFIG ADDRESS SPACE
	SIGNAL romconfiged : STD_LOGIC; --HAS THE ROM BEEN AUTOCONFIGED?
	SIGNAL ram2configed : STD_LOGIC; --HAS THE Z2 RAM BEEN AUTOCONFIGED?
	SIGNAL ram3configed : STD_LOGIC; --HAS THE Z3 RAM BEEN AUTOCONFIGED?
	SIGNAL boardconfiged : STD_LOGIC; --HAS THE ROM AND Z2 RAM FINISHED CONFIGURING?
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR (3 DOWNTO 0); --Z2 AUTOCONFIG DATA
	SIGNAL D_ZORRO3RAM : STD_LOGIC_VECTOR (3 DOWNTO 0); --Z3 AUTOCONFIG DATA
	SIGNAL D_2630 : STD_LOGIC_VECTOR (3 DOWNTO 0); --ROM AUTOCONFIG DATA
	SIGNAL regreset : STD_LOGIC; --REGISTER RESET 
	SIGNAL jmode : STD_LOGIC; --JMODE
	SIGNAL phantomlo : STD_LOGIC; --PHANTOM LOW SIGNAL
	SIGNAL phantomhi : STD_LOGIC; --PHANTOM HIGH SIGNAL
	SIGNAL hirom : STD_LOGIC; --IS THE ROM IN THE HIGH ADDRESS SPACE?
	SIGNAL lorom : STD_LOGIC; --IS THE ROM IN THE LOW ADDRESS SPACE?
	SIGNAL rambaseaddress0 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS	
	SIGNAL rambaseaddress1 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	SIGNAL rambaseaddress2 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	SIGNAL rambaseaddress3 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	SIGNAL ramsize : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE FROM J404
	
	--ROM RELATED SIGNALS
	CONSTANT DELAYVALUE : INTEGER := 1;
	SIGNAL dsackdelay : INTEGER RANGE 0 TO DELAYVALUE + 2;
	SIGNAL dsack_rom : STD_LOGIC;
	
begin

	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--THIS SETS THE DIRECTION OF THE LVC DATA BUFFERS BETWEEN THE 680X0 AND THE SDRAM.
	--EMDDIR <= NOT RnW;
	EMDDIR <= '0' WHEN RnW = '1' ELSE '1';
	
	--ENABLE/DISABLE THE SDRAM BUFFERS
	nEMENA <= '0' WHEN nMEMZ3 = '0' OR nMEMZ2 = '0' ELSE '1';
	
	---------------------
	-- ADDRESS BUFFERS --
	---------------------
	
	--THE AMIGA ADDRESS BUFFERS CONTROL THE FLOW OF THE ADDRESS BUS.
	--WHEN WE ARE BOSS, THE DATA FLOWS FROM THE 2630 TO THE AMIGA 2000.
	--WHEN WE ARE BOSS AND IN A DMA CYCLE, THE DATA FLOWS FROM THE AMIGA 2000 TO THE 2630.
	--WHEN IN 68K MODE, THE DATA FLOWS FROM THE AMIGA 2000 TO THE 2630.
	
	--THE ADDRESS BUFFER DIRECTION
	--AADIR <= '1' WHEN (nBOSS = '0' AND nBGACK = '1') ELSE '0';
	--AADIR <= nBGACK;
	AADIR <= '0' WHEN nBGACK = '0' ELSE '1';
	--AADIR <= '1';
	
	--ENABLE THE ADDRESS BUFFERS WHEN WE ARE BOSS OR WHEN WE ARE IN 68K MODE.
	--LOOKING AT THE LOGIC BELOW, WE BASICALLY NEVER DISABLE THE BUFFERS.
	--THIS MEANS WE COULD TIE IT TO GROUND?
	--nAAENA <= '0' WHEN nBOSS = '0' OR MODE68K = '1' ELSE '1'; 
	--nAAENA <= nBOSS;
	nAAENA <= '0' WHEN nBOSS = '0' ELSE '1';
	
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
	
	--ARE WE IN THE RAM ADDRESS SPACE?
	ramaccess <= '1' 
		WHEN 
			A(23 DOWNTO 21) = rambaseaddress0 OR 
			A(23 DOWNTO 21) = rambaseaddress1 OR 
			A(23 DOWNTO 21) = rambaseaddress2 OR 
			A(23 DOWNTO 21) = rambaseaddress3
		ELSE
			'0';
	
	--THIS DETECTS A 68030 MEMORY ACCESS.
	cpuaccess <= '1' 
		WHEN
			ramaccess = '1' AND			  
			ram2configed = '1' AND
			nBGACK = '1' AND 
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
			nAS = '0' AND nMEMZ3 = '1' AND (cpuaccess = '1' OR dmaaccess = '1')
		ELSE
			'1';
			
	--DURING A DMA CYCLE, WE NEED TO STOP GARY'S _DTACK SIGNAL SO 
	--WE CAN CREATE OUR OWN.
	nOVR <= '0' 
		WHEN 
			dmaaccess = '1' 
		ELSE 
			'Z';	
			
	--dmasattefour IS TO TRACK WHERE WE ARE IN THE DMA (68000) STATES.
	--SINCE THE AMIGA ADDRESS STROBE (_AAS) FALLS ON THE RISING EDGE OF 
	--STATE 2, WE CAN'T DETECT IT UNTIL THE NEXT 7MHz RISING EDGE, WHICH IS STATE 4.
	--THIS WORKS WELL AS STATE 4 IS THE ONE WE REALLY CARE ABOUT.
	--THE SIGNAL ONLY ASSERTS WHEN _AS (_AAS) IS ASSERTED AND THE CURRENT
	--SDRAM STATE IS RUN_STATE. THIS STOPS IT FROM ASSERTING 
	--DURING A REFRESH CYCLE.
		
	PROCESS (A7M, dmaaccess) BEGIN
	
		IF dmaaccess = '0' THEN
		
			dmastatefour <= '0';
			
		ELSIF RISING_EDGE (A7M) THEN
		
			IF nAS = '0' AND CURRENT_STATE = RUN_STATE THEN
			
				dmastatefour <= '1';
				
			END IF;
			
		END IF;
		
	END PROCESS;	
	
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

			IF (nMEMZ2 = '0') THEN		

				IF RnW = '0' THEN
				
					--FOR WRITES, WE ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING 
					--ON WHAT THE ACCESSING DEVICE IS ASKING FOR. DISCUSSION OF PORT 
					--SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL
					--WE ALSO INCLUDE BYTE SELECTION FOR DMA.
					
					--UPPER UPPER BYTE ENABLE (D31..24)
					IF 
						(A(1 downto 0) = "00") OR
						(nBGACK = '0' AND nUDS = '0' AND A(1) = '1')
					THEN			
						datamask(3) <= '0'; 
					ELSE 
						datamask(3) <= '1';
					END IF;

					--UPPER MIDDLE BYTE (D23..16)
					IF 
						(A(1 downto 0) = "01") OR
						(A(1) = '0' AND SIZ(0) = '0') OR
						(A(1) = '0' AND SIZ(1) = '1') OR
						(nBGACK = '0' AND nLDS = '0' AND A(1) = '1') 
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
						(A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0') OR
						(nBGACK = '0' AND nUDS = '0' AND A(1) = '0')
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
						(A(1) = '1' AND SIZ(1) ='1') OR
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
	
	--SDRAM COMMANDS ARE SAMPLED ON THE RISING EDGE. WE ARE SETTING COMMANDS ON THE 
	--FALLING EDGE SO THE COMMANDS ARE STABLE AT THE MOMENT THE SDRAM LATCHES THE COMMAND.
	
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
			
			-- ^^^^ THIS IS FALLING_EDGE FOR 25MHz AND RISING_EDGE FOR 50MHz.
			
			--PROCEED WITH SDRAM STATE MACHINE
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO.
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF nMEMZ2 IS ASSERTED.
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED, WE ARE IN THE ZORRO 2 ADDRESS SPACE, AND THE RAM IS AUTOCONFIGured.
			CASE CURRENT_STATE IS
			
				WHEN PRESTART =>
					--SET THE POWERUP SETTINGS SO THEY ARE LATCHED ON THE NEXT CLOCK EDGE
				
					CURRENT_STATE <= POWERUP;
					sdramcom <= ramstate_NOP;				
			
				WHEN POWERUP =>
					--First power up or warm reset
					--200 microsecond is needed to stabilize. We are going to rely on the 
					--the system reset to give us the needed time, although it might be inadequate.

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
				
					IF (refresh = '1') THEN
				
						--TIME TO REFRESH THE SDRAM, WHICH TAKES PRIORITY.	
						CURRENT_STATE <= AUTO_REFRESH;					
						--ZMA(10 downto 0) <= ("10000000000"); --PRECHARGE ALL
						sdramcom <= ramstate_AUTOREFRESH;							
					
					ELSIF nMEMZ2 = '0' THEN 
					
						--THE N2630 IS WIRED TO ACCEPT UP TO 13 SDRAM ADDRESS LINES, BUT WE ONLY
						--USE 11 FOR THE ROW ADDRESS. THIS IS BECAUASE ZORRO 2 IS LIMITED TO 
						--8MB OF RAM. WIRING IT LIKE THIS ALLOWS US TO USE A VARIETY OF SDRAMs.
						--THE BOM CALLS OUT A PAIR 4Mx16 SDRAMS, BUT SDRAMS WITH GREATER CAPACITY
						--COULD BE USED, IF DESIRED.
						
						--WE ARE IN THE Z2 MEMORY SPACE WITH THE ADDRESS AND DATA STROBES ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND. IN THE EVENT THIS IS A 68030 ACCESS, WE 
						--PROCEED IMMEDIATELY. IF THIS IS A DMA ACCESS, WE NEED TO WAIT UNTIL
						--WE ARE IN 68000 STATE 4 BEFORE PROCEEDING.
						
						IF (dmaaccess = '1' AND dmastatefour = '1') OR cpuaccess = '1' THEN
						
							CURRENT_STATE <= RAS_STATE;
							
							ZMA(10 downto 0) <= A(20 downto 10);
							ZBANK0 <= A(21);
							ZBANK1 <= A(22);
							
							sdramcom <= ramstate_BANKACTIVATE;							
							
							IF (RnW = '0' AND cpuaccess = '1') THEN
							
								--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY ASSERT _DSACKx.
								dsacken <= '1';
								
							ELSIF dmaaccess = '1' THEN
							
								--IF THIS IS A DMA ACTION, WE ALWAYS ASSERT nDTACK IN STATE 4.
								dtacken <= '1';
								
							END IF;
							
						END IF;
						
					END IF;
					
				WHEN RAS_STATE =>	
					
					--BANK ACTIVATE
					--SET CAS STATE VALUES SO THEY LATCH ON THE NEXT CLOCK EDGE
					CURRENT_STATE <= CAS_STATE;
					
					--A7 IS THE MAX ADDRESS BIT FOR THE COLUMN SELECTION.
					--WE USE THE AUTO PRECHARGE COMMAND.
					ZMA(10 downto 0) <= "100" & A(9 downto 2);	
					
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
					IF dsacken = '0' AND COUNT = 1 AND cpuaccess = '1' THEN
					
						dsacken <= '1';	
						
					END IF;
					
					--IF _DTACK IS ENABLED FOR A DMA CYCLE, WE CAN TURN OFF THE ENABLE SIGNAL.
					dtacken <= '0';
					
					--FOR DMA READ CYCLES, WE NEGATE THE SDRAM CLOCK ENABLE SIGNAL.
					--THIS HOLDS THE DATA OUTPUT ON THE BUS UNTIL THE DMA DEVICE
					--HAS RETRIEVED IT (NEGATED _AS). WRITE EVENTS HAPPEN IMMEDIATELY, SO THERE IS 
					--NO NEED TO STOP THE CLOCK FOR THAT CASE.
					
					IF RnW = '1' AND dmaaccess = '1' AND COUNT = 1 THEN
					
						CLKE <= '0';
						
					END IF;
					
					--IF WE ARE NO LONGER IN THE ZORRO 2 MEM SPACE, GO BACK TO START.
					IF nMEMZ2 = '1' THEN					
											
						CURRENT_STATE <= RUN_STATE;
						CLKE <= '1';
						dsacken <= '0';
						
					END IF;	
					
					COUNT <= 1;
				
			END CASE;
				
		END IF;
	END PROCESS;
	
	---------------------------
	-- A2630 ROM CHIP SELECT --
	---------------------------
	
	--THE ROM IS PLACED IN THE RESET VECTOR ($000000) WHEN THE SYSTEM FIRST STARTS/RESTARTS.
	--AT THAT TIME, THE ROM RESPONDS IN THE SPACE AT $000000 - $00FFFF.
	--THE ROM WILL STOP RESPONDING ONCE phantomlo IS SET = 1 AFTER CONFIGURATION.
	
	lorom <= '1' WHEN A(23 DOWNTO 16) = x"00" AND phantomlo = '0' AND RnW = '1' ELSE '0';
	
	--AFTERWARD, THE ROM IS THEN MOVED TO THE ADDRESS SPACE AT $F80000 - $F8FFFF.
	--THIS IS THE "NORMAL" PLACE FOR SYSTEM ROMS.
	--THE ROM WILL STOP RESPONDING ONCE phantomhi IS SET = 1 AFTER CONFIGURATION.
	--AT THAT TIME, KICKSTART TAKES OVER.
	
	hirom <= '1' WHEN A(23 DOWNTO 16) = x"F8" AND phantomhi = '0' AND RnW = '1' ELSE '0';
	
	--THE FINAL ROM CHIP SELECT SIGNAL
	nCSROM <= '0' WHEN (lorom = '1' OR hirom = '1') AND nAS = '0' ELSE '1';	
	
	-----------------------------
	-- 68030 DATA TRANSFER ACK --
	-----------------------------
	
	nDSACK <= 
			"01" WHEN nAS = '0' AND dsack_rom = '1' AND (hirom = '1' OR lorom = '1' OR autoconfigspace = '1') --16 BIT PORT  
		ELSE 
			"00" WHEN nAS = '0' AND dsacken = '1' AND cpuaccess = '1' --32 BIT PORT
		ELSE
			"11" WHEN hirom = '1' OR lorom = '1' OR autoconfigspace = '1' OR cpuaccess = '1' --HOLD BOTH DSACKS FOR NOW
		ELSE
			"ZZ";	
			
	--THIS DELAY EXISTS TO HELP THE 27C256 EPROM AND CPLD PUT VALID DATA ON THE BUS, ESPECIALLY WHEN
	--OPERATING AT 50MHz. THE _DSACK1 SIGNAL IS DELAYED BY THE NUMBER OF CLOCKS SPECIFIED IN THE 
	--delayvalue SIGNAL. THAT GIVES TIME FOR THE SIGNALS FROM THESE DEVICES TO MEET SETUP TIMES.
			
	PROCESS (CPUCLK, nRESET) BEGIN

		IF nRESET = '0' THEN
		
			dsackdelay <= 0;
			dsack_rom <= '0';
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF dsackdelay /= 0 THEN
			
				dsackdelay <= dsackdelay + 1;
				
			END IF;		
			
			CASE dsackdelay IS
			
				WHEN 0 =>
				
					IF nAS = '0' AND (hirom = '1' OR lorom = '1' OR autoconfigspace = '1') THEN
			
						dsackdelay <= 1;
					
					END IF;
					
				WHEN delayvalue =>
				
					dsack_rom <= '1';
					
				WHEN delayvalue + 2 =>
				
					dsackdelay <= 0;
					dsack_rom <= '0';
					
				WHEN others =>	
				
			END CASE;
		
		END IF;

	END PROCESS;
	
	---------------------------
	-- DMA DATA TRANSFER ACK --
	---------------------------
	
	PROCESS (CPUCLK) BEGIN
	
		IF RISING_EDGE (CPUCLK) THEN
		
			IF dmaaccess = '1' THEN
			
				--WE ARE IN THE SDRAM ADDRESS SPACE	AND THIS IS A DMA ACCESS
				IF dtacken = '1' or nDTACK = '0' THEN
				
					nDTACK <= '0';
					
				ELSE
				
					nDTACK <= '1';
					
				END IF;
				
			ELSE
			
				nDTACK <= 'Z';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	---------------------------
	-- STATE MACHINE DISABLE --
	---------------------------
	
	--ASSERT SMDIS (STATE MACHINE DISABLE) WHENEVER WE ARE ACCESSING A RESOURCE
	--ON THE 2630 CARD. THIS INCLUDES ROM, AUTOCONFIG, IDE, ZORRO 2, OR ZORRO 3 
	--MEMORY SPACES. THIS PREVENTS THE 68000 STATE MACHINE FROM STARTING
	--DURING THOSE ACCESS PERIODS.
	
	onboard <= '1' WHEN hirom = '1' OR lorom = '1' OR autoconfigspace = '1' ELSE '0';
	memaccess <= '1' WHEN nIDEACCESS = '0' OR nMEMZ2 = '0' OR nMEMZ3 = '0' ELSE '0';	
	
	SMDIS <= '1' WHEN onboard = '1' OR memaccess = '1' ELSE '0';
	
	-------------------
	-- JOHANN'S MODE --
	-------------------

	--This is a special reset used to reset the ROM configuration registers.  If
   --JMODE (Johann's special mode) is active, we can reset the registers
   --with the CPU.  Otherwise, the registers can only be reset with a cold
   --reset asserted.
	
	PROCESS (CPUCLK) BEGIN
	
		IF RISING_EDGE(CPUCLK) THEN
			IF (jmode = '0' AND nHALT = '0' AND nRESET = '0') OR (jmode = '1' AND nRESET = '0') THEN
				regreset <= '1';
			ELSE
				regreset <= '0';
			END IF;
		END IF;
		
	END PROCESS;
	
	---------------------------------
	-- SPECIAL AUTOCONFIG REGISTER --
	---------------------------------
	
	--THE SPECIAL REGISTER FOR THE A2630 RESIDES AT $E80040, LOWER BYTE.
	--THIS IS USED FOR THE ROM AUTOCONFIG IN PLACE OF THE REGULAR AUTOCONFIG
	--WRITE REGISTER FOUND AT $E80048. THIS REGISTER MAY APPEAR MULTIPLE TIMES,
	--UNTIL ROMCONFIGED IS WRITTEN HIGH. OTHERWISE, THE AUTOCONFIG PROCESS
	--IS IDENTICAL TO ANY OTHER.
	
	--EVEN THOUGH THIS ISN'T WITH THE AUTOCONFIG STUFF, IT
	--RESPONDS IN THE AUTOCONFIG SPACE, WITH _DSACK1 HANDLED THERE.
	
	PROCESS (CPUCLK, regreset) BEGIN
	
		IF (regreset = '1') THEN
		
			phantomlo <= '0';
			phantomhi <= '0';
			romconfiged <= '0';
			jmode <= '0';
			MODE68K <= '0';
	
		ELSIF FALLING_EDGE (CPUCLK) THEN
		
			IF (autoconfigspace = '1' AND A(6 downto 1) = "100000" AND RnW = '0' AND nDS = '0' AND nCPURESET = '1' AND romconfiged = '0') THEN
				phantomlo <= DROM(16);
				phantomhi <= DROM(17);
				romconfiged <= DROM(18);
				jmode <= DROM(19);
				MODE68K <= DROM(20);
			END IF;
			
		END IF;
		
	END PROCESS;
	
	----------------
	-- AUTOCONFIG --
	----------------
	
	--IS EVERYTHING WE WANT CONFIGURED?
	--THIS IS PASSED TO THE _COPCFG SIGNAL, WHICH MUST BE DONE
	--TO ALLOW THE CONFIGURATION CHAIN TO CONTINUE.
	
	CONFIGED <= '1' WHEN boardconfiged = '1' OR MODE68K = '1' ELSE '0';
	
	--We have three boards we need to autoconfig, in this order
	--1. The 68030 ROM. SEE ALSO SPECIAL REGISTER, ABOVE.
	--2. The base memory (4/8MB) in the Zorro 2 space.
	--3. The expansion memory in the Zorro 3 space.

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore.
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition
			
	--BOARDCONFIGED IS ASSERTED WHEN WE ARE DONE CONFIGING THE ROM AND ZORRO 2 MEMORY.
	--WHEN THE ZORRO 2 RAM IS DISABLED BY J303, IT SETS Z2AUTO = 0.
	
	boardconfiged <= '1' WHEN romconfiged = '1' AND (ram2configed = '1' OR nZ2DIS = '0') AND (ram3configed = '1' OR nZ3DIS = '0') ELSE '0';
	
	--WE ARE IN THE Z2 AUTOCONFIG ADDRESS SPACE ($E80000).
	--THIS IS QUALIFIED BY BOARDCONFIGED SO WE STOP RESPONDING TO THE AUTOCONFIG 
	--SPACE ONCE WE ARE COMPLETELY CONFIGURED.
	
	autoconfigspace <= '1'
		WHEN 
			A(23 downto 16) = x"E8" AND boardconfiged = '0'
		ELSE
			'0';				

	--THIS CODE ASSERTS THE AUTOCONFIG DATA ON TO D(31..28),
	--DEPENDING ON WHAT WE ARE AUTOCONFIGing.	
	--We AUTOCONFIG the 2630 FIRST, then the Zorro 2 RAM
	
	D(31 downto 28) <= 
			D_2630
				WHEN romconfiged = '0' AND autoconfigspace = '1' AND RnW = '1' AND nAS = '0'
		ELSE
			D_ZORRO2RAM 
				WHEN nZ2DIS = '1' AND ram2configed = '0' AND autoconfigspace = '1' AND RnW = '1' AND nAS = '0' 
		ELSE
			D_ZORRO3RAM 
				WHEN autoconfigspace = '1' AND RnW = '1' AND nAS = '0'
		ELSE
			"ZZZZ";		
			
	--THE ramsize VECTOR IS USED IN THE AUTOCONFIG SEQUENCE TO SET THE USER'S DESIRED RAM SIZE: 4 OR 8 MB.
	--THE USER IS ALLOWED TO AUTOCONFIG LESS THAN 8MB IN THE EVENT THEY ARE USING A CARD THAT RELIES ON 
	--IT'S OWN ONBOARD MEMORY FOR DMA. SUCH AS THE GVP IMPACT SERIES II CARDS. OUR MEMORY CANNOT BE 
	--SHUT UP. SO, WE DON'T WANT TO BLOCK OUT OTHER PERIPHERALS IF THEY NEED THEIR OWN RAM TO FUNCTION.
	
	ramsize <= "000" WHEN nRAM8 = '1' ELSE "111";
	
	--AUTOCONFIG SEQUENCE, IN ALL ITS GLORY!
	PROCESS ( nDS, nRESET ) BEGIN
	
		IF nRESET = '0' THEN
			
			rambaseaddress0 <= "111";
			rambaseaddress1 <= "111";
			rambaseaddress2 <= "111";
			rambaseaddress3 <= "111";
			
			ram2configed <= '0';			
			ram3configed <= '0';
			
			D_2630 <= "0000";
			D_ZORRO2RAM <= "0000";
			D_ZORRO3RAM <= "0000";
			
		ELSIF FALLING_EDGE (nDS) THEN
		
			IF autoconfigspace = '1' THEN
			
				IF RnW = '1' THEN
				
					CASE A(6 downto 1) IS

						--offset $00 NOT INVERTED
						WHEN "000000" => 
							D_2630 <= "1110"; 
							D_ZORRO2RAM <= "1110"; --er_type: Zorro 2 card without BOOT ROM, LINK TO MEM POOL
							D_ZORRO3RAM <= "1010"; --Z3 Board, LINK TO MEM POOL, NO ROM

						--offset $02 NOT INVERTED
						WHEN "000001" => 						
							
							D_2630 <= "0" & ramsize; 
							D_ZORRO2RAM <= "1" & ramsize; --RAM SIZE AS DETERMINED BY JUMPER J404. NEXT DEVICE IS RELATED.
							D_ZORRO3RAM <= "0100"; --256MB. LET THE OS SIZE THE Z3 RAM IN REGISTER $08.

						--offset $04 INVERTED
						WHEN "000010" => 
							D_2630 <= "1010";
							D_ZORRO2RAM <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number
							D_ZORRO3RAM <= "1111";

						--offset $06 INVERTED
						WHEN "000011" => 
							D_2630 <= "1110";
							D_ZORRO2RAM <= "1110"; --Product Number Lo Nibble
							D_ZORRO3RAM <= "1110";
							
						--offset $08 INVERTED
						WHEN "000100" =>
							D_2630 <= "1111"; 
							D_ZORRO2RAM <= "1011"; --PREFER 8 MEG SPACE, CAN'T BE SHUT UP
							D_ZORRO3RAM <= "0001"; --MEMORY DEVICE, CAN'T BE SHUT UP, EXTENDED RAM SIZE, ZORRO 3 CARD
						
						--offset $0A INVERTED
						WHEN "000101" =>
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111";
							D_ZORRO3RAM <= "1110"; --AUTOSIZED BY OS

						--offset $0C INVERTED						
						WHEN "000110" => 
							D_2630 <= OSMODE & "111"; --THE A2630 CONFIGURES THIS NIBBLE AS "0111" WHEN UNIX, "1111" WHEN AMIGA OS
							D_ZORRO2RAM <= "1111"; --Reserved: must be zeroes
							D_ZORRO3RAM <= "1111";

						--offset $12 INVERTED
						WHEN "001001" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, high byte, low nibble hi byte. Just for fun, lets put C= in here!
							D_ZORRO3RAM <= "1101";

						--offset $16 INVERTED
						WHEN "001011" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, low nibble low byte. Just for fun, lets put C= in here!
							D_ZORRO3RAM <= "1101";

						WHEN OTHERS => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111"; --INVERTED...Reserved offsets and unused offset values are all zeroes
							D_ZORRO3RAM <= "1111";

					END CASE;					

				ELSIF RnW = '0' AND A(6 downto 1) = "100100" THEN
				
					--WRITE REGISTER AT OFFSET $48. THIS IS WHERE THE BASE ADDRESS IS ASSIGNED.
								
					IF ram2configed = '0' AND nZ2DIS = '1' THEN
						
						--THIS IS THE ZORRO 2 RAM BASE ADDRESS.
							
						ram2configed <= '1';
							
						IF nRAM8 = '1' THEN
						
							--WHEN WE ARE AUTOCONFIGing 8MB OF RAM, WE USE UP ALL 
							--THE ADDRESSES OF THE 8MB SPACE, SO THESE ARE THE ONLY
							--POSSIBLE VALUES. 
							
							rambaseaddress0 <= "001";
							rambaseaddress1 <= "010";	
							rambaseaddress2 <= "011";
							rambaseaddress3 <= "100";	
							
						ELSE
							
							--THE USER HAS CHOSEN TO AUTOCONFIGure 4MB.
							--BECAUSE WE HAVE FOUR ADDRESSES TO POPULATE IN OUR LOGIC,
							--WE MAKE DUPLICATES OF THE POSSIBLE TWO 4MB ADDRESSES.
							
							CASE D(31 downto 29) IS
							
								WHEN "001" =>
									rambaseaddress0 <= "001";
									rambaseaddress1 <= "010";	
									rambaseaddress2 <= "001";
									rambaseaddress3 <= "010";	
									
								WHEN "010" =>
									rambaseaddress0 <= "010";
									rambaseaddress1 <= "011";	
									rambaseaddress2 <= "010";
									rambaseaddress3 <= "011";	
									
								WHEN others =>
									rambaseaddress0 <= "011";
									rambaseaddress1 <= "100";	
									rambaseaddress2 <= "011";
									rambaseaddress3 <= "100";
									
							END CASE;			
							
						END IF;
					
					ELSIF ram3configed = '0' THEN
					
						--ACCORDING TO THE MANUAL, Z3 BASE ADDRESS IS ASSIGNED
						--AT $48 FOR ZORRO 3 CARDS AUTOCONFIGed IN AT $E80000.
						
						ram3configed <= '1';
						
					END IF;

				END IF;					
					
			END IF;					
			
		END IF;
		
	END PROCESS;
	
	------------------------
	-- 68030 CACHE ENABLE --
	------------------------
	
	--CACHE INPUT INHIBIT (_CIIN) IS ASSERTED WHEN WE DO NOT WANT
	--THE 68030 TO LOAD DATA INTO ITS INSTRUCTION AND DATA CACHES.
	--MEMORY AND ROM ARE GOOD CANDIDATES FOR CACHING, BUT NOT CHIP
	--RAM BECAUSE AGNUS CAN ALSO USE THAT RAM.
	
	--IS THIS REALLY EVERYTHING WE SHOULD CACHE?
	--THE A2630 GOES ABOUT THIS FROM THE OTHER ANGLE, AND
	--DEACTIVATES THE CACHE OF CERTAIN MEMORY SPACES, RATHER
	--THAN ACTIVATE FOR CERTAIN MEMORY SPACES. THUS, THE C= LOGIC
	--WOULD BE MORE INCLUSIVE.

	nCIIN <= '1' 
		WHEN					
			nMEMZ2 = '0' OR --Zorro 2 Memory Space
			nMEMZ3 = '0' OR --Zorro 3 Memory Space
			A(23 DOWNTO 20) = x"F" OR --ROM SPACE
			A(23 DOWNTO 20) = x"C" --RANGER/SLOW RAM SPACE
		ELSE
			'0';		

	-----------------------
	-- 6888x CHIP SELECT --
	-----------------------
	
	--THE 6888x COPROCESSOR RESPONDS TO CPU SPACE CYCLES (FC = $7) AT
	--A(19..16) = $2. A(15..13) DEFINES COPROCESSOR NUMBER IN A 
	--MULTI-COPROCESSOR ENVIRONMENT. NO AMIGA MODELS HAD MORE THAN ONE
	--FPU, SO WE CAN SAFELY IGNORE THAT PART OF THE ADDRESS.
	
	--THE FPU IS OPTIONAL, SO WE WANT TO GENERATE A BUS ERROR IN THE 
	--EVENT IT IS NOT INSTALLED.
	
	cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0';
	fpuspace <= '1' WHEN A(19 downto 16) = "0010" ELSE '0';
	
	nFPUCS <= '0' WHEN cpuspace = '1' AND fpuspace = '1' AND nBGACK = '1' ELSE '1';
	nBERR <= '0' WHEN cpuspace = '1' AND fpuspace = '1' AND nBGACK = '1' AND nSENSE = '1' ELSE 'Z';
	
	--------------------
	-- AUTO VECTORING --
	--------------------
	
	--This forces all interrupts to be serviced by autovectoring.  None
	--of the built-in devices supply their own vectors, and the system is
	--generally incompatible with supplied vectors, so this shouldn't be
	--a problem working all the time.  During DMA we don't want any AVEC
	--generation, in case the DMA device is like a Boyer HD and doesn't
	--drive the function codes properly.
			
	--SOME TRIVIA...JEFF BOYER HAD A HAND IN DESIGNING SOME OF THE FIRST ZORRO 2
	--PERIPHERALS AT COMMODORE. SUCH CARDS INCLUDE THE A2052 RAM EXPANSION AND THE A2090 AND A2091
	--HARD DRIVE CARDS. AT MIMINUM, HE HAD A HAND IN DEVELOPING THE ORIGINAL DMAC CHIP FOUND ON THE 
	--A2090/A2091. THUS, IT SEEMS THE "BOYER HD" REFERENCED ABOVE IS ANY HARD DRIVE
	--CONTROLLER WITH HIS ORIGINAL DMAC. THAT DESIGN WAS REPLACED BY THE SDMAC IN THE A3000.
	--AGAIN, DESIGNED BY JEFF BOYER.
	
	nAVEC <= '0' WHEN cpuspace = '1' AND A(19 downto 16) = "1111" ELSE '1';

end Behavioral;