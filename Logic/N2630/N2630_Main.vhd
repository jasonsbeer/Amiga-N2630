----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:25 01/14/2022 
-- Design Name: 
-- Module Name:    N2630_Main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 1.0
-- Revision 0.01 - File Created
-- Additional Comments: 

-- Much of this logic is derived from the PAL equations for the A2630
-- Many thanks to Dave Haynie for making the equations public
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

entity N2630_Main is
    Port ( AH : in  STD_LOGIC_VECTOR (31 downto 16); --68030 Address High Bits
			  AL : in STD_LOGIC_VECTOR (6 downto 0); --68030 Address Low Bits
			  FC : in STD_LOGIC_VECTOR (2 downto 0);
			  SIZ : in STD_LOGIC_VECTOR (1 downto 0);           
			  nAS : in STD_LOGIC;
			  nDS : in STD_LOGIC;
			  R_W : in STD_LOGIC;
			  CLK : in STD_LOGIC; --68030 Clock
			  CDAC, nC1, C3, A7M : in STD_LOGIC; --Clocks from A2000
			  nRESET : in STD_LOGIC;
			  nHALT : in STD_LOGIC;
			  B2000 : in STD_LOGIC;
			  nABGACK : in STD_LOGIC;			  
			  nS7MDIS : in STD_LOGIC;
			  nASEN : in STD_LOGIC;
			  nVPA : in STD_LOGIC;	
			  nCPURESET : in STD_LOGIC;
			  
			  D : inout STD_LOGIC_VECTOR (20 downto 16);
			  DAC : inout STD_LOGIC_VECTOR (31 downto 28);
			  nDTACK : inout STD_LOGIC;			  
			  nABG : inout STD_LOGIC;
			  nABR : inout STD_LOGIC;
			  nBGACK : inout STD_LOGIC:='Z';
			  RAMCONF : inout STD_LOGIC;
			  
			  nAAS : inout STD_LOGIC:='1'; --Amiga (2000) Address Strobe
			  TRISTATE : inout STD_LOGIC:='0';
			  nASDELAY : out STD_LOGIC:='1';
			  nBOSS : inout STD_LOGIC:='1';
			  nCSROM : out  STD_LOGIC:='1';
			  nUUBE : out STD_LOGIC:='1';
			  nUMBE  : out STD_LOGIC:='1';
			  nLMBE : out STD_LOGIC:='1';
			  nLLBE : out STD_LOGIC:='1';
			  nOE0 : out STD_LOGIC:='1';
			  nOE1 : out STD_LOGIC:='1';
			  nWE0 : out STD_LOGIC:='1';
			  nWE1 : out STD_LOGIC:='1';
			  nSTERM : inout STD_LOGIC:='1';
			  ADDIR : out STD_LOGIC:='1';
			  nADDEH : out STD_LOGIC:='1';
			  nADDEL : out STD_LOGIC:='1';
			  CLK7M : inout STD_LOGIC:='0';
			  SCLK : inout STD_LOGIC:='0';
			  nS7MDIS_DFF : out STD_LOGIC:='1';
			  nDSACKEN : inout STD_LOGIC:='1'; --The FF code wants the output inverted, so we are starting in the active state
			  IVMA : inout STD_LOGIC:='1'; --The FF code wants the output inverted, so we are starting in the active state
			  nMEMLOCK : out STD_LOGIC:='1'; --MEMLOCK is used in the state machine
			  nADOEH : out STD_LOGIC:='1'; --Amiga Data Out Enable High
			  nADOEL : out STD_LOGIC:='1' --Amiga Data Out Enable Low
			  
			  );		
			  
end N2630_Main;

