EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 3 8
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 1545 4120 0    50   Input ~ 0
CPUCLK_A
Text GLabel 1350 900  0    50   BiDi ~ 0
D(31..0)
Text GLabel 1545 4570 0    50   Input ~ 0
R_W
Text Label 5300 6200 2    50   ~ 0
D16
Text Label 5300 6300 2    50   ~ 0
D17
Text Label 5300 6400 2    50   ~ 0
D18
Text Label 5300 6500 2    50   ~ 0
D19
Text Label 5300 6600 2    50   ~ 0
D20
Text Label 5300 6700 2    50   ~ 0
D21
Text Label 5300 6800 2    50   ~ 0
D22
Text Label 5300 6900 2    50   ~ 0
D23
Text Label 5300 7000 2    50   ~ 0
D24
Text Label 5300 7100 2    50   ~ 0
D25
Text Label 5300 7200 2    50   ~ 0
D26
Text Label 5300 7300 2    50   ~ 0
D27
Text Label 5300 7400 2    50   ~ 0
D28
Text Label 5300 7500 2    50   ~ 0
D29
Text Label 5300 7600 2    50   ~ 0
D30
Text Label 5300 7700 2    50   ~ 0
D31
Text Notes 12400 9650 0    236  ~ 0
EXPANDED MEMORY
Text Notes 14225 9150 2    118  ~ 0
If I only had a brain.
$Comp
L Device:C C406
U 1 1 62F57967
P 14450 8125
F 0 "C406" H 14565 8171 50  0000 L CNN
F 1 "0.33uF" H 14565 8080 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 14488 7975 50  0001 C CNN
F 3 "~" H 14450 8125 50  0001 C CNN
	1    14450 8125
	1    0    0    -1  
$EndComp
$Comp
L Device:C C407
U 1 1 62F59277
P 14875 8125
F 0 "C407" H 14990 8171 50  0000 L CNN
F 1 "0.33uF" H 14990 8080 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 14913 7975 50  0001 C CNN
F 3 "~" H 14875 8125 50  0001 C CNN
	1    14875 8125
	1    0    0    -1  
$EndComp
$Comp
L Device:C C408
U 1 1 62F59AAD
P 15300 8125
F 0 "C408" H 15415 8171 50  0000 L CNN
F 1 "0.33uF" H 15415 8080 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 15338 7975 50  0001 C CNN
F 3 "~" H 15300 8125 50  0001 C CNN
	1    15300 8125
	1    0    0    -1  
$EndComp
$Comp
L Device:C C409
U 1 1 62F5A38E
P 15725 8125
F 0 "C409" H 15840 8171 50  0000 L CNN
F 1 "0.33uF" H 15840 8080 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 15763 7975 50  0001 C CNN
F 3 "~" H 15725 8125 50  0001 C CNN
	1    15725 8125
	1    0    0    -1  
$EndComp
Wire Wire Line
	14450 8500 14450 8275
Wire Wire Line
	14450 7975 14450 7750
Wire Wire Line
	14450 7750 14875 7750
Wire Wire Line
	15725 7975 15725 7750
Wire Wire Line
	15725 8275 15725 8500
Wire Wire Line
	15725 8500 15300 8500
Wire Wire Line
	15300 7975 15300 7750
Connection ~ 15300 7750
Wire Wire Line
	15300 7750 15725 7750
Wire Wire Line
	14875 7975 14875 7750
Connection ~ 14875 7750
Wire Wire Line
	14875 7750 15300 7750
Wire Wire Line
	14875 8275 14875 8500
Connection ~ 14875 8500
Wire Wire Line
	14875 8500 14450 8500
Wire Wire Line
	15300 8275 15300 8500
Connection ~ 15300 8500
Wire Wire Line
	15300 8500 14875 8500
$Comp
L power:GND #PWR0111
U 1 1 63373380
P 14450 8500
F 0 "#PWR0111" H 14450 8250 50  0001 C CNN
F 1 "GND" H 14455 8327 50  0000 C CNN
F 2 "" H 14450 8500 50  0001 C CNN
F 3 "" H 14450 8500 50  0001 C CNN
	1    14450 8500
	1    0    0    -1  
$EndComp
Connection ~ 14450 8500
$Comp
L power:+3.3V #PWR0116
U 1 1 6337477A
P 14450 7750
F 0 "#PWR0116" H 14450 7600 50  0001 C CNN
F 1 "+3.3V" H 14465 7923 50  0000 C CNN
F 2 "" H 14450 7750 50  0001 C CNN
F 3 "" H 14450 7750 50  0001 C CNN
	1    14450 7750
	1    0    0    -1  
$EndComp
Connection ~ 14450 7750
Text GLabel 1545 4370 0    50   Input ~ 0
_RAS
Text GLabel 1545 4470 0    50   Input ~ 0
_CAS
$Comp
L Memory_EPROM:27C256 U103
U 1 1 62A96FFD
P 15175 4725
F 0 "U103" H 15250 4750 50  0000 C CNN
F 1 "27C256" H 15250 4650 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 15175 4725 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0014.pdf" H 15175 4725 50  0001 C CNN
	1    15175 4725
	1    0    0    -1  
$EndComp
$Comp
L Device:C C102
U 1 1 62B32A4C
P 12955 8135
F 0 "C102" H 13070 8181 50  0000 L CNN
F 1 "0.22uF" H 13070 8090 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 12993 7985 50  0001 C CNN
F 3 "~" H 12955 8135 50  0001 C CNN
	1    12955 8135
	1    0    0    -1  
$EndComp
$Comp
L Device:C C103
U 1 1 62B330BE
P 13455 8135
F 0 "C103" H 13570 8181 50  0000 L CNN
F 1 "0.22uF" H 13570 8090 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 13493 7985 50  0001 C CNN
F 3 "~" H 13455 8135 50  0001 C CNN
	1    13455 8135
	1    0    0    -1  
$EndComp
Wire Wire Line
	12955 8285 12955 8435
Wire Wire Line
	12955 8435 13455 8435
Wire Wire Line
	13455 8435 13455 8285
Wire Wire Line
	12955 7985 12955 7785
Wire Wire Line
	12955 7785 13455 7785
Wire Wire Line
	13455 7785 13455 7985
