----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       JASON NEUS
-- 
-- Create Date:    09:42:54 02/13/2022 
-- Design Name:    "HIGH" CPLD
-- Module Name:    MAIN_HIGH - Behavioral 
-- Project Name:   N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: MUCH OF THIS LOGIC AND COMMENTS ARE LIFTED STRAIGHT FROM THE PAL LOGIC FROM DAVE HAYNIE 
--                      (THANKS DAVE! HOPE YOU ARE DOING WELL.)
--                      EDITS FOR THE N2630 PROJECT MADE BY JASON NEUS
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

entity MAIN_HIGH is
    Port ( 
		--64 PINS USED
	 
		FC : IN STD_LOGIC_VECTOR (2 downto 0); --FCn FROM 68030
		AL : IN STD_LOGIC_VECTOR (6 downto 0); --ADDRESS BUS BITS 6..1
		AH : IN STD_LOGIC_VECTOR (23 downto 13); --ADDRESS BUS BITS 23..16
		SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
		CPUCLK : IN STD_LOGIC; --68030 CLOCK
		nAS : IN STD_LOGIC; --680x0 ADDRESS STROBE
		nDS : IN STD_LOGIC; --680x0 DATA STROBE
		RnW : IN STD_LOGIC; --680x0 READ/WRITE
		nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
		nSENSE : IN STD_LOGIC; --6888x PRESENCE
		--EXTSEL : IN STD_LOGIC; --IS THE EXPANSION RAM SELECTED?
		OSMODE : IN STD_LOGIC; --HIGH FOR AMIGA OS, LOW FOR UNIX
		PHANTOMHI : IN STD_LOGIC; --PHANTOM HI DATA
		PHANTOMLO : IN STD_LOGIC; --PHANTOM LO DATA
		--nBOSS : IN STD_LOGIC; --ARE WE BOSS?
		nCPURESET : IN STD_LOGIC; --RESET FOR THE 68030
		
		AUTO : IN STD_LOGIC; --SHOULD I AUTOCONFIG?
		--ROMCONF : IN STD_LOGIC; --ROM HAS BEEN CONFIGURED
		--RAMCONF : IN STD_LOGIC; --RAM HAS BEEN CONFIGURED
	   TWOMB : IN STD_LOGIC; --LOW LOGIC FOR 2MB CONFIGURATION, HIGH FOR 4MB
		nEXTERN : IN STD_LOGIC; --EXTERNAL ACCESS (DAUGHTER OR FPU)
		nCYCEND : IN STD_LOGIC; --CYCLE END
		nDSEN : IN STD_LOGIC; --DATA STROBE ENABLE
		nASEN: IN STD_LOGIC; --ADDRESS STROBE ENABLE
		TRISTATE : IN STD_LOGIC; --TRISTATE WHEN WE DON'T HAVE THE BUS
		nONBOARD : IN STD_LOGIC; --ARE WE USING RESOURCES ON THE 2630?
		nMEMSEL : IN STD_LOGIC; --ARE WE SELECTING MEMORY ON BOARD? FIRST 4 (8) MEGABYTES
	 
		DAC : INOUT STD_LOGIC_VECTOR (31 downto 28):= "ZZZZ"; --DATA BUS FOR THE AUTOCONFIG PROCESS
		CONFIGED : INOUT STD_LOGIC; --HAS AUTOCONFIG COMPLETED?
		nRESET : IN STD_LOGIC; --QUALIFIED SYSTEM RESET SIGNAL 
		ROMCLK : INOUT STD_LOGIC; --CLOCK FOR U303
	 
	 	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
		nBERR : OUT STD_LOGIC; --BUS ERROR
		nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
		nAVEC : OUT STD_LOGIC; --AUTO VECTORING
		nCSROM : OUT STD_LOGIC; --ROM CHIP SELECT		
		--nRAMCLK : OUT STD_LOGIC --CLOCK FOR U302
		nOE0 : OUT STD_LOGIC; --SRAM OUTPUT ENABLE BANK 0
		nOE1 : OUT STD_LOGIC; --SRAM OUTPUT ENABLE BANK 1
		nWE0 : OUT STD_LOGIC; --SRAM WRITE ENABLE BANK 0
		nWE1 : OUT STD_LOGIC; --SRAM WRITE ENABLE BANK 1
		nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
		nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
		nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
		nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
		nMEMLOCK : OUT STD_LOGIC; --LOCK MEMORY DURING ACCESS FOR STATE MACHINE
		nUDS : OUT STD_LOGIC; --68000 UPPER DATA STROBE
		nLDS : OUT STD_LOGIC; --68000 LOWER DATA STROBE
		ARnW : OUT STD_LOGIC; --68000 READ/WRITE SIGNAL
		nOVR : OUT STD_LOGIC --OVERRIDE GARY DTACK
		
		);
		
