# Amiga N2630
A re-imagining of the Amiga A2630 processor card.

<img src="/Images/N2360_PCB_R1.png" width="750">

## Table 1. Configuration Jumper Settings
Jumper|Description|Shorted|Open*
-|-|-|-
J301|Zorro 2 RAM Size|4MB|8MB
J302|Amiga Version|A2000|B2000
J303|Zorro 2 RAM|Do Not Configure|Configure
J304|OS Mode|Unix|Amiga OS
J305|Zorro 3 RAM|Do Not Configure|Configure
J600|IDE|Disabled|Enabled

*The factory configuration for all jumpers is open (no jumper)

## Table 1 REV 1. Configuration Jumper Settings
Jumper|Description|Shorted|Open*
-|-|-|-
J302|Amiga Version|A2000|B2000
J303|Zorro 2 RAM|Disable|Enable
J304|OS Mode|Unix|Amiga OS
J305|Zorro 3 RAM|Disable|Enable
J600|IDE|Disable|Enable

## Table 2. Clock Jumper Settings
Jumper|Description|1-2|2-3
-|-|-|-
J201|CPU Clock|28MHz|X1* (25MHz)
J202|FPU Clock|X1* (25MHz)|X2

*Factory default
