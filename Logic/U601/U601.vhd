----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       JASON NEUS
-- 
-- Create Date:    09:42:54 02/13/2022 
-- Design Name:    N2630 U601 CPLD
-- Module Name:    U601 - Behavioral 
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: MUCH OF THIS LOGIC AND COMMENTS ARE TRANSLATED FROM THE PAL LOGIC FROM DAVE HAYNIE.
--                      EDITS AND ADDITIONS FOR THE N2630 PROJECT MADE BY JASON NEUS.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity U601 is
    Port ( 
	 
		FC : IN STD_LOGIC_VECTOR (2 downto 0); --FCn FROM 68030
		A : IN STD_LOGIC_VECTOR (23 downto 0); --68030 Address Bus
		SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
		CPUCLK : IN STD_LOGIC; --68030 CLOCK
		nAS : IN STD_LOGIC; --680x0 ADDRESS STROBE
		nDS : IN STD_LOGIC; --680x0 DATA STROBE
		RnW : IN STD_LOGIC; --680x0 READ/WRITE
		nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
		nSENSE : IN STD_LOGIC; --6888x PRESENCE
		OSMODE : IN STD_LOGIC; --HIGH FOR AMIGA OS, LOW FOR UNIX
		PHANTOMHI : IN STD_LOGIC; --PHANTOM HI DATA
		PHANTOMLO : IN STD_LOGIC; --PHANTOM LO DATA
		nCPURESET : IN STD_LOGIC; --RESET FOR THE 68030		
		Z2AUTO : IN STD_LOGIC; --SHOULD I AUTOCONFIG ZORRO 2 RAM?
		nEXTERN : IN STD_LOGIC; --EXTERNAL ACCESS (DAUGHTER OR FPU)
		nCYCEND : IN STD_LOGIC; --CYCLE END
		nDSEN : IN STD_LOGIC; --DATA STROBE ENABLE
		nASEN: IN STD_LOGIC; --ADDRESS STROBE ENABLE
		TRISTATE : IN STD_LOGIC; --TRISTATE WHEN WE DON'T HAVE THE BUS		
		EXTSEL : IN STD_LOGIC; --EXPANSION RAM IS RESPONDING TO THE ADDRESS
		nRESET : IN STD_LOGIC; --A2000 SYSTEM RESET
		nAAS : IN STD_LOGIC; --AMIGA 2000 ADDRESS STROBE FOR DMA
	 
		D : INOUT STD_LOGIC_VECTOR (31 downto 28) := "ZZZZ"; --DATA BUS FOR THE AUTOCONFIG PROCESS
		--CONFIGED : INOUT STD_LOGIC; --HAS AUTOCONFIG COMPLETED?		
		ROMCLK : INOUT STD_LOGIC; --CLOCK FOR U303
		nONBOARD : INOUT STD_LOGIC; --ARE WE USING RESOURCES ON THE 2630?
		MEMACCESS : INOUT STD_LOGIC; --LOGIC HIGH WHEN WE ARE ACCESSING Z2 RAM	
		nUDS : INOUT STD_LOGIC; --68000 UPPER DATA STROBE
		nLDS : INOUT STD_LOGIC; --68000 LOWER DATA STROBE
	 
	 	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
		nBERR : OUT STD_LOGIC; --BUS ERROR
		nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
		nAVEC : OUT STD_LOGIC; --AUTO VECTORING
		nCSROM : OUT STD_LOGIC; --ROM CHIP SELECT	
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
		nMEMLOCK : OUT STD_LOGIC; --LOCK MEMORY DURING ACCESS FOR STATE MACHINE
		EMDDIR : OUT STD_LOGIC; --DIRECTION OF MEMORY DATA BUS FOR LEVEL SHIFTERS
		nDSACK0 : OUT STD_LOGIC;
		nDSACK1 : OUT STD_LOGIC;
		nDTACK : OUT STD_LOGIC; --68000 DTACK FOR DMA
		ZBANK0 : OUT STD_LOGIC; --ZORRO 2 SDRAM BANK0 SIGNAL
		ZBANK1 : OUT STD_LOGIC; --ZORRO 2 SDRAM BANK1 SIGNAL
		nOVR : OUT STD_LOGIC; --DTACK OVERRIDE TO GARY
		ADDIR : OUT STD_LOGIC --ADDRESS BUS DIRECTION CONTROL
		
		);
		
end U601;

