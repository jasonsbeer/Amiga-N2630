<img src="/Images/n2630exp-small.png">  
The N2630 is a Motorolla 68030 CPU card with additional RAM and IDE device port for the Amiga 2000 family of computers. It is installed in the CPU slot where it immediately upgrades the system to a 68030 processor with FPU, up to 264 megabytes of Fast RAM, and an ATA/IDE port. When desired, the 68030 processor may be temporarily disabled to run in 68000 mode. When running in 68000 mode, eight megabytes of Zorro 2 RAM remain enabled, unless otherwise disabled by the user.

<p align="center"><img src="/Images/2630rev2-small.png" width="750"></p>

## Features
1. Motorola 68030 microprocessor running at 25MHz or greater.
2. Motorola 68882 math coprocessor running at 25MHZ or greater.
3. 8 megabytes of Zorro 2 Fast RAM.
4. 16 to 256 megabytes of Zorro 3 Fast RAM.
5. PATA/IDE hard drive port.

## Installation Notes
This card may be installed in any Amiga 2000 computer. Installation is simply inserting the card into the 86 pin CPU/Coprocessor slot of the Amiga computer. There are no software drivers to install.  

Before installing, it is necessary to determine if you have an early, non-cost reduced motherboard. If your motherboard is marked "Made In Germany" and "(C) 1986 Commodore" on the left side of the board, you have a non-cost reduced Amiga 2000 board, designated "A2000" in this documentation. An example of a non-cost reduced Amiga 2000 motherboard can be see [here](http://amiga.resource.cx/photos/a2000,1). In the event you have an non-cost reduced "A2000" motherboard, you must remove the Motorola 68000 processor from the Amiga 2000 motherboard and place a jumper at J302 of the N2630. Unfortunately, it is not possible to run in Motorola 68000 mode on these early revision motherboards. All other Amiga 2000 motherboards are designated "B2000" and should leave the Motorola 68000 in place.

## 68030 Mode
By default, the N2630 starts in 68030 mode. When in 68030 mode, all installed RAM and the IDE/ATA device port are active.

## 68000 Mode
When desired, the 68030 may be disabled during a cold or warm start. This results in the Amiga falling back to using the 68000 processor. This may be desired when software does not run correctly on the 68030 processor. To start up in 68000 mode, hold down the right mouse button during startup. Select either the 68030 or 68000 from the screen options. Select "68000" and the Amiga will reset with the 68000 as the active processor. When in 68000 mode, the IDE/ATA port and Zorro 3 RAM are inactive. The Zorro 2 RAM continues to be available.

## FAST RAM
The N2630 uses SDRAM to provide the necessary memory for the Amiga system. SDRAM is the successor to Fast Page Memory found in devices such as the Amiga 3000, A2630 processor card, and other computers of the time. SDRAMs are a very cost effictive way to supply memory to older systems and are readily available either new or from unused memory modules. 

### Zorro 2
Zorro 2 RAM is the Amiga RAM found in the 24 bit address space of the Motorola 68000 processor. The Zorro 2 RAM on the N2630 is accessed by the 68030 as a 32-bit data bus and supports 16-bit DMA activities of the Zorro 2 bus. Installing 2Mx16 or greater capacity SDRAMs will allow the N2630 to configure the maximum of 8MB in the Zorro 2 space. Placing a jumper at position J404 will limit the amount of RAM configured to 4MB in the Zorro 2 space, freeing up 4MB to be supplied by other Zorro 2 devices. This may be useful in the event you have a device that requires it's own RAM for proper function. One example being the GVP Impact Series II card, which can only use its own RAM for DMA activities. 

The N2630 will always configure the onboard RAM and cannot be "shut up" in the AUTOCONFIG process. You must use the onboard RAM to maximize the performance of the MC68030. The N2630 Zorro 2 RAM may be disabled by placing a jumper at J303. This should only be done for testing purposes.

NOTE: Any SDRAM at least 2Mx16 in capacity in the 54-TSOP II footprint may be placed. However, it is not possible to achieve more than 8 megabytes of Zorro 2 RAM capacity. 

### Zorro 3
Zorro 3 RAM is the Amiga RAM found in the 32-bit address space of the Motorola 68030 processor. Both Zorro 2 and Zorro 3 RAM are used together on the N2630 card. Thus, the total memory available to the system will be the sum of the Zorro 2 and Zorro 3 RAM. 

Zorro 3 SDRAMs may be installed in different configurations to acheive a specific amount of final RAM (Table 1a). SDRAM must be installed in pairs, or banks, to acheive the needed 32 bit data path. Positions U406 and U407 represent the "low" bank and positions U408 and U409 represent the "high" bank. The banks must be populated as the low bank only or both low and high banks. The high bank will not function without the low bank popualated. The SDRAM footprint is 54-TSOP II. The indicated jumpers must be set as shown or your system may not function correctly. When installing both banks, jumpers J400, J401, and J401 must be set as shown in tables 1b and 1c. If only the low bank is populated, these jumpers should be left empty.

The Zorro 3 memory supports AUTOCONFIG with Kickstart 2.04 and newer and will be autosized by Amiga OS. When using Kickstart version 1.x, place a jumper at J305 to disable the Zorro 3 AUTOCONFIG. An addmem style program may be used to add the Zorro 3 memory to the Amiga's memory pool. See Table 1d for the N2630 Zorro 3 memory map.

Except as discussed above, disabling the Zorro 3 RAM is not recommended for regular use as this will degrade performance of the 68030.

**Table 1a.** Possible Zorro 3 RAM Combinations for the N2630.
Desired Zorro</br>3 RAM (MB)|SDRAM|Low Bank</br>(U406 and U407)|High Bank</br>(U408 and U409)
-|-|-|-
16|4MX16|Populated<sup>A</sup>|Unpopulated<sup>B</sup>
32|4MX16|Populated|Populated
32|8MX16|Populated|Unpopulated
64|8MX16|Populated|Populated
64|16MX16|Populated|Unpopulated
128|16Mx16|Populated|Populated
128|32MX16|Populated|Unpopulated
256|32MX16|Populated|Populated

<sup>A</sup> These SDRAM positions are populated by the SDRAM indicated.  
<sup>B</sup> This SDARM positions are not populated.

**Table 1b.** SDRAM Bank Jumper Setting.
Zorro 3 RAM</br>Banks Populated|J400
-|-
Low Bank Only|Open<sup>A</sup>
Both Banks|Shorted<sup>B</sup>

<sup>A</sup> No jumper.  
<sup>B</sup> Jumper placed. 
  
**Table 1c.** Jumper Configurations When Both Low and High Memory Banks Are Populated
Desired Zorro</br>3 RAM (MB)|SDRAM</br>Capacity|J401|J402
-|-|-|-
32|4MX16|Open<sup>[A]</sup>|Shorted<sup>[A]</sup>
64|8MX16|Shorted|Open
128|16Mx16|Shorted|Shorted
256|32MX16|Open|Open

<sup>A</sup> No jumper.  
<sup>B</sup> Jumper placed.  

**Table 1d.** N2630 Zorro 3 Memory Map
Desired Zorro</br>3 RAM (MB)|Starting Address|Ending Address
-|-|-
16|$40000000|$40FFFFFF
32|$40000000|$41FFFFFF
64|$40000000|$43FFFFFF
128|$40000000|$47FFFFFF
256|$40000000|$4FFFFFFF

## ATA/IDE Port
The N2630 includes an AUTOBOOT<sup>[A]</sup> ATA/IDE port compatable with hard drives and ATAPI<sup>[B]</sup> devices. The port supports two devices (master and slave) and operates in PIO 0 mode. The port may be disabled by placing a jumper on J600. (Table 2) For instructions on installing a new hard drive on Amiga computers, refer to the [Commodore Hard Drive User's Guide](DataSheet/Hard_Drive_Users_Guide.pdf). This includes the HDToolBox user guide and other useful information for setting up both IDE and SCSI devices.

<sup>A</sup>AUTOBOOT requires Kickstart v37.300 or greater or compatable SCSI.device in Kickstart.  
<sup>B</sup>ATAPI support included in Kickstart 3.1.4+. Older versions of Kickstart may require installation of third party ATAPI drivers.  

**Table x.** PIO Mode Jumpers
MAYBE THIS WORKS, MAYBE NOT.
MAYBE WE HAVE JUMPERS, MAYBE WE DON'T.

## 68882 Math Coprocessor (FPU)
The Motorolla MC68882 (or MC68881) floating point unit may be optionally added to the N2630. The FPU is typically driven at the same clock freuqency as the 68030 via the X1 oscillator, but may be clocked independently via the X2 oscillator (see Table 3, J202). The PLCC-68 footprint is supported, which is available up to 40MHz.

## Unix (Amix)
The N2630 card should fully support Amiga Unix (Amix). In order to boot into a Unix environment, you must place a jumper at J304. (Table 2) Although this feature is fully supported by the A2630 ROMs, it has not been tested with the N2630 at this time.

## Other Jumper Settings
In the following tables, OPEN indicates no jumper. Shorted indicates the presence of a jumper on the pins indicated. All jumpers must be set correctly or you may encounter unexpected bahaviors or failure to boot.

**Table 2.** Configuration Jumper Settings
Jumper|Description|Shorted|Open<sup>[A]</sup>
-|-|-|-
J302|Amiga Version|A2000|B2000
J303|Zorro 2 RAM|Disable|Enable
J304|OS Mode|Unix|Amiga OS
J305|Zorro 3 RAM|Disable|Enable
J404|Z2 4/8MB|4MB|8MB
J600|IDE|Disable|Enable

<sup>A</sup>The factory configuration for all jumpers is open (no jumper).  

**Table 3.** System Clock Jumper Settings
Jumper|Description|1-2|2-3
-|-|-|-
J202|FPU Clock|X1<sup>[A]</sup>|X2<sup>[B]</sup>

<sup>A</sup>FPU clock from X1. Factory default.  
<sup>B</sup>FPU clock from X2.

## Acknowledgements
Dave Haynie for sharing the A2630 technical details with the Amiga community.  
Matt Harlum for sharing his Gayle IDE code and listening to all my problems.  
Everyone who made the Amiga possible.  

## License
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