$Comp
L power:GND #PWR0133
U 1 1 62B75BE7
P 12955 8435
F 0 "#PWR0133" H 12955 8185 50  0001 C CNN
F 1 "GND" H 12960 8262 50  0000 C CNN
F 2 "" H 12955 8435 50  0001 C CNN
F 3 "" H 12955 8435 50  0001 C CNN
	1    12955 8435
	1    0    0    -1  
$EndComp
Connection ~ 12955 8435
$Comp
L power:+5V #PWR0134
U 1 1 62B765FC
P 12955 7785
F 0 "#PWR0134" H 12955 7635 50  0001 C CNN
F 1 "+5V" H 12970 7958 50  0000 C CNN
F 2 "" H 12955 7785 50  0001 C CNN
F 3 "" H 12955 7785 50  0001 C CNN
	1    12955 7785
	1    0    0    -1  
$EndComp
Connection ~ 12955 7785
$Comp
L power:+5V #PWR0135
U 1 1 62B9D0CA
P 15175 3625
F 0 "#PWR0135" H 15175 3475 50  0001 C CNN
F 1 "+5V" H 15190 3798 50  0000 C CNN
F 2 "" H 15175 3625 50  0001 C CNN
F 3 "" H 15175 3625 50  0001 C CNN
	1    15175 3625
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0136
U 1 1 62B9EA5D
P 15175 5825
F 0 "#PWR0136" H 15175 5575 50  0001 C CNN
F 1 "GND" H 15180 5652 50  0000 C CNN
F 2 "" H 15175 5825 50  0001 C CNN
F 3 "" H 15175 5825 50  0001 C CNN
	1    15175 5825
	1    0    0    -1  
$EndComp
Wire Wire Line
	15575 3825 15775 3825
Wire Wire Line
	15575 3925 15775 3925
Wire Wire Line
	15575 4025 15775 4025
Wire Wire Line
	15575 4525 15775 4525
Wire Wire Line
	15575 4425 15775 4425
Wire Wire Line
	15575 4325 15775 4325
Wire Wire Line
	15575 4225 15775 4225
Wire Wire Line
	15575 4125 15775 4125
Wire Wire Line
	14775 5225 14575 5225
Wire Wire Line
	14775 5125 14575 5125
Wire Wire Line
	14775 5025 14575 5025
Wire Wire Line
	14775 4925 14575 4925
Wire Wire Line
	14775 4825 14575 4825
Wire Wire Line
	14775 4725 14575 4725
Wire Wire Line
	14775 4625 14575 4625
Wire Wire Line
	14775 4525 14575 4525
Wire Wire Line
	14775 4425 14575 4425
Wire Wire Line
	14775 4325 14575 4325
Wire Wire Line
	14775 4225 14575 4225
Wire Wire Line
	14775 4125 14575 4125
Wire Wire Line
	14775 4025 14575 4025
Wire Wire Line
	14775 3925 14575 3925
Wire Wire Line
	14775 3825 14575 3825
Entry Wire Line
	15775 4525 15875 4425
Entry Wire Line
	15775 4425 15875 4325
Entry Wire Line
	15775 4325 15875 4225
Entry Wire Line
	15775 4225 15875 4125
Entry Wire Line
	15775 4125 15875 4025
Entry Wire Line
	15775 4025 15875 3925
Entry Wire Line
	15775 3925 15875 3825
Entry Wire Line
	15775 3825 15875 3725
Entry Wire Line
	14575 3825 14475 3725
Entry Wire Line
	14575 3925 14475 3825
Entry Wire Line
	14575 4025 14475 3925
Entry Wire Line
	14575 4125 14475 4025
Entry Wire Line
	14575 4225 14475 4125
Entry Wire Line
	14575 4325 14475 4225
Entry Wire Line
	14575 4425 14475 4325
Entry Wire Line
	14575 5225 14475 5125
Entry Wire Line
	14575 5125 14475 5025
Entry Wire Line
	14575 5025 14475 4925
Entry Wire Line
	14575 4925 14475 4825
Entry Wire Line
	14575 4825 14475 4725
Entry Wire Line
	14575 4725 14475 4625
Entry Wire Line
	14575 4625 14475 4525
Entry Wire Line
	14575 4525 14475 4425
Entry Wire Line
	14575 5425 14475 5325
Wire Wire Line
	14775 5425 14575 5425
Wire Wire Line
	14775 5525 14525 5525
Wire Wire Line
	14525 5525 14525 5825
Wire Wire Line
	14525 5825 15175 5825
Connection ~ 15175 5825
Text Label 15775 3825 2    50   ~ 0
D24
Text Label 15775 3925 2    50   ~ 0
D25
Text Label 15775 4025 2    50   ~ 0
D26
Text Label 15775 4125 2    50   ~ 0
D27
Text Label 15775 4225 2    50   ~ 0
D28
Text Label 15775 4325 2    50   ~ 0
D29
Text Label 15775 4425 2    50   ~ 0
D30
Text Label 15775 4525 2    50   ~ 0
D31
Text Label 14575 3825 0    50   ~ 0
A1
Text Label 14575 3925 0    50   ~ 0
A2
Text Label 14575 4025 0    50   ~ 0
A3
Text Label 14575 4125 0    50   ~ 0
A4
Text Label 14575 4225 0    50   ~ 0
A5
Text Label 14575 4325 0    50   ~ 0
A6
Text Label 14575 4425 0    50   ~ 0
A7
Text Label 14575 4525 0    50   ~ 0
A8
Text Label 14575 4625 0    50   ~ 0
A9
Text Label 14575 4725 0    50   ~ 0
A10
Text Label 14575 4825 0    50   ~ 0
A11
Text Label 14575 4925 0    50   ~ 0
A12
Text Label 14575 5025 0    50   ~ 0
A13
Text Label 14575 5125 0    50   ~ 0
A14
Text Label 14575 5225 0    50   ~ 0
A15
Text Label 14575 5425 0    50   ~ 0
A16
$Comp
L Memory_EPROM:27C256 U102
U 1 1 630008CE
P 13375 4725
F 0 "U102" H 13450 4750 50  0000 C CNN
F 1 "27C256" H 13450 4650 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm" H 13375 4725 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0014.pdf" H 13375 4725 50  0001 C CNN
	1    13375 4725
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0137
U 1 1 630008D4
P 13375 3625
F 0 "#PWR0137" H 13375 3475 50  0001 C CNN
F 1 "+5V" H 13390 3798 50  0000 C CNN
F 2 "" H 13375 3625 50  0001 C CNN
F 3 "" H 13375 3625 50  0001 C CNN
	1    13375 3625
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0138
U 1 1 630008DA
P 13375 5825
F 0 "#PWR0138" H 13375 5575 50  0001 C CNN
F 1 "GND" H 13380 5652 50  0000 C CNN
F 2 "" H 13375 5825 50  0001 C CNN
F 3 "" H 13375 5825 50  0001 C CNN
	1    13375 5825
	1    0    0    -1  
