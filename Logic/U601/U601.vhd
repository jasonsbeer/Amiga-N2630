----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       JASON NEUS
-- 
-- Create Date:    09:42:54 02/13/2022 
-- Design Name:    "HIGH" CPLD
-- Module Name:    U601 - Behavioral 
-- Project Name:   N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: MUCH OF THIS LOGIC AND COMMENTS ARE TRANSLATED FROM THE PAL LOGIC FROM DAVE HAYNIE 
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

entity U601 is
    Port ( 
		--64 PINS USED
	 
		FC : IN STD_LOGIC_VECTOR (2 downto 0); --FCn FROM 68030
		--AL : IN STD_LOGIC_VECTOR (6 downto 0); --ADDRESS BUS BITS 6..1
		--AH : IN STD_LOGIC_VECTOR (23 downto 13); --ADDRESS BUS BITS 23..16
		A : IN STD_LOGIC_VECTOR (31 downto 0); --68030 Address Bus
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
		--nBOSS : IN STD_LOGIC; --ARE WE BOSS?
		nCPURESET : IN STD_LOGIC; --RESET FOR THE 68030		
		Z2AUTO : IN STD_LOGIC; --SHOULD I AUTOCONFIG ZORRO 2 RAM?
		--ROMCONF : IN STD_LOGIC; --ROM HAS BEEN CONFIGURED
		--RAMCONF : IN STD_LOGIC; --RAM HAS BEEN CONFIGURED
	   --TWOMB : IN STD_LOGIC; --LOW LOGIC FOR 2MB CONFIGURATION, HIGH FOR 4MB
		nEXTERN : IN STD_LOGIC; --EXTERNAL ACCESS (DAUGHTER OR FPU)
		nCYCEND : IN STD_LOGIC; --CYCLE END
		nDSEN : IN STD_LOGIC; --DATA STROBE ENABLE
		nASEN: IN STD_LOGIC; --ADDRESS STROBE ENABLE
		TRISTATE : IN STD_LOGIC; --TRISTATE WHEN WE DON'T HAVE THE BUS		
		nMEMSEL : IN STD_LOGIC; --ARE WE SELECTING MEMORY ON BOARD? FIRST 4 (8) MEGABYTES
		EXTSEL : IN STD_LOGIC; --EXPANSION RAM IS RESPONDING TO THE ADDRESS
		nRESET : IN STD_LOGIC; --A2000 SYSTEM RESET
		--MODE68K : IN STD_LOGIC; --ARE WE IN 68K MODE?
	 
		D : INOUT STD_LOGIC_VECTOR (31 downto 28) := "ZZZZ"; --DATA BUS FOR THE AUTOCONFIG PROCESS
		CONFIGED : INOUT STD_LOGIC; --HAS AUTOCONFIG COMPLETED?		
		ROMCLK : INOUT STD_LOGIC; --CLOCK FOR U303
		nONBOARD : INOUT STD_LOGIC; --ARE WE USING RESOURCES ON THE 2630?
		MEMACCESS : INOUT STD_LOGIC; --LOGIC HIGH WHEN WE ARE ACCESSING Z2 RAM	
	 
	 	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
		nBERR : OUT STD_LOGIC; --BUS ERROR
		nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
		nAVEC : OUT STD_LOGIC; --AUTO VECTORING
		nCSROM : OUT STD_LOGIC; --ROM CHIP SELECT		
		--nRAMCLK : OUT STD_LOGIC --CLOCK FOR U302
		nOE0 : OUT STD_LOGIC; --SRAM OUTPUT ENABLE BANK 0
		--nOE1 : OUT STD_LOGIC; --SRAM OUTPUT ENABLE BANK 1
		nWE0 : OUT STD_LOGIC; --SRAM WRITE ENABLE BANK 0
		--nWE1 : OUT STD_LOGIC; --SRAM WRITE ENABLE BANK 1
		nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
		nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
		nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
		nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
		nMEMLOCK : OUT STD_LOGIC; --LOCK MEMORY DURING ACCESS FOR STATE MACHINE
		nUDS : OUT STD_LOGIC; --68000 UPPER DATA STROBE
		nLDS : OUT STD_LOGIC; --68000 LOWER DATA STROBE
		ARnW : OUT STD_LOGIC; --68000 READ/WRITE SIGNAL		
		EMDDIR : OUT STD_LOGIC --DIRECTION OF DATA LINES FOR MEMORY
		
		);
		
