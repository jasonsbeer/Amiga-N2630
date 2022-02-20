EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr B 17000 11000
encoding utf-8
Sheet 8 8
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
L CPLD_Xilinx:XC9572XL-TQ100 U600
U 1 1 620F1CDA
P 3000 5025
F 0 "U600" H 3000 6800 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 3000 6625 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 3000 5025 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 3000 5025 50  0001 C CNN
	1    3000 5025
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 5625 1650 5625
Wire Wire Line
	2000 5825 1650 5825
Wire Wire Line
	2000 5925 1650 5925
Wire Wire Line
	2000 6025 1650 6025
Wire Wire Line
	2000 6125 1650 6125
Wire Wire Line
	2000 6225 1650 6225
Wire Wire Line
	2000 6325 1650 6325
Wire Wire Line
	2000 6425 1650 6425
Wire Wire Line
	2000 6525 1650 6525
Wire Wire Line
	2000 6625 1650 6625
Wire Wire Line
	2000 6825 1650 6825
Wire Wire Line
	2000 6725 1650 6725
Wire Wire Line
	4350 5625 4000 5625
Wire Wire Line
	4350 5725 4000 5725
Wire Wire Line
	4350 5825 4000 5825
Wire Wire Line
	4350 5925 4000 5925
Wire Wire Line
	4350 6025 4000 6025
Wire Wire Line
	4350 6125 4000 6125
Wire Wire Line
	4350 6225 4000 6225
Wire Wire Line
	4350 6325 4000 6325
Wire Wire Line
	4350 6425 4000 6425
Wire Wire Line
	4350 6525 4000 6525
Wire Wire Line
	4350 6625 4000 6625
Wire Wire Line
	4350 6725 4000 6725
Wire Wire Line
	4350 6925 4000 6925
Wire Wire Line
	4350 6825 4000 6825
Wire Wire Line
	4350 3925 4000 3925
Wire Wire Line
	4350 4025 4000 4025
Wire Wire Line
	4350 4125 4000 4125
Wire Wire Line
	4350 4225 4000 4225
Wire Wire Line
	4350 4325 4000 4325
Wire Wire Line
	4350 4425 4000 4425
Wire Wire Line
	4350 4525 4000 4525
Wire Wire Line
	4350 4725 4000 4725
Wire Wire Line
	4350 4825 4000 4825
Wire Wire Line
	4350 5025 4000 5025
Wire Wire Line
	4350 4925 4000 4925
Wire Wire Line
	2000 3725 1675 3725
Wire Wire Line
	2000 3825 1675 3825
Wire Wire Line
	2000 3925 1675 3925
Wire Wire Line
	2000 4225 1675 4225
Wire Wire Line
	2000 4425 1675 4425
Wire Wire Line
	2000 4525 1675 4525
Wire Wire Line
	2000 4625 1675 4625
Wire Wire Line
	2000 4725 1675 4725
Wire Wire Line
	2000 4825 1675 4825
Wire Wire Line
	2000 5025 1675 5025
Wire Wire Line
	2000 4925 1675 4925
Wire Wire Line
	2000 3325 1675 3325
Wire Wire Line
	2000 3425 1675 3425
Wire Wire Line
	2000 3525 1675 3525
Wire Wire Line
	2000 3625 1675 3625
Wire Wire Line
	4350 5225 4000 5225
Wire Wire Line
	4350 5325 4000 5325
Wire Wire Line
	4350 5425 4000 5425
Wire Wire Line
	4625 7225 4000 7225
Wire Wire Line
	4625 7325 4000 7325
Wire Wire Line
	4625 7425 4000 7425
Wire Wire Line
	4625 7525 4000 7525
$Comp
L Connector_Generic:Conn_01x06 CN1
U 1 1 6215B057
P 4825 7425
F 0 "CN1" H 4905 7417 50  0000 L CNN
F 1 "CPLD0" H 4905 7326 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 4825 7425 50  0001 C CNN
F 3 "~" H 4825 7425 50  0001 C CNN
	1    4825 7425
	1    0    0    -1  
$EndComp
Text Label 4625 7225 2    50   ~ 0
TDI0
Text Label 4625 7325 2    50   ~ 0
TMS0
Text Label 4625 7425 2    50   ~ 0
TCK0
Text Label 4625 7525 2    50   ~ 0
TDO0
Wire Wire Line
	2700 7825 2700 8175
Wire Wire Line
	2700 8175 2800 8175
Wire Wire Line
	4100 8175 4100 7625
Wire Wire Line
	4100 7625 4625 7625
Wire Wire Line
	3400 7825 3400 8175
Connection ~ 3400 8175
Wire Wire Line
	3400 8175 4100 8175
Wire Wire Line
	3300 7825 3300 8175
Wire Wire Line
	3200 7825 3200 8175
Wire Wire Line
	3100 7825 3100 8175
Wire Wire Line
	3000 7825 3000 8175
Wire Wire Line
	2900 7825 2900 8175
Wire Wire Line
	2800 7825 2800 8175
Connection ~ 3300 8175
Wire Wire Line
	3300 8175 3400 8175
Connection ~ 3200 8175
Wire Wire Line
	3200 8175 3300 8175
Connection ~ 3100 8175
Wire Wire Line
	3100 8175 3200 8175
Connection ~ 2800 8175
Wire Wire Line
	2800 8175 2900 8175
Connection ~ 2900 8175
Wire Wire Line
	2900 8175 3000 8175
Connection ~ 3000 8175
Wire Wire Line
	3000 8175 3100 8175
$Comp
L power:GND #PWR0155
U 1 1 621CFBA1
P 4100 8175
F 0 "#PWR0155" H 4100 7925 50  0001 C CNN
F 1 "GND" H 4105 8002 50  0000 C CNN
F 2 "" H 4100 8175 50  0001 C CNN
F 3 "" H 4100 8175 50  0001 C CNN
	1    4100 8175
	1    0    0    -1  
$EndComp
Connection ~ 4100 8175
Text Label 4625 7625 2    50   ~ 0
GND
Wire Wire Line
	4625 7725 4450 7725
Wire Wire Line
	4450 7725 4450 8175
Wire Wire Line
	4450 8175 4275 8175
