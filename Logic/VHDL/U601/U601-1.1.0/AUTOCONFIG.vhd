----------------------------------------------------------------------------------
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AUTOCONFIG is

PORT (

		RnW : IN STD_LOGIC; --680x0 READ/WRITE
		CPUCLK : IN STD_LOGIC; --68030 CLOCK
		A : IN STD_LOGIC_VECTOR (23 DOWNTO 0); --680x0 ADDRESS LINES, ZORRO 2 ADDRESS SPACE
		nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
		nDS : IN STD_LOGIC; --68030 DATA STROBE
		nRESET : IN STD_LOGIC; --AMIGA RESET SIGNAL
		OSMODE : IN STD_LOGIC; --J304 UNIX/AMIGA OS
		nCPURESET : IN STD_LOGIC; --68030 RESET SIGNAL
		nHALT : IN STD_LOGIC; --68030 HALT
		nZ2DIS : IN STD_LOGIC; --ZORRO 2 RAM DISABLE
		nZ3DIS : IN STD_LOGIC; --ZORRO 3 RAM AUTOCONFIG DISABLE
		DROM : IN STD_LOGIC_VECTOR (20 DOWNTO 16); --THIS IS FOR THE ROM SPECIAL REGISTER
		nRAM8 : IN STD_LOGIC; --8/4MB RAM SELECTION JUMPER
		
		CONFIGED : INOUT STD_LOGIC; --ARE WE AUTOCONFIGED?
		D : INOUT STD_LOGIC_VECTOR (31 DOWNTO 28); --68030 DATA BUS
		nCSROM : INOUT STD_LOGIC; --ROM CHIP SELECT		
		MODE68K : INOUT STD_LOGIC; --ARE WE IN 68000 MODE?	
		
		autoconfigspace : INOUT STD_LOGIC;
		lorom : INOUT STD_LOGIC;
		hirom : INOUT STD_LOGIC;
		ram2configed : INOUT STD_LOGIC;
		
		rambaseaddress0 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS	
		rambaseaddress1 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
		rambaseaddress2 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
		rambaseaddress3 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0) --RAM BASE ADDRESS

);

end AUTOCONFIG;

architecture Behavioral of AUTOCONFIG is

	--AUTOCONFIG SIGNALS
	SIGNAL romconfiged : STD_LOGIC; --HAS THE ROM BEEN AUTOCONFIGED?
	SIGNAL ram3configed : STD_LOGIC; --HAS THE Z3 RAM BEEN AUTOCONFIGED?
	SIGNAL boardconfiged : STD_LOGIC; --HAS THE ROM AND Z2 RAM FINISHED CONFIGURING?
	SIGNAL D_ZORRO2RAM : STD_LOGIC_VECTOR (3 DOWNTO 0); --Z2 AUTOCONFIG DATA
	SIGNAL D_ZORRO3RAM : STD_LOGIC_VECTOR (3 DOWNTO 0); --Z3 AUTOCONFIG DATA
	SIGNAL D_2630 : STD_LOGIC_VECTOR (3 DOWNTO 0); --ROM AUTOCONFIG DATA
	SIGNAL regreset : STD_LOGIC; --REGISTER RESET 
	SIGNAL jmode : STD_LOGIC; --JMODE
	SIGNAL phantomlo : STD_LOGIC; --PHANTOM LOW SIGNAL
	SIGNAL phantomhi : STD_LOGIC; --PHANTOM HIGH SIGNAL
	SIGNAL ramsize : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE FROM J404

