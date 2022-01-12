


		THE A2630 DAUGHTERBOARD SPECIFICATION

			by Dave Haynie


	The A2630 is a basic asynchronous 68030 system (as described above)
running at 25MHz.  The A2630 supports up to 4 megabytes of 32 bit wide
memory on-board, similar in fashion to the A2620 memory.  The main
difference is that the A2630 on-board memory is always autoconfigured
memory; it cannot be relocated even with some PAL changes. 

	The A2630 does support 32 bit memory expansion, in the form of a
daughterboard which can contain a considerable amount of 32 bit memory. 
The daughterboard is specifically intended for the addition of a single
memory board to the A2630; it is not a general purpose 32 bit expansion bus
of any kind, and should not be expected to exist as-is on future 32 bit
Amiga system.  The daughterboard is connected via two 64 pin DIN
connectors, and a mechanical drawing of this connector is suppied in the
appendix. 

	The pinouts are as follows:


	   CN300				   CN301

 1	GND	 2	D0	 	 1	GND	 2	GND
 3	GND	 4	D1		 3	CPUCLK*	 4	CPUCLK
 5	GND	 6	D2		 5	VCC	 6	VCC
 7	GND	 8	D3		 7	A0	 8	DSACK0*
 9	GND	10	D4		 9	A1	10	DSACK1*
11	GND	12	D5		11	A2	12	STERM*
13	GND	14	D6		13	A3	14	CBACK*
15	GND	16	D7		15	A4	16	GND
17	GND	18	D8		17	A5	18	BERR*
19	GND	20	D9		19	A6	20	NORAM*
21	GND	22	D10		21	A7	22	GRESET*
23	GND	24	D11		23	A8	24	ECS*
25	GND	26	D12		25	A9	26	GND
27	GND	28	D13		27	A10	28	DBEN*
29	GND	30	D14		29	A11	30	AS*
31	GND	32	D15		31	A12	32	DS*
33	GND	34	D16		33	A13	34	R/W
35	GND	36	D17		35	A14	36	GND
37	GND	38	D18		37	A15	38	SIZ0
39	GND	40	D19		39	A16	40	SIZ1
41	GND	42	D20		41	A17	42	BGACK*
43	GND	44	D21		43	A18	44	GND
45	GND	46	D22		45	A19	46	FC0
47	GND	48	D23		47	A20	48	FC1
49	GND	50	D24		49	A21	50	FC2
51	GND	52	D25		51	A22	52	GND	
53	GND	54	D26		53	A23	54	CBREQ*
55	GND	56	D27		55	A24	56	EXTERN*
57	GND	58	D28		57	A25	58	IREFREQ*
59	GND	60	D29		59	VCC	60	VCC
61	GND	62	D30		61	A26	62	EXTSEL
63	GND	64	D31		63	GND	64	GND


NOTE: In the A2630 prototype, the CPUCLK* and EXTSEL pins were reversed.  All
      production units, however, have the correct pinout shown here.

The signals description follows (note that most of the signals are standard
68030 bus signals, which are more fully described in various Motorola 68030
secifications).  Unless otherwise specified, each signal supplied by the
daughterboard should be driven by an F-series or equivalent TTL output, and
each input should present no more than one F-series or equivalent AC or DC
load.  As usual, these are the guidelines we're writing the specifications
to; you ignore them at your own risk. 

POWER GROUP

	VCC		This is the +5V supply from the A2630.  This supply 
		has to travel a long way to get here; most daughterboards 
		will use a different supply (like from a disk drive power 
		cable) rather than the supplied +5V here.

	GND		This is the ground in common with the A2630's digital
		ground.  Grounding is very important for noise immunity!


MEMORY CYCLE GROUP

	Most of these signals are used in the basic definition and 
