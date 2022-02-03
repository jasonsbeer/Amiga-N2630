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
			  CLK : in STD_LOGIC;
			  _RESET : in STD_LOGIC;
			  B2000 : in STD_LOGIC;
			  _HALT : in STD_LOGIC;
			  
			  _DTACK : inout STD_LOGIC;			  
			  _ABG : inout STD_LOGIC;
			  _ABR : inout STD_LOGIC;
			  
			  --_ABG : out STD_LOGIC;
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
			  _STERM : out STD_LOGIC:='1'
			  
			  );		
			  
end N2630_Main;

architecture Behavioral of N2630_Main is

	signal AUTOCONFIG_DONE : STD_LOGIC:='0'; --Is the autoconfig process complete?
	signal BASEADDRESS : STD_LOGIC_VECTOR (3 downto 0);

	signal TWOMEG : STD_LOGIC:='0'; --Are we in the first 2 megabyte address space?
	signal FOURMEG : STD_LOGIC:='0'; --Are we in the second 2 megabyte address space?

	signal _ROMCLK : STD_LOGIC:='1'; --This qualifies the PHANTOM signals
	signal PHANTOMHI : STD_LOGIC:='0'; --Phantom signals used for ROM reading qualification
	signal PHANTOMLO : STD_LOGIC:='0'; --Phantom signals used for ROM reading qualification
	
	signal MODE68K : STD_LOGIC;
	signal _EXTERN : STD_LOGIC:='1'; --Pull low when daughter is being accessed

begin
	
	---------------------
	-- GENERAL SIGNALS --
	---------------------

	--These are required for one or more operations in the code below

	_ROMCLK <= '0'
	WHEN 
		( R_W = '0' AND _DS = '0' AND RESET = '1' AND A(6 downto 1) = x"40" AND AUTOCONFIG_DONE = '0' )
	OR
		( _ROMCLK = '0' AND _DS = '0' )
	ELSE
		'1';

	----------------
	-- AUTOCONFIG --
	----------------

	--We have two boards we need to autoconfig
	--1. The 68030 with base memory (up to 8MB) without BOOT ROM in the Zorro 2 space
	--2. The expansion memory (up to 112MB) in the Zorro 3 space

	--A good explaination of the autoconfig process is given in the Amiga Hardware Reference Manual from Commodore
	--https://archive.org/details/amiga-hardware-reference-manual-3rd-edition

	AUTOCONFIG : PROCESS (CLK, _RESET)
		BEGIN
		
		IF _RESET = '0' THEN
			--THE COMPUTER IS IN RESET
			--PUT THE AUTOCONFIG SETTINGS BACK TO NOT CONFIGURED
			AUTOCONFIG_DONE <= '0';
			BASEADDRESS <= x"0";
		
		ELSIF RISING_EDGE(CLK) AND AUTOCONFIG_DONE = '0' THEN
			IF ( A(23 downto 16) = x"E8" AND _AS = '0' AND _RW = '1') THEN
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
					BASEADDRESS <= D(31 downto 28); --This is written to our device from the Amiga
					AUTOCONFIG_DONE <= '1'; --Autoconfig process is done!
				END IF;
			
			END IF;
					
		END IF;	

	END PROCESS AUTOCONFIG;

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

	--THIS IS THE BASE 4 MEGABYTES OF SRAM
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
	
	-----------------
	-- BECOME BOSS --
	-----------------	
	
	--WE NEED TO BECOME B.O.S.S.! (Biomorphic Organisational Systems Supervisor)
	--ORIGINAL PAL U504
	
	--BOSS is a signal used by the B2000 to hold the 68000 on the main board 
	--in tristate (by using bus request). Our board uses BOSS to indicate that
	--we have control of the universe.  The inverse of BOSS is used as a CPU,
	--MMU and ROM control register reset.  BOSS gets asserted after we request
	--the bus from the 68000 (we wait until it starts it's first memory access
	--after reset) and recieve bus grant and the indication that the 68000 has
	--completed the current cycle.  BOSS gets held true in a latching term until
	--the next cold reset or until 68KMODE is asserted.	
	
	--First, we must request the bus on power up/reset
	--ABR is the Amiga bus request output. This signal is only asserted 
	--on powerup in order to get the bus so that we can assert BOSS, 
	--and it won't be asserted if MODE68K is asserted.	
	
	REQUESTBUS:PROCESS(_RESET, CLK) BEGIN
	
		IF ( MODE68K = '1' OR _BOSS = '0' ) THEN
			_ABR <= 'Z'; --Put this in high impedence cause we don't need it
			
		ELSIF ( _RESET = '1' AND _BOSS = '1' ) THEN
		
			ABR <= '0'
				WHEN
					( _RESET = '1' AND _AS = '1' AND MODE68K = '0' )
					--I'm using _AS in place of _AAS...which is basically a delayed address strobe
				OR
					( _RESET = '1' AND _ABR = '1' AND MODE68K = '0' );
		END IF;
		
	END PROCESS REQUESTBUS;
	
	--We wanna be the boss, but we have to be careful.  We're never the boss
	--during a cold reset, or during 68K mode.  We wait after reset for the
	--bus grant from the 68000, then we assert BOSS, if we're a B2000.  We
	--always assert BOSS during a non-reset if we're an A2000.  Finally, we
	--hold BOSS on the B2000 until either a full reset or the 68K mode is
	--activated.
	
	MODE68K <= D(20) WHEN _ROMCLK = '0';
	