$Comp
L power:+3.3V #PWR0172
U 1 1 621D5095
P 4275 8175
F 0 "#PWR0172" H 4275 8025 50  0001 C CNN
F 1 "+3.3V" H 4290 8348 50  0000 C CNN
F 2 "" H 4275 8175 50  0001 C CNN
F 3 "" H 4275 8175 50  0001 C CNN
	1    4275 8175
	1    0    0    -1  
$EndComp
Text Label 4625 7725 2    50   ~ 0
3.3V
$Comp
L CPLD_Xilinx:XC9572XL-TQ100 U601
U 1 1 62219218
P 7650 5025
F 0 "U601" H 7650 6800 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 7650 6625 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 7650 5025 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 7650 5025 50  0001 C CNN
	1    7650 5025
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 5525 6300 5525
Wire Wire Line
	6650 5625 6300 5625
Wire Wire Line
	6650 5725 6300 5725
Wire Wire Line
	6650 5825 6300 5825
Wire Wire Line
	6650 5925 6300 5925
Wire Wire Line
	6650 6025 6300 6025
Wire Wire Line
	6650 6125 6300 6125
Wire Wire Line
	6650 6225 6300 6225
Wire Wire Line
	6650 6325 6300 6325
Wire Wire Line
	6650 6425 6300 6425
Wire Wire Line
	6650 6525 6300 6525
Wire Wire Line
	6650 6625 6300 6625
Wire Wire Line
	6650 6825 6300 6825
Wire Wire Line
	6650 6725 6300 6725
Wire Wire Line
	9000 5625 8650 5625
Wire Wire Line
	9000 5725 8650 5725
Wire Wire Line
	9000 5825 8650 5825
Wire Wire Line
	9000 5925 8650 5925
Wire Wire Line
	9000 6025 8650 6025
Wire Wire Line
	9000 6125 8650 6125
Wire Wire Line
	9000 6225 8650 6225
Wire Wire Line
	9000 6325 8650 6325
Wire Wire Line
	9000 6425 8650 6425
Wire Wire Line
	9000 6525 8650 6525
Wire Wire Line
	9000 6625 8650 6625
Wire Wire Line
	9000 6725 8650 6725
Wire Wire Line
	9000 6925 8650 6925
Wire Wire Line
	9000 6825 8650 6825
Wire Wire Line
	9400 3725 8650 3725
Wire Wire Line
	9400 3825 8650 3825
Wire Wire Line
	9400 3925 8650 3925
Wire Wire Line
	9400 4025 8650 4025
Wire Wire Line
	9400 4125 8650 4125
Wire Wire Line
	9400 4225 8650 4225
Wire Wire Line
	9400 4325 8650 4325
Wire Wire Line
	9400 4425 8650 4425
Wire Wire Line
	9400 4525 8650 4525
Wire Wire Line
	9400 4625 8650 4625
Wire Wire Line
	9400 4725 8650 4725
Wire Wire Line
	9400 4825 8650 4825
Wire Wire Line
	9400 5025 8650 5025
Wire Wire Line
	9400 4925 8650 4925
Wire Wire Line
	6650 3725 6300 3725
Wire Wire Line
	6650 3825 6300 3825
Wire Wire Line
	6650 3925 6300 3925
Wire Wire Line
	6650 4025 6300 4025
Wire Wire Line
	6650 4425 6300 4425
Wire Wire Line
	6650 4525 6300 4525
Wire Wire Line
	6650 4625 6300 4625
Wire Wire Line
	6650 4725 6300 4725
Wire Wire Line
	6650 4825 6300 4825
Wire Wire Line
	6650 5025 6300 5025
Wire Wire Line
	6650 4925 6300 4925
Wire Wire Line
	9400 3325 8650 3325
Wire Wire Line
	9400 3425 8650 3425
Wire Wire Line
	9400 3525 8650 3525
Wire Wire Line
	9400 3625 8650 3625
Wire Wire Line
	6650 3325 6300 3325
Wire Wire Line
	6650 3425 6300 3425
Wire Wire Line
	6650 3525 6300 3525
Wire Wire Line
	6650 3625 6300 3625
Wire Wire Line
	9550 5225 8650 5225
Wire Wire Line
	9550 5325 8650 5325
Wire Wire Line
	9550 5425 8650 5425
Wire Wire Line
	9550 5525 8650 5525
Wire Wire Line
	9275 7225 8650 7225
Wire Wire Line
	9275 7325 8650 7325
Wire Wire Line
	9275 7425 8650 7425
Wire Wire Line
	9275 7525 8650 7525
Text Label 9275 7225 2    50   ~ 0
TDI1
Text Label 9275 7325 2    50   ~ 0
TMS1
Text Label 9275 7425 2    50   ~ 0
TCK1
Text Label 9275 7525 2    50   ~ 0
TDO1
Wire Wire Line
	7350 7825 7350 8175
Wire Wire Line
	7350 8175 7450 8175
Wire Wire Line
	8750 8175 8750 7625
Wire Wire Line
	8750 7625 9275 7625
Wire Wire Line
	8050 7825 8050 8175
Connection ~ 8050 8175
Wire Wire Line
	8050 8175 8750 8175
Wire Wire Line
	7950 7825 7950 8175
Wire Wire Line
	7850 7825 7850 8175
Wire Wire Line
	7750 7825 7750 8175
Wire Wire Line
	7650 7825 7650 8175
Wire Wire Line
	7550 7825 7550 8175
Wire Wire Line
	7450 7825 7450 8175
Connection ~ 7950 8175
Wire Wire Line
	7950 8175 8050 8175
Connection ~ 7850 8175
Wire Wire Line
	7850 8175 7950 8175
Connection ~ 7750 8175
Wire Wire Line
	7750 8175 7850 8175
Connection ~ 7450 8175
Wire Wire Line
	7450 8175 7550 8175
Connection ~ 7550 8175
Wire Wire Line
	7550 8175 7650 8175
Connection ~ 7650 8175
Wire Wire Line
	7650 8175 7750 8175
