# Amiga N2630
The N2630 is a Motorolla 68030 CPU card with RAM and IDE for the Amiga 2000 family of computers. It is installed in the CPU slot where it immediately upgrades the system to a 25MHz 68030 processor with FPU, 136 megabytes of Fast RAM, and an ATA/IDE port. When desired, the 68030 processor may be disabled in software to run the Amiga 2000 in 68000 mode. This enables compatability with tempermental software. When running in 68000 mode, eight megabytes of Zorro 2 RAM and the ATA/IDE port remain enabled, unless otherwise disabled by the user.

<img src="/Images/N2360_PCB_R1.png" width="750">

## Features
1. Motorola 68030 microprocessor running at 25MHz.
2. Motorola 68882 math coprocessor running at 25MHZ or greater.
3. Eight megabytes of Zorro 2 RAM.
4. 128 megabytes of Zorro 3 RAM.
5. PATA/IDE hard drive port.

## Installation Notes
This card may be installed in any Amiga 2000 computer. This includes Amiga 2000HD and Amiga 2000 EATX computers. Some Amiga 2000 versions came from the factory with a 68030 card installed. This card will work equally well in those systems. Installation is as simple as inserting the card into the 86 pin CPU/Coprocessor slot of the Amiga computer. There are no software drivers to install.  

Before installing, it is necessary to determine if you have an early, non-cost reduced motherboard. If your motherboard is marked "Made In Germany" and "(C) 1986 Commodore" on the left side of the board, you have a non-cost reduced Amiga 2000 board. An example of a non-cost reduced Amiga 2000 motherboard can be see [here](http://amiga.resource.cx/photos/photo2.pl?id=a2000&pg=2&res=med&lang=en). In the event you have an non-cost reduced motherboard, you must remove the Motorola 68000 processor from the Amiga 2000 motherboard. Unfortunately, it is not possible to run in Motorola 68000 mode on these early revision motherboards. All other Amiga 2000 motherboards should leave the Motorola 68000 in place.

(SCSI.DEVICE required in Kickstart for AUTOBOOT)


## 68030 Mode

## 68000 Mode

## Memory
### Zorro 2
### Zorro 3

## ATA/IDE Port

## 68882 Math Coprocessor (FPU)


## Table 1 REV 1. Configuration Jumper Settings
Jumper|Description|Shorted|Open*
-|-|-|-
J302|Amiga Version|A2000|B2000
J303|Zorro 2 RAM|Disable|Enable
J304|OS Mode|Unix|Amiga OS
J305|Zorro 3 RAM|Disable|Enable
J600|IDE|Disable|Enable

*The factory configuration for all jumpers is open (no jumper)

## Table 2. Clock Jumper Settings
Jumper|Description|1-2|2-3
-|-|-|-
J201|CPU Clock|28MHz|X1* (25MHz)
J202|FPU Clock|X1* (25MHz)|X2

*Factory default
