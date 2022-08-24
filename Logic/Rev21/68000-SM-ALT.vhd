CLK14 <= A7M XOR CDAC; --14 MHz CLOCK FOR 68000 STATE MACHINE
TYPE STATE68K IS ( S0, S1, S2, S3, S4, S5, S6, S7 );

--DSACK1 PROCESS
PROCESS (CPUCLK) BEGIN
  
  IF RISING_EDGE (CPUCLK) THEN
    
    IF nAS = '0' AND (dsacken = '1' OR nDSACK1 = '0') THEN
      
      dsackout <= '0';
    
    ELSE
      
      dsackout <= '1';
    
    END IF;
      
 END IF;
   
END PROCESS;

--DATA TRANSFER SIGNALS
nUDS <= udsout WHEN writecycle OR readcycle ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
nLDS <= ldsout WHEN writecycle OR readcycle ELSE '1' WHEN sm_enabled = '1' ELSE 'Z';
nAAS <= aasout WHEN sm_enabled = '1' ELSE 'Z';
ARnW <= arwout WHEN sm_enabled = '1' ELSE 'Z';
nVMA <= vmaout WHEN sm_enabled = '1' ELSE 'Z';
nDSACK1 <= dsackout WHEN sm_enabled = '1' ELSE 'Z';
    
--68000 STATE MACHINE PROCESS

PROCESS (CLK14, sm_enabled) BEGIN

	IF sm_enabled = '0' THEN		
    
		--THE STATE MACHINE IS DISABLED
		--TRISTATE APPROPRIATE SIGNALS AND SET OTHERS TO DISABLED

		CURRENT_STATE <= S0;

		aasout <= '1';
		arwout <= '1';
		vmaout <= '1';
		ldsout <= '1';
		udsout <= '1';
		readcycle <= '0';
		writecycle <= '0';
		dsacken <= '0';

	ELSIF RISING_EDGE (CLK14) THEN
	
		--BEGIN 68000 STATE MACHINE--
    
		CASE (CURRENT_STATE) IS

			WHEN S0 =>

				--STATE 0 IS THE START OF A CYCLE. 
				--WE WATCH FOR ASSERTION OF 68030 _AS TO SIGNAL THE CYCLE START

				IF nAS = '0' THEN

				  CURRENT_STATE <= S1;

				  --PREP THE DATA STROBES--
				  IF A(0) = '0' THEN
				    udsout <= '0';
				  ELSE
				    udsout <= '1';
				  END IF;

				  IF SIZ(1) = '1' OR SIZ(0) = '0' OR A(0) = '1' THEN
				    ldsout <= '0';
				  ELSE
				    ldsout <= '1';
				  END IF;	

				END IF;

			WHEN S1 =>            

				--PROCESSOR DRIVES A VALID ADDRESS ON THE BUS IN STATE 1. 
				--NOTHING MUCH FOR US TO DO.
				--SET UP FOR STATE 2.

				CURRENT_STATE <= S2;

				aasout <= '0';        

				IF RnW = '1' THEN readcycle <= '1';
				IF RnW = '0' THEN arwout <= '0';

			WHEN S2 =>

				--ASSERT _AAS FOR ALL CYCLES
				--ASSERT _LDS, AND _UDS FOR READ CYCLES
				--GO TO STATE 3

				CURRENT_STATE <= S3;

			WHEN S3 =>

				--PROCEED TO STATE 4.
				--DURING WRITE CYCLES, _LDS AND _UDS ARE ASSERTED ON THE RISING EDGE OF STATE 4.

				CURRENT_STATE <= S4;
				IF RnW = '0' THEN writecycle <= '1';

			WHEN S4 =>

				--SOME IMPORTANT STUFF HAPPENS AT S4.
				--IF THIS IS A 6800 CYCLE, ASSERT _VMA IF WE ARE IN SYNC WITH E
				--IF THIS IS A 68000 CYCLE, LOOK FOR ASSERTION OF _DTACK.
				--IF THIS IS A 68000 WRITE CYCLE, ASSERT THE DATA STROBES HERE (SET PREVIOUSLY).

				IF nVPA = '0' AND nVMA = '1' AND vmacount = 2 THEN
				  --THIS IS A 6800 CYCLE, WE WAIT HERE UNTIL THE
				  --APPROPRIATE TIME IS REACHED ON E TO ASSERT _VMA, WHICH IS 
				  --BETWEEN 3 AND 4 CLOCK CYCLES AFTER E GOES TO LOGIC LOW.		

				  vmaout <= '0';	

				END IF;

				IF (nDTACK = '0' OR nBERR = '0' OR (nVMA = '0' AND vmacount = 8)) THEN

				  --WHEN THE TARGET DEVICE HAS ASSERTED _DTACK OR _BERR, WE CONTINUE ON.
				  --IF THIS IS A 6800/6502 (CIA) CYCLE, WE WAIT UNTIL E IS HIGH TO PROCEED.
				  --OTHERWISE, INSERT WAIT STATES UNTIL ONE OF THESE CONDITIONS IS SATISFIED.

				  CURRENT_STATE <= S5;

				END IF;

			WHEN S5 =>

				--NOTHING HAPPENS HERE. GO TO STATE 6.

				CURRENT_STATE <= S6;

			WHEN S6 =>

				--DURING READ CYCLES, THE DATA IS DRIVEN ON TO THE BUS DURING STATE 6.
				--THE 68000 NORMALLY LATCHES DATA ON THE FALLING EDGE OF STATE 7.
				--FOR 6800 CYCLES, E FALLS WITH THE FALLING EDGE OF STATE 7.

				CURRENT_STATE <= S7;
				dsacken <= '1';

				--FOR ALL CYCLES, WE NEGATE _AAS, _LDS, AND _UDS IN STATE 7.
				aasout <= '1';
				writecycle <= '1';
				readcycle <= '1';

			WHEN S7 =>
				--HOLD AT STATE 7 UNTIL 68030 _AS NEGATES.
				--THAT PREVENTS US FROM STARTING A NEW CYCLE UNTIL THE CURRENT CYCLE IS COMPLETE.

				--ONCE WE ARE IN STATE 7, WE NEGATE dsacken AND ALLOW THE _DSACK1 PROCESSS
				--TO DO IT'S THING.
				dsacken <= '0';

				--ONCE THE 68030 _AS IS NEGATED, WE CAN CLOSE OUT THIS CYCLE AND GET READY FOR THE NEXT.
				--READ/WRITE AND _VMA ARE HELD UNTIL THE CYCLE IS DONE. NEGATING THEM TOO SOON WILL MESS UP THE CYCLE.
				IF nAS = '1' THEN

				CURRENT_STATE <= S0;
				arwout <= '1';
				vmaout <= '1';

				END IF;

		END CASE;
			
	END IF;
		
END PROCESS;
         
          