architecture Behavioral of N2630_Main is

	SIGNAL autoconfig_done : STD_LOGIC:='0'; --Is the autoconfig process complete?
	SIGNAL BASEADDRESS : STD_LOGIC_VECTOR (3 downto 0); --Probably don't even need this

	SIGNAL TWOMEG : STD_LOGIC:='0'; --Are we in the first 2 megabyte address space?
	SIGNAL FOURMEG : STD_LOGIC:='0'; --Are we in the second 2 megabyte address space?
	SIGNAL EIGHTMEG : STD_LOGIC:='0'; --Aare we in the second 4 megabyte address space

	SIGNAL AUTOCONFIGSPACE : STD_LOGIC:='0';
	SIGNAL n_onboard : STD_LOGIC:='1';
	SIGNAL HIROM : STD_LOGIC:='0';
	SIGNAL LOROM : STD_LOGIC:='0';
	SIGNAL ramclk : STD_LOGIC:='0';
	SIGNAL ROMCLK : STD_LOGIC:='0'; --This qualifies the PHANTOM signals
	SIGNAL n_regreset : STD_LOGIC:='Z'; --FOR U303 flip flop
	
	SIGNAL n_extern : STD_LOGIC:='1'; --Pull low when daughter OR FPU is being accessed
	SIGNAL cycend : STD_LOGIC:='0';
	SIGNAL nDSEN : STD_LOGIC:='1';
	SIGNAL n_edtack : STD_LOGIC:='0'; --The FF code wants the output inverted, so we are starting in the active state
	SIGNAL s_7mdis : STD_LOGIC; 
	
	SIGNAL n_clk7m : STD_LOGIC:='0'; --Inverted 7MHz clock, for consistency for now
	SIGNAL CLK14M : STD_LOGIC:='0'; --14MHz Clock
	SIGNAL basis7m : STD_LOGIC:='0'; --Internal 7MHz Clock
	
	--U303 D FF OUTPUTS
	SIGNAL PHANTOMLO : STD_LOGIC:='0'; --Phantom Low signal related to ROM selection
	SIGNAL PHANTOMHI,ROMCONF,RSTENB,JMODE,MODE68K : STD_LOGIC:='0';
	
	SIGNAL c1c3xor : STD_LOGIC:='0'; --This holds the XOR value for nC1 and C3

begin
	
	--I tried to lay this out in an order that "makes sense" from the time the machine
	--is started/reset...to put operations in order from earliest to latest	
	
	---------------------
	-- GENERAL SIGNALS --
	---------------------

	--These are required for one or more operations in the code below
	
	-- CLOCKS --
	c1c3xor <= nC1 XOR C3;
	
	basis7m <= '1'
		WHEN
			( B2000 = '1' AND A7M = '1' )
			--B2000 & A7M
		OR
			( B2000 = '0' AND c1c3xor = '1')
			--!B2000 & (!C1 $ C3)
		ELSE
			'0';
		
	CLK7M <= basis7m;	--ALSO: SCLK, IPLCLK, N7M		
	n_clk7m <= NOT basis7m; --ALSO: nDSCLK	
	CLK14M <= basis7m XOR CDAC;
	
	--This is the state machine clock.  This is basically a 14MHz clock, 
	--but some of it's edges are suppressed.  This lets the 68000 state
	--machine just skip the unimportant clock edges in the 68000 cycle
	--and just concentrate on the interesting edges.

	SCLK <= '1'
		WHEN
			( CDAC = '1' AND CLK14M = '1' AND CLK7M = '0' AND s_7mdis = '1' )
			--CDAC & P14M & !N7M & SN7MDIS
		OR
			( CDAC = '0' AND CLK14M = '1' AND CLK7M = '1' AND nS7MDIS = '1' )
			--!CDAC & P14M &  N7M & !S7MDIS
		ELSE
			'0';
			
	-- END CLOCKS --
	
	-- Delay Lines --
	
	--TRANSPORT is the keyword for mimicing a delay line
	--The delay lines on the A2630 are 100ns per tap...part A447-0100-02
	nASDELAY <= transport nAS after 100 ns;
	
	
	--TRISTATE is an output used to tristate all signals that go to the 68000
	--bus. This is done on powerup before BOSS is asserted and whenever a DMA
	--device has control of the A2000 Bus.  We want tristate when we're not 
	--BOSS, or when we are BOSS but we're being DMAed. U305
	
	TRISTATE <= '1'
		WHEN
			( nBOSS = '1' )
			--!BOSS
		OR
			( nBOSS = '0' AND nBGACK = '0' )
			--BOSS & BGACK
		ELSE
			'1';	
			
	--Initially, the logic here enabled IVMA during (!A3 & A2 & !A1 & A0 & VPA).
	--This is the proper time to have VMA come out, just about when the 68000 
	--would bring it out, actually slightly sooner since this PAL releases it on
	--the wrong 7M edge.  The main problem with this scheme is that if VPA falls 
	--in the case that's just prior to that enabling term (what I call CASE 3 
	--in my timing), the I/O cycle should be held off until the next E cycle.
	--The 68000 does this, but the above IVMA would run that cycle right away.
	--The fix to this used here moves the IVMA equation up by one clock cycle,
	--assuring that a CASE 3 VPA will be delayed.  This adds a potential problem
	--in that IVMA would is asserted sooner than a 68000 would assert it.  We
	--know this is no problem for 8520 devices, and /VPA driven devices aren't
	--supported under autoconfig, so we should be OK here.
	--
	--VMA = valid memory address
	--VPA = valid peripheral address
  
	--IVMA
	--U506 FF, clocked by A7M
	PROCESS ( A7M ) BEGIN
		IF (RISING_EDGE (A7M)) THEN
			IF (( AL(3 downto 0) = "0000" AND nVPA = '0' ) OR ( IVMA = '0' AND AL(3) = '0' )) THEN
			--!A3 & !A2 & !A1 & !A0 & VPA # !IVMA & !A3
				IVMA <= '0';
			ELSE
				IVMA <= '1';
			END IF;
		END IF;
	END PROCESS;

	--EDTACK
	--This was "!A3 & A2 & A1 & !A0 & !IVMA", but I think that may make
	--the cycle end too early.  So I'm pushing it up by one clock.
	--U506 DFF clocked by A7M

	PROCESS ( A7M ) BEGIN
		IF (RISING_EDGE (A7M)) THEN		
			IF AL( 3 downto 0) = "0111" AND IVMA = '0' THEN	
			--!EDTACK.D	= !A3 & A2 & A1 & A0 & !IVMA
				n_edtack <= '1';
			ELSE
				n_edtack <= '0';
			END IF;
		END IF;
	END PROCESS;		
			
	--nDSACKEN
	--This creates the DSACK go-ahead for all slow, 16 bit cycles.  These are,
	--in order, A2000 DTACK, 68xx/65xx emulation DTACK, and ROM or config
	--register access.
	--U505 DFF, clocked by SCLK
	
	PROCESS ( SCLK ) BEGIN
		IF ( RISING_EDGE(SCLK) ) THEN
			IF ( nDSEN = '1' AND cycend = '1' AND n_extern = '0' AND nDTACK = '0' ) 
				OR ( nDSEN = '1' AND cycend = '1' AND n_extern = '0' AND n_edtack ='0' )
				OR ( nDSEN = '1' AND cycend = '1' AND n_extern = '0' AND n_onboard = '0' ) 
			THEN 
				nDSACKEN <= '0';
			ELSE
				nDSACKEN <= '1';
			END IF;
			
			
