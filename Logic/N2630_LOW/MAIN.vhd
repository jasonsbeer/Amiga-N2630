----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       JASON NEUS
-- 
-- Create Date:    20:06:50 02/10/2022 
-- Design Name:    N2630 U600 CPLD
-- Module Name:    MAIN - Behavioral 
-- Project Name:   N2630
-- Target Devices: XC9572 64 PIN
-- Tool versions: 
-- Description:    LOGIC EQUATIONS FOR THE "LOW" CPLD
--
-- Dependencies: 
--
-- Revision: 0.0
-- Revision 0.01 - File Created
-- Additional Comments: MUCH OF THIS LOGIC AND COMMENTS ARE TRANSLATED FROM THE PAL LOGIC FROM DAVE HAYNIE 
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

entity MAIN is
	Port 
	( 
		--60 pins used
		A1 : IN STD_LOGIC; --ADDRESS LINE 1
		nABG : IN STD_LOGIC; --AMIGA BUS GRANT
		nHALT : IN STD_LOGIC; --_HALT SIGNAL
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
		ARnW : IN STD_LOGIC; --68000 READ/WRITE
		nVPA : IN STD_LOGIC; --68000 VALID PERIPHERAL ADDRESS
		JMODE : IN STD_LOGIC; --JOHANN'S SPECIAL MODE! WHO IS JOHANN AND WHY DOES HE GET HIS OWN MODE? LUCKY!
		MEMACCESS : IN STD_LOGIC; --WE ARE ACCESSING ON BOARD MEMORY
		CONFIGED : IN STD_LOGIC; --IS AUTOCONFIG COMPLETE?
		RSTENB : IN STD_LOGIC; -- RESET ENABLED
		nCPURESET : IN STD_LOGIC; --THE 68030 RESET SIGNAL
		CPUCLK : IN STD_LOGIC; --68030 CLOCK
		nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
		nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE		
		nONBOARD : IN STD_LOGIC; --ARE WE USING RESOURCES ON THE 2630?
		nS7MDIS : IN STD_LOGIC; --STATE MACHINE OUTPUT FROM U503		
		
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
		nABR : INOUT STD_LOGIC; -- AMIGA BUS REQUEST
		nDSACKEN : INOUT STD_LOGIC; --DSACKn ENABLE
		E : INOUT STD_LOGIC; --6800 E CLOCK
		nIVMA : INOUT STD_LOGIC; --VALID MEMORY ADDRESS		
		nRESET : INOUT STD_LOGIC; --_RESET SIGNAL
		nASDELAY : INOUT STD_LOGIC;
		DSEN : INOUT STD_LOGIC; --68000 DATA STROBE ENABLE
		RnW : INOUT STD_LOGIC; --68030 READ/WRITE
		
		nDSCLK : OUT STD_LOGIC; --GATE DSACKn REQUEST
		IPLCLK : OUT STD_LOGIC; --CLOCK TO LATCH IPL SIGNALS
		nDSACKDIS : OUT STD_LOGIC; --DSACK DISABLE
		nREGRESET : OUT STD_LOGIC; --PART OF RESET LOOP "FIX"
		nBGDIS : OUT STD_LOGIC; --BUS GRANT DISABLE
		nDSACK0 : OUT STD_LOGIC; --DSACK0
		nDSACK1 : INOUT STD_LOGIC; --DSACK1
		nOVR : OUT STD_LOGIC; --DDTACK Over Ride
		nADOEH : OUT STD_LOGIC; --ADDRESS OUTPUT ENABLE HIGH
		nADOEL : OUT STD_LOGIC; --ADDRESS OUTPUT ENABLE LOW
		ADDIR : OUT STD_LOGIC; --ADDRESS BUS DIRECTION CONTROL
		DRSEL : OUT STD_LOGIC; --DATA LATCH SELECT		
		nS7MDISD : OUT STD_LOGIC --INPUT FOR STATE MACHINE U503
			  
	);
end MAIN;

