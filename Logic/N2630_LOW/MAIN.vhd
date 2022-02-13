----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:06:50 02/10/2022 
-- Design Name: 
-- Module Name:    MAIN - Behavioral 
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

entity MAIN is
	Port 
	( 
		nABG : IN STD_LOGIC; --AMIGA BUS GRANT
		nHALT : IN STD_LOGIC; --_HALT SIGNAL
		nRESET : IN STD_LOGIC; --_RESET SIGNAL
		B2000 : IN STD_LOGIC; --IS THIS AN A2000 OR B2000
		MODE68K : IN STD_LOGIC; --ARE WE IN 68000 MODE (DISABLED)
		nABGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
		FC : IN STD_LOGIC_VECTOR ( 2 downto 0 ); --FCn FROM 68030
		EXTSEL : IN STD_LOGIC; --SELECTION INPUT FROM DAUGHTER CARD
		nSTERM : IN STD_LOGIC; --_STERM 68030 SIGNAL (SYNC TERMINATION)
		nASEN : IN STD_LOGIC; --ADDRESS STROBE ENABLE
		A7M : IN STD_LOGIC; --AMIGA 7MHZ CLOCK
		nC1 : IN STD_LOGIC; --AMIGA _C1 CLOCK
		nC3 : IN STD_LOGIC; --AMIGA _C3 CLOCK
		CDAC : IN STD_LOGIC; --AMIGA CDAC CLOCK
		nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
		
		
		P7M : INOUT STD_LOGIC; --7MHZ CLOCK
		n7M : INOUT STD_LOGIC; --7MHZ CLOCK 180 DEGREE		
		nBOSS : INOUT STD_LOGIC; --_BOSS SIGNAL	
		nAAS : INOUT STD_LOGIC; --AMIGA 68000 ADDRESS STROBE
		TRISTATE : INOUT STD_LOGIC; --IF WE DO NOT CONTROL THE BUS THEN TRISTATE
		nBGACK : INOUT STD_LOGIC; --BUS GRANT ACK
		nDTACK : INOUT STD_LOGIC; --DATA TRANSFER ACK
		nCYCEND : INOUT STD_LOGIC; --CYCLE END
		nEXTERN : INOUT STD_LOGIC; --ARE WE ACCESSING EXTERNAL MEMORY OR FPU?
		SCLK : INOUT STD_LOGIC; --STATE MACHINE CLOCK
		nMEMSEL : INOUT STD_LOGIC; --ARE WE SELECTING MEMORY ON BOARD? FIRST 4 (8) MEGABYTES
		SN7MDIS : INOUT STD_LOGIC;
		nS7MDIS : INOUT STD_LOGIC;
		nABR : INOUT STD_LOGIC;
		nONBOARD : INOUT STD_LOGIC;
		nDSACKEN : INOUT STD_LOGIC
			  
	);
end MAIN;

architecture Behavioral of MAIN is

	----------------------
	-- INTERNAL SIGNALS --
	----------------------
	
	--All internal signals are active HIGH!
	SIGNAL as : STD_LOGIC:='0';
	SIGNAL offboard : STD_LOGIC:='0';	
	SIGNAL memaccess : STD_LOGIC:='0'; --NEED TO ADD SOME MEMORY ACCESS LOGIC TO THIS LATER 
	SIGNAL configed : STD_LOGIC:='0'; --NEED TO ADD AUTOCONFIG LOGIC LATER
	SIGNAL cpuspace : STD_LOGIC:= '0'; --Derived from cpustate
	SIGNAL cpustate : STD_LOGIC_VECTOR ( 2 downto 0 ):= (others => '0'); --Derived from FC(2..0)
	SIGNAL basis7m : STD_LOGIC:='0';
	SIGNAL p14m : STD_LOGIC:='0'; --14mhz clock


