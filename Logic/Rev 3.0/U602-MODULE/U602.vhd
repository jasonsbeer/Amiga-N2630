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
-- Create Date:    January 20, 2023
-- Design Name:    N2630 U602 CPLD
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES 50MHz LOGIC FOR ZORRO 3 SDRAM CONTROLLER AND PSUEDO-GAYLE IDE CONTROLLER
--
-- Hardware Revision: 3.x
-- Revision History:
-- 	Initial Production Release xx-JAN-23
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

entity U602 is

PORT (
	
		--GENERAL SIGNALS
		A : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		nDS : IN STD_LOGIC;
		nAS : IN STD_LOGIC;
		nGRESET : IN STD_LOGIC;
		INTRQ : IN STD_LOGIC;
		CPUCLK : IN STD_LOGIC;
		RnW : IN STD_LOGIC;
		FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

		--IDE SIGNALS
		nIDEDIS : IN STD_LOGIC;
		D : INOUT STD_LOGIC;
		nIDEACCESS : INOUT STD_LOGIC;
		nDIOW : OUT STD_LOGIC;
		nDIOR : OUT STD_LOGIC;
		nCS0 : OUT STD_LOGIC;
		nCS1 : OUT STD_LOGIC;
		DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		nIDERST : OUT STD_LOGIC;
		IDEDIR : OUT STD_LOGIC;
		nINT2 : OUT STD_LOGIC;
		nDSACK : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		nIDEEN : OUT STD_LOGIC;
		
		
		--MEM SIGNALS
		A7M : IN STD_LOGIC; --7MHz AMIGA CLOCK
		SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 TRANSFER SIZE SIGNALS
		RAMSIZE : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE JUMPERS
		nMEMZ3 : INOUT STD_LOGIC;		
		nUUBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nUMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nLMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		nLLBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
		EMA : OUT STD_LOGIC_VECTOR (12 DOWNTO 0); --ZORRO 3 MEMORY BUS
		BANK0 : OUT STD_LOGIC; --SDRAM BANK0
		BANK1 : OUT STD_LOGIC; --SDRAM BANK1
		nEMCAS : OUT STD_LOGIC; --CAS
		nEMRAS : OUT STD_LOGIC; --RAS
		nEMWE : OUT STD_LOGIC; --WRITE ENABLE
		EMCLKE : OUT STD_LOGIC; --CLOCK ENABLE
		nEMCS0 : OUT STD_LOGIC; --CHIP SELECT LOW BANK
		nEMCS1 : OUT STD_LOGIC --CHIP SELECT HIGH BANK
		--nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
		--nSTERM : INOUT STD_LOGIC --68030 SYNCRONOUS TERMINATION SIGNAL
		--nCBACK : OUT STD_LOGIC --68030 CACHE BURST ACK
		--nBERR : OUT STD_LOGIC; --BUS ERROR FOR BURST MODE
	
	);

end U602;

architecture Behavioral of U602 is

	SIGNAL idesack : STD_LOGIC;
	SIGNAL memsack : STD_LOGIC;

begin

	------------------------------------
	-- INSTANTIATE THE IDE CONTROLLER --
	------------------------------------

	IDE: entity IDE 
		PORT MAP(
			A => A(23 DOWNTO 2),
			nDS => nDS,
			nAS => nAS,
			nGRESET => nGRESET,
			INTRQ => INTRQ,
			CPUCLK => CPUCLK,
			RnW => RnW,
			FC => FC,
			nIDEDIS => nIDEDIS,
			D => D,
			nIDEACCESS => nIDEACCESS,
			nDIOW => nDIOW,
			nDIOR => nDIOR,
			nCS0 => nCS0,
			nCS1 => nCS1,
			DA => DA,
			nIDERST => nIDERST,
			IDEDIR => IDEDIR,
			nINT2 => nINT2,
			DSACK => idesack,
			nIDEEN => nIDEEN
		);
		
	-----------------------------------------------
	-- INSTANTIATE THE ZORRO 3 MEMORY CONTROLLER --
	-----------------------------------------------
	
	ZORROMEM: entity ZORROMEM 
		PORT MAP(
			A => A,
			RnW => RnW,
			nAS => nAS,
			CPUCLK => CPUCLK,
			A7M => A7M,
			nGRESET => nGRESET,
			FC => FC,
			SIZ => SIZ,
			RAMSIZE => RAMSIZE,
			nMEMZ3 => nMEMZ3,
			DSACK => memsack,
			nUUBE => nUUBE,
			nUMBE => nUMBE,
			nLMBE => nLMBE,
			nLLBE => nLLBE,
			EMA => EMA,
			BANK0 => BANK0,
			BANK1 => BANK1,
			nEMCAS => nEMCAS,
			nEMRAS => nEMRAS,
			nEMWE => nEMWE,
			EMCLKE => EMCLKE,
			nEMCS0 => nEMCS0,
			nEMCS1 => nEMCS1
		);

	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	PROCESS (CPUCLK, nGRESET) BEGIN
	
		IF nGRESET = '0' THEN
		
			nDSACK <= "ZZ";
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF idesack = '1' THEN
			
				nDSACK <= "01";
				
			ELSIF memsack = '1' THEN
			
				nDSACK <= "00";
				
			ELSIF nIDEACCESS = '0' OR nMEMZ3 = '0' THEN
			
				nDSACK <= "11";
			
			ELSE
			
				nDSACK <= "ZZ";
				
			END IF;
			
		END IF;
		
	END PROCESS;

end Behavioral;

