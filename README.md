# Amiga N2630
The N2630 is a Motorolla 68030 CPU card with RAM and IDE for the Amiga 2000 family of computers. It is installed in the CPU slot where it immediately upgrades the system to a 25MHz 68030 processor with FPU, up to 264 megabytes of Fast RAM, and an ATA/IDE port. When desired, the 68030 processor may be disabled in software to run the Amiga 2000 in 68000 mode. This enables compatability with tempermental software. When running in 68000 mode, eight megabytes of Zorro 2 RAM and the ATA/IDE port remain enabled, unless otherwise disabled by the user.

<img src="/Images/N2360_PCB_R1.png" width="750">

## Features
1. Motorola 68030 microprocessor running at 25MHz.
2. Motorola 68882 math coprocessor running at 25MHZ or greater.
3. Eight megabytes of Zorro 2 Fast RAM.
4. Up to 256 megabytes of Zorro 3 Fast RAM.
5. PATA/IDE hard drive port.

## Installation Notes
This card may be installed in any Amiga 2000 computer. This includes Amiga 2000HD and Amiga 2000 EATX computers. Some Amiga 2000 versions came from the factory with a 68030 card installed. This card will work equally well in those systems. Installation is as simple as inserting the card into the 86 pin CPU/Coprocessor slot of the Amiga computer. There are no software drivers to install.  

Before installing, it is necessary to determine if you have an early, non-cost reduced motherboard. If your motherboard is marked "Made In Germany" and "(C) 1986 Commodore" on the left side of the board, you have a non-cost reduced Amiga 2000 board. An example of a non-cost reduced Amiga 2000 motherboard can be see [here](http://amiga.resource.cx/photos/a2000,1). In the event you have an non-cost reduced motherboard, you must remove the Motorola 68000 processor from the Amiga 2000 motherboard and place a jumper at J302. Unfortunately, it is not possible to run in Motorola 68000 mode on these early revision motherboards. All other Amiga 2000 motherboards should leave the Motorola 68000 in place.

## 68030 Mode

## 68000 Mode

## Memory
The N2630 uses SDRAM to provide the necessary memory for the Amiga system. SDRAM is the successor to Fast Page Memory found in devices such as the Amiga 3000, A2630 processor card, and other computers of the time. SDRAMs are a very cost effictive way to supply memory to older systems and are readily available from large electronics supply houses.    
### Zorro 2
Zorro 2 RAM is the Amiga RAM found in the 24 bit address space of the Motorola 68000 processor. This RAM space can be used by the Motorola 68030 and supports DMA activities on the Zorro 2 bus. When 68000 mode is selected, the Zorro 2 memory expansion remains available to the system. The Zorro 2 RAM may be disabled by adding a jumper to J303. Disabling the Zorro 2 RAM is not recommended for regular use as this will degrade performance of the system.

SPECIAL NOTE: The Zorro 2 SDRAMs at U400 and U401 are called out as 2Mx16 in the BOM. This is the specific size requried to acheive 8MB of Zorro 2 RAM. In the event you are unable to supply this specific size SDRAM, any greater capacity 16 bit wide SDRAM in the 54-TSOP II footprint may by substituted. For example, 4Mx16 could be placed and will function correctly. Zorro 2 RAM is limited to a maximum of 8MB. Placing greater capacity SDRAMs at U400 and U401 will not result in a greater amount of Zorro 2 RAM. 

### Zorro 3
Zorro 3 RAM is the Amiga RAM found in the 32 bit address space of the Motorola 68030 processor. Both Zorro 2 and Zorro 3 RAM are used together on the N2630 card. Thus, total memory available to the system will be the sum of the Zorro 2 and Zorro 3 RAM. Zorro 3 SDRAMs may be installed in different configurations to acheive a specific amount of final RAM (Table 1). The SDRAM footprint is 54-TSOP II. The indicated jumpers must be set as shown or your system may not function correctly.

The Zorro 3 RAM may be disabled by adding a jumper to J305. Disabling the Zorro 3 RAM is not recommended for regular use as this will degrade performance of the 68030.

**Table 1.** Possible Zorro 3 RAM configurations.
Desired Zorro</br>3 RAM (MB)|SDRAM</br>Capacity|U406|U407|U408|U409|JM0|JM1|JM2
-|-|-|-|-|-|-|-|-
16|4MX16|YES<sup>A</sup>|YES|NO<sup>B</sup>|NO|Open<sup>C</sup>|Open|Open
32|4MX16|YES|YES|YES|YES|Shorted<sup>D</sup>|Open|Open
32|8MX16|YES|YES|NO|NO|Open|Open|Shorted
64|8MX16|YES|YES|YES|YES|Shorted|Open|Shorted
64|16MX16|YES|YES|NO|NO|Open|Shorted|Open
128|16Mx16|YES|YES|YES|YES|Shorted|Shorted|Open
128|32MX16|YES|YES|NO|NO|Open|Shorted|Shorted
256|32MX16|YES|YES|YES|YES|Shorted|Shorted|Shorted

<sup>A</sup> This position to be populated by the SDRAM indicated.  
<sup>B</sup> This position not populated.  
<sup>C</sup> No jumper.  
<sup>D</sup> Jumper placed.  
## ATA/IDE Port
The N2630 includes an AUTOBOOT<sup>A</sup> ATA/IDE port compatable with hard drives and ATAPI<sup>B</sup> devices. The port supports two devices (master and slave) and operates in PIO mode. The port may be disabled by placing a jumper on J600 (Table 2). For instructions on installing a new hard drive on Amiga computers, refer to the [Commodore Hard Drive User's Guide](DataSheet/Hard_Drive_Users_Guide.pdf). This includes the HDToolBox user guide and other useful information for setting up both IDE and SCSI devices.

<sup>A</sup>AUTOBOOT requires Kickstart v37.300 or greater or compatable SCSI.device in Kickstart.  
<sup>B</sup>ATAPI support included in Kickstart 3.1.4+. Older versions of Kickstart may require installation of third party ATAPI drivers.  
## 68882 Math Coprocessor (FPU)


## Other Jumper Settings
In the following tables, OPEN indicates no jumper. Shorted indicates the presence of a jumper on the pins indicated. All jumpers must be set correctly or you may encounter unexpected bahaviors or failure to boot.

**Table 2.** Configuration Jumper Settings
Jumper|Description|Shorted|Open<sup>A</sup>
-|-|-|-
J302|Amiga Version|A2000|B2000
J303|Zorro 2 RAM|Disable|Enable
J304|OS Mode|Unix|Amiga OS
J305|Zorro 3 RAM|Disable|Enable
J600|IDE|Disable|Enable

<sup>A</sup>The factory configuration for all jumpers is open (no jumper).  

**Table 3.** SDRAM Refresh Jumper Settings
Jumper|50MHz<sup>A</sup>|40MHz|33MHz|25MHz
-|-|-|-|-
Jxxx|Shorted|Open|Shorted|Open
Jxx1|Shorted|Shorted|Open|Open

<sup>A</sup>Set jumpers to match CPU clock.

**Table 4.** System Clock Jumper Settings
Jumper|Description|1-2|2-3
-|-|-|-
J201|CPU Clock|28MHz|X1<sup>A,B</sup>
J202|FPU Clock|X1<sup>A</sup>|X2<sup>B</sup>

<sup>A</sup>Factory default.  
<sup>B</sup>The clock signal is supplied by X1 or X2 oscillator.

## License
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