end MAIN_HIGH;

architecture Behavioral of MAIN_HIGH is

	----------------------
	-- INTERNAL SIGNALS --
	----------------------
	
	--All internal signals are active HIGH!
	--SIGNAL baseaddress : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR 2630
	SIGNAL baseaddress_ZORRO2RAM : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR ZORRO 2 RAM
	--SIGNAL baseaddress_ZORRO3RAM : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR ZORRO 3 RAM
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
	
	SIGNAL D_2630 : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ"; --This throws a "hinder the constant cleaning" error. IGNORE IT.
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ";
	--SIGNAL D_ZORRO3RAM : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ";
	SIGNAL autoconfigcomplete_2630 : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	SIGNAL autoconfigcomplete_ZORRO2RAM : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	--SIGNAL autoconfigcomplete_ZORRO3RAM : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	
	SIGNAL twomeg : STD_LOGIC:='0'; --TWO MB RAM SPACE
	SIGNAL fourmeg : STD_LOGIC:='0'; --FOUR MB RAM SPACE
	
	SIGNAL icsrom : STD_LOGIC:='0';
	SIGNAL hirom : STD_LOGIC:='0';
	SIGNAL lorom : STD_LOGIC:='0';
	--SIGNAL addr : STD_LOGIC_VECTOR( 23 downto 15 ) := (others => '0'); --CONNECTED TO 68030 ADDRESS BUS
	SIGNAL readcycle : STD_LOGIC:='0';
	SIGNAL writecycle : STD_LOGIC:='0';
	SIGNAL romaddr : STD_LOGIC := '0';
	--SIGNAL ramaddr : STD_LOGIC := '0';
	--SIGNAL autoconfigwritecycle : STD_LOGIC := '0';
	SIGNAL csauto : STD_LOGIC := '0';
	SIGNAL icsauto : STD_LOGIC:='0';
	SIGNAL rds : STD_LOGIC:='0';
	SIGNAL wds : STD_LOGIC:='0';
	SIGNAL offboard : STD_LOGIC:='0';
	
	
	SIGNAL EXTSEL : STD_LOGIC:='0'; --THIS IS A TEMPORARY MEASURE UNTIL WE IMPLEMENT THE EXPANSION MEMORY
	                                --THIS ALLOWS ME TO IMPLEMENT THE LOGIC WITHOUT ACTUALLY CONNECTING ANYTHING
	

