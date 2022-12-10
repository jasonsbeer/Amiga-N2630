# Assembly Notes, BOM, and Ramblings

IMPORTANT INFORMATION. It is highly recommended you read this entire page before committing to assemble the N2630.

**Disclaimer:** This project is free and open source. It is a complex project and should only be undertaken by individuals experienced in SMD assembly techniques. No warranty or guarantee is offered that it will work for your particular situation. You assume all risk should you choose to build it.

## Bill of Materials  

The BOM is found [here](/N2630-REV30-BOM.csv).

Most components to assemble the N2630 are available at any good electronic supply house. The MC68030 and MC68882 will need to be obtained through a retailer that deals in legacy Motorola devices. At the time of writing this, you should expect to pay US$30 - $50 each. DO NOT buy components where you get five chips for $20. These are almost always counterfeit or remarked chips. Save yourself a lot of misery and pay for the real ones.

Most compents in the BOM are general purpose passive and logic parts with many compatable alternatives. It is difficult to keep a list of part numbers that remains valid, even for a short period of time. Because of this, only the part type, value, and footprint is listed. For some parts, to avoid ambiguity, I have listed Digikey part numbers to help you understand what is needed. You can cross reference the Digikey part number should it ever go out of stock.

128-PGA sockets are very difficult to find, and very expensive, if you do find them in stock. A good alternative is to use machine pin strips to make your own socket. It is not pretty, but it works well.

**NOTE:** 

1) Be sure to select 166MHz SDRAM. Slower SDRAM may not work at 50MHz.
2) Sockets are NOT listed in the BOM. I prefer 3M sockets for my projects.
3) Components not listed on the BOM are reserved for future use and do not need to be populated.

## Programming the CPLDs
The three CPLDs (U600, U601, and U602) must be programmed before the N2630 will function. Each CPLD has a dedicated programming port, CN600, CN601, and CN602. The best way to program these is to plug the card into the Amiga, power it on, and program it while in circuit with power coming from the Amiga 2000. The JED files can be found [here](/Logic/JED). Make certain to program each CPLD with the matching JED file for your hardware revision. 

Discussion of how to program CPLDs is out of the scope of this document, but many resources are available on the internet. I have been using a Raspberry Pi 2 with xc3sprog. Xilinx programming dongles are also available.

## Programming the ROMs
Most cheap EPROM programmers will handle the 27C256 EPROMs of the N2630. A popular one is the TL866II, but there are other options. There are a lot of these in the community. Someone may be able to assist if you do not wish to purchase a programmer. The EPROMs can be programmed independently of the N2630.

## Troubleshooting
1) Double check the jumpers. It is critical the jumpers be set correctly for proper and reliable function.
2) Check for solder bridges or bad solder joints.
3) Disable the Zorro 2 RAM, Zorro 3 RAM, and the IDE port. The Amiga 2000 will boot without these and it may help narrow down where the issue lies.

## Ramblings
The Zorro 3 RAM, IDE Port, and MC68882 are all optional. If you choose not to install the Zorro 3 RAM and/or IDE port, you can omit the associated logic and passives. If you do this, be sure to disable these by properly setting the matching jumper. The MC68882 is auto-detected and has no enable/disable jumper.