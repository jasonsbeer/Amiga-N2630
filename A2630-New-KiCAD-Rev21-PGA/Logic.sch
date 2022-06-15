EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 7 8
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74xx:74LS244_Split U606
U 1 1 634F09DD
P 3225 1950
F 0 "U606" H 3225 2267 50  0000 C CNN
F 1 "74HCT244" H 3225 2176 50  0000 C CNN
F 2 "Package_SO:SOIC-20W_7.5x12.8mm_P1.27mm" H 3225 1950 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 3225 1950 50  0001 C CNN
	1    3225 1950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244_Split U606
U 2 1 634F290D
P 3250 2650
F 0 "U606" H 3250 2967 50  0000 C CNN
F 1 "74HCT244" H 3250 2876 50  0000 C CNN
F 2 "Package_SO:SOIC-20W_7.5x12.8mm_P1.27mm" H 3250 2650 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 3250 2650 50  0001 C CNN
	2    3250 2650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244_Split U606
U 3 1 634F3A36
P 3250 3200
F 0 "U606" H 3250 3517 50  0000 C CNN
F 1 "74HCT244" H 3250 3426 50  0000 C CNN
F 2 "Package_SO:SOIC-20W_7.5x12.8mm_P1.27mm" H 3250 3200 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 3250 3200 50  0001 C CNN
	3    3250 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244_Split U606
U 4 1 634F4A87
P 3275 3725
F 0 "U606" H 3275 4042 50  0000 C CNN
F 1 "74HCT244" H 3275 3951 50  0000 C CNN
F 2 "Package_SO:SOIC-20W_7.5x12.8mm_P1.27mm" H 3275 3725 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 3275 3725 50  0001 C CNN
	4    3275 3725
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS244_Split U606
U 9 1 634F66F6
P 12250 6925
F 0 "U606" V 12375 6825 50  0000 L CNN
F 1 "74HCT244" V 12150 6750 50  0000 L CNN
F 2 "Package_SO:SOIC-20W_7.5x12.8mm_P1.27mm" H 12250 6925 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls241.pdf" H 12250 6925 50  0001 C CNN
	9    12250 6925
	1    0    0    -1  
$EndComp
Wire Wire Line
	3225 2200 1825 2200
Wire Wire Line
	2925 1950 1825 1950
Wire Wire Line
	2950 3200 1825 3200
Wire Wire Line
	2950 2650 1825 2650
Wire Wire Line
	2975 3725 1850 3725
Text GLabel 1825 1950 0    51   Input ~ 0
_IVMA
Text GLabel 1825 2200 0    51   Input ~ 0
TRISTATE
Text GLabel 1825 2650 0    51   Input ~ 0
FC0
Text GLabel 1825 3200 0    51   Input ~ 0
FC1
Text GLabel 1850 3725 0    51   Input ~ 0
FC2
Wire Wire Line
	3525 1950 4625 1950
Wire Wire Line
	3550 2650 4625 2650
Wire Wire Line
	3550 3200 4625 3200
Wire Wire Line
	3575 3725 4625 3725
Text GLabel 4625 1950 2    51   Output ~ 0
_VMA
Text GLabel 4625 2650 2    51   Output ~ 0
AFC0
Text GLabel 4625 3200 2    51   Output ~ 0
AFC1
Text GLabel 4625 3725 2    51   Output ~ 0
AFC2
$Comp
L 74xx:74LS74 U503
U 1 1 63568717
P 6975 4850
F 0 "U503" H 7125 5175 50  0000 C CNN
F 1 "74HCT74" H 7175 5100 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 6975 4850 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 6975 4850 50  0001 C CNN
	1    6975 4850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS74 U503
U 2 1 6356991E
P 8275 4850
F 0 "U503" H 8425 5175 50  0000 C CNN
F 1 "74HCT74" H 8475 5100 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 8275 4850 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 8275 4850 50  0001 C CNN
	2    8275 4850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS74 U503
U 3 1 6356B308
P 13225 6925
F 0 "U503" V 13325 6800 50  0000 L CNN
F 1 "74HCT74" V 13100 6775 50  0000 L CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 13225 6925 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 13225 6925 50  0001 C CNN
	3    13225 6925
	1    0    0    -1  