$EndComp
Wire Wire Line
	13775 3825 13975 3825
Wire Wire Line
	13775 3925 13975 3925
Wire Wire Line
	13775 4025 13975 4025
Wire Wire Line
	13775 4525 13975 4525
Wire Wire Line
	13775 4425 13975 4425
Wire Wire Line
	13775 4325 13975 4325
Wire Wire Line
	13775 4225 13975 4225
Wire Wire Line
	13775 4125 13975 4125
Wire Wire Line
	12975 5225 12775 5225
Wire Wire Line
	12975 5125 12775 5125
Wire Wire Line
	12975 5025 12775 5025
Wire Wire Line
	12975 4925 12775 4925
Wire Wire Line
	12975 4825 12775 4825
Wire Wire Line
	12975 4725 12775 4725
Wire Wire Line
	12975 4625 12775 4625
Wire Wire Line
	12975 4525 12775 4525
Wire Wire Line
	12975 4425 12775 4425
Wire Wire Line
	12975 4325 12775 4325
Wire Wire Line
	12975 4225 12775 4225
Wire Wire Line
	12975 4125 12775 4125
Wire Wire Line
	12975 4025 12775 4025
Wire Wire Line
	12975 3925 12775 3925
Wire Wire Line
	12975 3825 12775 3825
Entry Wire Line
	13975 4525 14075 4425
Entry Wire Line
	13975 4425 14075 4325
Entry Wire Line
	13975 4325 14075 4225
Entry Wire Line
	13975 4225 14075 4125
Entry Wire Line
	13975 4125 14075 4025
Entry Wire Line
	13975 4025 14075 3925
Entry Wire Line
	13975 3925 14075 3825
Entry Wire Line
	13975 3825 14075 3725
Entry Wire Line
	12775 3825 12675 3725
Entry Wire Line
	12775 3925 12675 3825
Entry Wire Line
	12775 4025 12675 3925
Entry Wire Line
	12775 4125 12675 4025
Entry Wire Line
	12775 4225 12675 4125
Entry Wire Line
	12775 4325 12675 4225
Entry Wire Line
	12775 4425 12675 4325
Entry Wire Line
	12775 5225 12675 5125
Entry Wire Line
	12775 5125 12675 5025
Entry Wire Line
	12775 5025 12675 4925
Entry Wire Line
	12775 4925 12675 4825
Entry Wire Line
	12775 4825 12675 4725
Entry Wire Line
	12775 4725 12675 4625
Entry Wire Line
	12775 4625 12675 4525
Entry Wire Line
	12775 4525 12675 4425
Entry Wire Line
	12775 5425 12675 5325
Wire Wire Line
	12975 5425 12775 5425
Wire Wire Line
	12975 5525 12725 5525
Wire Wire Line
	12725 5525 12725 5825
Wire Wire Line
	12725 5825 13375 5825
Connection ~ 13375 5825
Text Label 13975 3825 2    50   ~ 0
D16
Text Label 13975 3925 2    50   ~ 0
D17
Text Label 13975 4025 2    50   ~ 0
D18
Text Label 13975 4125 2    50   ~ 0
D19
Text Label 13975 4225 2    50   ~ 0
D20
Text Label 13975 4325 2    50   ~ 0
D21
Text Label 13975 4425 2    50   ~ 0
D22
Text Label 13975 4525 2    50   ~ 0
D23
Text Label 12775 3825 0    50   ~ 0
A1
Text Label 12775 3925 0    50   ~ 0
A2
Text Label 12775 4025 0    50   ~ 0
A3
Text Label 12775 4125 0    50   ~ 0
A4
Text Label 12775 4225 0    50   ~ 0
A5
Text Label 12775 4325 0    50   ~ 0
A6
Text Label 12775 4425 0    50   ~ 0
A7
Text Label 12775 4525 0    50   ~ 0
A8
Text Label 12775 4625 0    50   ~ 0
A9
Text Label 12775 4725 0    50   ~ 0
A10
Text Label 12775 4825 0    50   ~ 0
A11
Text Label 12775 4925 0    50   ~ 0
A12
Text Label 12775 5025 0    50   ~ 0
A13
Text Label 12775 5125 0    50   ~ 0
A14
Text Label 12775 5225 0    50   ~ 0
A15
Text Label 12775 5425 0    50   ~ 0
A16
Entry Bus Bus
	13975 3100 14075 3200
Entry Bus Bus
	12575 6300 12675 6200
Text GLabel 11775 6300 0    50   BiDi ~ 0
D(31:0)
Text GLabel 11850 3100 0    50   Input ~ 0
A(31:0)
Wire Wire Line
	14775 5625 14650 5625
Wire Wire Line
	14650 5625 14650 6075
Wire Wire Line
	14650 6075 12850 6075
Wire Wire Line
	12975 5625 12850 5625
Wire Wire Line
	12850 5625 12850 6075
Connection ~ 12850 6075
Wire Wire Line
	12850 6075 11775 6075
Text GLabel 11775 6075 0    50   Input ~ 0
_CSROM
Wire Notes Line
	11325 2925 11325 6425
Wire Notes Line
	11325 6425 16050 6425
Wire Notes Line
	16050 6425 16050 2900
Wire Notes Line
	16050 2900 11325 2900
