----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:34:19 05/22/2022 
-- Design Name: 
-- Module Name:    U600 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
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
	nABG : IN STD_LOGIC; --AMIGA BUS GRANT
	REFACKZ3 : IN STD_LOGIC; --ZORRO 3 RAM REFRESH ACK FROM U602
	REFACKZ2 : IN STD_LOGIC; --ZORRO 2 RAM REFRESH ACK FROM U601
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	nVPA : IN STD_LOGIC; --6800 VPA SIGNAL
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	B2000 : IN STD_LOGIC; --IS THIS AN A2000 OR B2000
	nRESET : IN STD_LOGIC; --_RESET SIGNAL
	nHALT : IN STD_LOGIC; --_HALT SIGNAL	
	MODE68K : IN STD_LOGIC; --ARE WE IN 68000 MODE (DISABLED)	
	nDTACK : IN STD_LOGIC; --68000 DATA TRANSFER ACK
	nABGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	MEMACCESS : IN STD_LOGIC; --SIGNALS WHEN WE ARE RESPONDING TO A RAM ADDRESS
	A1 : IN STD_LOGIC; --68030 ADDRESS LINE 1
	nONBOARD : IN STD_LOGIC; --ARE WE USING RESOURCES ON THE 2630?
	
	nEXTERN : INOUT STD_LOGIC; --ARE WE ACCESSING Z3 MEMORY OR FPU?	
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
	
	DRSEL : OUT STD_LOGIC; --DIRECTION SELECTION FOR U701 U702
	nADOEL : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nADOEH : OUT STD_LOGIC; --BUS DIRECTION CONTROL
	nBR : OUT STD_LOGIC
	
);


end U600;

architecture Behavioral of U600 is

	--DEFINE THE 68000 STATE MACHINE STATES
	TYPE STATE68K IS ( S2, S3, S4, S5, S6, S7 );
	SIGNAL CURRENT_STATE : STATE68K;
	
	--THESE ARE THE CLOCK CYCLES DEFINED FOR THE SDRAM REFRESH COUNTER
	SIGNAL REFRESH_COUNTER_DEFAULT : INTEGER := 185;
	CONSTANT REFRESH_COUNTER_33 : INTEGER := 244;
	CONSTANT REFRESH_COUNTER_40 : INTEGER := 296;
	CONSTANT REFRESH_COUNTER_50 : INTEGER := 370;
	
	--68000 STATE MACHINE SIGNALS
	SIGNAL dswait : STD_LOGIC := '0';
	
	--THIS IS THE SDRAM REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 511 := 0; --9 BIT NUMBER

	SIGNAL eclk_counter : INTEGER RANGE 0 TO 15 := 0; --4 BIT NUMBER E COUNTER
	SIGNAL esync : STD_LOGIC; --TRACKS E SIGNAL FALLING EDGE
	SIGNAL vmacount : INTEGER RANGE 0 TO 15 := 0; --COUNTER FOR E VMA
	SIGNAL vmacountreset : STD_LOGIC; --RESET THE VMA COUNTER
	SIGNAL preve : STD_LOGIC; --PART OF THE VMA COUNTER RESET
	SIGNAL eclk : STD_LOGIC; --E SIGNAL FOR "A2000"
	SIGNAL edsack : STD_LOGIC; --DSACK FOR 6800 PERIPHERALS
	

