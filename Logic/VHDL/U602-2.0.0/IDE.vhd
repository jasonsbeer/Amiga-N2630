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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IDE is

	PORT (
	
		A : IN STD_LOGIC_VECTOR (23 DOWNTO 2);
		nAS : IN STD_LOGIC;
		nRESET : IN STD_LOGIC;
		CPUCLK : IN STD_LOGIC;
		RnW : IN STD_LOGIC;
		nIDEACCESS : IN STD_LOGIC;
		IDE_PIO : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		
		nDIOW : OUT STD_LOGIC;
		nDIOR : OUT STD_LOGIC;
		nCS0 : INOUT STD_LOGIC;
		nCS1 : INOUT STD_LOGIC;
		DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		nIDERST : OUT STD_LOGIC;
		IDEDIR : OUT STD_LOGIC;
		DSACK : OUT STD_LOGIC;
		nIDEEN : OUT STD_LOGIC
	
	);

end IDE;

architecture Behavioral of IDE is

	SIGNAL ata_counter : INTEGER RANGE 0 TO 27;
	
	-----------------
	-- PIO TIMINGS --
	-----------------
	
	--T1 TIME IS THE SETUP TIME FOR _DIOx AFTER ASSERTION OF _CSx.
	--T2 TIME IS THE HOLD TIME OF THE _DIOx SIGNAL.
	--T9 TIME IS THE TIME AFTER NEGATION OF _DIOx THAT _CSx IS NEGATED. NORMALLY EQUAL TO OR GREATER THAN T4.
	--TEOC OFFSET IS AN OFFSET FROM ASSERTION OF DSACK (T2) TO THE TOTAL CYCLE TIME (T0).
		
	SIGNAL T1_TIME : INTEGER RANGE 0 TO 4;
	SIGNAL T2_TIME : INTEGER RANGE 0 TO 19;
	SIGNAL T9_TIME : INTEGER RANGE 0 TO 21;
	SIGNAL TEOC_OFFSET : INTEGER RANGE 0 TO 8;
	
	--PIO0
	CONSTANT T1_TIME_0 : INTEGER := 4; --6
	CONSTANT T2_TIME_0 : INTEGER := 19; --22
	CONSTANT T9_TIME_0 : INTEGER := 21; --24
	CONSTANT TEOC_OFFSET_0 : INTEGER := 8; --29
	
	--PIO2
	CONSTANT T1_TIME_2 : INTEGER := 2;
	CONSTANT T2_TIME_2 : INTEGER := 19;
	CONSTANT T9_TIME_2 : INTEGER := 20;
	CONSTANT TEOC_OFFSET_2 : INTEGER := 0;

	--PIO4
	CONSTANT T1_TIME_4 : INTEGER := 2;
	CONSTANT T2_TIME_4 : INTEGER := 6;
	CONSTANT T9_TIME_4 : INTEGER := 7;
	CONSTANT TEOC_OFFSET_4 : INTEGER := 7;
	
   --SANDISK ULTRA II TIMING
	CONSTANT T1_TIME_S : INTEGER := 0; --0
	CONSTANT T2_TIME_S : INTEGER := 3; --3
	CONSTANT T9_TIME_S : INTEGER := 4; --4
	CONSTANT TEOC_OFFSET_S : INTEGER := 0;


begin

	----------------
	-- PIO TIMING --
	----------------

	--THE PIO TIMING IS SET BY J902 AND J903.
	
	T1_TIME <= 		
		T1_TIME_0 WHEN IDE_PIO = "00" ELSE
		T1_TIME_2 WHEN IDE_PIO = "01" ELSE
		T1_TIME_4 WHEN IDE_PIO = "10" ELSE 
		T1_TIME_S WHEN IDE_PIO = "11";	
	
	T2_TIME <= 
		T2_TIME_0 WHEN IDE_PIO = "00" ELSE
		T2_TIME_2 WHEN IDE_PIO = "01" ELSE
		T2_TIME_4 WHEN IDE_PIO = "10" ELSE 
		T2_TIME_S WHEN IDE_PIO = "11";
		
	T9_TIME <= 
		T9_TIME_0 WHEN IDE_PIO = "00" ELSE
		T9_TIME_2 WHEN IDE_PIO = "01" ELSE
		T9_TIME_4 WHEN IDE_PIO = "10" ELSE 
		T9_TIME_S WHEN IDE_PIO = "11";
		
	TEOC_OFFSET <= 
		TEOC_OFFSET_0 WHEN IDE_PIO = "00" ELSE
		TEOC_OFFSET_2 WHEN IDE_PIO = "01" ELSE
		TEOC_OFFSET_4 WHEN IDE_PIO = "10" ELSE 
		TEOC_OFFSET_S WHEN IDE_PIO = "11";
	
	-------------------------------
	--    LIDE IDE INTERFACE     --
	-- DEVICE CONTROLLER SIGNALS --
	-------------------------------	
	
	--ENABLE THE IDE BUFFERS
	nIDEEN <= NOT (NOT nIDEACCESS AND NOT nAS);
	
	--SETS THE DIRECTION OF THE IDE BUFFERS
	IDEDIR <= NOT RnW;
	
	--PASS THE COMPUTER RESET SIGNAL TO THE IDE DEVICES.
	nIDERST <= nRESET;
	
	--IDE ADDRESS
	DA(2) <= A(11);
	DA(1) <= A(10);
	DA(0) <= A(9);
	nCS0 <= '0' WHEN nIDEACCESS = '0' AND nAS = '0' AND A(12) = '1' AND A(13) = '0' AND A(14) = '0' AND ata_counter >= 0 AND ata_counter < T9_TIME ELSE '1';
	nCS1 <= '0' WHEN nIDEACCESS = '0' AND nAS = '0' AND A(12) = '1' AND A(13) = '0' AND A(14) = '1' AND ata_counter >= 0 AND ata_counter < T9_TIME ELSE '1';
	
	--READ/WRITE
	nDIOR <= '0' WHEN nIDEACCESS = '0' AND nAS = '0' AND RnW = '1' AND ata_counter >= T1_TIME AND ata_counter < T2_TIME ELSE '1';  
	nDIOW <= '0' WHEN nIDEACCESS = '0' AND nAS = '0' AND RnW = '0' AND ata_counter >= T1_TIME AND ata_counter < T2_TIME ELSE '1'; 
	
	-------------------------------
	-- IDE DATA TRANSFER PROCESS --
	-------------------------------

	--ASSERT _DSACK1
	PROCESS (CPUCLK, nRESET) BEGIN
		IF nRESET = '0' THEN
			DSACK <= '0';
		ELSIF FALLING_EDGE(CPUCLK) THEN
			IF nIDEACCESS = '0' AND nAS = '0' AND ((RnW = '1' AND ata_counter = T2_TIME - 1) OR (RnW = '0' AND ata_counter = T2_TIME)) THEN 
				DSACK <= '1';
			ELSE
				DSACK <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	--IDE COUNTER PROCESS
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			ata_counter <= 0;
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF ata_counter > 0 THEN
				IF (RnW = '1' AND ata_counter = (T2_TIME + 1 + TEOC_OFFSET)) OR (RnW = '0' AND ata_counter = (T2_TIME + 2 + TEOC_OFFSET)) THEN
					ata_counter <= 0;
				ELSE
					ata_counter <= ata_counter + 1;					
				END IF;
			ELSIF nIDEACCESS = '0' AND nAS = '0' THEN
				ata_counter <= 1;
			END IF;
		
		END IF;
		
	END PROCESS; 

end Behavioral;