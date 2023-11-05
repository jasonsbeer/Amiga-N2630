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
-- Create Date:    JANUARY 9, 2023 
-- Design Name:    N2630 U600 CPLD
-- Project Name:   N2630 https://github.com/jasonsbeer/Amiga-N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description: BOSS, BUS INTERFACE, 6800 STATE MACHINE, 68000 STATE MACHINE
--
-- Revision History:
--    v1.0.0 21-JAN-23 Initial Production Release - JN
--    v1.1.0 02-FEB-23 Removed floating signals from 68k state machine while BOSS - JN
--                     Added bus grant delay to help accomodate Buster. -JN
--    v1.1.1 08-FEB-23 Hardened bus grant logic. -JN
--    v2.0.3 01-OCT-23 Added edge check on 68000 state machine state 4 to prevent responding on wrong edge with delayed assertion of _DTACK. -JN
--                     Added synchronizer to 68000 state machine start. -JN
--    v2.0.4 04-OCT-23 Fixed bus grant signal. -JN
--                     Altered 7MHz clock logic. -JN
--    v2.0.5 12-OCT-23 Added _DTACK FF to finally fix delayed _DTACK. -JN
--                     Fixed 68000 State 4 CDAC phase. -JN
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
	nBR : INOUT STD_LOGIC; --68030 BUS REQUEST SIGNAL	
	CLK7 : INOUT STD_LOGIC; --7MHz CLOCK OUTPUT
	
	ADDIR : OUT STD_LOGIC; --DIRECTION/LATCH OF 74FTC624 LOGIC
	IPLCLK : OUT STD_LOGIC; --CLOCK PULSE FOR U700
	DRSEL : OUT STD_LOGIC; --DIRECTION SELECTION FOR U701 U702
	nADOEL : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nADOEH : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nLDS : OUT STD_LOGIC; --68000 _LDS
	nUDS : OUT STD_LOGIC; --68000 _UDS
	nCLK7 : OUT STD_LOGIC --INVERTED 7MHZ OUT FOR 74HCT646 DATA LATCH
	
);

end U600;

architecture Behavioral of U600 is

	--DEFINE THE 68000 STATE MACHINE STATES
	TYPE STATE68K IS ( S0, S1, S2, S3, S4, S5, S6, S7 );
	SIGNAL CURRENT_STATE : STATE68K;	
	
	--68000 STATE MACHINE SIGNALS	
	SIGNAL sm_enabled : STD_LOGIC; --ARE WE ACCESSING THE AMIGA 2000 BOARD?
	SIGNAL eclk_counter : INTEGER RANGE 0 TO 15; --4 BIT NUMBER E COUNTER
	SIGNAL vmacount : INTEGER RANGE 0 TO 15; --COUNTER FOR E VMA
	SIGNAL eclk : STD_LOGIC; --E SIGNAL FOR "A2000"
	SIGNAL esync : STD_LOGIC; --ONE CLOCK DELAY OF E
	SIGNAL dsacken : STD_LOGIC; --ENABLE _DSACK1
	SIGNAL dsackcount : INTEGER RANGE 0 TO 2; --STATE MACHINE DSACK1 PROCESS
	SIGNAL ascycle : STD_LOGIC; --ENABLE AMIGA ADDRESS STROBE SIGNAL
	SIGNAL wcycle : STD_LOGIC;
	SIGNAL writecycle : STD_LOGIC;
	SIGNAL readcycle : STD_LOGIC;
	SIGNAL dsackcycle : STD_LOGIC; --ENABLE THE 68030 _DSACK1 SIGNAL
	SIGNAL vmacycle :STD_LOGIC; --ENABLE THE AMIGA _VMA SIGNAL
	SIGNAL edsack : STD_LOGIC;
	SIGNAL abg_delay : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL abg_disable : STD_LOGIC;
	SIGNAL SM_START : STD_LOGIC;
	SIGNAL dtack_asserted : STD_LOGIC;
	
	--CLOCK SIGNALS
	SIGNAL CLK14 : STD_LOGIC := '0';

