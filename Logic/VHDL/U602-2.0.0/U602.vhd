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
-- Create Date:    January 21, 2023
-- Design Name:    N2630 U602 CPLD
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES 50MHz LOGIC FOR ZORRO 3 SDRAM CONTROLLER AND IDE CONTROLLER
--
-- Hardware Revision: 3.x/4.x
-- Revision History:
--    v1.0.0 21-JAN-2023 Initial Production Release - JN
--    v1.1.0 11-OCT-2023 Fixed IDE Interrupt Handling Related To Ariadne. -JN
--                       Fixed IDE Disable Jumper -JN
--    V1.1.1 26-OCT-2023 Fixed Gayle register after soft reset. -JN
--    v2.0.0 07-DEC-2023 Replaced Gayle IDE with LIDE.DEVICE. -JN
--                       LIDE.device from LIV2 : https://github.com/LIV2/lide.device
--                       Added PIO 0, 2, 4, and SanDisk timing modes. -JN
--                       Added burst cache mode to Zorro 3 RAM. -JN
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
		nAS : IN STD_LOGIC;
		nRESET : IN STD_LOGIC;
		CPUCLK : IN STD_LOGIC;
		RnW : IN STD_LOGIC;
		FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0);

		--IDE SIGNALS
		IDE_PIO : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		nIDEACCESS : INOUT STD_LOGIC;
		nDIOW : OUT STD_LOGIC;
		nDIOR : OUT STD_LOGIC;
		nCS0 : INOUT STD_LOGIC;
		nCS1 : INOUT STD_LOGIC;
		DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		nIDERST : OUT STD_LOGIC;
		IDEDIR : OUT STD_LOGIC;
		nDSACK1 : OUT STD_LOGIC;
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
		nEMCS1 : OUT STD_LOGIC; --CHIP SELECT HIGH BANK
		nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
		nSTERM : OUT STD_LOGIC; --68030 SYNCRONOUS TERMINATION SIGNAL
		nCBACK : OUT STD_LOGIC --68030 CACHE BURST ACK
	
	);

end U602;

architecture Behavioral of U602 is

	SIGNAL idesack : STD_LOGIC;
	SIGNAL memsack : STD_LOGIC;
	SIGNAL cpu_space : STD_LOGIC;
	SIGNAL dsackcount : INTEGER RANGE 0 TO 7;
	SIGNAL mBURST_CYCLE : STD_LOGIC;

begin

	------------------------------------
	-- INSTANTIATE THE IDE CONTROLLER --
	------------------------------------

	IDE: entity work.IDE 
		PORT MAP(
			A => A(23 DOWNTO 2),
			nAS => nAS,
			nRESET => nRESET,
			CPUCLK => CPUCLK,
			RnW => RnW,
			nIDEACCESS => nIDEACCESS,
			IDE_PIO => IDE_PIO,
			nDIOW => nDIOW,
			nDIOR => nDIOR,
			nCS0 => nCS0,
			nCS1 => nCS1,
			DA => DA,
			nIDERST => nIDERST,
			IDEDIR => IDEDIR,
			DSACK => idesack,
			nIDEEN => nIDEEN
			
		);
		
	-----------------------------------------------
	-- INSTANTIATE THE ZORRO 3 MEMORY CONTROLLER --
	-----------------------------------------------
	
	ZORROMEM: entity work.ZORROMEM 
		PORT MAP(
			A => A,
			RnW => RnW,
			nAS => nAS,
			CPUCLK => CPUCLK,
			A7M => A7M,
			nRESET => nRESET,
			SIZ => SIZ,
			RAMSIZE => RAMSIZE,
			nCBREQ => nCBREQ,
			nMEMZ3 => nMEMZ3,
			BURST_CYCLE => mBURST_CYCLE,
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
			nEMCS1 => nEMCS1,
			CPU_SPACE => cpu_space
		);
		
	-----------------------
	-- CPU SPACE DECODER --
	-----------------------
	
	cpu_space <= '1' WHEN FC(2 downto 0) = "111" ELSE '0';

	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	 PROCESS (CPUCLK, nAS, nRESET) BEGIN
	
		IF nAS = '1' OR nRESET = '0' THEN
		
			dsackcount <= 0;
			nCBACK <= '1';
			nDSACK1 <= 'Z';
			nSTERM <= 'Z';
			
		ELSIF RISING_EDGE (CPUCLK) THEN
			
			IF nMEMZ3 = '0' OR nIDEACCESS = '0' THEN		
					
				CASE dsackcount IS
				
					WHEN 0 =>
					
						IF memsack = '1' OR idesack = '1' THEN
						
							dsackcount <= 1;
							
							IF memsack = '1' THEN
								nSTERM <= '0';
								nCBACK <= '0';
							ELSE  
								nDSACK1 <= '0';
							END IF;
							
						ELSE
						
							nDSACK1 <= '1';
							nSTERM <= '1';
							
						END IF;
						
					WHEN 1 =>
					
						nSTERM <= mBURST_CYCLE;
						dsackcount <= 2;
						
					WHEN 2 =>
					
						nDSACK1 <= '1'; --END OF IDE CYCLE.
						
						IF mBURST_CYCLE = '0' THEN --END OF NON-BURST MEMORY CYCLE.
							nSTERM <= '1';
							nCBACK <= '1';
						ELSE
							nSTERM <= '0'; --CONTINUE BURST MEMORY CYCLE.
							dsackcount <= 3;
						END IF;
						
					WHEN 3 =>
					
						nSTERM <= '1';
						dsackcount <= 4;
						
					WHEN 4 =>
					
						nSTERM <= '0';
						dsackcount <= 5;
						
					WHEN 5 =>
					
						nSTERM <= '1';
						nCBACK <= '1';
						dsackcount <= 6;
						
					WHEN 6 =>
					
						nSTERM <= '0';
						dsackcount <= 7;
						
					when 7 =>
					
						nSTERM <= '1';
					
				END CASE;					
				
			ELSE
			
				nDSACK1 <= 'Z';
				nSTERM <= 'Z';
				
			END IF;
			
		END IF;	
	
	END PROCESS;			

end Behavioral;

