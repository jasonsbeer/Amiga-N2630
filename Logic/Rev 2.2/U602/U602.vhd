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
-- Engineer:       JASON NEUS
-- 
-- Create Date:    November 27, 2022 
-- Design Name:    N2630 U602 CPLD
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES LOGIC FOR ZORRO 3 SDRAM CONTROLLER AND PSUEDO-GAYLE IDE CONTROLLER
--
-- Hardware Revision: 2.2
-- Additional Comments: 
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

entity U602 is
    Port ( 
				A : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
				RnW : IN STD_LOGIC; --READ/WRITE SIGNAL FROM 680x0
				nAS : IN STD_LOGIC; --ADDRESS STROBE
				IORDY : IN STD_LOGIC; --IDE I/O READY
				INTRQ : IN STD_LOGIC; --IDE INTERUPT REQUEST
				CPUCLK : IN STD_LOGIC; --25MHz CPU CLOCK
				A7M : IN STD_LOGIC; --7MHz AMIGA CLOCK
				nRESET : IN STD_LOGIC; --SYSTEM RESET SIGNAL VALID IN 68000 AND 68030 MODE
				--nGRESET : IN STD_LOGIC; --68030 ONLY RESET SIGNAL
				nIDEDIS : IN STD_LOGIC; --IDE DISABLE
				nDS : IN STD_LOGIC; --68030 DATA STROBE
				FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --68030 FUNCTION CODES
				SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 TRANSFER SIZE SIGNALS
				RAMSIZE : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE JUMPERS
	    		--nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
				
				D : INOUT STD_LOGIC; --THIS IS D31 OF THE 68030
				nMEMZ3 : INOUT STD_LOGIC; --SIGNALS THE OTHER LOGIC THAT WE ARE RESPONDING TO THE RAM ADDRESS SPACE		
				nIDEACCESS : INOUT STD_LOGIC; --SIGNALS THE OTHER LOGIC THAT WE ARE RESPONDING TO THE IDE ADDRESS SPACE
				nINT2 : INOUT STD_LOGIC; --INT2 DRIVEN BY IDE INTRQ
				nDIOR : INOUT STD_LOGIC; --IDE READ SIGNAL
				nDIOW : INOUT STD_LOGIC; --IDE WRITE SIGNAL
							
				nCS0 : OUT STD_LOGIC; --IDE CHIP SELECT 0
				nCS1 : OUT STD_LOGIC; --IDE CHIP SELECT 1
				DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --IDE ADDRESS LINES
				IDEDIR : OUT STD_LOGIC; --IDE BUFFER DIRECTION
				nIDEEN : OUT STD_LOGIC; --IDE BUFFER ENABLE
				nIDERST : OUT STD_LOGIC; --IDE RESET
				
				nDSACK : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
				nUUBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
				nUMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
				nLMBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
				nLLBE : OUT STD_LOGIC; --68030 DYNAMIC BUS SIZING OUTPUT
				EMA : OUT STD_LOGIC_VECTOR (12 DOWNTO 0); --ZORRO 3 MEMORY BUS
				BANK0 : OUT STD_LOGIC; --SDRAM BANK0
				BANK1 : OUT STD_LOGIC; --SDRAM BANK1
				nEMCAS : OUT STD_LOGIC; --CAS
				nEMRAS : OUT STD_LOGIC; --RAS
				nEMWE : OUT STD_LOGIC; --WRITE ENABLE
				EMCLKE : OUT STD_LOGIC; --CLOCK ENABLE
				nEMCS0 : OUT STD_LOGIC; --CHIP SELECT LOW BANK
				nEMCS1 : OUT STD_LOGIC --CHIP SELECT HIGH BANK
				--nSTERM : INOUT STD_LOGIC --68030 SYNCRONOUS TERMINATION SIGNAL
	    		--nCBACK : OUT STD_LOGIC --68030 CACHE BURST ACK
				--nBERR : OUT STD_LOGIC; --BUS ERROR FOR BURST MODE
			);
end U602;

