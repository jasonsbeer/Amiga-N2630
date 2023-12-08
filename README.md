<img src="/Images/n2630exp-small.png">  
The N2630 is a 50MHz Motorolla 68030 CPU card with additional RAM and IDE device port for the Amiga 2000 family of computers. It is installed in the CPU slot where it immediately upgrades the system to a 68030 processor with FPU, up to 264 megabytes of Fast RAM, and an IDE port. The N2630 is intended to be an evolution of the A2630 card.  

<br />Look for the N2630 channel on Discord: https://discord.gg/NU7SPYfNFj  

<p align="center"><img src="/Images/N2630-30-a.jpg" width="750"></p>

## CURRENT STATUS:
**Revision 4.0.1a/b is the current production release.**  

Sub-revision 4.0.1a supports the PLCC footprint MC68882. Sub-revision 4.0.1b supports the PGA footprint MC68882. They are otherwise identical.  

See the [issues](https://github.com/jasonsbeer/Amiga-N2630/issues) tab for known issues. [Click here](/TestedDevices.md) to see a list of devices tested with the N2630.

<p align="center">
<img src="/Images/n2630-401-med.jpg" width="400">
<img src="/Images/workbench.jpg" width="400">
</p>

## Features
1. Motorola 68030 microprocessor running at 50MHz.
2. Motorola 68882 math coprocessor running up to 50MHz.
3. 4 or 8 megabytes of Zorro 2 Fast RAM.
4. 16 to 256 megabytes of Zorro 3 Fast RAM.
5. IDE port with 40-pin cable and compact flash card options.

## Assembly Notes
Click [here](/AssemblyNotes.md) for more information on building the N2630.

## Installation Notes
This card may be installed in any Amiga 2000 computer. Installation is simply inserting the card into the 86 pin CPU/Coprocessor slot of the Amiga computer. There are no software drivers to install.  Kickstart v37.300 and greater is recommended.

**IMPORTANT:** Before installing a Revision 4.0.1 or greater N2630, it is necessary to determine if you have an early, non-cost reduced motherboard. If your motherboard is marked "Made In Germany" and "(C) 1986 Commodore" on the left side of the board, you have a non-cost reduced Amiga 2000 board, designated "A2000" in this documentation. An example of a non-cost reduced Amiga 2000 motherboard can be see [here](http://amiga.resource.cx/photos/a2000,1). In the event you have an non-cost reduced "A2000" motherboard, you must remove the Motorola 68000 processor from the Amiga 2000 motherboard and place a jumper at J302 of the N2630.  All other Amiga 2000 motherboards are designated "B2000" and should leave the Motorola 68000 in place. Revision 3.0.x cards do not support the original German A2000. 

**NOTES:**  
**1) Hardware revision 4.0.1 supports the original Germal A2000, but is untested.**  
**2) The A2091 hard drive card will not operate correctly when using Kickstart 1.x on a revision 6.2 or newer Amiga 2000 with the N2630 or A2630 CPU cards. You must use Kickstart 2.04 or newer.**

## 68030 Mode
By default, the N2630 starts in 68030 mode. When in 68030 mode, all installed RAM and the IDE device port are active.

## 68000 Mode
When desired, the 68030 may be disabled during a cold or warm start. This results in the Amiga falling back to the 68000 processor. This may be desired when software does not run correctly on the 68030 processor. To start up in 68000 mode, hold down the right mouse button during startup. Select "68000" and the Amiga will reset with the 68000 as the active processor. When in 68000 mode, the IDE port and on-board RAM are inactive. Motorola 68000 mode is not available with A2000 motherboards.

## 68882 Math Coprocessor (FPU)
The Motorolla MC68882 (or MC68881) floating point unit may be optionally added to the N2630. The FPU is typically driven at the same clock freuqency as the MC68030 via the X1 oscillator, but may be clocked independently via the X2 oscillator (see Table 3, J202).

