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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAIN_HIGH is
    Port ( 
	 
		FC : IN STD_LOGIC_VECTOR (2 downto 0); --FCn FROM 68030
		AL : IN STD_LOGIC_VECTOR (6 downto 1); --ADDRESS BUS BITS 6..1
		AH : IN STD_LOGIC_VECTOR (23 downto 13); --ADDRESS BUS BITS 23..16
		nRESET : IN STD_LOGIC; --COMPUTER RESET
		CPUCLK : IN STD_LOGIC; --68030 CLOCK
		nAS : IN STD_LOGIC; --680x0 ADDRESS STROBE
		nDS : IN STD_LOGIC; --680x0 DATA STROBE
		RnW : IN STD_LOGIC; --680x0 READ/WRITE
		nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
		nSENSE : IN STD_LOGIC; --6888x PRESENCE
		--EXTSEL : IN STD_LOGIC; --IS THE EXPANSION RAM SELECTED?
		
	 
		DAC : INOUT STD_LOGIC_VECTOR (31 downto 28); --DATA BUS FOR THE AUTOCONFIG PROCESS
		CONFIGED : INOUT STD_LOGIC; --HAS AUTOCONFIG COMPLETED?
		
	 
	 	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
		nBERR : OUT STD_LOGIC; --BUS ERROR
		nCIIN : OUT STD_LOGIC --68030 CACHE ENABLE
		
		
		);
		
end MAIN_HIGH;

architecture Behavioral of MAIN_HIGH is

	----------------------
	-- INTERNAL SIGNALS --
	----------------------
	
	--All internal signals are active HIGH!
	SIGNAL baseaddress : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR ZORRO 2 RAM
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


	----------------
	-- AUTOCONFIG --
	----------------

	--We have two boards we need to autoconfig
	--1. The 68030 with base memory (up to 8MB) without BOOT ROM in the Zorro 2 space
	--2. The expansion memory (up to 112MB) in the Zorro 3 space

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition
	
	--ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	
	autoconfigspace <= '1'
		WHEN 
			AH(23 downto 16) = "11101000" AND nAS = '0' --x"E8" hexadecimal
		ELSE
			'0';			
			
	--Here it is in all its glory...the AUTOCONFIG sequence
	PROCESS ( CPUCLK, nRESET ) BEGIN
		IF nRESET = '0' THEN
			CONFIGED <= '0';
			baseaddress <= "000";
		ELSIF ( FALLING_EDGE (CPUCLK) ) THEN
			IF ( autoconfigspace = '1' AND CONFIGED = '0' AND nAS = '0' ) THEN
				IF ( RnW = '1' ) THEN
				
					CASE AL(6 downto 1) IS

						--offset $00
						WHEN "000000" => DAC(31 downto 28) <= "1110"; --er_type: Zorro 2 card without BOOT ROM

						--offset $02
						WHEN "000001" => DAC(31 downto 28) <= "0111"; --er_type: 4MB

						--offset $04
						WHEN "000010" => DAC(31 downto 28) <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number

						--offset $06
						WHEN "000011" => DAC(31 downto 28) <= "1000"; --Product Number Lo Nibble				

						--offset $08
						WHEN "000100" => DAC(31 downto 28) <= "0010"; --er_flags: I/O device, can't be shut up, reserved, reserved

						--offset $0A
						--WHEN "000101" => D(31 downto 28) <= "0000"; --er_flags: Reserved, must be zeroes

						--offset $0C
						--WHEN "000110" => D(31 downto 28) <= "0000"; --Reserved: must be zeroes				

						--offset $0E
						--WHEN "000111" => D(31 downto 28) <= "0000"; --Reserved: must be zeroes	

						--offset $10
						WHEN "001000" => DAC(31 downto 28) <= "0100"; --Product Number, high nibble hi byte. Just for fun, lets put C= in here!

						--offset $12
						--WHEN "001001" => D(31 downto 28) <= "0000"; --Product Number, low nibble hi byte. Just for fun, lets put C= in here!

						--offset $14
						--WHEN "001010" => D(31 downto 28) <= "0000"; --Product Number, high nibble low byte. Just for fun, lets put C= in here!

						--offset $16
						WHEN "001011" => DAC(31 downto 28) <= "0100"; --Product Number, low nibble low byte. Just for fun, lets put C= in here!

						--offset $18
						--WHEN "001100" => D(31 downto 28) <= "0000"; --Serial number byte 0 high nibble

						--offset $1A
						--WHEN "001101" => D(31 downto 28) <= "0000"; --Serial number byte 0 low nibble				

						WHEN OTHERS => DAC(31 downto 28) <= "0000"; --Reserved offsets and unused offset values are all zeroes

					END CASE;
					
				--Is this one our base address? If yes, we are done with AUTOCONFIG
				ELSIF ( RnW = '0' AND nDS = '0' ) THEN			
					IF ( AL(6 downto 1) = "100100" ) THEN
						baseaddress <= DAC(31 downto 29); --This is written to our device from the Amiga
						CONFIGED <= '1'; --Autoconfig process is done!
					END IF;			
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	------------------------
	-- 68030 CACHE ENABLE --
	------------------------
	
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

end Behavioral;

