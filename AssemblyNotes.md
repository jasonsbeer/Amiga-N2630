# Assembly Notes, BOM, and Ramblings

IMPORTANT INFORMATION. It is highly recommended you read this entire page before committing to assemble the N2630. You must also review any postings in the [Issues](https://github.com/jasonsbeer/Amiga-N2630/issues) tab to fully understand any limitations or issues.

**Disclaimer:** This project is free and open source. It is a very complex project and should only be undertaken by individuals experienced in SMD assembly techniques. It requires knowledge and tools for programming complex logic devices and EPROMs. No warranty or guarantee is offered that it will work for your particular situation. You assume all risk should you choose to build it.

## Ordering PCBs

The N2630 PCB is a full-size Amiga 2000 CPU card with 4 layers. You can find the Gerber files [here](/Gerber). When ordering, it is recommended you choose the ENIG surface finish and chamfer the card edge. The layer stackup is shown below, in the event you need to define it as part of your order.

Board dimensions = 124.5mm x 318.4mm  
Track/Spacing = 4/4mil  
Min Hole Size = 0.3mm  

<!--<img src="/Images/jlcpcb1a.jpg" width = "600">

<img src="/Images/jlcpcb2a.jpg" width = "600">-->

<img src="/Images/jlcpcb3a.jpg" width = "400">

JLCPCB recently changed their production capabilites and will reject the N2630 PCB due to trace clearance.

## Bill of Materials  

The official BOM is found [here](/N2630-REV30-BOM.csv) and should be used for ordering parts. An interactive BOM can be found [here](/N2630-REV30-ibom.html). This can be used to locate components on the board. Download the file and open it your browser.

The MC68030 and MC68882 need to be obtained through a retailer that handles legacy Motorola devices. At the time of writing this, you should expect to pay US$30 - $50 each. DO NOT buy components where you get five chips for $20. These are likely counterfeit or remarked chips. Save yourself the misery and pay for the real ones.

Most compents in the BOM are general purpose passive and logic parts with many compatable alternatives. Due to availability of parts, it is difficult to keep a list of part numbers that remains valid even for a short period of time. I have listed Digikey part numbers I used in my most recent order to help you understand what is needed. You can cross reference the Digikey part number should these go out of stock.

**It is important to use the -10 speed rated Xilinx CPLDs in this project. The logic equations are designed for that speed. Going to faster rated CPLDs may break the timings and result in erratic behavior.**

PGA-128 sockets are very difficult to find and can be very expensive. A good alternative is to use machine pin strips to make your own socket. It is not pretty, but it works well. The Motorola parts you obtain may be pulls and have bent pins, which makes it very difficult to line up to the socket. I recommend adding the machine pin socket strips to the MC68030 one row at a time. You can then install the entire assembly for soldering. This greatly simplifies installation of the MC68030 on the board.

<img src="/Images/68030pins.jpg" width="500">

**NOTE:** 

1) Be sure to select 166MHz SDRAM. Slower SDRAM may not work at 50MHz.
2) Sockets are NOT listed in the BOM. I prefer 3M sockets for my projects.
3) Components not listed on the BOM are reserved for future use and do not need to be populated.
4) I recommend you do not install the 68882 (or socket) until everything is known to work. The through holes here are very convienient for connecting probes in the event troublshooting is required.

## Programming the CPLDs
The three CPLDs (U600, U601, and U602) must be programmed before the N2630 will function. Each CPLD has a dedicated programming port, CN600, CN601, and CN602. The best way to program these is to plug the card into the Amiga, power it on, and program it while in circuit with power coming from the Amiga 2000. The JED files can be found [here](/Logic/JED). Make certain to program each CPLD with the matching JED file for your hardware revision. 

Discussion programming CPLDs is not in the scope of this document, but many resources are available on the internet. I have been using a Raspberry Pi 2 with xc3sprog. Xilinx programming dongles are also available.

## Programming the ROMs
Most cheap EPROM programmers will handle the 27C256 EPROMs of the N2630. A popular one is the TL866II, but there are other options. There are a lot of these in the community. Someone may be able to assist if you do not wish to purchase a programmer. The EPROMs are programmed independently of the N2630. The ROMs can be found [here](/ROM/).

## Troubleshooting
1) Check for solder bridges or bad solder joints.
2) Double check the jumpers. It is critical the jumpers be set correctly for proper and reliable function.
3) Disable the Zorro 2 RAM, Zorro 3 RAM, and the IDE port. The Amiga 2000 will boot without these and it may help narrow down where the issue lies.

Follow these troubleshooting order of operations if your Amiga 2000 fails to start in 68030 mode or starts to a black screen. If these steps are executing correctly, you should start in 68030 mode and see the Kickstart screen. There a test points that can be used to help in troubleshooting process.

Table 1. N2630 startup order of operations.
Step|Expected Function|Possible Failure
-|-|-
1|N2630 asserts bus request (_BR at MC68000)|Bad solder joint. No power to U600.
2|MC68000 asserts bus grant (_BG)|
3|N2630 asserts _BOSS (_BGACK at MC68000) and negates bus request (_BR)|Bad solder joint. No power to U600.
4|MC68000 negates bus grant (_BG)|
5a|N2630 _CSROM begins oscillating|Bad solder joint on A(23..16) or _CSROM to U601. No power to U601.
5b|Concurrent with 5a, SMDIS begins oscillating|Bad solder joint at U600 or U601. No power to U601.
5c|Concurrent with 5a and 5b, N2630 drives MC68000/A2000 data and address buses to read A2000 chip registers|Bad solder joint or no power at U701, U702, U703, U704, U705, U706, U707. Bad solder joint signals _AAENA, AADIR, DRSEL, _ADOEH, _ADOEL, ADDIR, _AAS, _LDS, _UDS, AR_W, etc...
6|N2630 negates _CSROM|Bad solder joints on A(15..1) or D(31..16) at U102, U103, or MC68030.
7|N2630 drives MC68000/A2000 data and address buses|Bad solder joint or no power at U701, U702, U703, U704, U705, U706, U707. Bad solder joint signals _AAENA, AADIR, DRSEL, _ADOEH, _ADOEL, ADDIR, _AAS, _LDS, _UDS, AR_W, etc...
8|Kickstart screen appears|

Table 2. N2630 test points.
Test Point|Meaning|Purpose
-|-|-
SMDIS|State Machine Disable|This signal is HIGH when onboard ROM, RAM, or IDE address spaces are active.
_MEMZ2|Zorro 2 Memory Access|This signal is LOW when onboard Zorro 2 RAM address space is active.
_MEMZ3|Zorro 3 Memory Access|This signal is LOW when onboard Zorro 3 RAM address space is active.
_IDEACCESS|IDE Access|This signal is LOW when onboard IDE address space is active.
MODE68K|68000 Mode|This signal is HIGH when the N2630 is operating in Motorola 68000 mode. Low when in Motorola 68030 mode.

## Ramblings
The Zorro 3 RAM, IDE Port, and MC68882 are all optional. If you choose not to install the Zorro 3 RAM and/or IDE port, you can omit the associated logic and passives. If you do this, be sure to disable these by properly setting the matching jumper. The MC68882 is auto-detected and has no enable/disable jumper.
