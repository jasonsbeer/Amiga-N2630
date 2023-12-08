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
-- Engineer:       JASON NEUS
-- 
-- Create Date:    JANUARY 22, 2023 
-- Design Name:    N2630 U601 CPLD
-- Project Name:   N2630 https://github.com/jasonsbeer/Amiga-N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES LOGIC FOR AUTOCONFIG, ROM SELECT, ZORRO2 SDRAM CONTROLLER
--
-- Hardware Revision: 3.x
-- Revision History:
--    v1.0.0 22-JAN-23 Initial production release. - JN
--    v1.1.0 13-FEB-23 Fixed DMA timings. - JN
--    v1.2.0 16-FEB-23 AUTOCONFIG DSACK timings were preventing the CPU menu from working. Fixed. - JN
--    v1.2.1 25-FEB-23 Added additional delay to ROM _DSACK1 to accomodate 200ns EPROMS. - JN
--    v1.2.2 26-FEB-23 Fixed _DSACKx contention with Zorro 3 cycles. -JN
--    v1.2.3 27-OCT-23 Moved _RESET to U601 and fixed reset glitch. -MH
--    v1.2.4 04-NOV-23 Fixed DSACK glitch during ROM select. -MH
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

entity U601 is

PORT
(

	RnW : IN STD_LOGIC; --680x0 READ/WRITE
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	A : IN STD_LOGIC_VECTOR (23 DOWNTO 0); --680x0 ADDRESS LINES, ZORRO 2 ADDRESS SPACE
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	nDS : IN STD_LOGIC; --68030 DATA STROBE
	nRESET : INOUT STD_LOGIC; --AMIGA RESET SIGNAL
	nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
	nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE
	SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
	FC : IN STD_LOGIC_VECTOR (2 downto 0); --68030 FUNCTION CODES
	OSMODE : IN STD_LOGIC; --J304 UNIX/AMIGA OS
	nCPURESET : IN STD_LOGIC; --68030 RESET SIGNAL
	nHALT : IN STD_LOGIC; --68030 HALT
	nZ2DIS : IN STD_LOGIC; --ZORRO 2 RAM DISABLE
	nZ3DIS : IN STD_LOGIC; --ZORRO 3 RAM AUTOCONFIG DISABLE
	DROM : IN STD_LOGIC_VECTOR (20 DOWNTO 16); --THIS IS FOR THE ROM SPECIAL REGISTER
	nMEMZ3 : IN STD_LOGIC; --ZORRO 3 RAM IS RESPONDING TO THE ADDRESS
	nSENSE : IN STD_LOGIC; --68882 SENSE
	nIDEACCESS : IN STD_LOGIC; --IDE IS RESPONDING TO THE ADDRESS SPACE
	nBOSS : IN STD_LOGIC; --BOSS SIGNAL
	CLK7 : IN STD_LOGIC; --AMIGA 7MHZ CLOCK
	nRAM8 : IN STD_LOGIC; --8/4MB RAM SELECTION JUMPER
	
	nMEMZ2 : INOUT STD_LOGIC; --ARE WE ACCESSING ZORRO 2 RAM ADDRESS SPACE
	CONFIGED : INOUT STD_LOGIC; --ARE WE AUTOCONFIGED?
	D : INOUT STD_LOGIC_VECTOR (31 DOWNTO 28); --68030 DATA BUS
	nCSROM : INOUT STD_LOGIC; --ROM CHIP SELECT	
	SMDIS : INOUT STD_LOGIC; --STATE MACHINE DISABLE 	
	MODE68K : INOUT STD_LOGIC; --ARE WE IN 68000 MODE?	
	
	nFPUCS : OUT STD_LOGIC; --FPU CHIP SELECT
	nBERR : OUT STD_LOGIC; --BUS ERROR
	nCIIN : OUT STD_LOGIC; --68030 CACHE ENABLE
	nAVEC : OUT STD_LOGIC; --AUTO VECTORING
	ZBANK0 : OUT STD_LOGIC; --BANK0 SIGNAL
	ZBANK1 : OUT STD_LOGIC; --BANK1 SIGNAL
	CLKE : OUT STD_LOGIC; --SDRAM CLOCK ENABLE
	ZMA : OUT STD_LOGIC_VECTOR (12 downto 0); --Z2 SDRAM ADDRESS BUS
	nZCS : OUT STD_LOGIC; --SDRAM CHIP SELECT
	nZWE : OUT STD_LOGIC; --SDRAM WRITE ENABLE
	nZCAS : OUT STD_LOGIC; --SDRAM CAS
	nZRAS : OUT STD_LOGIC; --SDRAM RAS
	nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
	nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
	nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
	nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
	nDTACK : OUT STD_LOGIC; --68000 DTACK FOR DMA
	nDSACK : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); --_DSACK1, _DSACK0
	nOVR : OUT STD_LOGIC; --DTACK OVERRIDE
	EMDDIR : OUT STD_LOGIC; --DIRECTION OF MEMORY DATA BUS BUFFERS
	nEMENA : OUT STD_LOGIC; --ENABLE THE MEMORY DATA BUS BUFFERS
	AADIR : OUT STD_LOGIC; --ADDRESS BUS BUFFER DIRECTION
	nAAENA : OUT STD_LOGIC --ADDRESS BUS BUFFER ENABLE

);