$Comp
L power:GND #PWR0173
U 1 1 62219287
P 8750 8175
F 0 "#PWR0173" H 8750 7925 50  0001 C CNN
F 1 "GND" H 8755 8002 50  0000 C CNN
F 2 "" H 8750 8175 50  0001 C CNN
F 3 "" H 8750 8175 50  0001 C CNN
	1    8750 8175
	1    0    0    -1  
$EndComp
Connection ~ 8750 8175
Text Label 9275 7625 2    50   ~ 0
GND
Wire Wire Line
	9275 7725 9100 7725
Wire Wire Line
	9100 7725 9100 8175
Wire Wire Line
	9100 8175 8925 8175
$Comp
L power:+3.3V #PWR0174
U 1 1 62219292
P 8925 8175
F 0 "#PWR0174" H 8925 8025 50  0001 C CNN
F 1 "+3.3V" H 8940 8348 50  0000 C CNN
F 2 "" H 8925 8175 50  0001 C CNN
F 3 "" H 8925 8175 50  0001 C CNN
	1    8925 8175
	1    0    0    -1  
$EndComp
Text Label 9275 7725 2    50   ~ 0
3.3V
$Comp
L Connector_Generic:Conn_01x06 CN2
U 1 1 62227388
P 9475 7425
F 0 "CN2" H 9555 7417 50  0000 L CNN
F 1 "CPLD1" H 9555 7326 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 9475 7425 50  0001 C CNN
F 3 "~" H 9475 7425 50  0001 C CNN
	1    9475 7425
	1    0    0    -1  
$EndComp
Text Label 9275 3325 0    50   ~ 0
A0
Text Label 9275 3425 0    50   ~ 0
A1
Text Label 9275 3525 0    50   ~ 0
A2
Text Label 9275 3625 0    50   ~ 0
A3
Text Label 9275 3725 0    50   ~ 0
A4
Text Label 9275 3825 0    50   ~ 0
A5
Text Label 9275 3925 0    50   ~ 0
A6
Text Label 9275 4025 0    50   ~ 0
A13
Text Label 9275 4125 0    50   ~ 0
A14
Text Label 9275 4225 0    50   ~ 0
A15
Text Label 9275 4325 0    50   ~ 0
A16
Text Label 9275 4425 0    50   ~ 0
A17
Text Label 9275 4525 0    50   ~ 0
A18
Text Label 9275 4625 0    50   ~ 0
A19
Text Label 9275 4725 0    50   ~ 0
A20
Text Label 9275 4825 0    50   ~ 0
A21
Text Label 9275 4925 0    50   ~ 0
A22
Text Label 9275 5025 0    50   ~ 0
A23
Text Label 9275 5225 0    50   ~ 0
D28
Text Label 9275 5325 0    50   ~ 0
D29
Text Label 9275 5425 0    50   ~ 0
D30
Text Label 9275 5525 0    50   ~ 0
D31
Text GLabel 1675 3325 0    50   Input ~ 0
_AS
Text GLabel 1675 3425 0    50   Input ~ 0
AR_W
Text GLabel 1675 3525 0    50   Output ~ 0
R_W
Text GLabel 1675 3625 0    50   Input ~ 0
_ABG
Text GLabel 1675 3725 0    50   Input ~ 0
_ABGACK
Text GLabel 1675 3825 0    50   Input ~ 0
_ASEN
Text GLabel 1675 3925 0    50   Output ~ 0
_AAS
Text GLabel 1675 4225 0    50   Output ~ 0
_ABR
Text GLabel 1675 4425 0    50   Output ~ 0
_ASDELAY
Text GLabel 1675 4525 0    50   Output ~ 0
_DSEN
Text GLabel 4350 6925 2    50   Input ~ 0
_HALT
Text GLabel 4350 6525 2    50   Input ~ 0
B2000
Text GLabel 4350 6425 2    50   Input ~ 0
MODE68K
Text GLabel 4350 5225 2    50   Input ~ 0
FC2
Text GLabel 4350 5325 2    50   Input ~ 0
FC1
Text GLabel 4350 5425 2    50   Input ~ 0
FC0
Text GLabel 4350 6325 2    50   Input ~ 0
EXTSEL
Text GLabel 4350 6125 2    50   Input ~ 0
JMODE
Text GLabel 4350 4125 2    50   Input ~ 0
_STERM
Text GLabel 1650 5825 0    50   Input ~ 0
A7M
Text GLabel 1650 5925 0    50   Input ~ 0
_C1
Text GLabel 1650 6025 0    50   Input ~ 0
_C3
Text GLabel 1650 6125 0    50   Input ~ 0
CDAC
Text GLabel 4350 6225 2    50   Input ~ 0
_VPA
Text GLabel 1675 4625 0    50   Input ~ 0
MEMACCESS
Text GLabel 1675 4725 0    50   Input ~ 0
CONFIGED
Text GLabel 4350 6725 2    50   Input ~ 0
RESENB
Text GLabel 1650 6225 0    50   Input ~ 0
CPUCLK_A
Text GLabel 1675 4825 0    50   Input ~ 0
_UDS
Text GLabel 1675 4925 0    50   Input ~ 0
_LDS
Text GLabel 1650 6325 0    50   Output ~ 0
7M
Text GLabel 1650 6425 0    50   Output ~ 0
_7M
Text GLabel 1650 6525 0    50   Output ~ 0
SCLK
Text GLabel 1650 6625 0    50   Output ~ 0
SN7MDIS
Text GLabel 1650 6725 0    50   Output ~ 0
_S7MDIS
Text GLabel 1650 6825 0    50   Output ~ 0
DSCLK
Text GLabel 1650 5625 0    50   Output ~ 0
IPLCLK
Text GLabel 4350 4725 2    50   Output ~ 0
_DSACKDIS
Text GLabel 4350 4525 2    50   Output ~ 0
_REGRESET
Text GLabel 4350 4425 2    50   Output ~ 0
_BGDIS
Text GLabel 4350 4325 2    50   Output ~ 0
_DSACK0
Text GLabel 4350 4225 2    50   Output ~ 0
_DSACK1
Text GLabel 1675 5025 0    50   Output ~ 0
_BGACK
Text GLabel 4350 4025 2    50   Output ~ 0
_CYCEND
Text GLabel 4350 3925 2    50   Output ~ 0
_MEMSEL
Text GLabel 4350 4825 2    50   Output ~ 0
E
Text GLabel 4350 4925 2    50   Output ~ 0
_DSACKEN
Text GLabel 4350 5025 2    50   Input ~ 0
_ONBOARD
Text GLabel 4350 6625 2    50   Output ~ 0
_CPURESET
Text GLabel 4350 6825 2    50   Output ~ 0
_RESET
Text GLabel 4350 5625 2    50   Output ~ 0
_IVMA
Text GLabel 4350 5725 2    50   Output ~ 0
_EXTERN
Text GLabel 4350 5825 2    50   Output ~ 0
_DTACK
Text GLabel 4350 5925 2    50   Output ~ 0
TRISTATE
Text GLabel 4350 6025 2    50   Output ~ 0
_BOSS
NoConn ~ 4000 3325
NoConn ~ 2000 6925
NoConn ~ 2000 5725
NoConn ~ 2000 5525
NoConn ~ 2000 5425
NoConn ~ 2000 5325
NoConn ~ 2000 5225
NoConn ~ 2000 4325
NoConn ~ 2000 4125
NoConn ~ 2000 4025
Entry Wire Line
	9400 5025 9500 4925
