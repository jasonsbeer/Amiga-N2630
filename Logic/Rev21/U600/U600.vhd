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
-- Create Date:    JULY 18, 2022 
-- Design Name:    N2630 U600 CPLD
-- Project Name:   N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description: BOSS, GLUE LOGIC, BUS INTERFACE, E CLOCK GENERATION, 68000 STATE MACHINE
--
-- Revision:  
-- Revision 1.0 - Original Release
-- Additional Comments: SPECIAL THANKS TO DAVE HAYNIE FOR RELEASING THE A2630 PAL LOGIC EQUATIONS.
--                      ORIGINAL PAL EQUATIONS BY C= COMMODORE.
--                      TRANSLATIONS AND ORIGINAL EQUATIONS FOR THE N2630 PROJECT BY JASON NEUS.
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
	SDSPEED : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --INPUT FROM J402 AND J403
	A7M : IN STD_LOGIC; --AMIGA 7MHZ CLOCK	
	REFACKZ3 : IN STD_LOGIC; --ZORRO 3 RAM REFRESH ACK FROM U602
	REFACKZ2 : IN STD_LOGIC; --ZORRO 2 RAM REFRESH ACK FROM U601
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
	REF : INOUT STD_LOGIC; --SDRAM REFRESH SIGNAL
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
	nBR : OUT STD_LOGIC --68030 BUS REQUEST SIGNAL
	
);


end U600;

architecture Behavioral of U600 is

	--DEFINE THE 68000 STATE MACHINE STATES
	TYPE STATE68K IS ( S0, S2, S4, S6 );
	SIGNAL CURRENT_STATE : STATE68K;
	
	--THESE ARE THE CLOCK CYCLES DEFINED FOR THE SDRAM REFRESH COUNTER
	SIGNAL REFRESH_COUNTER_DEFAULT : INTEGER := 511;
	CONSTANT REFRESH_COUNTER_25 : INTEGER := 185;
	CONSTANT REFRESH_COUNTER_33 : INTEGER := 244;
	CONSTANT REFRESH_COUNTER_40 : INTEGER := 296;
	CONSTANT REFRESH_COUNTER_50 : INTEGER := 370;
	
	--THIS IS THE SDRAM REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 511 := 0; --9 BIT NUMBER
	
	--68000 STATE MACHINE SIGNALS
	SIGNAL nLDSOUT : STD_LOGIC := '1'; --VALUE FOR _LDS
	SIGNAL nUDSOUT : STD_LOGIC := '1'; --VALUE FOR _UDS
	SIGNAL dsenable : STD_LOGIC := '0'; --ENABLE THE 68000 DATA STROBES
	SIGNAL sm_enabled : STD_LOGIC := '0'; --ARE WE ACCESSING THE AMIGA 2000 BOARD?
	SIGNAL eclk_counter : INTEGER RANGE 0 TO 15 := 0; --4 BIT NUMBER E COUNTER
	SIGNAL vmacount : INTEGER RANGE 0 TO 15 := 0; --COUNTER FOR E VMA
	SIGNAL eclk : STD_LOGIC := '0'; --E SIGNAL FOR "A2000"
	SIGNAL esync : STD_LOGIC := '0'; --ONE CLOCK DELAY OF E
	SIGNAL DSACKEN : STD_LOGIC := '0'; --ENABLE _DSACK1
	SIGNAL STATE7 : STD_LOGIC := '0'; --ARE WE IN 68000 STATE 7?
	
	--CLOCK SIGNALS
	SIGNAL basis7m : STD_LOGIC := '0';

