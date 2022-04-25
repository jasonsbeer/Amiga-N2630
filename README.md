# Amiga N2630
A re-imagining of the Amiga A2630 processor card.

<img src="/Images/N2360_PCB_R1.png" width="750">

## Features
1. Accelerator card for the Amiga 2000 computer.
2. Compatible with either 2 or 4* layer Amiga 2000 boards and the Amiga 2000 EATX.
3. Motorola 68030 microprocessor running at 25MHz, which can be disabled to enhance compatability with non-compliant software.
4. Motorola 68882 math coprocessor running at 25MHZ or can be independently clocked up to the rated speed of the 68882.
5. 8 megabytes of Zorro 2 RAM that can be used even when the 68030 processor is disabled.
6. 112 megabytes of Zorro 3 RAM.
7. PATA/IDE drive support that can be used even when the 68030 processor is disabled. SCSI.DEVICE required in Kickstart for AUTOBOOT.**

*Motorola 68000 CPU must be removed from 4-layer boards for proper operation.

**Kickstart version 37.300 and greater include SCSI.DEVICE in ROM.

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