end U601;

architecture Behavioral of U601 is
	
	--MEMORY ACCESS SIGNALS
	SIGNAL main_cpuaccess : STD_LOGIC; --ARE WE IN A CPU MEMORY CYCLE?
	SIGNAL main_dsacken : STD_LOGIC; --FEEDS THE 68030 DSACK SIGNALS
	
	--ADDRESS SPACES
	SIGNAL memaccess : STD_LOGIC := '0';
	SIGNAL onboard : STD_LOGIC := '0';
	
	--FPU SIGNALS
	SIGNAL main_cpuspace : STD_LOGIC;
	SIGNAL fpuspace : STD_LOGIC;
	
	--AUTOCONFIG SIGNALS
	SIGNAL main_autoconfigspace : STD_LOGIC; --AUTOCONFIG ADDRESS SPACE
	SIGNAL main_ram2configed : STD_LOGIC; --HAS THE Z2 RAM BEEN AUTOCONFIGED?
	SIGNAL main_hirom : STD_LOGIC; --IS THE ROM IN THE HIGH ADDRESS SPACE?
	SIGNAL main_lorom : STD_LOGIC; --IS THE ROM IN THE LOW ADDRESS SPACE?
	SIGNAL main_rambaseaddress0 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS	
	SIGNAL main_rambaseaddress1 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	SIGNAL main_rambaseaddress2 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	SIGNAL main_rambaseaddress3 : STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM BASE ADDRESS
	
   --ROM RELATED SIGNALS
	CONSTANT DELAYVALUE : INTEGER := 10;
	SIGNAL dsackdelay : INTEGER RANGE 0 TO DELAYVALUE + 2;
	SIGNAL dsack_rom : STD_LOGIC;
	
	--CPU SIGNALS
	SIGNAL reset_enable: STD_LOGIC;