architecture Behavioral of U602 is
	
	--MEMORY SIGNALS
	SIGNAL memsel : STD_LOGIC; --ARE WE IN THE ZORRO 3 MEMORY SPACE?
	SIGNAL cs_mem : STD_LOGIC; --ARE WE IN THE UPPER SDRAM PAIR?
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 127 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	SIGNAL dsacken : STD_LOGIC;
	SIGNAL chipselected : STD_LOGIC;
	
	--THE SDRAM COMMAND CONSTANTS ARE: _CS, _RAS, _CAS, _WE
	CONSTANT ramstate_NOP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111"; --SDRAM NOP
	CONSTANT ramstate_PRECHARGE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010"; --SDRAM PRECHARGE ALL;
	CONSTANT ramstate_BANKACTIVATE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ramstate_READ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ramstate_WRITE : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ramstate_AUTOREFRESH : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";
	CONSTANT ramstate_MODEREGISTER : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	
	--DEFINE THE SDRAM STATE MACHINE STATES
	TYPE SDRAM_STATE IS ( PRESTART, POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, RAS_STATE, CAS_STATE );	
	SIGNAL CURRENT_STATE : SDRAM_STATE;
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL sdramstartup : STD_LOGIC;
	
	--GAYLE SIGNALS
	SIGNAL gayleid : STD_LOGIC_VECTOR (7 DOWNTO 0); --THIS IS THE GAYLE ID VALUE
	SIGNAL gayle_space : STD_LOGIC; --ARE WE IN ANY OF THE GAYLE REGISTER SPACES?
	SIGNAL gayleid_space : STD_LOGIC;
	SIGNAL gaylereg_space : STD_LOGIC;
	SIGNAL dataoutgayle : STD_LOGIC;
	SIGNAL ideintenable : STD_LOGIC;
	SIGNAL intreq : STD_LOGIC;
	SIGNAL intchg : STD_LOGIC;
	SIGNAL clrint : STD_LOGIC;
	SIGNAL intlast : STD_LOGIC;
	SIGNAL ide_space : STD_LOGIC;
	SIGNAL idesacken : STD_LOGIC;
	
	--IDE STATE MACHINE SIGNALS
	SIGNAL renable : STD_LOGIC;
	SIGNAL wenable : STD_LOGIC;
	
	CONSTANT PIO0_T1 : INTEGER := 1; --70ns
	CONSTANT PIO0_T2 : INTEGER := 8; --165ns
	CONSTANT PIO0_T4 : INTEGER := 1; --30ns
	CONSTANT PIO0_Teoc : INTEGER := 4; --600ns

	SIGNAL ata_counter : INTEGER RANGE 0 TO 30;
	CONSTANT T0 : INTEGER := 0;
	CONSTANT T1 : INTEGER := PIO0_T1;
	CONSTANT T2 : INTEGER := PIO0_T1 + PIO0_T2;
	--CONSTANT T4 : INTEGER := PIO0_T1 + PIO0_T2 + PIO0_T4;
	--CONSTANT Tdsack_read : INTEGER := PIO0_T1 + PIO0_T2 - 2;
	--CONSTANT Tdsack_write : INTEGER := PIO0_T1 + PIO0_T2 - 1;
	CONSTANT Teoc : INTEGER := PIO0_T1 + PIO0_T2 + PIO0_T4 + PIO0_Teoc;
	
	--ATA STATE MACHINE SIGNALS
	
	--25MHz CLOCK CYCLES NEEDED TO FULFILL MODE TIMING REQUIREMENTS FOR 16 BIT CYCLES.
	--TIME|MODE0|MODE1|MODE2|MODE3
	------------------------------
	-- t1 |  2  |  2  |  1  |  1
	-- t2 |  5  |  4  |  3  |  2
	-- eoc|  8  |  4  |  2  |  2

	--25MHz CLOCK CYCLES NEEDED TO FULFILL MODE TIMING REQUIREMENTS FOR 8 BIT CYCLES.
	--TIME|MODE0|MODE1|MODE2|MODE3
	------------------------------
	-- t1 |  2  |  2  |  1  |  1
	-- t2 |  8  |  8  |  8  |  2
	-- eoc|  5  |  1  |  1  |  2

	-- eoc (end of cycle) is T2i, T9, or T0-T1-T2. Whichever is greatest.

	