Text GLabel 15500 1175 2    50   Input ~ 0
A[31..0]
Entry Wire Line
	9400 4625 9500 4525
Entry Wire Line
	9400 4525 9500 4425
Entry Wire Line
	9400 4425 9500 4325
Entry Wire Line
	9400 4325 9500 4225
Entry Wire Line
	9400 4225 9500 4125
Entry Wire Line
	9400 4125 9500 4025
Entry Wire Line
	9400 4025 9500 3925
Entry Wire Line
	9400 3925 9500 3825
Entry Wire Line
	9400 3825 9500 3725
Entry Wire Line
	9400 3725 9500 3625
Entry Wire Line
	9400 3625 9500 3525
Entry Wire Line
	9400 3525 9500 3425
Entry Wire Line
	9400 3425 9500 3325
Entry Wire Line
	9400 3325 9500 3225
Entry Wire Line
	9400 4925 9500 4825
Entry Wire Line
	9400 4825 9500 4725
Entry Wire Line
	9400 4725 9500 4625
Entry Wire Line
	9550 5525 9650 5425
Entry Wire Line
	9550 5425 9650 5325
Entry Wire Line
	9550 5325 9650 5225
Entry Wire Line
	9550 5225 9650 5125
Text GLabel 15500 1400 2    50   BiDi ~ 0
D[31..0]
Text GLabel 9000 5625 2    50   Input ~ 0
FC2
Text GLabel 9000 5725 2    50   Input ~ 0
FC1
Text GLabel 9000 5825 2    50   Input ~ 0
FC0
Text GLabel 9000 5925 2    50   Input ~ 0
SIZ0
Text GLabel 9000 6025 2    50   Input ~ 0
SIZ1
Text GLabel 9000 6125 2    50   Output ~ 0
_FPUCS
Text GLabel 9000 6225 2    50   Output ~ 0
_BERR
Text GLabel 6300 6125 0    50   Input ~ 0
CPUCLK_A
Text GLabel 6300 6225 0    50   Input ~ 0
PHANTOMHI
Text GLabel 6300 6325 0    50   Input ~ 0
PHANTOMLO
Text GLabel 6300 6825 0    50   Output ~ 0
_CIIN
Text GLabel 9000 6425 2    50   Input ~ 0
_AS
Text GLabel 9000 6525 2    50   Input ~ 0
_DS
Text GLabel 9000 6625 2    50   Input ~ 0
R_W
Text GLabel 9000 6825 2    50   Input ~ 0
_SENSE
Text GLabel 9000 6725 2    50   Input ~ 0
_BGACK
Text GLabel 9000 6925 2    50   Output ~ 0
_CSROM
Text GLabel 6300 6525 0    50   Input ~ 0
OSMODE
Text GLabel 6300 4525 0    50   Input ~ 0
AUTO
Text GLabel 6300 4425 0    50   Input ~ 0
TWOMB
Text GLabel 6300 5725 0    50   Input ~ 0
_EXTERN
Text GLabel 6300 5825 0    50   Input ~ 0
_CYCEND
Text GLabel 6300 5525 0    50   Input ~ 0
_DSEN
Text GLabel 6300 5625 0    50   Input ~ 0
_ASEN
Text GLabel 6300 4725 0    50   Input ~ 0
TRISTATE
Text GLabel 6300 6625 0    50   Output ~ 0
_ONBOARD
Text GLabel 6300 6725 0    50   Input ~ 0
_MEMSEL
Text GLabel 6300 3325 0    50   Output ~ 0
_OE0
Text GLabel 6300 3425 0    50   Output ~ 0
_OE1
Text GLabel 6300 3525 0    50   Output ~ 0
_WE0
Text GLabel 6300 3625 0    50   Output ~ 0
_WE1
Text GLabel 6300 3725 0    50   Output ~ 0
_UUBE
Text GLabel 6300 4025 0    50   Output ~ 0
_LLBE
Text GLabel 6300 3825 0    50   Output ~ 0
_UMBE
Text GLabel 6300 3925 0    50   Output ~ 0
_LMBE
Text GLabel 4350 3825 2    50   Output ~ 0
_OVR
Text GLabel 6300 4625 0    50   Output ~ 0
CONFIGED
Text GLabel 6300 4825 0    50   Output ~ 0
ROMCLK
Text GLabel 6300 4925 0    50   Output ~ 0
_UDS
Text GLabel 6300 5025 0    50   Output ~ 0
_LDS
Text GLabel 6300 6425 0    50   Input ~ 0
_RESET
Text GLabel 6300 5925 0    50   Output ~ 0
_AVEC
Text GLabel 6300 6025 0    50   Output ~ 0
_MEMLOCK
Text GLabel 9000 6325 2    50   Output ~ 0
AR_W
NoConn ~ 6650 5425
NoConn ~ 6650 5325
NoConn ~ 6650 5225
NoConn ~ 6650 4125
NoConn ~ 6650 4325
NoConn ~ 6650 6925
Text Notes 13450 9675 2    236  ~ 0
CPLDs
Wire Wire Line
	7350 2325 7350 2050