architecture Behavioral of MAIN is

	----------------------
	-- INTERNAL SIGNALS --
	----------------------
	
	--All internal signals are active HIGH!
	SIGNAL as : STD_LOGIC:='0';
	SIGNAL offboard : STD_LOGIC:='0';		
	SIGNAL cpuspace : STD_LOGIC:= '0'; --Derived from cpustate
	SIGNAL cpustate : STD_LOGIC_VECTOR ( 2 downto 0 ):= "000"; --Derived from FC(2..0)
	SIGNAL basis7m : STD_LOGIC:='0';
	SIGNAL p14m : STD_LOGIC:='0'; --14mhz clock
	SIGNAL sca : STD_LOGIC_VECTOR ( 3 downto 0 ):= "0000"; --STATE COUNTER
	SIGNAL sync : STD_LOGIC:='0';
	SIGNAL esync : STD_LOGIC:='0';
	SIGNAL cycledone : STD_LOGIC:='0';
	SIGNAL dmaaccess : STD_LOGIC:='0';
	SIGNAL dmadtack : STD_LOGIC:='0';
	SIGNAL dmacycle : STD_LOGIC:='0';	
	SIGNAL aasq : STD_LOGIC:='0';
	SIGNAL aas40 : STD_LOGIC:='0';
	SIGNAL aas80 : STD_LOGIC:='0';
	SIGNAL dmadelay : STD_LOGIC:='0';
	SIGNAL cpudtack : STD_LOGIC:='0';
	SIGNAL cpucycle : STD_LOGIC:='0';
	SIGNAL bras : STD_LOGIC:='0';
	SIGNAL dsackdly : STD_LOGIC:='0';
	SIGNAL edtack : STD_LOGIC:='0';
	SIGNAL sn7mdis : STD_LOGIC:='0'; --STATE MACHINE CLOCK DISABLE

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
			(CDAC = '1' AND p14m = '1' AND n7M = '0' AND sn7mdis = '1') OR 
			(CDAC = '0' AND p14m = '1' AND n7M = '1' AND nS7MDIS = '1') 
		ELSE '0';
		
	--This clock is used to gate a DSACK request.

	nDSCLK <= NOT basis7m;

	--This clock is used to latch the interrupt lines between the motherboard
	--and the 68030.  If this isn't done, you'll get phantom interrupts
	--that you probably won't even notice in AmigaOS, but can be fatal to
	--time critical interrupt code in UNIX and possibly even AmigaOS.

	IPLCLK <= basis7m;
	
	-----------------
	-- Delay Lines --
	-----------------
	
	--TRANSPORT is the keyword for mimicing a delay line
	--The delay lines on the A2630 are 100ns per tap...part A447-0100-02
	nASDELAY <= transport nAS after 100 ns;
	
	--BRAS		= cpucycle & !CHARGE		# cpucycle & ERAS & !ROFF		# dmacycle		# REFRAS;
	bras <= '1' WHEN cpucycle = '1' OR dmacycle = '1' ELSE '0';
	dsackdly <= transport bras after 300ns;
		
	----------------------------
	-- INTERNAL SIGNAL DEFINE --
	----------------------------
	
	as <= '1' WHEN nASEN = '0' AND nCYCEND = '1' AND nEXTERN = '1' ELSE '0';
	offboard <= '1' WHEN (nONBOARD = '1' OR nMEMSEL = '1' OR nEXTERN = '1') ELSE '0';
	cpustate <= FC ( 2 downto 0 );
	cpuspace <= '1' WHEN cpustate = "111" ELSE '0';
	
	
	--The standard qualification for a DMA memory cycle.  This is much the
	--same as the CPU cycle, only it obeys the 68000 comparible signals
	--instead of 68030 signals.  The DMA cycle can DTACK early, since we
	--know the minimum clock period is more than the DRAM access time. U600

	--dmaaccess	=  BGACK & !REFACK & MEMSEL & AAS;	
	dmaaccess <= '1' WHEN nBGACK = '0' AND nMEMSEL = '0' AND nAAS = '0' ELSE '0';

	--dmadtack	= dmaaccess & AAS80;
	--this is delayed 2 clock cycles from the original DMA request
	dmadtack <= '1' WHEN dmaaccess = '1' AND aas80 = '1' ELSE '0';

	--dmacycle	= dmaaccess & AAS40 & !DMADELAY (was 1);	changed phase of dmadelay
	--this is delayed 1 clock cycles from the original DMA request
	dmacycle <= '1' WHEN dmaaccess = '1' AND aas40 = '1' AND dmadelay = '0' ELSE '0';
	
	--This indicates when a memory cycle is complete.
	--cycledone	= cpudtack # dmadtack;
	cycledone <= '1' WHEN cpudtack = '1' OR dmadtack = '1' ELSE '0';
	
	
	--The standard qualification for a CPU memory cycle.  We have to wait
	--until refresh is arbitrated, and make sure we're selected and it's
	--not an EXTSELal cycle.

	--cpucycle	= !BGACK & !REFACK & MEMSEL & ASDELAY &  AS & !EXTSEL;
	--REFACK IS DRAM REFRESH ACK...I DON'T CARE ABOUT DRAM STUFF HERE...AT THE MOMENT
	cpucycle <= '1' WHEN nBGACK = '1' AND nMEMSEL = '0' AND nASDELAY = '0' AND nAS = '0' AND EXTSEL = '0' ELSE '0';

	--THIS LOOKS KINDA HACKY...THE DSACKDELAY IS A 300ns DELAY OF BRAS...PROBABLY ENOUGH TIME FOR THE RAM TO DO ITS STUFF
	--THERE'S NO ACTUAL CONFIRMATION, WE JUST ASSUME STUFF HAPPENED...REVIEW THIS LATER FOR APPROPRIATNESS
	--cpudtack	= cpucycle & DSACKDLY;
	cpudtack <= '1' WHEN cpucycle = '1' AND dsackdly = '1' ELSE '0';
	
	--These next lines make us delayed and synchronized versions of the 
	--68000 compatible address strobe, used to handle synchronization during DMA. U600

	--AASQ.D		= BGACK & AAS;
	PROCESS ( CPUCLK ) BEGIN
		IF RISING_EDGE ( CPUCLK ) THEN
			IF nBGACK = '0' AND nAAS = '0' THEN		
				aasq <= '1';
			ELSE 
				aasq <= '0';
			END IF;	
		END IF;
	END PROCESS;

	--AAS40.D		= BGACK & AAS & AASQ;
	PROCESS ( CPUCLK ) BEGIN
		IF RISING_EDGE ( CPUCLK ) THEN
			IF nBGACK = '0' AND nAAS = '0' AND aasq = '1' THEN
				aas40 <= '1'; 
			ELSE 
				aas40 <= '0';
			END IF;
		END IF;
	END PROCESS;

	--AAS80.D		= BGACK & AAS & AASQ & AAS40;
	PROCESS ( CPUCLK ) BEGIN
		IF RISING_EDGE ( CPUCLK ) THEN
			IF nBGACK = '0' AND nAAS = '0' AND  aasq = '1' AND aas40 = '1' THEN
				aas80 <= '1';
			ELSE 
				aas80 <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	
	--The purpose of DMADELAY is to hold off RAS during a DMA cycle
	--until there's a data strobe.  Doubling up on this functional
	--output, we also use DMADELAY to qualify "cpuread" during non-DMA
	--cycles.

	--DMADELAY	=  BGACK & !UDS & !LDS		# !BGACK &      CAS & MEMSEL & !REFHOLD		# !BGACK & DMADELAY & MEMSEL & !REFHOLD;
	--CAS AND REFHOLD ARE RELATED TO DRAM REFRESH...NOT NEEDED AT THIS TIME
	dmadelay <= '1' 
		WHEN 
			( nBGACK = '0' AND nUDS = '1' AND nLDS = '1' ) OR 
			( nBGACK = '1' AND dmadelay = '1' AND nMEMSEL = '0' ) 
		ELSE 
			'0';

	
	
	--ESYNC is simply a one clock delay of E. It is used by the counter to do 
	--edge detection.  When a high to low transition of the E clock is detected,
	--the counter is forced to a known state. This allows an absolute count to 
	--be used for VMA and peripheral DTACK.  This sync-up is only required when
	--the board is in a B2000, since that board will be receiving E from the 
	--motherboard.  On an A2000, the E clock is absent (because the processor 
	--is pulled) and thus WE create the E clock, and can create it in such a way
	--as to make it automatically synced.

	--ESYNC.D		= E & B2000;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF 
				E = '1' AND B2000 = '1'
			THEN
				esync <= '1';
			ELSE
				esync <= '0';
			END IF;
		END IF;
	END PROCESS;
		
	sync <= '1' WHEN ESYNC = '0' OR E = '1' ELSE '0'; --sync		= !ESYNC # E;
	
	---------------------
	-- REQUEST THE BUS --
	---------------------	

	--ABR is the Amiga bus request output. This signal is only asserted by 
	--this PAL on powerup in order to get the bus so that we can assert BOSS, 
	--and it won't be asserted if MODE68K is asserted. U305
	
	--ABR		= !RESET & AAS & !BOSS & !MODE68K
	--	      # !RESET & ABR & !BOSS & !MODE68K;

	--ABR.OE		= !RESET & !BOSS & !MODE68K;

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
	--activated. U504

	nBOSS <= '0' 
		WHEN 
			( nABG = '0' AND nAAS ='1' AND nDTACK = '1' AND nHALT = '1' AND nRESET = '1' AND B2000 = '1' AND MODE68K = '0' ) OR 
			( nHALT = '1' AND MODE68K = '0' AND nBOSS = '0' ) OR 
			( nRESET = '1' AND MODE68K = '0' AND nBOSS = '0' ) OR 
			( B2000 = '0' AND nHALT ='1' AND nRESET ='1')
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
	--bits in the zorro 2 configuration register if the register is configured.  Note 
	--that EXTERN cycles can only happen during non-DMA conditions, and they 
	--must qualify the CPU driven memory cycles. U305
	
	--HAD TO CHANGE access TO memaccess

	nMEMSEL <= '0' 
		WHEN 
			MEMACCESS = '1' AND CONFIGED = '1' AND nAS = '0' AND nEXTERN = '1' AND nBGACK = '1'
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
	
	
	-----------------------
	-- READ/WRITE SIGNAL --
	-----------------------
	
	--Logic Equations related to the DMA to RAM interface U505
	
	RnW <= ARnW WHEN nBGACK = '0' ELSE 'Z';
	
	-------------------------
	-- DSACK LATCH DISABLE --
	-------------------------
	
	--This is used to disable the DSACK latch.  EXTERN here is basically 
	--extra insurance that no board-generated DSACK will come out for 
	--these special cycles. JN: NO EXTERN IN THE EQUATION...MUST BE AN OLD NOTE

	--DSACKDIS	= !AS ;
	nDSACKDIS <= '0' WHEN nAS = '1';
	
	------------------
	-- 6800 E CLOCK --
	------------------
	
	E <= '1' WHEN sca(2) = '1' ELSE '0' WHEN sca(2) = '0' ELSE 'Z' WHEN B2000 = '0';
	
	--------------------------
	-- VALID MEMORY ADDRESS --
	--------------------------
	
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
  
	--!IVMA.D		=   !A3 & !A2 & !A1 & !A0 & VPA	# !IVMA & !A3;
	PROCESS ( P7M ) BEGIN
		IF RISING_EDGE ( P7M ) THEN
			IF 
				( sca(3) = '0' AND sca(2) = '0' AND sca(1) = '0' AND sca(0) = '0' AND nVPA = '0' ) OR
				( nIVMA = '0' AND sca(3) = '0' ) 
			THEN		
				nIVMA <= '0';
			ELSE
				nIVMA <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	-------------
	-- EDT ACK --
	-------------
	
	--This was "!A3 & A2 & A1 & !A0 & !IVMA", but I think that may make
	--the cycle end too early.  So I'm pushing it up by one clock. U506

	--!EDTACK.D	= !A3 & A2 & A1 & A0 & !IVMA;
	PROCESS ( P7M ) BEGIN
		IF RISING_EDGE ( P7M ) THEN
			IF 
				( sca(3) = '0' AND sca(2) = '1' AND sca(1) = '1' AND sca(0) = '1' AND nIVMA = '0' ) 
			THEN
				edtack <= '1';
			ELSE
				edtack <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	-------------------
	-- STATE COUNTER --
	-------------------
	
	--Here's the 68xx/65xx family state counter.  The counter bits A0 .. A3 are 
	--used by the 6800 cycle logic. The 6800 cycle logic uses the counter to 
	--generate the E clock and VMA and to sync DTACK to the E clock.  U504
   
	--NOTE THESE ARE NOT THE 680x0 BUS
	--SINCE THIS A 4 BIT COUNTER (QUALIFIED BY SYNC?), WE CAN PROBABLY DO SOMETHING MORE SIMPLE IN VHDL
	
	--LIKE THIS, BUT LETS GET THE LOGIC JUST WORKING FIRST
	--signal sca : std_logic_vector(3 downto 0)
	--	process(n7M)
	--begin
	-- if (rising_edge(n7m)) then sca <= sca + 1;
	-- end if;
	--end process;

	--!A0.D		=  A0 & sync;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF 
				sca(0) = '1' AND sync = '1' 
			THEN 
				sca(0) <= '0';
			ELSE
				sca(0) <= '1';
			END IF;
		END IF;
	END PROCESS;

	--!A1.D		= !A1 & !A0 #  A1 &  A0 #  A3 # !sync;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF 
				( sca(1) = '0' AND sca(0) = '0' ) OR
				( sca(1) = '1' AND sca(0) = '1' ) OR
				( sca(3) = '1' ) OR
				( sync = '0' )
			THEN		
				sca(1) <= '0';
			ELSE
				sca(1) <= '1';
			END IF;
		END IF;
	END PROCESS;

	--!A2.D		= !A2 & !A0 # !A2 & !A1	#  A2 &  A1 & A0 # !sync;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF
				( sca(2) = '0' AND sca(0) = '0' ) OR
				( sca(2) = '0' AND sca(1) = '0' ) OR
				( sca(2) = '1' AND sca(1) = '1' AND sca(0) = '1' ) OR
				( sync = '0' )
			THEN		
				sca(2) <= '0';
			ELSE
				sca(2) <= '1';
			END IF;
		END IF;
	END PROCESS;

	--!A3.D		= !A3 & !A2 & sync # !A1 &  A0 & sync # !A3 & !A0 & sync;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF
				( sca(3) = '0' AND sca(2) = '0' AND sync = '1' ) OR
				( sca(1) = '0' AND sca(0) = '1' AND sync = '1' ) OR
				( sca(3) = '0' AND sca(0) = '0' AND sync = '1' ) 
			THEN		
				sca(3) <= '0';
			ELSE
				sca(3) <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	--------------
	-- REGRESET --
	--------------
	
	--This is a special reset used to reset the configuration registers.  If
	--JMODE (Johann's special mode) is active, we can reset the registers
	--with the CPU.  Otherwise, the registers can only be reset with a cold
	--reset asserted. U504

	--REGRESET.D	= !JMODE & HALT & RESET			#  JMODE & RESET;
	PROCESS ( n7M ) BEGIN
		IF RISING_EDGE (n7M) THEN
			IF 
				( JMODE = '0' AND nHALT = '0' AND nRESET = '0' ) OR 
				( JMODE = '1' AND nRESET = '0' )
			THEN		
				nREGRESET <= '0';
			ELSE
				nREGRESET <= '1';
			END IF;
		END IF;
	END PROCESS;
			
	-----------
	-- RESET --
	-----------
	
	--The RESET output feeds to the /RST signal from the A2000
	--motherboard.  Which in turn enables the assertion of the /BOSS
	--line when you're on a B2000.  Which in turn creates the
	--/CPURESET line.  Together these make the RESET output.	In
	--order to eliminate the glitch on RESET that this loop makes,
	--the RESENB input is gated into the creation of RESET.  What
	--this implies is that the 68020 can't reset the system until
	--we're RESENB, OK?.  Make sure to consider the effects of this
	--gated reset on any special use of the ROM configuration register.
	--Using JMODE it's possible to reset the ROM configuration register
	--under CPU control, but not if the RESENB line is negated.
	
	--RESET		= BOSS & CPURESET & RESENB;
	nRESET <= '0' WHEN nBOSS = '0' AND nCPURESET ='0' AND RSTENB = '1' ELSE '1';
	
	-----------------------------
	-- 68030 BUS GRANT DISABLE --
	-----------------------------
	
	--The following is used to control the external latching of the '030
	--version of Bus Grant.  Since some '030 cycles can't be seen by the
	--expansion bus, DMA devices can't know when an '030 cycle may be going
	--on.  Since THEY must arbitrate /BGACK with this knowledge, it's 
	--necessary for US to do it instead, since we can see all cycles.  If
	--ABG has already been asserted, we don't disable it unless we're reset.

	--BGDIS		= !BOSS			# !ABG & DSACK1		# !ABG & AS ;
	nBGDIS <= '0' WHEN nBOSS = '1' OR ( nABG = '1' AND nDSACK1 = '0' ) OR ( nABG = '1' AND nAS = '0' ) ELSE '1';	
	
	------------
	-- DSACKn --
	------------
	
	--These are the cycle termination signals.  They're really both the
	--same, and both driven, indicating that we are, in fact, a 32 bit
	--wide port.  They go hi-Z when we're not selecting memory, so that
	--other DSACK sources (FPU and the slow bus stuff) can get their
	--chance to terminate. U600

	--DSACK0		= cycledone;
	--DSACK0.OE	= MEMSEL;
	nDSACK0 <= cycledone
		WHEN
			nMEMSEL = '0'
		ELSE
			'Z';

	--DSACK1		= cycledone;
	--DSACK1.OE	= MEMSEL;
	nDSACK1 <= cycledone
		WHEN
			nMEMSEL = '0'
		ELSE
			'Z';
			
	-------------------------
	-- GARY DTACK OVERRIDE --
	-------------------------
	
	--The OVR signal must be asserted whenever on-board memory is selected
	--during a DMA cycle.  It tri-states GARY's DTACK output, allowing
	--one to be created by our memory logic.

	--OVR		= BGACK & MEMSEL;
	--OVR.OE		= BGACK & MEMSEL;
	nOVR <= '0' WHEN nBGACK = '0' AND nMEMSEL = '0' ELSE 'Z';
	
	
	-----------------------------------
	-- ADDRESS BUS DIRECTION CONTROL --
	-----------------------------------
	
	--This is data direction control

	--!ADDIR		=  BGACK & !RW		# !BGACK &  RW;
	ADDIR <= '0' --AMIGA WRITING TO 2630
		WHEN 
			( nBGACK = '0' AND RnW = '0' ) OR  
			( nBGACK = '1' AND RnW = '1' ) 
		ELSE 
			'1'; --2630 WRITING TO THE AMIGA
			
	--------------------------
	-- ADDRESS ENABLE HI/LO --
	--------------------------
	
	--This handles the data buffer enable, including the 16 to 32 bit data
	--bus conversion required for DMA cycles.

	--ADOEH		= BOSS &  BGACK &  MEMSEL & AAS & !A1		# BOSS & !BGACK & !MEMSEL &  AS & !ONBOARD & !EXTERN;
	nADOEH <= '0' 
		WHEN 
		( nBOSS = '0' AND nBGACK = '0' AND nMEMSEL = '0' AND nAAS = '0' AND A1 = '0' ) OR 
		( nBOSS = '0' AND nBGACK = '1' AND nMEMSEL = '1' AND nAS = '0' AND nONBOARD = '1' AND nEXTERN = '1' ) 
		ELSE
			'1';

	--ADOEL		= BOSS &  BGACK &  MEMSEL & AAS &  A1;
	nADOEL <= '0' WHEN  nBOSS = '0' AND nBGACK = '0' AND nMEMSEL = '0' AND nAAS = '0' AND A1 = '0'  ELSE '1';
	
	
	----------------------
	-- AMIGA DATA LATCH --
	----------------------
	
	--This selects when we want data latching, which we in fact want only on
	--read cycles.

	--DRSEL		= BOSS & !BGACK & RW;
	DRSEL <= '1' WHEN nBOSS = '0' AND nBGACK = '1' AND RnW = '1' ELSE '0';
	
	
	-----------------
	-- BUS CONTROL --
	-----------------
	
	--This one disables the rising edge clock.  It's latched externally.
	--I qualify with EXTERN as well, to help make sure this state machine
	--doesn't get started for special cycles.  Since ASEN isn't qualified
	--externally with EXTERN, everywhere here it's used, it must be 
	--qualified with EXTERN too. U505
	
	--NOTE: ON THE SCHEMATIC, DSEN IS ACTIVE LOW, BUT IS TREATED AS ACTIVE HIGH IN THE PAL LOGIC

	--S7MDIS		= !DSEN & ASEN & !EXTERN & DSACKEN;
	nS7MDISD <= '0' WHEN DSEN = '0' AND nASEN = '0' AND nEXTERN = '1' AND nDSACKEN = '0' ELSE '1';
	
	
	--This one disables the falling edge clock.  This is similarly qualified
	--with EXTERN. U505

	--S_7MDIS.D	= ASEN & !EXTERN & CYCEND;
	PROCESS ( SCLK ) BEGIN
		IF RISING_EDGE (SCLK) THEN
			IF 
				nASEN = '0' AND nEXTERN = '1' AND nCYCEND = '0'
			THEN
				sn7mdis <= '1';
			ELSE
				sn7mdis <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	--This one marks the end of a slow cycle. U505
	
	--!CYCEND.D	= !DSACKEN & CYCEND;	
	PROCESS ( SCLK ) BEGIN
		IF RISING_EDGE (SCLK) THEN
			IF nDSACKEN = '1' AND nCYCEND = '1' THEN
				nCYCEND <= '0'; 
			ELSE
				nCYCEND <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	--This creates the DSACK go-ahead for all slow, 16 bit cycles.  These are,
	--in order, A2000 DTACK, 68xx/65xx emulation DTACK, and ROM or config
	--register access. U505

	--!DSACKEN.D	= !DSEN & CYCEND & !EXTERN &   DTACK
	--		# !DSEN & CYCEND & !EXTERN &  EDTACK
	--		# !DSEN & CYCEND & !EXTERN & ONBOARD;
	PROCESS ( SCLK ) BEGIN
		IF RISING_EDGE (SCLK) THEN
			IF 
				(DSEN = '0' AND nEXTERN = '1' AND nCYCEND = '1' AND nDTACK = '0') OR
				(DSEN = '0' AND nEXTERN = '1' AND nCYCEND = '1' AND edtack = '1') OR --note: edtack inverted from original
				(DSEN = '0' AND nEXTERN = '1' AND nCYCEND = '1' AND nONBOARD = '0')
			THEN
				nDSACKEN <= '1';
			ELSE
				nDSACKEN <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	--Here we enable data strobe to the A2000.  Are we properly considering
	--the R/W line here?  EXTERN qualification included here too. U505

	PROCESS ( SCLK ) BEGIN
		IF RISING_EDGE (SCLK) THEN
			IF nASEN = '0' AND nEXTERN = '1' AND nCYCEND = '1' THEN
				DSEN <= '0' ;
			ELSE
				DSEN <= '1';
			END IF;
		END IF;
	END PROCESS;

end Behavioral;