begin

	---------------------------
	-- SDRAM REFRESH COUNTER --
	---------------------------
	
	--THE REFRESH OPERATION MUST BE PERFORMED 8192 TIMES EACH 64ms.
	--SO...8192 TIMES IN 64,000,000ns. THATS ONCE EVERY 7812.5ns.
	--7812.5ns IS EQUAL TO APPROX...
	
	--56 7.16MHz CLOCK CYCLES
	--185 25MHz CLOCK CYCLES
	--244 33MHz CLOCK CYCLES
	--296 40MHz CLOCK CYCLES
	--370 50MHz CLOCK CYCLES
	
	--WE USE THE 7MHz CLOCK TO DRIVE THE REFRESH COUNTER BECAUSE THAT 
	--WILL ALWAYS BE AVAILABLE NO MATTER OUR N2630 CONFIGURATION.
	--SINCE WE ARE JUMPING BETWEEN CLOCK DOMAINS, WE NEED TO HAVE
	--TWO PROCESSES TO ACCOMODATE THE JUMP.
	
	refreset <= '1' WHEN CURRENT_STATE = AUTO_REFRESH ELSE '0';
	
	PROCESS (A7M, refreset) BEGIN
	
		IF refreset = '1' THEN
		
			REFRESH_COUNTER <= 0;			
			
		ELSIF RISING_EDGE (A7M) THEN
		
			REFRESH_COUNTER <= REFRESH_COUNTER + 1;
			
		END IF;
		
	END PROCESS;
	
	
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			refresh <= '0';
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF REFRESH_COUNTER >= REFRESH_DEFAULT THEN
			
				refresh <= '1';
				
			ELSE
			
				refresh <= '0';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	-------------------------------
	-- ZORRO 3 MEMORY ADDRESSING --
	-------------------------------
			
	--THIS LOGIC SUPPORTS UP TO 256MB IN THE ZORRO 3 EXPANSION SPACE.	
	--THE ADDRESS SPACE FOR THE VARIOUS RANGES POSSIBLE ARE SPLIT IN
	--HALF IN THE EVENT BOTH SDRAM BANKS ARE POPULATED. BOTH BANKS MUST
	--BE POPULATED TO ACHIEVE 256MB.
	--EXPANSION.LIBRARY IGNORES CARDS FROM $10000000 - $3FFFFFFF, SO
	--WE START AT $40000000.
	
	--$40000000 - $400FFFFF = 8MB
	--$40000000 - $40FFFFFF = 16MB
	--$40000000 - $41FFFFFF = 32MB
	--$40000000 - $43FFFFFF = 64MB
	--$40000000 - $47FFFFFF = 128MB
	--$40000000 - $4FFFFFFF = 256MB

	nMEMZ3 <= '0'
		WHEN
			FC(2 DOWNTO 0) /= "111" AND A(31 DOWNTO 28) = "0100"
		ELSE 			 
			'1';
	
	memsel <= '1' WHEN nMEMZ3 = '0' AND nAS = '0' ELSE '0';
	
	
	PROCESS ( CPUCLK ) BEGIN
	
		IF FALLING_EDGE(CPUCLK) AND nMEMZ3 = '0' THEN	
				
			CASE RAMSIZE (2 DOWNTO 0) IS
			
				--THE NUMBER OF ADDRESS PINS AVAILABLE FOR THE ROW ADDRESS IS AS FOLLOWS:
				-- 4Mx16 - A11-A0 (16MB PER PAIR)
				-- 8Mx16 - A11-A0 (32MB PER PAIR)
				--16Mx16 - A12-A0 (64MB PER PAIR)
				--32Mx16 - A12-A0 (128MB PER PAIR)
				
				--THE NUMBER OF ADDRESS PINS AVAILABLE FOR THE COLUMN ADDRESS IS AS FOLLOWS:
				-- 4Mx16 - A7-A0 (16MB PER PAIR)
				-- 8Mx16 - A8-A0 (32MB PER PAIR)
				--16Mx16 - A8-A0 (64MB PER PAIR)
				--32Mx16 - A9-A0 (128MB PER PAIR)
				
				WHEN "010" => --32MB BOTH MEMORY BANKS POPULATED 4Mx16
					cs_mem <= A(24);
					
				WHEN "100" => --64MB BOTH MEMORY BANKS POPULATED 8Mx16
					cs_mem <= A(25);
					
				WHEN "000" => --128MB BOTH MEMORY BANKS POPULATED 16Mx16
					cs_mem <= A(26);
					
				WHEN "110" => --256MB BOTH MEMORY BANKS POPULATED 32Mx16
					cs_mem <= A(27);
					
				WHEN OTHERS =>
				
					cs_mem <= '0';
					
					--HOW ABOUT SOME NICE ASCII ART?
					
					--	.-----------------------------------------------------------------------------.
					--	||Es| |F1 |F2 |F3 |F4 |F5 | |F6 |F7 |F8 |F9 |F10|                  C= AMIGA   |
					--	||__| |___|___|___|___|___| |___|___|___|___|___|                             |
					--	| _____________________________________________     ________    ___________   |
					--	||~  |! |" |§ |$ |% |& |/ |( |) |= |? |` || |<-|   |Del|Help|  |{ |} |/ |* |  |
					--	||`__|1_|2_|3_|4_|5_|6_|7_|8_|9_|0_|ß_|´_|\_|__|   |___|____|  |[ |]_|__|__|  |
					--	||<-  |Q |W |E |R |T |Z |U |I |O |P |Ü |* |   ||               |7 |8 |9 |- |  |
					--	||->__|__|__|__|__|__|__|__|__|__|__|__|+_|_  ||               |__|__|__|__|  |
					--	||Ctr|oC|A |S |D |F |G |H |J |K |L |Ö |Ä |^ |<'|               |4 |5 |6 |+ |  |
					--	||___|_L|__|__|__|__|__|__|__|__|__|__|__|#_|__|       __      |__|__|__|__|  |
					--	||^    |> |Y |X |C |V |B |N |M |; |: |_ |^     |      |A |     |1 |2 |3 |E |  |
					--	||_____|<_|__|__|__|__|__|__|__|,_|._|-_|______|    __||_|__   |__|__|__|n |  |
					--	|   |Alt|A  |                       |A  |Alt|      |<-|| |->|  |0    |. |t |  |
					--	|   |___|___|_______________________|___|___|      |__|V_|__|  |_____|__|e_|  |
					--	|                                                                             |
					--	`-----------------------------------------------------------------------------'
					
					--https://www.asciiart.eu/computers/amiga
				
			END CASE;
		
		END IF;
		
	END PROCESS;	
	
	-----------------------------
	-- SDRAM DATA MASK ACTIONS --
	-----------------------------		
		
	nUUBE <= datamask(3);
	nUMBE <= datamask(2);
	nLMBE <= datamask(1);
	nLLBE <= datamask(0);	
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF nRESET = '0' THEN 
		
			datamask <= "1111";
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN

			IF (memsel = '1') THEN		

				IF RnW = '0' THEN
				
					--FOR WRITES, WE ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING 
					--ON WHAT THE ACCESSING DEVICE IS ASKING FOR. DISCUSSION OF PORT 
					--SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL
					
					--UPPER UPPER BYTE ENABLE (D31..24)
					IF 
						A(1 downto 0) = "00"
					THEN			
						datamask(3) <= '0'; 
					ELSE 
						datamask(3) <= '1';
					END IF;

					--UPPER MIDDLE BYTE (D23..16)
					IF 
						(A(1 downto 0) = "01") OR
						(A(1) = '0' AND SIZ(0) = '0') OR
						(A(1) = '0' AND SIZ(1) = '1')
					THEN
						datamask(2) <= '0';
					ELSE
						datamask(2) <= '1';
					END IF;

					--LOWER MIDDLE BYTE (D15..8)
					IF 
						(A(1 downto 0) = "10") OR
						(A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0') OR
						(A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1') OR
						(A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0')
					THEN
						datamask(1) <= '0';
					ELSE
						datamask(1) <= '1';
					END IF;

					--LOWER LOWER BYTE (D7..0)
					IF 
						(A(1 downto 0) = "11") OR
						(A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1') OR
						(SIZ(0) = '0' AND SIZ(1) = '0') OR
						(A(1) = '1' AND SIZ(1) ='1')
					THEN
						datamask(0) <= '0';
					ELSE
						datamask(0) <= '1';
					END IF;	
				
				ELSE
				
					--FOR READS, WE RETURN ALL 32 BITS
					datamask <= "0000";
					
				END IF;
				
			ELSE
			
				datamask <= "1111";

			END IF;	
			
		END IF;
		
	END PROCESS;
	
	---------------------------
	-- SDRAM COMMAND ACTIONS --
	---------------------------
	
	--SDRAM COMMANDS ARE SAMPLED ON THE RISING EDGE. WE ARE SETTING COMMANDS ON THE 
	--FALLING EDGE SO THE COMMANDS ARE STABLE AT THE MOMENT THE SDRAM LATCHES THE COMMAND.
	
	--BECAUSE WE ALLOW ONE OR TWO BANKS OF 32-BIT SDRAM, WE MUST DIRECT THE CHIP
	--SELECT SIGNAL TO THE CORRECT BANK, OR BOTH BANKS, DEPENDING ON THE DESIRED FUNCTION.
	--BOTH BANKS ARE SELECTED FOR PROGRAMMING AND REFRESHING.
	--DURING MEMORY ACCESS BY THE CPU, ONLY ONE BANK IS SELECTED.
	
	chipselected <= '1' WHEN sdramstartup = '1' OR CURRENT_STATE = AUTO_REFRESH ELSE '0';
	
	nEMCS0 <= '0' WHEN (cs_mem = '0' AND sdramcom(3) = '0') OR chipselected = '1' ELSE '1';
	nEMCS1 <= '0' WHEN (cs_mem = '1' AND sdramcom(3) = '0') OR chipselected = '1' ELSE '1';
	
	nEMRAS <= sdramcom(2);
	nEMCAS <= sdramcom(1);	
	nEMWE <= sdramcom(0);	
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF (nRESET = '0') THEN 
		
				--THE AMIGA HAS BEEN RESET OR JUST POWERED UP
				CURRENT_STATE <= PRESTART;				
				sdramcom <= ramstate_NOP;				
				SDRAM_START_REFRESH_COUNT <= '0';
				sdramstartup <= '1';
				
				EMCLKE <= '0';
				COUNT <= 0;
				dsacken <= '0';
				
				EMA(12 DOWNTO 0) <= (OTHERS => '0');
				BANK0 <= '0';
				BANK1 <= '0';
		
		ELSIF ( FALLING_EDGE (CPUCLK) ) THEN			
		
			--PROCEED WITH SDRAM STATE MACHINE
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO.
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF nMEMZ2 IS ASSERTED.
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED, WE ARE IN THE ZORRO 2 ADDRESS SPACE, AND THE RAM IS AUTOCONFIGured.
			CASE CURRENT_STATE IS
			
				WHEN PRESTART =>
					--SET THE POWERUP SETTINGS SO THEY ARE LATCHED ON THE NEXT CLOCK EDGE
				
					CURRENT_STATE <= POWERUP;
					sdramcom <= ramstate_NOP;				
			
				WHEN POWERUP =>
					--COLD OR WARM STARTUP. WE RELY ON THE SYSTEM RESET SIGNAL
					--TO PROVIDE THE 200 microsecond NEEDED TO STABALIZE THE SDRAM.

					CURRENT_STATE <= POWERUP_PRECHARGE;
					EMA(12 downto 0) <= ("0010000000000"); --PRECHARGE ALL			
					sdramcom <= ramstate_PRECHARGE;
					EMCLKE <= '1';
					
				WHEN POWERUP_PRECHARGE =>
				
					CURRENT_STATE <= MODE_REGISTER;
					EMA(12 downto 0) <= "0001000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2
					sdramcom <= ramstate_MODEREGISTER;
				
				WHEN MODE_REGISTER =>
				
					--TWO CLOCK CYCLES ARE NEEDED FOR THE REGISTER TO, WELL, REGISTER
					
					IF (COUNT = 0) THEN
						--NOP ON THE SECOND CLOCK DURING MODE REGISTER
						sdramcom <= ramstate_NOP;
					ELSE
						--NOW NEED TO REFRESH TWICE
						CURRENT_STATE <= AUTO_REFRESH;
						sdramcom <= ramstate_AUTOREFRESH;
						sdramstartup <= '0'; --SDRAM IS PROGRAMMED.
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh minimum time is 60ns. We must NOP enough clock cycles to meet this requirement.
					--50MHz IS 20ns PER CYCLE, 40MHz IS 24ns, 33 IS 30ns, 25MHz IS 40ns.
					--SO, 3 CLOCK CYCLES FOR 50 AND 40 MHz AND 2 CLOCK CYCLES FOR 33 AND 25 MHz.					
					
					--ADD A CLOCK CYCLE TO ACHIEVE THE MINIMIM REFRESH TIME OF 60ns
					--THIS IS REALLY ONLY NEEDED AT 40MHz AND GREATER, BUT WE COMPROMISE HERE
					--AND APPLY TO EVERYTHING.
					COUNT <= 0;
					
					CURRENT_STATE <= AUTO_REFRESH_CYCLE;
					sdramcom <= ramstate_NOP;
					
				WHEN AUTO_REFRESH_CYCLE =>
					
					IF (COUNT = 1) THEN 
						--ENOUGH CLOCK CYCLES HAVE PASSED. WE CAN PROCEED.
						
						IF (SDRAM_START_REFRESH_COUNT = '0') THEN		
							--DO WE NEED TO REFRESH AGAIN (STARTUP)?
						
							CURRENT_STATE <= AUTO_REFRESH;
							sdramcom <= ramstate_AUTOREFRESH;
							
							SDRAM_START_REFRESH_COUNT <= '1';
							
						ELSE
						
							--GO TO OUR IDLE STATE AND WAIT.
							CURRENT_STATE <= RUN_STATE;
							sdramcom <= ramstate_NOP;							
							
						END IF;
						
					END IF;		

					COUNT <= COUNT + 1;						
				
				WHEN RUN_STATE =>
				
					IF (refresh = '1') THEN
				
						--TIME TO REFRESH THE SDRAM, WHICH TAKES PRIORITY.	
						CURRENT_STATE <= AUTO_REFRESH;					
						--EMA(12 downto 0) <= ("0010000000000"); --PRECHARGE ALL
						sdramcom <= ramstate_AUTOREFRESH;							
					
					ELSIF memsel = '1' THEN 
						
						--WE ARE IN THE Z3 MEMORY SPACE WITH THE ADDRESS AND DATA STROBES ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND. 
						
						CURRENT_STATE <= RAS_STATE;
						
						EMA(12 downto 0) <= A(25) & A(21 DOWNTO 10);
						BANK0 <= A(22);
						BANK1 <= A(23);
						
						sdramcom <= ramstate_BANKACTIVATE;							
						
						IF RnW = '0' THEN
						
							--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY ASSERT _DSACKx.
							dsacken <= '1';
							
						END IF;
						
					END IF;
					
				WHEN RAS_STATE =>	
					
					--BANK ACTIVATE
					--SET CAS STATE VALUES SO THEY LATCH ON THE NEXT CLOCK EDGE
					CURRENT_STATE <= CAS_STATE;					
					
					EMA(12 downto 0) <= "001" & A(26) & A(24) & A(9 downto 2);
					
					IF RnW = '0' THEN
						--WRITE STATE
						sdramcom <= ramstate_WRITE;
					ELSE
						--READ STATE
						sdramcom <= ramstate_READ;
					END IF;	
					
					COUNT <= 0;
					
				WHEN CAS_STATE =>
					
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES.
					
					--WE NOP FOR THE REMAINING CYCLES.
					sdramcom <= ramstate_NOP;
					
					--IF _DSACKx IS NOT ENABLED FROM A 68030 WRITE CYCLE, ENABLE IT NOW.					
					dsacken <= '1';		
					
					--IF WE ARE NO LONGER IN THE ZORRO 3 MEM SPACE, GO BACK TO START.
					IF memsel = '0' THEN					
										
						dsacken <= '0';
						CURRENT_STATE <= RUN_STATE;		
						
					END IF;	
					
					COUNT <= 1;
				
			END CASE;
				
		END IF;
		
	END PROCESS;
	
	-----------------------------
	-- 68030 DATA TRANSFER ACK --
	-----------------------------	
	
	nDSACK <=
			"10" WHEN gayle_space = '1' AND nAS = '0' --OR (idesacken = '1' AND nAS = '0' AND A(13) = '0') --8 BIT PORT
		ELSE
			"01" WHEN idesacken = '1' AND nAS = '0' AND ide_space = '1' --AND A(13) = '1' --16 BIT PORT
		ELSE
			"00" WHEN dsacken = '1' AND nAS = '0' --32 BIT PORT
		ELSE
			"11" WHEN gayle_space = '1' OR ide_space = '1' OR nMEMZ3 = '0'
		ELSE 
			"ZZ";
	
	---------------------
	-- DATA BUS OUTPUT --
	---------------------
	
	--WE NEED TO COMMUNICATE DATA RELATED TO GAYLE/IDE.
	
	D <= 
			dataoutgayle WHEN gayle_space = '1' AND RnW = '1'
		ELSE
			'Z'; 	
	
	---------------------
	-- GAYLE REGISTERS --
	---------------------   
	---------------------------
	--WE ARE USING THE AMIGA OS GAYLE IDE INTERFACE SUPPORTING PIO WITH UP TO 2 DRIVES.
	--IT IS SIMPLE TO IMPLEMENT AND READY OUT OF THE BOX WITH KS => 37.300.
	--COMPATABILITY CAN BE ADDED TO EARLIER KICKSTARTS BY ADDING THE APPROPRIATE SCSI.DEVICE TO ROM.

	--TO TRICK AMIGA OS INTO THINKING WE HAVE A GAYLE ADDRESS DECODER, WE NEED TO RESPOND TO GAYLE SPECIFIC REGISTERS.
	--SEE THE GAYLE SPECIFICATIONS FOR MORE DETAILS.
	--WE DISABLE THE ATA PORT BY IGNORING THE GAYLE CONFIGURATION REGISTERS, WHICH TELLS AMIGA OS THERE IS NO GAYLE HERE.
	---------------------------
	
	--THE GAYLE ID REGISTER IS AT $DE1000. THIS SEEMS TO BE THE ONLY ADDRESS USED
	--IN THE $DE1XXX SPACE, SO WE CAN JUST LOOK FOR THE MOST SIGNIFICANT BITS.
	gayleid_space <= '1' WHEN A(23 DOWNTO 15) = "110111100" AND nIDEDIS = '1' AND nMEMZ3 = '1' ELSE '0'; --110111100001000000000000
	
	--CHECKS IF THE CURRENT ADDRESS IS IN THE GAYLE REGISTER SPACE.
	--THE GAYLE REGISTERS ARE FOUND IN $DA8XXX SPACE. WE ARE SPECIFICALLY 
	--INTERESTED IN ANY REGISTER HAVING TO DO WITH INTERRUPT REQUESTS.
	gaylereg_space <= '1' WHEN A(23 DOWNTO 15) = "110110101" AND nMEMZ3 = '1' ELSE '0'; --110110101000000000000000
	
	gayle_space <= '1' WHEN gaylereg_space = '1' OR gayleid_space = '1' ELSE '0';		
	
	--GAYLE IDENTIFICATION AND REGISTER PROCESS
	PROCESS (nDS, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			ideintenable <= '0';
			gayleid <= "11010001"; 
	
		ELSIF FALLING_EDGE (nDS) THEN
			--ELSIF (nDS'EVENT AND nDS = '0') THEN
					
			IF gayleid_space = '1' THEN
			
				--11010000 = $D0 = ECS Gayle, 11010001 = $D1 = AGA Gayle
				--GAYLE_ID CONFIGURATION REGISTER IS AT $DE1000. WHEN ADDRESS IS $DE1000 AND R_W IS READ, BIT 7 IS READ.
				--BELOW IS A SIMPLE SHIFT REGISTER TO LOAD THE GAYLE ID VALUE. BECAUSE THIS IS A 68030 PROCESSOR, 
				--WE USE THE AGA GAYLE SETTING AS USED IN THE A1200, A 68020 MACHINE.
				--IF ANYTHING IS WRITTEN TO $DE1000, THAT MEANS THE REGISTER HAS BEEN RESET AND WE NEED TO RE-ESTABLISH GAYLE.
				
				IF RnW = '1' THEN	
					
					--dataoutgayle <= gayleid(3);
					--gayleid <= gayleid (2 DOWNTO 0) & "0";
					dataoutgayle <= gayleid(7);
					gayleid <= gayleid (6 downto 0) & "0";
					
				ELSE
				
					gayleid <= "11010001";
				
				END IF;	
				
			ELSIF gaylereg_space = '1' THEN
			
				IF RnW = '1' THEN
				
					--READ MODE
					
					CASE A(14 DOWNTO 12) IS
						
						--THE REGISTER AT $DA8000 IDENTIFIES THE ATA DEVICE 
						--AS THE SOURCE OF THE IRQ.						
						WHEN "000" => --$8
							
							dataoutgayle <= INTRQ;										
						
						--WHEN THERE IS A NEW IDE IRQ, WE SET THIS TO '1'. 
						--AMIGA OS SETS TO '0' WHEN IT IS DONE HANDLING THE IRQ.
						WHEN "001" => --$9

							dataoutgayle <= intchg;
							
						--WHEN THE IDE DEVICE IS ASSERTING INTERRUPT REQUEST, WE 
						--SET THE BIT AT $DAA000. THIS TELLS AMIGA OS THE IDE DEVICE
						--IS REQUESTING THE INTERUPT.					
						WHEN "010" => --$A
						
							dataoutgayle <= ideintenable;	
							
						WHEN OTHERS =>
						
							dataoutgayle <= 'Z';
						
					END CASE;
					
				ELSE
				
					--WRITE MODE
					CASE A(14 DOWNTO 12) IS
					
						--AFTER AMIGA OS HAS COMPLETED ITS HANDLING OF THE IDE
						--INTERUPT, IT SIGNALS US HERE BY CLEARING THE BIT.
						WHEN "010" => --$A
						
							ideintenable <= D;
							
						WHEN OTHERS =>						
							
					END CASE;				
				
				END IF;
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	------------------------------------------------------
	-- GAYLE COMPATABLE HARD DRIVE CONTROLLER INTERFACE --
	------------------------------------------------------
	
	--THE FOLLOWING LOGIC HANDLES THE IDE INTERRUPT REQEUSTS.
	--WHEN INTRQ = '1', WE SIGNAL THE INTERRUPT REQUEST ON REGISTER $DA8000 AND $DA9000 AND ASSERT _INT2.
	--WHEN AMIGA OS IS DONE HANDLING THE REQUEST, IT NEGATES THE IDE INT ON $DA9000 AND WE THEN NEGATE _INT2.
	
	--PASS THE IDE DEVICE INTRQ SIGNAL TO _INT2 WHEN INTERRUPTS ARE ENABLED.
	nINT2 <= '0' 
		WHEN 
			intchg = '1' AND 
			ideintenable = '1' 
		ELSE
			'Z'; 
	
	--CLEAR THE INTERUPT WHEN AMIGA OS SIGNALS TO DO SO.
	clrint <= '1' 
		WHEN 
			A(23 DOWNTO 12) = "110110101001" AND --$DA9 110110101001000000000000
			RnW = '0' AND 
			nDS = '0' AND 
			D = '0' AND 
			nMEMZ3 = '1' 
		ELSE 
			'0'; 
	
	--GET THE CURRENT IDE INTERUPT STATE
	PROCESS (CPUCLK) BEGIN
			
		IF RISING_EDGE (CPUCLK) THEN
		
			intreq <= INTRQ;
			intlast <= intreq;
			
		END IF;
		
	END PROCESS;
	
	--CHECK FOR A CHANGE IN THE ATA INTERRUPT SIGNAL
	PROCESS (CPUCLK, clrint) BEGIN
	
		IF clrint = '1' THEN
		
			intchg <= '0';
			
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			IF intreq = '1' AND intlast = '0' THEN
			
				intchg <= '1';
				
			END IF;
			
		END IF;
		
	END PROCESS;
	
	
	--ARE WE IN THE ASSIGNED ADDRESS SPACE FOR THE IDE CONTROLLER?
	--GAYLE ATA CHIP SELECT ADDRESS SPACE IS $DA0000 - $DA3FFF. 
	--THE CHIP SELECT SPACE FROM $DA4000 - $DA7FFF IS IN THE SPECS AS NOT USED.
	--THIS CAN BE BROKEN INTO 8 BIT AND 16 BIT COMMANDS, WHICH CHANGES THE TIME TO EXECUTE.
	ide_space <= '1' 
		WHEN 
			A(23 DOWNTO 15) = "110110100" AND 
			nMEMZ3 = '1' 
		ELSE
			'0';
	
	--SIGNAL U601 TO DISABLE THE 6800/68000 STATE MACHINES.
	nIDEACCESS <= '0' 
		WHEN 
			gayle_space = '1' OR 
			ide_space = '1' 
		ELSE
			'1'; --110110100000000000000000
	
	--ENABLE THE IDE BUFFERS
	nIDEEN <= '0' 
		WHEN 
			ide_space = '1' AND nAS = '0'
		ELSE
			'1';
	
	--SETS THE DIRECTION OF THE IDE BUFFERS
	IDEDIR <= NOT RnW;
	
	--WE PASS THE COMPUTER RESET SIGNAL TO THE IDE DRIVE
	nIDERST <= nRESET;	
	
	--ASSERT THE IDE ADDRESS SIGNALS WHEN WE ARE IN 
	--THE IDE ADDRESS SPACE AND _AS IS ASSERTED.
	nCS0 <= '0' WHEN nAS = '0' AND A(12) = '0' AND ide_space = '1' ELSE '1';
	nCS1 <= '0' WHEN nAS = '0' AND A(12) = '1' AND ide_space = '1' ELSE '1';
	DA <= A(4 DOWNTO 2) WHEN nAS = '0' AND ide_space = '1' ELSE "111";

	--READ/WRITE SIGNALS
	nDIOR <= '0' WHEN renable = '1' ELSE '1';
	nDIOW <= '0' WHEN wenable = '1' ELSE '1';
	
	--THIS IS THE TIMER PROCESS FOR IDE. SINCE THIS IS AN ASYNCHRONOUS PROCESS, 
	--WE HAVE TO COUNT CLOCK EDGES TO DETERMINE WHEN ACTIONS OCCUR. 
	
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			renable <= '0';
			wenable <= '0';
			idesacken <= '0';
			ata_counter <= T0;			
		
		ELSIF RISING_EDGE (CPUCLK) THEN
		
			--INCREMENT THE COUNTER WHEN WE ARE IN A CYCLE.
			IF ata_counter /= 0 THEN
			
				ata_counter <= ata_counter + 1;
				
			END IF;
			
			CASE ata_counter IS
			
				WHEN T0 =>
				
					IF ide_space = '1' AND nAS = '0' THEN
					
						ata_counter <= 1;
						
					END IF;
			
				WHEN T1 =>
				
					--T1 IS THE SETUP TIME FOR _DIOR AND _DIOW.
					renable <= RnW;
					wenable <= NOT RnW;
					
				WHEN T2 - 2 =>
				
					--THIS TIMINING IS PROBABLY NOT GOOD FOR WRITE CYCLES.
					idesacken <= '1';
					
				WHEN T2 =>
				
					--T2 IS THE TIME _DIOR OR _DIOW IS ASSERTED.
					--WHEN IT HAS ELAPSED, WE CAN NEGATE THOSE SIGNALS.
					renable <= '0';
					wenable <= '0';
					idesacken <= '0';
					
				--WHEN T2 + 1 =>
				
					--idesacken <= '0';
					
				WHEN Teoc =>
					
					ata_counter <= T0;					
					
				WHEN others =>		
				
			END CASE;
		
		END IF;	
	
	END PROCESS;
	
end Behavioral;