Text Notes 11600 4000 0    157  ~ 0
ROMs
Text Label 3200 2600 0    50   ~ 0
EMA0
Text Label 3200 2700 0    50   ~ 0
EMA1
Text Label 3200 2800 0    50   ~ 0
EMA2
Text Label 3200 2900 0    50   ~ 0
EMA3
Text Label 3200 3000 0    50   ~ 0
EMA4
Text Label 3200 3100 0    50   ~ 0
EMA5
Text Label 3200 3200 0    50   ~ 0
EMA6
Text Label 3200 3300 0    50   ~ 0
EMA7
Text Label 3200 3400 0    50   ~ 0
EMA8
Text Label 3200 3500 0    50   ~ 0
EMA9
Text Label 3200 3600 0    50   ~ 0
EMA10
Text Label 3200 3700 0    50   ~ 0
EMA11
Text Label 3200 3800 0    50   ~ 0
EMA12
$Comp
L N2630:SDRAM_256MB(16Mx16) U406
U 1 1 62134E3A
P 4250 3650
F 0 "U406" H 4250 3650 50  0000 C CNN
F 1 "SDRAM_512Mb(32Mx16)" H 4250 3450 50  0000 C CNN
F 2 "TSOPII-54" H 4250 3650 50  0001 C CIN
F 3 "" H 4250 3400 50  0001 C CNN
	1    4250 3650
	1    0    0    -1  
$EndComp
Text Label 5300 2600 2    50   ~ 0
D0
Text Label 5300 2700 2    50   ~ 0
D1
Text Label 5300 2800 2    50   ~ 0
D2
Text Label 5300 2900 2    50   ~ 0
D3
Text Label 5300 3000 2    50   ~ 0
D4
Text Label 5300 3100 2    50   ~ 0
D5
Text Label 5300 3200 2    50   ~ 0
D6
Text Label 5300 3300 2    50   ~ 0
D7
Text Label 5300 3400 2    50   ~ 0
D8
Text Label 5300 3500 2    50   ~ 0
D9
Text Label 5300 3600 2    50   ~ 0
D10
Text Label 5300 3700 2    50   ~ 0
D11
Text Label 5300 3800 2    50   ~ 0
D12
Text Label 5300 3900 2    50   ~ 0
D13
Text Label 5300 4000 2    50   ~ 0
D14
Text Label 5300 4100 2    50   ~ 0
D15
Wire Wire Line
	5050 2600 5300 2600
Entry Wire Line
	5300 2600 5400 2500
Wire Wire Line
	5050 2700 5300 2700
Entry Wire Line
	5300 2700 5400 2600
Wire Wire Line
	5050 2800 5300 2800
Entry Wire Line
	5300 2800 5400 2700
Wire Wire Line
	5050 2900 5300 2900
Entry Wire Line
	5300 2900 5400 2800
Wire Wire Line
	5050 3000 5300 3000
Entry Wire Line
	5300 3000 5400 2900
Wire Wire Line
	5050 3100 5300 3100
Entry Wire Line
	5300 3100 5400 3000
Wire Wire Line
	5050 3200 5300 3200
Entry Wire Line
	5300 3200 5400 3100
Wire Wire Line
	5050 3300 5300 3300
Entry Wire Line
	5300 3300 5400 3200
Wire Wire Line
	5050 3400 5300 3400
Entry Wire Line
	5300 3400 5400 3300
Wire Wire Line
	5050 3500 5300 3500
Entry Wire Line
	5300 3500 5400 3400
Wire Wire Line
	5050 3600 5300 3600
Entry Wire Line
	5300 3600 5400 3500
Wire Wire Line
	5050 3700 5300 3700
Entry Wire Line
	5300 3700 5400 3600
Wire Wire Line
	5050 3800 5300 3800
Entry Wire Line
	5300 3800 5400 3700
Wire Wire Line
	5050 3900 5300 3900
Entry Wire Line
	5300 3900 5400 3800
Wire Wire Line
	5050 4000 5300 4000
Entry Wire Line
	5300 4000 5400 3900
Wire Wire Line
	5050 4100 5300 4100
Entry Wire Line
	5300 4100 5400 4000
Wire Wire Line
	3950 2350 3950 2250
Wire Wire Line
	3950 2250 4050 2250
Wire Wire Line
	4550 2250 4550 2150
Wire Wire Line
	4550 2350 4550 2250
Connection ~ 4550 2250
Wire Wire Line
	4450 2350 4450 2250
Connection ~ 4450 2250
Wire Wire Line
	4450 2250 4550 2250
Wire Wire Line
	4350 2350 4350 2250
Connection ~ 4350 2250
Wire Wire Line
	4350 2250 4450 2250
Wire Wire Line
	4250 2350 4250 2250
Connection ~ 4250 2250
Wire Wire Line
	4250 2250 4350 2250
Wire Wire Line
	4150 2350 4150 2250
Connection ~ 4150 2250
Wire Wire Line
	4150 2250 4250 2250
Wire Wire Line
	4050 2350 4050 2250
Connection ~ 4050 2250
Wire Wire Line
	4050 2250 4150 2250
$Comp
L power:+3.3V #PWR?
U 1 1 6233C744
P 4550 2150
F 0 "#PWR?" H 4550 2000 50  0001 C CNN
F 1 "+3.3V" H 4565 2323 50  0000 C CNN
F 2 "" H 4550 2150 50  0001 C CNN
F 3 "" H 4550 2150 50  0001 C CNN
	1    4550 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 4950 3950 5050
Wire Wire Line
	3950 5050 4050 5050
Wire Wire Line
	4550 5050 4550 5150
Wire Wire Line
	4550 5050 4550 4950
Connection ~ 4550 5050
Wire Wire Line
	4450 4950 4450 5050
Connection ~ 4450 5050
Wire Wire Line
	4450 5050 4550 5050
Wire Wire Line
	4350 4950 4350 5050
Connection ~ 4350 5050
Wire Wire Line
	4350 5050 4450 5050
Wire Wire Line
	4250 4950 4250 5050
Connection ~ 4250 5050
Wire Wire Line
	4250 5050 4350 5050
Wire Wire Line
	4150 4950 4150 5050
Connection ~ 4150 5050
Wire Wire Line
	4150 5050 4250 5050
Wire Wire Line
	4050 4950 4050 5050
Connection ~ 4050 5050
Wire Wire Line
	4050 5050 4150 5050
$Comp
L power:GND #PWR?
U 1 1 623C45EC
P 4550 5150
F 0 "#PWR?" H 4550 4900 50  0001 C CNN
F 1 "GND" H 4555 4977 50  0000 C CNN
F 2 "" H 4550 5150 50  0001 C CNN
F 3 "" H 4550 5150 50  0001 C CNN
	1    4550 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 2600 3200 2600
Entry Wire Line
	3200 2600 3100 2500
Wire Wire Line
	3450 2700 3200 2700
Entry Wire Line
	3200 2700 3100 2600
