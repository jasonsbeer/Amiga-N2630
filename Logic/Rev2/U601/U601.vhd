----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:04:43 05/22/2022 
-- Design Name: 
-- Module Name:    U601 - Behavioral 
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

entity U601 is

PORT
(

	RnW : IN STD_LOGIC; --680x0 READ/WRITE
	REF : IN STD_LOGIC; --SDRAM REFRESH SIGNAL
	CPUCLK : IN STD_LOGIC; --68030 CLOCK
	A : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --680x0 ADDRESS LINES
	nAS : IN STD_LOGIC; --68030 ADDRESS STROBE
	nAAS : IN STD_LOGIC; --68000 ADDRESS STROBE
	nRESET : IN STD_LOGIC; --AMIGA RESET SIGNAL
	nBGACK : IN STD_LOGIC; --AMIGA BUS GRANT ACK
	nUDS : IN STD_LOGIC; --68000 UPPER DATA STROBE
	nLDS : IN STD_LOGIC; --68000 LOWER DATA STROBE
	nDS : IN STD_LOGIC; --68030 DATA STROBE
	SIZ : IN STD_LOGIC_VECTOR (1 downto 0); --SIZE BUS FROM 68030
	FC : IN STD_LOGIC_VECTOR (2 downto 0); --68030 FUNCTION CODES
	
	MEMACCESS : INOUT STD_LOGIC; --LOGIC HIGH WHEN WE ARE ACCESSING Z2 RAM
	REFACKZ2 : INOUT STD_LOGIC; --REFRESH ACK
	
	ZBANK0 : OUT STD_LOGIC; --BANK0 SIGNAL
	ZBANK1 : OUT STD_LOGIC; --BANK1 SIGNAL
	CLKE : OUT STD_LOGIC; --SDRAM CLOCK ENABLE
	ZMA : OUT STD_LOGIC_VECTOR (10 downto 0); --Z2 SDRAM ADDRESS BUS
	nZCS : OUT STD_LOGIC; --SDRAM CHIP SELECT
	nZWE : OUT STD_LOGIC; --SDRAM WRITE ENABLE
	nZCAS : OUT STD_LOGIC; --SDRAM CAS
	nZRAS : OUT STD_LOGIC; --SDRAM RAS
	nUUBE : OUT STD_LOGIC; --UPPER UPPER BYTE ENABLE
	nUMBE : OUT STD_LOGIC; --UPPER MIDDLE BYTE ENABLE
	nLMBE : OUT STD_LOGIC; --LOWER MIDDLE BYTE ENABLE
	nLLBE : OUT STD_LOGIC; --LOWER LOWER BYTE ENABLE
	nDTACK : OUT STD_LOGIC; --68000 DTACK FOR DMA
	nDSACK0 : OUT STD_LOGIC; --68030 DSACK
	nDSACK1 : OUT STD_LOGIC;
	nOVR : OUT STD_LOGIC; --DTACK OVERRIDE
	EMDDIR : OUT STD_LOGIC --DIRECTION OF MEMORY DATA BUS BUFFERS
	

);

end U601;

architecture Behavioral of U601 is
	
	--MEMORY ACCESS SIGNALS
	SIGNAL dmaaccess : STD_LOGIC; --ARE WE IN A DMA MEMORY CYCLE?
	SIGNAL cpuaccess : STD_LOGIC; --ARE WE IN A CPU MEMORY CYCLE?
	SIGNAL dsack : STD_LOGIC; --FEEDS THE 68030 DSACK SIGNALS
	
	--DEFINE THE SDRAM STATE MACHINE 
	TYPE SDRAM_STATE IS ( POWERUP, POWERUP_PRECHARGE, MODE_REGISTER, AUTO_REFRESH, AUTO_REFRESH_CYCLE, RUN_STATE, CAS_STATE, DATA_STATE );
	SIGNAL CURRENT_STATE : SDRAM_STATE; --CURRENT SDRAM STATE
	SIGNAL SDRAM_START_REFRESH_COUNT : STD_LOGIC; --WE NEED TO REFRESH TWICE UPON STARTUP
	SIGNAL COUNT : INTEGER RANGE 0 TO 2 := 0; --COUNTER FOR SDRAM STARTUP ACTIVITIES

	--AUTOCONFIG SIGNALS
	SIGNAL autoconfigcomplete_ZORRO2RAM : STD_LOGIC := '0'; --HAS THE Z2 RAM BEEN AUTOCONFIGED?
	SIGNAL baseaddress_ZORRO2RAM : STD_LOGIC_VECTOR ( 2 downto 0 ):="000"; --BASE ADDRESS ASSIGNED FOR ZORRO 2 RAM
	

