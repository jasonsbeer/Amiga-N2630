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
		nDS : IN STD_LOGIC;
		nAS : IN STD_LOGIC;
		nGRESET : IN STD_LOGIC;
		INTRQ : IN STD_LOGIC;
		CPUCLK : IN STD_LOGIC;
		RnW : IN STD_LOGIC;
		FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		nIDEDIS : IN STD_LOGIC;

		D : INOUT STD_LOGIC;

		nIDEACCESS : INOUT STD_LOGIC;
		nDIOW : OUT STD_LOGIC;
		nDIOR : OUT STD_LOGIC;
		nCS0 : OUT STD_LOGIC;
		nCS1 : OUT STD_LOGIC;
		DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		nIDERST : OUT STD_LOGIC;
		IDEDIR : OUT STD_LOGIC;
		nINT2 : OUT STD_LOGIC;
		DSACK : OUT STD_LOGIC;
		nIDEEN : OUT STD_LOGIC
	
	);

end IDE;

architecture Behavioral of IDE is

	SIGNAL gayleid_space : STD_LOGIC;
	SIGNAL gaylereg_space : STD_LOGIC;
	SIGNAL gayle_space : STD_LOGIC;
	SIGNAL gayleid : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL dataoutgayle : STD_LOGIC;
	SIGNAL intchg : STD_LOGIC;
	SIGNAL ideintenable : STD_LOGIC;
	SIGNAL ide_space : STD_LOGIC;
	SIGNAL cs1en : STD_LOGIC;
	SIGNAL cs0en : STD_LOGIC;
	SIGNAL renable : STD_LOGIC;
	SIGNAL wenable : STD_LOGIC;
	SIGNAL idesacken : STD_LOGIC;
	SIGNAL access16 : STD_LOGIC;
	SIGNAL cpu_space : STD_LOGIC;
	
	SIGNAL ata_counter : INTEGER RANGE 0 TO 30;	
	
	--IDE PIO MODE ZERO TIMINGS
	--THESE TIMES ARE THE SAME FOR BOTH 8 AND 16 BIT CYCLES
	CONSTANT T0 : INTEGER := 0;
	CONSTANT T1 : INTEGER := 6; --70ns
	CONSTANT T4 : INTEGER := 2; --30ns T4 IS THE HOLD TIME FOR WRITES AND MUST BE GREATER THAN T9.
	
	--8 BIT TIMINGS
	CONSTANT T2_8 : INTEGER := 16; --290ns	
	CONSTANT Teoc_8 : INTEGER := 5; --600ns

	--16 BIT TIMINGS
	CONSTANT T2_16 : INTEGER := 10; --165ns
	CONSTANT Teoc_16 : INTEGER := 12; --600ns
	
	--FINAL 8 BIT TIMINGS
	CONSTANT PIO0_T1_8 : INTEGER := T1;
	CONSTANT PIO0_T2_8 : INTEGER := T1 + T2_8;
	CONSTANT PIO0_T4_8 : INTEGER := T1 + T2_8 + T4;
	CONSTANT PIO0_Teoc_8 : INTEGER := T1 + T2_8 + T4 + Teoc_8;
	
	--FINAL 16 BIT TIMINGS
	CONSTANT PIO0_T1_16 : INTEGER := T1;
	CONSTANT PIO0_T2_16 : INTEGER := T1 + T2_16;
	CONSTANT PIO0_T4_16 : INTEGER := T1 + T2_16 + T4;
	CONSTANT PIO0_Teoc_16 : INTEGER := T1 + T2_16 + T4 + Teoc_16;