Wire Wire Line
	7950 2325 7950 2050
Wire Wire Line
	7950 2050 7850 2050
Connection ~ 7350 2050
Wire Wire Line
	7350 2050 7350 1750
Wire Wire Line
	7850 2325 7850 2050
Connection ~ 7850 2050
Wire Wire Line
	7850 2050 7750 2050
Wire Wire Line
	7750 2325 7750 2050
Connection ~ 7750 2050
Wire Wire Line
	7750 2050 7650 2050
Wire Wire Line
	7650 2325 7650 2050
Connection ~ 7650 2050
Wire Wire Line
	7650 2050 7550 2050
Wire Wire Line
	7550 2325 7550 2050
Connection ~ 7550 2050
Wire Wire Line
	7550 2050 7450 2050
Wire Wire Line
	7450 2325 7450 2050
Connection ~ 7450 2050
Wire Wire Line
	7450 2050 7350 2050
$Comp
L power:+3.3V #PWR0175
U 1 1 62B40651
P 7350 1750
F 0 "#PWR0175" H 7350 1600 50  0001 C CNN
F 1 "+3.3V" H 7365 1923 50  0000 C CNN
F 2 "" H 7350 1750 50  0001 C CNN
F 3 "" H 7350 1750 50  0001 C CNN
	1    7350 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	2700 2325 2700 2050
Wire Wire Line
	3300 2325 3300 2050
Wire Wire Line
	3300 2050 3200 2050
Connection ~ 2700 2050
Wire Wire Line
	2700 2050 2700 1750
Wire Wire Line
	3200 2325 3200 2050
Connection ~ 3200 2050
Wire Wire Line
	3200 2050 3100 2050
Wire Wire Line
	3100 2325 3100 2050
Connection ~ 3100 2050
Wire Wire Line
	3100 2050 3000 2050
Wire Wire Line
	3000 2325 3000 2050
Connection ~ 3000 2050
Wire Wire Line
	3000 2050 2900 2050
Wire Wire Line
	2900 2325 2900 2050
Connection ~ 2900 2050
Wire Wire Line
	2900 2050 2800 2050
Wire Wire Line
	2800 2325 2800 2050
Connection ~ 2800 2050
Wire Wire Line
	2800 2050 2700 2050
$Comp
L power:+3.3V #PWR0176
U 1 1 62B427B6
P 2700 1750
F 0 "#PWR0176" H 2700 1600 50  0001 C CNN
F 1 "+3.3V" H 2715 1923 50  0000 C CNN
F 2 "" H 2700 1750 50  0001 C CNN
F 3 "" H 2700 1750 50  0001 C CNN
	1    2700 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3825 4350 3825
NoConn ~ 6650 4225
$Comp
L CPLD_Xilinx:XC9572XL-TQ100 U602
U 1 1 6284DBB1
P 12625 5025
F 0 "U602" H 12625 6800 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 12625 6625 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 12625 5025 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 12625 5025 50  0001 C CNN
	1    12625 5025
	1    0    0    -1  
$EndComp
Wire Wire Line
	11625 5525 11275 5525
Wire Wire Line
	11625 5625 11275 5625
Wire Wire Line
	11625 5725 11275 5725
Wire Wire Line
	11625 5825 11275 5825
Wire Wire Line
	11625 5925 11275 5925
Wire Wire Line
	11625 6025 11275 6025
Wire Wire Line
	11625 6125 11275 6125
Wire Wire Line
	11625 6325 11275 6325
Wire Wire Line
	11625 6425 11275 6425
Wire Wire Line
	11625 6525 11275 6525
Wire Wire Line
	11625 6625 11275 6625
Wire Wire Line
	11625 6825 11275 6825
Wire Wire Line
	11625 6725 11275 6725
Wire Wire Line
	13975 5925 13625 5925
Wire Wire Line
	13975 6025 13625 6025
Wire Wire Line
	13975 6125 13625 6125
Wire Wire Line
	13975 6225 13625 6225
Wire Wire Line
	13975 6325 13625 6325
Wire Wire Line
	13975 6425 13625 6425
Wire Wire Line
	13975 6525 13625 6525
Wire Wire Line
	13975 6625 13625 6625
Wire Wire Line
	13975 6725 13625 6725
Wire Wire Line
	13975 6925 13625 6925
Wire Wire Line
	13975 6825 13625 6825
Wire Wire Line
	14375 3725 13625 3725
Wire Wire Line
	14375 3825 13625 3825
Wire Wire Line
	14375 3925 13625 3925
Wire Wire Line
	14375 4025 13625 4025
Wire Wire Line
	14375 4125 13625 4125
Wire Wire Line
	14375 4225 13625 4225
Wire Wire Line
	14375 4325 13625 4325
Wire Wire Line
	14375 4425 13625 4425
Wire Wire Line
	14375 4525 13625 4525
Wire Wire Line
	14375 4625 13625 4625
Wire Wire Line
	14375 4725 13625 4725
Wire Wire Line
	14375 4825 13625 4825
Wire Wire Line
	14375 5025 13625 5025
Wire Wire Line
	14375 4925 13625 4925
Wire Wire Line
	11625 3725 11275 3725
Wire Wire Line
	11625 3825 11275 3825
Wire Wire Line
	11625 3925 11275 3925
Wire Wire Line
	11625 4525 11275 4525
Wire Wire Line
	11625 4625 11275 4625
Wire Wire Line
	11625 4725 11275 4725
Wire Wire Line
	11625 4825 11275 4825
Wire Wire Line
	11625 5025 11275 5025
Wire Wire Line
	11625 4925 11275 4925
Wire Wire Line
	14375 3325 13625 3325
Wire Wire Line
	14375 3425 13625 3425
Wire Wire Line
	14375 3525 13625 3525
Wire Wire Line
	14375 3625 13625 3625
Wire Wire Line
	11625 3325 11275 3325
Wire Wire Line
	11625 3425 11275 3425
Wire Wire Line
	11625 3525 11275 3525
Wire Wire Line
	14250 7225 13625 7225
Wire Wire Line
	14250 7325 13625 7325
Wire Wire Line
	14250 7425 13625 7425
