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
-- Create Date:    December 17, 2022 
-- Design Name:    N2630 U600 CPLD
-- Project Name:   N2630 https://github.com/jasonsbeer/Amiga-N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description: BOSS, GLUE LOGIC, BUS INTERFACE, 6800/6502 STATE MACHINE, 68000 STATE MACHINE
--
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

entity U600 is

PORT 
(
	A7M : IN STD_LOGIC; --AMIGA 7MHZ CLOCK	
	CDAC : IN STD_LOGIC; --CDAC CLOCK
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	nVPA : IN STD_LOGIC; --6800 VPA SIGNAL
	B2000 : IN STD_LOGIC; --IS THIS AN A2000 OR B2000
	nHALT : IN STD_LOGIC; --_HALT SIGNAL	
	MODE68K : IN STD_LOGIC; --ARE WE IN 68000 MODE (DISABLED)	
	nDTACK : IN STD_LOGIC; --68000 DATA TRANSFER ACK
	nABGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nMEMZ2 : IN STD_LOGIC; --SIGNALS WHEN WE ARE RESPONDING TO A ZORRO 2 RAM ADDRESS
	A : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 ADDRESS LINES 0 AND 1
	SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 SIZE BITS
	FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0 ); --68030 FUNCTION CODES
	SMDIS : IN STD_LOGIC; --STATE MACHINE DISABLE
	nCPURESET : IN STD_LOGIC; --THE 68030 RESET SIGNAL
	nSTERM : IN STD_LOGIC; --STERM SIGNAL DRIVEN BY U602
	nC1 : IN STD_LOGIC; --C1 CLOCK
	nC3 : IN STD_LOGIC; --C3 CLOCK
	nBERR : IN STD_LOGIC; --680x0 BUS ERROR SIGNAL
	
	nAS : INOUT STD_LOGIC; --68030 ADDRESS STROBE
	nABR : INOUT STD_LOGIC; -- AMIGA BUS REQUEST	
	nBOSS : INOUT STD_LOGIC; --_BOSS SIGNAL
	E : INOUT STD_LOGIC; --E CLOCK
	nVMA : INOUT STD_LOGIC; --6800 VMA SIGNAL	
	nAAS : INOUT STD_LOGIC; --AMIGA 68000 ADDRESS STROBE	
	RnW : INOUT STD_LOGIC; --68030 READ/WRITE
	TRISTATE : INOUT STD_LOGIC; --TRISTATE SIGNAL
	ARnW : INOUT STD_LOGIC; --DMA READ/WRITE FROM AMIGA 2000
	nDSACK1 : INOUT STD_LOGIC; --16 BIT DSACK SIGNAL
	nBGACK : INOUT STD_LOGIC; --BUS GRANT ACK
	nRESET : INOUT STD_LOGIC; --_RESET SIGNAL
	nABG : INOUT STD_LOGIC; --AMIGA BUS GRANT
	nBG : INOUT STD_LOGIC; --68030 BUS GRANT SIGNAL
	
	ADDIR : OUT STD_LOGIC; --DIRECTION/LATCH OF 74FTC624 LOGIC
	IPLCLK : OUT STD_LOGIC; --CLOCK PULSE FOR U700
	DRSEL : OUT STD_LOGIC; --DIRECTION SELECTION FOR U701 U702
	nADOEL : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nADOEH : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nLDS : OUT STD_LOGIC; --68000 _LDS
	nUDS : OUT STD_LOGIC; --68000 _UDS
	nBR : OUT STD_LOGIC; --68030 BUS REQUEST SIGNAL
	nCLK7 : OUT STD_LOGIC --INVERTED 7MHZ OUT FOR 74HCT646 DATA LATCH
	
);


end U600;