Wire Wire Line
	3450 2800 3200 2800
Entry Wire Line
	3200 2800 3100 2700
Wire Wire Line
	3450 2900 3200 2900
Entry Wire Line
	3200 2900 3100 2800
Wire Wire Line
	3450 3000 3200 3000
Entry Wire Line
	3200 3000 3100 2900
Wire Wire Line
	3450 3100 3200 3100
Entry Wire Line
	3200 3100 3100 3000
Wire Wire Line
	3450 3200 3200 3200
Entry Wire Line
	3200 3200 3100 3100
Wire Wire Line
	3450 3300 3200 3300
Entry Wire Line
	3200 3300 3100 3200
Wire Wire Line
	3450 3400 3200 3400
Entry Wire Line
	3200 3400 3100 3300
Wire Wire Line
	3450 3500 3200 3500
Entry Wire Line
	3200 3500 3100 3400
Wire Wire Line
	3450 3600 3200 3600
Entry Wire Line
	3200 3600 3100 3500
Wire Wire Line
	3450 3700 3200 3700
Entry Wire Line
	3200 3700 3100 3600
Wire Wire Line
	3450 3800 3200 3800
Entry Wire Line
	3200 3800 3100 3700
Text Label 3200 6200 0    50   ~ 0
EMA0
Text Label 3200 6300 0    50   ~ 0
EMA1
Text Label 3200 6400 0    50   ~ 0
EMA2
Text Label 3200 6500 0    50   ~ 0
EMA3
Text Label 3200 6600 0    50   ~ 0
EMA4
Text Label 3200 6700 0    50   ~ 0
EMA5
Text Label 3200 6800 0    50   ~ 0
EMA6
Text Label 3200 6900 0    50   ~ 0
EMA7
Text Label 3200 7000 0    50   ~ 0
EMA8
Text Label 3200 7100 0    50   ~ 0
EMA9
Text Label 3200 7200 0    50   ~ 0
EMA10
Text Label 3200 7300 0    50   ~ 0
EMA11
Text Label 3200 7400 0    50   ~ 0
EMA12
$Comp
L N2630:SDRAM_256MB(16Mx16) U407
U 1 1 62536620
P 4250 7250
F 0 "U407" H 4250 7250 50  0000 C CNN
F 1 "SDRAM_512Mb(32Mx16)" H 4250 7050 50  0000 C CNN
F 2 "TSOPII-54" H 4250 7250 50  0001 C CIN
F 3 "" H 4250 7000 50  0001 C CNN
	1    4250 7250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 6200 5300 6200
Entry Wire Line
	5300 6200 5400 6100
Wire Wire Line
	5050 6300 5300 6300
Entry Wire Line
	5300 6300 5400 6200
Wire Wire Line
	5050 6400 5300 6400
Entry Wire Line
	5300 6400 5400 6300
Wire Wire Line
	5050 6500 5300 6500
Entry Wire Line
	5300 6500 5400 6400
Wire Wire Line
	5050 6600 5300 6600
Entry Wire Line
	5300 6600 5400 6500
Wire Wire Line
	5050 6700 5300 6700
Entry Wire Line
	5300 6700 5400 6600
Wire Wire Line
	5050 6800 5300 6800
Entry Wire Line
	5300 6800 5400 6700
Wire Wire Line
	5050 6900 5300 6900
Entry Wire Line
	5300 6900 5400 6800
Wire Wire Line
	5050 7000 5300 7000
Entry Wire Line
	5300 7000 5400 6900
Wire Wire Line
	5050 7100 5300 7100
Entry Wire Line
	5300 7100 5400 7000
Wire Wire Line
	5050 7200 5300 7200
Entry Wire Line
	5300 7200 5400 7100
Wire Wire Line
	5050 7300 5300 7300
Entry Wire Line
	5300 7300 5400 7200
Wire Wire Line
	5050 7400 5300 7400
Entry Wire Line
	5300 7400 5400 7300
Wire Wire Line
	5050 7500 5300 7500
Entry Wire Line
	5300 7500 5400 7400
Wire Wire Line
	5050 7600 5300 7600
Entry Wire Line
	5300 7600 5400 7500
Wire Wire Line
	5050 7700 5300 7700
Entry Wire Line
	5300 7700 5400 7600
Wire Wire Line
	3950 5950 3950 5850
Wire Wire Line
	3950 5850 4050 5850
Wire Wire Line
	4550 5850 4550 5750
Wire Wire Line
	4550 5950 4550 5850
Connection ~ 4550 5850
Wire Wire Line
	4450 5950 4450 5850
Connection ~ 4450 5850
Wire Wire Line
	4450 5850 4550 5850
Wire Wire Line
	4350 5950 4350 5850
Connection ~ 4350 5850
Wire Wire Line
	4350 5850 4450 5850
Wire Wire Line
	4250 5950 4250 5850
Connection ~ 4250 5850
Wire Wire Line
	4250 5850 4350 5850
Wire Wire Line
	4150 5950 4150 5850
Connection ~ 4150 5850
Wire Wire Line
	4150 5850 4250 5850
Wire Wire Line
	4050 5950 4050 5850
Connection ~ 4050 5850
Wire Wire Line
	4050 5850 4150 5850
$Comp
L power:+3.3V #PWR?
U 1 1 6253666A
P 4550 5750
F 0 "#PWR?" H 4550 5600 50  0001 C CNN
F 1 "+3.3V" H 4565 5923 50  0000 C CNN
F 2 "" H 4550 5750 50  0001 C CNN
F 3 "" H 4550 5750 50  0001 C CNN
	1    4550 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 8550 3950 8650
Wire Wire Line
	3950 8650 4050 8650
Wire Wire Line
	4550 8650 4550 8750
Wire Wire Line
	4550 8650 4550 8550
Connection ~ 4550 8650
Wire Wire Line
	4450 8550 4450 8650
Connection ~ 4450 8650
Wire Wire Line
	4450 8650 4550 8650
Wire Wire Line
	4350 8550 4350 8650
Connection ~ 4350 8650
Wire Wire Line
	4350 8650 4450 8650
Wire Wire Line
	4250 8550 4250 8650
Connection ~ 4250 8650
Wire Wire Line
	4250 8650 4350 8650
Wire Wire Line
	4150 8550 4150 8650
Connection ~ 4150 8650
Wire Wire Line
	4150 8650 4250 8650
