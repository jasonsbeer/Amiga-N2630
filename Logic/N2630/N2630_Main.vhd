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
           _CSROM : out  STD_LOGIC;
			  PHANTOMLO : in STD_LOGIC;
			  PHANTOMHI : in STD_LOGIC;
			  _AS : in STD_LOGIC;
			  _DS : in STD_LOGIC;
			  R_W : inout STD_LOGIC;
			  _BOSS : out STD_LOGIC;
			  _ABG : out STD_LOGIC;
			  _AAS : out STD_LOGIC;			  
			  _UUBE : out STD_LOGIC:='1';
			  _UMBE  : out STD_LOGIC:='1';
			  _LMBE : out STD_LOGIC:='1';
			  _LLBE : out STD_LOGIC:='1';
			  _OE0 : out STD_LOGIC:='1';
			  _OE1 : out STD_LOGIC:='1';
			  _WE0 : out STD_LOGIC:='1';
			  _WE1 : out STD_LOGIC:='1';
			  STERM : out STD_LOGIC:='1'
			  );			  
end N2630_Main;

architecture Behavioral of N2630_Main is

signal TWOMEG:STD_LOGIC; --Are we in the first 2 megabyte address space?
signal FOURMEG:STD_LOGIC; --Are we in the second 2 megabyte address space?

begin

---------------
-- RAM STUFF --
---------------

--THIS DETERMINES IF WE ARE IN THE FIRST OR SECOND 2 MEGS OF ADDRESS SPACE
--THIS IS ALL IN SECTION 12.5 OF THE 68030 MANUAL
--I DO NOT UNDERSTAND THE SIGNIFICANCE OF A30. IT IS SHOWN IN THE EQUATIONS OF THE MANUAL BUT IS NOT DISCUSSED.
--SO, I AM INCLUDING IT HERE. MAYBE IT SIGNIFIES A RAM ACCESS EVENT?
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
--Original PAL: Multiple
--the values in the process statement will trigger the process when one of them changes
RAM_ACCESS:PROCESS ( _AS, R_W, _DS ) BEGIN

	IF (FC(2 downto 0) /= x"7" AND _AS = '0' AND _DS = '0') THEN
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
			
		--ENABLE OUTPUT OR WRITE DEPENDING ON THE CPU REQUEST
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
				R_W = '0' AND _DS = '0' AND TWOMEG = '1'
			ELSE '1';
			
		_WE1 <= '0' -- BANK1
			WHEN
				R_W = '0' AND _DS = '0' AND FOURMEG = '1'
			ELSE '1';	
			
		--_STERM = Bus response signal that indicates a port size of 32 bits and
		--that data may be latched on the next falling clock edge.
		_STERM <= '0'
			WHEN
				TWOMEG = '1' OR FOURMEG = '1'
			ELSE '1';
			
				
		--ecs (EXTERNAL CYCLE START) HOW DOES THAT FIT IN?
		--DSACK0 AND 1 GO IN HERE SOMEWHERE (PORT SIZE ACK)
		--CACHE GOES IN HERE SOMEWHERE
		--_CBREQ _CBACK
		
	ELSE 
		--DEACTIVATE ALL THE RAM STUFF
		_UUBE <= '1';
		_UMBE <= '1';
		_LMBE <= '1';
		_LLBE <= '1';
		
		_OE0 <= '1';
		_OE1 <= '1';
		_WE0 <= '1';
		_WE1 <= '1';
		
		_STERM = '1';
	END IF;
	

END PROCESS RAM_ACCESS;

-------------------
-- END RAM STUFF --
-------------------


--AMIGA ADDRESS STROBE
--ORIGINAL PAL U501
--AAS:PROCESS(ASEN, CYCEND, EXTERN

--!CYCEND.D	= !DSACKEN & CYCEND;

--AT TIMES WE NEED TO GRANT BUS MASTERY TO THE A2000
--WE DO THAT HERE
--DO SOMETHING!

--WE NEED TO BECOME BOSS!
--AT STARTUP OR RESET WE ALLOW THE 68K TO DO ITS FIRST CYCLE AND THEN WE TAKE CONTROL OF THE BUS
--ORIGINAL PAL U504
--BOSS:PROCESS(_ABG, _AAS



--WE NEED TO SUPPLY A ROM ENABLE SIGNAL WHEN THE ADDRESS
--SPACE IS LOOKING IN THE AREA THE ROM NORMALLY OCCUPIES
--Original PAL: U304
ROM_ENABLE:PROCESS( A(23 downto 16), PHANTOMHI, PHANTOMLO, _AS, R_W ) BEGIN

	IF (R_W = '1' AND _AS = '1') THEN
		--This is a read cycle
		IF (A(23 downto 16) >= x"f80000" AND A(23 downto 16) <= x"f8ffff") THEN 
			--This is the high rom address space
			--Set _CSROM low to activate the ROMs
			_CSROM <= '0';
		ELSIF (A(23 downto 16) >= x"000000" AND A(23 downto 16) <= x"00ffff") THEN 
			--This is the low rom memory space
			--Set _CSROM low to activate the ROMs
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