$EndComp
Text GLabel 6125 3975 0    51   Input ~ 0
_GRESET
Text GLabel 6125 4350 0    51   Input ~ 0
_MEMLOCK
Text GLabel 6125 4750 0    51   Input ~ 0
_ASDELAY
Text GLabel 6125 4850 0    51   Input ~ 0
SCLK
Wire Wire Line
	8275 4550 8275 3975
Wire Wire Line
	8275 3975 6125 3975
Wire Wire Line
	6975 4550 6975 4350
Wire Wire Line
	6975 4350 6125 4350
Wire Wire Line
	6675 4850 6425 4850
Wire Wire Line
	6675 4750 6125 4750
NoConn ~ 7275 4950
NoConn ~ 8575 4950
Wire Wire Line
	7275 4750 7475 4750
Wire Wire Line
	6975 5150 6975 5300
Wire Wire Line
	6975 5300 7500 5300
Wire Wire Line
	7500 5300 7500 5075
Wire Wire Line
	8275 5150 8275 5300
Wire Wire Line
	8275 5300 8825 5300
Wire Wire Line
	8825 5300 8825 5075
$Comp
L power:+5V #PWR0143
U 1 1 6357ECC4
P 8825 5075
F 0 "#PWR0143" H 8825 4925 50  0001 C CNN
F 1 "+5V" H 8840 5248 50  0000 C CNN
F 2 "" H 8825 5075 50  0001 C CNN
F 3 "" H 8825 5075 50  0001 C CNN
	1    8825 5075
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0144
U 1 1 6357ED6E
P 7500 5075
F 0 "#PWR0144" H 7500 4925 50  0001 C CNN
F 1 "+5V" H 7515 5248 50  0000 C CNN
F 2 "" H 7500 5075 50  0001 C CNN
F 3 "" H 7500 5075 50  0001 C CNN
	1    7500 5075
	1    0    0    -1  
$EndComp
Wire Wire Line
	8575 4750 8875 4750
Wire Wire Line
	7975 4850 7800 4850
Wire Wire Line
	7800 4850 7800 5425
Wire Wire Line
	7800 5425 6425 5425
Wire Wire Line
	6425 5425 6425 4850
Connection ~ 6425 4850
Wire Wire Line
	6425 4850 6125 4850
Wire Wire Line
	7975 4750 7900 4750
$Comp
L 74xx:74LS174 U303
U 1 1 635CAE10
P 3125 7975
F 0 "U303" H 3250 8600 50  0000 C CNN
F 1 "74HCT174" H 3325 8525 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 3125 7975 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS174" H 3125 7975 50  0001 C CNN
	1    3125 7975
	1    0    0    -1  
$EndComp
Wire Wire Line
	2625 7575 2475 7575
Wire Wire Line
	2625 7675 2475 7675
Wire Wire Line
	2625 7775 2475 7775
Wire Wire Line
	2625 7875 2475 7875
Wire Wire Line
	2625 7975 2475 7975
Wire Wire Line
	2625 8075 2475 8075
Wire Wire Line
	3625 7575 4250 7575
Wire Wire Line
	3625 7675 4250 7675
Wire Wire Line
	3625 7875 4250 7875
Wire Wire Line
	3625 7975 4250 7975
Wire Wire Line
	3625 8075 4250 8075
Entry Wire Line
	2475 7575 2375 7475
Entry Wire Line
	2475 7675 2375 7575
Entry Wire Line
	2475 7775 2375 7675
Entry Wire Line
	2475 7975 2375 7875
Entry Wire Line
	2475 8075 2375 7975
Text GLabel 2025 6850 0    51   Input ~ 0
D[31..0]
Entry Bus Bus
	2275 6850 2375 6950
Text Label 2475 7575 0    51   ~ 0
D16
Text Label 2475 7675 0    51   ~ 0
D17
Text Label 2475 7775 0    51   ~ 0
D18
Text Label 2475 7975 0    51   ~ 0
D19
Text Label 2475 8075 0    51   ~ 0
D20
Wire Wire Line
	2475 7875 2475 7825