begin
	
	------------
	-- CLOCKS --
	------------
	
	--Here I define the 7MHz basis clock used to make many other clocks.
	--On the A2620 I used a set of jumpers to let you change the clocking
	--around for A2000 vs. B2000.  Here it's all done based on the B2000 
	--setting jumper.  On a B2000, we gets the 7MHz from the Coprocessor 
	--Slot.  On an A2000, I'll make it from C1 and C3.
		
	basis7m <= '1' WHEN ( B2000 = '1' AND A7M = '1' ) OR ( B2000 = '0' AND (nC1 = '1' OR nC3 = '0' )) ELSE '0';
	
	--The 7MHz clock lines are pretty simple.  I make 'em both here to keep 
	--them consistent with each other and all other clocks derived from the
	--motherboard.

	P7M <= basis7m;
	n7M <= NOT basis7m;
	
	--The 14MHz clock lines are pretty simple too.  I make 'em both here to 
	--keep them consistent with each other and all other clocks derived from 
	--the motherboard.

	p14m <= '1' WHEN basis7m = '1' AND CDAC = '1' ELSE '0';
	--N14M <= '1' WHEN basis7m AND CDAC = '1' ELSE '0';
	
	--This is the state machine clock.  This is basically a 14MHz clock, 
	--but some of it's edges are suppressed.  This lets the 68000 state
	--machine just skip the unimportant clock edges in the 68000 cycle
	--and just concentrate on the interesting edges.
	
	SCLK <= '1' 
		WHEN 
			(CDAC = '1' AND p14m = '1' AND n7M = '0' AND SN7MDIS = '1') OR 
			(CDAC = '0' AND p14m = '1' AND n7M = '1' AND nS7MDIS = '1') 
		ELSE '0';
		
	----------------------------
	-- INTERNAL SIGNAL DEFINE --
	----------------------------
	
	as <= '1' WHEN nASEN = '0' AND nCYCEND = '1' AND nEXTERN = '1' ELSE '0';
	offboard <= '1' WHEN (nONBOARD = '1' OR nMEMSEL = '1' OR nEXTERN = '1') ELSE '0';
	cpuspace <= '1' WHEN cpustate = x"7" ELSE '0';
	cpustate <= FC ( 2 downto 0 );
	
	---------------------
	-- REQUEST THE BUS --
	---------------------	

	--ABR is the Amiga bus request output. This signal is only asserted by 
	--this PAL on powerup in order to get the bus so that we can assert BOSS, 
	--and it won't be asserted if MODE68K is asserted.

	nABR <= '0' 
		WHEN 
			( nRESET = '1' AND nAAS = '0' AND nBOSS = '1' AND MODE68K = '0' ) OR 
			( nRESET = '1' AND nABR = '0' AND nBOSS = '1' AND MODE68K = '0' ) 
		ELSE 'Z';

	-----------------
	-- BECOME BOSS --
	-----------------	
	
	--WE NEED TO BECOME B.O.S.S. (Biomorphic Organisational Systems Supervisor)	
	
	--BOSS is a signal used by the B2000 to hold the 68000 on the main board 
	--in tristate (by using bus request). Our board uses BOSS to indicate that
	--we have control of the universe.  The inverse of BOSS is used as a CPU,
	--MMU and ROM control register reset.  BOSS gets asserted after we request
	--the bus from the 68000 (we wait until it starts it's first memory access
	--after reset) and recieve bus grant and the indication that the 68000 has
	--completed the current cycle.  BOSS gets held true in a latching term until
	--the next cold reset or until 68KMODE is asserted.
	--
	--We wanna be the boss, but we have to be careful.  We're never the boss
	--during a cold reset, or during 68K mode.  We wait after reset for the
	--bus grant from the 68000, then we assert BOSS, if we're a B2000.  We
	--always assert BOSS during a non-reset if we're an A2000.  Finally, we
	--hold BOSS on the B2000 until either a full reset or the 68K mode is
	--activated.

	nBOSS <= '0' 
		WHEN 
			( nABG = '0' AND nAAS ='1' AND nDTACK = '1' AND nHALT = '1' AND nRESET = '1' AND B2000 = '1' AND MODE68K = '0' ) OR 
			(nHALT = '1' AND MODE68K = '0' AND nBOSS = '0' ) OR 
			(nRESET = '1' AND MODE68K = '0' AND nBOSS = '0' ) OR 
			(B2000 = '0' AND nHALT ='1' AND nRESET ='1')
		ELSE
			'1';
			
	--------------------------		
	-- AMIGA ADDRESS STROBE --
	--------------------------
	
	--68000 style address strobe. Again, this only becomes active when the
	--TRISTATE signal is negated and the memory cycle is for an offboard
	--resource. U501

	nAAS <= '0' WHEN as = '1' AND TRISTATE = '0' AND offboard = '1' ELSE 'Z';
	
	--------------
	-- TRISTATE --
	--------------
	
	--TRISTATE is an output used to tristate all signals that go to the 68000
	--bus. This is done on powerup before BOSS is asserted and whenever a DMA
	--device has control of the A2000 Bus.  We want tristate when we're not 
	--BOSS, or when we are BOSS but we're being DMAed. U305

	TRISTATE <= '1' WHEN nBOSS = '1' OR ( nBOSS = '0' AND nBGACK = '0' ) ELSE '0';
	
	-------------------
	-- BUS GRANT ACK --
	-------------------
	
	--We keep ABGACK disconnected from BGACK until we are BOSS. U501

	nBGACK <= nABGACK WHEN nBOSS = '0' ELSE 'Z';
	
	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	--This is the DTACK generator for DMA access to on-board memory.  It
	--waits until we're in a cycle, and then a fixed delay from RAS, to `
	--account for any refresh that must take place. U501

	nDTACK <= '0' WHEN nBGACK = '0' AND nMEMSEL = '0' AND nAAS = '0' AND nSTERM = '0' ELSE '1';

	------------
	-- MEMSEL --
	------------

	--MEMSEL is an output indicating that the address bus matches the address
	--bits in the configuration register if the register is configured.  Note 
	--that EXTERN cycles can only happen during non-DMA conditions, and they 
	--must qualify the CPU driven memory cycles. U305
	
	--HAD TO CHANGE access TO memaccess

	nMEMSEL <= '0' 
		WHEN 
			memaccess = '1' AND configed = '1' AND nAS = '0' AND nEXTERN = '1' AND nBGACK = '1'
		ELSE '1'
			WHEN nBGACK = '1'
		ELSE 'Z';
		
	------------
	-- EXTERN --
	------------
		
	--Here's the EXTERN logic.  The EXTERN signal is used to qualify unusual
	--memory accesses.  There are two kinds, CPU space and daughterboard
	--space.  CPU space is given by the function codes.  Daughterboard space
	--is defined to be a processor access with EXTSEL asserted.  DMA devices 
	--can't get to daughterboard space. U306

	nEXTERN <= '0' WHEN ( cpuspace = '1' AND nBGACK = '1' ) OR ( EXTSEL = '1' AND nBGACK = '1' ) ELSE '1';
	
	---------------
	-- CYCLE END --
	---------------
	
	--This one marks the end of a slow cycle. U505
	
	PROCESS ( SCLK ) BEGIN
		IF RISING_EDGE (SCLK) THEN
			IF nDSACKEN = '1' AND nCYCEND = '1' THEN
				nCYCEND <= '0'; 
			ELSE
				nCYCEND <= '1';
			END IF;
		END IF;
	END PROCESS;

end Behavioral;