begin

	------------
	-- CLOCKS --
	------------
	
	--THE 7MHz CLOCK CAN BE PULLED FROM THE CPU SLOT OF THE B2000, BUT MUST BE RECREATED
	--FROM C1 AND C2 ON THE A2000.
		
	basis7m <= '1' WHEN ( B2000 = '1' AND A7M = '1' ) OR ( B2000 = '0' AND (nC1 = '1' XOR nC3 = '0' )) ELSE '0';	
	
	--This clock is used to latch the interrupt lines between the motherboard
	--and the 68030.  If this isn't done, you'll get phantom interrupts
	--that you probably won't even notice in AmigaOS, but can be fatal to
	--time critical interrupt code in UNIX and possibly even AmigaOS. U708

	IPLCLK <= basis7m;

	----------------------------------
	-- AUTOREFRESH COUNTER SETTINGS --
	----------------------------------
	
	--THIS IS THE SDRAM REFRESH COUNTER USED BY U601 AND U602.
	--SET THE REFRESH COUNTER TO THE NUMBER SPECIFIED BY THE USER VIA JUMPERS.
	--THE JUMPERS J403 AND J404 ARE PULLED TO +3.3V, SO NO JUMPER = 1.
	--25MHz IS THE DEFAULT.
	 
	REFRESH_COUNTER_DEFAULT <=
		REFRESH_COUNTER_50 WHEN SDSPEED (1 DOWNTO 0) = "00" ELSE
		REFRESH_COUNTER_40 WHEN SDSPEED (1 DOWNTO 0) = "01" ELSE
		REFRESH_COUNTER_33 WHEN SDSPEED (1 DOWNTO 0) = "10" ELSE
		REFRESH_COUNTER_25 WHEN SDSPEED (1 DOWNTO 0) = "11";
		
	---------------------------
	-- SDRAM REFRESH COUNTER --
	---------------------------
	
	--THE SDRAM REFRESH COUNTER IS INCREMENTED ONE TIME PER 68030 CLOCK CYCLE.
	--ONCE IT REACHES THE DEFINED VALUE, IT IS RESET TO ZERO AND REF IS ASSERTED AND 
	--HELD UNTIL BOTH REFACKZ2 AND REFACKZ3 ARE ASSERTED. REF IS THEN NEGATED.
	--SIMLATED OK
	
	PROCESS (CPUCLK) BEGIN
		IF RISING_EDGE(CPUCLK) THEN
			IF (REFRESH_COUNTER > REFRESH_COUNTER_DEFAULT) THEN			
				REF <= '1';
				REFRESH_COUNTER <= 0;				
			ELSE			
				REFRESH_COUNTER <= REFRESH_COUNTER + 1;				
				IF REF = '0' OR (REF = '1' AND REFACKZ2 = '1' AND REFACKZ3 = '1') THEN
					REF <= '0';
				ELSE
					REF <= '1';
				END IF;
				
			END IF;
		END IF;
	END PROCESS;			

	---------------------
	-- REQUEST THE BUS --
	---------------------	

	--Request the Amiga 2000 bus at power up or reset so be we can become the BOSS.
	--Bus mastering is supposed to be clocked on the 7MHz rising edge (A2000 technical reference).
	--BUS REQUEST (_BR) HAS A PULLUP ON THE A2000.
	
	PROCESS (basis7m) BEGIN
		IF (RISING_EDGE (basis7m)) THEN
		
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
	--activated. U504

	--Check if the bus has been granted and lock in BOSS
	--Bus mastering is supposed to be clocked on the 7MHz rising edge (A2000 technical reference)
	--Doing it like this avoids combitorial loops and it should work fine
	--BOSS HAS A PULLUP ON THE A2000

	PROCESS (basis7m) BEGIN
		IF (RISING_EDGE (basis7m)) THEN
			IF (nBOSS = '0') THEN
				--HOLD BOSS UNTIL ONE OF THE CONDITION BELOW IS FALSE
				IF ( nHALT = '1' AND MODE68K = '0') OR ( nRESET = '1' AND MODE68K = '0' ) THEN
					nBOSS <= '0';
				ELSE
					nBOSS <= 'Z';
				END IF;
			ELSE
				--ASSERT _BGACK (_BOSS) WHEN THE 68000 HAS FINISHED ITS CURRENT CYCLE (_AS AND _DTACK ARE NEGATED).
				IF 
					( B2000 = '1' AND nABG = '0' AND nAAS ='1' AND nDTACK = '1' AND nHALT = '1' AND nRESET = '1' AND MODE68K = '0' ) OR 
					( B2000 = '0' AND nHALT ='1' AND nRESET ='1') 
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
	--under CPU control, but not if the RESENB line is negated. U301
	
	--THERE IS A PULLUP ON THE A2000 FOR RESET (RST).
	--FLOAT RESET UNTIL WE ARE ACTUALLY READY TO USE IT.
	
	--RESET		= BOSS & CPURESET & RESENB;
	--RSTENB IS ACTIVE WHEN ROM IS CONFIGED...CHEAT HERE AND GO WITH OUR CONFIGED SIGNAL FROM U601
	--RSTENB IN REV 9 2630 IS TIED TO +5V, SO WE SHOULD BE ABLE TO IGNORE IT HERE.
	nRESET <= '0' WHEN nBOSS = '0' AND nCPURESET ='0' ELSE 'Z';
	
	---------------------------
	-- E AND RELATED SIGNALS --
	---------------------------
	
	--WHEN IN "A2000" MODE, WE MUST GENERATE OUR OWN E BECAUSE THE 68000 
	--PROCESSOR IS REMOVED FROM THE MOTHERBOARD. WHEN IN "B2000" MODE, WE CAN
	--USE THE EXISTING E SIGNAL BUT WE MUST REPLY TO _VPA SIGNALS EITHER WAY.
	
	E <= 'Z' WHEN B2000 = '1' ELSE eclk;
	
	--E IS A TIMING SIGNAL FOR 6800 BASED PERIPHERLS. THE CIA'S USE THE E SIGNAL.
	--IT IS 6 CLOCK CYCLES LOW AND 4 HIGH AND ASYNCHRONOUS WITH THE CPU CLOCK.  
	--THAT MEANS WE CAN MAKE OUR OWN WITH A SIMPLE COUNTER DRIVEN FROM THE AMIGA 
	--7MHz CLOCK. WE ONLY CREATE OUR OWN E WHEN WE ARE IN AN "A2000" MACHINE. 
	--TRIVIA: E MEANS "ENABLE"

	PROCESS (basis7m) BEGIN
		IF FALLING_EDGE (basis7m) AND B2000 = '0' THEN
			
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
	
	PROCESS (basis7m) BEGIN
		
		IF FALLING_EDGE (basis7m) THEN
			esync <= E;
		END IF;
		
	END PROCESS;
	
	--VMA (VALID MEMORY ADDRESS) IS A 6800 SIGNAL DRIVEN IN RESPONSE TO VPA (VALID PERIPHERAL ADDRESS).
	--VMA IS TO BE ASSERTED WHEN THE PROCESSOR IS SYNCED TO THE E CLOCK. THIS IS DONE IN THE 68000
	--STATE MACHINE AND IS DISCUSSED IN APPENDIX B OF THE 68000 MANUAL.	
	--WE USE THIS COUNTER SO WE KNOW WHEN TO ASSERT _VMA AS IT TRACKS WHERE WE ARE IN THE E CYCLE.
	--THE COUNTER GOES FROM 0 TO 9 TO ACCOUNT FOR THE 10 TOTAL CLOCKS IN AN E CYCLE.
	
	PROCESS (basis7m) BEGIN	

		IF FALLING_EDGE (basis7m) THEN
			IF E = '0' AND esync = '1' THEN
				--RESET THE COUNTER
				vmacount <= 0;		
			ELSE
				vmacount <= vmacount + 1;
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
		--NOT DMA AND ACCESSING MEMORY IN 68000 MODE (BOSS=1, MODE68K =1)
		--NOT DMA AND ACCESSING IDE IN 68000 MODE (BOSS=1, MODE68K =1)
		
	--SMDIS (STATE MACHINE DISABLED) IS ASSERTED (=1) WHEN USING RESOURCES ON THE 2630 CARD
		--IDE MEMORY SPACE
		--ZORRO 3 MEMORY SPACE
		--ZORRO 2 MEMORY SPACE
		--ROM MEMORY SPACE
		
	nADOEH <= '0' 
		WHEN 
			--( nBOSS = '0' AND nBGACK = '1' AND MEMACCESS = '0' AND nAS = '0' AND nONBOARD = '1' AND nEXTERN = '1' ) 
			( nBOSS = '0' AND nBGACK = '1' AND SMDIS = '0' AND nAAS = '0' ) OR
			( nBOSS = '0' AND nBGACK = '0' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '1' )  
			--OR ( nBOSS = '1' AND MODE68K = '1' AND nBGACK = '1' AND nMEMZ2 = '0' AND nAAS = '0' ) 
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
	--BECOME INVALID BEFORE THE 6030 LATCHES. I AM HOPING TO MAKE IT WORK
	--SO WE DON'T NEED TO USE THE 74xx646'S. THEY ARE COSTLY WHEN COMPARED
	--TO A 74xx245, FOR EXAMPLE.

	--DRSEL		= BOSS & !BGACK & RW;
	--DRSEL <= '1' WHEN nBOSS = '0' AND nBGACK = '1' AND RnW = '1' ELSE '0';
	DRSEL <= '0';
	
	--This is data direction control U500
	--PIN 5		= !BGACK	;	/* '030 Bus grant acknowledge */
	--PIN 16	= !ADDIR	;	/* Amiga data direction control */
	--!ADDIR	=  BGACK & !RW		# !BGACK &  RW;
	ADDIR <= '1'
		WHEN 
			( nBGACK = '0' AND RnW = '1' ) OR
			( nBGACK = '1' AND RnW = '0' ) 
		ELSE 
			'0';
	
	--TRISTATE is an output used to tristate all signals that go to the 68000
	--bus. This is done on powerup before BOSS is asserted and whenever a DMA
	--device has control of the A2000 Bus.  We want tristate when we're not 
	--BOSS, or when we are BOSS but we're being DMAed. U305

	--TRISTATE	= !BOSS # (BOSS & BGACK);
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
	--SINCE THE REQUESTING DEVICE IS SUPPOSED TO WAIT UNTIL THE PROCESSOR HAS COMPLETED
	--IT'S CURRENT CYCLE, WE MUST DO THE ARBITRATION FOR THEM. WAIT UNTIL THE DATA 
	--TRANSFER SIGNALS ARE ALL CLEAR BEFORE PASSING BUS GRANT TO THE REQUESTING DEVICE.
	nABG <= '0' WHEN nBG = '0' AND nBOSS = '0' AND nAS = '1' AND nDSACK1 = '1' AND nSTERM = '1' ELSE 'Z' WHEN nBOSS = '1' ELSE '1'; 
	
	----------------------------------------
	-- 68000 STATE MACHINE ENABLE/DISABLE --
	----------------------------------------
			
	--SMDIS (STATE MACHINE DISABLE) IS USED TO INDICATE ROM, CPU SPACE, 
	--ZORRO 2 RAM, ZORRO 3 RAM, AND IDE ACCESS ACTIVITIES.
	
	--sm_enabled (STATE MACHINE ENABLED) IS '1' WHEN WE ARE NOT USING ANY 
	--RESOURCES ON OUR CARD. WE ARE GOING AFTER SOMETHING ON THE AMIGA 2000.
	
	sm_enabled <= '1' 
		WHEN 
			--(nONBOARD = '1' AND MEMACCESS = '0' AND nEXTERN = '1')
			SMDIS = '0' AND 
			nBGACK = '1' AND 
			FC ( 2 downto 0 ) /= "111"
		ELSE 
			'0';
			
	-------------------------
	-- 68000 STATE MACHINE --
	-------------------------
	
	--THIS IS HOW THE 68030 COMMUNICATES WITH THE AMIGA 2000 BOARD, WHICH ONLY 
	--UNDERSTANDS MC68000. WITH THIS STATE MACHINE, WE SLOW THINGS DOWN
	--BY USING THE 7MHz CLOCK TO HELP SUPPLY 68000 COMPATABLE SIGNALS AND TIMINGS.
	
	--LOTS OF STUFF GOING ON HERE. WE MUST CONSIDER BOTH 6800 AND 68000 DATA TRANSFERS AND
	--WE MUST SUPPLY THE APPROPRIATE SUPPORTING SIGNALS AT THE CORRECT TIME. 
	
	--DO NOT START A 68000/6800 CYCLE ON DMA, FPU, IDE, OR ON BOARD MEMORY ACCESS.

	--THE CHALLENGE HERE IS TO GET THE TIMINGS OF THE 68000 BASED A2000 TO MATCH UP
	--WITH THE TIMINGS OF THE 68030 ON OUR CARD, WHICH CAN RUN ANYWHERE UP TO 50MHz.
	--ANOTHER VARIABLE IS THE STATES OF THE TWO ARCHITECTURES ARE NOT ALIGNED.
	--IF THE TIMINGS ARE NOT RIGHT OR WE GET OFF A STATE, THE SYSTEM WILL STOP RESPONDING
	--DUE TO MISSED SIGNALS OR CORRUPTED DATA FROM POORLY TIMED LATCHING.
		
	--68000 DATA STROBE OUTPUTS
	--FOR 68000 DATA STROBES, SEE TABLE 7-7 (pp7-23) IN 68030 MANUAL
	--nUDS IS ASSERTED ANYWHERE WE SEE W (WORD) IN COLUMN D31:24 (UPPER BYTE)
	--nLDS IS ASSERTED ANYWHERE WE SEE W (WORD) IN COLUMN D23:16 (LOWER BYTE)
	
	nUDS <= nUDSOUT WHEN dsenable = '1' ELSE 'Z';
	nLDS <= nLDSOUT WHEN dsenable = '1' ELSE 'Z';	

	--THE STATE MACHINE

	PROCESS (basis7m, TRISTATE, sm_enabled) BEGIN

		IF TRISTATE = '1' OR sm_enabled = '0' THEN

			--WE WANT TO TRISTATE THESE SIGNALS WHEN THE STATE MACHINE IS NOT ACTIVE.

			ARnW <= 'Z';
			nAAS <= 'Z';
			nVMA <= 'Z';
			DSACKEN <= '0';
			DSENABLE <= '0';

			--SET CURRENT STATE TO S0
			CURRENT_STATE <= S0;

		ELSIF RISING_EDGE (basis7m) THEN

			--MOST OF THE INTERESTING STATES ARE FIRED ON THE RISING EDGE.
			--THE ONLY EXCEPTION IS S7, WHICH IS ON THE FALLING EDGE.
			
			CASE (CURRENT_STATE) IS

				WHEN S0 =>

					--STATE 0 IS THE START OF A CYCLE.
					--WATCH FOR ASSERTION OF _AS TO TRIGGER THE START OF A CYCLE.
					--WE WANT TO WAIT UNTIL THE CLOCK IS HIGH SO WE START IN STATE 0, NOT STATE 1.					
					--WE CONSIDER _DSACK1 TO ENSURE WE DON'T START IF THE PREVIOUS
					--CYCLE IS NOT YET COMPLETE IN A BACK-TO-BACK SITUATION.
					--THAT SHOULD NEVER HAPPEN, BUT, YOU KNOW.
					
					DSACKEN <= '0';

					IF nAS = '0' AND nDSACK1 /= '0' THEN
					
						CURRENT_STATE <= S2;

						nAAS <= '0';	
						ARnW <= RnW;

						--PREP THE DATA STROBES	
						IF A(0) = '0' THEN
							nUDSOUT <= '0';
						ELSE
							nUDSOUT <= '1';
						END IF;

						IF SIZ(1) = '1' OR SIZ(0) = '0' OR A(0) = '1' THEN
							nLDSOUT <= '0';
						ELSE
							nLDSOUT <= '1';
						END IF;	

						--DURING A READ CYCLE, ASSERT DATA STROBES WITH THE ADDRESS STROBE.
						IF RnW = '1' THEN						
							
							dsenable <= '1';

						END IF;

					END IF;

				WHEN S2 =>

					CURRENT_STATE <= S4;

					--DURING A WRITE CYCLE, ASSERT DATA STROBES AT S4.
					IF RnW = '0' THEN						
						
						dsenable <= '1';

					END IF;

				WHEN S4 =>

					--SOME IMPORTANT STUFF HAPPENS AT S4.
					--IF THIS IS A 6800 CYCLE, ASSERT _VMA IF WE ARE IN SYNC WITH E
					--IF THIS IS A 68000 CYCLE, LOOK FOR ASSERTION OF _DTACK.
					--IF THIS IS A 68000 WRITE CYCLE, ASSERT THE DATA STROBES HERE (SET PREVIOUSLY).

					IF (nVPA = '0') THEN
						--THIS IS A 6800 CYCLE, WE WAIT HERE UNTIL THE
						--APPROPRIATE TIME IS REACHED ON E TO ASSERT _VMA, WHICH IS 
						--BETWEEN 3 AND 4 CLOCK CYCLES AFTER E GOES TO LOGIC LOW.
								
						IF vmacount = 1 OR vmacount = 2 THEN
								
							nVMA <= '0';
							DSACKEN <= '1';
							CURRENT_STATE <= S6;
							
						END IF;
							
					ELSE
								
						IF (nDTACK = '0' OR nBERR = '0') THEN

							--WHEN THE TARGET DEVICE HAS ASSERTED _DTACK OR _BERR, WE CONTINUE ON.
							--OTHERWISE, INSERT WAIT STATES UNTIL _DTACK OR _BERR IS ASSERTED.
									
							DSACKEN <= '1';
							CURRENT_STATE <= S6;
							
						END IF;

					END IF;

				WHEN S6 =>

					--AT S6, DATA IS PLACED ON THE BUS WHEN READING.
					--WE WANT TO ASSERT _DSACK1 ON THE FALLING EDGE OF S7.
					--TO ACCOMPLISH THAT, WE ASSERT THE DSACK ENABLE SIGNAL, 
					--WHICH IS THEN HANDLED BY ANOTHER CLOCKED PROCESS THAT 
					--WORKS ON THE FALLING EDGE OF THE 7MHz CLOCK.

					--BY DOING THIS, WE ASSERT _DSACK1 DURING S7 ONLY.
					--REGARDLESS OF THE 68030 ADDRESS STROBE.

					CURRENT_STATE <= S0;
					ARnW <= '1';
					nAAS <= '1';
					nVMA <= '1';
					nUDSOUT <= '1';
					nLDSOUT <= '1';					
					DSACKEN <= '0';

			END CASE;

		END IF;

	END PROCESS;
	
	--THIS PROCESS ASSERTS _DSACK1 WHEN DSACKEN AND STATE7 ARE ASSERTED.
	--IT CONTINUES TO ASSERT _DSACK1 UNTIL _AS IS NEGATED.

	PROCESS (CPUCLK) BEGIN

		--ASSERT _DSACK1 DURING STATE 7 AND HOLD UNTIL _AS IS NEGATED.

		IF RISING_EDGE (CPUCLK) THEN

			IF sm_enabled = '1' THEN

				IF STATE7 = '1' AND DSACKEN = '1' THEN 

					--ASSERT _DSACK1.
					nDSACK1 <= '0';

				ELSIF nDSACK1 = '0' AND nAS = '0' THEN

					--HOLD _DSACK1 WHILE _AS IS ASSERTED.
					nDSACK1 <= '0';
				
				ELSE

					--WE ARE IN A STATE MACHINE CYCLE, BUT NOT STATE 7.
					nDSACK1 <= '1';
					
				END IF;

			ELSE

				--WE ARE NOT IN A CYCLE.
				nDSACK1 <= 'Z';

			END IF;

		END IF;

	END PROCESS;
	
	
	--THIS PROCESS DETERMINES WHEN WE ARE IN STATE 7.
	--THIS IS DONE BY CHECKING IF DSACKEN IS ASSERTED, WHICH IS IN STATES 6 AND 7.
	--WE CHECK FOR IT ON THE FALLING EDGE OF THE 7MHz CLOCK, RESULTING IN CONFIRMATION THAT WE ARE IN STATE 7.
	--DSACKEN IS NEGATED ON THE NEXT RISING EDGE, LEADING TO STATE 0.
	
	PROCESS (basis7m) BEGIN

		IF FALLING_EDGE (basis7m) THEN 
		
			IF DSACKEN = '1' THEN

				--WE ARE IN STATE 7

				STATE7 <= '1';

			ELSE

				STATE7 <= '0';

			END IF;

		END IF;

	END PROCESS;

end Behavioral;