# FAQs

### Must I install Zorro 3 RAM?
No. If you leave the Zorro 3 SDRAM banks empty, place a jumper at J405 to disable the Zorro 3 AUTOCONFIG.

### I already have a Zorro 2 memory card. Do I have to install Zorro 2 memory?
For maximum performance, you must install Zorro 2 RAM on the N2630 card. Due to the design of the N2630 memory interface, the Zorro 2 memory on the N2630 is accessed as 32 bits wide by the 68030. This will maximize performance of the 68030. Zorro 2 RAM on other cards will be 16 bits wide accessed at 7MHz, severely reducing throughput of the 68030. If necessary, you may place a jumper at J405 to limit the N2630 Zorro 2 RAM to 4MB.

### My software, [fill in then blank], does not work with the N2630.
It is likely, especially for games, that some will fail when running in 68030 mode. To regain compatability, you should start your Amiga in 68000 mode. See [68000 mode](/README.md#68000-mode) on the main page.