Wire Wire Line
	2475 7825 2075 7825
Wire Wire Line
	2075 7825 2075 7700
$Comp
L power:+5V #PWR0145
U 1 1 635DF0C9
P 2075 7700
F 0 "#PWR0145" H 2075 7550 50  0001 C CNN
F 1 "+5V" H 2090 7873 50  0000 C CNN
F 2 "" H 2075 7700 50  0001 C CNN
F 3 "" H 2075 7700 50  0001 C CNN
	1    2075 7700
	1    0    0    -1  
$EndComp
Text GLabel 4250 8075 2    51   Output ~ 0
68KMODE
Text GLabel 4250 7975 2    51   Output ~ 0
JMODE
$Comp
L power:+5V #PWR0146
U 1 1 63609F5E
P 3125 7275
F 0 "#PWR0146" H 3125 7125 50  0001 C CNN
F 1 "+5V" H 3140 7448 50  0000 C CNN
F 2 "" H 3125 7275 50  0001 C CNN
F 3 "" H 3125 7275 50  0001 C CNN
	1    3125 7275
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0149
U 1 1 6360ABD4
P 3125 8775
F 0 "#PWR0149" H 3125 8525 50  0001 C CNN
F 1 "GND" H 3130 8602 50  0000 C CNN
F 2 "" H 3125 8775 50  0001 C CNN
F 3 "" H 3125 8775 50  0001 C CNN
	1    3125 8775
	1    0    0    -1  
$EndComp
Wire Wire Line
	2625 8275 2075 8275
Wire Wire Line
	2625 8475 2075 8475
Text GLabel 2075 8475 0    51   Input ~ 0
_REGRESET
$Comp
L 74xx:74LS74 U502
U 2 1 61F06783
P 7175 2400
F 0 "U502" H 7325 2725 50  0000 C CNN
F 1 "74HCT74" H 7375 2650 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 7175 2400 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 7175 2400 50  0001 C CNN
	2    7175 2400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS74 U502
U 1 1 61F07A23
P 8625 2400
F 0 "U502" H 8775 2725 50  0000 C CNN
F 1 "74HCT74" H 8825 2650 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 8625 2400 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 8625 2400 50  0001 C CNN
	1    8625 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	8625 2100 8625 1825
Wire Wire Line
	8625 1825 7175 1825
Wire Wire Line
	7175 2100 7175 1825
Connection ~ 7175 1825
Wire Wire Line
	7175 1825 6075 1825
Text GLabel 6075 1825 0    50   Input ~ 0
BGDIS
NoConn ~ 7475 2500
Wire Wire Line
	7475 2300 8200 2300
Wire Wire Line
	8325 2400 8025 2400
Wire Wire Line
	8025 2400 8025 3000
Wire Wire Line
	8025 3000 6500 3000
Wire Wire Line
	6875 2400 6500 2400
Wire Wire Line
	6500 2400 6500 3000
Connection ~ 6500 3000
Wire Wire Line
	6500 3000 6075 3000
Text GLabel 6075 3000 0    50   Input ~ 0
7M
Wire Wire Line
	7175 2700 7175 2900
Wire Wire Line
	7175 2900 7675 2900
Wire Wire Line
	7675 2900 7675 2650
$Comp
L power:+5V #PWR0150
U 1 1 61F175E8
P 7675 2650
F 0 "#PWR0150" H 7675 2500 50  0001 C CNN
F 1 "+5V" H 7690 2823 50  0000 C CNN
F 2 "" H 7675 2650 50  0001 C CNN
F 3 "" H 7675 2650 50  0001 C CNN
	1    7675 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	6875 2300 6075 2300
Text GLabel 6075 2300 0    50   Input ~ 0
BG
NoConn ~ 8925 2300
Wire Wire Line
	8925 2500 9175 2500
