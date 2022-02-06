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
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 16);			  
			  FC : in STD_LOGIC_VECTOR (2 downto 0);
			  SIZ : in STD_LOGIC_VECTOR (1 downto 0);           
			  _AS : in STD_LOGIC;
			  _DS : in STD_LOGIC;
			  R_W : in STD_LOGIC;
			  CLK : in STD_LOGIC; --68030 Clock
			  CDAC, _C1, C3, A7M : in STD_LOGIC; --Clocks from A2000
			  _RESET : in STD_LOGIC;
			  _HALT : in STD_LOGIC;
			  B2000 : in STD_LOGIC;
			  _ABGACK : in STD_LOGIC;
			  S_7MDIS : in STD_LOGIC;
			  _S7MDIS : in STD_LOGIC;
			  _ASEN : in STD_LOGIC;			   
			  
			  D : inout STD_LOGIC_VECTOR (20 downto 16);
			  _DTACK : inout STD_LOGIC;			  
			  _ABG : inout STD_LOGIC;
			  _ABR : inout STD_LOGIC;
			  _BGACK : inout STD_LOGIC:='Z';
			  
			  --_AAS : out STD_LOGIC;
			  _BOSS : out STD_LOGIC:='1';
			  _CSROM : out  STD_LOGIC:='1';
			  _UUBE : out STD_LOGIC:='1';
			  _UMBE  : out STD_LOGIC:='1';
			  _LMBE : out STD_LOGIC:='1';
			  _LLBE : out STD_LOGIC:='1';
			  _OE0 : out STD_LOGIC:='1';
			  _OE1 : out STD_LOGIC:='1';
			  _WE0 : out STD_LOGIC:='1';
			  _WE1 : out STD_LOGIC:='1';
			  _STERM : out STD_LOGIC:='1';
			  _DTACK : out STD_LOGIC:='1';
			  ADDIR : out STD_LOGIC:='1';
			  _ADDEH : out STD_LOGIC:='1';
			  _ADDEL : out STD_LOGIC:='1';
			  _CSROM : out STD_LOGIC:='1';
			  CLK7M : out STD_LOGIC:='0';
			  SCLK : out STD_LOGIC:='0';
			  S7MDIS_DFF : out STD_LOGIC:='0'
			  
			  
			  );		
			  
end N2630_Main;

architecture Behavioral of N2630_Main is

	SIGNAL AUTOCONFIG_DONE : STD_LOGIC:='0'; --Is the autoconfig process complete?
	SIGNAL BASEADDRESS : STD_LOGIC_VECTOR (3 downto 0); --Probably don't even need this

	SIGNAL TWOMEG : STD_LOGIC:='0'; --Are we in the first 2 megabyte address space?
	SIGNAL FOURMEG : STD_LOGIC:='0'; --Are we in the second 2 megabyte address space?
	SIGNAL EIGHTMEG : STD_LOGIC:='0'; --Aare we in the second 4 megabyte address space

	SIGNAL AUTOCONFIGSPACE : STD_LOGIC:='0';
	SIGNAL _ONBOARD : STD_LOGIC:='1';
	SIGNAL HIROM : STD_LOGIC:='0';
	SIGNAL LOROM : STD_LOGIC:='0';
	SIGNAL ROMCLK : STD_LOGIC:='1'; --This qualifies the PHANTOM signals
	SIGNAL _REGRESET : STD_LOGIC:='Z'; --FOR U303 flip flop
	
	SIGNAL _EXTERN : STD_LOGIC:='1'; --Pull low when daughter OR FPU is being accessed
	
	SIGNAL _CLK7M : STD_LOGIC:='0'; --Inverted 7MHz clock, for consistency for now
	--SIGNAL CLK7M, SCLK : STD_LOGIC:='0'; --7MHz clock	
	SIGNAL CLK14M : STD_LOGIC:='0'; --14MHz Clock
	
	--U303 D FF OUTPUTS
	SIGNAL PHANTOMLO,PHANTOMHI,ROMCONF,RSTENB,JMODE,MODE68K : STD_LOGIC:="0";