begin

	----------------------------
	-- INTERNAL SIGNAL DEFINE --
	----------------------------

	--field cpuaddr	= [A23..13] ;			/* Normal CPU space stuff */
	chipram <= '1' WHEN AH(23 downto 13) >= "00000000000" AND AH(23 downto 13) <= "00011111111"  ELSE '0';
	--chipram		= (cpuaddr:[000000..1fffff]) ;    /* All Chip RAM */
	--busspace	= (cpuaddr:[200000..9fffff]) ;    /* Main expansion bus */
	ciaspace <= '1' WHEN AH(23 downto 13) >= "10100000000" AND AH(23 downto 13) <= "10111111111" ELSE '0';
	--ciaspace	= (cpuaddr:[a00000..bfffff]) ;    /* VPA decode */
	--extraram	= (cpuaddr:[c00000..cfffff]) ;    /* Motherboard RAM */
	chipregs <= '1' WHEN AH(23 downto 13) >= "11010000000" AND AH(23 downto 13) <= "11011111111" ELSE '0';
	--chipregs	= (cpuaddr:[d00000..dfffff]) ;    /* Custom chip registers */
	iospace <= '1' WHEN AH(23 downto 13) >= "11101000000" AND AH(23 downto 13) <= "11101111111" ELSE '0';
	--iospace		= (cpuaddr:[e80000..efffff]) ;    /* I/O expansion bus */
	--romspace	= (cpuaddr:[f80000..ffffff]) ;    /* All ROM */
	
	--field spacetype	= [A19..16] ;
	--interruptack	= (spacetype:f0000) ;
	--coppercom	= (spacetype:20000) ;
	--breakpoint	= (spacetype:00000) ;
	interruptack <= '1' WHEN AH( 19 downto 16 ) = "1111" ELSE '0';
	coppercom <= '1' WHEN AH( 19 downto 16 ) = "0010" ELSE '0';
	mc68881 <= '1' WHEN AH( 15 downto 13 ) = "001" ELSE '0';
	
	userdata	<= '1' WHEN FC( 2 downto 0 ) = "001" ELSE '0'; --(cpustate:1)
	superdata <= '1' WHEN FC( 2 downto 0 ) = "101" ELSE '0'; --(cpustate:5)
	cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0'; --(cpustate:7)
	
	--addr <= AH( 23 downto 15 );
	--Low memory ROM space, used for mapping of ROMs on reset.
	lorom <= '1' WHEN AH( 23 downto 15 ) >= "000000000" AND AH( 23 downto 15 ) <= "111111111" ELSE '0'; --addr:[000000..00ffff]
	--High memory rom space, where ROMs normally reside when available.
	hirom <= '1' WHEN AH( 23 downto 15 ) >= "111110000" AND AH( 23 downto 15 ) <= "111110001" ELSE '0'; --addr:[f80000..f8ffff]	
	--icsrom		= hirom & !PHANHI & readcycle		# lorom & !PHANLO & readcycle;
	icsrom <= '1' WHEN ( hirom = '1' AND PHANTOMHI = '0' AND readcycle = '1' ) OR ( lorom = '1' AND PHANTOMLO = '0' AND readcycle = '1' ) ELSE '0';
	--icsrom <= '1' WHEN ( hirom = '1' AND RnW = '1' AND nAS = '0' ) OR ( lorom = '1' AND RnW = '1' AND nAS = '0' ) ELSE '0';
	--romaddr		= addr:40;
	romaddr <= '1' WHEN AL(6 downto 1) = "100000" ELSE '0'; --01000000
	--ramaddr		= addr:48;
	--ramaddr <= '1' WHEN AL(6 downto 1) = "100100" ELSE '0'; --01001000
	
	
	readcycle <= '1' WHEN RnW = '1' AND nAS = '0' ELSE '0';
	
	--CSAUTO		= icsauto		# CSAUTO & AS; CHIP SELECT FOR AUTOCONFIG
	csauto <= '1' WHEN ( icsauto = '1' ) OR ( csauto = '1' AND nAS = '0') ELSE '0';
	
	--writecycle	= CSAUTO & !PRW & DS & !CPURESET;
	writecycle <= '1' WHEN csauto = '1' AND RnW = '0' AND nDS ='0' AND nCPURESET = '1' ELSE '0';
	--WRITECYCLE WHEN CSAUTO AND WRITE MODE AND DATA STROBE AND NOT CPURESET
	--csauto IS WHEN WE ARE IN THE AUTOCONFIG PROCESS
	
	--This is the basic autoconfig chip select logic.  The special register
	--always shows up first, the standard RAM register doesn't show up if 
	--we're inhibiting autoconfiguration.

	--icsauto		= autocon & AS & !RAMCONF &  AUTO 		# autocon & AS & !ROMCONF & !AUTO;
	icsauto <= '1' 
		WHEN 
			( AUTO = '1' AND autoconfigspace = '1' AND nAS = '0' AND autoconfigcomplete_ZORRO2RAM = '0' ) OR 
			( AUTO = '0' AND autoconfigspace = '1' AND nAS = '0' AND autoconfigcomplete_2630 = '0' ) 
		ELSE 
			'0';

	--rds		=  ASEN & !CYCEND &  RW & !EXTERN;
	rds <= '1' WHEN nASEN = '0' AND nCYCEND = '1' AND RnW = '1' AND nEXTERN = '1' ELSE '0';

	--wds		=  DSEN & !CYCEND & !RW;
	wds <= '1' WHEN nDSEN = '0' AND nCYCEND = '1' AND RnW = '0' ELSE '0';
	
	--offboard	= !(ONBOARD # MEMSEL # EXTERN);
	offboard <= '1' WHEN (nONBOARD = '1' OR nMEMSEL = '1' OR nEXTERN = '1') ELSE '0';

	----------------
	-- AUTOCONFIG --
	----------------

	--We have three boards we need to autoconfig, in this order
	--1. The 68030 board itself
	--2. The 68030 base memory (up to 8MB) without BOOT ROM in the Zorro 2 space
	--3. The expansion memory (up to 112MB) in the Zorro 3 space	

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition	
	
	--ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	
	autoconfigspace <= '1'
		WHEN 
			AH(23 downto 16) = "11101000" AND nAS = '0' --x"E8" & 0000 hexadecimal 
		ELSE
			'0';	

	--THIS CODE DUMPS THE AUTOCONFIG DATA ON TO D(31..28) DEPENDING ON WHAT WE ARE AUTOCONFIGing	
	DAC(31 downto 28) <= 
		D_2630 WHEN autoconfigcomplete_2630 = '0' AND autoconfigspace ='1' AND CONFIGED = '0' ELSE
		D_ZORRO2RAM WHEN autoconfigcomplete_ZORRO2RAM = '0' AND autoconfigspace ='1' AND CONFIGED = '0' ELSE
		--D_ZORRO3RAM WHEN autoconfigcomplete_ZORRO3RAM = '0' AND autoconfigspace ='1' AND CONFIGED = '0' ELSE
		"ZZZZ";
		
			
	--Here it is in all its glory...the AUTOCONFIG sequence
	PROCESS ( CPUCLK, nRESET ) BEGIN
		IF nRESET = '0' THEN
		
			CONFIGED <= '0';
			--baseaddress <= "000";
			baseaddress_ZORRO2RAM <= "000";
			--baseaddress_ZORRO3RAM <= "000";
			autoconfigcomplete_2630 <= '0';
			autoconfigcomplete_ZORRO2RAM <= '0';
			--autoconfigcomplete_ZORRO3RAM <= '0';
			D_2630 <= "ZZZZ";
			D_ZORRO2RAM <= "ZZZZ";
			--D_ZORRO3RAM <= "ZZZZ";
			
		ELSIF ( FALLING_EDGE (CPUCLK)) THEN
			IF ( autoconfigspace = '1' AND CONFIGED = '0' ) THEN
				IF ( RnW = '1' ) THEN
				
					CASE AL(6 downto 1) IS

						--offset $00
						WHEN "000000" => 
							D_2630 <= "1110"; 
							D_ZORRO2RAM <= "1110"; --er_type: Zorro 2 card without BOOT ROM, LINK TO MEM POOL
							--D_ZORRO3RAM <= "1010"; --er_type: Zorro 3 card without BOOT ROM, LINK TO MEM POOL

						--offset $02
						WHEN "000001" => 
							D_2630 <= "0111";
							D_ZORRO2RAM <= "011" & TWOMEG; --er_type: NEXT BOARD NOT RELATED, 2MB OR 4MB
							--D_ZORRO3RAM <= "0011"; --NEXT BOARD NOT RELATED, 128MB

						--offset $04 INVERTED
						WHEN "000010" => 
							D_2630 <= "1010";
							D_ZORRO2RAM <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number
							--D_ZORRO3RAM <= "1010";

						--offset $06 INVERTED
						WHEN "000011" => 
							D_2630 <= "1110";
							D_ZORRO2RAM <= "1110"; --Product Number Lo Nibble
							--D_ZORRO3RAM <= "1111";

						--offset $08 INVERTED
						WHEN "000100" => 
							D_2630 <= "1111"; --CAN'T BE SHUT UP
							D_ZORRO2RAM <= "1011"; --er_flags: I/O device, can be shut up, reserved, reserved
							--D_ZORRO3RAM <= "0101"; --MEMORY DEVICE, CAN BE SHUT UP, Z3 SIZE

						--offset $0C INVERTED						
						WHEN "000110" => 
							D_2630 <= OSMODE & "111"; --THE A2630 CONFIGURES THIS NIBBLE AS "0111" WHEN UNIX, "1111" WHEN AMIGA OS
							D_ZORRO2RAM <= "1111"; --Reserved: must be zeroes
							--D_ZORRO3RAM <= "1111";

						--offset $12 INVERTED
						WHEN "001001" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, high byte, low nibble hi byte. Just for fun, lets put C= in here!
							--D_ZORRO3RAM <= "1101";

						--offset $16 INVERTED
						WHEN "001011" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, low nibble low byte. Just for fun, lets put C= in here!
							--D_ZORRO3RAM <= "1101";

						WHEN OTHERS => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111"; --INVERTED...Reserved offsets and unused offset values are all zeroes
							--D_ZORRO3RAM <= "1111";

					END CASE;
					
				--Is this one our base address? If yes, we are done with AUTOCONFIG
				ELSIF ( RnW = '0' AND nDS = '0' ) THEN	
				
					IF ( AL(6 downto 1) = "100100" ) THEN
					
						IF ( autoconfigcomplete_2630 = '0' ) THEN
							--BASE ADDRESS FOR THE 68030 BOARD
							--baseaddress <= DAC(31 downto 29);
							--THE 68030 BOARD IS CONFIGED
							autoconfigcomplete_2630 <= '1'; 
						ELSIF ( autoconfigcomplete_ZORRO2RAM = '0' ) THEN
							--BASE ADDRESS FOR THE ZORRO 2 RAM
							baseaddress_ZORRO2RAM <= DAC(31 downto 29); 
							--THE ZORRO 2 RAM IS CONFIGED
							autoconfigcomplete_ZORRO2RAM <= '1'; 
						--ELSIF ( autoconfigcomplete_ZORRO3RAM = '0' ) THEN
							--BASE ADDRESS FOR THE ZORRO 3 RAM
							--baseaddress_ZORRO3RAM <= DAC(31 downto 29); 
							 --THE ZORRO 3 RAM IS CONFIGED
							--autoconfigcomplete_ZORRO3RAM <= '1';
						END IF;
						
						IF ((AUTO = '0') OR autoconfigcomplete_ZORRO2RAM = '1') THEN
							--We always autoconfig the 2630, so do that no matter what
							--AUTO is driven by a jumper on the board, if it is logic 0, the user does not want to use the 
							--on board RAM. Thus, we will stop after the 2630 is autoconfiged.
							--PROBABLY NEED A DIFFERENT CONSIDERATION FOR Z3 RAM
							CONFIGED <= '1'; 
							D_2630 <= "ZZZZ";
							D_ZORRO2RAM <= "ZZZZ";
							--D_ZORRO3RAM <= "ZZZZ";
						END IF;					
						
					END IF;					
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	---------------------
	-- ROM CHIP SELECT --
	---------------------
	
	--This is the basic ROM chip select logic.  We want ROM to pay attention
	--to the phantom signals, and only show up on reads.
	
	--CSROM		= icsrom;
	nCSROM <= '0' WHEN icsrom = '1' ELSE '1';
			
	---------------
	-- RAM STUFF --
	---------------

	--THIS DETERMINES IF WE ARE IN THE FIRST OR SECOND 2 MEGS OF ADDRESS SPACE	
	--HOW DOES BASE ADDRESS FIGURE IN TO ALL THIS?
	twomeg <= '1' 
		WHEN
			AH(23 downto 21) = baseaddress_ZORRO2RAM AND autoconfigcomplete_ZORRO2RAM = '1' --A21 IS LOW IN THE FIRST 2 MEGS
		ELSE
			'0';
			
	fourmeg <= '1'
		WHEN
			AH(23 downto 21) = baseaddress_ZORRO2RAM + 1 AND TWOMB = '1' AND autoconfigcomplete_ZORRO2RAM = '1' --A21 IS HIGH IN THE SECOND 2 MEGS
		ELSE
			'0';	
			
	--	EIGHTMEG <= '1'
	--		WHEN
	--			AH(31 downto 21) = "01000000011" --A22 IS HIGH IN THE SECOND 4 MEGS
	--		ELSE
	--			'0';
	
	--OUTPUT ENABLE OR WRITE ENABLE DEPENDING ON THE CPU REQUEST
	nOE0 <= '0' WHEN RnW = '1' AND twomeg = '1' ELSE '1';
	nOE1 <= '0' WHEN RnW = '1' AND fourmeg = '1' ELSE '1';
	nWE0 <= '0' WHEN RnW = '0' AND twomeg = '1' ELSE '1';
	nWE1 <= '0' WHEN RnW = '0' AND fourmeg = '1' ELSE '1';	
	
	--THIS IS ALL IN SECTION 12 OF THE 68030 MANUAL
	RAM_ACCESS:PROCESS ( CPUCLK ) BEGIN
		
		IF ( FALLING_EDGE (CPUCLK) ) THEN

			IF (autoconfigcomplete_ZORRO2RAM = '1' AND cpuspace = '0' AND nAS = '0') THEN		

				--ENABLE THE VARIOUS BYTES ON THE SRAM DEPENDING ON WHAT THE CPU IS ASKING FOR

				--UPPER UPPER BYTE ENABLE (D31..24)
				IF (( RnW = '1' ) 
					OR (RnW = '0' AND AL(1 downto 0) = "00" AND nDS = '0')) 
				THEN			
					nUUBE <= '0'; 
				ELSE 
					nUUBE <= '1';
				END IF;

				--UPPER MIDDLE BYTE (D23..16)
				IF (( RnW = '1' ) 
					OR ( RnW = '0' AND AL(1 downto 0) = "01"  AND nDS = '0')
					OR ( AL(1) = '0' AND SIZ(0) = '0'  AND nDS = '0') 
					OR ( AL(1) = '0' AND SIZ(1) = '1'  AND nDS = '0')) 
				THEN
					nUMBE <= '0';
				ELSE
					nUMBE <= '1';
				END IF;

				--LOWER MIDDLE BYTE (D15..8)
				IF (( RnW = '1' )
					OR ( RnW = '0' AND AL(1 downto 0) = "10"  AND nDS = '0') 
					OR ( AL(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0'  AND nDS = '0') 
					OR	( AL(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1'  AND nDS = '0') 
					OR ( AL(0) = '1' AND AL(1) = '0' AND SIZ(0) = '0'  AND nDS = '0'))
				THEN
					nLMBE <= '0';
				ELSE
					nLMBE <= '1';
				END IF;

				--LOWER LOWER BYTE (D7..0)
				IF (( RnW = '1' )
					OR	( RnW = '0' AND ( AL(1 downto 0) = "11"  AND nDS = '0' ))
					OR (AL(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') 
					OR	(SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') 
					OR	(AL(1) = '1' AND SIZ(1) ='1' AND nDS = '0'))
				THEN
					nLLBE <= '0';
				ELSE
					nLLBE <= '1';
				END IF;	

				--nSTERM = Bus response signal that indicates a port size of 32 bits and
				--that data may be latched on the next falling clock edge. Synchronous transfer.
				--STERM is only used on the daughterboard of the A2630. The A2630 card uses DSACKx for terminiation,
				--which may be due to the 32 <-> 16 bit transfers when DMA'ing

				--IF TWOMEG = '1' OR FOURMEG = '1' THEN
				--	nSTERM <= '0';
				--ELSE
				--	nSTERM <= '1';
				--END IF;

				--CACHE GOES IN HERE SOMEWHERE
				--_CBREQ _CBACK WE ARE NOT USING ANY CACHE MEMORY
				--DBEN external data buffers - not needed

			ELSE 
				--DEACTIVATE ALL THE RAM STUFF
				--nSTERM <= '1';

				nUUBE <= '1';
				nUMBE <= '1';
				nLMBE <= '1';
				nLLBE <= '1';	

			END IF;	
		END IF;
	END PROCESS RAM_ACCESS;
	
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
	
	nCIIN <= '1' 
		WHEN
			(chipram = '1' AND ( userdata = '1' OR superdata = '1' ) AND EXTSEL = '0') OR
			--!CACHE = chipram & (userdata # superdata) & !EXTSEL
			(ciaspace = '1' AND EXTSEL = '0') OR
			--ciaspace & !EXTSEL
			(chipregs = '1' AND EXTSEL = '0') OR
			--chipregs & !EXTSEL
			(iospace = '1' AND EXTSEL = '0')
			--iospace & !EXTSEL
		ELSE
			'0';		

	-----------------------
	-- 6888x CHIP SELECT --
	-----------------------
	
	--This selects the 68881 or 68882 math chip, as long as there's no DMA 
	--going on.  If the chip isn't there, we want a bus error generated to 
	--force an F-line emulation exception.  Add in AS as a qualifier here
	--if the PAL ever turns out too slow to make FPUCS before AS.

	nFPUCS <= '0' WHEN ( cpuspace = '1' AND coppercom = '1' AND mc68881 = '1' AND nBGACK = '1' ) ELSE '1';

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

	--AVEC		= cpuspace & interruptack & !BGACK;
	nAVEC <= '0' WHEN (cpuspace = '1' AND interruptack = '1' AND nBGACK = '1') ELSE '1';


	---------------------------------
	-- CLOCKS FOR FF U302 AND U303 --
	---------------------------------
	
	--I DON'T KNOW...SOME OF THIS LOOKS LIKE AUTOCONFIG STUFF...I DON'T NEED THE AUTOCONFIG LOGIC...
	
	
	
	--SEEMS THAT THIS CLOCKS U307 DURING THE AUTOCONFIG WRITE CYCLE BUT BEFORE THE 2360 AUTOCONFIG BASE ADDRESS IS ASSIGNED
			
	--THE ADDRESS romaddr x40 (binary 01000000) LINES UP WITH THE SERIAL NUMBER READ DURING AUTOCONFIG, BUT THAT MEANS NOTHING IN THIS CONTEXT?
	--DAVE MUST HAVE PICKED A POINT BEFORE THE AUTOCONFIG WAS COMPLETE TO LATCH THE DATA ON U307? But the serial number read is a "read" event, but this
	--is looking for a "write" event? So I'm not sure this will ever fire...
	
	--THIS GOES THROUGH AN INVERTING GATE IN THE A2630 (U307). NO NEED FOR THAT, SO WE INVERT THE SIGNAL HERE!
	--ROMCLK = writecycle & romaddr & !CONFIGED  #  ROMCLK & DS;
	ROMCLK <= '1' WHEN ( writecycle = '1' AND romaddr = '1' AND autoconfigcomplete_2630 = '0' ) OR ( ROMCLK = '1' AND nDS = '0' ) ELSE '0';
	--WRITECYCLE WHEN CSAUTO AND WRITE MODE AND DATA STROBE AND NOT CPURESET
	--csauto IS WHEN WE ARE IN THE AUTOCONFIG PROCESS

	--RAMCLK		= writecycle & ramaddr & !ROMCLK		# !CPURESET & RAMCLK;	
	--nRAMCLK <= '0' WHEN ( writecycle = '1' AND ramaddr = '1' AND nROMCLK = '1' ) OR (nCPURESET = '1' AND nROMCLK = '1' ) ELSE '1';
	
	-----------------
	-- MEMORY LOCK --
	-----------------
	
	--MEMLOCK is used to lock out the 68000 state machine during a fast 
	--system cycle, which is basically either an on-board memory cycle
	--or an EXTERN cycle.  Additionally, the 68000 state machine uses
	--this same mechanism to end it's own cycle, so CYCEND also gets
	--included. U305

	nMEMLOCK <= '0' 
		WHEN
			( CONFIGED = '1' AND ( twomeg = '1' OR fourmeg = '1' ))
			--access & CONFIGED
		OR
			( nAS = '1' )
			--!AS
		OR
			( nEXTERN = '0' )
			--EXTERN
		OR
			( nCYCEND = '1' )
			--CYCEND
		ELSE
			'1';
			
	------------------		
	-- DATA STROBES --
	------------------
					
	--68000 style data strobes.  These are kept in tri-state when the 
	--TRISTATE signal is active, or when we're not "offboard".  For 68030
	--caching, we must always return 16 bits on reads, regardless of the
	--state of A0, SIZ1, or SIZ2.  Since the CAS PAL for onboard memory
	--was full when this feature of the 68030 was considered, I kludge
	--a fix here.  If the memory access is a normal offboard access, UDS
	--looks normal.  If the memory access is not offboard, the then UDS
	--reflects the state of the CPU's R/W line. U501

	--UDS		= wds & !A0		# rds ;
	nUDS <= 'Z' 
		WHEN 
			TRISTATE = '1' OR offboard = '0'
		ELSE '0'
			WHEN
				wds = '1' AND AL(0) = '0'
		ELSE 
			'1';

	--LDS		= wds & SIZ1		# wds & !SIZ0		# wds & A0		# rds ;
	nLDS <= 'Z'
		WHEN
			TRISTATE = '1' OR offboard = '0'
		ELSE '0'
			WHEN
				((wds = '1' AND SIZ(1) = '1') OR 
				(wds = '1' AND SIZ(0) = '0') OR 
				(wds = '1' AND AL(0) = '1') OR
				rds = '1')
		ELSE 
			'1';
			
	--------------
	-- Amiga RW --
	--------------

	--This signal is the Amiga bus RW line. This signal tristates when we are 
	--not yet boss and when there is a DMA device active, or during an
	--onboard cycle. It shares the 68030 RW signal with the Amiga 2000 hardware

	--ARW		= RW ;
	ARnW <= RnW WHEN TRISTATE = '0' AND offboard = '0' ELSE 'Z';
	
	-------------------------
	-- GARY DTACK OVERRIDE --
	-------------------------
	
	--The OVR signal must be asserted whenever on-board memory is selected
	--during a DMA cycle.  It tri-states GARY's DTACK output, allowing
	--one to be created by our memory logic.

	--OVR		= BGACK & MEMSEL;
	--OVR.OE		= BGACK & MEMSEL;
	nOVR <= '0' WHEN nBGACK = '0' AND nMEMSEL = '0' ELSE 'Z';

end Behavioral;