--			DSACKEN <= '0'
--			WHEN
--				( nDSen = '1' AND cycend = '1' AND EXTERN = '0' AND nDTACK = '0' )
--				--!DSACKEN.D = !DSEN & CYCEND & !EXTERN &   DTACK
--			OR
--				( nDSen = '1' AND cycend = '1' AND EXTERN = '0' and n_edtack ='0' )
--				--!DSACKEN.D = !DSEN & CYCEND & !EXTERN &  EDTACK
--			OR
--				( nDSen = '1' AND cycend = '1' AND EXTERN = '0' AND n_onboard = '0' )
--				--!DSACKEN.D = !DSEN & CYCEND & !EXTERN & ONBOARD
--			ELSE
--				'1';
		END IF;
	END PROCESS;
				
	--CYCEND				
	--This one marks the end of a slow cycle 
	--U505 DFF clocked by SCLK
	PROCESS ( SCLK ) BEGIN
		IF (RISING_EDGE(SCLK)) THEN
			IF ( nDSACKEN = '1' AND cycend =  '0' ) THEN
			--!CYCEND.D = !DSACKEN & CYCEND
				cycend <= '1';
			ELSE
				cycend <= '0';
			END IF;
			
--			cycend <= '1'
--			WHEN
--				nDSACKEN = '1' AND cycend =  '0'
--				--!CYCEND.D = !DSACKEN & CYCEND
--				--the output is inverted so we look for !cycend here
--			ELSE
--				'0';
		END IF;
	END PROCESS;
	
	
	--nAAS
	--68000 style address strobe. Again, this only becomes active when the
	--TRISTATE signal is negated and the memory cycle is for an offboard
	--resource. Meaning, we want to talk to something on the A2000. U501
	
	PROCESS ( nASEN ) BEGIN
		IF 
			( TRISTATE = '0' AND (n_onboard = '1' OR ( TWOMEG = '0' AND FOURMEG = '0' ) OR n_extern = '1' ))
			--offboard = !(ONBOARD # MEMSEL # EXTERN)
			--.OE = !TRISTATE & offboard
			--This checks to see if we are not in tristate and not addressing a resource on the A2630
			THEN		
				IF
					( nASEN = '0' AND cycend = '0' AND n_extern = '1' )
					--ASEN & !CYCEND & !EXTERN
					THEN
						nAAS <= '0';	
					ELSE
						nAAS <= '1';
				END IF;
			ELSE
				nAAS <= 'Z';				
		END IF;
	END PROCESS;
	
	--MEMLOCK is used to lock out the 68000 state machine during a fast 
	--system cycle, which is basically either an on-board memory cycle
	--or an EXTERN cycle.  Additionally, the 68000 state machine uses
	--this same mechanism to end it's own cycle, so CYCEND also gets
	--included. U305

	nMEMLOCK <= '0' 
		WHEN
			( autoconfig_done = '1' AND ( TWOMEG = '1' OR FOURMEG = '1' ))
			--access & CONFIGED
		OR
			( nAS = '1' )
			--!AS
		OR
			( n_extern = '0' )
			--EXTERN
		OR
			( cycend = '1' )
			--CYCEND
		ELSE
			'1';			
	
	--Here's the EXTERN logic.  The EXTERN signal is used to qualify unusual
	--memory accesses.  There are two kinds, CPU space and daughterboard
	--space.  CPU space is given by the function codes.  Daughterboard space
	--is defined to be a processor access with EXTSEL asserted.  DMA devices 
	--can't get to daughterboard space.

	n_extern <= '0'
		WHEN
			( FC(2 downto 0) = x"7" AND nBGACK = '1' )
			--cpuspace & !BGACK
		--OR
			--EXTSEL & !BGACK
			--EXTSEL comes from the daughter card!
		ELSE
			'1';
			
	--nDSEN
	--Here we enable data strobe to the A2000.  Are we properly considering
	--the R/W line here?  EXTERN qualification included here too. 
	--U505 Clocked by SCLK
	PROCESS ( SCLK ) BEGIN
		IF (RISING_EDGE(SCLK)) THEN
			IF ( nASEN = '0' AND n_extern = '1' AND cycend = '1' ) THEN
				--ASEN & !EXTERN & CYCEND
				nDSen <= '0';
			ELSE
				nDSen <= '1';
			END IF;
		
--			nDSen <= '0'
--			WHEN
--				nASEN = '0' AND n_extern = '1' AND cycend = '1'
--				--ASEN & !EXTERN & CYCEND
--			ELSE
--				'1';
		END IF;
	END PROCESS;
	
	--nS7MDIS_DFF
	--This one disables the rising edge clock.  It's latched externally.
	--I qualify with EXTERN as well, to help make sure this state machine
	--doesn't get started for special cycles.  Since ASEN isn't qualified
	--externally with EXTERN, everywhere here it's used, it must be 
	--qualified with EXTERN too.
	--ORIGINAL PAL U505, FLIP FLOP, CLOCKED BY SCLK, NO RESET. This is the D input of U503

	PROCESS ( SCLK ) BEGIN
		IF (RISING_EDGE (SCLK)) THEN
			IF ( nDSEN = '1' AND nASEN = '0' AND n_extern = '0' AND nDSACKEN = '1' ) THEN
				--nS7MDIS_DFF	= !DSEN & ASEN & !EXTERN & DSACKEN;
				nS7MDIS_DFF <= '0';
			ELSE
				nS7MDIS_DFF <= '1';
			END IF;
--			nS7MDIS_DFF <= '0'
--			WHEN
--				( nDSen = '1' AND nASEN = '0' AND EXTERN = '0' AND nDSACKEN = '1' )
--				--nS7MDIS_DFF	= !DSEN & ASEN & !EXTERN & DSACKEN;
--			ELSE
--				'1';
		END IF;
	END PROCESS;
	
	--This one disables the falling edge clock.  This is similarly qualified
	--with EXTERN.
	--ORIGINAL PAL U505, FLIP FLOP, CLOCKED BY SCLK, NO RESET.
	PROCESS ( SCLK ) BEGIN
		IF (RISING_EDGE (SCLK)) THEN
			IF ( nASEN = '0' AND n_extern = '0' AND cycend = '1' ) THEN
				--S_7MDIS.D = ASEN & !EXTERN & CYCEND;
				s_7mdis <= '0';
			ELSE
				s_7mdis <= '1';
			END IF;
--			s_7mdis <= '0'
--			WHEN
--				nASEN = '0' AND EXTERN = '0' AND cycend = '1'
--				--S_7MDIS.D = ASEN & !EXTERN & CYCEND;
--			ELSE
--				'1';
		END IF;
	END PROCESS;
				

	--ROMCLK U301 PAL
	--THIS IS USED TO CLOCK THE U303 D FLIP FLOP
	ROMCLK <= '1'
		WHEN 
			( R_W = '0' AND nDS = '0' AND nRESET = '1' AND AL(6 downto 1) = x"40" AND autoconfig_done = '0' )
		OR
			( ROMCLK = '1' AND nDS = '0' )
		ELSE
			'0';	


	--RAMCLK U301 PAL
	--THIS IS USED TO CLOCK THE U302 D FLIP FLOP
	ramclk <= '1'
		WHEN
			( R_W = '0' AND nDS = '0' AND nRESET = '1' AND AL(6 downto 1) = x"48" AND ROMCLK = '0' )
			--writecycle & ramaddr & !ROMCLK
		OR
			( nRESET = '1' AND RAMCLK = '1' )
			--!CPURESET & RAMCLK
		ELSE
			'0';
			
			
	--U303 D FF = 74LS174 (triggered on rising edge)
	--THIS IS ONLY USED AT STARTUP TO HELP WITH READING THE ROMs AND SETTING 68K MODE
	--This could be moved to a 74HCT174 later if we fill up the CPLD
	PROCESS (ROMCLK, n_regreset) BEGIN
		IF n_regreset = '0' THEN
			PHANTOMLO <= '0';
			PHANTOMHI <= '0';
			ROMCONF <= '0';
			RSTENB <= '0';
			JMODE <= '0';
			MODE68K <= '0';
		ELSIF RISING_EDGE (ROMCLK) THEN
			PHANTOMLO <= D(16);
			PHANTOMHI <= D(17);
			ROMCONF <= D(18);
			RSTENB <= '1';
			JMODE <= D(19);
			MODE68K <= D(20);
		END IF;
	END PROCESS;
	
	--U302 D FF = 74LS174 (triggered on rising edge)
	PROCESS (ramclk, nCPURESET) BEGIN
		IF nCPURESET = '0' THEN
			RAMCONF <= '0';
		ELSIF RISING_EDGE (RAMCLK) THEN
			RAMCONF <= ROMCONF;
		END IF;	
	END PROCESS;
	
	--n_regreset
	--	This is a special reset used to reset the configuration registers.  If
	-- JMODE (Johann's special mode) is active, we can reset the registers
	-- with the CPU.  Otherwise, the registers can only be reset with a cold
	-- reset asserted.
	--Original PAL U504 (16R6A flip flop, according to data sheet is triggered on rising edge, schematics show falling edge?)

	PROCESS (n_clk7m) BEGIN
		IF (RISING_EDGE(n_clk7m)) THEN 
			IF (( JMODE = '0' AND nHALT = '0' AND nRESET = '0') OR ( JMODE = '1' AND nRESET = '0' )) THEN
				n_regreset <= '0'	;
			ELSE
				n_regreset <= '1'	;
			END IF;
--			n_regreset <= '0'		
--			WHEN
--				( JMODE = '0' AND nHALT = '0' AND nRESET = '0' )
--			OR
--				( JMODE = '1' AND nRESET = '0' )
--			ELSE
--				'1';
		END IF;
	END PROCESS;
			
	-----------------
	-- BECOME BOSS --
	-----------------	
	
	--WE NEED TO BECOME B.O.S.S. (Biomorphic Organisational Systems Supervisor)	
	
	--First, we must request the bus on power up/reset
	--ABR is the Amiga bus request output. This signal is only asserted 
	--on powerup in order to get the bus so that we can assert BOSS, 
	--and it won't be asserted if MODE68K is asserted.	
	
	REQUESTBUS:PROCESS(nRESET, CLK) BEGIN
	
		IF ( MODE68K = '1' OR nBOSS = '0' ) THEN		
			nABR <= '1'; 
			
		ELSIF ( nRESET = '1' AND nBOSS = '1' ) THEN	
			IF (( RISING_EDGE(CLK) AND nAAS = '1' AND MODE68K = '0' )OR	( nABR = '1' AND MODE68K = '0' )) THEN
				nABR <= '0';
			END IF;
		
--			nABR <= '0'
--				WHEN
--					( RISING_EDGE(CLK) AND nAAS = '1' AND MODE68K = '0' )
--				OR
--					( nABR = '1' AND MODE68K = '0' );
		END IF;
		
	END PROCESS REQUESTBUS;
	
	--nBGACK (Bus Grant Acknowledge)
	--We keep nABGACK disconnected from nBGACK until we are BOSS.
	--Original PAL U501
	
	PROCESS(nRESET, CLK) BEGIN
		IF nBOSS = '1' THEN
			nBGACK <= 'Z';
		ELSE
			nBGACK <= nABGACK;
		END IF;
	END PROCESS;
	
	--nDTACK
	--This is the DTACK generator for DMA access to on-board memory.  It
	--waits until we're in a cycle, and then a fixed delay from RAS, to `
	--account for any refresh that must take place.	
	--Original PAL U501
	--We don't need a RAS delay...cause we're using SRAM

	nDTACK <= '0'
		WHEN
			--nDTACK = BGACK & MEMSEL & AAS & STERM;
			nBGACK = '0' AND nAS = '0' AND nSTERM = '0' AND (TWOMEG = '1' OR FOURMEG = '1')
		ELSE
			'1';
		
	--BOSS is a signal used by the B2000 to hold the 68000 on the main board 
	--in tristate (by using bus request). Our board uses BOSS to indicate that
	--we have control of the universe.  The inverse of BOSS is used as a CPU,
	--MMU and ROM control register reset.  BOSS gets asserted after we request
	--the bus from the 68000 (we wait until it starts it's first memory access
	--after reset) and recieve bus grant and the indication that the 68000 has
	--completed the current cycle.  BOSS gets held true in a latching term until
	--the next cold reset or until 68KMODE is asserted.	
	
	--We wanna be the boss, but we have to be careful.  We're never the boss
	--during a cold reset, or during 68K mode.  We wait after reset for the
	--bus grant from the 68000, then we assert BOSS, if we're a B2000.  We
	--always assert BOSS during a non-reset if we're an A2000.  Finally, we
	--hold BOSS on the B2000 until either a full reset or the 68K mode is
	--activated.
	--ORIGINAL PAL U504
	
	--not a flip flop
	BOSS:PROCESS(nRESET, CLK) BEGIN
	
		IF nBOSS = '1' THEN	
			IF (( RISING_EDGE(CLK) AND nAAS = '1' AND nABG = '0' AND nDTACK = '1' 
				AND nHALT = '1' AND nRESET = '1' AND B2000 = '1' AND MODE68K = '0' )
				OR ( nHALT = '1' AND MODE68K = '0' )
				OR	( nRESET = '1' AND MODE68K = '0' )
				OR	( B2000 = '0' AND nHALT = '1' AND nRESET = '1' )) --This is for the original A2000
			THEN
				nBOSS <= '0';
			ELSE
				nBOSS <= '1';
					
--			nBOSS <= '0' 				
--				WHEN 
--					( RISING_EDGE(CLK) AND nAAS = '1' AND nABG = '0' AND nDTACK = '1' 
--					AND HALT = '1' AND nRESET = '1' AND B2000 = '1' AND MODE68K = '0' )
--					--nABG = 0 means the Amiga is trying to grant us the bus
--				OR
--					( nHALT = '1' AND MODE68K = '0' )
--				OR
--					( nRESET = '1' AND MODE68K = '0' )
--				OR
--					( B2000 = '0' AND HALT = '1' AND nRESET = '1' ) --This is for the original A2000
--				ELSE
--					'1'; 
					
			END IF;
		END IF;			
	END PROCESS BOSS;	

	----------------
	-- AUTOCONFIG --
	----------------

	--We have two boards we need to autoconfig
	--1. The 68030 with base memory (up to 8MB) without BOOT ROM in the Zorro 2 space
	--2. The expansion memory (up to 112MB) in the Zorro 3 space

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition
	
	--ARE WE IN THE AUTOCONFIG ADDRESS SPACE?
	PROCESS (nAS) BEGIN
		IF 
			AH(23 downto 16) = x"E8" AND nAS = '0' 
		THEN
			AUTOCONFIGSPACE <= '1';
		ELSE
			AUTOCONFIGSPACE <= '0';
		END IF;
	END PROCESS;	

	AUTOCONFIG : PROCESS (CLK, nRESET)
		BEGIN
		
		IF nRESET = '0' THEN
			--THE COMPUTER IS IN RESET
			--PUT THE AUTOCONFIG SETTINGS BACK TO NOT CONFIGURED
			autoconfig_done <= '0';
			BASEADDRESS <= x"0";
		
		ELSIF RISING_EDGE(CLK) AND autoconfig_done = '0' THEN
			IF ( AUTOCONFIGSPACE = '1' AND R_W = '1') THEN
				--THIS IS THE AUTOCONFIG BASE ADDRESS
				
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
				
			--Is this one our base address?
			ELSIF (R_W = '0' AND nDS = '0' AND nAS = '0' AND autoconfig_done = '0') THEN
			
				IF ( AL(6 downto 1) = x"48" ) THEN
					--I DON'T KNOW WHAT TO DO WITH THIS...WE PROBABLY DON'T NEED IT
					BASEADDRESS <= DAC(31 downto 28); --This is written to our device from the Amiga
					autoconfig_done <= '1'; --Autoconfig process is done!
				END IF;
			
			END IF;
					
		END IF;	

	END PROCESS AUTOCONFIG;
	
	----------------
	-- ROM ENABLE --
	----------------

	--WE NEED TO SUPPLY A ROM ENABLE SIGNAL WHEN THE ADDRESS
	--SPACE IS LOOKING IN THE AREA THE ROM NORMALLY OCCUPIES
	--Original PAL: U304
	
	HIROM <= '1'
		WHEN
			AH(23 downto 16) >= x"f80000" AND AH(23 downto 16) <= x"f8ffff"
		ELSE
			'0';
			
	LOROM <= '1'
		WHEN
			AH(23 downto 16) >= x"000000" AND AH(23 downto 16) <= x"00ffff"
		ELSE
			'0';

	ROM_ENABLE:PROCESS( nAS ) BEGIN

		IF (R_W = '1' AND nAS = '0') THEN
			--This is a read cycle
			IF (HIROM = '1' AND PHANTOMHI = '0') THEN 
				--High memory rom space, where ROMs normally reside when available.
				nCSROM <= '0';
			ELSIF ( LOROM = '1' AND PHANTOMLO = '0') THEN 
				--Low memory ROM space, used for mapping of ROMs on reset.
				nCSROM <= '0';		
			ELSE
				--We are not in the ROM address spaces
				nCSROM <= '1';
			END IF;
		ELSE
			--We are not in a read cycle
			nCSROM <= '1';
		END IF;

	END PROCESS ROM_ENABLE;

	---------------
	-- RAM STUFF --
	---------------

	--THIS DETERMINES IF WE ARE IN THE FIRST OR SECOND 2 MEGS OF ADDRESS SPACE
	--THIS IS ALL IN SECTION 12 OF THE 68030 MANUAL
	
	TWOMEG <= '1' 
		WHEN
			AH(31 downto 21) = "01000000000" --A21 IS LOW IN THE FIRST 2 MEGS
		ELSE
			'0';
			
	FOURMEG <= '1'
		WHEN
			AH(31 downto 21) = "01000000001" --A21 IS HIGH IN THE SECOND 2 MEGS
		ELSE
			'0';	
			
--	EIGHTMEG <= '1'
--		WHEN
--			AH(31 downto 22) = "0100000001" --A22 IS HIGH IN THE SECOND 4 MEGS
--		ELSE
--			'0';

	--THIS IS THE RAM IN THE ZORRO 2 SPACE (UP TO 8 MEGABYTES)
	--WE DIRECT THE RAM SIGNALING BASED ON WHAT THE 68030 IS ASKING FOR
	--THIS IS A 32 BIT PORT WITH NO WAIT STATES
	--Original PAL: Multiple

	--The basic process goes like this:
	--68030: drive A31:0, drive FC2:0, drive SIZ1:0, Set R_W, assert nAS, drive D31:0 (for write), assert nDS (for write)
	--A2630: decode address and store/provide data on D31:0, assert nSTERM
	--68030: Negate nAS and nDS
	--A2630: Negate nSTERM

	--the values in the process statement will trigger the process when one of them changes

	RAM_ACCESS:PROCESS ( nAS, R_W, nDS ) BEGIN

		IF (autoconfig_done = '1' AND FC(2 downto 0) /= x"7" AND nAS = '0' AND nDS = '0') THEN
			--$7 = CPU SPACE...we do not want to interject ourselves when the CPU is taking care of it's own business		
			
			--ENABLE THE VARIOUS BYTES ON THE SRAM DEPENDING ON WHAT THE CPU IS ASKING FOR
			
			--UPPER UPPER BYTE ENABLE (D31..24)
			IF (( R_W = '1' ) 
				OR (R_W = '0' AND AL(1 downto 0) = "00")) 
			THEN			
				nUUBE <= '0'; 
			ELSE 
				nUUBE <= '1';
			END IF;
			
			--UPPER MIDDLE BYTE (D23..16)
			IF (( R_W = '1' ) 
				OR ( R_W = '0' AND (( AL(1 downto 0) = "01" )
				OR ( AL(1) = '0' AND SIZ(0) = '0' ) 
				OR ( AL(1) = '0' AND SIZ(1) = '1' )))) 
			THEN
				nUMBE <= '0';
			ELSE
				nUMBE <= '1';
			END IF;
			
			--LOWER MIDDLE BYTE (D15..8)
			IF (( R_W = '1' )
				OR ( R_W = '0' AND (( AL(1 downto 0) = "10" ) 
				OR ( AL(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0' ) 
				OR	( AL(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1' ) 
				OR ( AL(0) = '1' AND AL(1) = '0' AND SIZ(0) = '0' ))))
			THEN
				nLMBE <= '0';
			ELSE
				nLMBE <= '1';
			END IF;
				
			--LOWER LOWER BYTE (D7..0)
			IF (( R_W = '1' )
				OR	( R_W = '0' AND ( AL(1 downto 0) = "11" 
				OR (AL(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1') 
				OR	(SIZ(0) = '0' AND SIZ(1) = '0') 
				OR	(AL(1) = '1' AND SIZ(1) ='1'))))
			THEN
				nLLBE <= '0';
			ELSE
				nLLBE <= '1';
			END IF;
				
				
			--OUTPUT ENABLE OR WRITE ENABLE DEPENDING ON THE CPU REQUEST
			IF R_W = '1' AND TWOMEG = '1' THEN			
				nOE0 <= '0'; --BANK0
			ELSE
				nOE0 <= '1';
			END IF;
			
			IF R_W = '1' AND FOURMEG = '1' THEN
				nOE1 <= '0'; -- BANK1
			ELSE
				nOE1 <= '1';
			END IF;
			
			IF R_W = '0' AND TWOMEG = '1' THEN
				nWE0 <= '0'; -- BANK0
			ELSE
				nWE0 <= '1';
			END IF;
				
			IF R_W = '0' AND FOURMEG = '1' THEN
				nWE1 <= '0'; -- BANK1
			ELSE
				nWE1 <= '1';
			END IF;
			
			--NEED TO FIGURE OUT HOW TO DEAL WITH DSACK FOR 16 BIT TRANSFERS FROM A2000
				
			--nSTERM = Bus response signal that indicates a port size of 32 bits and
			--that data may be latched on the next falling clock edge. Synchronous transfer.
			--STERM is only used on the daughterboard of the A2630. The A2630 card uses DSACKx for terminiation.
			--We should be OK here as we are using fast SRAM and can use the 2 clock cycle read/write
			IF TWOMEG = '1' OR FOURMEG = '1' THEN
				nSTERM <= '0';
			ELSE
				nSTERM <= '1';
			END IF;
				
					
			--ecs (EXTERNAL CYCLE START) HOW DOES THAT FIT IN? it doesn't
			
			--DSACK0 AND 1 GO IN HERE SOMEWHERE (PORT SIZE ACK) these are for asynchronise data transfer
			--since dsackx is only used in asynchronise transfers, I don't think we need it here?
			--We are using STERM and only doing synchronous transfers cuz the sram is fast enough to handle the transfer in 2 clock cycles
			--Anyhow, put DASCKx both low to indicate 32 bit port transfer terminiation (transfer is complete)
			
			--CACHE GOES IN HERE SOMEWHERE
			--_CBREQ _CBACK WE ARE NOT USING ANY CACHE MEMORY
			--DBEN external data buffers - not needed
			
		ELSE 
			--DEACTIVATE ALL THE RAM STUFF
			nSTERM <= '1';
			
			nUUBE <= '1';
			nUMBE <= '1';
			nLMBE <= '1';
			nLLBE <= '1';
			
			nOE0 <= '1';
			nOE1 <= '1';
			nWE0 <= '1';
			nWE1 <= '1';	
			
		END IF;		

	END PROCESS RAM_ACCESS;
	
	----------------------------
	-- DATA BUS DIRECTION --
	----------------------------
	
	--Original PAL U500
	--We need to point the data lines in the correct direction, 
	--but also convert between 16 and 32 bit when talking to the A2000
	
	--This is data direction control

	ADDIR	<= '1'
		WHEN
			( nBGACK = '0' AND R_W = '0' )
		OR
			( nBGACK = '1' AND R_W = '1' )
		ELSE
			'0';

	--This handles the data buffer enable, including the 16 to 32 bit data
	--bus conversion required for DMA cycles.
	
	--ARE WE TRYING TO ACCESS SOMETHING ON THE A2630?	
	--LOOKS TO BE ONLY AT STARTUP AS THIS ONLY CONSIDERS ROM ACCESS OR AUTOCONFIG
	--ALSO USED WHEN THE A2630 WANTS TO TALK TO SOMETHING ON THE A2000
	n_onboard <= '0'
		WHEN
			( HIROM = '1' AND PHANTOMHI = '0' AND R_W = '0' AND nAS = '0' )
		OR
			( LOROM = '1' AND PHANTOMLO = '0'  AND R_W = '0' AND nAS = '0' )
		OR
			( AUTOCONFIGSPACE = '1' AND nAS ='0' AND RAMCONF = '0' )
			--iscauto = autocon & AS & !RAMCONF &  AUTO 
		OR
			( AUTOCONFIGSPACE = '1' AND nAS ='0' AND ROMCONF = '0' )
			--ICSAUTO (OR) autocon & AS & !ROMCONF & !AUTO
			--AUTO = should I autoconfig? Yes, always autoconfig, so we don't include that
		OR
			( n_onboard = '0' AND nAS ='0' )
		ELSE
			'1';

	--_ADOEH = ENABLE D(31..16)
	nADOEH <= '0'
		WHEN
			( nBOSS = '0' AND nBGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND nAAS = '0' AND AL(1) = '0' )
			--BOSS &  BGACK &  MEMSEL & AAS & !A1
		OR
			( nBOSS = '0' AND nBGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND nAAS = '0' AND n_onboard = '1' )
			--BOSS & !BGACK & !MEMSEL &  AS & !ONBOARD & !EXTERN;
			--EXTERN tells us if we are accessing expansion memory...not doing that right now
		ELSE
			'1';
			
	--_ADOEL = ENABLE D(15..0)
	nADOEL <= '0'
		WHEN 
			( nBOSS = '0' AND nBGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND nAAS = '0' AND AL(1) = '1' )
			-- BOSS &  BGACK &  MEMSEL & AAS &  A1
		ELSE
		'1';

end Behavioral;