$Comp
L 74xx:74LS05 U?
U 1 1 61F2B4A6
P 9475 2500
AR Path="/61DF74A0/61F2B4A6" Ref="U?"  Part="4" 
AR Path="/634ECC15/61F2B4A6" Ref="U300"  Part="1" 
F 0 "U300" H 9475 2817 50  0000 C CNN
F 1 "74HCT05" H 9475 2726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 9475 2500 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS05" H 9475 2500 50  0001 C CNN
	1    9475 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9775 2500 10325 2500
Text GLabel 10325 2500 2    50   Output ~ 0
_ABG
Wire Wire Line
	8200 2300 8200 2900
Wire Wire Line
	8200 2900 8625 2900
Wire Wire Line
	8625 2900 8625 2700
Connection ~ 8200 2300
Wire Wire Line
	8200 2300 8325 2300
$Comp
L 74xx:74LS05 U?
U 7 1 61F4989C
P 11325 6925
AR Path="/61DF74A0/61F4989C" Ref="U?"  Part="4" 
AR Path="/634ECC15/61F4989C" Ref="U300"  Part="7" 
F 0 "U300" V 11425 6925 50  0000 C CNN
F 1 "74HCT05" V 11225 6925 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 11325 6925 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS05" H 11325 6925 50  0001 C CNN
	7    11325 6925
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U?
U 2 1 61F6E714
P 6675 6950
AR Path="/61DF74A0/61F6E714" Ref="U?"  Part="4" 
AR Path="/634ECC15/61F6E714" Ref="U300"  Part="2" 
AR Path="/6209FB19/61F6E714" Ref="U?"  Part="3" 
F 0 "U300" H 6675 7267 50  0000 C CNN
F 1 "74HCT05" H 6675 7176 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 6675 6950 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS05" H 6675 6950 50  0001 C CNN
	2    6675 6950
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 61F737D0
P 6675 7350
AR Path="/61DF74A0/61F737D0" Ref="U?"  Part="3" 
AR Path="/6209FB19/61F737D0" Ref="U?"  Part="2" 
AR Path="/634ECC15/61F737D0" Ref="U307"  Part="2" 
F 0 "U307" H 6675 7033 50  0000 C CNN
F 1 "74HCT04" H 6675 7124 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 6675 7350 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS04" H 6675 7350 50  0001 C CNN
	2    6675 7350
	1    0    0    -1  
$EndComp
Wire Wire Line
	6375 6950 6150 6950
Wire Wire Line
	6375 7350 6150 7350
Text GLabel 5950 6950 0    50   Input ~ 0
_BOSS
Wire Wire Line
	6150 6950 6150 7350
Connection ~ 6150 6950
Wire Wire Line
	6150 6950 5950 6950
Wire Wire Line
	6975 6950 7625 6950
Wire Wire Line
	6975 7350 8525 7350
Text GLabel 8525 7350 2    50   Output ~ 0
_GRESET
Text GLabel 8525 6950 2    50   Output ~ 0
_CPURESET
$Comp
L Device:R R500
U 1 1 61F83B73
P 7625 6800
F 0 "R500" H 7695 6846 50  0000 L CNN
F 1 "1K" H 7695 6755 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 7555 6800 50  0001 C CNN
F 3 "~" H 7625 6800 50  0001 C CNN
	1    7625 6800
	1    0    0    -1  
$EndComp
Connection ~ 7625 6950
Wire Wire Line
	7625 6950 8525 6950
$Comp
L power:+5V #PWR0151
U 1 1 61F847B3
P 7625 6650
F 0 "#PWR0151" H 7625 6500 50  0001 C CNN
F 1 "+5V" H 7640 6823 50  0000 C CNN
F 2 "" H 7625 6650 50  0001 C CNN
F 3 "" H 7625 6650 50  0001 C CNN
	1    7625 6650
	1    0    0    -1  
$EndComp
Text GLabel 12775 2275 2    50   Input ~ 0
_VPA
Wire Wire Line
	12775 2275 12475 2275