Wire Wire Line
	14250 7525 13625 7525
Text Label 14250 7225 2    50   ~ 0
TDI1
Text Label 14250 7325 2    50   ~ 0
TMS1
Text Label 14250 7425 2    50   ~ 0
TCK1
Text Label 14250 7525 2    50   ~ 0
TDO1
Wire Wire Line
	12325 7825 12325 8175
Wire Wire Line
	12325 8175 12425 8175
Wire Wire Line
	13725 8175 13725 7625
Wire Wire Line
	13725 7625 14250 7625
Wire Wire Line
	13025 7825 13025 8175
Connection ~ 13025 8175
Wire Wire Line
	13025 8175 13725 8175
Wire Wire Line
	12925 7825 12925 8175
Wire Wire Line
	12825 7825 12825 8175
Wire Wire Line
	12725 7825 12725 8175
Wire Wire Line
	12625 7825 12625 8175
Wire Wire Line
	12525 7825 12525 8175
Wire Wire Line
	12425 7825 12425 8175
Connection ~ 12925 8175
Wire Wire Line
	12925 8175 13025 8175
Connection ~ 12825 8175
Wire Wire Line
	12825 8175 12925 8175
Connection ~ 12725 8175
Wire Wire Line
	12725 8175 12825 8175
Connection ~ 12425 8175
Wire Wire Line
	12425 8175 12525 8175
Connection ~ 12525 8175
Wire Wire Line
	12525 8175 12625 8175
Connection ~ 12625 8175
Wire Wire Line
	12625 8175 12725 8175
$Comp
L power:GND #PWR0178
U 1 1 6284DC19
P 13725 8175
F 0 "#PWR0178" H 13725 7925 50  0001 C CNN
F 1 "GND" H 13730 8002 50  0000 C CNN
F 2 "" H 13725 8175 50  0001 C CNN
F 3 "" H 13725 8175 50  0001 C CNN
	1    13725 8175
	1    0    0    -1  
$EndComp
Connection ~ 13725 8175
Text Label 14250 7625 2    50   ~ 0
GND
Wire Wire Line
	14250 7725 14075 7725
Wire Wire Line
	14075 7725 14075 8175
Wire Wire Line
	14075 8175 13900 8175
$Comp
L power:+3.3V #PWR0179
U 1 1 6284DC24
P 13900 8175
F 0 "#PWR0179" H 13900 8025 50  0001 C CNN
F 1 "+3.3V" H 13915 8348 50  0000 C CNN
F 2 "" H 13900 8175 50  0001 C CNN
F 3 "" H 13900 8175 50  0001 C CNN
	1    13900 8175
	1    0    0    -1  
$EndComp
Text Label 14250 7725 2    50   ~ 0
3.3V
$Comp
L Connector_Generic:Conn_01x06 CN3
U 1 1 6284DC2B
P 14450 7425
F 0 "CN3" H 14530 7417 50  0000 L CNN
F 1 "CPLD1" H 14530 7326 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 14450 7425 50  0001 C CNN
F 3 "~" H 14450 7425 50  0001 C CNN
	1    14450 7425
	1    0    0    -1  
$EndComp
Text Label 14250 3325 0    50   ~ 0
A0
Text Label 14250 3425 0    50   ~ 0
A1
Text Label 14250 3525 0    50   ~ 0
A2
Text Label 14250 3625 0    50   ~ 0
A3
Text Label 14250 3725 0    50   ~ 0
A4
Text Label 14250 3825 0    50   ~ 0
A5
Text Label 14250 3925 0    50   ~ 0
A6
Text Label 14250 4025 0    50   ~ 0
A7
Text Label 14250 4125 0    50   ~ 0
A8
Text Label 14250 4225 0    50   ~ 0
A9
Text Label 14250 4325 0    50   ~ 0
A10
Text Label 14250 4425 0    50   ~ 0
A11
Text Label 14250 4525 0    50   ~ 0
A12
Text Label 14250 4625 0    50   ~ 0
A13
Text Label 14250 4825 0    50   ~ 0
A15
Text Label 14250 4925 0    50   ~ 0
A16
Text Label 14250 5025 0    50   ~ 0
A17
Entry Wire Line
	14375 5025 14475 4925
Entry Wire Line
	14375 4625 14475 4525
Entry Wire Line
	14375 4525 14475 4425
Entry Wire Line
	14375 4425 14475 4325
Entry Wire Line
	14375 4325 14475 4225
Entry Wire Line
	14375 4225 14475 4125
Entry Wire Line
	14375 4125 14475 4025
Entry Wire Line
	14375 4025 14475 3925
Entry Wire Line
	14375 3925 14475 3825
Entry Wire Line
	14375 3825 14475 3725
Entry Wire Line
	14375 3725 14475 3625
Entry Wire Line
	14375 3625 14475 3525
Entry Wire Line
	14375 3525 14475 3425
Entry Wire Line
	14375 3425 14475 3325
Entry Wire Line
	14375 3325 14475 3225
Entry Wire Line
	14375 4925 14475 4825
Entry Wire Line
	14375 4825 14475 4725
Entry Wire Line
	14375 4725 14475 4625
Wire Wire Line
	12325 2325 12325 2050
Wire Wire Line
	12925 2325 12925 2050
Wire Wire Line
	12925 2050 12825 2050
Connection ~ 12325 2050
Wire Wire Line
	12325 2050 12325 1750
Wire Wire Line
	12825 2325 12825 2050
Connection ~ 12825 2050
Wire Wire Line
	12825 2050 12725 2050
Wire Wire Line
	12725 2325 12725 2050
Connection ~ 12725 2050
Wire Wire Line
	12725 2050 12625 2050
Wire Wire Line
	12625 2325 12625 2050
Connection ~ 12625 2050
Wire Wire Line
	12625 2050 12525 2050
Wire Wire Line
	12525 2325 12525 2050
Connection ~ 12525 2050
Wire Wire Line
	12525 2050 12425 2050
Wire Wire Line
	12425 2325 12425 2050
Connection ~ 12425 2050
Wire Wire Line
	12425 2050 12325 2050
