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
-- Create Date:    November 9, 2022 
-- Design Name:    N2630 U602 CPLD
-- Project Name:   N2630
-- Target Devices: XC95144 144 PIN
-- Tool versions: 
-- Description: INCLUDES LOGIC FOR ZORRO 3 SDRAM CONTROLLER AND GAYLE IDE CONTROLLER
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
				--MODE68K : IN STD_LOGIC; --ARE WE IN 68000 MODE?
				CPUCLK : IN STD_LOGIC; --25MHz CPU CLOCK
				A7M : IN STD_LOGIC; --7MHz AMIGA CLOCK
				nRESET : IN STD_LOGIC; --SYSTEM RESET SIGNAL VALID IN 68000 AND 68030 MODE
				--nGRESET : IN STD_LOGIC; --68030 ONLY RESET SIGNAL
				nIDEDIS : IN STD_LOGIC; --IDE DISABLE
				--nZ3DIS : IN STD_LOGIC; --ZORRO 3 RAM DISABLE
				nDS : IN STD_LOGIC; --68030 DATA STROBE
				FC : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --68030 FUNCTION CODES
				SIZ : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --68030 TRANSFER SIZE SIGNALS
				--nBGACK : IN STD_LOGIC; --680x0 BUS GRANT ACK
				RAMSIZE : IN STD_LOGIC_VECTOR (2 DOWNTO 0); --RAM SIZE JUMPERS
	    		--nCBREQ : IN STD_LOGIC; --68030 CACHE BURST REQUEST
				--nIO16 : IN STD_LOGIC; --IDE IO16 SIGNAL, NOT USED.
				
				--D : INOUT  STD_LOGIC_VECTOR (31 DOWNTO 28);
				D : INOUT STD_LOGIC; --THIS IS D31 OF THE 68030
				nMEMZ3 : INOUT STD_LOGIC; --SIGNALS THE OTHER LOGIC THAT WE ARE RESPONDING TO THE RAM ADDRESS SPACE		
				nIDEACCESS : INOUT STD_LOGIC; --SIGNALS THE OTHER LOGIC THAT WE ARE RESPONDING TO THE IDE ADDRESS SPACE
				nINT2 : INOUT STD_LOGIC; --INT2 DRIVEN BY IDE INTRQ
				nDIOR : INOUT STD_LOGIC; --IDE READ SIGNAL
				nDIOW : INOUT STD_LOGIC; --IDE WRITE SIGNAL
				
				--AUTOCONFIG_SPACE : INOUT STD_LOGIC;
				--Z3CONFIGED : IN STD_LOGIC; --HAS ZORRO 3 RAM BEEN AUTOCONFIGed? ACTIVE HIGH				
				nCS0 : OUT STD_LOGIC; --IDE CHIP SELECT 0
				nCS1 : OUT STD_LOGIC; --IDE CHIP SELECT 1
				DA : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --IDE ADDRESS LINES
				IDEDIR : OUT STD_LOGIC; --IDE BUFFER DIRECTION
				nIDEEN : OUT STD_LOGIC; --IDE BUFFER ENABLE
				nIDERST : OUT STD_LOGIC; --IDE RESET
				
				nDSACK0 : INOUT STD_LOGIC; --68030 ASYNC DATA ACK SIGNAL
				nDSACK1 : INOUT STD_LOGIC; --68030 ASYNC DATA ACK SIGNAL
				--nDTACK : OUT STD_LOGIC; --68000 DATA SIGNAL
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
	--SIGNAL MEMORY_SPACE : STD_LOGIC := '0'; --READY TO START RAM CYCLE?
	SIGNAL memsel : STD_LOGIC; --ARE WE IN THE ZORRO 3 MEMORY SPACE?
	SIGNAL cs_mem : STD_LOGIC; --ARE WE IN THE UPPER SDRAM PAIR?
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES
	--SIGNAL Z3RAM_CONFIGED : STD_LOGIC := '0'; --HAS ZORRO 3 RAM BEEN AUTOCONFIGed? ACTIVE HIGH
	SIGNAL rowad : STD_LOGIC_VECTOR (12 DOWNTO 0) := "0000000000000";
	SIGNAL bankad : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	SIGNAL colad : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL datamask : STD_LOGIC_VECTOR (3 DOWNTO 0); --DATA MASK
	SIGNAL refresh : STD_LOGIC; --SIGNALS TIME TO REFRESH
	SIGNAL refreset : STD_LOGIC; --RESET THE REFRESH COUNTER
	SIGNAL REFRESH_COUNTER : INTEGER RANGE 0 TO 127 := 0;
	CONSTANT REFRESH_DEFAULT : INTEGER := 54; --7MHz REFRESH COUNTER
	--SIGNAL memcycle : STD_LOGIC;
	SIGNAL sdramcom : STD_LOGIC_VECTOR (3 DOWNTO 0); --SDRAM COMMAND
	--SIGNAL stermen : STD_LOGIC; --ENABLE _STERM
	SIGNAL dsacken : STD_LOGIC;
	--SIGNAL ndsack : STD_LOGIC;
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
	SIGNAL gayleid : STD_LOGIC_VECTOR (3 DOWNTO 0); --THIS IS THE GAYLE ID VALUE
	--SIGNAL gayleregistered : STD_LOGIC; --HAS OUR GAYLE EMULATOR BEEN REGISTERED?
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
	--SIGNAL idesackdisable : STD_LOGIC;
	SIGNAL delaycount : INTEGER RANGE 0 TO 15;
	SIGNAL counthalt : STD_LOGIC; --PAUSE THE DELAY COUNTER
	SIGNAL countreset : STD_LOGIC; --RESET THE DELAY COUNTER
	
	CONSTANT T1 : INTEGER := 2; --T1 = 70ns. DELAY TWO CLOCK CYCLES AT 25MHz (80ns). 
	CONSTANT Tack : INTEGER := 4; --ASSERT _DSACK1 AFTER 4 CLOCK CYCLES.
	CONSTANT T2 : INTEGER := 6; --T2 = 165ns. This is satisfied by Tack + T2 = 160ns
	CONSTANT Teoc : INTEGER := 15; --Teoc = T0 - T1 - T2. T0 = 600ns
	
	--SIGNAL T1GO : STD_LOGIC;
	--SIGNAL T2GO : STD_LOGIC;
	SIGNAL ATAGO : STD_LOGIC;
	
	
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
				
				WHEN "111" => --16MB LOW BANK POPULATED 4Mx16
					cs_mem <= '0';
					bankad <= A(23 DOWNTO 22);
					rowad <= "0" & A(21 downto 10);					
					colad <= "00" & A(9 DOWNTO 2);
						
				WHEN "010" => --32MB BOTH MEMORY BANKS POPULATED 4Mx16
					cs_mem <= A(24);
					bankad <= A(23 DOWNTO 22);
					rowad <= "0" & A(21 downto 10);					
					colad <= "00" & A(9 DOWNTO 2);
			
				WHEN "011" => --32MB LOW BANK POPULATED 8Mx16
					cs_mem <= '0';
					bankad <= A(24 DOWNTO 23);
					rowad <= "0" & A(22 downto 11);
					colad <= "0" & A(10 DOWNTO 2);
						
				WHEN "100" => --64MB BOTH MEMORY BANKS POPULATED 8Mx16
					cs_mem <= A(25);
					bankad <= A(24 DOWNTO 23);
					rowad <= "0" & A(22 downto 11);					
					colad <= "0" & A(10 DOWNTO 2);
		
				WHEN "101" => --64MB LOW BANK POPULATED 16Mx16
					cs_mem <= '0';
					bankad <= A(25 DOWNTO 24);
					rowad <= A(23 downto 11);					
					colad <= "0" & A(10 DOWNTO 2);
						
				WHEN "000" => --128MB BOTH MEMORY BANKS POPULATED 16Mx16
					cs_mem <= A(26);
					bankad <= A(25 DOWNTO 24);
					rowad <= A(23 downto 11);					
					colad <= "0" & A(10 DOWNTO 2);
					
				WHEN "001" => --128MB LOW BANK POPULATED 32Mx16
					cs_mem <= '0';
					bankad <= A(26 DOWNTO 25);
					rowad <= A(24 downto 12);					
					colad <= A(11 DOWNTO 2);
						
				WHEN "110" => --256MB BOTH MEMORY BANKS POPULATED 32Mx16
					cs_mem <= A(27);
					bankad <= A(26 DOWNTO 25);
					rowad <= A(24 downto 12);					
					colad <= A(11 DOWNTO 2);

				WHEN OTHERS =>
				
					--NOTHING TO DO HERE. HOW ABOUT SOME NICE ASCII ART?
					
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
					--First power up or warm reset
					--200 microsecond is needed to stabilize. We are going to rely on the 
					--the system reset to give us the needed time, although it might be inadequate.

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
						EMA(12 downto 0) <= ("0010000000000"); --PRECHARGE ALL
						sdramcom <= ramstate_AUTOREFRESH;							
					
					ELSIF memsel = '1' THEN 
						
						--WE ARE IN THE Z3 MEMORY SPACE WITH THE ADDRESS AND DATA STROBES ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND. 
						
						CURRENT_STATE <= RAS_STATE;
												
						EMA(12 downto 0) <= rowad(12 DOWNTO 0);
						BANK0 <= bankad(0);
						BANK1 <= bankad(1);
						
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
					
					EMA(12 downto 0) <= "001" & colad (9 DOWNTO 0);	
					
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
					IF dsacken = '0' AND COUNT = 0 THEN
					
						dsacken <= '1';						
						
					ELSE
					
						dsacken <= '0';
						
					END IF;
					
					--IF WE ARE NO LONGER IN THE ZORRO 3 MEM SPACE, GO BACK TO START.
					IF memsel = '0' THEN					
											
						CURRENT_STATE <= RUN_STATE;		
						
					END IF;	
					
					COUNT <= 1;
				
			END CASE;
				
		END IF;
		
	END PROCESS;
	
	-----------------------------
	-- 68030 DATA TRANSFER ACK --
	-----------------------------
	
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			nDSACK0 <= 'Z';
			nDSACK1 <= 'Z';
	
		ELSIF RISING_EDGE (CPUCLK) THEN
			
			IF memsel = '1' THEN
			
				--WE ARE IN THE ZORRO 3 ADDRESS SPACE WITH _AS ASSERTED.
				IF dsacken = '1' OR nDSACK0 = '0' THEN
			
					nDSACK0 <= '0';
					nDSACK1 <= '0';
				
				ELSE
				
					nDSACK0 <= '1';
					nDSACK1 <= '1';
				
				END IF;
				
			ELSIF ide_space = '1' AND nAS = '0' THEN
			
				--WE ARE IN THE IDE I/0 ADDRESS SPACE WITH _AS ASSERTED.
				IF idesacken = '1' OR nDSACK1 = '0' THEN
				
					nDSACK1 <= '0';
					
				ELSE
				
					nDSACK1 <= '1';
			
				END IF;
				
			ELSIF gayle_space = '1' THEN
			
				--WE ARE IN THE GAYLE REGISTER ADDRESS SPACE
				IF nAS = '0' THEN
				
					nDSACK1 <= '0';
					
				ELSE
				
					nDSACK1 <= '1';
					
				END IF;
				
			ELSE
			
				nDSACK0 <= 'Z';
				nDSACK1 <= 'Z';
				
			END IF;
		
		END IF;
		
	END PROCESS;
	
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
	--WE DISABLE THE IDE PORT BY SIMPLY IGNORING THE GAYLE CONFIGURATION REGISTERS, WHICH TELLS AMIGA OS THERE IS NO GAYLE HERE.
	---------------------------
	
	--THE GAYLE ID REGISTER IS AT $DE1000. THIS SEEMS TO BE THE ONLY ADDRESS USED
	--IN THE $DE1XXX SPACE, SO WE CAN JUST LOOK FOR THE MOST SIGNIFICANT BITS.
	gayleid_space <= '1' WHEN A(23 DOWNTO 15) = "110111100" AND nIDEDIS = '1' ELSE '0'; --110111100001000000000000
	
	--CHECKS IF THE CURRENT ADDRESS IS IN THE GAYLE REGISTER SPACE.
	--THE GAYLE REGISTERS ARE FOUND IN $DA8XXX SPACE. WE ARE SPECIFICALLY 
	--INTERESTED IN ANY REGISTER HAVING TO DO WITH INTERRUPT REQUESTS.
	gaylereg_space <= '1' WHEN A(23 DOWNTO 15) = "110110101" ELSE '0'; --110110101000000000000000
	
	gayle_space <= '1' WHEN gaylereg_space = '1' OR gayleid_space = '1' ELSE '0';		
	
	--GAYLE IDENTIFICATION AND REGISTER PROCESS
	PROCESS (nDS, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			ideintenable <= '0';
			gayleid <= "1101"; 
	
		ELSIF FALLING_EDGE (nDS) THEN
					
			IF gayleid_space = '1' THEN
			
				--11010000 = $D0 = ECS Gayle, 11010001 = $D1 = AGA Gayle
				--GAYLE_ID CONFIGURATION REGISTER IS AT $DE1000. WHEN ADDRESS IS $DE1000 AND R_W IS READ, BIT 7 IS READ.
				--BELOW IS A SIMPLE SHIFT REGISTER TO LOAD THE GAYLE ID VALUE, OF WHICH ONLY THE HIGH NIBBLE IS CONSIDERED.
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
						
						--THE REGISTER AT $DA8000 IDENTIFIES THE IDE DEVICE AS THE SOURCE OF THE IRQ.						
						WHEN "000" => --$8
							
							dataoutgayle <= intreq;										
						
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
						
							dataoutgayle <= 'Z';
							
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
	nINT2 <= '0' WHEN intchg = '1' AND ideintenable = '1' ELSE 'Z'; 
	
	--CLEAR THE INTERUPT WHEN AMIGA OS SIGNALS TO DO SO.
	clrint <= '1' WHEN A(23 DOWNTO 12) = "110110101001" AND RnW = '0' AND nDS = '0' AND D = '0' ELSE '0'; --$DA9
	
	--GET THE CURRENT IDE INTERUPT STATE
	PROCESS (CPUCLK) BEGIN
			
		IF RISING_EDGE (CPUCLK) THEN
		
			intreq <= INTRQ;
			intlast <= intreq;
			
		END IF;
		
	END PROCESS;
	
	--CHECK FOR A CHANGE IN THE IDE INTERRUPT SIGNAL
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
	--GAYLE IDE CHIP SELECT ADDRESS SPACE IS $DA0000 - $DA3FFF. 
	ide_space <= '1' WHEN A(23 DOWNTO 15) = "110110100" ELSE '0';
	
	--SIGNAL U601 TO DISABLE THE 6800/68000 STATE MACHINES.
	nIDEACCESS <= '0' WHEN gayle_space = '1' OR ide_space = '1' ELSE '1'; --110110100000000000000000
	
	--ENABLE THE IDE BUFFERS
	nIDEEN <= '0' WHEN ide_space = '1' ELSE '1'; --ide_space = '1'
	
	--SETS THE DIRECTION OF THE IDE BUFFERS
	IDEDIR <= NOT RnW;
	
	--WE PASS THE COMPUTER RESET SIGNAL TO THE IDE DRIVE
	nIDERST <= nRESET;
	
	--GAYLE SPECS TELL US WHEN THE IDE CHIP SELECT LINES ARE ACTIVE
	--AND IS DRIVEN PURELY BY ADDRESS.	
	nCS0 <= '0' WHEN A(12) = '0' AND ide_space = '1' AND nAS = '0' ELSE '1';
	nCS1 <= '0' WHEN A(12) = '1' AND ide_space = '1' AND nAS = '0' ELSE '1';
			
	--GAYLE EXPECTS IDE DA2..0 TO BE CONNECTED TO A4..2	
	DA(0) <= A(2);
	DA(1) <= A(3);
	DA(2) <= A(4);
	
	--READ/WRITE SIGNALS
	--nDIOR <= '0' WHEN RnW = '1' AND T2GO = '1' ELSE '1';
	--nDIOW <= '0' WHEN RnW = '0' AND T2GO = '1' ELSE '1';


	--ATA PIO COMMUNICATION PROCESS
	PROCESS (CPUCLK, nRESET) BEGIN
	
		IF nRESET = '0' THEN
		
			ATAGO <= '0';	
			counthalt <= '0';
			countreset <= '0';
			idesacken <= '0';
			nDIOR <= '1';
			nDIOW <= '1';			
	
		ELSIF RISING_EDGE (CPUCLK) THEN		
		
			CASE (delaycount) IS
			
				WHEN T1 =>
				
					--T1 HAS ELAPSED. ASSERT READ/WRITE AND GO TO T2.
					ATAGO <= '1';
					nDIOR <= NOT RnW; --(0 WHEN R, 1 WHEN W)
					nDIOW <= RnW;     --(1 WHEN R, 0 WHEN W)						
					
				WHEN Tack =>
				
					IF IORDY = '1' THEN
					
						idesacken <= '1';	
						counthalt <= '0';							
						
					ELSE
					
						counthalt <= '1';
						
					END IF;
					
				WHEN T2 =>						
					
					nDIOR <= '1';
					nDIOW <= '1';
					
				WHEN Teoc =>
				
					ATAGO <= '0';
					countreset <= '1';
					
				WHEN OTHERS =>
				
					idesacken <= '0';	
					countreset <= '0';
				
			END CASE;				

		END IF;
		
	END PROCESS;
						
					
	PROCESS (CPUCLK, nRESET, countreset) BEGIN
	
		IF nRESET = '0' OR countreset = '1' THEN
		
			delaycount <= 0;
	
		ELSIF FALLING_EDGE (CPUCLK) THEN
		
			IF (ide_space = '1' AND nAS = '0') OR ATAGO = '1' THEN 
			
				IF counthalt = '0' THEN
			
					delaycount <= delaycount + 1;
					
				END IF;
					
			ELSE
			
				delaycount <= 0;
					
			END IF;
			
		END IF;
		
	END PROCESS;	
	
end Behavioral;