architecture Behavioral of U601 is

	--DEFINE THE SDRAM STATE MACHINE STATES
	TYPE SDRAM_STATE IS ( POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, CAS_STATE, DATA_STATE );
	
	SIGNAL CURRENT_STATE : SDRAM_STATE;
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC := '0'; --WE NEED TO REFRESH TWICE UPON STARTUP	
	SIGNAL dmaaccess : STD_LOGIC := '0'; --IS A DMA CYCLE GOING ON?
	SIGNAL cpuaccess : STD_LOGIC := '0'; --IS THE CPU ACCESSING THE MEMORY?
	SIGNAL dsack : STD_LOGIC := 'Z'; --Feeds nDSACKx
	
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 255 := 0;
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	
	CONSTANT REFRESH_COUNTER_DEFAULT : INTEGER := 185;
	--AT 25MHZ, WE NEED TO REFRESH EVERY 195 CLOCK CYCLES
	--THIS CAUSES US TO REFRESH 8192 TIMES EVERY 64 MILLISECONDS
	--WE GO A LITTLE LESS THAN 195 IN CASE REFRESH HITS IN THE MIDDLE OF A RAM ACTION
	--THAT GIVES US SOME WIGGLE ROOM

	----------------------
	-- INTERNAL SIGNALS --
	----------------------
	
	SIGNAL baseaddress_ZORRO2RAM : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR ZORRO 2 RAM
	SIGNAL autoconfigspace : STD_LOGIC:='0'; --ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	SIGNAL chipram : STD_LOGIC:='0';
	SIGNAL ciaspace : STD_LOGIC:='0';
	SIGNAL chipregs : STD_LOGIC:='0';
	SIGNAL iospace	 : STD_LOGIC:='0';
	SIGNAL userdata : STD_LOGIC:='0';
	SIGNAL superdata : STD_LOGIC:='0';
	SIGNAL interruptack : STD_LOGIC:='0';
	SIGNAL cpuspace : STD_LOGIC:='0';
	SIGNAL coppercom : STD_LOGIC:='0';
	SIGNAL mc68881 : STD_LOGIC:='0';
	
	SIGNAL D_2630 : STD_LOGIC_VECTOR ( 2 downto 0 ) := "ZZZ";
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ";
	SIGNAL autoconfigcomplete_2630 : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	SIGNAL autoconfigcomplete_ZORRO2RAM : STD_LOGIC := '0'; --HAS ZORRO2 RAM BEEN AUTOCONFIGed?
	SIGNAL configed : STD_LOGIC; --HAS AUTOCONFIG COMPLETED?		
	
	SIGNAL icsrom : STD_LOGIC:='0';
	SIGNAL hirom : STD_LOGIC:='0';
	SIGNAL lorom : STD_LOGIC:='0';
	SIGNAL readcycle : STD_LOGIC:='0';
	SIGNAL writecycle : STD_LOGIC:='0';
	SIGNAL romaddr : STD_LOGIC := '0';
	SIGNAL csauto : STD_LOGIC := '0';
	SIGNAL icsauto : STD_LOGIC:='0';
	SIGNAL rds : STD_LOGIC:='0';
	SIGNAL wds : STD_LOGIC:='0';
	SIGNAL offboard : STD_LOGIC:='0';	