qualification of a memory cycle, and can generally change on a cycle by
cycle basis.  Some are provided by the 68030/A2630, some by the 
daughterboard memory logic.


	CPUCLK,CPUCLK*	These are the inverted and non-inverted versions of
		the clock signal used to drive the 68030, and perhaps the
		68882, on the A2630 board.  It is recommended that these
		be buffered very close to the edge connector of the daughter
		board; they are perhaps the most critical signals in the
		system.
		
	EXTSEL		This is an active-high input to the A2630 indicating
		that the daughterboard is responding to the current bus
		address.  This should be driven based purely on address
		(including the address space as specified by the function
		codes) and qualifiers such as BGACK*, NORAM*, BERR*, GRESET*,
		etc, as appropriate.  It should not include any AS* qualifier,
		and the maximum address to EXTSEL delay should be no longer
		than 10ns for reliable operation.  Asserting EXTSEL at the
		wrong time (eg, when you're trying to access on-board or 
		68000 resources) will cause the daughterboard to "overlay"
		the other resource.  This may actually be the desired effect,
		for things such as cache boards.
	
	ECS*		This is the 68030 "External Cycle Start" line,
		passed unbuffered.  Some DRAM refresh arbiters can make use
		of this line.  

	DBEN*		This is the 68030 "Data Buffer Enable" line, passed
		unbuffered.  It may be of use for driving the required data
		bus buffers, though as stated by Motorola, it will not be
		fast enough for zero wait state synchronous memory cycles.

	AS*		This is the 68030 "Address Strobe" line, passed
		unbuffered.  It is the one and only valid indicator of what
		constitutes a memory cycle.  Note that asserting EXTSEL 
		will disable the 68000 compatible address strobe that's
		normally created by the 68030 for offboard memory cycles.
		

	DS*		This is the 68030 "Data Strobe" line, passed 
		unbuffered.  It indicates valid data from the 68030 on a
		write, and the earliest that data may be placed on the
		data bus during a read.  

	R/W		This is the 68030 "Read/Write" line, passed 
		unbuffered.  It's high for a write, low for a read, just
		as you'd expect.

	BGACK*		This is the 68030 "Bus Grant Acknowledge" line, 
		which is asserted when an external device has mastered the
		A2630 bus.  While no DMA is possible to memory boards that
		sit outside of the Zorro II/68000 24 bit address space, 
		daughterboards must still qualify with BGACK* to assure 
		that an invalid address isn't supplied (since A24 is not
		driven by a DMA device).

	CBREQ*		This is the 68030 "Cache Burst REQuest" line, 
		passed unbuffered.  This is asserted by the 68030 to indicate
		that it's capable of a synchronous cache line burst.  


	CBACK*		This is the 68030 "Cache Burst ACKnowledge" line.
		This is asserted by the daughterboard in response to a CBREQ*
		from the 68030, as outlined by the Motorola documents.  This
		line should be driven by a tri-state or open collector/drain
		output, and left in the appropriate quiescent state when the
		daughterboard is not responding to the current address.

	IREFREQ*	This is a refresh request signal create by the 
		memory logic on the A2630, and it may optionally be used to
		by the refresh logic on the daughterboard.  The creation
		of this signal is a little weird; it's based on a timer 
		which runs off the 7MHz A2000 clock, and sampled on the
		rising edge of the CPUCLK.  It's recommended that the refresh
		"go-ahead" signal on any daughterboard DRAM circuitry sample
		this on CPUCLK; it's guaranteed to stay valid for at least
		one 25MHz clock period, and may actually stay valid for
		several.

	EXTERN*		This is an output from the A2630, used to indicate
		that an "external" device is responding to an address.  There
		are two external devices; the 68882 and the daughterboard.
		Asserting EXTSEL will in turn result in EXTERN* being driven
		by the A2630 logic.  Most daughterboard circuits will not
		use this line.


SYSTEM GROUP

	These signals are system configuration, startup, or error signals,