end U601;

architecture Behavioral of U601 is

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
	
	SIGNAL D_2630 : STD_LOGIC_VECTOR ( 2 downto 0 ) := "ZZZ";
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ";
	--SIGNAL D_ZORRO3RAM : STD_LOGIC_VECTOR ( 3 downto 0 ):="ZZZZ";
	SIGNAL autoconfigcomplete_2630 : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	SIGNAL autoconfigcomplete_ZORRO2RAM : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	--SIGNAL autoconfigcomplete_ZORRO3RAM : STD_LOGIC := '0'; --HAS 68030 BOARD BEEN AUTOCONFIGed?
	
	--SIGNAL twomeg : STD_LOGIC:='0'; --TWO MB RAM SPACE
	--SIGNAL fourmeg : STD_LOGIC:='0'; --FOUR MB RAM SPACE
	
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

begin

	----------------------------
	-- INTERNAL SIGNAL DEFINE --
	----------------------------

	--ADDRESS DECODING

	--field cpuaddr	= [A23..13] ;			/* Normal CPU space stuff */
	chipram <= '1' WHEN A(23 downto 13) >= "00000000000" AND A(23 downto 13) <= "00011111111"  ELSE '0';
	--chipram		= (cpuaddr:[000000..1fffff]) ;    /* All Chip RAM */
	--busspace	= (cpuaddr:[200000..9fffff]) ;    /* Main expansion bus */
	ciaspace <= '1' WHEN A(23 downto 13) >= "10100000000" AND A(23 downto 13) <= "10111111111" ELSE '0';
	--ciaspace	= (cpuaddr:[a00000..bfffff]) ;    /* VPA decode */
	--extraram	= (cpuaddr:[c00000..cfffff]) ;    /* Motherboard RAM */
	chipregs <= '1' WHEN A(23 downto 13) >= "11010000000" AND A(23 downto 13) <= "11011111111" ELSE '0';
	--chipregs	= (cpuaddr:[d00000..dfffff]) ;    /* Custom chip registers */
	iospace <= '1' WHEN A(23 downto 13) >= "11101000000" AND A(23 downto 13) <= "11101111111" ELSE '0';
	--iospace		= (cpuaddr:[e80000..efffff]) ;    /* I/O expansion bus */
	--romspace	= (cpuaddr:[f80000..ffffff]) ;    /* All ROM */
	
	--field spacetype	= [A19..16] ;
	--interruptack	= (spacetype:f0000) ;
	--coppercom	= (spacetype:20000) ;
	--breakpoint	= (spacetype:00000) ;
	interruptack <= '1' WHEN A( 19 downto 16 ) = "1111" ELSE '0';
	coppercom <= '1' WHEN A( 19 downto 16 ) = "0010" ELSE '0';
	mc68881 <= '1' WHEN A( 15 downto 13 ) = "001" ELSE '0';
	
	userdata	<= '1' WHEN FC( 2 downto 0 ) = "001" ELSE '0'; --(cpustate:1)
	superdata <= '1' WHEN FC( 2 downto 0 ) = "101" ELSE '0'; --(cpustate:5)
	cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0'; --(cpustate:7)
	

	--ramaddr		= addr:48;
	--ramaddr <= '1' WHEN A(6 downto 1) = "100100" ELSE '0'; --01001000
	
	
	readcycle <= '1' WHEN RnW = '1' AND nAS = '0' ELSE '0';
	

	


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
	--3. The expansion memory (up to 112MB) in the Zorro 3 space. This is done in U602.	

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition	
	
	--ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	
	autoconfigspace <= '1'
		WHEN 
			A(23 downto 16) = "11101000" AND nAS = '0' --x"E8" hexadecimal 
		ELSE
			'0';	

	--THIS CODE DUMPS THE AUTOCONFIG DATA ON TO D(31..28) DEPENDING ON WHAT WE ARE AUTOCONFIGing	
	--We AUTOCONFIG the 2630 FIRST, then the Zorro 2 RAM
	--For REV 0 we only have 2 MB of RAM, so always config it unless AUTO = 0
	D(31 downto 28) <= 
		D_2630(0) & D_2630(1) & "1" & D_2630(2) WHEN autoconfigcomplete_2630 = '0' AND autoconfigspace ='1' AND CONFIGED = '0' ELSE
		D_ZORRO2RAM WHEN autoconfigcomplete_ZORRO2RAM = '0' AND autoconfigspace ='1' AND CONFIGED = '0' ELSE
		"ZZZZ";		
			
	--Here it is in all its glory...the AUTOCONFIG sequence
	PROCESS ( CPUCLK, nRESET ) BEGIN
		IF nRESET = '0' THEN
			--The computer has been reset
			
			CONFIGED <= '0';
			
			baseaddress_ZORRO2RAM <= "000";
			
			autoconfigcomplete_2630 <= '0';
			autoconfigcomplete_ZORRO2RAM <= '0';			
			
		ELSIF ( FALLING_EDGE (CPUCLK)) THEN
			IF ( autoconfigspace = '1' AND CONFIGED = '0' ) THEN
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
							D_ZORRO2RAM <= "0110"; --er_type: NEXT BOARD NOT RELATED, 2MB

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
							D_ZORRO2RAM <= "1011"; --er_flags: I/O device, can be shut up, reserved, reserved

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
							CONFIGED <= '1'; 
						END IF;					
						
					END IF;					
				END IF;
			END IF;
		END IF;
	END PROCESS;
			
	---------------
	-- RAM STUFF --
	---------------

	--THIS DETERMINES IF WE ARE ACCESSING ZORRO 2 RAM
	--We need to signal the U600 if the address space is pointing at our zorro 2 ram
	MEMACCESS <= '1' 
		WHEN
			autoconfigcomplete_ZORRO2RAM = '1' AND A(23 downto 21) = baseaddress_ZORRO2RAM AND A(20) = '0' --A20 IS LOW IN THE FIRST 2 MEGS
		ELSE
			'0';
	
	--OUTPUT ENABLE OR WRITE ENABLE DEPENDING ON THE CPU REQUEST
	nOE0 <= '0' WHEN RnW = '1' AND MEMACCESS = '1' ELSE '1';
	nWE0 <= '0' WHEN RnW = '0' AND MEMACCESS = '1' ELSE '1';
	
	--THIS IS ALL IN SECTION 12 OF THE 68030 MANUAL
	RAM_ACCESS:PROCESS ( CPUCLK ) BEGIN
		
		IF ( FALLING_EDGE (CPUCLK) ) THEN

			IF (autoconfigcomplete_ZORRO2RAM = '1' AND cpuspace = '0' AND nAS = '0') THEN		

				--ENABLE THE VARIOUS BYTES ON THE SRAM DEPENDING ON WHAT THE CPU IS ASKING FOR

				--UPPER UPPER BYTE ENABLE (D31..24)
				IF (( RnW = '1' ) 
					OR (RnW = '0' AND A(1 downto 0) = "00" AND nDS = '0')) 
				THEN			
					nUUBE <= '0'; 
				ELSE 
					nUUBE <= '1';
				END IF;

				--UPPER MIDDLE BYTE (D23..16)
				IF (( RnW = '1' ) 
					OR ( RnW = '0' AND A(1 downto 0) = "01"  AND nDS = '0')
					OR ( A(1) = '0' AND SIZ(0) = '0'  AND nDS = '0') 
					OR ( A(1) = '0' AND SIZ(1) = '1'  AND nDS = '0')) 
				THEN
					nUMBE <= '0';
				ELSE
					nUMBE <= '1';
				END IF;

				--LOWER MIDDLE BYTE (D15..8)
				IF (( RnW = '1' )
					OR ( RnW = '0' AND A(1 downto 0) = "10"  AND nDS = '0') 
					OR ( A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0'  AND nDS = '0') 
					OR	( A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1'  AND nDS = '0') 
					OR ( A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0'  AND nDS = '0'))
				THEN
					nLMBE <= '0';
				ELSE
					nLMBE <= '1';
				END IF;

				--LOWER LOWER BYTE (D7..0)
				IF (( RnW = '1' )
					OR	( RnW = '0' AND ( A(1 downto 0) = "11"  AND nDS = '0' ))
					OR (A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') 
					OR	(SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') 
					OR	(A(1) = '1' AND SIZ(1) ='1' AND nDS = '0'))
				THEN
					nLLBE <= '0';
				ELSE
					nLLBE <= '1';
				END IF;	

			ELSE 
				--DEACTIVATE ALL THE RAM STUFF

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
	
	--EXTSEL = 1 is when Zorro 3 RAM is responding to the address space
	--So, this original code never caches in Z3 ram. 
	--Might want to consider looking into that when Z3 ram is present.
	
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


	---------------
	-- ROM STUFF --
	---------------

	--This group of logic is to drive the clock on U303 in order to capture
	--important information for the ROM at startup/autoconfig
	
	--addr <= A( 23 downto 15 );
	--Low memory ROM space, used for mapping of ROMs on reset.
	lorom <= '1' WHEN A( 23 downto 16 ) = "00000000" ELSE '0'; --addr:[000000..00ffff] AND A( 23 downto 16 ) <= "11111111"
	
	--High memory rom space, where ROMs normally reside when available.
	hirom <= '1' WHEN A( 23 downto 16 ) = "11111000" ELSE '0'; --addr:[f80000..f8fff] AND A( 23 downto 15 ) <= "111110001"
	
	--icsrom		= hirom & !PHANHI & readcycle		# lorom & !PHANLO & readcycle;
	icsrom <= '1' 
		WHEN 
			( hirom = '1' AND PHANTOMHI = '0' AND readcycle = '1' ) OR 
			( lorom = '1' AND PHANTOMLO = '0' AND readcycle = '1' ) 
		ELSE 
			'0';
	
	--The Special Device configuration register is at $E80040, occupying the lower byte of that word.
	--romaddr		= addr:40;
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
	--to the phantom signals, and only show up on reads.
	
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
		
	--THIS GOES THROUGH AN INVERTING GATE IN THE A2630 (U307). NO NEED FOR THAT, SO WE SUPPLY THE CORRECT SIGNAL HERE!
	--ROMCLK = writecycle & romaddr & !CONFIGED  #  ROMCLK & DS;
	--ROMCLK <= '1' WHEN ( writecycle = '1' AND romaddr = '1' AND autoconfigcomplete_2630 = '0' ) OR ( ROMCLK = '1' AND nDS = '0' ) ELSE '0';
	
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
	nMEMLOCK <= '0' 
		WHEN
			( CONFIGED = '1' AND MEMACCESS = '1' )
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
				( wds = '1' AND A(0) = '0' ) OR
				( rds = '1' )
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
				(wds = '1' AND A(0) = '1') OR
				(rds = '1'))
		ELSE 
			'1';
			
	--------------
	-- Amiga RW --
	--------------

	--This signal is the Amiga bus RW line. This signal tristates when we are 
	--not yet boss and when there is a DMA device active, or during an
	--onboard cycle. It shares the 68030 RW signal with the Amiga 2000 hardware

	--ARW		= RW ;	
	ARnW <= 'Z' 
		WHEN 
			TRISTATE = '1' OR offboard = '0'
		ELSE
			RnW;
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
	
	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--This sets the direction of the LVC data buffers between the 680x0 and the RAM
	
	EMDDIR <= NOT RnW;


end Behavioral;