begin
	
	--I tried to lay this out in an order that "makes sense" from the time the machine
	--is started/reset...to put operations in order from earliest to latest	
	
	---------------------
	-- GENERAL SIGNALS --
	---------------------

	--These are required for one or more operations in the code below
	
	-- CLOCKS --

	BASIS7M <= '1'
		WHEN
			( B2000 = '1' AND A7M )
			--B2000 & A7M
		OR
			( B2000 = '0' AND ( C1 XOR C3 ))
			--!B2000 & (!C1 $ C3)
		ELSE
			'0';
		
	CLK7M <= BASIS7M;	--ALSO: SCLK, IPLCLK, N7M		
	_CLK7M <= NOT BASIS7M; --ALSO: _DSCLK	
	CLK14M <= BASIS7M XOR CDAC;
	
	--This is the state machine clock.  This is basically a 14MHz clock, 
	--but some of it's edges are suppressed.  This lets the 68000 state
	--machine just skip the unimportant clock edges in the 68000 cycle
	--and just concentrate on the interesting edges.

	SCLK <= '1'
		WHEN
			( CDAC = '1' AND CLK14M = '1' AND CLK7M = '0' AND S_7MDIS = '1' )
			--CDAC & P14M & !N7M & SN7MDIS
		OR
			( CDAC = '0' AND CLK14M = '1' AND CLK7M = '1' AND _S7MDIS = '1' )
			--!CDAC & P14M &  N7M & !S7MDIS
		ELSE
			'0';
			
	-- END CLOCKS --
	
	--Here's the EXTERN logic.  The EXTERN signal is used to qualify unusual
	--memory accesses.  There are two kinds, CPU space and daughterboard
	--space.  CPU space is given by the function codes.  Daughterboard space
	--is defined to be a processor access with EXTSEL asserted.  DMA devices 
	--can't get to daughterboard space.

	EXTERN <= '1'
		WHEN
			( FC(2 downto 0) = x"7" AND _BGACK = '1' )
			--cpuspace & !BGACK
		--OR
			--EXTSEL & !BGACK
			--ESXTSEL comes from the daughter card!
		ELSE
			'0';
			
	--This one marks the end of a slow cycle U505 clocked by SCLK

	!CYCEND.D	= !DSACKEN & CYCEND;
			
	--Here we enable data strobe to the A2000.  Are we properly considering
	--the R/W line here?  EXTERN qualification included here too. U505
	!DSEN.D		= ASEN & !EXTERN & CYCEND;
	
	--This creates the DSACK go-ahead for all slow, 16 bit cycles.  These are,
	--in order, A2000 DTACK, 68xx/65xx emulation DTACK, and ROM or config
	--register access. U505

	!DSACKEN.D	= !DSEN & CYCEND & !EXTERN &   DTACK
		# !DSEN & CYCEND & !EXTERN &  EDTACK
		# !DSEN & CYCEND & !EXTERN & ONBOARD;
			
	--This one disables the rising edge clock.  It's latched externally.
	--I qualify with EXTERN as well, to help make sure this state machine
	--doesn't get started for special cycles.  Since ASEN isn't qualified
	--externally with EXTERN, everywhere here it's used, it must be 
	--qualified with EXTERN too.
	--ORIGINAL PAL U505, FLIP FLOP, CLOCKED BY SCLK, NO RESET. This is the D input of U503

	S7MDIS_DFF	= !DSEN & ASEN & !EXTERN & DSACKEN;
	
	
	



		
	

	--ROMCLK U301 PAL
	--THIS IS USED TO CLOCK THE U303 D FLIP FLOP
	ROMCLK <= '1'
		WHEN 
			( R_W = '0' AND _DS = '0' AND RESET = '1' AND A(6 downto 1) = x"40" AND AUTOCONFIG_DONE = '0' )
		OR
			( ROMCLK = '1' AND _DS = '0' )
		ELSE
			'0';	


	--RAMCLK U301 PAL
	--THIS IS USED TO CLOCK THE U302 D FLIP FLOP
	RAMCLK <= '1'
		WHEN
			( R_W = '0' AND _DS = '0' AND RESET = '1' AND A(6 downto 1) = x"48" AND ROMCLK = '0' )
			--writecycle & ramaddr & !ROMCLK
		OR
			( _RESET = '1' AND RAMCLK = '1' )
			--!CPURESET & RAMCLK
		ELSE
			'0';
			
			
	--U303 D FF = 74LS174 (triggered on rising edge)
	--THIS IS ONLY USED AT STARTUP TO HELP WITH READING THE ROMs AND SETTING 68K MODE
	--This could be moved to a 74HCT174 later if we fill up the CPLD
	PROCESS (ROMCLK, _REGRESET) BEGIN
		IF _REGRESET = '0' THEN
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
	PROCESS (RAMCLK, _CPURESET) BEGIN
		IF _CPURESET = '0' THEN
			RAMCONF <= '0';
		ELSIF RISING_EDGE (RAMCLK) THEN
			RAMCONF <= ROMCONF;
		END IF;	
	END PROCESS;
	
	--_REGRESET
	--	This is a special reset used to reset the configuration registers.  If
	-- JMODE (Johann's special mode) is active, we can reset the registers
	-- with the CPU.  Otherwise, the registers can only be reset with a cold
	-- reset asserted.
	--Original PAL U504 (16R6A flip flop, according to data sheet is triggered on rising edge, schematics show falling edge?)

	PROCESS (_7MCLK) BEGIN
		IF (RISING_EDGE(_7MCLK)) THEN 
			_REGRESET <= NOT _REGRESET			
				WHEN
					( JMODE = '0' AND _HALT = '0' AND _RESET = '0' )
				OR
					( JMODE = '1' AND _RESET = '0' );
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
	
	REQUESTBUS:PROCESS(_RESET, CLK) BEGIN
	
		IF ( MODE68K = '1' OR _BOSS = '0' ) THEN		
			_ABR <= '1'; 
			
		ELSIF ( _RESET = '1' AND _BOSS = '1' ) THEN		
			ABR <= '0'
				WHEN
					( RISING_EDGE(CLK) AND _AS = '1' AND MODE68K = '0' )
					--I'm using _AS in place of _AAS...which is basically a delayed address strobe
					--I'm trying to make my own delay by waiting for the next rising clock edge
					--_AS asserts on the falling edge, so this waits until the clock's rising edge,
					--essentially delaying it after _AS unasserts
				OR
					( _ABR = '1' AND MODE68K = '0' );
		END IF;
		
	END PROCESS REQUESTBUS;
	
	--_BGACK (Bus Grant Acknowledge)
	--We keep _ABGACK disconnected from _BGACK until we are BOSS.
	--Original PAL U501
	
	PROCESS(_RESET, CLK) BEGIN
		IF BOSS = '1' THEN
			_BGACK <= 'Z';
		ELSE
			_BGACK <= _ABGACK;
		END IF;
	END PROCESS;
	
	--_DTACK
	--This is the DTACK generator for DMA access to on-board memory.  It
	--waits until we're in a cycle, and then a fixed delay from RAS, to `
	--account for any refresh that must take place.	
	--Original PAL U501
	--We don't need a RAS delay...cause we're using SRAM

	_DTACK <= '0'
		WHEN
			--_DTACK = BGACK & MEMSEL & AAS & STERM;
			_BGACK = '0' AND _AS = '0' AND _STERM = '0' AND (TWOMEG = '1' OR FOURMEG = '1')
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
	
	--not a flip flot
	BOSS:PROCESS(_RESET, CLK) BEGIN
	
		IF _BOSS = '1' THEN		
			
			_BOSS <= '0' 				
				WHEN 
					( RISING_EDGE(CLK) AND _AS = '1' AND _ABG = '0' AND _DTACK = '1' 
					AND HALT = '1' AND _RESET = '1' AND B2000 = '1' AND MODE68K = '0' )
					--_ABG = 0 means the Amiga is trying to grant us the bus
					--I'm using _AS and rising_edge(clk) in place of _AAS...which is basically a delayed address strobe
				OR
					( _HALT = '1' AND MODE68K = '0' )
				OR
					( _RESET = '1' AND MODE68K = '0' )
				OR
					( B2000 = '0' AND HALT = '1' AND _RESET = '1' ) --This is for the original A2000
				ELSE
					'1'; 
					
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
	PROCESS (_AS) BEGIN
		IF 
			A(23 downto 16) = x"E8" AND _AS = '0' 
		THEN
			AUTOCONFIGSPACE <= '1';
		ELSE
			AUTOCONFIGSPACE <= '0';
		END IF;
	END PROCESS;	

	AUTOCONFIG : PROCESS (CLK, _RESET)
		BEGIN
		
		IF _RESET = '0' THEN
			--THE COMPUTER IS IN RESET
			--PUT THE AUTOCONFIG SETTINGS BACK TO NOT CONFIGURED
			AUTOCONFIG_DONE <= '0';
			BASEADDRESS <= x"0";
		
		ELSIF RISING_EDGE(CLK) AND AUTOCONFIG_DONE = '0' THEN
			IF ( AUTOCONFIGSPACE = '1' AND R_W = '1') THEN
				--THIS IS THE AUTOCONFIG BASE ADDRESS
				
				CASE A(6 downto 1) IS
					
					--offset $00
					WHEN "000000" => D(31 downto 28) <= "1110"; --er_type: Zorro 2 card without BOOT ROM
				
					--offset $02
					WHEN "000001" => D(31 downto 28) <= "0111"; --er_type: 4MB
					
					--offset $04
					WHEN "000010" => D(31 downto 28) <= "1010"; --Product Number Hi Nibble, we are stealing the A2630 product number
					
					--offset $06
					WHEN "000011" => D(31 downto 28) <= "1000"; --Product Number Lo Nibble				
					
					--offset $08
					WHEN "000100" => D(31 downto 28) <= "0010"; --er_flags: I/O device, can't be shut up, reserved, reserved
					
					--offset $0A
					--WHEN "000101" => D(31 downto 28) <= "0000"; --er_flags: Reserved, must be zeroes
					
					--offset $0C
					--WHEN "000110" => D(31 downto 28) <= "0000"; --Reserved: must be zeroes				
					
					--offset $0E
					--WHEN "000111" => D(31 downto 28) <= "0000"; --Reserved: must be zeroes	
					
					--offset $10
					WHEN "001000" => D(31 downto 28) <= "0100"; --Product Number, high nibble hi byte. Just for fun, lets put C= in here!
					
					--offset $12
					--WHEN "001001" => D(31 downto 28) <= "0000"; --Product Number, low nibble hi byte. Just for fun, lets put C= in here!
					
					--offset $14
					--WHEN "001010" => D(31 downto 28) <= "0000"; --Product Number, high nibble low byte. Just for fun, lets put C= in here!
					
					--offset $16
					WHEN "001011" => D(31 downto 28) <= "0100"; --Product Number, low nibble low byte. Just for fun, lets put C= in here!
					
					--offset $18
					--WHEN "001100" => D(31 downto 28) <= "0000"; --Serial number byte 0 high nibble
					
					--offset $1A
					--WHEN "001101" => D(31 downto 28) <= "0000"; --Serial number byte 0 low nibble				
					
					WHEN OTHERS => D(31 downto 28) <= "0000"; --Reserved offsets and unused offset values are all zeroes
					
				END CASE;
				
			--Is this one our base address?
			ELSIF (R_W = '0' AND _DS = '0' AND _AS = '0' AND AUTOCONFIG_DONE = '0') THEN
			
				IF ( A(6 downto 1) = x"48" ) THEN
					--I DON'T KNOW WHAT TO DO WITH THIS...WE PROBABLY DON'T NEED IT
					BASEADDRESS <= D(31 downto 28); --This is written to our device from the Amiga
					AUTOCONFIG_DONE <= '1'; --Autoconfig process is done!
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
			A(23 downto 16) >= x"f80000" AND A(23 downto 16) <= x"f8ffff"
		ELSE
			'0';
			
	LOROM <= '1'
		WHEN
			A(23 downto 16) >= x"000000" AND A(23 downto 16) <= x"00ffff"
		ELSE
			'0';

	ROM_ENABLE:PROCESS( _AS ) BEGIN

		IF (R_W = '1' AND _AS = '0') THEN
			--This is a read cycle
			IF (HIROM = '1' AND PHANTOMHI = '0') THEN 
				--High memory rom space, where ROMs normally reside when available.
				_CSROM <= '0';
			ELSIF ( LOROM = '1' AND PHANTOMLO = '0') THEN 
				--Low memory ROM space, used for mapping of ROMs on reset.
				_CSROM <= '0';		
			ELSE
				--We are not in the ROM address spaces
				_CSROM <= '1';
			END IF;
		ELSE
			--We are not in a read cycle
			_CSROM <= '1';
		END IF;

	END PROCESS ROM_ENABLE;

	---------------
	-- RAM STUFF --
	---------------

	--THIS DETERMINES IF WE ARE IN THE FIRST OR SECOND 2 MEGS OF ADDRESS SPACE
	--THIS IS ALL IN SECTION 12 OF THE 68030 MANUAL
	
	TWOMEG <= '1' 
		WHEN
			A(31 downto 21) = "01000000000" --A21 IS LOW IN THE FIRST 2 MEGS
		ELSE
			'0';
			
	FOURMEG <= '1'
		WHEN
			A(31 downto 21) = "01000000001" --A21 IS HIGH IN THE SECOND 2 MEGS
		ELSE
			'0';	
			
	EIGHTMEG <= '1'
		WHEN
			A(31 downto 22) = "0100000001" --A22 IS HIGH IN THE SECOND 4 MEGS
		ELSE
			'0';

	--THIS IS THE RAM IN THE ZORRO 2 SPACE (UP TO 8 MEGABYTES)
	--WE DIRECT THE RAM SIGNALING BASED ON WHAT THE 68030 IS ASKING FOR
	--THIS IS A 32 BIT PORT WITH NO WAIT STATES
	--Original PAL: Multiple

	--The basic process goes like this:
	--68030: drive A31:0, drive FC2:0, drive SIZ1:0, Set R_W, assert _AS, drive D31:0 (for write), assert _DS (for write)
	--A2630: decode address and store/provide data on D31:0, assert _STERM
	--68030: Negate _AS and _DS
	--A2630: Negate _STERM

	--the values in the process statement will trigger the process when one of them changes

	RAM_ACCESS:PROCESS ( _AS, R_W, _DS ) BEGIN

		IF (AUTOCONFIG_DONE = '1' AND FC(2 downto 0) /= x"7" AND _AS = '0' AND _DS = '0') THEN
			--$7 = CPU SPACE...we do not want to interject ourselves when the CPU is taking care of it's own business		
			
			--ENABLE THE VARIOUS BYTES ON THE SRAM DEPENDING ON WHAT THE CPU IS ASKING FOR
			
			_UUBE <= '0' --UPPER UPPER BYTE ENABLE (D31..24)
				WHEN
					R_W = '1' --THIS IS A READ CYCLE
				OR	
					(R_W = '0' AND A(1 downto 0) = "00")
				ELSE '1';
			
			_UMBE <= '0' --UPPER MIDDLE BYTE ENABLE (D23..16)
				WHEN
					R_W = '1'
				OR 
					(R_W = '0' AND ( A(1 downto 0) = "01" OR 
					( A(1) = '0' AND SIZ(0) = '0' ) OR 
					( A(1) = '0' AND SIZ(1) = '1' )))
				ELSE '1';
				
			_LMBE <= '0' --LOWER MIDDLE BYTE (D15..8)
				WHEN
					R_W = '1'
				OR 
					(R_W = '0' AND ( A(1 downto 0) = "10" OR 
					( A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0' ) OR 
					( A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1' ) OR 
					( A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0' )))
				ELSE '1';
				
			_LLBE <= '0' --LOWER LOWER BYTE (D7..0)
				WHEN
					R_W = '1'
				OR
					(R_W = '0' AND ( A(1 downto 0) = "11" OR 
					(A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1') OR
					(SIZ(0) = '0' AND SIZ(1) = '0') OR
					(A(1) = '1' AND SIZ(1) ='1')))
				ELSE '1';
				
			--OUTPUT ENABLE OR WRITE ENABLE DEPENDING ON THE CPU REQUEST
			_OE0 <= '0' --BANK0
				WHEN
					R_W = '1' AND TWOMEG = '1'
				ELSE '1';
			
			_OE1 <= '0' -- BANK1
				WHEN
					R_W = '1' AND FOURMEG = '1'
				ELSE '1';
				
			_WE0 <= '0' -- BANK0
				WHEN
					R_W = '0' AND TWOMEG = '1'
				ELSE '1';
				
			_WE1 <= '0' -- BANK1
				WHEN
					R_W = '0' AND FOURMEG = '1'
				ELSE '1';	
				
			--_STERM = Bus response signal that indicates a port size of 32 bits and
			--that data may be latched on the next falling clock edge. Synchronous transfer.
			--STERM is only used on the daughterboard of the A2630. The A2630 card uses DSACKx for terminiation.
			--We should be OK here as we are using fast SRAM and can use the 2 clock cycle read/write
			_STERM <= '0'
				WHEN
					TWOMEG = '1' OR FOURMEG = '1'
				ELSE '1';
				
					
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
			_STERM <= '1';
			
			_UUBE <= '1';
			_UMBE <= '1';
			_LMBE <= '1';
			_LLBE <= '1';
			
			_OE0 <= '1';
			_OE1 <= '1';
			_WE0 <= '1';
			_WE1 <= '1';	
			
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
			( _BGACK = '0' AND R_W = '0' )
		OR
			( _BGACK = '1' AND R_W = '1' )
		ELSE
			'0';

	--This handles the data buffer enable, including the 16 to 32 bit data
	--bus conversion required for DMA cycles.
	
	--ARE WE TRYING TO ACCESS SOMETHING ON THE A2630?	
	--LOOKS TO BE ONLY AT STARTUP AS THIS ONLY CONSIDERS ROM ACCESS OR AUTOCONFIG
	_ONBOARD <= '0'
		WHEN
			( HIROM = '1' AND PHANTOMHI = '0' AND R_W = '0' AND _AS ='0' )
		OR
			( LOWROM = '1' AND PHANTOMLO = '0'  AND R_W = '0' AND _AS ='0' )
		OR
			( AUTOCONFIGSPACE = '1' AND _AS ='0' AND RAMCONF = '0' )
			--iscauto = autocon & AS & !RAMCONF &  AUTO 
		OR
			( AUTOCONFIGSPACE = '1' AND _AS ='0' AND ROMCONF = '0' )
			--ICSAUTO (OR) autocon & AS & !ROMCONF & !AUTO
			--AUTO = should I autoconfig? Yes, always autoconfig, so we don't include that
		OR
			( _ONBOARD = '0' AND _AS ='0' )
		ELSE
			'1';

	--_ADOEH = ENABLE D(31..16)
	_ADOEH <= '0'
		WHEN
			( _BOSS = '0' AND _BGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND _AS = '0' AND A(1) = '0' )
			--BOSS &  BGACK &  MEMSEL & AAS & !A1
		OR
			( _BOSS = '0' AND _BGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND _AS = '0' AND _ONBOARD = '1' )
			--BOSS & !BGACK & !MEMSEL &  AS & !ONBOARD & !EXTERN;
			--EXTERN tells us if we are accessing expansion memory...not doing that right now
		ELSE
			'1';
			
		--_ADOEL = ENABLE D(15..0)
		_ADOEL <= '0'
			WHEN 
				( _BOSS = '0' AND _BGACK = '0' AND (TWOMEG = '1' OR FOURMEG = '1') AND _AS = '0' AND A(1) = '1' )
				-- BOSS &  BGACK &  MEMSEL & AAS &  A1
			ELSE
			'1';

end Behavioral;