begin

	---------------------
	-- ADDRESS DECODES --
	---------------------
	
	autoconfigspace <= '1' WHEN A(23 downto 16) = x"E8" AND boardconfiged = '0' ELSE '0';		
	
	--THE ROM IS PLACED IN THE RESET VECTOR ($000000) WHEN THE SYSTEM FIRST STARTS/RESTARTS.
	--AT THAT TIME, THE ROM RESPONDS IN THE SPACE AT $000000 - $00FFFF.
	--THE ROM WILL STOP RESPONDING ONCE phantomlo IS SET = 1 AFTER CONFIGURATION.
	
	lorom <= '1' WHEN A(23 DOWNTO 16) = x"00" AND phantomlo = '0' AND RnW = '1' ELSE '0';
	
	--AFTERWARD, THE ROM IS THEN MOVED TO THE ADDRESS SPACE AT $F80000 - $F8FFFF.
	--THIS IS THE "NORMAL" PLACE FOR SYSTEM ROMS.
	--THE ROM WILL STOP RESPONDING ONCE phantomhi IS SET = 1 AFTER CONFIGURATION.
	--AT THAT TIME, KICKSTART TAKES OVER.
	
	hirom <= '1' WHEN A(23 DOWNTO 16) = x"F8" AND phantomhi = '0' AND RnW = '1' ELSE '0';
	
	---------------------------
	-- A2630 ROM CHIP SELECT --
	---------------------------
	
	nCSROM <= '0' WHEN (lorom = '1' OR hirom = '1') AND nAS = '0' ELSE '1';	

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
	
	--EVEN THOUGH THIS ISN'T WITH THE AUTOCONFIG STUFF, IT
	--RESPONDS IN THE AUTOCONFIG SPACE, WITH _DSACK1 HANDLED THERE.
	
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
	--THIS IS PASSED TO THE _COPCFG SIGNAL, WHICH MUST BE DONE
	--TO ALLOW THE CONFIGURATION CHAIN TO CONTINUE.
	
	CONFIGED <= '1' WHEN boardconfiged = '1' OR MODE68K = '1' ELSE '0';
	
	--We have three boards we need to autoconfig, in this order
	--1. The 68030 ROM. SEE ALSO SPECIAL REGISTER, ABOVE.
	--2. The base memory (4/8MB) in the Zorro 2 space.
	--3. The expansion memory in the Zorro 3 space.

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore.
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition
			
	--BOARDCONFIGED IS ASSERTED WHEN WE ARE DONE CONFIGING THE ROM AND ZORRO 2 MEMORY.
	--WHEN THE ZORRO 2 RAM IS DISABLED BY J303, IT SETS Z2AUTO = 0.
	
	boardconfiged <= '1' WHEN romconfiged = '1' AND (ram2configed = '1' OR nZ2DIS = '0') AND (ram3configed = '1' OR nZ3DIS = '0') ELSE '0';			

	--THIS CODE ASSERTS THE AUTOCONFIG DATA ON TO D(31..28),
	--DEPENDING ON WHAT WE ARE AUTOCONFIGing.	
	--We AUTOCONFIG the 2630 FIRST, then the Zorro 2 RAM
	
	D(31 downto 28) <= 
			D_2630
				WHEN romconfiged = '0' AND autoconfigspace = '1' AND RnW = '1' AND nAS = '0'
		ELSE
			D_ZORRO2RAM 
				WHEN nZ2DIS = '1' AND ram2configed = '0' AND autoconfigspace = '1' AND RnW = '1' AND nAS = '0' 
		ELSE
			D_ZORRO3RAM 
				WHEN autoconfigspace = '1' AND RnW = '1' AND nAS = '0'
		ELSE
			"ZZZZ";		
			
	--THE ramsize VECTOR IS USED IN THE AUTOCONFIG SEQUENCE TO SET THE USER'S DESIRED RAM SIZE: 4 OR 8 MB.
	--THE USER IS ALLOWED TO AUTOCONFIG LESS THAN 8MB IN THE EVENT THEY ARE USING A CARD THAT RELIES ON 
	--IT'S OWN ONBOARD MEMORY FOR DMA. SUCH AS THE GVP IMPACT SERIES II CARDS. OUR MEMORY CANNOT BE 
	--SHUT UP. SO, WE DON'T WANT TO BLOCK OUT OTHER PERIPHERALS IF THEY NEED THEIR OWN RAM TO FUNCTION.
	
	ramsize <= "000" WHEN nRAM8 = '1' ELSE "111";
	
	--AUTOCONFIG SEQUENCE, IN ALL ITS GLORY!
	PROCESS ( nDS, nRESET ) BEGIN
	
		IF nRESET = '0' THEN
			
			rambaseaddress0 <= "111";
			rambaseaddress1 <= "111";
			rambaseaddress2 <= "111";
			rambaseaddress3 <= "111";
			
			ram2configed <= '0';			
			ram3configed <= '0';
			
			D_2630 <= "0000";
			D_ZORRO2RAM <= "0000";
			D_ZORRO3RAM <= "0000";
			
		ELSIF FALLING_EDGE (nDS) THEN
		
			IF autoconfigspace = '1' THEN
			
				IF RnW = '1' THEN
				
					CASE A(6 downto 1) IS

						--offset $00 NOT INVERTED
						WHEN "000000" => 
							D_2630 <= "1110"; 
							D_ZORRO2RAM <= "1110"; --er_type: Zorro 2 card without BOOT ROM, LINK TO MEM POOL
							D_ZORRO3RAM <= "1010"; --Z3 Board, LINK TO MEM POOL, NO ROM

						--offset $02 NOT INVERTED
						WHEN "000001" => 						
							
							D_2630 <= "0" & ramsize; 
							D_ZORRO2RAM <= "1" & ramsize; --RAM SIZE AS DETERMINED BY JUMPER J404. NEXT DEVICE IS RELATED.
							D_ZORRO3RAM <= "0100"; --256MB. LET THE OS SIZE THE Z3 RAM IN REGISTER $08.

						--offset $04 INVERTED
						WHEN "000010" => 
							D_2630 <= "1010";
							D_ZORRO2RAM <= "1111"; --Product Number Hi Nibble
							D_ZORRO3RAM <= "1111";

						--offset $06 INVERTED
						WHEN "000011" => 
							D_2630 <= "1110";
							D_ZORRO2RAM <= "1111"; --Product Number Lo Nibble
							D_ZORRO3RAM <= "1110";
							
						--offset $08 INVERTED
						WHEN "000100" =>
							D_2630 <= "1111"; 
							D_ZORRO2RAM <= "1011"; --PREFER 8 MEG SPACE, CAN'T BE SHUT UP
							D_ZORRO3RAM <= "0001"; --MEMORY DEVICE, CAN'T BE SHUT UP, EXTENDED RAM SIZE, ZORRO 3 CARD
						
						--offset $0A INVERTED
						WHEN "000101" =>
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111";
							D_ZORRO3RAM <= "1110"; --AUTOSIZED BY OS

						--offset $0C INVERTED						
						WHEN "000110" => 
							D_2630 <= OSMODE & "111"; --THE A2630 CONFIGURES THIS NIBBLE AS "0111" WHEN UNIX, "1111" WHEN AMIGA OS
							D_ZORRO2RAM <= "1111"; --Reserved: must be zeroes
							D_ZORRO3RAM <= "1111";

						--offset $12 INVERTED
						WHEN "001001" => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1101"; --MANUFACTURER Number, low nibble high byte.
							D_ZORRO3RAM <= "1101";
							
						--offset $14 INVERTED
						WHEN "001010" => --00010100
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1010"; --MANUFACTURER Number, high nibble low byte.
							D_ZORRO3RAM <= "1010";

						--offset $16 INVERTED
						WHEN "001011" => --00010110
							D_2630 <= "1111";
							D_ZORRO2RAM <= "0111"; --MANUFACTURER Number, low nibble low byte.
							D_ZORRO3RAM <= "0111";
							
						--offset $22 INVERTED
						WHEN "010001" =>
							D_2630 <= "1111";
							D_ZORRO2RAM <= "0101"; --SERIAL Number, low nibble third byte.
							D_ZORRO3RAM <= "0101";
							
						--offset $24 INVERTED
						WHEN "010010" =>
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1011"; --SERIAL Number, high nibble fourth byte.
							D_ZORRO3RAM <= "1011";
							
						--offset $26 INVERTED
						WHEN "010011" => --00010110
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1001"; --SERIAL Number, low nibble fourth byte.
							D_ZORRO3RAM <= "1001";							

						WHEN OTHERS => 
							D_2630 <= "1111";
							D_ZORRO2RAM <= "1111"; --INVERTED...Reserved offsets and unused offset values are all zeroes
							D_ZORRO3RAM <= "1111";

					END CASE;					

				ELSIF RnW = '0' AND A(6 downto 1) = "100100" THEN
				
					--WRITE REGISTER AT OFFSET $48. THIS IS WHERE THE BASE ADDRESS IS ASSIGNED.
								
					IF ram2configed = '0' AND nZ2DIS = '1' THEN
						
						--THIS IS THE ZORRO 2 RAM BASE ADDRESS.
							
						ram2configed <= '1';
							
						IF nRAM8 = '1' THEN
						
							--WHEN WE ARE AUTOCONFIGing 8MB OF RAM, WE USE UP ALL 
							--THE ADDRESSES OF THE 8MB SPACE, SO THESE ARE THE ONLY
							--POSSIBLE VALUES. 
							
							rambaseaddress0 <= "001";
							rambaseaddress1 <= "010";	
							rambaseaddress2 <= "011";
							rambaseaddress3 <= "100";	
							
						ELSE
							
							--THE USER HAS CHOSEN TO AUTOCONFIGure 4MB.
							--BECAUSE WE HAVE FOUR ADDRESSES TO POPULATE IN OUR LOGIC,
							--WE MAKE DUPLICATES OF THE POSSIBLE TWO 4MB ADDRESSES.
							
							CASE D(31 downto 29) IS
							
								WHEN "001" =>
									rambaseaddress0 <= "001";
									rambaseaddress1 <= "010";	
									rambaseaddress2 <= "001";
									rambaseaddress3 <= "010";	
									
								WHEN "010" =>
									rambaseaddress0 <= "010";
									rambaseaddress1 <= "011";	
									rambaseaddress2 <= "010";
									rambaseaddress3 <= "011";	
									
								WHEN others =>
									rambaseaddress0 <= "011";
									rambaseaddress1 <= "100";	
									rambaseaddress2 <= "011";
									rambaseaddress3 <= "100";
									
							END CASE;			
							
						END IF;
					
					ELSIF ram3configed = '0' THEN
					
						--ACCORDING TO THE MANUAL, Z3 BASE ADDRESS IS ASSIGNED
						--AT $48 FOR ZORRO 3 CARDS AUTOCONFIGed AT $E80000.
						
						ram3configed <= '1';
						
					END IF;

				END IF;					
					
			END IF;					
			
		END IF;
		
	END PROCESS;


end Behavioral;