begin

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
		REFRESH_COUNTER_33 WHEN SDSPEED (1 DOWNTO 0) = "10";
		
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
	
	PROCESS (A7M) BEGIN
		IF (RISING_EDGE (A7M)) THEN
			IF ( nRESET = '0' OR nBOSS = '0' OR MODE68K = '1' ) THEN		
				--We do not need to request the bus at this time.
				--We are BOSS, or we have RESET, or we are in 68000 mode.
				--Tristate so we don't interfere with other bus requesters on the Amiga 2000.
				nABR <= 'Z';
			ELSE
				IF nABR = '0' THEN	
					--nABR is asserted, but are we BOSS yet?
					IF (nRESET = '1' AND nBOSS = '1' AND MODE68K = '0') THEN
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
	
	--BOSS		= ABG & !AAS & !DTACK & !HALT & !RESET & B2000 & !MODE68K 
	--	#  !HALT & !MODE68K & BOSS
	--	# !RESET & !MODE68K & BOSS
	--	# !B2000 & !HALT & !RESET;
	PROCESS (A7M) BEGIN
		IF (RISING_EDGE (A7M)) THEN
			IF (nBOSS = '0') THEN
				--Negate BOSS because we have RESET, HALTed, OR CHANGED TO 68000 MODE.
				IF (MODE68K = '1' OR nHALT = '0' OR nRESET = '0') THEN					
					nBOSS <= 'Z';
				END IF;
			ELSE
				--ACCORDING TO THE 68000 MANUAL, WE SHOULD NOT ASSERT _BGACK (_BOSS) UNTIL _AS AND _DTACK ARE NEGATED.
				IF 
					(( B2000 = '1' AND nABG = '0' AND nAAS ='1' AND nDTACK = '1' AND nHALT = '1' AND nRESET = '1' AND MODE68K = '0' ) OR 
					( B2000 = '0' AND nHALT ='1' AND nRESET ='1')) 
				THEN
					nBOSS <= '0';
				ELSE
					nBOSS <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	---------------------------
	-- E AND RELATED SIGNALS --
	---------------------------
	
	--WHEN IN "A2000" MODE, WE MUST GENERATE OUR OWN E BECAUSE THE 68000 
	--PROCESSOR IS REMOVED FROM THE MOTHERBOARD. WHEN IN "B2000" MODE, WE CAN
	--USE THE EXISTING E SIGNAL BUT WE MUST REPLY TO _VPA SIGNALS EITHER WAY.
	
	E <= 'Z' WHEN B2000 = '1' ELSE eclk;
	
	--E IS A SIGNAL FOR 6800 BASED PERIPHERLS. THE CIA'S USE THE E SIGNAL.
	--IT IS 6 CLOCK CYCLES LOW AND 4 HIGH AND IS INDEPENDENT (ASYNCHRONOUS) OF THE PROCESSOR CLOCK.
	--THAT MEANS WE CAN MAKE OUR OWN WITH A SIMPLE COUNTER AND DRIVE IT FROM THE AMIGA 7MHz CLOCK.
	--TRIVIA: E MEANS "ENABLE"
	--SIMULATED OK

	PROCESS (A7M) BEGIN
		IF FALLING_EDGE (A7M) AND B2000 = '0' THEN
			
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
	
	--VMA (VALID MEMORY ADDRESS) IS A 6800 SIGNAL DRIVEN IN RESPONSE TO VPA (VALID PERIPHERAL ADDRESS).
	--VMA IS TO BE ASSERTED WHEN THE PROCESSOR IS SYNCED TO THE E CLOCK.
	--THIS IS IN APPENDIX B OF THE 68000 MANUAL.	
	--WE USE THIS COUNTER SO WE KNOW WHEN TO ASSERT _VMA. THE COUNTER RESTARTS AT EVERY E FALLING EDGE
	--AND IS ONE CLOCK BEHIND E.
	--SIMULATED OK
	
	PROCESS (A7M) BEGIN	
		
		IF E = '0' and preve = '1' AND vmacountreset = '0' THEN
			vmacountreset <= '1';
		ELSE
			vmacountreset <= '0';
			preve <= E;
		END IF;

		IF FALLING_EDGE (A7M) THEN
			IF vmacountreset = '1' THEN
				vmacount <= 0;				
			ELSE
				vmacount <= vmacount + 1;
			END IF;
		END IF;
		
	END PROCESS;
	
	--HERE WE LOOK FOR _VPA ASSERTION AND ASSERT _VMA AT THE RIGHT TIME.
	--WE SHOULD ONLY ASSERT _VPA WHEN E IS LOGIC LOW AND SOMEWHERE BETWEEN
	--3 AND 4 CLOCK CYCLES AFTER E GOES TO LOGIC LOW. _VMA IS NEGATED
	--WHEN _AS IS NEGATED. OUR VMACOUNT IS RESET ONE CLOCK AFTER E GOES LOW.
	
	--DSACK IS ASSERTED 2 CLOCKS BEFORE E FALLS (VMACOUNT=7).
	
	--NOTE: the 68030 doesn't natively support 6800 peripherals, so DSACK
	--to signify the end of a cycle.
	
	PROCESS (A7M) BEGIN
	
		IF FALLING_EDGE (A7M) THEN
		
			IF (nVPA = '0') THEN
				IF (vmacount = 1 OR vmacount = 2 OR nVMA = '0') AND nAS = '0' THEN
					nVMA <= '0';					
				ELSE
					nVMA <= '1';					
				END IF;
				
				IF vmacount = 7 AND nVMA = '0' AND nAS = '0' THEN
					edsack <= '0';
				ELSE
					edsack <= '1';
				END IF;
				
			ELSE
				nVMA <= '1';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	--THIS IS FOR 16 BIT ASYNC CYCLES THAT WE ARE DOING.
	
	PROCESS (CPUCLK) BEGIN
		IF RISING_EDGE (CPUCLK) THEN
			
			IF 
				edsack = '0' OR --THE END OF AN E CYCLE
				--nDTACK = '0' OR --THE END OF A MEMORY CYCLE FROM THE Z2 BUS TO US (MAY BE HANDLED SOMEWHERE ELSE)
				(nDSACK1 = '0' AND nAS = '0') --HOLD UNTIL _AS IS NEGATED
			THEN
				nDSACK1 <= '0';
			ELSE
				nDSACK1 <= 'Z';
			END IF;
		
		END IF;
	END PROCESS;
		
					
	---------------------------------------
	-- AMIGA 68030 <-> 68000 BUS CONTROL --
	---------------------------------------
	
	--This handles the data buffer enable, including the 16 to 32 bit data
	--bus conversion required for DMA cycles.

	--ADOEH		= BOSS &  BGACK &  MEMSEL & AAS & !A1		# BOSS & !BGACK & !MEMSEL &  AS & !ONBOARD & !EXTERN;
	--ADOEH CONTROLS D31..17. SEE DRSEL SIGNAL (BELOW). U701, U702
	nADOEH <= '0' 
		WHEN 
			( nBOSS = '0' AND nBGACK = '0' AND MEMACCESS = '1' AND nAAS = '0' AND A1 = '0' ) OR 
			( nBOSS = '0' AND nBGACK = '1' AND MEMACCESS = '0' AND nAS = '0' AND nONBOARD = '1' AND nEXTERN = '1' ) 
		ELSE
			'1';

	--ADOEL		= BOSS &  BGACK &  MEMSEL & AAS &  A1;
	--ADOEL CONTROLS D16..0. U703, U704
	nADOEL <= '0' 
		WHEN nBOSS = '0' AND nBGACK = '0' AND MEMACCESS = '1' AND nAAS = '0' AND A1 = '1'  ELSE '1';
	
	--This selects when we want data latching, which we in fact want only on
	--read cycles.
	
	--THIS CONTROLS DIRECTION OF D31..17, WHICH THE 68030 USES TO COMMUNICATE "DOWN" TO 16 BITS. U701, U702

	--DRSEL		= BOSS & !BGACK & RW;
	DRSEL <= '1' WHEN nBOSS = '0' AND nBGACK = '1' AND RnW = '1' ELSE '0';
	
	--TRISTATE is an output used to tristate all signals that go to the 68000
	--bus. This is done on powerup before BOSS is asserted and whenever a DMA
	--device has control of the A2000 Bus.  We want tristate when we're not 
	--BOSS, or when we are BOSS but we're being DMAed. U305

	--TRISTATE	= !BOSS # (BOSS & BGACK);
	TRISTATE <= '1' WHEN nBOSS = '1' OR ( nBOSS = '0' AND nBGACK = '0' ) ELSE '0';
	
	---------------------------
	-- 68030<->68000 SIGNALS --
	---------------------------
	
	--WHEN DMA, THE RW SIGNAL FROM THE AMIGA IS LINKED TO THE RW ON OUR CARD
	--AMIGA TO 68030
	RnW <= ARnW WHEN nBGACK = '0' ELSE 'Z';

	--DURING NON-DMA OPERATION, WE LINK THE 68030 RW SIGNAL TO THE 68000 RW SIGNAL ON THE AMIGA
	--IT TRISTATES WHEN WE ARE NOT BOSS OR THE ACTION IS STRICTLY ON OUR CARD.
	--68030 TO AMIGA
	ARnW <= 'Z' 
		WHEN 
			TRISTATE = '1' OR offboard = '0'
		ELSE
			RnW;
	
	--LOCK THE AMIGA _BGACK TO OUR 68030 nBGACK WHEN WE ARE BOSS.
	nBGACK <= nABGACK WHEN nBOSS = '0' ELSE 'Z';
	
	--WHEN WE ARE BOSS, WE PASS THE AMIGA BUS REQUEST TO THE 68030.
	nBR <= nABR WHEN nBOSS = '0' AND nBGACK = '1' ELSE 'Z';
	
	-------------------------
	-- 68000 STATE MACHINE --
	-------------------------
	
	--WE MUST SUPPLY THE _AS, _LDS, _UDS SIGNALS. THIS STATE MACHINE ENDEVORS TO SUPPLY THE
	--VARIOUS 68000 COMPATABLE SIGNALS AT THE CORRECT TIME.
	
	--DATA STROBES ASSERT W/READ IN READ CYCLES
	--DATA STROBES ASSERT 1 CLOCK LATER IN WRITE CYCLES
	
	--DO NOT START AN AMIGA CYCLE ON SPECIAL ACCESS (FPU, Z3 MEMORY)
	
	--SEE TABLE 7-7 (pp7-23) IN 68030 MANUAL
	--nUDS IS ASSERTED ANYWHERE WE SEE W (WORD) IN COLUMN D31:24 (UPPER BYTE)
	--nLDS IS ASSERTED ANYWHERE WE SEE W (WORD) IN COLUMN D23:16 (LOWER BYTE)
	
	nUDS <= nUDSOUT;
	nLDS <= nLDSOUT;
	
	--LINK THE 68000 ADDRESS STROBE TO THE 68030 WHEN WE ARE NOT IN DMA
	nAAS <= nAS WHEN nBGACK = '1' ELSE 'Z';
	
	PROCESS (A7M, nRESET) BEGIN
	
		IF (nRESET = '0') THEN
			CURRENT_STATE <= "S2";
			nUDSOUT <= 'Z';
			nLDSOUT <= 'Z';
	
		ELSIF RISING_EDGE (A7M) THEN
		
			IF TRISTATE = '1' OR offboard = '0' THEN
				nUDSOUT <= 'Z';
				nLDSOUT <= 'Z';
			ELSE
		
				CASE (CURRENT_STATE) IS
				
					WHEN "S2" =>
						IF nAS = '0' AND nEXTERN = '1' THEN 							
							CURRENT_STATE <= "S3";
						END IF;
						
						IF RnW = '1' THEN 
							--READ CYCLE, WE CAN ASSERT UDS/LDS IMMEDIATELY
							--AND WE ALWAYS ASSERT BOTH.
							nUDSOUT <= '0';
							nLDSOUT <= '0';
						END IF;
						
					WHEN "S3" =>
						--NOTHING HERE, GO TO NEXT STATE
						CURRENT_STATE <= "S4";
						
					WHEN "S4" =>
						--IF A READ CYCLE, ASSERT DTACK AND DSACK1.
						--IF A WRITE CYCLE, ASSERT THE DATA STROBES HERE.
						IF RnW = '1' THEN
							nDTACK <= '0';
							nDSACK1 <= '0';
						ELSE
							nUDS <= '0' WHEN A(0) = '0' ELSE '1';
							nLDS <= '0' WHEN SIZ(1) = '1' OR SIZ(0) = '0' OR A(0) = '1' ELSE '1';
						END IF;
						
						CURRENT_STATE <= "S5";
						
					WHEN "S5" =>
						--NOTHING HERE, GO TO NEXT STATE
						CURRENT_STATE <= "S6";
						
					WHEN "S6" =>
						--WHEN READ: DATA IS WRITTEN TO THE BUS BY THE DEVICE
						CURRENT_STATE <= "S7";
						
					WHEN "S7" =>
						--ASSUMING NO WAIT STATES, THE 68030 SHOULD NEGATE _AS AT THIS TIME
						--WE WILL HI Z THE DATA STROBES
						
						IF (nAS = '1') THEN		
							nUDSOUT <= '1';
							nLDSOUT <= '1';
							
							CURRENT_STATE <= "S2";
						END IF;
					
				END CASE;				
			END IF;
		END IF;
	END PROCESS;

			
	--OFFBOARD MEANING WE ARE NOT USING ANY RESOURCES ON OUR CARD, WE ARE GOING AFTER SOMETHING ON THE AMIGA 2000
	--offboard	= !(ONBOARD # MEMSEL # EXTERN); U501
	offboard <= '1' 
		WHEN 
			(nONBOARD = '1' AND MEMACCESS = '0' AND nEXTERN = '1')
		ELSE 
			'0';
			
	

end Behavioral;