$Comp
L power:+3.3V #PWR0180
U 1 1 6284DC81
P 12325 1750
F 0 "#PWR0180" H 12325 1600 50  0001 C CNN
F 1 "+3.3V" H 12340 1923 50  0000 C CNN
F 2 "" H 12325 1750 50  0001 C CNN
F 3 "" H 12325 1750 50  0001 C CNN
	1    12325 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	14375 5825 13625 5825
Wire Wire Line
	14375 5225 13625 5225
Wire Wire Line
	14375 5325 13625 5325
Wire Wire Line
	14375 5425 13625 5425
Wire Wire Line
	14375 5525 13625 5525
Wire Wire Line
	14375 5725 13625 5725
Wire Wire Line
	14375 5625 13625 5625
Text Label 14250 5825 0    50   ~ 0
A24
Text Label 14250 5225 0    50   ~ 0
A18
Text Label 14250 5325 0    50   ~ 0
A19
Text Label 14250 5425 0    50   ~ 0
A20
Text Label 14250 5525 0    50   ~ 0
A21
Text Label 14250 5625 0    50   ~ 0
A22
Text Label 14250 5725 0    50   ~ 0
A23
Entry Wire Line
	14375 5725 14475 5625
Entry Wire Line
	14375 5325 14475 5225
Entry Wire Line
	14375 5225 14475 5125
Entry Wire Line
	14375 5825 14475 5725
Entry Wire Line
	14375 5625 14475 5525
Entry Wire Line
	14375 5525 14475 5425
Entry Wire Line
	14375 5425 14475 5325
Text Label 14250 4725 0    50   ~ 0
A14
Entry Bus Bus
	14475 1275 14575 1175
Text GLabel 11275 3325 0    50   Input ~ 0
R_W
Text GLabel 11275 3425 0    50   Input ~ 0
_AS
Text GLabel 11275 3525 0    50   Input ~ 0
_DS
Text Label 11275 6825 0    50   ~ 0
EMA0
Text Label 11275 6725 0    50   ~ 0
EMA1
Text Label 11275 6625 0    50   ~ 0
EMA2
Text Label 11275 6525 0    50   ~ 0
EMA3
Text Label 11275 6425 0    50   ~ 0
EMA4
Text Label 11275 6325 0    50   ~ 0
EMA5
Text Label 11275 6225 0    50   ~ 0
EMA6
Text Label 11275 6125 0    50   ~ 0
EMA7
Text Label 11275 6025 0    50   ~ 0
EMA8
Text Label 11275 5925 0    50   ~ 0
EMA9
Text Label 11275 5825 0    50   ~ 0
EMA10
Text Label 11275 5725 0    50   ~ 0
EMA11
Text Label 11275 5625 0    50   ~ 0
EMA12
Entry Wire Line
	11275 5625 11175 5725
Entry Wire Line
	11275 5725 11175 5825
Entry Wire Line
	11275 5825 11175 5925
Entry Wire Line
	11275 5925 11175 6025
Entry Wire Line
	11275 6025 11175 6125
Entry Wire Line
	11275 6125 11175 6225
Entry Wire Line
	11275 6225 11175 6325
Wire Wire Line
	11275 6225 11625 6225
Entry Wire Line
	11275 6325 11175 6425
Entry Wire Line
	11275 6425 11175 6525
Entry Wire Line
	11275 6525 11175 6625
Entry Wire Line
	11275 6625 11175 6725
Entry Wire Line
	11275 6725 11175 6825
Entry Wire Line
	11275 6825 11175 6925
Wire Bus Line
	11175 8750 15300 8750
Text GLabel 15300 8750 2    50   Output ~ 0
EMA[12..0]
Text GLabel 13975 5925 2    50   Output ~ 0
EM0B0
Text GLabel 13975 6025 2    50   Output ~ 0
EM0B1
Text GLabel 13975 6125 2    50   Output ~ 0
EM1B0
Text GLabel 13975 6225 2    50   Output ~ 0
EM1B1
Text GLabel 13975 6325 2    50   Output ~ 0
_RAS0
Text GLabel 13975 6425 2    50   Output ~ 0
_RAS1
Text GLabel 13975 6525 2    50   Output ~ 0
_CAS0
Text GLabel 13975 6625 2    50   Output ~ 0
_CAS1
Text GLabel 13975 6725 2    50   Output ~ 0
EM0R_W
Text GLabel 13975 6825 2    50   Output ~ 0
EM1R_W
Text GLabel 13975 6925 2    50   Output ~ 0
_CSEM0
Text GLabel 11275 5525 0    50   Output ~ 0
_CSEM1
Text GLabel 11275 5025 0    50   Output ~ 0
EM0CLKE
Text GLabel 11275 4925 0    50   Output ~ 0
EM1CLKE
Text GLabel 11275 4825 0    50   Output ~ 0
_EM0LLBE
Text GLabel 11275 4725 0    50   Output ~ 0
_EM0LMBE
Text GLabel 11275 4625 0    50   Output ~ 0
_EM0UMBE
Text GLabel 11275 4525 0    50   Output ~ 0
_EM0UUBE
Text GLabel 11275 3925 0    50   Output ~ 0
_EM1LLBE
Text GLabel 11275 3825 0    50   Output ~ 0
_EM1LMBE
Text GLabel 11275 3725 0    50   Output ~ 0
_EM1UMBE
Text GLabel 11275 3625 0    50   Output ~ 0
_EM1UUBE
Wire Wire Line
	11625 3625 11275 3625
Text GLabel 4350 3725 2    50   Output ~ 0
_ADOEH
Text GLabel 4350 3625 2    50   Output ~ 0
_ADOEL
Wire Wire Line
	4350 3725 4000 3725
Wire Wire Line
	4000 3625 4350 3625
Wire Wire Line
	4900 4625 4000 4625
Entry Wire Line
	4900 4625 5000 4525
Wire Bus Line
	5000 4525 5000 1175
Entry Bus Bus
	9600 1175 9500 1275
Text Label 4900 4625 2    50   ~ 0
A1
Text GLabel 4350 3525 2    50   Output ~ 0
ADDIR
Wire Wire Line
	4350 3525 4000 3525
Wire Wire Line
	4000 3425 4350 3425
