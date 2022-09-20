--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:16:39 08/26/2022
-- Design Name:   
-- Module Name:   /mnt/work/amiga/Peripherals/A2630/Recreate/Logic/U600/TEST.vhd
-- Project Name:  U600
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: U600
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TEST IS
END TEST;
 
ARCHITECTURE behavior OF TEST IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT U600
    PORT(
         A7M : IN  std_logic;
         CDAC : IN  std_logic;
         REFACKZ3 : IN  std_logic;
         REFACKZ2 : IN  std_logic;
         CPUCLK : IN  std_logic;
         nVPA : IN  std_logic;
         B2000 : IN  std_logic;
         nHALT : IN  std_logic;
         MODE68K : IN  std_logic;
         nDTACK : IN  std_logic;
         nABGACK : IN  std_logic;
         nMEMZ2 : IN  std_logic;
         A : IN  std_logic_vector(1 downto 0);
         SIZ : IN  std_logic_vector(1 downto 0);
         FC : IN  std_logic_vector(2 downto 0);
         SMDIS : IN  std_logic;
         nCPURESET : IN  std_logic;
         nSTERM : IN  std_logic;
         nC1 : IN  std_logic;
         nC3 : IN  std_logic;
         nBERR : IN  std_logic;
         nAS : INOUT  std_logic;
         nABR : INOUT  std_logic;
         nBOSS : INOUT  std_logic;
         REF : INOUT  std_logic;
         E : INOUT  std_logic;
         nVMA : INOUT  std_logic;
         nAAS : INOUT  std_logic;
         RnW : INOUT  std_logic;
         TRISTATE : INOUT  std_logic;
         ARnW : INOUT  std_logic;
         nDSACK1 : INOUT  std_logic;
         nBGACK : INOUT  std_logic;
         nRESET : INOUT  std_logic;
         nABG : INOUT  std_logic;
         nBG : INOUT  std_logic;
         ADDIR : OUT  std_logic;
         IPLCLK : OUT  std_logic;
         DRSEL : OUT  std_logic;
         nADOEL : OUT  std_logic;
         nADOEH : OUT  std_logic;
         nLDS : OUT  std_logic;
         nUDS : OUT  std_logic;
         nBR : OUT  std_logic;
         nCLK7 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A7M : std_logic := '0';
   signal CDAC : std_logic := '0';
   signal REFACKZ3 : std_logic := '0';
   signal REFACKZ2 : std_logic := '0';
   signal CPUCLK : std_logic := '0';
   signal nVPA : std_logic := '0';
   signal B2000 : std_logic := '0';
   signal nHALT : std_logic := '0';
   signal MODE68K : std_logic := '0';
   signal nDTACK : std_logic := '0';
   signal nABGACK : std_logic := '0';
   signal nMEMZ2 : std_logic := '0';
   signal A : std_logic_vector(1 downto 0) := (others => '0');
   signal SIZ : std_logic_vector(1 downto 0) := (others => '0');
   signal FC : std_logic_vector(2 downto 0) := (others => '0');
   signal SMDIS : std_logic := '0';
   signal nCPURESET : std_logic := '0';
   signal nSTERM : std_logic := '0';
   signal nC1 : std_logic := '0';
   signal nC3 : std_logic := '0';
   signal nBERR : std_logic := '0';

	--BiDirs
   signal nAS : std_logic;
   signal nABR : std_logic;
   signal nBOSS : std_logic;
   signal REF : std_logic;
   signal E : std_logic;
   signal nVMA : std_logic;
   signal nAAS : std_logic;
   signal RnW : std_logic;
   signal TRISTATE : std_logic;
   signal ARnW : std_logic;
   signal nDSACK1 : std_logic;
   signal nBGACK : std_logic;
   signal nRESET : std_logic;
   signal nABG : std_logic;
   signal nBG : std_logic;

 	--Outputs
   signal ADDIR : std_logic;
   signal IPLCLK : std_logic;
   signal DRSEL : std_logic;
   signal nADOEL : std_logic;
   signal nADOEH : std_logic;
   signal nLDS : std_logic;
   signal nUDS : std_logic;
   signal nBR : std_logic;
   signal nCLK7 : std_logic;
	
	SIGNAL CLK14 : STD_LOGIC;

   -- Clock period definitions
   constant CPUCLK_period : time := 40 ns;
   constant A7M_period : time := 139 ns;
	constant CDAC_period : time := 139 ns;
	constant E_period : time := 1390 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: U600 PORT MAP (
          A7M => A7M,
          CDAC => CDAC,
			 CPUCLK => CPUCLK,
          REFACKZ3 => REFACKZ3,
          REFACKZ2 => REFACKZ2,          
          nVPA => nVPA,
          B2000 => B2000,
          nHALT => nHALT,
          MODE68K => MODE68K,
          nDTACK => nDTACK,
          nABGACK => nABGACK,
          nMEMZ2 => nMEMZ2,
          A => A,
          SIZ => SIZ,
          FC => FC,
          SMDIS => SMDIS,
          nCPURESET => nCPURESET,
          nSTERM => nSTERM,
          nC1 => nC1,
          nC3 => nC3,
          nBERR => nBERR,
          nAS => nAS,
          nABR => nABR,
          nBOSS => nBOSS,
          REF => REF,
          E => E,
          nVMA => nVMA,
          nAAS => nAAS,
          RnW => RnW,
          TRISTATE => TRISTATE,
          ARnW => ARnW,
          nDSACK1 => nDSACK1,
          nBGACK => nBGACK,
          nRESET => nRESET,
          nABG => nABG,
          nBG => nBG,
          ADDIR => ADDIR,
          IPLCLK => IPLCLK,
          DRSEL => DRSEL,
          nADOEL => nADOEL,
          nADOEH => nADOEH,
          nLDS => nLDS,
          nUDS => nUDS,
          nBR => nBR,
          nCLK7 => nCLK7
        );
		  
  CLK14 <= A7M XOR CDAC;
  

   -- Clock process definitions
	E_process:process
	begin
		E <= '0';
		wait for E_period/6;
		E <= '1';
		wait for E_period/4;
	end process;
	
   CPUCLK_process :process
   begin
		CPUCLK <= '0';
		wait for CPUCLK_period/2;
		CPUCLK <= '1';
		wait for CPUCLK_period/2;
   end process;
 
   A7MCLK_process :process
   begin
		A7M <= '0';
		wait for A7M_period/2;
		A7M<= '1';
		wait for A7M_period/2;
   end process;

   CDAC_process :process
   begin
		CDAC <= '0' after 35ns;
		wait for CDAC_period/2;
		CDAC <= '1' after 35ns;
		wait for CDAC_period/2;
   end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CPUCLK_period*10;

      -- insert stimulus here 
		

      wait;
   end process;

END;