Wire Wire Line
	4050 8550 4050 8650
Connection ~ 4050 8650
Wire Wire Line
	4050 8650 4150 8650
$Comp
L power:GND #PWR?
U 1 1 62536684
P 4550 8750
F 0 "#PWR?" H 4550 8500 50  0001 C CNN
F 1 "GND" H 4555 8577 50  0000 C CNN
F 2 "" H 4550 8750 50  0001 C CNN
F 3 "" H 4550 8750 50  0001 C CNN
	1    4550 8750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 6200 3200 6200
Entry Wire Line
	3200 6200 3100 6100
Wire Wire Line
	3450 6300 3200 6300
Entry Wire Line
	3200 6300 3100 6200
Wire Wire Line
	3450 6400 3200 6400
Entry Wire Line
	3200 6400 3100 6300
Wire Wire Line
	3450 6500 3200 6500
Entry Wire Line
	3200 6500 3100 6400
Wire Wire Line
	3450 6600 3200 6600
Entry Wire Line
	3200 6600 3100 6500
Wire Wire Line
	3450 6700 3200 6700
Entry Wire Line
	3200 6700 3100 6600
Wire Wire Line
	3450 6800 3200 6800
Entry Wire Line
	3200 6800 3100 6700
Wire Wire Line
	3450 6900 3200 6900
Entry Wire Line
	3200 6900 3100 6800
Wire Wire Line
	3450 7000 3200 7000
Entry Wire Line
	3200 7000 3100 6900
Wire Wire Line
	3450 7100 3200 7100
Entry Wire Line
	3200 7100 3100 7000
Wire Wire Line
	3450 7200 3200 7200
Entry Wire Line
	3200 7200 3100 7100
Wire Wire Line
	3450 7300 3200 7300
Entry Wire Line
	3200 7300 3100 7200
Wire Wire Line
	3450 7400 3200 7400
Entry Wire Line
	3200 7400 3100 7300
Entry Bus Bus
	5400 1000 5300 900 
Text GLabel 1350 1100 0    50   BiDi ~ 0
EM(12..0)
Entry Bus Bus
	3100 1200 3000 1100
Text Label 9300 6200 2    50   ~ 0
D16
Text Label 9300 6300 2    50   ~ 0
D17
Text Label 9300 6400 2    50   ~ 0
D18
Text Label 9300 6500 2    50   ~ 0
D19
Text Label 9300 6600 2    50   ~ 0
D20
Text Label 9300 6700 2    50   ~ 0
D21
Text Label 9300 6800 2    50   ~ 0
D22
Text Label 9300 6900 2    50   ~ 0
D23
Text Label 9300 7000 2    50   ~ 0
D24
Text Label 9300 7100 2    50   ~ 0
D25
Text Label 9300 7200 2    50   ~ 0
D26
Text Label 9300 7300 2    50   ~ 0
D27
Text Label 9300 7400 2    50   ~ 0
D28
Text Label 9300 7500 2    50   ~ 0
D29
Text Label 9300 7600 2    50   ~ 0
D30
Text Label 9300 7700 2    50   ~ 0
D31
Text Label 7200 2600 0    50   ~ 0
EMA0
Text Label 7200 2700 0    50   ~ 0
EMA1
Text Label 7200 2800 0    50   ~ 0
EMA2
Text Label 7200 2900 0    50   ~ 0
EMA3
Text Label 7200 3000 0    50   ~ 0
EMA4
Text Label 7200 3100 0    50   ~ 0
EMA5
Text Label 7200 3200 0    50   ~ 0
EMA6
Text Label 7200 3300 0    50   ~ 0
EMA7
Text Label 7200 3400 0    50   ~ 0
EMA8
Text Label 7200 3500 0    50   ~ 0
EMA9
Text Label 7200 3600 0    50   ~ 0
EMA10
Text Label 7200 3700 0    50   ~ 0
EMA11
Text Label 7200 3800 0    50   ~ 0
EMA12
$Comp
L N2630:SDRAM_256MB(16Mx16) U408
U 1 1 625C827E
P 8250 3650
F 0 "U408" H 8250 3650 50  0000 C CNN
F 1 "SDRAM_512Mb(32Mx16)" H 8250 3450 50  0000 C CNN
F 2 "TSOPII-54" H 8250 3650 50  0001 C CIN
F 3 "" H 8250 3400 50  0001 C CNN
	1    8250 3650
	1    0    0    -1  
$EndComp
Text Label 9300 2600 2    50   ~ 0
D0
Text Label 9300 2700 2    50   ~ 0
D1
Text Label 9300 2800 2    50   ~ 0
D2
Text Label 9300 2900 2    50   ~ 0
D3
Text Label 9300 3000 2    50   ~ 0
D4
Text Label 9300 3100 2    50   ~ 0
D5
Text Label 9300 3200 2    50   ~ 0
D6
Text Label 9300 3300 2    50   ~ 0
D7
Text Label 9300 3400 2    50   ~ 0
D8
Text Label 9300 3500 2    50   ~ 0
D9
Text Label 9300 3600 2    50   ~ 0
D10
Text Label 9300 3700 2    50   ~ 0
D11
Text Label 9300 3800 2    50   ~ 0
D12
Text Label 9300 3900 2    50   ~ 0
D13
Text Label 9300 4000 2    50   ~ 0
D14
Text Label 9300 4100 2    50   ~ 0
D15
Wire Wire Line
	9050 2600 9300 2600
Entry Wire Line
	9300 2600 9400 2500
Wire Wire Line
	9050 2700 9300 2700
Entry Wire Line
	9300 2700 9400 2600
Wire Wire Line
	9050 2800 9300 2800
Entry Wire Line
	9300 2800 9400 2700
Wire Wire Line
	9050 2900 9300 2900
Entry Wire Line
	9300 2900 9400 2800
Wire Wire Line
	9050 3000 9300 3000
Entry Wire Line
	9300 3000 9400 2900
Wire Wire Line
	9050 3100 9300 3100
Entry Wire Line
	9300 3100 9400 3000
Wire Wire Line
	9050 3200 9300 3200
Entry Wire Line
	9300 3200 9400 3100
Wire Wire Line
	9050 3300 9300 3300
Entry Wire Line
	9300 3300 9400 3200
Wire Wire Line
	9050 3400 9300 3400
Entry Wire Line
	9300 3400 9400 3300