architecture Behavioral of U600 is

	--DEFINE THE 68000 STATE MACHINE STATES
	TYPE STATE68K IS ( S0, S1, S2, S3, S4, S5, S6, S7 );
	SIGNAL CURRENT_STATE : STATE68K;	
	
	--68000 STATE MACHINE SIGNALS
	SIGNAL ldsout : STD_LOGIC := '1'; --VALUE FOR _LDS
	SIGNAL udsout : STD_LOGIC := '1'; --VALUE FOR _UDS
	SIGNAL sm_enabled : STD_LOGIC := '0'; --ARE WE ACCESSING THE AMIGA 2000 BOARD?
	SIGNAL eclk_counter : INTEGER RANGE 0 TO 15 := 0; --4 BIT NUMBER E COUNTER
	SIGNAL vmacount : INTEGER RANGE 0 TO 15 := 0; --COUNTER FOR E VMA
	SIGNAL eclk : STD_LOGIC := '0'; --E SIGNAL FOR "A2000"
	SIGNAL esync : STD_LOGIC := '0'; --ONE CLOCK DELAY OF E
	SIGNAL DSACKEN : STD_LOGIC := '0'; --ENABLE _DSACK1
	SIGNAL ascycle : STD_LOGIC := '0'; --ENABLE AMIGA ADDRESS STROBE SIGNAL
	SIGNAL rwcycle : STD_LOGIC := '0'; --ENABLE AMIGA READ/WRITE SIGNAL
	SIGNAL writecycle : STD_LOGIC := '0';
	SIGNAL readcycle : STD_LOGIC := '0';
	SIGNAL dsackcycle : STD_LOGIC := '0'; --ENABLE THE 68030 _DSACK1 SIGNAL
	SIGNAL vmacycle :STD_LOGIC := '0'; --ENABLE THE AMIGA _VMA SIGNAL
	SIGNAL edsack : STD_LOGIC := '0';
	
	--CLOCK SIGNALS
	SIGNAL CLK7 : STD_LOGIC := '0';
	SIGNAL CLK14 : STD_LOGIC := '0';

