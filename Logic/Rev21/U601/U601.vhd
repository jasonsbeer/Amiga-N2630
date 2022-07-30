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
-- Create Date:    JULY 30, 2022 
-- Design Name:    N2630 U601 CPLD
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES LOGIC FOR ZORRO 2 AUTOCONFIG, ZORRO2 SDRAM CONTROLLER, AND GENERAL GLUE LOGIC
--
-- Revision: 
-- Revision 1.0 - Original Release
-- Additional Comments: SPECIAL THANKS TO DAVE HAYNIE FOR RELEASING THE A2630 PAL LOGIC EQUATIONS.
--                      ORIGINAL PAL EQUATIONS BY C= COMMODORE.
--                      TRANSLATIONS AND ORIGINAL EQUATIONS FOR THE A30 PROJECT BY JASON NEUS.
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
	REF : IN STD_LOGIC; --SDRAM REFRESH SIGNAL
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	A : IN STD_LOGIC_VECTOR (23 DOWNTO 0); --680x0 ADDRESS LINES, ZORRO 2 ADDRESS SPACE
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	nAAS : IN STD_LOGIC; --68000 ADDRESS STROBE
	nDS : IN STD_LOGIC; --68030 DATA STROBE
	nRESET : IN STD_LOGIC; --AMIGA RESET SIGNAL
	nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
	nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE
	SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
	FC : IN STD_LOGIC_VECTOR (2 downto 0); --68030 FUNCTION CODES
	J404 : IN STD_LOGIC; --CPU CLOCK SPEED
	OSMODE : IN STD_LOGIC; --J304 UNIX/AMIGA OS
	nCPURESET : IN STD_LOGIC; --68030 RESET SIGNAL
	nHALT : IN STD_LOGIC; --68030 HALT
	Z2AUTO : IN STD_LOGIC; --J303 ZORRO 2 DISABLE
	DROM : IN STD_LOGIC_VECTOR (20 DOWNTO 16); --THIS IS FOR THE ROM SPECIAL REGISTER
	nMEMZ3 : IN STD_LOGIC; --ZORRO 3 RAM IS RESPONDING TO THE ADDRESS (WAS EXTSEL)
	nSENSE : IN STD_LOGIC; --68882 SENSE
	nZ3CONFIGED : IN STD_LOGIC; --IS ZORRO 3 RAM CONFIGURED?	
	nIDEACCESS : IN STD_LOGIC; --IDE IS RESPONDING TO THE ADDRESS SPACE
	nBOSS : IN STD_LOGIC; --BOSS SIGNAL
	
	nMEMZ2 : INOUT STD_LOGIC; --ARE WE ACCESSING ZORRO 2 RAM ADDRESS SPACE
	nREFACKZ2 : INOUT STD_LOGIC; --REFRESH ACK
	CONFIGED : INOUT STD_LOGIC; --ARE WE AUTOCONFIGED?
	D : INOUT STD_LOGIC_VECTOR (31 DOWNTO 28); --68030 DATA BUS
	nCSROM : INOUT STD_LOGIC; --ROM CHIP SELECT
	
	SMDIS : INOUT STD_LOGIC := '0'; --STATE MACHINE DISABLE (WAS nONBOARD)
	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
	nBERR : OUT STD_LOGIC; --BUS ERROR
	nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
	nAVEC : OUT STD_LOGIC; --AUTO VECTORING
	MODE68K : OUT STD_LOGIC; --ARE WE IN 68000 MODE?	
	ZBANK0 : OUT STD_LOGIC; --BANK0 SIGNAL
	ZBANK1 : OUT STD_LOGIC; --BANK1 SIGNAL
	CLKE : OUT STD_LOGIC; --SDRAM CLOCK ENABLE
	ZMA : OUT STD_LOGIC_VECTOR (10 downto 0); --Z2 SDRAM ADDRESS BUS
	nZCS : OUT STD_LOGIC; --SDRAM CHIP SELECT
	nZWE : OUT STD_LOGIC; --SDRAM WRITE ENABLE
	nZCAS : OUT STD_LOGIC; --SDRAM CAS
	nZRAS : OUT STD_LOGIC; --SDRAM RAS
	nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
	nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
	nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
	nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
	nDTACK : OUT STD_LOGIC; --68000 DTACK FOR DMA
	nDSACK0 : OUT STD_LOGIC; --68030 DSACK
	nDSACK1 : OUT STD_LOGIC;
	nOVR : OUT STD_LOGIC; --DTACK OVERRIDE
	EMDDIR : OUT STD_LOGIC; --DIRECTION OF MEMORY DATA BUS BUFFERS
	nEMENA : OUT STD_LOGIC; --ENABLE THE MEMORY DATA BUS BUFFERS
	AADIR : OUT STD_LOGIC; --ADDRESS BUS BUFFER DIRECTION
	nAAENA : OUT STD_LOGIC --ADDRESS BUS BUFFER ENABLE

);