begin

	----------------------------
	-- INSTANTIATE AUTOCONFIG --
	----------------------------

	AUTOCONFIG: ENTITY AUTOCONFIG PORT MAP(
		RnW => RnW,
		CPUCLK => CPUCLK,
		A => A,
		nAS => nAS,
		nDS => nDS,
		nRESET => nRESET,
		OSMODE => OSMODE,
		nCPURESET => nCPURESET,
		nHALT => nHALT,
		nZ2DIS => nZ2DIS,
		nZ3DIS => nZ3DIS,
		DROM => DROM,
		nRAM8 => nRAM8,
		CONFIGED => CONFIGED,
		D => D,
		nCSROM => nCSROM,
		MODE68K => MODE68K,
		reset_enable => reset_enable,
		rambaseaddress0 => main_rambaseaddress0,
		rambaseaddress1 => main_rambaseaddress1,
		rambaseaddress2 => main_rambaseaddress2,
		rambaseaddress3 => main_rambaseaddress3,
		autoconfigspace => main_autoconfigspace,
		hirom => main_hirom,
		lorom => main_lorom,
		ram2configed => main_ram2configed
	);
	
	--------------------------------------------
	-- INSTANTIATE THE ZORRO 2 RAM CONTROLLER --
	--------------------------------------------
	
	ZORRO2RAM: ENTITY ZORRO2RAM PORT MAP(
		rambaseaddress0 => main_rambaseaddress0,
		rambaseaddress1 => main_rambaseaddress1,
		rambaseaddress2 => main_rambaseaddress2,
		rambaseaddress3 => main_rambaseaddress3,
		cpuspace => main_cpuspace,
		ram2configed => main_ram2configed,
		RnW => RnW,
		CPUCLK => CPUCLK,
		A => A,
		nAS => nAS,
		nRESET => nRESET,
		nBGACK => nBGACK,
		nUDS => nUDS,
		nLDS => nLDS,
		SIZ => SIZ,
		nMEMZ3 => nMEMZ3,
		CLK7 => CLK7,
		nMEMZ2 => nMEMZ2,
		dsacken => main_dsacken,
		cpuaccess => main_cpuaccess,
		ZBANK0 => ZBANK0,
		ZBANK1 => ZBANK1,
		CLKE => CLKE,
		ZMA => ZMA,
		nZCS => nZCS,
		nZWE => nZWE,
		nZCAS => nZCAS,
		nZRAS => nZRAS,
		nUUBE => nUUBE,
		nUMBE => nUMBE,
		nLMBE => nLMBE,
		nLLBE => nLLBE,
		nDTACK => nDTACK,
		nOVR => nOVR,
		EMDDIR => EMDDIR,
		nEMENA => nEMENA
	);

	
	-----------
	-- RESET --
	-----------

	--68030 RESET DRIVES nRESET TO THE A2000 WHEN WE'RE BOSS
	--BUT nRESET FROM THE AMIGA CAN ALSO DRIVE nCPURESET TO RESET THE 030
	--TO PREVENT THE LOOP GLITCH THIS CREATES WE GATE THIS WITH reset_enable
	--reset_enable BECOMES TRUE WHEN THE SPECIAL AUTOCONFIG REGISTER IS WRITTEN 

	nRESET <= '0' WHEN nBOSS = '0' AND nCPURESET ='0' and reset_enable = '1' ELSE 'Z';

	---------------------
	-- ADDRESS DECODES --
	---------------------
				
	main_cpuspace <= '1' WHEN FC(2 downto 0) = "111" ELSE '0';
	fpuspace <= '1' WHEN A(19 downto 16) = "0010" ELSE '0';
	
	---------------------
	-- ADDRESS BUFFERS --
	---------------------
	
	--THE AMIGA ADDRESS BUFFERS CONTROL THE FLOW OF THE ADDRESS BUS.
	--WHEN WE ARE BOSS, THE DATA FLOWS FROM THE 2630 TO THE AMIGA 2000.
	--WHEN WE ARE BOSS AND IN A DMA CYCLE, THE DATA FLOWS FROM THE AMIGA 2000 TO THE 2630.
	--WHEN IN 68K MODE, THE DATA FLOWS FROM THE AMIGA 2000 TO THE 2630.
	
	--THE ADDRESS BUFFER DIRECTION
	--AADIR <= '1' WHEN (nBOSS = '0' AND nBGACK = '1') ELSE '0';
	AADIR <= '0' WHEN nBGACK = '0' ELSE '1';
	
	--ENABLE THE ADDRESS BUFFERS WHEN WE ARE BOSS OR WHEN WE ARE IN 68K MODE.
	--LOOKING AT THE LOGIC BELOW, WE BASICALLY NEVER DISABLE THE BUFFERS.
	--THIS MEANS WE COULD TIE IT TO GROUND?
	--nAAENA <= '0' WHEN nBOSS = '0' OR MODE68K = '1' ELSE '1'; 
	nAAENA <= '0' WHEN nBOSS = '0' ELSE '1';

	
	-----------------------------
	-- 68030 DATA TRANSFER ACK --
	-----------------------------
	
	nDSACK <= 
			"01" WHEN nAS = '0' AND (dsack_rom = '1' OR main_autoconfigspace = '1') --16 BIT PORT
		ELSE 
			"00" WHEN nAS = '0' AND main_dsacken = '1' AND main_cpuaccess = '1' --32 BIT PORT
		ELSE
			"11" WHEN main_hirom = '1' OR main_lorom = '1' OR main_autoconfigspace = '1' OR main_cpuaccess = '1' --HOLD BOTH DSACKS FOR NOW
		ELSE
			"ZZ";	
			
	--THIS DELAY EXISTS TO HELP THE 27C256 EPROM AND CPLD PUT VALID DATA ON THE BUS, ESPECIALLY WHEN
	--OPERATING AT 50MHz. THE _DSACK1 SIGNAL IS DELAYED BY THE NUMBER OF CLOCKS SPECIFIED IN THE 
	--delayvalue SIGNAL. THAT GIVES TIME FOR THE SIGNALS FROM THESE DEVICES TO MEET SETUP TIMES.
			
    PROCESS (CPUCLK, nRESET) BEGIN
        IF nRESET = '0' THEN
            dsackdelay <= 0;
            dsack_rom <= '0';
            
        ELSIF RISING_EDGE (CPUCLK) THEN
            IF (nCSROM = '1') THEN
                dsackdelay <= 0;
                dsack_rom  <= '0';
            ELSE
                dsackdelay <= dsackdelay + 1;
                CASE dsackdelay IS
                    WHEN delayvalue =>
                        dsack_rom <= '1';
                    WHEN delayvalue + 2 =>
                        dsackdelay <= 0;
                        dsack_rom <= '0';
                    WHEN others =>    
                END CASE;
            END IF;
        END IF;
    END PROCESS;
	
	---------------------------
	-- STATE MACHINE DISABLE --
	---------------------------
	
	--ASSERT SMDIS (STATE MACHINE DISABLE) WHENEVER WE ARE ACCESSING A RESOURCE
	--ON THE 2630 CARD. THIS INCLUDES ROM, AUTOCONFIG, IDE, ZORRO 2, OR ZORRO 3 
	--MEMORY SPACES. THIS PREVENTS THE 68000 STATE MACHINE FROM STARTING
	--DURING THOSE ACCESS PERIODS.
	
	onboard <= '1' WHEN main_hirom = '1' OR main_lorom = '1' OR main_autoconfigspace = '1' ELSE '0';
	memaccess <= '1' WHEN nIDEACCESS = '0' OR nMEMZ2 = '0' OR nMEMZ3 = '0' ELSE '0';	
	
	SMDIS <= '1' WHEN onboard = '1' OR memaccess = '1' ELSE '0';
	
	
	------------------------
	-- 68030 CACHE ENABLE --
	------------------------
	
	--CACHE INPUT INHIBIT (_CIIN) IS ASSERTED WHEN WE DO NOT WANT
	--THE 68030 TO LOAD DATA INTO ITS INSTRUCTION AND DATA CACHES.
	--MEMORY AND ROM ARE GOOD CANDIDATES FOR CACHING, BUT NOT CHIP
	--RAM BECAUSE AGNUS CAN ALSO USE THAT RAM.
	
	--IS THIS REALLY EVERYTHING WE SHOULD CACHE?
	--THE A2630 GOES ABOUT THIS FROM THE OTHER ANGLE, AND
	--DEACTIVATES THE CACHE OF CERTAIN MEMORY SPACES, RATHER
	--THAN ACTIVATE FOR CERTAIN MEMORY SPACES. THUS, THE C= LOGIC
	--WOULD BE MORE INCLUSIVE.

	nCIIN <= '1' 
		WHEN					
			nMEMZ2 = '0' OR --Zorro 2 Memory Space
			nMEMZ3 = '0' OR --Zorro 3 Memory Space
			A(23 DOWNTO 20) = x"F" OR --ROM SPACE
			A(23 DOWNTO 20) = x"C" --RANGER/SLOW RAM SPACE
		ELSE
			'0';		

	-----------------------
	-- 6888x CHIP SELECT --
	-----------------------
	
	--THE 6888x COPROCESSOR RESPONDS TO CPU SPACE CYCLES (FC = $7) AT
	--A(19..16) = $2. A(15..13) DEFINES COPROCESSOR NUMBER IN A 
	--MULTI-COPROCESSOR ENVIRONMENT. NO AMIGA MODELS HAD MORE THAN ONE
	--FPU, SO WE CAN SAFELY IGNORE THAT PART OF THE ADDRESS.
	
	--THE FPU IS OPTIONAL, SO WE WANT TO GENERATE A BUS ERROR IN THE 
	--EVENT IT IS NOT INSTALLED.
	
	nFPUCS <= '0' WHEN main_cpuspace = '1' AND fpuspace = '1' AND nBGACK = '1' ELSE '1';
	nBERR <= '0' WHEN main_cpuspace = '1' AND fpuspace = '1' AND nBGACK = '1' AND nSENSE = '1' ELSE 'Z';
	
	--------------------
	-- AUTO VECTORING --
	--------------------
	
	--This forces all interrupts to be serviced by autovectoring.  None
	--of the built-in devices supply their own vectors, and the system is
	--generally incompatible with supplied vectors, so this shouldn't be
	--a problem working all the time.  During DMA we don't want any AVEC
	--generation, in case the DMA device is like a Boyer HD and doesn't
	--drive the function codes properly.
			
	--SOME TRIVIA...JEFF BOYER HAD A HAND IN DESIGNING SOME OF THE FIRST ZORRO 2
	--PERIPHERALS AT COMMODORE. SUCH CARDS INCLUDE THE A2052 RAM EXPANSION AND THE A2090 AND A2091
	--HARD DRIVE CARDS. AT MIMINUM, HE HAD A HAND IN DEVELOPING THE ORIGINAL DMAC CHIP FOUND ON THE 
	--A2090/A2091. THUS, IT SEEMS THE "BOYER HD" REFERENCED ABOVE IS ANY HARD DRIVE
	--CONTROLLER WITH HIS ORIGINAL DMAC. THAT DESIGN WAS REPLACED BY THE SDMAC IN THE A3000.
	--AGAIN, DESIGNED BY JEFF BOYER.
	
	nAVEC <= '0' WHEN main_cpuspace = '1' AND A(19 downto 16) = "1111" ELSE '1';

end Behavioral;
