# FAQs

### I already have a Zorro 2 memory card. Can I install less than 8 megabytes and use my existing card? 
For maximum performance, it is advisable to install the maximum amount of Zorro 2 RAM on the N2630 card. Due to the design of the N2630 memory interface, the Zorro 2 memory on the N2630 is accessed as 32 bits wide by the 68030. This will maximize performance of the 68030. Zorro 2 RAM on other cards will be 16 bits wide, thus reducing throughput of the 68030. 

In the event you have a card that only DMA's to itself, such as the GVP Impact Series II, you may place a jumper at J405 to limit the N2630 Zorro 2 RAM to 4MBs. This will leave 4MBs of space for the RAM on the DMA device.

### My software, [fill in then blank], does not work with the N2630.
It is likely, especially for games, that some will fail when running in 68030 mode. To regain compatability, you should start your Amiga in 68000 mode. See [68000 mode](/README.md#68000-mode) on the main page. It is common that software, games especially, use routines where timing is critical to gain the greatest performance from stock Amigas. This means the timings of the 68030 may break certain applications
