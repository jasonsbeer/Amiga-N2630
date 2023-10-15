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
--    v2.0.6 13-OCT-23 Tweaked 68000 state machine timing. -JN
--    v2.0.7 14-OCT-23 Changed 68000 state machine to be driven by 50MHz clock. --JN
--                     Removed State 0 from 68000 state machine. -JN
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
	nLDS : INOUT STD_LOGIC; --68000 _LDS
	nUDS : INOUT STD_LOGIC; --68000 _UDS
	nCLK7 : OUT STD_LOGIC --INVERTED 7MHZ OUT FOR 74HCT646 DATA LATCH
	
);

end U600;

architecture Behavioral of U600 is

	--DEFINE THE 68000 STATE MACHINE STATES
	TYPE STATE68K IS ( S1, S2, S3, S4, S5, S6, S7 );
	SIGNAL CURRENT_STATE : STATE68K;	
	
	--68000 STATE MACHINE SIGNALS	
	SIGNAL sm_enabled : STD_LOGIC; --ARE WE ACCESSING THE AMIGA 2000 BOARD?
	SIGNAL eclk_counter : INTEGER RANGE 0 TO 15; --4 BIT NUMBER E COUNTER
	SIGNAL vmacount : INTEGER RANGE 0 TO 15; --COUNTER FOR E VMA
	SIGNAL eclk : STD_LOGIC; --E SIGNAL FOR "A2000"
	SIGNAL esync : STD_LOGIC; --ONE CLOCK DELAY OF E
	SIGNAL dsacken : STD_LOGIC; --ENABLE _DSACK1
	SIGNAL dsackcount : INTEGER RANGE 0 TO 2; --STATE MACHINE DSACK1 PROCESS
	SIGNAL dsackcycle : STD_LOGIC; --ENABLE THE 68030 _DSACK1 SIGNAL
	SIGNAL vmacycle :STD_LOGIC; --ENABLE THE AMIGA _VMA SIGNAL
	SIGNAL edsack : STD_LOGIC;
	SIGNAL abg_delay : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL abg_disable : STD_LOGIC;
	SIGNAL CLK7_EDGE : STD_LOGIC_VECTOR(1 DOWNTO 0);
	

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
	
	nVMA <= 
		'0' WHEN vmacycle = '1' AND TRISTATE = '0'
	ELSE 
		'1' WHEN TRISTATE = '0'
	ELSE
		'Z';
	
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
	
	
	-----------------------------
	-- MC68000 STATE MACHINE --
	-----------------------------
	
	--7MHz CLOCK EDGE DETECT
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			CLK7_EDGE <= "00";
		
		ELSIF FALLING_EDGE (CPUCLK) THEN
		
			CLK7_EDGE <= CLK7_EDGE(0) & CLK7;
			
		END IF;
		
	END PROCESS;
	
	--THE STATE MACHINE
	PROCESS (CPUCLK, sm_enabled, nRESET) BEGIN
	
		IF sm_enabled = '0' OR nRESET = '0' THEN
		
			CURRENT_STATE <= S1;
			nAAS <= 'Z';
			nUDS <= 'Z';
			nLDS <= 'Z';
			ARnW <= 'Z';
			dsacken <= '0';
		
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			CASE CURRENT_STATE IS
			
				--WE CAN IGNORE STATE 0 FOR OUR PURPOSES
				
				WHEN S1 =>
				
					IF CLK7_EDGE = "01" AND nAS = '0' THEN
						nAAS <= '0';
						nUDS <= NOT (NOT A(0) AND RnW);	
						nLDS <= NOT ((SIZ(1) OR NOT SIZ(0) OR A(0)) AND RnW);
						ARnW <= RnW;
						CURRENT_STATE <= S2;
					ELSE
						nAAS <= '1';
						nUDS <= '1';
						nLDS <= '1';
						ARnW <= '1';
					END IF;
					
				WHEN S2 =>				
				
					IF CLK7_EDGE = "10" THEN CURRENT_STATE <= S3; END IF;
				
				WHEN S3 =>
				
					IF CLK7_EDGE = "01" THEN
						nUDS <= NOT (NOT A(0) AND (NOT RnW OR NOT nUDS));
						nLDS <= NOT ((SIZ(1) OR NOT SIZ(0) OR A(0)) AND (NOT RnW OR NOT nLDS));
						CURRENT_STATE <= S4;
					END IF;
					
				WHEN S4 =>
				
					IF CLK7_EDGE = "10" AND (nDTACK = '0' OR nBERR = '0' OR edsack = '1') THEN CURRENT_STATE <= S5; END IF;
				
				WHEN S5 =>
				
					IF CLK7_EDGE = "01" THEN CURRENT_STATE <= S6; END IF;
				
				WHEN S6 =>
				
					IF CLK7_EDGE = "10" THEN
						nAAS <= '1';
						nUDS <= '1';
						nLDS <= '1';
						dsacken <= '1';
						CURRENT_STATE <= S7;
					END IF;
				
				WHEN S7 =>
				
					IF CLK7_EDGE = "01" THEN
						ARnW <= '1';
						dsacken <= '0';
						CURRENT_STATE <= S1;
					END IF;			
			
			END CASE;
		
		END IF;	
	
	END PROCESS;

END Behavioral;