$Comp
L Device:R R501
U 1 1 61F93D08
P 12475 2125
F 0 "R501" H 12545 2171 50  0000 L CNN
F 1 "1K" H 12545 2080 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 12405 2125 50  0001 C CNN
F 3 "~" H 12475 2125 50  0001 C CNN
	1    12475 2125
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0152
U 1 1 61F941E9
P 12475 1975
F 0 "#PWR0152" H 12475 1825 50  0001 C CNN
F 1 "+5V" H 12490 2148 50  0000 C CNN
F 2 "" H 12475 1975 50  0001 C CNN
F 3 "" H 12475 1975 50  0001 C CNN
	1    12475 1975
	1    0    0    -1  
$EndComp
Text GLabel 12775 2950 2    50   Input ~ 0
_DTACK
Wire Wire Line
	12775 2950 12475 2950
$Comp
L Device:R R502
U 1 1 61FA2CD0
P 12475 2800
F 0 "R502" H 12545 2846 50  0000 L CNN
F 1 "1K" H 12545 2755 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 12405 2800 50  0001 C CNN
F 3 "~" H 12475 2800 50  0001 C CNN
	1    12475 2800
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0153
U 1 1 61FA2CD6
P 12475 2650
F 0 "#PWR0153" H 12475 2500 50  0001 C CNN
F 1 "+5V" H 12490 2823 50  0000 C CNN
F 2 "" H 12475 2650 50  0001 C CNN
F 3 "" H 12475 2650 50  0001 C CNN
	1    12475 2650
	1    0    0    -1  
$EndComp
Text Notes 8125 3775 2    118  ~ 0
STATE MACHINE
Wire Bus Line
	2025 6850 2275 6850
Text GLabel 2075 8275 0    50   Input ~ 0
ROMCLK
Text GLabel 4250 7675 2    50   Output ~ 0
PHANTOMHI
Text GLabel 4250 7575 2    50   Output ~ 0
PHANTOMLO
Text GLabel 4250 7875 2    50   Output ~ 0
RSTENB
$Comp
L Device:C C300
U 1 1 6353B771
P 11700 6900
F 0 "C300" H 11815 6946 50  0000 L CNN
F 1 "0.22" H 11815 6855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 11738 6750 50  0001 C CNN
F 3 "~" H 11700 6900 50  0001 C CNN
	1    11700 6900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C606
U 1 1 6353D849
P 12625 6900
F 0 "C606" H 12740 6946 50  0000 L CNN
F 1 "0.22" H 12740 6855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 12663 6750 50  0001 C CNN
F 3 "~" H 12625 6900 50  0001 C CNN
	1    12625 6900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C503
U 1 1 6353FA52
P 13625 6900
F 0 "C503" H 13740 6946 50  0000 L CNN
F 1 "0.22" H 13740 6855 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 13663 6750 50  0001 C CNN
F 3 "~" H 13625 6900 50  0001 C CNN
	1    13625 6900
	1    0    0    -1  
$EndComp
Wire Wire Line
	13625 6750 13625 6425
Wire Wire Line
	13625 6425 13225 6425
Connection ~ 12250 6425
Wire Wire Line
	12250 6425 11700 6425
Wire Wire Line
	11325 7425 11700 7425
Wire Wire Line
	13625 7425 13625 7050
Wire Wire Line
	13225 7325 13225 7425
Connection ~ 13225 7425
Wire Wire Line
	13225 7425 13625 7425
Wire Wire Line
	13225 6525 13225 6425
Connection ~ 13225 6425
Wire Wire Line
	13225 6425 12625 6425
$Comp
L power:+5V #PWR0103
U 1 1 635487F0
P 13625 6425
F 0 "#PWR0103" H 13625 6275 50  0001 C CNN
F 1 "+5V" H 13640 6598 50  0000 C CNN
F 2 "" H 13625 6425 50  0001 C CNN
F 3 "" H 13625 6425 50  0001 C CNN
	1    13625 6425
	1    0    0    -1  
$EndComp
Connection ~ 13625 6425
$Comp
L power:GND #PWR0183
U 1 1 63548D8D
P 13625 7425
F 0 "#PWR0183" H 13625 7175 50  0001 C CNN
F 1 "GND" H 13630 7252 50  0000 C CNN
F 2 "" H 13625 7425 50  0001 C CNN
F 3 "" H 13625 7425 50  0001 C CNN
	1    13625 7425
	1    0    0    -1  
