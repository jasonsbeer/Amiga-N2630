----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:17:16 01/10/2022 
-- Design Name: 
-- Module Name:    RAM_Controller_Main - Behavioral 
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

entity RAM_Controller_Main is
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
			  D : inout STD_LOGIC_VECTOR (3 downto 0);
           MA : out  STD_LOGIC_VECTOR (12 downto 0);
           FC : in  STD_LOGIC_VECTOR (2 downto 0);
           CPUCLK : in  STD_LOGIC;
           _DBEN : in  STD_LOGIC;
           _AS : in  STD_LOGIC;
           _DS : in  STD_LOGIC;
           _BGACK : out  STD_LOGIC;
           _CBREQ : in  STD_LOGIC;
           _CBACK : out  STD_LOGIC;
           _BERR : out  STD_LOGIC;
           _GRESET : in  STD_LOGIC;
           SIZ0 : in  STD_LOGIC;
           SIZ1 : in  STD_LOGIC;
           _DSACK0 : out  STD_LOGIC;
           _DSACK1 : out  STD_LOGIC;
           _STERM : out  STD_LOGIC);
end RAM_Controller_Main;

architecture Behavioral of RAM_Controller_Main is

SIGNAL AUTOCONF: STD_LOGIC:='0'; --Somewhere to hold autoconfig mode boolean
SIGNAL AUTOCONFCOMP: STD_LOGIC_VECTOR(1 DOWNTO 0):="00"; --Autoconfig complete signal

begin

--Is the AMIGA in autoconfig mode?
--We know by checking for address $E80000 on the bus
AC_ADDRESS:PROCESS(CPUCLK, _GRESET) BEGIN
	IF(_GRESET = '0') THEN --The Amiga has been reset, start from scratch
		AUTOCONF <= '0';
	ELSIF(FALLING_EDGE(CPUCLK)) THEN --CHECK FOR ADDRESS ON FALLING CLOCK EDGE
		IF(A(31 DOWNTO 16) = x"00E8" AND AUTOCONFCOMP /="11") THEN
		
			--THE Z3 MANUAL SAYS TO LOOK AT A31:24???
		
			AUTOCONF <= '1';
		ELSE
			AUTOCONF <= '0';
		END IF;
	END IF;
END PROCESS AC_ADDRESS;
		

AUTOCONF:PROCESS (CPUCLK, _GRESET) BEGIN
--Process: AUTOCONFIG
--SIGNALS USED: 
--CPUCLK = the system clock
--_GRESET = the A2630 global reset signal

--The autoconfig process begins anew at each system reset
--Autoconfig is accomplished by the Amiga polling the card, responses can be supplied by logic or ROM.
--We're using logic in this case, of course.
--The responses are supplied as nibbles. See the Amiga Developer's Reference Guide.

	IF (_GRESET = '0') THEN --The Amiga has been reset (this includes power on)
	
		--NIB0 <= "1111"; --Here are two nibbles!
		--NIB1 <= "1111";
		
		--SHUTUP <= "11"; --Our card supports shut up

	ELSIF RISING_EDGE(CPUCLK) THEN
		--Autoconfig base mem location is $E80000
		--The address bus will increment by the offsets from the base address defined in the Amiga Dev Guide
		--Look for those offsets of interest on the Address bus and respond
		CASE A(6 DOWNTO 0) IS
			WHEN "0000000" => --PIC TYPE OFFSET $00
				D <= "1010"; --Zorro 3 Memory Card, No Boot ROM
				
			WHEN "0000010" => --PIC SIZE OFFSET $02
				D <= "0010"; --Not related to next logic device, set a base mem size (64MB), which will be modified anyhow (see bit 5 above)
				
			WHEN "0000100" => --Device product number. OFFSET $04. INVERTED.			 
				D <= "1111"; --this is just made up for now
				
			WHEN "0001000" => --er_Flags. OFFSET $08. INVERTED.
				D <= "1011"; -- Zorro 3 Card, can be shut up, Extended Memory Size, Memory Device
				
			WHEN "0001010" => --er_Flags. OFFSET $0A. INVERTED.
				D <= "1000"; --Autosized by OS
				
			WHEN "0010000" => --Manufacturer ID. OFFSET $10
				
			
				
		END CASE;
	END IF;
END PROCESS AUTOCONF;
		
		--NOW THAT WE HAVE SET OUR AUTOCONFIG NIBBLES IN RESPONSE TO THE OFFSET, SEND THEM TO THE AMIGA!
		--THE ADDRESS STROBE NEEDS TO BE LOW AND _RW NEEDS TO BE LOW (WRITE) AND WE ARE IN AUTOCONFIG MODE
		--IF(_AS = '0' AND R_W = '0' AND AUTOCONF = '1') THEN
				
				
		
	
	

end Behavioral;