begin

	------------
	-- CLOCKS --
	------------
	
	--IN AN EFFORT TO SUPPORT THE ORIGINAL GERMAN "A2000" MACHINE, WE CAN RECREATE THE 
	--7MHz SYSTEM CLOCK BY XNORing C1 AND C3. FOR A "B2000" MACHINE, WE PASS THROUGH
	--THE 7MHz CLOCK PROVIDED ON THE CPU SLOT.
	
	CLK7 <= A7M WHEN B2000 = '1' ELSE nC1 XNOR nC3;
	
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
	
	--IN ORDER TO BECOME BOSS, WE NEED TO FIRST REQUEST THE BUS FROM THE MC68000.
	
	PROCESS (CLK7, nRESET, MODE68K) BEGIN
	
		IF nRESET = '0' OR MODE68K = '1' THEN
		
			nABR <= 'Z';
			
		ELSIF RISING_EDGE (CLK7) THEN
		
			IF nBOSS = '1' AND MODE68K = '0' THEN
			
				IF nABR = '0' OR nAAS = '0' THEN 
				
					nABR <= '0';
					
				ELSE
				
					nABR <= '1';
					
				END IF;
				
			ELSE
			
				nABR <= 'Z';
				
			END IF;
			
		END IF;
		
	END PROCESS;

	-----------------
	-- BECOME BOSS --
	-----------------	
	
	--WE NEED TO BECOME B.O.S.S. (Biomorphic Organisational Systems Supervisor)

	PROCESS (CLK7, nRESET) BEGIN

		IF RISING_EDGE (CLK7) THEN
		
			IF (nBOSS = '0') THEN
				IF ( nHALT = '1' AND MODE68K = '0') OR ( nRESET = '1' AND MODE68K = '0' ) THEN
					nBOSS <= '0';
				ELSE
					nBOSS <= '1';
				END IF;
			ELSE
				IF 
					( B2000 = '1' AND nABG = '0' AND nAAS = '1' AND nDTACK = '1' AND nHALT = '1' AND MODE68K = '0' ) OR 
					( B2000 = '0' AND nHALT = '1') 
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
	
	--ADOEH CONTROLS D31..16. SEE DRSEL SIGNAL (BELOW). U701, U702
	--WE WANT _ADOEH ASSERTED (ENABLED) WHEN
		--NOT DMA AND ACCESSING THE A2000 BOARD IN 68030 MODE (BOSS=0, STATE MACHINE ENABLED)
		--DMA AND ACCESSING Z2 MEMORY IN 68030 MODE (BOSS=0)
		--NOT DMA AND ACCESSING MEMORY IN 68000 MODE (BOSS=1, MODE68K =1) NOTE: NOT IMPLEMENTED
		--NOT DMA AND ACCESSING IDE IN 68000 MODE (BOSS=1, MODE68K =1) NOTE: NOT IMPLEMENTED
		
	--SMDIS (STATE MACHINE DISABLED) IS ASSERTED (=1) WHEN USING RESOURCES ON THE 2630 CARD
		--IDE ADDRESS SPACE
		--ZORRO 3 MEMORY ADDRESS SPACE
		--ZORRO 2 MEMORY ADDRESS SPACE
		--ROM ADDRESS SPACE
		
	nADOEH <= '0' 
		WHEN 
			( nBOSS = '0' AND nBGACK = '1' AND sm_enabled = '1' ) OR
			( nBOSS = '0' AND nBGACK = '0' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '1' )  
			--OR ( nBOSS = '1' AND MODE68K = '1' AND nBGACK = '1' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '1' ) 
			--OR ( nBOSS = '1' AND MODE68K = '1' AND nBGACK = '1' AND nIDEACCESS AND nAAS = '0' )
			
		ELSE
			'1';
	
	--ADOEL CONTROLS D15..0. U703, U704 AND SHOULD ONLY BE ACTIVE DURING DMA.
	nADOEL <= '0' 
		WHEN 
			nBOSS = '0' AND nBGACK = '0' AND nMEMZ2 = '0' AND nAAS = '0' AND A(1) = '0' 
		ELSE 
			'1';
		
	--THE N2630 LATCHES DATA ON READS BECAUSE IT NEGATES _AAS AT THE MOMENT
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
	
	--THIS SIGNAL IS USED BY U606 AND OUR 68000 STATE MACHINE.
	TRISTATE <= '1' WHEN nBOSS = '1' OR ( nBOSS = '0' AND nBGACK = '0' ) ELSE '0';
			
	----------------------------
	-- ZORRO II BUS MASTERING --
	----------------------------
	
	--WHEN THE BUS IS GRANTED AND THE ZORRO 2 DEVICE HAS ACK'd,
	--THE ZORRO 2 DEVICE DRIVES THE R_W AND _AS SIGNALS, WHICH
	--WE CONNECT THROUGH TO THE MC68030.
	
	RnW <= ARnW WHEN nBOSS = '0' AND nBGACK = '0' ELSE 'Z';
	nAS <= nAAS WHEN nBOSS = '0' AND nBGACK = '0' ELSE 'Z';
	
	--THE ZORRO2 _BGACK SIGNAL GOES TO OUR MC68030 _BGACK WHEN WE ARE BOSS.
	
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN 
		
			nBGACK <= '1';
	
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF nBOSS = '0' AND nABGACK = '0' THEN
			
				nBGACK <= '0';
				
			ELSE
			
				nBGACK <= '1';
				
			END IF;
			
		END IF;
		
	END PROCESS;
			
	--THE BUSTER _CBR SIGNAL FEEDS THE MC68030 _BR WHEN WE ARE BOSS.
	
	nBR <= 
			'0' WHEN nABR = '0' AND nBOSS = '0' AND nBGACK = '1' 
		ELSE
			'Z'; --THERE IS A PULLUP ON BR.
	
	--ANY DEVICE REQUESTING THE BUS CANNOT "SEE" ALL THE 68030 DATA TRANSFER SIGNALS.
	--SINCE THE REQUESTING DEVICE MUST WAIT UNTIL THE PROCESSOR HAS COMPLETED
	--IT'S CURRENT CYCLE, WE MUST DO THE ARBITRATION FOR THEM. WAIT UNTIL THE DATA 
	--TRANSFER SIGNALS ARE ALL CLEAR BEFORE PASSING BUS GRANT TO THE REQUESTING DEVICE.	
	
	--abg_disable <= '1' WHEN nBOSS = '1' OR (nABG = '1' AND (nDSACK1 = '0' OR nAS = '0' OR nSTERM = '0')) ELSE '0';
	abg_disable <= nBOSS OR (nABG AND (NOT nDSACK1 OR NOT nAS OR NOT nSTERM));
	
	--PASS THE BUS GRANT SIGNAL FROM THE MC68030 TO THE REQUESTING DEVICE.
	--BUSTER WANTS SOME DELAY BETWEEN ASSERTING THE BUS REQUEST AND RECEIVING A BUS GRANT.
	--IF THESE TWO EVENTS HAPPEN TOO CLOSE TOGETHER, BUSTER MISSES THE BUS GRANT ASSERTION.
	--WE USE A SIMPLE SHIFT REGISTER TO DELAY THE ASSERTION OF _CBG TO BUSTER.
	
	nABG <= '0' WHEN abg_delay = "00" AND abg_disable = '0' ELSE 'Z';
	
	PROCESS (CLK7, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			abg_delay <= (OTHERS => '1');
	
		ELSIF RISING_EDGE (CLK7) THEN	
		
			abg_delay <= abg_delay(0) & nBG;
			
		END IF;
		
	END PROCESS;
	
	----------------------------------------
	-- 68000 STATE MACHINE ENABLE/DISABLE --
	----------------------------------------
			
	--SMDIS (STATE MACHINE DISABLE) IS USED TO INDICATE ROM, CPU SPACE, 
	--ZORRO 2 RAM, ZORRO 3 RAM, AND IDE ACCESS ACTIVITIES.
	
	--sm_enabled (STATE MACHINE ENABLED) IS '1' WHEN WE ARE NOT ADDRESSING 
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
			
	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	--THE _DSACK1 PROCESS ASSERTS _DSACK1 DURING STATE 7 OF 
	--THE 6800/68000 STATE MACHINE. WE HOLD IT FOR TWO CLOCK CYCLES
	--AND THEN NEGATE. THIS HOLDS IT LONG ENOUGH FOR THE 68030 TO 
	--LATCH THE SIGNAL. THIS ALSO WORKS BETTER AT 50MHz WHEN
	--COMPARED TO NEGATING _DSACK1 IN RESPONSE TO THE NEGATION OF _AS.
	
	nDSACK1 <= 
		'0' WHEN dsackcycle = '1' AND sm_enabled = '1'
	ELSE
		'1' WHEN sm_enabled = '1' 
	ELSE
		'Z';
	
	PROCESS (CPUCLK, nRESET, dsacken) BEGIN
	
		IF dsacken = '0' OR nRESET = '0' THEN
		
			dsackcycle <= '0';
			dsackcount <= 0;
			
		ELSIF FALLING_EDGE (CPUCLK) THEN
			
			CASE dsackcount IS
			
				WHEN 0 =>
				
					IF dsacken = '1' THEN
					
						dsackcount <= 1;
						dsackcycle <= '1';
						
					END IF;
					
				WHEN 2 =>
				
					dsackcycle <= '0';
					
				WHEN others =>
				
					dsackcount <= dsackcount + 1;
				
			END CASE;
			
		END IF;	
	
	END PROCESS;

	---------------------------
	--  68000 STATE MACHINE  --
	-- DATA TRANSFER SIGNALS --
	---------------------------	
	
	nUDS <= 
			'0' WHEN A(0) = '0' AND (writecycle = '1' OR readcycle = '1') AND TRISTATE = '0'
		ELSE 
			'1' WHEN TRISTATE = '0'
		ELSE
			'Z';
			
	nLDS <= 
			'0' WHEN (SIZ(1) = '1' OR SIZ(0) = '0' OR A(0) = '1') AND (writecycle = '1' OR readcycle = '1') AND TRISTATE = '0'
		ELSE 
			'1' WHEN TRISTATE = '0'
		ELSE
			'Z';
	
	nAAS <= 
			'0' WHEN ascycle = '1' AND TRISTATE = '0'
		ELSE 
			'1' WHEN TRISTATE = '0' 
		ELSE 
			'Z';
	
	ARnW <=
			'0' WHEN wcycle = '1' AND TRISTATE = '0'
		ELSE
			'1' WHEN TRISTATE = '0'
		ELSE
			'Z';
			
	nVMA <= 
			'0' WHEN vmacycle = '1' AND TRISTATE = '0'
		ELSE 
			'1' WHEN TRISTATE = '0'
		ELSE
			'Z';

	--------------------------
	-- _DTACK LATCH PROCESS --
	--------------------------

	--BECAUSE OUR 7MHz CLOCK IS JUST BEHIND THE ZORRO2 7MHz CLOCK.
	--SOME DEVICES ASSERT _DTACK ON THE FALLING EDGE, WHICH MESSES
	--UP THE 68000 STATE MACHINE. THIS IS BECAUSE OUR DELAYED CLOCK EDGE
	--CATCHES _DTACK TOO SOON. THIS FF DELAYS THE FALLING EDGE ASSERTION
	--JUST ENOUGH TO PREVENT THIS ISSUE.

	PROCESS (nDTACK, nAAS, nRESET) BEGIN

		IF nAAS = '1' OR nRESET = '0' THEN

			dtack_asserted <= '0';

		ELSIF FALLING_EDGE (nDTACK) THEN

			dtack_asserted <= '1';

		END IF;

	END PROCESS;
		 
	---------------------------
	--  68000 STATE MACHINE  --
	-- STATE MACHINE PROCESS --
	---------------------------	

	PROCESS (CLK14, nRESET, sm_enabled) BEGIN

		IF nRESET = '0' OR sm_enabled = '0' THEN		

			CURRENT_STATE <= S0;
			SM_START <= '0';
			
			ascycle <= '0';
			wcycle <= '0';
			readcycle <= '0';
			writecycle <= '0';
			dsacken <= '0';

		ELSIF RISING_EDGE (CLK14) THEN
		
			--BEGIN 68000 STATE MACHINE--
		 
			CASE (CURRENT_STATE) IS

				WHEN S0 =>

					--STATE 0 IS THE START OF A CYCLE. 
					--WE MAKE SURE TO START ON THE CORRECT EDGE BY SAMPLING CDAC.					

					IF CDAC = '1' AND SM_START = '1' THEN

						CURRENT_STATE <= S1;
						  
					ELSE
						
						CURRENT_STATE <= S0;
						SM_START <= NOT nAS;

					END IF;

				WHEN S1 =>            

					--PROCESSOR DRIVES A VALID ADDRESS ON THE BUS IN STATE 1. 
					--NOTHING MUCH FOR US TO DO.
					--SET UP FOR STATE 2.
				
					CURRENT_STATE <= S2;
					
					ascycle <= '1';
					
					IF RnW = '1' THEN
						readcycle <= '1';
					ELSE
						readcycle <= '0';
						wcycle <= '1';
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

					IF CDAC = '1' AND (dtack_asserted = '1' OR nBERR = '0' OR edsack = '1') THEN

						--WHEN THE TARGET DEVICE HAS ASSERTED _DTACK OR _BERR, WE CONTINUE ON.
						--IF THIS IS A 6800 (CIA) CYCLE, WE WAIT UNTIL E IS HIGH TO PROCEED.
						--OTHERWISE, INSERT WAIT STATES UNTIL ONE OF THESE CONDITIONS IS SATISFIED.

						CURRENT_STATE <= S5;
						
					ELSE
						
						CURRENT_STATE <= S4;

					END IF;

				WHEN S5 =>

					--NOTHING HAPPENS HERE. GO TO STATE 6.

					IF CDAC = '1' THEN --1 WORKS GREAT, 0 WILL EVENTUALLY CRASH.
						CURRENT_STATE <= S6; 
					END IF;

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
					wcycle <= '0';
					SM_START <= '0';
					CURRENT_STATE <= S0;

			END CASE;
				
		END IF;
			
	END PROCESS;

END Behavioral;