$EndComp
Connection ~ 13625 7425
Wire Wire Line
	12625 6750 12625 6425
Connection ~ 12625 6425
Wire Wire Line
	12625 6425 12250 6425
Wire Wire Line
	12625 7050 12625 7425
Connection ~ 12625 7425
Wire Wire Line
	12625 7425 13225 7425
Connection ~ 12250 7425
Wire Wire Line
	12250 7425 12625 7425
Wire Wire Line
	11700 6750 11700 6425
Connection ~ 11700 6425
Wire Wire Line
	11700 6425 11325 6425
Wire Wire Line
	11700 7050 11700 7425
Connection ~ 11700 7425
Wire Wire Line
	11700 7425 12250 7425
Wire Notes Line
	10650 3225 10650 1250
Wire Notes Line
	10650 1250 5575 1250
Wire Notes Line
	5575 1250 5575 3225
Wire Notes Line
	5575 3225 10650 3225
Text Notes 6625 1600 0    118  ~ 0
BUS GRANT ENABLE/DISABLE
Wire Notes Line
	5550 3525 9500 3525
Wire Notes Line
	9500 3525 9500 5725
Wire Notes Line
	9500 5725 5550 5725
Wire Notes Line
	5550 5725 5550 3525
Text GLabel 8875 4750 2    51   Output ~ 0
_S7MDIS
Text GLabel 6100 4175 0    51   Input ~ 0
_S7MDISD
Wire Wire Line
	6100 4175 7900 4175
Wire Wire Line
	7900 4175 7900 4750
Text GLabel 8875 4300 2    51   Output ~ 0
_ASEN
Wire Wire Line
	8875 4300 7475 4300
Wire Wire Line
	7475 4300 7475 4750
NoConn ~ 3625 7775
Wire Notes Line
	1300 6375 1300 9075
Wire Notes Line
	1300 9075 4900 9075
Wire Notes Line
	4900 9075 4900 6375
Wire Notes Line
	4900 6375 1300 6375
Text Notes 4400 6775 2    118  ~ 0
STARTUP ROM CONFIG
Wire Notes Line
	9150 7800 9150 5975
Wire Notes Line
	9150 5975 5525 5975
Wire Notes Line
	5525 5975 5525 7800
Wire Notes Line
	5525 7800 9150 7800
Text Notes 8100 6325 2    118  ~ 0
RESET CONFIGURE
$Comp
L 74xx:74LS74 U507
U 1 1 622DFEF1
P 2900 5375
F 0 "U507" H 3050 5700 50  0000 C CNN
F 1 "74HCT74" H 3100 5625 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 2900 5375 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 2900 5375 50  0001 C CNN
	1    2900 5375
	1    0    0    -1  
$EndComp
Wire Wire Line
	2900 5075 2900 4950
$Comp
L power:+5V #PWR01
U 1 1 622EA597
P 2900 4950
F 0 "#PWR01" H 2900 4800 50  0001 C CNN
F 1 "+5V" H 2915 5123 50  0000 C CNN
F 2 "" H 2900 4950 50  0001 C CNN
F 3 "" H 2900 4950 50  0001 C CNN
	1    2900 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	2900 5675 2900 5800
Wire Wire Line
	2900 5800 1925 5800
Text GLabel 1925 5800 0    51   Input ~ 0
_DSACKDIS
NoConn ~ 3200 5475
Wire Wire Line
	3200 5275 3575 5275
Wire Wire Line
	2600 5275 1925 5275
Wire Wire Line
	2600 5375 1925 5375
Text GLabel 1925 5275 0    51   Input ~ 0
_DSACKEN
Text GLabel 1925 5375 0    51   Input ~ 0
DSCLK
$Comp
L 74xx:74LS05 U?
U 5 1 622FFD89
P 3875 5275
AR Path="/61DF74A0/622FFD89" Ref="U?"  Part="4" 
AR Path="/634ECC15/622FFD89" Ref="U300"  Part="5" 
AR Path="/6209FB19/622FFD89" Ref="U?"  Part="5" 
F 0 "U300" H 3875 5592 50  0000 C CNN
F 1 "74HCT05" H 3875 5501 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 3875 5275 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS05" H 3875 5275 50  0001 C CNN
	5    3875 5275
	1    0    0    -1  