## ROMs
The N2630 requires two 27C256 EPROMs (burned by the user) to function. The ROMs handle the system startup for CPU selection and contains the [LIDE.device](https://github.com/LIV2/lide.device) AUTOBOOT ROM. See the instructions [here](/ROMs.md) for burning the N2630 ROMs.

## FAST RAM
The N2630 uses SDRAM to provide the necessary memory for the Amiga system. SDRAM is the successor to Fast Page Memory found in devices such as the Amiga 3000, A2630 processor card, and other computers of the time. SDRAMs are a cost effective way to supply memory to older systems and are readily available either new or from unused memory modules. 

### Zorro 2
Zorro 2 RAM is the Amiga RAM found in the 24 bit address space of the Motorola 68000 processor. The Zorro 2 RAM on the N2630 is accessed by the 68030 as a 32-bit data bus and supports 16-bit DMA activities of the Zorro 2 bus. Placing a jumper at position J404 will limit the amount of RAM to 4MB in the Zorro 2 space, freeing up 4MB to be supplied by other Zorro 2 devices. As an example, if you have a 4MB Zorro 2 video card, it will be necessary to set jumper J404 to free up this address space for the video card. Failure to do so will result in the video card failing to pass the AUTOCONFIG process. As another example, if you have two 4MB Zorro 2 devices, such as a video card and Bridge card, these devices require the entire 8MB Zorro 2 address space. In this situation, you must disable the Zorro 2 RAM entirely by placing a jumper at J403.

Using expansion memory on the Zorro 2 bus is not recommended, as this will negatively impact the performance of the MC68030 when accessing this memory on the Zorro 2 bus. The expansion memory on the N2630 should always be used as a first choice.

NOTE: Any SDRAM at least 2Mx16 in capacity in the 54-TSOP II footprint may be placed. However, it is not possible to achieve more than 8 megabytes of Zorro 2 RAM capacity. 

### Zorro 3
Zorro 3 RAM is the Amiga RAM found in the 32-bit address space of the Motorola 68030 processor. The Zorro 3 RAM on the N2630 supports the cache burst mode of the 68030 processor. Both Zorro 2 and Zorro 3 RAM are used together on the N2630 card. Thus, the total memory available to the system will be the sum of the Zorro 2 and Zorro 3 RAM. 

Zorro 3 SDRAMs may be installed in different configurations to achieve a specific amount of final RAM (Table 1a). SDRAM must be installed in pairs, or banks, to achieve the needed 32 bit data path. Positions U406 and U407 represent the "low" bank and positions U408 and U409 represent the "high" bank. The banks must be populated as the low bank only or both low and high banks. The high bank will not function without the low bank populated. The SDRAM footprint is 54-TSOP II. The indicated jumpers must be set as shown or your system may not function correctly. When installing both banks, jumpers J400 and J401 must be set as shown in tables 1b and 1c. If only the low bank is populated, these jumpers are not used.

The Zorro 3 memory supports AUTOCONFIG with Kickstart 2.04 and newer and will be auto sized by Amiga OS. When using Kickstart version 1.x, place a jumper at J405 to disable the Zorro 3 AUTOCONFIG. An addmem style program may be used to add the Zorro 3 memory to the Amiga's memory pool. See Table 1d for the N2630 Zorro 3 memory map.

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

<sup>A</sup>These SDRAM positions are populated by the SDRAM indicated.  
<sup>B</sup>This SDRAM positions are not populated.

**Table 1b.** SDRAM Bank Jumper Setting.
Zorro 3 RAM</br>Banks Populated|J400
-|-
Low Bank Only|Open<sup>A</sup>
Both Banks|Shorted<sup>B</sup>

<sup>A</sup>No jumper.  
<sup>B</sup>Jumper placed. 
  
**Table 1c.** Jumper Configurations When Both Low and High Memory Banks Are Populated.
Desired Zorro</br>3 RAM (MB)|SDRAM</br>Capacity|J401<sup>[A]</sup>|J402<sup>[A]</sup>
-|-|-|-
32|4MX16|Open<sup>[B]</sup>|Shorted<sup>[C]</sup>
64|8MX16|Shorted|Open
128|16Mx16|Shorted|Shorted
256|32MX16|Open|Open

<sup>A</sup>Ignored when J400 is open.  
<sup>B</sup>No jumper.  
<sup>C</sup>Jumper placed.  

**Table 1d.** N2630 Zorro 3 Memory Map.
Desired Zorro</br>3 RAM (MB)|Starting Address|Ending Address
-|-|-
16|$40000000|$40FFFFFF
32|$40000000|$41FFFFFF
64|$40000000|$43FFFFFF
128|$40000000|$47FFFFFF
256|$40000000|$4FFFFFFF

## IDE Port
The N2630 includes a buffered, host terminated AUTOBOOT IDE port for hard drives and ATAPI<sup>[B]</sup> devices. The N2630 implements [LIDE.device](https://github.com/LIV2/lide.device) as the IDE driver. The driver must be present on the N2630 ROMs for the IDE port to function. See [ROMs](#ROMs) for more details. The IDE port may be accessed via the 40-pin IDE header and the compact flash card slot. There are a few different ways to combine devices on the port, but the total number of IDE devices on the N2630 cannot exceed two (master and slave). For instructions on installing a new hard drive on Amiga computers, refer to the [Commodore Hard Drive User's Guide](DataSheet/Hard_Drive_Users_Guide.pdf). This includes the HDToolBox user guide and other useful information for setting up both IDE and SCSI devices. 

The IDE logic supports four speed modes: PIO0, PIO2, PIO4, and SanDisk Ultra 2 (see Table 2B). The modes PIO0, PIO2, and PIO4 follow the published timing specifications of those modes, with PIO0 being the slowest. The SanDisk Ultra 2 mode was developed for the SanDisk Ultra 2 compact flash card and is capable of 7.4M/s transfer rate. The SanDisk Ultra 2 mode is an undocumented IDE timing and may not work with other compact flash devices. The speed mode you select will be determined by the slowest IDE device on your system. To determine what speed your devices support, it is recommended to start with the slowest setting (PIO0) and adjust one setting higher at a time until your device(s) stop working. The mode you choose should be the fastest mode where all devices function correctly. Jumpers should only be changed while the system is off.

Each IDE device must be set as slave or master. Devices present on the 40 pin IDE port may use cable select by shorting J905 when using a proper cable select IDE cable. See the manual for each device to determine the how to designate the device's master or slave setting. Master and slave for the compact flash device are set via J901 on the N2630.

**NOTE:** The compact flash card slot is not effected by the cable select jumper (J905).  Thus, J905 should only be used when a proper cable select IDE cable is implemented on the 40 pin IDE port.

<sup>A</sup>ATAPI support included in Kickstart 3.1.4+. Older versions of Kickstart may require installation of third party ATAPI drivers.  

**Table 2A.** IDE Configuration Jumper Settings.
Jumper|Description|Open<sup>[A]</sup>|Shorted<sup>[B]</sup>
-|-|-|-
J900|RESERVED||
J901|Compact Flash Select|Slave|Master
J902|PIO MODE||
J903|PIO MODE||
J904|RESERVED||
J905|Cable Select|Disable|Enable

<sup>A</sup>No jumper.  
<sup>B</sup>Jumper placed. 

**Table 2B.** IDE PIO Mode.
Jumper|J902|J903
-|-|-
PIO0|Shorted[B]|Shorted|
PIO2|Shorted|Open[A]|
PIO4|Open|Shorted|
SanDisk Ultra 2|Open|Open|

<sup>A</sup>No jumper.  
<sup>B</sup>Jumper placed.

## Other Jumper Settings
In the following tables, OPEN indicates no jumper. Shorted indicates the presence of a jumper on the pins indicated. All jumpers must be set correctly or you may encounter unexpected behaviors or failure to boot.

**Table 3a.** Configuration Jumper Settings
Jumper|Description|Shorted|Open<sup>[A]</sup>
-|-|-|-
J302|Amiga Version|A2000|B2000
J304|OS Mode|Unix|Amiga OS
J403|Zorro 2 RAM|Disable|Enable
J404|Z2 4/8MB|4MB|8MB
J405|Zorro 3 RAM|Disable|Enable

<sup>A</sup>The factory configuration for all jumpers is open (no jumper).  

**Table 3b.** System Clock Jumper Settings
Jumper|Description|1-2|2-3
-|-|-|-
J202|FPU Clock|X1<sup>[A]</sup>|X2<sup>[B]</sup>

<sup>A</sup>FPU clock from X1. Factory default.  
<sup>B</sup>FPU clock from X2.

## Revision History
Revision 4.0.1a/b  
   Sub-revision 'a' supports OLCC MC68882, sub-revision 'b' supports the PGA MC68882.  
   Changed jumper footprint to increase ease of assembly.  
   Added order number location for JLCPCB.  
   Added support for original German A2000 machines.
   
Revision 3.0.1  
   Added copper thieving areas to top and bottom layers.  
   
Revision 3.0  
   Initial production release.  

## Acknowledgements
Dave Haynie for sharing the A2630 technical details with the Amiga community.  
Matt Harlum for (LIV2) sharing his Gayle IDE code, LIDE.device, submitting code improvements, listening my struggles, and his numerous other contributions to this project.  
Stephen Durham (steveed) for loaning me his ethernet cards.  
Members of the Discord testing group: LIV2, steeveed, Chrissy, Pillock.  
Everyone who made the Amiga possible.  

Last Updated: December 8, 2023

## License
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