begin

	------------
	-- CLOCKS --
	------------
	
	--THE 7MHz CLOCK CAN BE PULLED FROM THE CPU SLOT OF THE B2000, BUT MUST BE RECREATED
	--FROM C1 AND C2 ON THE A2000.
		
	CLK7 <= '1' WHEN ( B2000 = '1' AND A7M = '1' ) OR ( B2000 = '0' AND (nC1 = '1' XOR nC3 = '0' )) ELSE '0';	
	
	--This clock is used to latch the interrupt lines between the motherboard
	--and the 68030.  If this isn't done, you'll get phantom interrupts
	--that you probably won't even notice in AmigaOS, but can be fatal to
	--time critical interrupt code in UNIX and possibly even AmigaOS.

	IPLCLK <= CLK7;
	
	--THIS CLOCK DRIVES THE 74HCT646 DATA BUS LATCHES.
	--IT IS AN INVERTED VERSION OF THE AMIGA 7MHz CLOCK.
	
	nCLK7 <= NOT CLK7;
	
	--THIS IS A 14MHz CLOCK FOR THE 68000 STATE MACHINE
	CLK14 <= CLK7 XOR CDAC;

	---------------------
	-- REQUEST THE BUS --
	---------------------	

	--Request the Amiga 2000 bus at power up or reset so be we can become the BOSS.
	--Bus mastering is supposed to be clocked on the 7MHz rising edge (A2000 technical reference).
	--BUS REQUEST (_BR) HAS A PULLUP ON THE A2000.
	
	PROCESS (CLK7) BEGIN
		IF RISING_EDGE (CLK7) THEN
		
			IF (nRESET = '0' OR nBOSS = '0' OR MODE68K = '1' ) THEN		
				--We do not need to request the bus at this time.
				--We are BOSS or we are in 68000 mode.
				--Tristate so we don't interfere with other bus requesters on the Amiga 2000.
				nABR <= 'Z';
				
			ELSE		
			
				IF nABR = '0' THEN	
					--nABR is asserted, but are we BOSS yet?
					IF (nBOSS = '1' AND MODE68K = '0') THEN
						nABR <= '0';
					ELSE
						nABR <= '1';
					END IF;	
				ELSE
					--nABR is not asserted. Should it be?
					IF (nAAS = '0' AND nBOSS = '1' AND MODE68K = '0') THEN				
						nABR <= '0';
					ELSE
						nABR <= '1';
					END IF;
				END IF;
				
			END IF;
			
		END IF;
	END PROCESS;

	-----------------
	-- BECOME BOSS --
	-----------------	
	
	--WE NEED TO BECOME B.O.S.S. (Biomorphic Organisational Systems Supervisor)	
	
	--BOSS is a signal used by the B2000 to hold the 68000 on the U600 board 
	--in tristate (by using bus request). Our board uses BOSS to indicate that
	--we have control of the universe.  The inverse of BOSS is used as a CPU,
	--MMU and ROM control register reset.  BOSS gets asserted after we request
	--the bus from the 68000 (we wait until it starts it's first memory access
	--after reset) and recieve bus grant and the indication that the 68000 has
	--completed the current cycle.  BOSS gets held true in a latching term until
	--the next cold reset or until 68KMODE is asserted.
	--
	--We wanna be the boss, but we have to be careful.  We're never the boss
	--during a cold reset, or during 68K mode.  We wait after reset for the
	--bus grant from the 68000, then we assert BOSS, if we're a B2000.  We
	--always assert BOSS during a non-reset if we're an A2000.  Finally, we
	--hold BOSS on the B2000 until either a full reset or the 68K mode is
	--activated.

	PROCESS (CLK7, nRESET) BEGIN

		IF RISING_EDGE (CLK7) THEN
		
			IF (nBOSS = '0') THEN
				--HOLD BOSS UNTIL ONE OF THE CONDITION BELOW IS FALSE
				IF ( nHALT = '1' AND MODE68K = '0') OR ( nRESET = '1' AND MODE68K = '0' ) THEN
					nBOSS <= '0';
				ELSE
					nBOSS <= '1';
				END IF;
			ELSE
				--ASSERT _BGACK (_BOSS) WHEN THE 68000 HAS FINISHED ITS CURRENT CYCLE (_AS AND _DTACK ARE NEGATED).
				IF 
					( B2000 = '1' AND nABG = '0' AND nAAS ='1' AND nDTACK = '1' AND nHALT = '1' AND MODE68K = '0' ) OR 
					( B2000 = '0' AND nHALT ='1') 
				THEN
					nBOSS <= '0';
				ELSE
					nBOSS <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	-----------
	-- RESET --
	-----------
	
	--The RESET output feeds to the /RST signal from the A2000
	--motherboard.  Which in turn enables the assertion of the /BOSS
	--line when you're on a B2000.  Which in turn creates the
	--/CPURESET line.  Together these make the RESET output.	In
	--order to eliminate the glitch on RESET that this loop makes,
	--the RESENB input is gated into the creation of RESET.  What
	--this implies is that the 68020 can't reset the system until
	--we're RESENB, OK?.  Make sure to consider the effects of this
	--gated reset on any special use of the ROM configuration register.
	--Using JMODE it's possible to reset the ROM configuration register
	--under CPU control, but not if the RESENB line is negated.
	
	--THERE IS A PULLUP ON THE A2000 FOR RESET (RST).
	--FLOAT RESET UNTIL WE ARE ACTUALLY READY TO USE IT.

	nRESET <= '0' WHEN nBOSS = '0' AND nCPURESET ='0' ELSE 'Z';
	
	------------------------
	-- 6800 STATE MACHINE --
	------------------------
	
	--WHEN IN "A2000" MODE, WE MUST GENERATE OUR OWN E BECAUSE THE 68000 
	--PROCESSOR IS REMOVED FROM THE MOTHERBOARD. WHEN IN "B2000" MODE, WE CAN
	--USE THE EXISTING E SIGNAL BUT WE MUST REPLY TO _VPA EITHER WAY.
	
	E <= 'Z' WHEN B2000 = '1' ELSE eclk;
	
	--E IS A TIMING SIGNAL FOR 6800 BASED PERIPHERLS. THE CIAs USE THE E SIGNAL.
	--IT IS 6 CLOCK CYCLES LOW AND 4 HIGH AND ASYNCHRONOUS WITH ANY OTHER CLOCK.  
	--THAT MEANS WE CAN MAKE OUR OWN WITH A SIMPLE COUNTER DRIVEN FROM THE AMIGA 
	--7MHz CLOCK. WE ONLY CREATE OUR OWN E WHEN WE ARE IN AN "A2000" MACHINE. 
	--TRIVIA: E MEANS "ENABLE"

	PROCESS (CLK7, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			eclk_counter <= 0;			
	
		ELSIF FALLING_EDGE (CLK7) THEN
			
			IF (eclk_counter < 6) THEN
				eclk <= '0';
			ELSE
				eclk <= '1';
			END IF;
			
			IF (eclk_counter = 9) THEN
				eclk_counter <= 0;
			ELSE			
				eclk_counter <= eclk_counter +1;
			END IF;
			
		END IF;
			
	END PROCESS;
	
	--THIS IS OUR E SYNC SIGNAL AND IS ONE 7MHz CLOCK BEHIND E. THIS GIVES US
	--A WAY TO DETECT THE E FALLING EDGE, WHICH TELLS US WHEN A NEW E CYCLE STARTS.	
	
	PROCESS (CLK7) BEGIN
		
		IF FALLING_EDGE (CLK7) THEN
			esync <= E;
		END IF;
		
	END PROCESS;
	
	--VMA (VALID MEMORY ADDRESS) IS A 6800 SIGNAL DRIVEN IN RESPONSE TO VPA (VALID PERIPHERAL ADDRESS).
	--VMA IS TO BE ASSERTED WHEN THE PROCESSOR IS SYNCED TO THE E CLOCK. THIS IS DONE IN THE 68000
	--STATE MACHINE AND IS DISCUSSED IN APPENDIX B OF THE 68000 MANUAL.	
	--WE USE THIS COUNTER SO WE KNOW WHEN TO ASSERT _VMA AS IT TRACKS WHERE WE ARE IN THE E CYCLE.
	--THE COUNTER GOES FROM 0 TO 9 TO ACCOUNT FOR THE 10 TOTAL CLOCKS IN AN E CYCLE, BUT IS ONE CLOCK BEHIND.
	
	PROCESS (CLK7, nRESET) BEGIN	
		
		IF nRESET = '0' THEN
		
			vmacycle <= '0';
			edsack <= '0';

		ELSIF FALLING_EDGE (CLK7) THEN
		
			--VMA COUNTER
			IF E = '0' AND esync = '1' THEN
				--RESET THE COUNTER
				vmacount <= 0;		
			ELSE
				vmacount <= vmacount + 1;
			END IF;
			
			--RESPOND TO _VPA IN 6800 CYCLES
			--THIS FEEDS INTO THE 68000 STATE MACHINE TO 
			--SIGNAL THE END OF THE CYCLE.
			IF nVPA = '0' THEN
			
				IF vmacount = 1 THEN
				
					vmacycle <= '1';
					
				ELSIF nVMA = '0' AND vmacount = 7 THEN
				
					edsack <= '1';
					
				END IF;
				
			ELSE
			
				vmacycle <= '0';
				edsack <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
					
	---------------------------------------
	-- AMIGA 68030 <-> 68000 BUS CONTROL --
	---------------------------------------
	
	--WHEN IN DMA MODE, ADDRESS LINE 1 IS CONSIDERED TO ACCOMODATE HOW THE DATA IS STORED AND RETRIEVED.
	--REMEMBER, WE ARE 32 BIT MEMORY, SO TWO DMA WORDS (HIGH AND LOW) ARE STORED AT A SINGLE LOCATION. 
	--A1 IS USED TO DETERMINE WHETHER THE DATA IS STORED AT THE HIGH WORD (1) OR THE LOW WORD (0).
	--THE DATA LINES ARE REGULATED BY 646 AND 245 TRANSCEIVERS.
	--IF A1 = '1' (HIGH WORD), THEN THE 646's ARE ACTIVE AND THE 245's ARE NOT ACTIVE. 
	--THE INVERSE IS TRUE WHEN A1 = '0' (LOW WORD). THIS HELPS DIRECT THE 68000 DMA DRIVEN
	--DATA SIGNALS (D15..0) TO THE CORRECT WORD (HIGH OR LOW) AT THE ADDRESS LOCATION.
	
	--WHEN NOT IN DMA MODE, THE 68030 UTILIZES D31..D16 FOR 16-BIT CYCLES. IN THAT INSTANCE,
	--WE ENABLE THE 646's TO CONNECT 68030 D31..16 TO THE AMIGA 68000 D15..0. THE 245's ARE
	--DISABLED BECAUSE THEY ARE NOT NEEDED. THE 74FCT646's ARE THE DATA BUS WORK HORSES HERE.
	
	--THE LOGIC SIGNALS BELOW COMBINE TO RESULT IN THE FOLLOWING SETTINGS ON THE 646 LATCH/TRANSCEIVERS...
	--DMA READ  = N2630 -> AMIGA
	--DMA WRITE = N2630 <- AMIGA
	--NON-DMA READ = N2630 <-LATCHED- AMIGA
	--NON-DMA WRITE = N2630 -> AMIGA
	
	--ADOEH		= BOSS &  BGACK &  MEMSEL & AAS & !A1		# BOSS & !BGACK & !MEMSEL &  AS & !ONBOARD & !EXTERN;
	--ADOEH CONTROLS D31..17. SEE DRSEL SIGNAL (BELOW). U701, U702
	--WE WANT _ADOEH ASSERTED (ENABLED) WHEN
		--NOT DMA AND ACCESSING THE A2000 BOARD IN 68030 MODE (BOSS=0, STATE MACHINE ENABLED)
		--DMA AND ACCESSING Z2 MEMORY IN 68030 MODE (BOSS=0)
		--NOT DMA AND ACCESSING MEMORY IN 68000 MODE (BOSS=1, MODE68K =1) NOTE: NOT IMPLEMENTED
		--NOT DMA AND ACCESSING IDE IN 68000 MODE (BOSS=1, MODE68K =1) NOTE: NOT IMPLEMENTED
		
	--SMDIS (STATE MACHINE DISABLED) IS ASSERTED (=1) WHEN USING RESOURCES ON THE 2630 CARD
		--IDE MEMORY SPACE
		--ZORRO 3 MEMORY SPACE
		--ZORRO 2 MEMORY SPACE
		--ROM MEMORY SPACE
		
	nADOEH <= '0' 
		WHEN 
			--( nBOSS = '0' AND nBGACK = '1' AND SMDIS = '0' AND nAS = '0' ) OR
			( nBOSS = '0' AND nBGACK = '1' AND sm_enabled = '1' ) OR
			( nBOSS = '0' AND nBGACK = '0' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '1' )  
			--OR ( nBOSS = '1' AND MODE68K = '1' AND nBGACK = '1' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '1' ) 
			--OR ( nBOSS = '1' AND MODE68K = '1' AND nBGACK = '1' AND nIDEACCESS AND nAAS = '0' )
			
		ELSE
			'1';
	
	--ADOEL		= BOSS &  BGACK &  MEMSEL & AAS &  A1;
	--ADOEL CONTROLS D16..0. U703, U704 AND SHOULD ONLY BE ACTIVE DURING DMA.
	nADOEL <= '0' 
		WHEN 
			nBOSS = '0' AND nBGACK = '0' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '0' 
		ELSE 
			'1';
	
	--This selects when we want data latching, which we in fact want only on
	--read cycles.
	
	--THE A2630 LATCHES DATA ON READS BECAUSE IT NEGATES _AAS AT THE MOMENT
	--IT ASSERTS _DSACK1. BECAUSE OF THIS, THE DATA NEEDS TO BE STABLE
	--WHILE THE 68030 COMPLETES THE CYCLE. OTHERWISE, THE 68000 DATA MAY
	--BECOME INVALID BEFORE THE 6030 LATCHES. 

	DRSEL <= '1' WHEN nBOSS = '0' AND nBGACK = '1' AND RnW = '1' ELSE '0';
	
	--CONTROLS DIRECTION OF THE DATA BUS
	ADDIR <= '1'
		WHEN 
			( nBGACK = '0' AND RnW = '1' ) OR
			( nBGACK = '1' AND RnW = '0' ) 
		ELSE 
			'0';
	
	--THIS SIGNAL IS ONLY USED ON U606, WHICH BUFFERS THE 
	--FUNCTION CODES AND INTERUPTS.

	TRISTATE <= '1' WHEN nBOSS = '1' OR ( nBOSS = '0' AND nBGACK = '0' ) ELSE '0';
			
	-----------------------------
	-- 68030 <-> 68000 SIGNALS --
	-----------------------------
	
	-- BIDIRECTIONAL SIGNALS --
	
	--68000 TO 68030 - DMAing
	RnW <= ARnW WHEN nBOSS = '0' AND nBGACK = '0' ELSE 'Z';
	nAS <= nAAS WHEN nBOSS = '0' AND nBGACK = '0' ELSE 'Z';
	
	-- UNIDIRECTIONAL SIGNALS --
	
	--LOCK THE 68000 TO OUR 68030 WHEN WE ARE BOSS.
	nBGACK <= nABGACK WHEN nBOSS = '0' ELSE 'Z'; --THERE IS NOT A PULLUP ON BGACK.
	nBR <= '0' WHEN nABR = '0' AND nBOSS = '0' AND nBGACK = '1' ELSE 'Z'; --THERE IS A PULLUP ON BR.
	
	--ANY DEVICE REQUESTING THE BUS CANNOT "SEE" ALL THE 68030 DATA TRANSFER SIGNALS.
	--SINCE THE REQUESTING DEVICE MUST WAIT UNTIL THE PROCESSOR HAS COMPLETED
	--IT'S CURRENT CYCLE, WE MUST DO THE ARBITRATION FOR THEM. WAIT UNTIL THE DATA 
	--TRANSFER SIGNALS ARE ALL CLEAR BEFORE PASSING BUS GRANT TO THE REQUESTING DEVICE.
	nABG <= '0' WHEN nBG = '0' AND nBOSS = '0' AND nAS = '1' AND nDSACK1 = '1' AND nSTERM = '1' ELSE 'Z' WHEN nBOSS = '1' ELSE '1'; 
	--nABG <= '0' WHEN nBG = '0' AND nBOSS = '0' AND nAS = '1' AND nDSACK1 = '1' ELSE 'Z' WHEN nBOSS = '1' ELSE '1'; 
	
	----------------------------------------
	-- 68000 STATE MACHINE ENABLE/DISABLE --
	----------------------------------------
			
	--SMDIS (STATE MACHINE DISABLE) IS USED TO INDICATE ROM, CPU SPACE, 
	--ZORRO 2 RAM, ZORRO 3 RAM, AND IDE ACCESS ACTIVITIES.
	
	--sm_enabled (STATE MACHINE ENABLED) IS '1' WHEN WE ARE NOT USING ANY 
	--RESOURCES ON OUR CARD. WE ARE GOING AFTER SOMETHING ON THE AMIGA 2000.
	
	sm_enabled <= '1' 
		WHEN
			nAS = '0' AND
			SMDIS = '0' AND 
			nBGACK = '1' AND 
			FC ( 2 downto 0 ) /= "111" AND
			TRISTATE = '0'
		ELSE 
			'0';
			
	-------------------------
	-- 68000 STATE MACHINE --
	-------------------------

	--DSACK1 PROCESS
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			dsackcycle <= '0';
	  
		ELSIF RISING_EDGE (CPUCLK) THEN
		 
			IF sm_enabled = '1' THEN
				 
				IF nAS = '0' AND (dsacken = '1' OR nDSACK1 = '0') THEN
					 
					dsackcycle <= '1';

				ELSE
				 
					dsackcycle <= '0';
				 
				END IF;
				 
			ELSE
				 
				 dsackcycle <= '0';
			 
			END IF;
			
		END IF;
		
	END PROCESS;

	--DATA TRANSFER SIGNALS
	nUDS <= udsout WHEN writecycle = '1' OR readcycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	nLDS <= ldsout WHEN writecycle = '1' OR readcycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	nAAS <= '0' WHEN ascycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	--nAAS <= nAS WHEN ascycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	ARnW <= RnW WHEN rwcycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	nVMA <= '0' WHEN vmacycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
	nDSACK1 <= '0' WHEN dsackcycle = '1' ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
		 
	--68000 STATE MACHINE PROCESS

	PROCESS (CLK14, sm_enabled, nRESET) BEGIN

		IF sm_enabled = '0' OR nRESET = '0' THEN		
		 
			--THE STATE MACHINE IS DISABLED

			CURRENT_STATE <= S0;
			
			ldsout <= '1';
			udsout <= '1';
			
			ascycle <= '0';
			rwcycle <= '0';
			readcycle <= '0';
			writecycle <= '0';
			dsacken <= '0';

		ELSIF RISING_EDGE (CLK14) THEN
		
			--BEGIN 68000 STATE MACHINE--
			
			--PREP THE DATA STROBES--
			IF A(0) = '0' THEN
				udsout <= '0';
			ELSE
				udsout <= '1';
			END IF;

			IF SIZ(1) = '1' OR SIZ(0) = '0' OR A(0) = '1' THEN
				ldsout <= '0';
			ELSE
				ldsout <= '1';
			END IF;	
		 
			CASE (CURRENT_STATE) IS

				WHEN S0 =>

					--STATE 0 IS THE START OF A CYCLE. 
					--WE MAKE SURE TO START ON THE CORRECT EDGE BY SAMPLING CDAC.					

					IF CDAC = '1' THEN	

						CURRENT_STATE <= S1;
						  
					ELSE
						
						CURRENT_STATE <= S0;

					END IF;

				WHEN S1 =>            

					--PROCESSOR DRIVES A VALID ADDRESS ON THE BUS IN STATE 1. 
					--NOTHING MUCH FOR US TO DO.
					--SET UP FOR STATE 2.

					CURRENT_STATE <= S2;
					
					ascycle <= '1';
					rwcycle <= '1';
						
					IF RnW = '1' THEN
						readcycle <= '1';
					ELSE
						readcycle <= '0';
					END IF;

				WHEN S2 =>

					--ASSERT _AAS FOR ALL CYCLES
					--ASSERT _LDS, AND _UDS FOR READ CYCLES
					--GO TO STATE 3

					CURRENT_STATE <= S3;

				WHEN S3 =>

					--PROCEED TO STATE 4.
					--DURING WRITE CYCLES, _LDS AND _UDS ARE ASSERTED ON THE RISING EDGE OF STATE 4.

					CURRENT_STATE <= S4;
					IF RnW = '0' THEN 
						writecycle <= '1'; 
					ELSE 
						writecycle <= '0'; 
					END IF;

				WHEN S4 =>

					--SOME IMPORTANT STUFF HAPPENS AT S4.
					--IF THIS IS A 6800 CYCLE, ASSERT _VMA IF WE ARE IN SYNC WITH E. SEE 6800 STATE MACHINE.
					--IF THIS IS A 68000 CYCLE, LOOK FOR ASSERTION OF _DTACK.
					--IF THIS IS A 68000 WRITE CYCLE, ASSERT THE DATA STROBES HERE (SET PREVIOUSLY).

					IF nDTACK = '0' OR nBERR = '0' OR edsack = '1' THEN

						--WHEN THE TARGET DEVICE HAS ASSERTED _DTACK OR _BERR, WE CONTINUE ON.
						--IF THIS IS A 6800/6502 (CIA) CYCLE, WE WAIT UNTIL E IS HIGH TO PROCEED.
						--OTHERWISE, INSERT WAIT STATES UNTIL ONE OF THESE CONDITIONS IS SATISFIED.

						CURRENT_STATE <= S5;
						
					ELSE
						
						CURRENT_STATE <= S4;

					END IF;

				WHEN S5 =>

					--NOTHING HAPPENS HERE. GO TO STATE 6.

					CURRENT_STATE <= S6;

				WHEN S6 =>

					--DURING READ CYCLES, THE DATA IS DRIVEN ON TO THE BUS DURING STATE 6.
					--THE 68000 NORMALLY LATCHES DATA ON THE FALLING EDGE OF STATE 7.
					--FOR 6800 CYCLES, E FALLS WITH THE FALLING EDGE OF STATE 7.

					CURRENT_STATE <= S7;
					dsacken <= '1';

					--FOR ALL CYCLES, WE NEGATE _AAS, _LDS, AND _UDS IN STATE 7.
					ascycle <= '0';
					writecycle <= '0';
					readcycle <= '0';

				WHEN S7 =>

					--ONCE WE ARE IN STATE 7, WE NEGATE dsacken AND ALLOW THE _DSACK1 PROCESSS
					--TO DO IT'S THING.
					dsacken <= '0';

					--READ/WRITE AND _VMA ARE HELD UNTIL THE RISING EDGE OF STATE 0.
					--NEGATING THEM TOO SOON WILL MESS UP THE CYCLE.
					CURRENT_STATE <= S0;
					rwcycle <= '0';

			END CASE;
				
		END IF;
			
	END PROCESS;

END Behavioral;