and will rarely change.  They may have an effect on what's done during a
memory cycle.

	NORAM*
			This is the direct output of the NORAM* jumper
		(J303) on the A2630.  It is passed unbuffered.

	BERR*		This is the 68030 "Bus Error" line, passed
		unbuffered.  This is used by the A2000 system to indicate
		a bus collision of some kind, by the A2630 to generate
		F-line exceptions when a math chip isn't present, and by
		the MMU to indicate bus faults.  The current memory cycle
		is aborted when BERR* is asserted.

	GRESET*		This is a buffered version of the "Global" reset
		line, used on the A2630 to indicate a full system reset.
		Full system reset occurs on either a power-up or a keyboard-
		generated reset.  The RESET instruction will not assert.
		GRESET*.


BUS SIZING GROUP

	These signals, actually an integral part of the memory cycle logic
of any design, are used to match the desired bus size to the actual bus
size.  I don't anticipate any daughterboards with anything other than 32 
bit ports, but I suppose it's possible.

	SIZ0,SIZ1	These are the bus sizing indicators from the 68030,
		passed unbuffered.  For a memory location to be cachable,
		it must always read it's full port size (eg, probably 32
		bits), regardless of the state of the sizing bits.  For a
		write, the size bits are important.  This is explained in
		detail in Motorola's 68030 documentation.

	A0,A1		These are the lowest two address lines, which are
		actually more part of the bus sizing mechanism than real
		address lines when you're talking about a 32 bit port.  As
		with the SIZ bits, these are explained fully in the 68030
		manual.

	DSACK0*,DSACK1*	These are the lines used to terminate a 68030 
		asynchronous cycle; they go directly to the 68030.  These
		serve to encode the size of the memory port you're dealing
		with; the normal 32 bit port will assert both of them.  The
		minimum asynchronous cycle is three CPUCLKs, or 120ns at
		the A2630's standard 25MHz.  The 68030 will sample the DSACK
		lines on the falling edge of the CPUCLK and latch the data on
		a read on the next falling edge.  The nice thing about the
		asynchronous mode is that you don't have too much worry about
		setups and holds -- if both DSACKs miss the sampling edge, 
		they'll be caught safely on the next sampling edge, just like
		on the 68000.  Also, the data on a read need only be held 
		until DS* is negated.  These lines should be driven by open 
		collector/drain or tristate drivers, and left in the quiescent
		state when the daughterboard isn't being selected.

	STERM*		This is the line used to terminate a 68030
		synchronous cycle; it goes directly to the 68030.  All 
		synchronous cycles are by convention 32 bits wide.  The
		minimum synchronous cycle is two CPUCLKs, or 80ns at the
		A2630's standard 25MHz.  The 68030 will sample the STERM
		line on the rising edge of the CPUCLK and latch the data on
		the following falling edge.  The nice thing about the 
		synchronous mode is speed -- the basic cycle can go 1 clock
		faster, and it can also exploit data cache line burst loads.
		However, all signals must be guaranteed stable at their
		sampling points within the Motorola specified setup and hold
		times, or the 68030 could see some metastability and end up
		behaving unexpectedly (eg, you crash or, even worse, mungle
		some data).  This line should be driven by an open collector,
		open drain, or tristate output, and it should be left in the
		appropriate quiescent state when the daughterboard isn't
		being selected.


BUS GROUP

	These are the basic 68030 system buses.

	FC(2:0)		These are the 68030 function code outputs, passed
		unbuffered.  Any memory system on a daughterboard must make
		sure it ignores any CPU space accesses (FC2:0 = 111) or a
		collision between daughterboard memory and the CPU may
		take place.  It's possible to hook up additional 68030
		style coprocessors to the daughterboard bus, bus full bus 
		decoding is absolutely required.  The A2630 uses the two
		standard coprocessors, the MMU (number 0) and the FPU
		(number 1).

	A(26:2)		The unbuffered 68030 address bus.  As mentioned,
		this MUST be buffered, and it's recommended that the buffers
		live as close to the daughterboard connector as possible.
		Daughterboard memory should not be placed in the $0000000
		through $0ffffff range, as that's reserved for main Amiga
		resources (of course including A2630 on-board memory).

	D(31:0)		The unbuffered 68030 data bus.  As mentioned, this
		MUST be buffered and it's recommended that the buffers
		live as close to the daughterboard connector as possible.