--	BOSS:PROCESS(_RESET) BEGIN
--		IF (_BOSS = '1') THEN		
--			
--			_BOSS <= '0' 
--				WHEN 
--					( _ABG = '0' AND _AS = '1' AND _DTACK = '1' AND HALT = '1' AND _RESET = '1' AND B2000 = '1' AND MODE68K = '0' )
--					--I'm using _AS in place of _AAS...which is basically a delayed address strobe
--				OR
--					( HALT = '1' AND MODE68K = '0' AND BOSS = '1' )
--				OR
--					( _RESET = '1' AND MODE68K = '0' AND BOSS = '1' )
--				OR
--					( B2000 = '0' AND HALT = '1' AND _RESET = '1' ) --This is for the original A2000
--				ELSE
--					'1'; 
				
			---------------------------------------
			
--			DTACK		= BGACK & MEMSEL & AAS & STERM;	
--			
--			aas		=  ASEN & !CYCEND & !EXTERN;
--			
--			asen = delayed address strobe
--			
--			!CYCEND.D	= !DSACKEN & CYCEND
--			
--			!DSACKEN.D	= !DSEN & CYCEND & !EXTERN &   DTACK
--			# !DSEN & CYCEND & !EXTERN &  EDTACK
--			# !DSEN & CYCEND & !EXTERN & ONBOARD;
--			
--			!DSEN.D		= ASEN & !EXTERN & CYCEND;
--			
--			EDTACK.D	= !A3 & A2 & A1 & A0 & !IVMA;
--			
--			!IVMA.D		=   !A3 & !A2 & !A1 & !A0 & VPA
--			# !IVMA & !A3;
--			
--			ONBOARD		= icsrom 
--			# icsauto
--			# ONBOARD & AS;
--			
--			EXTERN		= cpuspace & !BGACK
--			# EXTSEL & !BGACK ;
--			
--			BGACK = 68030
--			
--			EXTSEL = from daughter
			
--		END IF;		
	
--	END PROCESS BOSS;

	----------------
	-- ROM ENABLE --
	----------------

	--WE NEED TO SUPPLY A ROM ENABLE SIGNAL WHEN THE ADDRESS
	--SPACE IS LOOKING IN THE AREA THE ROM NORMALLY OCCUPIES
	--PHANTOMHI and PHANTOMLO SIGNALS NEED TO BE ACCOUNTED FOR...WISH I KNEW MORE ABOUT THAT
	--Original PAL: U304

	PHANTOMHI <= D(17) WHEN _ROMCLK = '0';

	PHANTOMLO <= D(16) WHEN _ROMCLK = '0';

	ROM_ENABLE:PROCESS( _AS ) BEGIN

		IF (R_W = '1' AND _AS = '0') THEN
			--This is a read cycle
			IF (A(23 downto 16) >= x"f80000" AND A(23 downto 16) <= x"f8ffff" AND PHANTOMHI = '0') THEN 
				--High memory rom space, where ROMs normally reside when available.
				_CSROM <= '0';
			ELSIF (A(23 downto 16) >= x"000000" AND A(23 downto 16) <= x"00ffff"  AND PHANTOMLO = '0') THEN 
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


end Behavioral;

