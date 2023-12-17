# Building the N2630 ROMs

The N2630 requires two 27C256 EPROMS with the correct ROM images to function. The low ROM occupies space U102 and the high ROM occupies U103.

## BIN Files
Before burning, you must acquire the following files:

[A2630 High ROM](/ROM)  
[A2630 Low ROM](/ROM)  
[LIDE.device High ROM](https://github.com/LIV2/lide.device/releases/latest/download/lide-N2630-high.rom)  
[LIDE.device Low ROM](https://github.com/LIV2/lide.device/releases/latest/download/lide-N2630-low.rom)  

## Burning
You must combine the two HIGH ROM and two LOW ROM files together before burning. Instructions are given here to combine the ROM files with the XGecu Pro software for the TL866II (and successor) programmers. Other programmers should have similar functionality, but are outside the scope of this document.

The A2630 ROM occupies $0000 - $3FFF of each EPROM. The LIDE.device occupies $4000 - $7FFF of each EPROM.  

From the XGecu software:  

1. Import the A2630 Low ROM: Use the default import settings. After importing, you should see data in the $0000 - $3FFF address range. The bytes in last few lines are all $FF, which is normal.  

<img src="/Images/XGECU1.jpg">

2. Import the LIDE.device Low ROM: Select the file and change the import settings as follows:  
   2a. To Buffer Strat[SIC] Addr(HEX) = 04000  
   2b. Clear Buffer When Loading the File = DISABLE.  
   2c. Click OK to import the file.

<img src="/Images/XGECU2.jpg">
   
4. You should now see the LIDE.device data has occupied the $4000 - $7FFF address range.  
5. The A2630 data should still occupy the $0000 - $3FFF range. If not, repeat from step 1.  
6. Burn the EPROM as per programmer user manual.
7. Label the EPROM.
8. Repeat steps 1 - 6 with the HIGH ROM files.  

You should now have two ROMS, low and high, for the N2630.
   