Wire Wire Line
	9050 3500 9300 3500
Entry Wire Line
	9300 3500 9400 3400
Wire Wire Line
	9050 3600 9300 3600
Entry Wire Line
	9300 3600 9400 3500
Wire Wire Line
	9050 3700 9300 3700
Entry Wire Line
	9300 3700 9400 3600
Wire Wire Line
	9050 3800 9300 3800
Entry Wire Line
	9300 3800 9400 3700
Wire Wire Line
	9050 3900 9300 3900
Entry Wire Line
	9300 3900 9400 3800
Wire Wire Line
	9050 4000 9300 4000
Entry Wire Line
	9300 4000 9400 3900
Wire Wire Line
	9050 4100 9300 4100
Entry Wire Line
	9300 4100 9400 4000
Wire Wire Line
	7950 2350 7950 2250
Wire Wire Line
	7950 2250 8050 2250
Wire Wire Line
	8550 2250 8550 2150
Wire Wire Line
	8550 2350 8550 2250
Connection ~ 8550 2250
Wire Wire Line
	8450 2350 8450 2250
Connection ~ 8450 2250
Wire Wire Line
	8450 2250 8550 2250
Wire Wire Line
	8350 2350 8350 2250
Connection ~ 8350 2250
Wire Wire Line
	8350 2250 8450 2250
Wire Wire Line
	8250 2350 8250 2250
Connection ~ 8250 2250
Wire Wire Line
	8250 2250 8350 2250
Wire Wire Line
	8150 2350 8150 2250
Connection ~ 8150 2250
Wire Wire Line
	8150 2250 8250 2250
Wire Wire Line
	8050 2350 8050 2250
Connection ~ 8050 2250
Wire Wire Line
	8050 2250 8150 2250
$Comp
L power:+3.3V #PWR?
U 1 1 625C82C8
P 8550 2150
F 0 "#PWR?" H 8550 2000 50  0001 C CNN
F 1 "+3.3V" H 8565 2323 50  0000 C CNN
F 2 "" H 8550 2150 50  0001 C CNN
F 3 "" H 8550 2150 50  0001 C CNN
	1    8550 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 4950 7950 5050
Wire Wire Line
	7950 5050 8050 5050
Wire Wire Line
	8550 5050 8550 5150
Wire Wire Line
	8550 5050 8550 4950
Connection ~ 8550 5050
Wire Wire Line
	8450 4950 8450 5050
Connection ~ 8450 5050
Wire Wire Line
	8450 5050 8550 5050
Wire Wire Line
	8350 4950 8350 5050
Connection ~ 8350 5050
Wire Wire Line
	8350 5050 8450 5050
Wire Wire Line
	8250 4950 8250 5050
Connection ~ 8250 5050
Wire Wire Line
	8250 5050 8350 5050
Wire Wire Line
	8150 4950 8150 5050
Connection ~ 8150 5050
Wire Wire Line
	8150 5050 8250 5050
Wire Wire Line
	8050 4950 8050 5050
Connection ~ 8050 5050
Wire Wire Line
	8050 5050 8150 5050
$Comp
L power:GND #PWR?
U 1 1 625C82E2
P 8550 5150
F 0 "#PWR?" H 8550 4900 50  0001 C CNN
F 1 "GND" H 8555 4977 50  0000 C CNN
F 2 "" H 8550 5150 50  0001 C CNN
F 3 "" H 8550 5150 50  0001 C CNN
	1    8550 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 2600 7200 2600
Entry Wire Line
	7200 2600 7100 2500
Wire Wire Line
	7450 2700 7200 2700
Entry Wire Line
	7200 2700 7100 2600
Wire Wire Line
	7450 2800 7200 2800
Entry Wire Line
	7200 2800 7100 2700
Wire Wire Line
	7450 2900 7200 2900
Entry Wire Line
	7200 2900 7100 2800
Wire Wire Line
	7450 3000 7200 3000
Entry Wire Line
	7200 3000 7100 2900
Wire Wire Line
	7450 3100 7200 3100
Entry Wire Line
	7200 3100 7100 3000
Wire Wire Line
	7450 3200 7200 3200
Entry Wire Line
	7200 3200 7100 3100
Wire Wire Line
	7450 3300 7200 3300
Entry Wire Line
	7200 3300 7100 3200
Wire Wire Line
	7450 3400 7200 3400
Entry Wire Line
	7200 3400 7100 3300
Wire Wire Line
	7450 3500 7200 3500
Entry Wire Line
	7200 3500 7100 3400
Wire Wire Line
	7450 3600 7200 3600
Entry Wire Line
	7200 3600 7100 3500
Wire Wire Line
	7450 3700 7200 3700
Entry Wire Line
	7200 3700 7100 3600
Wire Wire Line
	7450 3800 7200 3800
Entry Wire Line
	7200 3800 7100 3700
Text Label 7200 6200 0    50   ~ 0
EMA0
Text Label 7200 6300 0    50   ~ 0
EMA1
Text Label 7200 6400 0    50   ~ 0
EMA2
Text Label 7200 6500 0    50   ~ 0
EMA3
Text Label 7200 6600 0    50   ~ 0
EMA4
Text Label 7200 6700 0    50   ~ 0
EMA5
Text Label 7200 6800 0    50   ~ 0
EMA6
Text Label 7200 6900 0    50   ~ 0
EMA7
Text Label 7200 7000 0    50   ~ 0
EMA8
Text Label 7200 7100 0    50   ~ 0
EMA9
Text Label 7200 7200 0    50   ~ 0
EMA10
Text Label 7200 7300 0    50   ~ 0
EMA11
Text Label 7200 7400 0    50   ~ 0
EMA12
$Comp
L N2630:SDRAM_256MB(16Mx16) U409
U 1 1 625C830F
P 8250 7250
F 0 "U409" H 8250 7250 50  0000 C CNN
F 1 "SDRAM_512Mb(32Mx16)" H 8250 7050 50  0000 C CNN
F 2 "TSOPII-54" H 8250 7250 50  0001 C CIN
F 3 "" H 8250 7000 50  0001 C CNN
	1    8250 7250
	1    0    0    -1  
$EndComp
Wire Wire Line
	9050 6200 9300 6200
Entry Wire Line
	9300 6200 9400 6100
Wire Wire Line
	9050 6300 9300 6300
Entry Wire Line
	9300 6300 9400 6200
