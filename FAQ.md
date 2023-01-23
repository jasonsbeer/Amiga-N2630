# FAQs

### I already have a Zorro 2 memory card. Do I have to install Zorro 2 memory?
The N2630 must have on-board memory to maximize performance of the Motorolla 68030 processor. All on board memory, even in the Zorro 2 space, is 32 bits wide. In practice, you *could* omit the Zorro 2 memory if you install Zorro 3 memory. However, Zorro 2 RAM on Zorro 2 cards will be 16 bits wide accessed at 7MHz, severely restricting the MC68030 during memory access to those spaces. Alternatively, you may place a jumper at J405 to limit the N2630 Zorro 2 RAM to 4MB. This will leave 4MB of AUTOCONFIG space available for memory on Zorro 2 cards.

### My software, [fill in then blank], does not work with the N2630.
It is likely, especially for games, that some will fail when running in 68030 mode. To regain compatability, you should start your Amiga in 68000 mode. See [68000 mode](/README.md#68000-mode) on the main page.

### What are the AUTOCONFIG details?
The N2630 identifies as two seperate AUTOCONFIG devices: a Zorro 2 memory card and a Zorro 3 memory card. The manufacturer ID is listed as "600" with the Zorro 2 device as product number 0 and the Zorro 3 device as product 1. Both reflect 2630 as the serial number.
<img src="/Images/autoconfig.jpg"  width="600">