end U601;

architecture Behavioral of U601 is
	
	--MEMORY ACCESS SIGNALS
	SIGNAL dmaaccess : STD_LOGIC := '0'; --ARE WE IN A DMA MEMORY CYCLE?
	SIGNAL cpuaccess : STD_LOGIC := '0'; --ARE WE IN A CPU MEMORY CYCLE?
	SIGNAL dsack : STD_LOGIC := '1'; --FEEDS THE 68030 DSACK SIGNALS
	
	--ADDRESS SPACES
	--SIGNAL chipram : STD_LOGIC:='0';
	--SIGNAL ciaspace : STD_LOGIC:='0';
	--SIGNAL chipregs : STD_LOGIC:='0';
	--SIGNAL iospace	 : STD_LOGIC:='0';
	
	--68030 FUNCTION CODES
	--SIGNAL userdata : STD_LOGIC:='0';
	--SIGNAL superdata : STD_LOGIC:='0';	
	--SIGNAL cpuspace : STD_LOGIC:='0';
	
	--INTERRUPT
	--SIGNAL interruptack : STD_LOGIC:='0';
	
	--FPU SIGNALS
	SIGNAL coppercom : STD_LOGIC:='0';
	SIGNAL mc68881 : STD_LOGIC:='0';
	
	--DEFINE THE SDRAM STATE MACHINE 
	TYPE SDRAM_STATE IS ( PRESTART, POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, RAS_STATE, CAS_STATE );
	SIGNAL CURRENT_STATE : SDRAM_STATE; --CURRENT SDRAM STATE
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES

	--AUTOCONFIG SIGNALS
	SIGNAL autoconfigspace : STD_LOGIC := '0'; --AUTOCONFIG ADDRESS SPACE
	SIGNAL romconfiged : STD_LOGIC := '0'; --HAS THE ROM BEEN AUTOCONFIGED?
	SIGNAL ramconfiged : STD_LOGIC := '0'; --HAS THE Z2 RAM BEEN AUTOCONFIGED?
	SIGNAL boardconfiged : STD_LOGIC := '0'; --HAS THE ROM AND Z2 RAM FINISHED CONFIGURING?
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR (3 DOWNTO 0); --Z2 AUTOCONFIG DATA
	SIGNAL D_2630 : STD_LOGIC_VECTOR (3 DOWNTO 0); --ROM AUTOCONFIG DATA
	SIGNAL regreset : STD_LOGIC := '0'; --REGISTER RESET 
	SIGNAL jmode : STD_LOGIC := '0'; --JMODE
	SIGNAL phantomlo : STD_LOGIC := '0'; --PHANTOM LOW SIGNAL
	SIGNAL phantomhi : STD_LOGIC := '0'; --PHANTOM HIGH SIGNAL
	SIGNAL hirom : STD_LOGIC := '0'; --IS THE ROM IN THE HIGH ADDRESS SPACE?
	SIGNAL lorom : STD_LOGIC := '0'; --IS THE ROM IN THE LOW ADDRESS SPACE?
	SIGNAL rambaseaddress : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; --RAM BASE ADDRESS	
	SIGNAL acdsack : STD_LOGIC := '1';
	
	--ROM RELATED SIGNALS
	CONSTANT DELAYVALUE : INTEGER := 3;
	SIGNAL dsackdelay : STD_LOGIC_VECTOR ( DELAYVALUE DOWNTO 0 ) := (OTHERS => '0') ; --DELAY DSACK CYCLE
	