Wire Wire Line
	9050 6400 9300 6400
Entry Wire Line
	9300 6400 9400 6300
Wire Wire Line
	9050 6500 9300 6500
Entry Wire Line
	9300 6500 9400 6400
Wire Wire Line
	9050 6600 9300 6600
Entry Wire Line
	9300 6600 9400 6500
Wire Wire Line
	9050 6700 9300 6700
Entry Wire Line
	9300 6700 9400 6600
Wire Wire Line
	9050 6800 9300 6800
Entry Wire Line
	9300 6800 9400 6700
Wire Wire Line
	9050 6900 9300 6900
Entry Wire Line
	9300 6900 9400 6800
Wire Wire Line
	9050 7000 9300 7000
Entry Wire Line
	9300 7000 9400 6900
Wire Wire Line
	9050 7100 9300 7100
Entry Wire Line
	9300 7100 9400 7000
Wire Wire Line
	9050 7200 9300 7200
Entry Wire Line
	9300 7200 9400 7100
Wire Wire Line
	9050 7300 9300 7300
Entry Wire Line
	9300 7300 9400 7200
Wire Wire Line
	9050 7400 9300 7400
Entry Wire Line
	9300 7400 9400 7300
Wire Wire Line
	9050 7500 9300 7500
Entry Wire Line
	9300 7500 9400 7400
Wire Wire Line
	9050 7600 9300 7600
Entry Wire Line
	9300 7600 9400 7500
Wire Wire Line
	9050 7700 9300 7700
Entry Wire Line
	9300 7700 9400 7600
Wire Wire Line
	7950 5950 7950 5850
Wire Wire Line
	7950 5850 8050 5850
Wire Wire Line
	8550 5850 8550 5750
Wire Wire Line
	8550 5950 8550 5850
Connection ~ 8550 5850
Wire Wire Line
	8450 5950 8450 5850
Connection ~ 8450 5850
Wire Wire Line
	8450 5850 8550 5850
Wire Wire Line
	8350 5950 8350 5850
Connection ~ 8350 5850
Wire Wire Line
	8350 5850 8450 5850
Wire Wire Line
	8250 5950 8250 5850
Connection ~ 8250 5850
Wire Wire Line
	8250 5850 8350 5850
Wire Wire Line
	8150 5950 8150 5850
Connection ~ 8150 5850
Wire Wire Line
	8150 5850 8250 5850
Wire Wire Line
	8050 5950 8050 5850
Connection ~ 8050 5850
Wire Wire Line
	8050 5850 8150 5850
$Comp
L power:+3.3V #PWR?
U 1 1 625C8349
P 8550 5750
F 0 "#PWR?" H 8550 5600 50  0001 C CNN
F 1 "+3.3V" H 8565 5923 50  0000 C CNN
F 2 "" H 8550 5750 50  0001 C CNN
F 3 "" H 8550 5750 50  0001 C CNN
	1    8550 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 8550 7950 8650
Wire Wire Line
	7950 8650 8050 8650
Wire Wire Line
	8550 8650 8550 8750
Wire Wire Line
	8550 8650 8550 8550
Connection ~ 8550 8650
Wire Wire Line
	8450 8550 8450 8650
Connection ~ 8450 8650
Wire Wire Line
	8450 8650 8550 8650
Wire Wire Line
	8350 8550 8350 8650
Connection ~ 8350 8650
Wire Wire Line
	8350 8650 8450 8650
Wire Wire Line
	8250 8550 8250 8650
Connection ~ 8250 8650
Wire Wire Line
	8250 8650 8350 8650
Wire Wire Line
	8150 8550 8150 8650
Connection ~ 8150 8650
Wire Wire Line
	8150 8650 8250 8650
Wire Wire Line
	8050 8550 8050 8650
Connection ~ 8050 8650
Wire Wire Line
	8050 8650 8150 8650
$Comp
L power:GND #PWR?
U 1 1 625C8363
P 8550 8750
F 0 "#PWR?" H 8550 8500 50  0001 C CNN
F 1 "GND" H 8555 8577 50  0000 C CNN
F 2 "" H 8550 8750 50  0001 C CNN
F 3 "" H 8550 8750 50  0001 C CNN
	1    8550 8750
	1    0    0    -1  
$EndComp
Wire Wire Line
	7450 6200 7200 6200
Entry Wire Line
	7200 6200 7100 6100
Wire Wire Line
	7450 6300 7200 6300
Entry Wire Line
	7200 6300 7100 6200
Wire Wire Line
	7450 6400 7200 6400
Entry Wire Line
	7200 6400 7100 6300
Wire Wire Line
	7450 6500 7200 6500
Entry Wire Line
	7200 6500 7100 6400
Wire Wire Line
	7450 6600 7200 6600
Entry Wire Line
	7200 6600 7100 6500
Wire Wire Line
	7450 6700 7200 6700
Entry Wire Line
	7200 6700 7100 6600
Wire Wire Line
	7450 6800 7200 6800
Entry Wire Line
	7200 6800 7100 6700
Wire Wire Line
	7450 6900 7200 6900
Entry Wire Line
	7200 6900 7100 6800
Wire Wire Line
	7450 7000 7200 7000
Entry Wire Line
	7200 7000 7100 6900
Wire Wire Line
	7450 7100 7200 7100
Entry Wire Line
	7200 7100 7100 7000
Wire Wire Line
	7450 7200 7200 7200
Entry Wire Line
	7200 7200 7100 7100
Wire Wire Line
	7450 7300 7200 7300
Entry Wire Line
	7200 7300 7100 7200
Wire Wire Line
	7450 7400 7200 7400
Entry Wire Line
	7200 7400 7100 7300
Wire Bus Line
	1350 1100 7100 1100
Wire Bus Line
	1350 900  9400 900 
Wire Bus Line
	11775 6300 14475 6300
Wire Bus Line
	11850 3100 15875 3100
Wire Bus Line
	14075 3200 14075 4425
Wire Bus Line
	15875 3100 15875 4425
Wire Bus Line
	14475 3725 14475 6300
Wire Bus Line
	12675 3725 12675 6200
Wire Bus Line
	3100 1200 3100 7300
Wire Bus Line
	7100 1100 7100 7300
Wire Bus Line
	5400 1000 5400 7600
Wire Bus Line
	9400 900  9400 7600
$EndSCHEMATC