begin

	---------------------
	-- ADDRESS DECODES --
	---------------------

	cpu_space <= '1' WHEN FC(2 downto 0) = "111" ELSE '0';
	ide_space <= '1' WHEN A(23 DOWNTO 15) = "110110100" AND cpu_space = '0' ELSE	'0';		
	gayleid_space <= '1' WHEN A(23 DOWNTO 15) = "110111100" AND cpu_space = '0' AND nIDEDIS = '1' ELSE '0';
	gaylereg_space <= '1' WHEN A(23 DOWNTO 15) = "110110101" AND cpu_space = '0' ELSE '0';

	-------------------------------
	-- ADDRESS DECODE SIGNALLING --
	-------------------------------

	gayle_space <= '1' WHEN gayleid_space = '1' OR gaylereg_space = '1' ELSE '0';	
	
	nIDEACCESS <= '0' WHEN gayleid_space = '1' OR gaylereg_space = '1' OR ide_space = '1' ELSE '1';

	-----------------------
	-- DATA TRANSFER ACK --
	-----------------------
	
	--nDSACK1 <= '0' 
	--		WHEN (gayle_space = '1' AND nDS = '0') OR idesacken = '1' 
	--	ELSE '1' 
	--		WHEN (ide_space = '1' AND idesacken = '0') OR gayle_space = '1'
	--	ELSE 'Z';

	DSACK <= '1' WHEN (gayle_space = '1' AND nDS = '0') OR idesacken = '1' ELSE '0';
	--DSACK <= '1' WHEN idesacken = '1' ELSE '0';
	--GSACK <= '1' WHEN gayle_space = '1' AND nDS = '0' ELSE '0';
	
	------------------------------------------------------
	-- GAYLE COMPATABLE HARD DRIVE CONTROLLER INTERFACE --
	------------------------------------------------------

	------------------------------------------------------
	--WE ARE USING THE AMIGA OS GAYLE ATA/IDE INTERFACE SUPPORTING PIO WITH UP TO 2 DRIVES.
	--IT IS SIMPLE TO IMPLEMENT AND READY OUT OF THE BOX WITH KS => 37.300.
	--COMPATABILITY CAN BE ADDED TO EARLIER KICKSTARTS BY ADDING THE APPROPRIATE SCSI.DEVICE TO ROM.
	--TO TRICK AMIGA OS INTO THINKING WE HAVE A GAYLE ADDRESS DECODER, WE NEED TO RESPOND TO GAYLE SPECIFIC REGISTERS.
	--SEE THE GAYLE SPECIFICATIONS FOR MORE DETAILS.
	--WE DISABLE THE IDE PORT BY IGNORING THE GAYLE CONFIGURATION REGISTERS, WHICH TELLS AMIGA OS THERE IS NO GAYLE HERE.
	------------------------------------------------------

	------------------------------------
	-- GAYLE COMPATABLE IDE INTERFACE --
	--       INTERRUPT HANDLER        --
	------------------------------------
	
	intchg <= '1' WHEN INTRQ = '1' ELSE '0';	
	
	nINT2 <= '0' WHEN intchg = '1' AND ideintenable = '1' ELSE 'Z'; 

	------------------------------------
	-- GAYLE COMPATABLE IDE INTERFACE --
	--           REGISTERS            --
	------------------------------------
	
	D <= dataoutgayle WHEN (gayleid_space = '1' OR gaylereg_space = '1') AND RnW = '1' ELSE 'Z';

	PROCESS (nDS, nGRESET) BEGIN
	
		IF nGRESET = '0' THEN
		
			gayleid <= "1101";
			ideintenable <= '0';
			
		ELSIF FALLING_EDGE (nDS) THEN
		
			IF gayleid_space = '1' THEN

				--11010000 = $D0 = ECS Gayle, 11010001 = $D1 = AGA Gayle
				--GAYLE_ID CONFIGURATION REGISTER IS AT $DE1000. WHEN ADDRESS IS $DE1000 AND R_W IS READ, BIT 7 IS READ.
				--BELOW IS A SIMPLE SHIFT REGISTER TO LOAD THE GAYLE ID VALUE. 
				--IF ANYTHING IS WRITTEN TO $DE1000, THAT MEANS THE REGISTER HAS BEEN RESET AND WE NEED TO RE-ESTABLISH GAYLE.
		
				IF RnW = '1' THEN
				
					dataoutgayle <= gayleid(3);
					gayleid <= gayleid (2 DOWNTO 0) & "0";
					
				ELSE
				
					gayleid <= "1101";
					
				END IF;
				
			ELSIF gaylereg_space = '1' THEN
			
				IF RnW = '1' THEN
				
					--READ MODE
					
					CASE A(14 DOWNTO 12) IS
												
						WHEN "000" => --$8
							
							dataoutgayle <= INTRQ;										
						
						--WHEN "001" => --$9

							--dataoutgayle <= intchg;
					
						WHEN "010" => --$A
						
							dataoutgayle <= ideintenable;	
							
						WHEN OTHERS =>
						
							dataoutgayle <= 'Z';
						
					END CASE;
					
				ELSE
				
					--WRITE MODE
					
					CASE A(14 DOWNTO 12) IS
					
						--WHEN "001" => --$9

							--clrint <= NOT D;
					
						WHEN "010" => --$A
						
							ideintenable <= D;
							
						WHEN OTHERS =>						
							
					END CASE;				
				
				END IF;
				
			
			END IF;
			
		END IF;
		
	END PROCESS;	
	
	------------------------------------
	-- GAYLE COMPATABLE IDE INTERFACE --
	--   DEVICE CONTROLLER SIGNALS    --
	------------------------------------	
	
	--ENABLE THE IDE BUFFERS
	nIDEEN <= '0' WHEN ide_space = '1' AND nAS = '0' ELSE '1';
	
	--SETS THE DIRECTION OF THE IDE BUFFERS
	IDEDIR <= '0' WHEN RnW = '1' ELSE '1';
	
	--PASS THE COMPUTER RESET SIGNAL TO THE IDE DEVICES.
	nIDERST <= '0' WHEN nGRESET = '0' ELSE '1';
	
	--IDE ADDRESS CONSISTS OF BOTH CHIP SELECT SIGNALS AND THREE 68030 ADDRESS SIGNALS.
	nCS0 <= '0' WHEN cs0en = '1' ELSE '1';
	nCS1 <= '0' WHEN cs1en = '1' ELSE '1';	
	DA(2) <= '1' WHEN A(4) = '1' ELSE '0';
	DA(1) <= '1' WHEN A(3) = '1' ELSE '0';
	DA(0) <= '1' WHEN A(2) = '1' ELSE '0';

	--READ/WRITE SIGNALS
	nDIOR <= '0' WHEN renable = '1' ELSE '1';
	nDIOW <= '0' WHEN wenable = '1' ELSE '1';
	
	------------------------------------
	-- GAYLE COMPATABLE IDE INTERFACE --
	--       DEVICE CONTROLLER        --
	------------------------------------
	
	--THE IDE INTERFACE IS ASYNCHRONOUS WITH THE 68030. IN ORDER TO 
	--TIME EVENTS CORRECTLY, WE COUNT CLOCK EDGES. THIS MEANS ANY
	--TIME WE CHANGE CLOCK SPEEDS, THESE TIMINGS MUST BE CONSIDERED.
	
	PROCESS (CPUCLK, nGRESET) BEGIN
	
		IF nGRESET = '0' THEN
		
			renable <= '0';
			wenable <= '0';
			idesacken <= '0';
			cs0en <= '0';
			cs1en <= '0';
			ata_counter <= T0;
			access16 <= '0';
		
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			--INCREMENT THE COUNTER WHEN WE ARE IN A CYCLE.
			IF ata_counter = T0 THEN
			
				IF ide_space = '1' AND nDS = '0' THEN
							
					ata_counter <= 1;
					
					--SET THE CHIP SELECT SIGNAL.
					IF A(12) = '0' THEN
						cs0en <= '1';
					ELSE
						cs1en <= '1';
					END IF;
					
					--SET THE CYCLE TYPE.
					IF A(13) = '1' THEN				
						access16 <= '1';						
					ELSE					
						access16 <= '0';						
					END IF;
					
				END IF;
				
			ELSE
			
				ata_counter <= ata_counter + 1;
				
			END IF;
			
			CASE access16 IS
			
				WHEN '0' =>
				
					--8 BIT CYCLE.
			
					CASE ata_counter IS
					
						WHEN PIO0_T1_8 =>
						
							--T1 IS THE SETUP TIME FOR _DIOR AND _DIOW.
							IF RnW = '1' THEN
								renable <= '1';
							ELSE
								wenable <= '1';
							END IF;
								
						WHEN PIO0_T2_8 - 2 =>
						
							--ASSERT _DSACKx
							IF RnW = '1' THEN
								idesacken <= '1';
							END IF;
							
						WHEN PIO0_T2_8 =>
						
							--T2 IS THE LENGTH OF TIME _DIOR OR _DIOW IS ASSERTED.
							--WHEN IT HAS ELAPSED, WE CAN NEGATE THOSE SIGNALS.
							renable <= '0';
							wenable <= '0';
							
							IF RnW = '1' THEN
								idesacken <= '0';
							ELSE
								idesacken <= '1';
							END IF;
							
						WHEN PIO0_T4_8 =>
						
							--T4 IS THE HOLD TIME FOR WRITES.
							idesacken <= '0';
							cs0en <= '0';
							cs1en <= '0';
							
						WHEN PIO0_Teoc_8 =>
							
							ata_counter <= T0;					
							
						WHEN others =>		
						
					END CASE;
					
				WHEN '1' =>
					
					--16 BIT CYCLE.
					
					CASE ata_counter IS
					
						WHEN PIO0_T1_16 =>
						
							--T1 IS THE SETUP TIME FOR _DIOR AND _DIOW.
							
							IF RnW = '1' THEN
								renable <= '1';
							ELSE
								wenable <= '1';
							END IF;
							
						WHEN PIO0_T2_16 - 2 =>
						
							--ASSERT _DSACKx
							IF RnW = '1' THEN
								idesacken <= '1';
							END IF;
							
						WHEN PIO0_T2_16 =>
						
							--T2 IS THE LENGTH OF TIME _DIOR OR _DIOW IS ASSERTED.
							--WHEN IT HAS ELAPSED, WE CAN NEGATE THOSE SIGNALS.
							renable <= '0';
							wenable <= '0';
							
							IF RnW = '1' THEN
								idesacken <= '0';
							ELSE
								idesacken <= '1';
							END IF;
							
						WHEN PIO0_T4_16 =>
						
							--T4 IS THE HOLD TIME FOR WRITES.
							idesacken <= '0';
							cs0en <= '0';
							cs1en <= '0';
							
						WHEN PIO0_Teoc_16 =>
							
							ata_counter <= T0;					
							
						WHEN others =>		
						
					END CASE;
					
				WHEN others =>
				
			END CASE;				
		
		END IF;	
	
	END PROCESS;

end Behavioral;