begin

	--chipram <= '1' WHEN A(23 downto 12) >= x"000" AND A(23 downto 12) <= x"1FF"  ELSE '0'; 
	--chipram		= (cpuaddr:[000000..1fffff]) ;    /* All Chip RAM */ 0-000111111111111111111111
	--busspace	= (cpuaddr:[200000..9fffff]) ;    /* Main expansion bus */ 001000000000000000000000-100111111111111111111111
	--ciaspace <= '1' WHEN A(23 downto 12) >= x"A00" AND A(23 downto 12) <= x"BFF" ELSE '0';
	--ciaspace	= (cpuaddr:[a00000..bfffff]) ;    /* VPA decode */ 101000000000000000000000-101111111111111111111111
	--extraram	= (cpuaddr:[c00000..cfffff]) ;    /* Motherboard RAM */ 110000000000000000000000-110011111111111111111111
	--chipregs <= '1' WHEN A(23 downto 12) >= x"D00" AND A(23 downto 12) <= x"DFF" ELSE '0';
	--chipregs	= (cpuaddr:[d00000..dfffff]) ;    /* Custom chip registers */ 110100000000000000000000-110111111111111111111111
	--iospace <= '1' WHEN A(23 downto 12) >= x"E80" AND A(23 downto 12) <= x"EFF" ELSE '0';
	--iospace		= (cpuaddr:[e80000..efffff]) ;    /* I/O expansion bus */ 111010000000000000000000-111011111111111111111111
	--romspace	= (cpuaddr:[f80000..ffffff]) ;    /* All ROM */ 111110000000000000000000-111111111111111111111111

	--cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0'; --(cpustate:7)

	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--This sets the direction of the LVC data buffers between the 680x0 and the RAM
	--We simply go with the inverse of the RW signal.
	EMDDIR <= NOT RnW;
	
	--ENABLE/DISABLE THE SDRAM BUFFERS
	nEMENA <= '0' WHEN nAS = '0' AND ( nMEMZ3 = '0' OR nMEMZ2 = '0' ) ELSE '1';
	
	---------------------
	-- ADDRESS BUFFERS --
	---------------------
	
	--THE AMIGA ADDRESS BUFFERS CONTROL THE FLOW OF THE ADDRESS BUS.
	--WHEN WE ARE BOSS, THE DATA FLOWS FROM THE 2630 TO THE AMIGA 2000.
	--WHEN WE ARE BOSS AND IN A DMA CYCLE, THE DATA FLOWS FROM THE AMIGA 2000 TO THE 2630.
	--WHEN IN 68K MODE, THE DATA FLOWS TO THE 2630.
	
	--THE ADDRESS BUFFER DIRECTION
	--AADIR <= '1' WHEN (nBOSS = '0' AND nBGACK = '1') ELSE '0';
	AADIR <= nBGACK;	
	
	--ENABLE THE BUFFERS WHEN WE ARE BOSS OR WHEN WE ARE IN 68K MODE.
	--nAAENA <= '0' WHEN nBOSS = '0' OR MODE68K = '1' ELSE '1'; 
	nAAENA <= nBOSS;
	
	---------------
	-- RAM STUFF --
	---------------

	--EITHER THE 68030 OR DMA FROM THE ZORRO 2 BUS CAN ACCESS ZORRO 2 RAM ON OUR CARD
	--SIMULATES OK
	
	--THE 8MB DATA SPACE USES UP TO (AND INCLUDING) A21.
	--THIS MEANS WHEN 8MBs ARE INSTALLED, WE RESPOND WHEN A23..22 = BASEADDRESS.
	--WITH 4MBs INSTALLED, WE RESPOND WHEN A23..21 = BASEADDRESS.
	--WITH 2MBs INSTALLED, WE RESPOND WHEN A23..20 = BASEADDRESS.
	--WITH 1MB INSTALLED, WE RESPOND WHEN A23..19 = BASEADDRESS.
	
	--THIS DETECTS A 68030 MEMORY ACCESS
	cpuaccess <= '1' 
		WHEN
			ramconfiged = '1' AND A(23 DOWNTO 21) = rambaseaddress AND nAS = '0' AND nBGACK = '1' AND FC(2 downto 0) /= "111"
		ELSE
			'0';
	
	--THIS DETECTS A DMA MEMORY ACCESS
	dmaaccess <= '1'
		WHEN
			ramconfiged = '1' AND A(23 DOWNTO 21) = rambaseaddress AND nAAS = '0' AND nBGACK = '0'
		ELSE
			'0';
			
	nMEMZ2 <= '0' 
		WHEN
			cpuaccess = '1' OR dmaaccess = '1'
		ELSE
			'1';
			
	--The OVR signal must be asserted whenever on-board memory is selected
	--during a DMA cycle.  It tri-states GARY's DTACK output, allowing
	--one to be created by our memory logic. u501

	nOVR <= '0' 
		WHEN 
			dmaaccess = '1' 
		ELSE 
			'Z';	
	
	-------------------------------------
	-- SDRAM FALLING CLOCK EDGE ACTIONS --
	-------------------------------------
	
	PROCESS ( CPUCLK ) BEGIN
		
		IF ( FALLING_EDGE (CPUCLK) ) THEN

			IF (nMEMZ2 = '0') THEN		

				--ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING ON WHAT THE ACCESSING DEVICE IS ASKING FOR. U603
				--DISCUSSION OF PORT SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL
				--WE ALSO INCLUDE BYTE SELECTION FOR DMA.
				
				--UPPER UPPER BYTE ENABLE (D31..24)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "00" AND nDS = '0') OR
					(nBGACK = '0' AND nUDS = '0' AND A(1) = '1'))
				THEN			
					nUUBE <= '0'; 
				ELSE 
					nUUBE <= '1';
				END IF;

				--UPPER MIDDLE BYTE (D23..16)
				IF 
					(( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "01" AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '0' AND nLDS = '0' AND A(1) = '1')) 
				THEN
					nUMBE <= '0';
				ELSE
					nUMBE <= '1';
				END IF;

				--LOWER MIDDLE BYTE (D15..8)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "10" AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '1' AND A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0' AND nDS = '0') OR
					(nBGACK = '0' AND nUDS = '0' AND A(1) = '0'))
				THEN
					nLMBE <= '0';
				ELSE
					nLMBE <= '1';
				END IF;

				--LOWER LOWER BYTE (D7..0)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "11" AND nDS = '0' ) OR
					(nBGACK = '1' AND A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '1' AND SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '1' AND SIZ(1) ='1' AND nDS = '0') OR
					(nBGACK = '0' AND nLDS = '0' AND A(1) = '0'))
				THEN
					nLLBE <= '0';
				ELSE
					nLLBE <= '1';
				END IF;	

			ELSE 
				--DEACTIVATE ALL THE RAM BYTE MASKS

				nUUBE <= '1';
				nUMBE <= '1';
				nLMBE <= '1';
				nLLBE <= '1';

			END IF;	
		END IF;
	END PROCESS;
	
	---------------------------
	-- SDRAM COMMAND ACTIONS --
	---------------------------
	
	--SDRAM COMMANDS ARE SAMPLED ON THE RISING EDGE. WE ARE SETTING COMMANDS ON THE 
	--FALLING EDGE SO THE COMMANDS ARE STABLE AT THE MOMENT THE SDRAM LATCHES THE COMMAND.
	--SDRAM COMMANDS ALL SIMULATE OK
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF (nRESET = '0') THEN 
				--THE AMIGA HAS BEEN RESET OR JUST POWERED UP
				CURRENT_STATE <= PRESTART;
				SDRAM_START_REFRESH_COUNT <= '0';
				
				nZCAS <= '1';
				nZRAS <= '1';
				nZWE <= '1';
				nZCS <= '1';
				CLKE <= '0';
				COUNT <= 0;
				nDTACK <= 'Z';
				nREFACKZ2 <= '1';
				dsack <= '1';
		
		ELSIF ( FALLING_EDGE (CPUCLK) ) THEN
			
			--WE CANNOT USE BURST MODE IN Z2 RAM, WHICH ONLY WORKS WITH STERM TERMINATED ACTIONS.
			--ZORRO 2 RAM ACCESSES ARE ALL ASYNCHROUNOUS.
			
			--SDRAM is pretty fast. Most operations will complete in less than one 50MHz clock cycle. 
			--Only AUTOREFRESH takeS more than one clock cycle at 60ns. 			
			
			--WE WATCH FOR THE REF(RESH) SIGNAL FROM U600 TO TELL US WHEN TO REFRESH THE SDRAM.
			--WHEN REF IS ASSERTED, WE WAIT UNTIL WE ARE NOT IN MEMORY CYCLE AND THEN
			--ACKNOWLEDGE THE REFRESH BY ASSERTING REFACK2. WE ASSERT REFACK2 UNTIL
			--REF IS NEGATED.
			
			IF (REF = '1') THEN
			
				IF (nREFACKZ2 = '1') THEN
				
					--TIME TO REFRESH THE SDRAM, BUT ONLY IF WE ARE NOT IN THE MIDDLE OF A MEMORY ACCESS CYCLE
					IF nMEMZ2 = '1' THEN
					
						CURRENT_STATE <= AUTO_REFRESH;
						nZWE <= '1';
						nZRAS <= '0';
						nZCAS <= '0';
						nZCS <= '0';
						
						nREFACKZ2 <= '0';
						
					END IF;
					
				END IF;
					
			ELSE
				
				IF (nREFACKZ2 = '0') THEN
				
					--NEGATE REFACKZ2
					nREFACKZ2 <= '1';
					
				END IF;
				
			END IF;
		
			--PROCEED WITH SDRAM STATE MACHINE
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO.
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF nMEMZ2 IS ASSERTED.
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED, WE ARE IN THE ZORRO 2 ADDRESS SPACE, AND THE RAM IS AUTOCONFIGured.
			CASE CURRENT_STATE IS
			
				WHEN PRESTART =>
					--SET THE POWERUP SETTINGS SO THEY ARE LATCHED ON THE NEXT CLOCK EDGE
				
					CURRENT_STATE <= POWERUP;
					CLKE <= '0'; --DISABLE CLOCK
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '1'; --NOP STATE					
			
				WHEN POWERUP =>
					--First power up or warm reset
					--200 microsecond is needed to stabilize. We are going to rely on the 
					--the system reset to give us the needed time, although it might be inadequate.

					CURRENT_STATE <= POWERUP_PRECHARGE;
					ZMA <= ("10000000000"); --PRECHARGE ALL			
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '1';
					nZCS <= '0';
					CLKE <= '1';
					
				WHEN POWERUP_PRECHARGE =>
				
					CURRENT_STATE <= MODE_REGISTER;
					ZMA <= "01000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2,
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '0';
					nZCS <= '0';	
				
				WHEN MODE_REGISTER =>
				
					--TWO CLOCK CYCLES ARE NEEDED FOR THE REGISTER TO, WELL, REGISTER
					
					IF (COUNT = 0) THEN
						--NOP ON THE SECOND CLOCK DURING MODE REGISTER
						nZWE <= '1';
						nZRAS <= '1';
						nZCAS <= '1';
						nZCS <= '1';
					ELSE
						--NOW NEED TO REFRESH TWICE
						CURRENT_STATE <= AUTO_REFRESH;
						nZWE <= '1';
						nZRAS <= '0';
						nZCAS <= '0';
						nZCS <= '0';
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh minimum time is 60ns. We must NOP enough clock cycles to meet this requirement.
					--50MHz IS 20ns PER CYCLE, 40MHz IS 24ns, 33 IS 30ns, 25MHz IS 40ns.
					--SO, 3 CLOCK CYCLES FOR 50 AND 40 MHz AND 2 CLOCK CYCLES FOR 22 AND 25 MHz.
					
					--THE WAY THIS REFRESH LOGIC IS WRITTEN, YOU ALWAYS HAVE AN EXTRA CLOCK
					--AFTER THE REFRESH (NOT DURING STARTUP, THOUGH) AS IT GOES INTO RUN STATE WHEN 
					--THE 68030 HAS ASSERTED _AS DURING THE REFRESH., RUN_STATE BEING THE "EXTRA" CLOCK.
					--SO...AUTO_REFRESH -> AUTO_REFRESH_CYCLE -> RUN_STATE -> RAS_STATE.
					--IDEALLY IT WOULD GO AUTO_REFRESH -> AUTO_REFRESH_CYCLE -> RAS_STATE.
					--THIS COULD BE A TARGET FOR FUTURE OPTIMIZATION.
					
					IF (J404 = '0') THEN
						--WE NEED TO ADD A CLOCK CYCLE TO ACHEIVE THE MINIMIM REFRESH TIME OF 60ns
						COUNT <= 0;
					ELSE
						--OUR CLOCK IS SLOW ENOUGH TO ACCOMODATE THE 60ns TIME.
						COUNT <= 1;
					END IF;
					
					CURRENT_STATE <= AUTO_REFRESH_CYCLE;
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '1';
					
				WHEN AUTO_REFRESH_CYCLE =>
					
					IF (COUNT = 1) THEN 
						--ENOUGH CLOCK CYCLES HAVE PASSED. WE CAN PROCEED.
						
						IF (SDRAM_START_REFRESH_COUNT = '0') THEN		
							--DO WE NEED TO REFRESH AGAIN (STARTUP)?
						
							CURRENT_STATE <= AUTO_REFRESH;
							nZWE <= '1';
							nZRAS <= '0';
							nZCAS <= '0';
							nZCS <= '0';
							
							SDRAM_START_REFRESH_COUNT <= '1';
							
						ELSE
						
							CURRENT_STATE <= RUN_STATE;
							
							nZCS <= '1';
							nZRAS <= '1';	
							nZCAS <= '1';							
							nZWE <= '1';
							
						END IF;
						
					END IF;		

					COUNT <= COUNT + 1;						
				
				WHEN RUN_STATE =>
					
					IF nMEMZ2 = '0' THEN 
					
						--WE ARE IN THE Z2 MEMORY SPACE WITH THE ADDRESS STROBE ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND W/RAS
						
						CURRENT_STATE <= RAS_STATE;
						ZMA(10 downto 0) <= A(12 downto 2);
						ZBANK0 <= A(13);
						ZBANK1 <= A(14);
						
						nZCS <= '0';
						nZRAS <= '0';	
						nZCAS <= '1';							
						nZWE <= '1';
						
						--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY ASSERT _DSACKx.
						IF (RnW = '0') THEN
						
							dsack <= '0';
							
						END IF;
						
					END IF;
					
				WHEN RAS_STATE =>	
					
					--BANK ACTIVATE
					--SET CAS STATE VALUES SO THEY LATCH ON THE NEXT CLOCK EDGE
					CURRENT_STATE <= CAS_STATE;
					ZMA(6 downto 0) <= A(21 downto 15);
					ZMA(7) <= '0';
					ZMA(8) <= '0';
					ZMA(9) <= '0';
					ZMA(10) <= '1'; --PRECHARGE
					
					nZCS <= '0';
					nZRAS <= '1';	
					nZCAS <= '0';	
					nZWE <= RnW;	
					
				WHEN CAS_STATE =>
					
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES.
					
					--WE NOP FOR THE REMAINING CYCLES.
					nZCS <= '1';
					nZRAS <= '1';	
					nZCAS <= '1';							
					nZWE <= '1';
					
					IF (RnW = '1') THEN
						
						--68030 CAN COMMIT ON THE NEXT FALLING CLOCK EDGE.
						--ASSERTING BOTH DSACKs TELLS THE 68030 THAT THIS IS A 32 BIT PORT.
						dsack <= '0'; 
						
					END IF;						
					
					IF (nMEMZ2 = '1') THEN 
						--THE ADDRESS STROBE HAS NEGATED INDICATING THE END OF THE MEMORY ACCESS.
						
						dsack <= '1';
						
						--IN THE EVENT WE HAVE A REFRESH ASSERTED AND WAITING,
						--WE GO THERE INSTANTLY. OTHERWISE, RETURN TO RUN STATE.
						
						IF REF = '0' THEN 
						
							CURRENT_STATE <= RUN_STATE;	
						
						ELSE
						
							--THERE IS A REFRESH ASSERTED, GO TO THE REFRESH STATE
							CURRENT_STATE <= AUTO_REFRESH;
							
							nZWE <= '1';
							nZRAS <= '0';
							nZCAS <= '0';
							nZCS <= '0';	
						
							nREFACKZ2 <= '0';
							
						END IF;
						
					END IF;	
				
			END CASE;
				
		END IF;
	END PROCESS;
	
	---------------------------
	-- A2630 ROM CHIP SELECT --
	---------------------------
	
	--THE ROM IS PLACED IN THE RESET VECTOR ($000000) WHEN THE SYSTEM FIRST STARTS/RESTARTS.
	--AT THAT TIME, THE ROM RESPONDS IN THE SPACE AT $000000 - $00FFFF.
	--THE ROM WILL STOP RESPONDING ONCE phantomlo IS SET = 1 AFTER CONFIGURATION.
	
	lorom <= '1' WHEN A(23 DOWNTO 16) = x"00" AND phantomlo = '0' AND RnW = '1' AND nAS = '0' ELSE '0';
	
	--AFTERWARD, THE ROM IS THEN MOVED TO THE ADDRESS SPACE AT $F80000 - $F8FFFF.
	--THIS IS THE "NORMAL" PLACE FOR SYSTEM ROMS.
	--THE ROM WILL STOP RESPONDING ONCE phantomhi IS SET = 1 AFTER CONFIGURATION.
	
	--11111000
	hirom <= '1' WHEN A(23 DOWNTO 16) = x"F8" AND phantomhi = '0' AND RnW = '1' AND nAS = '0' ELSE '0';
	
	--THE FINAL ROM CHIP SELECT SIGNAL
	nCSROM <= '0' WHEN lorom = '1' OR hirom = '1' ELSE '1';	
	
	---------------------------
	-- ROM DATA TRANSFER ACK --
	---------------------------
	
	--THIS IS FOR 16 BIT ROM ACCESS ASYNC CYCLES.
	
	PROCESS (CPUCLK) BEGIN
	
		IF RISING_EDGE (CPUCLK) THEN
			
			IF nCSROM = '0' THEN
				
				--WE ARE IN THE ONBOARD ROM ADDRESS SPACE.
				--THE 27C256 EPROM NEEDS 40-75ns TO STABILIZE DATA.
				--THIS DELAYS DSACK BY THE NUMBER OF CLOCKS DEFINED BY DELAYVALUE.
			
				IF dsackdelay(DELAYVALUE) = '1' THEN				
					
					nDSACK0 <= '1';
					nDSACK1 <= '0';
				
				ELSIF dsackdelay(DELAYVALUE) = '0' THEN				
					
					nDSACK1 <= '1';
					
					dsackdelay(0) <= '1';
					dsackdelay(DELAYVALUE DOWNTO 1) <= dsackdelay(DELAYVALUE-1 DOWNTO 0);
				
				END IF;	

			ELSIF autoconfigspace = '1' THEN
			
				--WE ARE IN THE AUTOCONFIG ADDRESS SPACE
				nDSACK0 <= '1';
				nDSACK1 <= acdsack;
				
			ELSIF nMEMZ2 = '0' THEN
			
				--WE ARE IN THE SDRAM ADDRESS SPACE
				
				nDSACK0 <= dsack;
				nDSACK1 <= dsack;
				
			ELSE
			
				nDSACK0 <= 'Z';
				nDSACK1 <= 'Z';
				
				dsackdelay <= (OTHERS => '0');
				
			END IF;
		
		END IF;
		
	END PROCESS;
	
	---------------------------
	-- STATE MACHINE DISABLE --
	---------------------------
	
	--ASSERT SMDIS (STATE MACHINE DISABLE) WHENEVER WE ARE ACCESSING A RESOURCE
	--ON THE 2630 CARD. THIS INCLUDES ROM, AUTOCONFIG, IDE, ZORRO 2, OR ZORRO 3 
	--MEMORY SPACES. THIS PREVENTS THE 68000 STATE MACHINE FROM STARTING.
	
	PROCESS (CPUCLK) BEGIN
	
		IF RISING_EDGE (CPUCLK) THEN	
		
			IF (hirom = '1' OR lorom = '1' OR autoconfigspace = '1' OR nIDEACCESS = '0' OR nMEMZ2 = '0' OR nMEMZ3 = '0') OR (SMDIS = '1' AND nAS = '0') THEN
			
				SMDIS <= '1';
				
			ELSE
			
				SMDIS <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	
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
	
	--EVEN THOUGH THIS ISN'T WITH THE AUTOCONFIG STUFF, IT STILL
	--RESPONDS IN THE AUTOCONFIG SPACE, WITH DTACK HANDLED THERE.
	
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
	--THIS IS PASSED TO THE _COPCFG SIGNAL 
	--U602 WILL ASSERT Z3CONFIGED WHEN Z3 RAM HAS BEEN AUTOCONFIGed OR IF Z3 RAM IS DISABLED.
	CONFIGED <= '1' WHEN nZ3CONFIGED = '1' AND boardconfiged = '1' ELSE '0';	

	--We have three boards we need to autoconfig, in this order
	--1. The 68030 ROM (SEE ALSO SPECIAL REGISTER, ABOVE)
	--2. The base memory (8MB) in the Zorro 2 space
	--3. The expansion memory in the Zorro 3 space. This is done in U602.	

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition
			
	--BOARDCONFIGED IS ASSERTED WHEN WE ARE DONE CONFIGING THE ROM AND ZORRO 2 MEMORY
	--WHEN THE ZORRO 2 RAM IS DISABLED BY J303, IT SETS Z2AUTO = 0.
	boardconfiged <= '1' WHEN (romconfiged = '1' AND Z2AUTO = '0') OR (romconfiged= '1' AND ramconfiged = '1') ELSE '0';
	
	--WE ARE IN THE Z2 AUTOCONFIG ADDRESS SPACE ($E80000).
	--THIS IS QUALIFIED BY BOARDCONFIGED SO WE STOP RESPONDING TO THE AUTOCONFIG 
	--SPACE ONCE WE ARE COMPLETELY CONFIGURED.
	--11101000
	autoconfigspace <= '1'
		WHEN 
			A(23 downto 16) = x"E8" AND boardconfiged = '0' AND nAS = '0'
		ELSE
			'0';				

	--THIS CODE ASSERTS THE AUTOCONFIG DATA ON TO D(31..28),
	--DEPENDING ON WHAT WE ARE AUTOCONFIGing.	
	--We AUTOCONFIG the 2630 FIRST, then the Zorro 2 RAM
	--SIMULATES OK
	
	D(31 downto 28) <= 
			D_2630
				WHEN romconfiged = '0' AND autoconfigspace = '1' AND RnW = '1'
		ELSE
			D_ZORRO2RAM 
				WHEN autoconfigspace ='1' AND RnW = '1'
		ELSE
			"ZZZZ";		
			
	--Here it is in all its glory...the AUTOCONFIG sequence
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF nRESET = '0' THEN
			
			rambaseaddress <= "000";			
			ramconfiged <= '0';	
			acdsack <= '1';
			
		ELSIF ( RISING_EDGE (CPUCLK)) THEN
		
			IF autoconfigspace = '1' THEN
			
				IF RnW = '1' THEN
					--The 680x0 is reading from us
				
					CASE A(6 downto 1) IS

						--offset $00
						WHEN "000000" => 
							D_2630 <= "1110"; 
							D_ZORRO2RAM <= "1110"; --er_type: Zorro 2 card without BOOT ROM, LINK TO MEM POOL

						--offset $02
						WHEN "000001" => 
							D_2630 <= "0000"; --8MB
							D_ZORRO2RAM <= "0000"; --er_type: NEXT BOARD NOT RELATED, 0MB

						--offset $04 INVERTED
						WHEN "000010" => 
							D_2630 <= "1010";
							D_ZORRO2RAM <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number

						--offset $06 INVERTED
						WHEN "000011" => 
							D_2630 <= "1110";
							D_ZORRO2RAM <= "1111"; --Product Number Lo Nibble

						--offset $0C INVERTED						
						WHEN "000110" => 
							D_2630 <= OSMODE & "111"; --THE A2630 CONFIGURES THIS NIBBLE AS "0111" WHEN UNIX, "1111" WHEN AMIGA OS
							D_ZORRO2RAM <= "1111"; --Reserved: must be zeroes

						--offset $12 INVERTED
						WHEN "001001" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, high byte, low nibble hi byte. Just for fun, lets put C= in here!

						--offset $16 INVERTED
						WHEN "001011" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, low nibble low byte. Just for fun, lets put C= in here!

						WHEN OTHERS => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111"; --INVERTED...Reserved offsets and unused offset values are all zeroes

					END CASE;

				ELSIF ( RnW = '0' AND nDS = '0' ) THEN	
				
					IF ( A(6 downto 1) = "100100" ) THEN
						--WRITE REGISTER AT OFFSET $48. THIS IS WHERE THE BASE ADDRESS IS ASSIGNED.
						
						--THERE MIGHT BE A CASE WHERE WE ARE HAVE JUST CONFIGED THE ROM WHERE
						--WE GET TO THIS ADDRESS AND MISTAKENLY THINK IT'S THE RAM BEING CONFIGURED
						--FOOD FOR THOUGHT. IN THAT CASE WE NEED TO WAIT UNTIL WE GET TO THE NEXT
						--AUTOCONFIG CYCLE TO ENTER THE BELOW CODE.
						
						IF ( romconfiged = '1' AND ramconfiged = '0' ) THEN
						
							--BASE ADDRESS FOR THE ZORRO 2 RAM
							rambaseaddress <= D(31 downto 29);
							ramconfiged <= '1'; 
							
						END IF;								
						
					END IF;	
						
				END IF;			
				
				--DSACK AFTER EACH CYCLE
				acdsack <= '0';
				
			END IF;
			
			--WE ARE IN THE AUTOCONFIG SPACE, BUT _AS IS NOT ASSERTED
			acdsack <= '1';
			
		END IF;
		
	END PROCESS;
	
	------------------------
	-- 68030 CACHE ENABLE --
	------------------------
	
	--This is the cache control signal.  We want the cache enabled when we're
	--in memory, but it can't go for CHIP memory, since Agnus can also write
	--to that memory.  Expansion bus memory, $C00000 memory, and ROM are prime
	--targets for caching.  CHIP RAM, all chip registers, and the space we leave
	--aside for I/O devices shouldn't be cached.  This isn't prefect, as it's
	--certainly possible to place I/O devices in the normal expansion space, or
	--RAM in the I/O space.  Note that we always want to cache program, just not
	--always data.  The "wanna be cached" term doesn't fit, so here's the 
	--"don't wanna be cached" terms, with inversion. U306	
		
	--userdata	<= '1' WHEN FC( 2 downto 0 ) = "001" ELSE '0'; --(cpustate:1)
	--superdata <= '1' WHEN FC( 2 downto 0 ) = "101" ELSE '0'; --(cpustate:5)
	
	nCIIN <= '1' 
		WHEN			
			--(chipram = '1' AND ( userdata = '1' OR superdata = '1' ) AND EXTSEL = '0') OR
			--!CACHE = chipram & (userdata # superdata) & !EXTSEL
			--(ciaspace = '1'  AND EXTSEL = '0') OR
			--ciaspace & !EXTSEL
			--(chipregs = '1'  AND EXTSEL = '0') OR
			--chipregs & !EXTSEL
			--(iospace = '1'  AND EXTSEL = '0')
			--iospace & !EXTSEL
			nMEMZ2 = '0' OR
			nMEMZ3 = '0' OR
			( A(23 DOWNTO 16) >= x"F8" AND A(23 DOWNTO 16) <= x"FF" )
		ELSE
			'0';		

	-----------------------
	-- 6888x CHIP SELECT --
	-----------------------
	
	--This selects the 68881 or 68882 math chip (FPU chip select), as long as there's no DMA 
	--going on.  If the chip isn't there, we want a bus error generated to 
	--force an F-line emulation exception.  Add in AS as a qualifier here
	--if the PAL ever turns out too slow to make FPUCS before AS. U306
	
	--field spacetype	= [A19..16] ;
	--coppercom	= (spacetype:20000) ; 00100000000000000000
	coppercom <= '1' WHEN A( 19 downto 16 ) = "0010" ELSE '0';
	--field copperid	= [A15..13] ;	
	--mc68881	= (copperid:2000) ; 0010000000000000
	mc68881 <= '1' WHEN A( 15 downto 13 ) = "001" ELSE '0';

	--FPUCS = cpuspace & coppercom & mc68881 & !BGACK;
	nFPUCS <= '0' WHEN ( FC(2 downto 0) = "111" AND coppercom = '1' AND mc68881 = '1' AND nBGACK = '1' ) ELSE '1';

	--BERR		= cpuspace & coppercom & mc68881 & !SENSE & !BGACK;
	--BERR.OE	= cpuspace & coppercom & mc68881 & !SENSE & !BGACK;
	nBERR <= '0' WHEN ( FC(2 downto 0) = "111" AND coppercom = '1' AND mc68881 = '1' AND nBGACK = '1' AND nSENSE = '1' ) ELSE 'Z';
	
	--------------------
	-- AUTO VECTORING --
	--------------------
	
	--This forces all interrupts to be serviced by autovectoring.  None
	--of the built-in devices supply their own vectors, and the system is
	--generally incompatible with supplied vectors, so this shouldn't be
	--a problem working all the time.  During DMA we don't want any AVEC
	--generation, in case the DMA device is like a Boyer HD and doesn't
	--drive the function codes properly. U306	
		
	--field spacetype	= [A19..16] ;
	--interruptack	= (spacetype:f0000) ;
	--11110000000000000000
	--interruptack <= '1' WHEN A( 19 downto 16 ) = "1111" ELSE '0';

	--AVEC		= cpuspace & interruptack & !BGACK;
	nAVEC <= '0' WHEN (FC(2 downto 0) = "111" AND A( 19 downto 16 ) = "1111" AND nBGACK = '1') ELSE '1';

end Behavioral;