$EndComp
Wire Wire Line
	4175 5275 4300 5275
Text GLabel 4300 5275 2    51   Output ~ 0
_DSACK1
Wire Notes Line
	1325 4375 1325 5950
Wire Notes Line
	1325 5950 4775 5950
Wire Notes Line
	4775 5950 4775 4350
Wire Notes Line
	4775 4350 1325 4350
Text Notes 1850 4625 0    118  ~ 0
DSACK FOR 16 BIT CYCLES
Text GLabel 12125 3225 2    51   Input ~ 0
EXTSEL
Wire Wire Line
	12125 3225 11825 3225
$Comp
L Device:R R300
U 1 1 62326104
P 11825 3375
F 0 "R300" H 11895 3421 50  0000 L CNN
F 1 "1K" H 11895 3330 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 11755 3375 50  0001 C CNN
F 3 "~" H 11825 3375 50  0001 C CNN
	1    11825 3375
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 6232AD74
P 11825 3525
F 0 "#PWR04" H 11825 3275 50  0001 C CNN
F 1 "GND" H 11830 3352 50  0000 C CNN
F 2 "" H 11825 3525 50  0001 C CNN
F 3 "" H 11825 3525 50  0001 C CNN
	1    11825 3525
	1    0    0    -1  
$EndComp
Text GLabel 11675 2250 2    50   Input ~ 0
_MEMSEL
Wire Wire Line
	11675 2250 11375 2250
$Comp
L Device:R R301
U 1 1 62330055
P 11375 2100
F 0 "R301" H 11445 2146 50  0000 L CNN
F 1 "470" H 11445 2055 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 11305 2100 50  0001 C CNN
F 3 "~" H 11375 2100 50  0001 C CNN
	1    11375 2100
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR03
U 1 1 6233005B
P 11375 1950
F 0 "#PWR03" H 11375 1800 50  0001 C CNN
F 1 "+5V" H 11390 2123 50  0000 C CNN
F 2 "" H 11375 1950 50  0001 C CNN
F 3 "" H 11375 1950 50  0001 C CNN
	1    11375 1950
	1    0    0    -1  
$EndComp
Text GLabel 11675 2950 2    50   Input ~ 0
_AS
Wire Wire Line
	11675 2950 11375 2950
$Comp
L Device:R R302
U 1 1 62340D22
P 11375 2800
F 0 "R302" H 11445 2846 50  0000 L CNN
F 1 "3.3K" H 11445 2755 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 11305 2800 50  0001 C CNN
F 3 "~" H 11375 2800 50  0001 C CNN
	1    11375 2800
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR02
U 1 1 62340D28
P 11375 2650
F 0 "#PWR02" H 11375 2500 50  0001 C CNN
F 1 "+5V" H 11390 2823 50  0000 C CNN
F 2 "" H 11375 2650 50  0001 C CNN
F 3 "" H 11375 2650 50  0001 C CNN
	1    11375 2650
	1    0    0    -1  
$EndComp
Wire Notes Line
	1350 1275 1350 4050
Wire Notes Line
	1350 4050 4975 4050
Wire Notes Line
	4975 4050 4975 1275
Wire Notes Line
	4975 1275 1350 1275
Text Notes 2000 1525 0    118  ~ 0
OUTPUT TO AMIGA BUFFER
Wire Notes Line
	11125 3825 13175 3825
Wire Notes Line
	13175 3825 13175 1225
Wire Notes Line
	13175 1225 11125 1225
Wire Notes Line
	11125 1225 11125 3825
Text Notes 11400 1550 0    118  ~ 0
PULL UP/DOWN
Text Notes 12350 9625 0    236  ~ 0
DISCRETE LOGIC BITS
Text Notes 12325 9150 0    118  ~ 0
Summer turns me upside down
Wire Bus Line
	2375 6950 2375 7975
$EndSCHEMATC