Text GLabel 4350 3425 2    50   Output ~ 0
DRSEL
Text Notes 12275 9175 0    118  ~ 0
The Big Banana TPIR
Wire Wire Line
	11625 4425 11275 4425
Text GLabel 11275 4425 0    50   Output ~ 0
EXTSEL
Text GLabel 11275 5425 0    50   Output ~ 0
_CBACK
Text GLabel 11275 5325 0    50   Input ~ 0
_CBREQ
Wire Wire Line
	11625 5425 11275 5425
Wire Wire Line
	11275 5325 11625 5325
Wire Wire Line
	11625 5225 11275 5225
Text GLabel 11275 5225 0    50   Input ~ 0
_RESET
Wire Wire Line
	11625 4025 10600 4025
Wire Wire Line
	11625 4125 10600 4125
Wire Wire Line
	11625 4225 10600 4225
Wire Wire Line
	11625 4325 10600 4325
Entry Wire Line
	10600 4325 10500 4225
Entry Wire Line
	10600 4225 10500 4125
Entry Wire Line
	10600 4125 10500 4025
Entry Wire Line
	10600 4025 10500 3925
Entry Bus Bus
	10500 1500 10600 1400
Text Label 10600 4025 0    50   ~ 0
D28
Text Label 10600 4125 0    50   ~ 0
D29
Text Label 10600 4225 0    50   ~ 0
D30
Text Label 10600 4325 0    50   ~ 0
D31
Text GLabel 11000 7125 0    51   Input ~ 0
Z3AUTO
Wire Wire Line
	11000 7125 11625 7125
Wire Wire Line
	11625 7125 11625 6925
Wire Wire Line
	4000 5525 4350 5525
Text GLabel 4350 5525 2    50   Output ~ 0
AS
$Comp
L Device:C C600
U 1 1 62EECB09
P 2800 9375
F 0 "C600" H 2700 9625 50  0000 L CNN
F 1 "0.01uF" H 2700 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 2838 9225 50  0001 C CNN
F 3 "~" H 2800 9375 50  0001 C CNN
	1    2800 9375
	1    0    0    -1  
$EndComp
$Comp
L Device:C C601
U 1 1 62F1114F
P 3100 9375
F 0 "C601" H 3000 9625 50  0000 L CNN
F 1 "0.1uF" H 3000 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 3138 9225 50  0001 C CNN
F 3 "~" H 3100 9375 50  0001 C CNN
	1    3100 9375
	1    0    0    -1  
$EndComp
$Comp
L Device:C C602
U 1 1 62F1169F
P 3400 9375
F 0 "C602" H 3300 9625 50  0000 L CNN
F 1 "0.01uF" H 3300 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 3438 9225 50  0001 C CNN
F 3 "~" H 3400 9375 50  0001 C CNN
	1    3400 9375
	1    0    0    -1  
$EndComp
$Comp
L Device:C C603
U 1 1 62F119F1
P 3700 9375
F 0 "C603" H 3600 9625 50  0000 L CNN
F 1 "0.1uF" H 3600 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 3738 9225 50  0001 C CNN
F 3 "~" H 3700 9375 50  0001 C CNN
	1    3700 9375
	1    0    0    -1  
$EndComp
$Comp
L Device:C C604
U 1 1 62F11F7F
P 4000 9375
F 0 "C604" H 3900 9625 50  0000 L CNN
F 1 "0.01uF" H 3900 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 4038 9225 50  0001 C CNN
F 3 "~" H 4000 9375 50  0001 C CNN
	1    4000 9375
	1    0    0    -1  
$EndComp
$Comp
L Device:C C605
U 1 1 62F1336C
P 4300 9375
F 0 "C605" H 4200 9625 50  0000 L CNN
F 1 "0.1uF" H 4200 9125 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 4338 9225 50  0001 C CNN
F 3 "~" H 4300 9375 50  0001 C CNN
	1    4300 9375
	1    0    0    -1  
$EndComp
Wire Wire Line
	2475 9525 2475 9650
Connection ~ 2800 9525
Wire Wire Line
	2800 9525 2475 9525
Connection ~ 3100 9525
Wire Wire Line
	3100 9525 2800 9525
Connection ~ 3400 9525
Wire Wire Line
	3400 9525 3100 9525
Connection ~ 3700 9525
Wire Wire Line
	3700 9525 3400 9525
Connection ~ 4000 9525
Wire Wire Line
	4000 9525 3700 9525
Wire Wire Line
	4300 9525 4000 9525
Wire Wire Line
	2475 9225 2475 9125
Connection ~ 2800 9225
Wire Wire Line
	2800 9225 2475 9225
Connection ~ 3100 9225
Wire Wire Line
	3100 9225 2800 9225
Connection ~ 3400 9225
Wire Wire Line
	3400 9225 3100 9225
Connection ~ 3700 9225
Wire Wire Line
	3700 9225 3400 9225
Connection ~ 4000 9225
Wire Wire Line
	4000 9225 3700 9225
Wire Wire Line
	4300 9225 4000 9225
$Comp
L power:GND #PWR0182
U 1 1 62F5AC51
P 2475 9650
F 0 "#PWR0182" H 2475 9400 50  0001 C CNN
F 1 "GND" H 2480 9477 50  0000 C CNN
F 2 "" H 2475 9650 50  0001 C CNN
F 3 "" H 2475 9650 50  0001 C CNN
	1    2475 9650
	1    0    0    -1  
$EndComp
Wire Bus Line
	9650 1400 15500 1400
Wire Bus Line
	5000 1175 15500 1175
Wire Bus Line
	9650 1400 9650 5425
Wire Bus Line
	10500 1500 10500 4225
Wire Bus Line
	9500 1275 9500 4925
Wire Bus Line
	11175 5725 11175 8750
Wire Bus Line
	14475 1275 14475 5725
$Comp
L power:+3.3V #PWR0181
U 1 1 630418F1
P 2475 9125
F 0 "#PWR0181" H 2475 8975 50  0001 C CNN
F 1 "+3.3V" H 2490 9298 50  0000 C CNN
F 2 "" H 2475 9125 50  0001 C CNN
F 3 "" H 2475 9125 50  0001 C CNN
	1    2475 9125
	1    0    0    -1  
$EndComp
$EndSCHEMATC