begin

	---------------------------
	-- MEMORY DATA DIRECTION --
	---------------------------
	
	--This sets the direction of the LVC data buffers between the 680x0 and the RAM
	--We simply go with the inverse of the RW signal.
	EMDDIR <= NOT RnW;
	
	---------------
	-- RAM STUFF --
	---------------

	--EITHER THE 68030 OR DMA FROM THE ZORRO 2 BUS CAN ACCESS ZORRO 2 RAM ON OUR CARD
	
	--THIS DETECTS MEMORY ACCESS BY THE 68030
	cpuaccess <= '1' 
		WHEN
			autoconfigcomplete_ZORRO2RAM = '1' AND A(23 downto 21) = baseaddress_ZORRO2RAM AND nAS = '0' AND FC(2 DOWNTO 0) /= "111"
		ELSE
			'0';
	
	--THIS DETECTS MEMORY ACCESS BY DMA
	dmaaccess <= '1'
		WHEN
			autoconfigcomplete_ZORRO2RAM = '1' AND A(23 downto 21) = baseaddress_ZORRO2RAM AND nAAS = '0' AND nBGACK = '0'
		ELSE
			'0';
			
	MEMACCESS <= '1' 
		WHEN
			cpuaccess = '1' OR dmaaccess = '1'
		ELSE
			'0';
			
	--The OVR signal must be asserted whenever on-board memory is selected
	--during a DMA cycle.  It tri-states GARY's DTACK output, allowing
	--one to be created by our memory logic. u501

	nOVR <= '0' 
		WHEN 
			dmaaccess = '1' 
		ELSE 
			'Z';	
			
	--IN OUR LOGIC, nDSACK0 = nDSACK1 WITHOUT EXCEPTION.
	--WE ARE A 32 BIT PORT, SO WE ALWAYS ASSERT BOTH.
	nDSACK0 <= dsack;
	nDSACK1 <= dsack;
	
	-------------------------------------
	-- SDRAM FALLING CLOCK EDGE ACTIONS --
	-------------------------------------
	
	PROCESS ( CPUCLK ) BEGIN
		
		IF ( FALLING_EDGE (CPUCLK) ) THEN

			IF (MEMACCESS = '1') THEN		

				--ENABLE THE VARIOUS BYTES ON THE SDRAM DEPENDING ON WHAT THE ACCESSING DEVICE IS ASKING FOR. U603
				--DISCUSSION OF PORT SIZE AND BYTE SIZING IS ALL IN SECTION 12 OF THE 68030 USER MANUAL
				--WE ALSO INCLUDE BYTE SELECTION FOR DMA.
				
				--UPPER UPPER BYTE ENABLE (D31..24)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "00" AND nDS = '0') OR
					(nBGACK = '0' AND nUDS = '0' AND A(1) = '1'))
				THEN			
					nUUBE <= '0'; 
				ELSE 
					nUUBE <= '1';
				END IF;

				--UPPER MIDDLE BYTE (D23..16)
				IF 
					(( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "01" AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '0' AND nLDS = '0' AND A(1) = '1')) 
				THEN
					nUMBE <= '0';
				ELSE
					nUMBE <= '1';
				END IF;

				--LOWER MIDDLE BYTE (D15..8)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "10" AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '0' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '1' AND A(0) = '1' AND A(1) = '0' AND SIZ(0) = '0' AND nDS = '0') OR
					(nBGACK = '0' AND nUDS = '0' AND A(1) = '0'))
				THEN
					nLMBE <= '0';
				ELSE
					nLMBE <= '1';
				END IF;

				--LOWER LOWER BYTE (D7..0)
				IF 
				   (( RnW = '1' ) OR
					(nBGACK = '1' AND A(1 downto 0) = "11" AND nDS = '0' ) OR
					(nBGACK = '1' AND A(0) = '1' AND SIZ(0) = '1' AND SIZ(1) = '1' AND nDS = '0') OR
					(nBGACK = '1' AND SIZ(0) = '0' AND SIZ(1) = '0' AND nDS = '0') OR
					(nBGACK = '1' AND A(1) = '1' AND SIZ(1) ='1' AND nDS = '0') OR
					(nBGACK = '0' AND nLDS = '0' AND A(1) = '0'))
				THEN
					nLLBE <= '0';
				ELSE
					nLLBE <= '1';
				END IF;	

			ELSE 
				--DEACTIVATE ALL THE RAM BYTE MASKS

				nUUBE <= '1';
				nUMBE <= '1';
				nLMBE <= '1';
				nLLBE <= '1';

			END IF;	
		END IF;
	END PROCESS;
	
	-------------------------------------
	-- SDRAM RISING CLOCK EDGE ACTIONS --
	-------------------------------------
	
	PROCESS ( CPUCLK, nRESET ) BEGIN
	
		IF (nRESET = '0') THEN 
				--THE AMIGA HAS BEEN RESET OR JUST POWERED UP
				CURRENT_STATE <= POWERUP;
				nZCAS <= '1';
				nZRAS <= '1';
				nZWE <= '1';
				nZCS <= '1';
				CLKE <= '0';
				COUNT <= 0;
				dsack <= 'Z';
				nDTACK <= 'Z';
		
		ELSIF ( RISING_EDGE (CPUCLK) ) THEN
			
			--WE CANNOT USE BURST MODE IN Z2 RAM, WHICH ONLY WORKS WITH STERM TERMINATED ACTIONS.
			--ZORRO 2 RAM ACCESSES ARE ALL ASYNCHROUNOUS.
			
			--SDRAM is pretty fast. Most operations will complete in less than one 25MHz clock cycle. Only AUTOREFRESH and 
			--successive BANK ACTIVE commands take more than one clock cycle. Both are 60ns. 
			
			--WE NEED TO ACCOUNT FOR OTHER CLOCK SPEEDS DURING SDRAM OPERATIONS
			--50MHz IS 20ns PER CYCLE, 40MHz IS 24ns, 33 IS 30ns, 25MHz IS 40ns.
			
			
			--WE WATCH FOR THE REF(RESH) SIGNAL FROM U600 TO TELL US WHEN TO REFRESH THE SDRAM.
			--WHEN REF IS ASSERTED, WE WAIT UNTIL WE ARE NOT IN MEMORY CYCLE AND THEN
			--ACKNOWLEDGE THE REFRESH BY ASSERTING REFACK2. WE ASSERT REFACK2 UNTIL
			--REF IS NEGATED.
			
			IF (REF = '1') THEN
			
				IF (REFACKZ2 = '0') THEN
				
					--TIME TO REFRESH THE SDRAM, BUT ONLY IF WE ARE NOT IN THE MIDDLE OF A MEMORY ACCESS CYCLE
					IF MEMACCESS = '0' THEN
						CURRENT_STATE <= AUTO_REFRESH;
						REFACKZ2 <= '1';
					END IF;
					
				ELSE
				
					IF (REF = '0') THEN
						REFACKZ2 <= '0';
					END IF;
				END IF;
				
			END IF;
		
			--PROCEED WITH SDRAM STATE MACHINE
			--THE FIRST STATES ARE TO INITIALIZE THE SDRAM, WHICH WE ALWAYS DO
			--THE LATER STATES ARE TO UTILIZE THE SDRAM, WHICH ONLY HAPPENS IF MEMACCESS = 1
			--THIS MEANS THE ADDRESS STROBE IS ASSERTED, WE ARE IN THE ZORRO 2 ADDRESS SPACE, AND THE RAM IS AUTOCONFIGured
			CASE CURRENT_STATE IS
			
				WHEN POWERUP =>
					--First power up or warm reset
					--200 microsecond is needed to stabilize. We are going to rely on the 
					--the system reset to give us the needed time, although it might be inadequate.
					CLKE <= '0'; --DISABLE CLOCK
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '0'; --NOP STATE
					CURRENT_STATE <= POWERUP_PRECHARGE;
					
				WHEN POWERUP_PRECHARGE =>
					ZMA <= ("10000000000"); --PRECHARGE ALL			
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '1';
					nZCS <= '0';
					CLKE <= '1';
					CURRENT_STATE <= MODE_REGISTER;
				
				WHEN MODE_REGISTER =>
					--TWO CLOCK CYCLES ARE NEEDED FOR THE REGISTER TO, WELL, REGISTER
					ZMA <= "01000100000"; --PROGRAM THE SDRAM...NO READ OR WRITE BURST, CAS LATENCY=2,
					nZWE <= '0';
					nZRAS <= '0';
					nZCAS <= '0';
					nZCS <= '0';	
					
					IF (COUNT = 1) THEN
						--NOW NEED TO REFRESH TWICE
						CURRENT_STATE <= AUTO_REFRESH;
					END IF;
					
					COUNT <= COUNT + 1;
					
				WHEN AUTO_REFRESH =>
					--REFRESH the SDRAM
					--MUST BE FOLLOWED BY NOPs UNTIL REFRESH COMPLETE
					--Refresh time is 60ns. Each 25MHz clock period is 40ns.
					--If we wait two clock cycles, this will allow time for refresh.
					
					nZWE <= '1';
					nZRAS <= '0';
					nZCAS <= '0';
					nZCS <= '0';
					
					COUNT <= 0;
					
					SDRAM_START_REFRESH_COUNT <= '0';
					CURRENT_STATE <= AUTO_REFRESH_CYCLE;						
					
				WHEN AUTO_REFRESH_CYCLE =>
					--NOPs WHILE THE SDRAM IS REFRESHING
					nZWE <= '1';
					nZRAS <= '1';
					nZCAS <= '1';
					nZCS <= '0';
					
					--IF (COUNT = 1) THEN --TWO CLOCK CYCLES HAVE PASSED. WE CAN PROCEED.
						--DO WE NEED TO REFRESH AGAIN (STARTUP)?
						IF (SDRAM_START_REFRESH_COUNT = '0') THEN							
							CURRENT_STATE <= AUTO_REFRESH;
							SDRAM_START_REFRESH_COUNT <= '1';
						ELSE
							CURRENT_STATE <= RUN_STATE;
						END IF;
					--END IF;		

					--COUNT <= COUNT + 1;						
				
				WHEN RUN_STATE =>
					--CLOCK EDGE 0
					
					IF (MEMACCESS = '1') THEN 
						--WE ARE IN THE Z2 MEMORY SPACE WITH THE ADDRESS STROBE ASSERTED.
						--SEND THE BANK ACTIVATE COMMAND W/RAS
						
						ZMA(10 downto 0) <= A(12 downto 2);
						ZBANK0 <= A(13);
						ZBANK1 <= A(14);
						
						nZCS <= '0';
						nZRAS <= '0';	
						nZCAS <= '1';							
						nZWE <= '1';
						
						IF (nBGACK = '0') THEN
							nDTACK <= '1'; --DMA ACCESS, NEGATE BECAUSE _WE_ ARE TALKING TO THE ZORRO 2 BUS NOW							
						ELSE
							dsack <= '1'; --NEGATE DSACK BECAUSE _WE_ ARE TALKING TO THE 68030 BUS RIGHT NOW
						END IF; 
						
						CURRENT_STATE <= CAS_STATE;
						COUNT <= 0;
					END IF;
					
				WHEN CAS_STATE =>
					--CLOCK EDGE 1
					--READ OR WRITE WITH AUTOPRECHARGE
					
					ZMA(7 downto 0) <= A(22 downto 15);
					ZMA(8) <= '0';
					ZMA(9) <= '0';
					ZMA(10) <= '1'; --PRECHARGE
					
					nZCS <= '0';
					nZRAS <= '1';	
					nZCAS <= '0';	
					nZWE <= RnW;

					--IF THIS IS A WRITE ACTION, WE CAN IMMEDIATELY PROCEED TO THE ACTION.
					--IF THIS IS A READ ACTION, THE CAS LATENCY IS 2 CLOCK CYCLES, SO WE NEED TO WAIT ONE MORE CLOCK BEFORE READING.
					--DURING DMA, THE REQUESTING DEVICE'S RW SIGNAL IS LOCKED TO OUR RW SIGNAL.
					
					--DO WE WANT TO CONSIDER DS ON THE READ ACTION?
					IF ((RnW = '0') OR (RnW = '1' AND COUNT >= 1)) THEN
					
						IF (nBGACK = '0') THEN
						
							nDTACK <= '0'; --ASSERT nDTACK SINCE THIS IS A DMA EVENT. DMA DEVICE CAN COMMIT ON THE NEXT FALLING CLOCK EDGE.
							
						ELSE
						
							--68030 CAN COMMIT ON THE NEXT FALLING CLOCK EDGE.
							--ASSERTING BOTH DSACKs TELLS THE 68030 THAT THIS IS A 32 BIT PORT.
							dsack <= '0'; 
							
						END IF;
						
						CURRENT_STATE <= DATA_STATE;
					
					END IF;						
					
					COUNT <= COUNT + 1;
					
				WHEN DATA_STATE =>
					--RISING CLOCK EDGE 2
					--THIS IS THE CLOCK EDGE WE EXPECT THE DATA TO BE WRITTEN TO OR READ FROM THE SDRAM
					--WE NEED TO WAIT 30ns BEFORE ISSUING ANOTHER BANK ACTIVATE COMMAND. NO PROBLEM, SINCE ONE CLOCK CYCLE IS 40ns.
					
					IF (MEMACCESS = '0') THEN --THE ADDRESS STROBE HAS NEGATED INDICATING THE END OF THE MEMORY ACCESS
						
						--TRISTATE SO WE DON'T INTERFERE WITH OTHER DEVICES ON THE BUSES
						dsack <= 'Z';
						nDTACK <= 'Z';
						
						CURRENT_STATE <= RUN_STATE;
						
						--SET NOP
						nZCS <= '1';
						nZRAS <= '1';	
						nZCAS <= '1';							
						nZWE <= '1';
						
					END IF;					
				
			END CASE;
				
		END IF;
	END PROCESS;


end Behavioral;

