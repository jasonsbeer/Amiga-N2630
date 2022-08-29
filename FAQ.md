# FAQs

### I already have a Zorro 2 memory card. Can I install less than 8 megabytes and use my existing card? Or no Zorro 2 memory at all?
For maximum performance, it is advisable to install the maximum amount of Zorro 2 RAM on the N2630 card. Due to the design of the N2630 memory interface, the Zorro 2 memory on the N2630 is accessed as 32 bits wide by the 68030. This will maximize performance of the 68030. Zorro 2 RAM on other cards will be only 16 bits wide, thus reducing throughput of the 68030. If you insist on not installing any Zorro 2 RAM, you may do so. Be sure to place a jumper at J303 to disable the Zorro 2 AUTOCONFIG.

In the event you have a card that only DMA's to itself, such as the GVP Impact Series II, you may place a jumper at J405 to limit the N2630 Zorro 2 RAM to 4MBs. This will leave 4MBs of space for the RAM on the DMA device.

### Blah blah blah?
Bleh bleh bleh.