begin

	----------------------------
	-- INTERNAL SIGNAL DEFINE --
	----------------------------

	--ADDRESS DECODING

	--field cpuaddr	= [A23..13] ;			/* Normal CPU space stuff */
	chipram <= '1' WHEN A(23 downto 13) >= "00000000000" AND A(23 downto 13) <= "00011111111"  ELSE '0';
	--chipram		= (cpuaddr:[000000..1fffff]) ;    /* All Chip RAM */ 0-000111111111111111111111
	--busspace	= (cpuaddr:[200000..9fffff]) ;    /* Main expansion bus */ 001000000000000000000000-100111111111111111111111
	ciaspace <= '1' WHEN A(23 downto 13) >= "10100000000" AND A(23 downto 13) <= "10111111111" ELSE '0';
	--ciaspace	= (cpuaddr:[a00000..bfffff]) ;    /* VPA decode */ 101000000000000000000000-101111111111111111111111
	--extraram	= (cpuaddr:[c00000..cfffff]) ;    /* Motherboard RAM */ 110000000000000000000000-110011111111111111111111
	chipregs <= '1' WHEN A(23 downto 13) >= "11010000000" AND A(23 downto 13) <= "11011111111" ELSE '0';
	--chipregs	= (cpuaddr:[d00000..dfffff]) ;    /* Custom chip registers */ 110100000000000000000000-110111111111111111111111
	iospace <= '1' WHEN A(23 downto 13) >= "11101000000" AND A(23 downto 13) <= "11101111111" ELSE '0';
	--iospace		= (cpuaddr:[e80000..efffff]) ;    /* I/O expansion bus */ 111010000000000000000000-111011111111111111111111
	--romspace	= (cpuaddr:[f80000..ffffff]) ;    /* All ROM */ 111110000000000000000000-111111111111111111111111

	cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0'; --(cpustate:7)	

	--ramaddr		= addr:48;
	--ramaddr <= '1' WHEN A(6 downto 1) = "100100" ELSE '0'; --01001000	

	----------------
	-- AUTOCONFIG --
	----------------

	--We have three boards we need to autoconfig, in this order
	--1. The 68030 board itself
	--2. The base memory (8MB) without BOOT ROM in the Zorro 2 space
	--3. The expansion memory (112MB) in the Zorro 3 space. This is done in U602.	

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition	
	
	--ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	
	autoconfigspace <= '1'
		WHEN 
			A(23 downto 16) = "11101000" AND nAS = '0'
		ELSE
			'0';	

	--THIS CODE DUMPS THE AUTOCONFIG DATA ON TO D(31..28) DEPENDING ON WHAT WE ARE AUTOCONFIGing	
	--We AUTOCONFIG the 2630 FIRST, then the Zorro 2 RAM
	D(31 downto 28) <= 
			D_2630(0) & D_2630(1) & "1" & D_2630(2) 
				WHEN autoconfigcomplete_2630 = '0' AND autoconfigspace = '1'
		ELSE
			D_ZORRO2RAM 
				WHEN autoconfigcomplete_ZORRO2RAM = '0' AND autoconfigspace ='1'
		ELSE
			"ZZZZ";		
			
	--Here it is in all its glory...the AUTOCONFIG sequence
	PROCESS ( CPUCLK, nRESET ) BEGIN
		IF nRESET = '0' THEN
			--The computer has been reset
			
			configed <= '0';
			
			baseaddress_ZORRO2RAM <= "000";
			
			autoconfigcomplete_2630 <= '0';
			autoconfigcomplete_ZORRO2RAM <= '0';			
			
		ELSIF ( FALLING_EDGE (CPUCLK)) THEN
			IF ( autoconfigspace = '1' AND configed = '0' ) THEN
				IF ( RnW = '1' ) THEN
					--The 680x0 is reading from us
				
					CASE A(6 downto 1) IS

						--offset $00
						WHEN "000000" => 
							D_2630 <= "110"; 
							D_ZORRO2RAM <= "1110"; --er_type: Zorro 2 card without BOOT ROM, LINK TO MEM POOL

						--offset $02
						WHEN "000001" => 
							D_2630 <= "011";
							D_ZORRO2RAM <= "0000"; --er_type: NEXT BOARD NOT RELATED, 2MB

						--offset $04 INVERTED
						WHEN "000010" => 
							D_2630 <= "100";
							D_ZORRO2RAM <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number

						--offset $06 INVERTED
						WHEN "000011" => 
							D_2630 <= "110";
							D_ZORRO2RAM <= "1110"; --Product Number Lo Nibble

						--offset $08 INVERTED
						WHEN "000100" => 
							D_2630 <= "111"; --CAN'T BE SHUT UP
							D_ZORRO2RAM <= "1011"; --er_flags: I/O device, can't be shut up, reserved, reserved

						--offset $0C INVERTED						
						WHEN "000110" => 
							D_2630 <= OSMODE & "11"; --THE A2630 CONFIGURES THIS NIBBLE AS "0111" WHEN UNIX, "1111" WHEN AMIGA OS
							D_ZORRO2RAM <= "1111"; --Reserved: must be zeroes

						--offset $12 INVERTED
						WHEN "001001" => 
							D_2630 <= "111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, high byte, low nibble hi byte. Just for fun, lets put C= in here!

						--offset $16 INVERTED
						WHEN "001011" => 
							D_2630 <= "111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, low nibble low byte. Just for fun, lets put C= in here!

						WHEN OTHERS => 
							D_2630 <= "111";
							D_ZORRO2RAM <= "1111"; --INVERTED...Reserved offsets and unused offset values are all zeroes

					END CASE;
					
				--Is this one our base address? If yes, we are done with AUTOCONFIG
				ELSIF ( RnW = '0' AND nDS = '0' ) THEN	
				
					IF ( A(6 downto 1) = "100100" ) THEN
					
						IF ( autoconfigcomplete_2630 = '0' ) THEN
						
							--BASE ADDRESS FOR THE 68030 BOARD
							--We don't acutally need this for anything, 
							--but it is confirmation that the 2630 ROM has been configed
							autoconfigcomplete_2630 <= '1'; 
							
						ELSIF ( autoconfigcomplete_ZORRO2RAM = '0' ) THEN
						
							--BASE ADDRESS FOR THE ZORRO 2 RAM
							baseaddress_ZORRO2RAM <= D(31 downto 29); 
							--THE ZORRO 2 RAM IS CONFIGED
							autoconfigcomplete_ZORRO2RAM <= '1'; 
							
						END IF;
						
						IF ((Z2AUTO = '0') OR autoconfigcomplete_ZORRO2RAM = '1') THEN
							--We always autoconfig the 2630 ROM.
							--Z2AUTO is driven by a jumper on the board, if it is logic 0, the user does not want to use the 
							--on board Z2 RAM. Thus, we will stop after the 2630 is autoconfiged.
							configed <= '1'; 
						END IF;					
						
					END IF;					
				END IF;
			END IF;
		END IF;
	END PROCESS;
			
	---------------
	-- RAM STUFF --
	---------------

	--EITHER THE 68030 OR DMA FROM THE ZORRO 2 BUS CAN ACCESS ZORRO 2 RAM ON OUR CARD
	
	--THE CPU IS ADDRESSING THE ZORRO 2 MEMORY SPACE. U305
	--THIS DETECTS MEMORY ACCESS BY THE 68030
	cpuaccess <= '1' 
		WHEN
			autoconfigcomplete_ZORRO2RAM = '1' AND A(23 downto 21) = baseaddress_ZORRO2RAM AND nAS = '0' AND cpuspace = '0'
		ELSE
			'0';
	
	--THIS DETECTS MEMORY ACCESS BY DMA
	--DMA ACCESS IS VERY SIMILAR TO 68030 ACCESS, BUT THE SIGNALS ARE 68000 BASED
	dmaaccess <= '1'
		WHEN
			autoconfigcomplete_ZORRO2RAM = '1' AND A(23 downto 21) = baseaddress_ZORRO2RAM AND nAAS = '0' AND nBGACK = '0'
		ELSE
			'0';
			
	MEMACCESS <= '1' 
		WHEN
			cpuaccess = '1' OR dmaaccess = '1'
		ELSE
			'0';
			
	--The OVR signal must be asserted whenever on-board memory is selected
	--during a DMA cycle.  It tri-states GARY's DTACK output, allowing
	--one to be created by our memory logic. u501

	--OVR		= BGACK & MEMSEL;
	--OVR.OE		= BGACK & MEMSEL;
	nOVR <= '0' 
		WHEN 
			nBGACK = '0' AND MEMACCESS = '1' 
			--nBGACK = '0' AND nMEMSEL = '0' 
		ELSE 
			'Z';	
			
	--IN OUR LOGIC, nDSACK0 = nDSACK1 WITHOUT EXCEPTION. TRYING TO SIMPLIFY THINGS HERE.
	nDSACK0 <= dsack;
	nDSACK1 <= dsack;
	
	--WE NEED TO BE RESPONSIVE TO BOTH THE CPU AND DMA READ/WRITE REQUESTS
	--WE NEED TO HOLD OFF THE CPU WHEN A DMA CYCLE IS IN PROGRESS AND VICE VERSA
	--nBGACK DOES THIS NICELY. WHEN ASSERTED, THE 68030 RELEASES THE BUS, AND THUS WILL NOT TRY TO TALK TO RAM (AT LEAST IN THEORY). 
	--EXTERNAL DEVICES ARE NOT TO ASSERT nBGACK UNTIL THE 680x0 NEGATES nAS AND nDSACK (nDTACK). pp7-100.
	
	-------------------------------------
	-- SDRAM FALLING CLOCK EDGE ACTIONS --
	-------------------------------------
	
	PROCESS ( CPUCLK ) BEGIN
		
		IF ( FALLING_EDGE (CPUCLK) ) THEN

			IF (MEMACCESS = '1') THEN		

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
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0'  AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(1) = '1'  AND nDS = '0') OR
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
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0'  AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1'  AND nDS = '0') OR
					(nBGACK = '1' AND A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0'  AND nDS = '0') OR
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
	
	-------------------------------------
	-- SDRAM RISING CLOCK EDGE ACTIONS --
	-------------------------------------
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF (nRESET = '0') THEN 
				--THE AMIGA HAS BEEN RESET
				CURRENT_STATE <= POWERUP;
				nZCAS <= '1';
				nZRAS <= '1';
				nZWE <= '1';
				nZCS <= '1';
				CLKE <= '0';
				COUNT <= 0;
				SDRAM_START_REFRESH_COUNT <= '0';
				dsack <= 'Z';
				nDTACK <= 'Z';
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN
			
			--We must use DSACKn for Zorro 2 RAM because this enables dynamic bus sizing, which is needed for Z2 devices.
			--BECAUSE OF THIS, WE CANNOT USE BURST MODE IN Z2 RAM, WHICH ONLY WORKS WITH STERM TERMINATED ACTIONS.
			
			--SDRAM is pretty fast. Most operations will complete in less than one 25MHz clock cycle. Only AUTOREFRESH and 
			--successive BANK ACTIVE commands take more than one clock cycle. Both are 60ns.
			
			--REFRESH
			IF (REFRESH_COUNTER >= REFRESH_COUNTER_DEFAULT AND CURRENT_STATE /= DATA_STATE) THEN
				--TIME TO REFRESH THE SDRAM, BUT ONLY IF WE ARE NOT IN THE MIDDLE OF A MEMORY ACCESS CYCLE
				IF (MEMACCESS = '0') THEN
					--IF THIS IS NOT A MEMORY CYCLE, PROCEED DIRECTLY TO REFRESH
					CURRENT_STATE <= AUTO_REFRESH;
				END IF;
			ELSE
				--INCREMENT THE REFRESH COUNTER
				REFRESH_COUNTER <= REFRESH_COUNTER + 1;
			END IF;
		
			--PROCEED WITH SDRAM STATE MACHINE
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF MEMACCESS = 1
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED, WE ARE IN THE ZORRO 2 ADDRESS SPACE, AND THE RAM IS AUTOCONFIGured
			CASE CURRENT_STATE IS
			
				WHEN POWERUP =>
					--First power up or warm reset
					--200 microsecond is needed to stabilize. We are going to rely on the 
					--the system reset to give us the needed time, although it might be inadequate.
					CLKE <= '0'; --DISABLE CLOCK
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '0'; --NOP STATE
					CURRENT_STATE <= POWERUP_PRECHARGE;
					
				WHEN POWERUP_PRECHARGE =>
					--nZPRECHARGE <= '1'; --ALL BANKS TO BE PRECHARGED
					ZMA <= (OTHERS => '0');
					ZMA(10) <= '1'; --PRECHARGE ALL				
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '1';
					nZCS <= '0';
					CLKE <= '1';
					CURRENT_STATE <= MODE_REGISTER;
				
				WHEN MODE_REGISTER =>
					--TWO CLOCK CYCLES ARE NEEDED FOR THE REGISTER TO, WELL, REGISTER
					ZMA <= "01000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2,
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '0';
					nZCS <= '0';	
					
					IF (COUNT = 1) THEN
						--NOW NEED TO REFRESH TWICE
						CURRENT_STATE <= AUTO_REFRESH;
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh time is 60ns. Each 25MHz clock period is 40ns.
					--If we wait two clock cycles, this will allow time for refresh.
					
					nZWE <= '1';
					nZRAS <= '0';
					nZCAS <= '0';
					nZCS <= '0';
					
					COUNT <= 0;
					
					CURRENT_STATE <= AUTO_REFRESH_CYCLE;				
					
				WHEN AUTO_REFRESH_CYCLE =>
					--NOPs WHILE THE SDRAM IS REFRESHING
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '0';
					
					--IF (COUNT = 1) THEN --TWO CLOCK CYCLES HAVE PASSED. WE CAN PROCEED.
						--DO WE NEED TO REFRESH AGAIN (STARTUP)?
						IF (SDRAM_START_REFRESH_COUNT = '0') THEN							
							CURRENT_STATE <= AUTO_REFRESH;
							SDRAM_START_REFRESH_COUNT <= '1';
						ELSE
							CURRENT_STATE <= RUN_STATE;
							REFRESH_COUNTER <= 0;
						END IF;
					--END IF;		

					--COUNT <= COUNT + 1;						
				
				WHEN RUN_STATE =>
					--CLOCK EDGE 0
					
					IF (MEMACCESS = '1') THEN 
						--WE ARE IN THE Z2 MEMORY SPACE WITH THE ADDRESS STROBE ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND W/RAS
						
						ZMA(10 downto 0) <= A(12 downto 2);
						ZBANK0 <= A(13);
						ZBANK1 <= A(14);
						
						nZCS <= '0';
						nZRAS <= '0';	
						nZCAS <= '1';							
						nZWE <= '1';
						
						IF (nBGACK = '0') THEN
							nDTACK <= '1'; --DMA ACCESS, NEGATE BECAUSE _WE_ ARE TALKING TO THE ZORRO 2 BUS NOW							
						ELSE
							dsack <= '1'; --NEGATE DSACK BECAUSE _WE_ ARE TALKING TO THE 68030 BUS RIGHT NOW
						END IF; 
						
						CURRENT_STATE <= CAS_STATE;
						COUNT <= 0;
					END IF;
					
				WHEN CAS_STATE =>
					--CLOCK EDGE 1
					--READ OR WRITE WITH AUTOPRECHARGE
					
					ZMA(7 downto 0) <= A(22 downto 15);
					ZMA(8) <= '0';
					ZMA(9) <= '0';
					ZMA(10) <= '1'; --PRECHARGE
					
					nZCS <= '0';
					nZRAS <= '1';	
					nZCAS <= '0';	
					nZWE <= RnW;

					--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY PROCEED TO THE ACTION
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES, SO WE NEED TO WAIT ONE MORE CLOCK BEFORE READING
					--DURING DMA, THE REQUESTING DEVICE'S RW SIGNAL IS LOCKED TO OUR RW SIGNAL
					
					--DO WE WANT TO CONSIDER DS ON THE READ ACTION?
					IF ((RnW = '0') OR (RnW = '1' AND COUNT >= 1)) THEN
					
						IF (nBGACK = '0') THEN
						
							nDTACK <= '0'; --ASSERT nDTACK SINCE THIS IS A DMA EVENT. DMA DEVICE CAN COMMIT ON THE NEXT FALLING CLOCK EDGE.
							
						ELSE
						
							--68030 CAN COMMIT ON THE NEXT FALLING CLOCK EDGE.
							--ASSERTING BOTH DSACKs TELLS THE 68030 THAT THIS IS A 32 BIT PORT.
							dsack <= '0'; 
							
						END IF;
						
						CURRENT_STATE <= DATA_STATE;
					
					END IF;						
					
					COUNT <= COUNT + 1;
					
				WHEN DATA_STATE =>
					--RISING CLOCK EDGE 2
					--THIS IS THE CLOCK EDGE WE EXPECT THE DATA TO BE WRITTEN TO OR READ FROM THE SDRAM
					--WE NEED TO WAIT 30ns BEFORE ISSUING ANOTHER BANK ACTIVATE COMMAND. NO PROBLEM, SINCE ONE CLOCK CYCLE IS 40ns.
					
					IF (MEMACCESS = '0') THEN --THE ADDRESS STROBE HAS NEGATED INDICATING THE END OF THE MEMORY ACCESS
						
						--TRISTATE SO WE DON'T INTERFERE WITH OTHER DEVICES ON THE BUSES
						dsack <= 'Z';
						nDTACK <= 'Z';
						
						CURRENT_STATE <= RUN_STATE;
						
						--SET NOP
						nZCS <= '1';
						nZRAS <= '1';	
						nZCAS <= '1';							
						nZWE <= '1';
						
					END IF;					
				
			END CASE;
				
		END IF;
	END PROCESS;
	
	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--This sets the direction of the LVC data buffers between the 680x0 and the RAM
	
	EMDDIR <= NOT RnW;
	
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
	
	--EXTSEL = 1 is when Zorro 3 RAM is responding to the address space (EXTSEL)
	--So, this original code never caches in Z3 ram. 
	--Might want to consider looking into that when Z3 ram is present.	
		
	userdata	<= '1' WHEN FC( 2 downto 0 ) = "001" ELSE '0'; --(cpustate:1)
	superdata <= '1' WHEN FC( 2 downto 0 ) = "101" ELSE '0'; --(cpustate:5)
	
	nCIIN <= '1' 
		WHEN
			EXTSEL = '0' AND (
			(chipram = '1' AND ( userdata = '1' OR superdata = '1' )) OR
			--!CACHE = chipram & (userdata # superdata) & !EXTSEL
			(ciaspace = '1') OR
			--ciaspace & !EXTSEL
			(chipregs = '1') OR
			--chipregs & !EXTSEL
			(iospace = '1'))
			--iospace & !EXTSEL
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
	nFPUCS <= '0' WHEN ( cpuspace = '1' AND coppercom = '1' AND mc68881 = '1' AND nBGACK = '1' ) ELSE '1';

	--BERR		= cpuspace & coppercom & mc68881 & !SENSE & !BGACK;
	--BERR.OE	= cpuspace & coppercom & mc68881 & !SENSE & !BGACK;
	nBERR <= '0' WHEN ( cpuspace = '1' AND coppercom = '1' AND mc68881 = '1' AND nBGACK = '1' AND nSENSE = '1' ) ELSE 'Z';
	
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
	interruptack <= '1' WHEN A( 19 downto 16 ) = "1111" ELSE '0';

	--AVEC		= cpuspace & interruptack & !BGACK;
	nAVEC <= '0' WHEN (cpuspace = '1' AND interruptack = '1' AND nBGACK = '1') ELSE '1';


	---------------
	-- ROM STUFF --
	---------------

	--This group of logic is to drive the clock on U303 in order to capture
	--important information for the ROM at startup/autoconfig u304
	
	--addr <= A( 23 downto 15 );
	--Low memory ROM space, used for mapping of ROMs on reset.
	lorom <= '1' WHEN A( 23 downto 16 ) = "00000000" ELSE '0'; --addr:[000000..00ffff] 
	--00ffff = 000000001111111111111111
	
	--High memory rom space, where ROMs normally reside when available.
	hirom <= '1' WHEN A( 23 downto 16 ) = "11111000" ELSE '0'; --addr:[f80000..f8ffff] 
	--f80000 = 111110000000000000000000
	--f8fff =   111110001111111111111111
	
	readcycle <= '1' WHEN RnW = '1' AND nAS = '0' ELSE '0';
	
	--icsrom		= hirom & !PHANHI & readcycle		# lorom & !PHANLO & readcycle;
	icsrom <= '1' 
		WHEN 
			( hirom = '1' AND PHANTOMHI = '0' AND readcycle = '1' ) OR 
			( lorom = '1' AND PHANTOMLO = '0' AND readcycle = '1' ) 
		ELSE 
			'0';
	
	--The Special Device configuration register is at $E80040, occupying the lower byte of that word.
	--romaddr		= addr:40;
	--THIS SIGNAL LATCHES HIGH WHEN THE ADDRESS IS EQUAL TO THE SPECIAL REGISTER. THIS IS SEPERATE FROM THE AUTOCONFIG PROCESS.
	--THIS IS OK. LEAVE IT.
	romaddr <= '1' WHEN A(6 downto 1) = "100000" ELSE '0'; --01000000

	--icsauto		= autocon & AS & !RAMCONF &  AUTO 		# autocon & AS & !ROMCONF & !AUTO;
	--autocon = we're in autoconfig space (e8000 - e8fff)
	--ramconf and rom conf = are the ram or rom autoconfiged?
	--auto = should we autoconfig ram? 1=yes
	--U301 
	
	--This will hold the latch on U303 from the time autoconfig begins until it is complete
	icsauto <= '1' 
		WHEN 
			( autoconfigspace = '1' AND nAS = '0' AND autoconfigcomplete_ZORRO2RAM = '0' AND Z2AUTO = '1' ) OR 
			( autoconfigspace = '1' AND nAS = '0' AND autoconfigcomplete_2630 = '0' AND Z2AUTO = '0' ) 
		ELSE 
			'0';
			
	--This is the basic ROM chip select logic.  We want ROM to pay attention
	--to the phantom signals, and only show up on reads. U304
	
	--CSROM		= icsrom;
	--nCSROM <= '0' WHEN icsrom = '1' ELSE '1';
	nCSROM <= NOT icsrom;
	
	--CSAUTO		= icsauto		# CSAUTO & AS; 	
	--CHIP SELECT FOR AUTOCONFIG
	--CAN THIS BE REWORKED BECAUSE OF HOW I'M AUTOCONFIGING?
	--probably not, as this is to latch U303. 
	--there might be an alternative way, but this is ok for now
	PROCESS (CPUCLK) BEGIN
		IF RISING_EDGE (CPUCLK) THEN
			IF csauto = '1' THEN
				IF nAS = '0' THEN
					csauto <= '1';
				ELSE
					csauto <= '0';
				END IF;
			ELSE
				IF icsauto = '1' THEN
					csauto <= '1';
				ELSE
					csauto <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	--writecycle	= CSAUTO & !PRW & DS & !CPURESET;
	writecycle <= '1' WHEN csauto = '1' AND RnW = '0' AND nDS ='0' AND nCPURESET = '1' ELSE '0';
	--WRITECYCLE WHEN CSAUTO AND WRITE MODE AND DATA STROBE AND NOT CPURESET	
		
	--THIS GOES THROUGH AN INVERTING GATE IN THE A2630 (U307). NO NEED FOR THAT, CUZ WE CAN SUPPLY THE CORRECT SIGNAL HERE!
	--ROMCLK = writecycle & romaddr & !CONFIGED  #  ROMCLK & DS;
	
	--The 2630 ROM falls into the special register category and is handled differently than the typical AUTOCONFIG sequence
	--This clocks U303, which latches some data lines to capture the PHANTOM signals, among others
	PROCESS (CPUCLK) BEGIN
		IF RISING_EDGE ( CPUCLK ) THEN
			IF (ROMCLK = '1') THEN		
				--ROMCLK is already latched, but if data strobe is still asserted, we need to hold the latch
				IF (nDS = '0') THEN
					ROMCLK <= '1';
				ELSE
					ROMCLK <= '0';
				END IF;
			ELSE
				--ROMCLK is not latched. Should it be?
				IF (writecycle = '1' AND romaddr = '1' AND autoconfigcomplete_2630 = '0') THEN
					ROMCLK <= '1';
				ELSE
					ROMCLK <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	-----------------
	-- MEMORY LOCK --
	-----------------
	
	--MEMLOCK is used to lock out the 68000 state machine during a fast 
	--system cycle, which is basically either an on-board memory cycle
	--or an EXTERN (Z3 or FPU) cycle.  Additionally, the 68000 state machine uses
	--this same mechanism to end it's own cycle, so CYCEND also gets
	--included. U305

	--"Normal" state is logic low unless we are DMAing.
	--MEMLOCK		= access & CONFIGED		# !AS		# EXTERN		# CYCEND;
	
	--should configed here actually be z2_ram_configed?
	
	nMEMLOCK <= '0' 
		WHEN
			( configed = '1' AND MEMACCESS = '1' )
			--access & CONFIGED
		OR
			( nAS = '1' )
			--!AS
		OR
			( nEXTERN = '0' )
			--EXTERN
		OR
			( nCYCEND = '0' )
			--CYCEND
		ELSE
			'1';
			
	------------------		
	-- DATA STROBES --
	------------------
	
	--rds		=  ASEN & !CYCEND &  RW & !EXTERN;
	rds <= '1' WHEN nASEN = '0' AND nCYCEND = '1' AND RnW = '1' AND nEXTERN = '1' ELSE '0';

	--wds		=  DSEN & !CYCEND & !RW;
	wds <= '1' WHEN nDSEN = '0' AND nCYCEND = '1' AND RnW = '0' ELSE '0';
	
	--offboard	= !(ONBOARD # MEMSEL # EXTERN);
	--Can this be replaced with nBGACK = 0??
	--nMEMSEL is low when we are accessing Z2 ram...either cpu or dma
	--Should be "1" when we are not using any onboard resources...that is no z2 ram, rom, or autoconfig in process, or cpu space
	--offboard <= '1' WHEN (nONBOARD = '1' OR nMEMSEL = '1' OR nEXTERN = '1') ELSE '0';
	offboard <= '1' 
	WHEN 
		(nONBOARD = '1' AND MEMACCESS = '0' AND nEXTERN = '1')
		--(nONBOARD = '1' OR nMEMSEL = '1' OR nEXTERN = '1') 
	ELSE 
		'0';
					
	--68000 style data strobes.  These are kept in tri-state when the 
	--TRISTATE signal is active, or when we're not "offboard".  For 68030
	--caching, we must always return 16 bits on reads, regardless of the
	--state of A0, SIZ1, or SIZ2. If the memory access is a normal offboard access, UDS
	--looks normal.  If the memory access is not offboard, the then UDS
	--reflects the state of the CPU's R/W line. U501

	--UDS		= wds & !A0		# rds ;
	--[UDS, LDS, ARW, AAS].OE = !TRISTATE & offboard ;
	nUDS <= 'Z' 
		WHEN 
			TRISTATE = '1' OR offboard = '0'
		ELSE '0'
			WHEN
				( wds = '1' AND A(0) = '0' ) OR
				( rds = '1' )
		ELSE 
			'1';

	--LDS		= wds & SIZ1		# wds & !SIZ0		# wds & A0		# rds ;
	--[UDS, LDS, ARW, AAS].OE = !TRISTATE & offboard ;
	nLDS <= 'Z'
		WHEN
			TRISTATE = '1' OR offboard = '0'
		ELSE '0'
			WHEN
				((wds = '1' AND SIZ(1) = '1') OR 
				(wds = '1' AND SIZ(0) = '0') OR 
				(wds = '1' AND A(0) = '1') OR
				(rds = '1'))
		ELSE 
			'1';
			
	----------------------
	-- ONBOARD RESOURCE --
	----------------------
	
	--DETERMINES IF WE ARE USING A RESOURCE ON THE 2630 BOARD
	--Basically, if we accessing the 2630 ROM or in autoconfig mode, then
	--we are "ONBOARD"
	
	--ONBOARD		= icsrom 		# icsauto		# ONBOARD & AS;
	--nONBOARD <= '0' WHEN icsrom = '1' OR icsauto = '1' OR ( nONBOARD = '0' AND nAS = '0' ) ELSE '1';

	PROCESS (CPUCLK) BEGIN
		IF RISING_EDGE ( CPUCLK ) THEN
			IF (nONBOARD = '0') THEN
				--We are currently in an onboard process. We need to hold it until the address strobe is negated.
				IF (nAS = '0') THEN
					nONBOARD <= '0';
				ELSE
					nONBOARD <= '1';
				END IF;
			ELSE
				--Are we accessing the 2630 ROM or in autoconfig mode?	
				IF (icsrom = '1' OR icsauto = '1') THEN
					nONBOARD <= '0';
				ELSE
					nONBOARD <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-----------------------------------
	-- ADDRESS BUS DIRECTION CONTROL --
	-----------------------------------
	
	--This is data direction control

	--!ADDIR		=  BGACK & !RW		# !BGACK &  RW;
	ADDIR <= '0' --AMIGA WRITING TO 2630
		WHEN 
			( nBGACK = '0' AND RnW = '0' ) OR  
			( nBGACK = '1' AND RnW = '1' ) 
		ELSE 
			'1'; --2630 WRITING TO THE AMIGA

end Behavioral;
