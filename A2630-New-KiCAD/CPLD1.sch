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
P 4800 5025
F 0 "U600" H 4800 6800 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 4800 6625 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 4800 5025 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 4800 5025 50  0001 C CNN
	1    4800 5025
	1    0    0    -1  
$EndComp
Wire Wire Line
	3800 5625 1800 5625
Wire Wire Line
	3800 5825 1800 5825
Wire Wire Line
	3800 5925 1800 5925
Wire Wire Line
	3800 6025 1800 6025
Wire Wire Line
	3800 6125 1800 6125
Wire Wire Line
	3800 6225 1800 6225
Wire Wire Line
	3800 6325 1800 6325
Wire Wire Line
	3800 6425 1800 6425
Wire Wire Line
	3800 6525 1800 6525
Wire Wire Line
	3800 6625 1800 6625
Wire Wire Line
	3800 6825 1800 6825
Wire Wire Line
	3800 6725 1800 6725
Wire Wire Line
	6925 5625 5800 5625
Wire Wire Line
	6925 5725 5800 5725
Wire Wire Line
	6925 5825 5800 5825
Wire Wire Line
	6925 5925 5800 5925
Wire Wire Line
	6925 6025 5800 6025
Wire Wire Line
	6900 6125 5800 6125
Wire Wire Line
	6900 6225 5800 6225
Wire Wire Line
	6900 6325 5800 6325
Wire Wire Line
	6900 6425 5800 6425
Wire Wire Line
	6900 6525 5800 6525
Wire Wire Line
	6900 6625 5800 6625
Wire Wire Line
	6900 6725 5800 6725
Wire Wire Line
	6900 6925 5800 6925
Wire Wire Line
	6900 6825 5800 6825
Wire Wire Line
	6925 3925 5800 3925
Wire Wire Line
	6925 4025 5800 4025
Wire Wire Line
	6925 4125 5800 4125
Wire Wire Line
	6925 4225 5800 4225
Wire Wire Line
	6925 4325 5800 4325
Wire Wire Line
	6925 4425 5800 4425
Wire Wire Line
	6925 4525 5800 4525
Wire Wire Line
	6925 4625 5800 4625
Wire Wire Line
	6925 4725 5800 4725
Wire Wire Line
	6925 4825 5800 4825
Wire Wire Line
	6925 5025 5800 5025
Wire Wire Line
	6925 4925 5800 4925
Wire Wire Line
	3800 3725 1800 3725
Wire Wire Line
	3800 3825 1800 3825
Wire Wire Line
	3800 3925 1800 3925
Wire Wire Line
	3800 4225 1800 4225
Wire Wire Line
	3800 4425 1800 4425
Wire Wire Line
	3800 4525 1800 4525
Wire Wire Line
	3800 4625 1800 4625
Wire Wire Line
	3800 4725 1800 4725
Wire Wire Line
	3800 4825 1800 4825
Wire Wire Line
	3800 5025 1800 5025
Wire Wire Line
	3800 4925 1800 4925
Wire Wire Line
	3800 3325 1800 3325
Wire Wire Line
	3800 3425 1800 3425
Wire Wire Line
	3800 3525 1800 3525
Wire Wire Line
	3800 3625 1800 3625
Wire Wire Line
	6925 5225 5800 5225
Wire Wire Line
	6925 5325 5800 5325
Wire Wire Line
	6925 5425 5800 5425
Wire Wire Line
	6425 7225 5800 7225
Wire Wire Line
	6425 7325 5800 7325
Wire Wire Line
	6425 7425 5800 7425
Wire Wire Line
	6425 7525 5800 7525
$Comp
L Connector_Generic:Conn_01x06 CN1
U 1 1 6215B057
P 6625 7425
F 0 "CN1" H 6705 7417 50  0000 L CNN
F 1 "CPLD0" H 6705 7326 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 6625 7425 50  0001 C CNN
F 3 "~" H 6625 7425 50  0001 C CNN
	1    6625 7425
	1    0    0    -1  
$EndComp
Text Label 6425 7225 2    50   ~ 0
TDI0
Text Label 6425 7325 2    50   ~ 0
TMS0
Text Label 6425 7425 2    50   ~ 0
TCK0
Text Label 6425 7525 2    50   ~ 0
TDO0
Wire Wire Line
	4500 7825 4500 8175
Wire Wire Line
	4500 8175 4600 8175
Wire Wire Line
	5900 8175 5900 7625
Wire Wire Line
	5900 7625 6425 7625
Wire Wire Line
	5200 7825 5200 8175
Connection ~ 5200 8175
Wire Wire Line
	5200 8175 5900 8175
Wire Wire Line
	5100 7825 5100 8175
Wire Wire Line
	5000 7825 5000 8175
Wire Wire Line
	4900 7825 4900 8175
Wire Wire Line
	4800 7825 4800 8175
Wire Wire Line
	4700 7825 4700 8175
Wire Wire Line
	4600 7825 4600 8175
Connection ~ 5100 8175
Wire Wire Line
	5100 8175 5200 8175
Connection ~ 5000 8175
Wire Wire Line
	5000 8175 5100 8175
Connection ~ 4900 8175
Wire Wire Line
	4900 8175 5000 8175
Connection ~ 4600 8175
Wire Wire Line
	4600 8175 4700 8175
Connection ~ 4700 8175
Wire Wire Line
	4700 8175 4800 8175
Connection ~ 4800 8175
Wire Wire Line
	4800 8175 4900 8175
$Comp
L power:GND #PWR0155
U 1 1 621CFBA1
P 5900 8175
F 0 "#PWR0155" H 5900 7925 50  0001 C CNN
F 1 "GND" H 5905 8002 50  0000 C CNN
F 2 "" H 5900 8175 50  0001 C CNN
F 3 "" H 5900 8175 50  0001 C CNN
	1    5900 8175
	1    0    0    -1  
$EndComp
Connection ~ 5900 8175
Text Label 6425 7625 2    50   ~ 0
GND
Wire Wire Line
	6425 7725 6250 7725
Wire Wire Line
	6250 7725 6250 8175
Wire Wire Line
	6250 8175 6075 8175
$Comp
L power:+3.3V #PWR0172
U 1 1 621D5095
P 6075 8175
F 0 "#PWR0172" H 6075 8025 50  0001 C CNN
F 1 "+3.3V" H 6090 8348 50  0000 C CNN
F 2 "" H 6075 8175 50  0001 C CNN
F 3 "" H 6075 8175 50  0001 C CNN
	1    6075 8175
	1    0    0    -1  
$EndComp
Text Label 6425 7725 2    50   ~ 0
3.3V
$Comp
L CPLD_Xilinx:XC9572XL-TQ100 U601
U 1 1 62219218
P 11225 5025
F 0 "U601" H 11225 6800 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 11225 6625 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 11225 5025 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 11225 5025 50  0001 C CNN
	1    11225 5025
	1    0    0    -1  
$EndComp
Wire Wire Line
	10225 5525 8900 5525
Wire Wire Line
	10225 5625 8900 5625
Wire Wire Line
	10225 5725 8900 5725
Wire Wire Line
	10225 5825 8900 5825
Wire Wire Line
	10225 5925 8900 5925
Wire Wire Line
	10225 6025 8900 6025
Wire Wire Line
	10225 6125 8900 6125
Wire Wire Line
	10225 6225 8900 6225
Wire Wire Line
	10225 6325 8900 6325
Wire Wire Line
	10225 6425 8900 6425
Wire Wire Line
	10225 6525 8900 6525
Wire Wire Line
	10225 6625 8900 6625
Wire Wire Line
	10225 6825 8900 6825
Wire Wire Line
	10225 6725 8900 6725
Wire Wire Line
	13575 5625 12225 5625
Wire Wire Line
	13575 5725 12225 5725
Wire Wire Line
	13575 5825 12225 5825
Wire Wire Line
	13575 5925 12225 5925
Wire Wire Line
	13575 6025 12225 6025
Wire Wire Line
	13575 6125 12225 6125
Wire Wire Line
	13575 6225 12225 6225
Wire Wire Line
	13575 6325 12225 6325
Wire Wire Line
	13575 6425 12225 6425
Wire Wire Line
	13575 6525 12225 6525
Wire Wire Line
	13575 6625 12225 6625
Wire Wire Line
	13575 6725 12225 6725
Wire Wire Line
	13575 6925 12225 6925
Wire Wire Line
	13575 6825 12225 6825
Wire Wire Line
	13300 3725 12225 3725
Wire Wire Line
	13300 3825 12225 3825
Wire Wire Line
	13300 3925 12225 3925
Wire Wire Line
	13300 4025 12225 4025
Wire Wire Line
	13300 4125 12225 4125
Wire Wire Line
	13300 4225 12225 4225
Wire Wire Line
	13300 4325 12225 4325
Wire Wire Line
	13300 4425 12225 4425
Wire Wire Line
	13300 4525 12225 4525
Wire Wire Line
	13300 4625 12225 4625
Wire Wire Line
	13300 4725 12225 4725
Wire Wire Line
	13300 4825 12225 4825
Wire Wire Line
	13300 5025 12225 5025
Wire Wire Line
	13300 4925 12225 4925
Wire Wire Line
	10225 3725 8900 3725
Wire Wire Line
	10225 3825 8900 3825
Wire Wire Line
	10225 3925 8900 3925
Wire Wire Line
	10225 4025 8900 4025
Wire Wire Line
	10225 4225 8900 4225
Wire Wire Line
	10225 4425 8900 4425
Wire Wire Line
	10225 4525 8900 4525
Wire Wire Line
	10225 4625 8900 4625
Wire Wire Line
	10225 4725 8900 4725
Wire Wire Line
	10225 4825 8900 4825
Wire Wire Line
	10225 5025 8900 5025
Wire Wire Line
	10225 4925 8900 4925
Wire Wire Line
	13300 3325 12225 3325
Wire Wire Line
	13300 3425 12225 3425
Wire Wire Line
	13300 3525 12225 3525
Wire Wire Line
	13300 3625 12225 3625
Wire Wire Line
	10225 3325 8900 3325
Wire Wire Line
	10225 3425 8900 3425
Wire Wire Line
	10225 3525 8900 3525
Wire Wire Line
	10225 3625 8900 3625
Wire Wire Line
	13400 5225 12225 5225
Wire Wire Line
	13400 5325 12225 5325
Wire Wire Line
	13400 5425 12225 5425
Wire Wire Line
	13400 5525 12225 5525
Wire Wire Line
	12850 7225 12225 7225
Wire Wire Line
	12850 7325 12225 7325
Wire Wire Line
	12850 7425 12225 7425
Wire Wire Line
	12850 7525 12225 7525
Text Label 12850 7225 2    50   ~ 0
TDI1
Text Label 12850 7325 2    50   ~ 0
TMS1
Text Label 12850 7425 2    50   ~ 0
TCK1
Text Label 12850 7525 2    50   ~ 0
TDO1
Wire Wire Line
	10925 7825 10925 8175
Wire Wire Line
	10925 8175 11025 8175
Wire Wire Line
	12325 8175 12325 7625
Wire Wire Line
	12325 7625 12850 7625
Wire Wire Line
	11625 7825 11625 8175
Connection ~ 11625 8175
Wire Wire Line
	11625 8175 12325 8175
Wire Wire Line
	11525 7825 11525 8175
Wire Wire Line
	11425 7825 11425 8175
Wire Wire Line
	11325 7825 11325 8175
Wire Wire Line
	11225 7825 11225 8175
Wire Wire Line
	11125 7825 11125 8175
Wire Wire Line
	11025 7825 11025 8175
Connection ~ 11525 8175
Wire Wire Line
	11525 8175 11625 8175
Connection ~ 11425 8175
Wire Wire Line
	11425 8175 11525 8175
Connection ~ 11325 8175
Wire Wire Line
	11325 8175 11425 8175
Connection ~ 11025 8175
Wire Wire Line
	11025 8175 11125 8175
Connection ~ 11125 8175
Wire Wire Line
	11125 8175 11225 8175
Connection ~ 11225 8175
Wire Wire Line
	11225 8175 11325 8175
$Comp
L power:GND #PWR0173
U 1 1 62219287
P 12325 8175
F 0 "#PWR0173" H 12325 7925 50  0001 C CNN
F 1 "GND" H 12330 8002 50  0000 C CNN
F 2 "" H 12325 8175 50  0001 C CNN
F 3 "" H 12325 8175 50  0001 C CNN
	1    12325 8175
	1    0    0    -1  
$EndComp
Connection ~ 12325 8175
Text Label 12850 7625 2    50   ~ 0
GND
Wire Wire Line
	12850 7725 12675 7725
Wire Wire Line
	12675 7725 12675 8175
Wire Wire Line
	12675 8175 12500 8175
$Comp
L power:+3.3V #PWR0174
U 1 1 62219292
P 12500 8175
F 0 "#PWR0174" H 12500 8025 50  0001 C CNN
F 1 "+3.3V" H 12515 8348 50  0000 C CNN
F 2 "" H 12500 8175 50  0001 C CNN
F 3 "" H 12500 8175 50  0001 C CNN
	1    12500 8175
	1    0    0    -1  
$EndComp
Text Label 12850 7725 2    50   ~ 0
3.3V
$Comp
L Connector_Generic:Conn_01x06 CN2
U 1 1 62227388
P 13050 7425
F 0 "CN2" H 13130 7417 50  0000 L CNN
F 1 "CPLD1" H 13130 7326 50  0000 L CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x06_P2.54mm_Vertical" H 13050 7425 50  0001 C CNN
F 3 "~" H 13050 7425 50  0001 C CNN
	1    13050 7425
	1    0    0    -1  
$EndComp
Text Label 12850 3325 0    50   ~ 0
A0
Text Label 12850 3425 0    50   ~ 0
A1
Text Label 12850 3525 0    50   ~ 0
A2
Text Label 12850 3625 0    50   ~ 0
A3
Text Label 12850 3725 0    50   ~ 0
A4
Text Label 12850 3825 0    50   ~ 0
A5
Text Label 12850 3925 0    50   ~ 0
A6
Text Label 12850 4025 0    50   ~ 0
A13
Text Label 12850 4125 0    50   ~ 0
A14
Text Label 12850 4225 0    50   ~ 0
A15
Text Label 12850 4325 0    50   ~ 0
A16
Text Label 12850 4425 0    50   ~ 0
A17
Text Label 12850 4525 0    50   ~ 0
A18
Text Label 12850 4625 0    50   ~ 0
A19
Text Label 12850 4725 0    50   ~ 0
A20
Text Label 12850 4825 0    50   ~ 0
A21
Text Label 12850 4925 0    50   ~ 0
A22
Text Label 12850 5025 0    50   ~ 0
A23
Text Label 12850 5225 0    50   ~ 0
D28
Text Label 12850 5325 0    50   ~ 0
D29
Text Label 12850 5425 0    50   ~ 0
D30
Text Label 12850 5525 0    50   ~ 0
D31
Text GLabel 1800 3325 0    50   Input ~ 0
_AS
Text GLabel 1800 3425 0    50   Input ~ 0
AR_W
Text GLabel 1800 3525 0    50   Output ~ 0
R_W
Text GLabel 1800 3625 0    50   Input ~ 0
_ABG
Text GLabel 1800 3725 0    50   Input ~ 0
_ABGACK
Text GLabel 1800 3825 0    50   Input ~ 0
_ASEN
Text GLabel 1800 3925 0    50   Output ~ 0
_AAS
Text GLabel 1800 4225 0    50   Output ~ 0
_ABR
Text GLabel 1800 4425 0    50   Output ~ 0
_ASDELAY
Text GLabel 1800 4525 0    50   Output ~ 0
_DSEN
Text GLabel 6900 6925 2    50   Input ~ 0
_HALT
Text GLabel 6900 6525 2    50   Input ~ 0
B2000
Text GLabel 6900 6425 2    50   Input ~ 0
MODE68K
Text GLabel 6925 5225 2    50   Input ~ 0
FC2
Text GLabel 6925 5325 2    50   Input ~ 0
FC1
Text GLabel 6925 5425 2    50   Input ~ 0
FC0
Text GLabel 6900 6325 2    50   Input ~ 0
EXTSEL
Text GLabel 6900 6125 2    50   Input ~ 0
JMODE
Text GLabel 6925 4125 2    50   Input ~ 0
_STERM
Text GLabel 1800 5825 0    50   Input ~ 0
A7M
Text GLabel 1800 5925 0    50   Input ~ 0
_C1
Text GLabel 1800 6025 0    50   Input ~ 0
_C3
Text GLabel 1800 6125 0    50   Input ~ 0
CDAC
Text GLabel 6900 6225 2    50   Input ~ 0
_VPA
Text GLabel 1800 4625 0    50   Input ~ 0
MEMACCESS
Text GLabel 1800 4725 0    50   Input ~ 0
CONFIGED
Text GLabel 6900 6725 2    50   Input ~ 0
RESENB
Text GLabel 1800 6225 0    50   Input ~ 0
CPUCLK_A
Text GLabel 1800 4825 0    50   Input ~ 0
_UDS
Text GLabel 1800 4925 0    50   Input ~ 0
_LDS
Text GLabel 1800 6325 0    50   Output ~ 0
7M
Text GLabel 1800 6425 0    50   Output ~ 0
_7M
Text GLabel 1800 6525 0    50   Output ~ 0
SCLK
Text GLabel 1800 6625 0    50   Output ~ 0
SN7MDIS
Text GLabel 1800 6725 0    50   Output ~ 0
_S7MDIS
Text GLabel 1800 6825 0    50   Output ~ 0
DSCLK
Text GLabel 1800 5625 0    50   Output ~ 0
IPLCLK
Text GLabel 6925 4725 2    50   Output ~ 0
_DSACKDIS
Text GLabel 6925 4625 2    50   Output ~ 0
_EDTACK
Text GLabel 6925 4525 2    50   Output ~ 0
_REGRESET
Text GLabel 6925 4425 2    50   Output ~ 0
_BGDIS
Text GLabel 6925 4325 2    50   Output ~ 0
_DSACK0
Text GLabel 6925 4225 2    50   Output ~ 0
_DSACK1
Text GLabel 1800 5025 0    50   Output ~ 0
_BGACK
Text GLabel 6925 4025 2    50   Output ~ 0
_CYCEND
Text GLabel 6925 3925 2    50   Output ~ 0
_MEMSEL
Text GLabel 6925 4825 2    50   Output ~ 0
E
Text GLabel 6925 4925 2    50   Output ~ 0
_DSACKEN
Text GLabel 6925 5025 2    50   Output ~ 0
_ONBOARD
Text GLabel 6900 6625 2    50   Output ~ 0
_CPURESET
Text GLabel 6900 6825 2    50   Output ~ 0
_RESET
Text GLabel 6925 5625 2    50   Output ~ 0
_IVMA
Text GLabel 6925 5725 2    50   Output ~ 0
_EXTERN
Text GLabel 6925 5825 2    50   Output ~ 0
_DTACK
Text GLabel 6925 5925 2    50   Output ~ 0
TRISTATE
Text GLabel 6925 6025 2    50   Output ~ 0
_BOSS
NoConn ~ 5800 3825
NoConn ~ 5800 3725
NoConn ~ 5800 3625
NoConn ~ 5800 3525
NoConn ~ 5800 3425
NoConn ~ 5800 3325
NoConn ~ 5800 5525
NoConn ~ 3800 6925
NoConn ~ 3800 5725
NoConn ~ 3800 5525
NoConn ~ 3800 5425
NoConn ~ 3800 5325
NoConn ~ 3800 5225
NoConn ~ 3800 4325
NoConn ~ 3800 4125
NoConn ~ 3800 4025
Entry Wire Line
	13300 5025 13400 4925
Wire Bus Line
	13400 1650 15500 1650
Text GLabel 15500 1650 2    50   Input ~ 0
A[31..0]
Entry Wire Line
	13300 4625 13400 4525
Entry Wire Line
	13300 4525 13400 4425
Entry Wire Line
	13300 4425 13400 4325
Entry Wire Line
	13300 4325 13400 4225
Entry Wire Line
	13300 4225 13400 4125
Entry Wire Line
	13300 4125 13400 4025
Entry Wire Line
	13300 4025 13400 3925
Entry Wire Line
	13300 3925 13400 3825
Entry Wire Line
	13300 3825 13400 3725
Entry Wire Line
	13300 3725 13400 3625
Entry Wire Line
	13300 3625 13400 3525
Entry Wire Line
	13300 3525 13400 3425
Entry Wire Line
	13300 3425 13400 3325
Entry Wire Line
	13300 3325 13400 3225
Entry Wire Line
	13300 4925 13400 4825
Entry Wire Line
	13300 4825 13400 4725
Entry Wire Line
	13300 4725 13400 4625
Entry Wire Line
	13400 5525 13500 5425
Entry Wire Line
	13400 5425 13500 5325
Entry Wire Line
	13400 5325 13500 5225
Entry Wire Line
	13400 5225 13500 5125
Wire Bus Line
	13500 1850 15500 1850
Text GLabel 15500 1850 2    50   BiDi ~ 0
D[31..0]
Text GLabel 13575 5625 2    50   Input ~ 0
FC2
Text GLabel 13575 5725 2    50   Input ~ 0
FC1
Text GLabel 13575 5825 2    50   Input ~ 0
FC0
Text GLabel 13575 5925 2    50   Input ~ 0
SIZ0
Text GLabel 13575 6025 2    50   Input ~ 0
SIZ1
Text GLabel 13575 6125 2    50   Output ~ 0
_FPUCS
Text GLabel 13575 6225 2    50   Output ~ 0
_BERR
Text GLabel 8900 6125 0    50   Input ~ 0
CPUCLK_A
Text GLabel 8900 6225 0    50   Input ~ 0
PHANTOMHI
Text GLabel 8900 6325 0    50   Input ~ 0
PHANTOMLO
Text GLabel 8900 6825 0    50   Output ~ 0
_CIIN
Text GLabel 13575 6425 2    50   Input ~ 0
_AS
Text GLabel 13575 6525 2    50   Input ~ 0
_DS
Text GLabel 13575 6625 2    50   Input ~ 0
R_W
Text GLabel 13575 6825 2    50   Input ~ 0
_SENSE
Text GLabel 13575 6725 2    50   Input ~ 0
_BGACK
Text GLabel 13575 6925 2    50   Output ~ 0
_CSROM
Text GLabel 8900 6525 0    50   Input ~ 0
OSMODE
Text GLabel 8900 4525 0    50   Input ~ 0
AUTO
Text GLabel 8900 4425 0    50   Input ~ 0
TWOMB
Text GLabel 8900 5725 0    50   Input ~ 0
_EXTERN
Text GLabel 8900 5825 0    50   Input ~ 0
_CYCEND
Text GLabel 8900 5525 0    50   Input ~ 0
_DSEN
Text GLabel 8900 5625 0    50   Input ~ 0
_ASEN
Text GLabel 8900 4725 0    50   Input ~ 0
TRISTATE
Text GLabel 8900 6625 0    50   Input ~ 0
_ONBOARD
Text GLabel 8900 6725 0    50   Input ~ 0
_MEMSEL
Text GLabel 8900 3325 0    50   Output ~ 0
_OE0
Text GLabel 8900 3425 0    50   Output ~ 0
_OE1
Text GLabel 8900 3525 0    50   Output ~ 0
_WE0
Text GLabel 8900 3625 0    50   Output ~ 0
_WE1
Text GLabel 8900 3725 0    50   Output ~ 0
_UUBE
Text GLabel 8900 4025 0    50   Output ~ 0
_LLBE
Text GLabel 8900 3825 0    50   Output ~ 0
_UMBE
Text GLabel 8900 3925 0    50   Output ~ 0
_LMBE
Text GLabel 8900 4225 0    50   Output ~ 0
_OVR
Text GLabel 8900 4625 0    50   Output ~ 0
CONFIGED
Text GLabel 8900 4825 0    50   Output ~ 0
ROMCLK
Text GLabel 8900 4925 0    50   Output ~ 0
_UDS
Text GLabel 8900 5025 0    50   Output ~ 0
_LDS
Text GLabel 8900 6425 0    50   Input ~ 0
_RESET
Text GLabel 8900 5925 0    50   Output ~ 0
_AVEC
Text GLabel 8900 6025 0    50   Output ~ 0
_MEMLOCK
Text GLabel 13575 6325 2    50   Output ~ 0
AR_W
NoConn ~ 10225 5425
NoConn ~ 10225 5325
NoConn ~ 10225 5225
NoConn ~ 10225 4125
NoConn ~ 10225 4325
NoConn ~ 10225 6925
Text Notes 13450 9675 2    236  ~ 0
CPLDs
Wire Wire Line
	10925 2325 10925 2050
Wire Wire Line
	11525 2325 11525 2050
Wire Wire Line
	11525 2050 11425 2050
Connection ~ 10925 2050
Wire Wire Line
	10925 2050 10925 1750
Wire Wire Line
	11425 2325 11425 2050
Connection ~ 11425 2050
Wire Wire Line
	11425 2050 11325 2050
Wire Wire Line
	11325 2325 11325 2050
Connection ~ 11325 2050
Wire Wire Line
	11325 2050 11225 2050
Wire Wire Line
	11225 2325 11225 2050
Connection ~ 11225 2050
Wire Wire Line
	11225 2050 11125 2050
Wire Wire Line
	11125 2325 11125 2050
Connection ~ 11125 2050
Wire Wire Line
	11125 2050 11025 2050
Wire Wire Line
	11025 2325 11025 2050
Connection ~ 11025 2050
Wire Wire Line
	11025 2050 10925 2050
$Comp
L power:+3.3V #PWR0175
U 1 1 62B40651
P 10925 1750
F 0 "#PWR0175" H 10925 1600 50  0001 C CNN
F 1 "+3.3V" H 10940 1923 50  0000 C CNN
F 2 "" H 10925 1750 50  0001 C CNN
F 3 "" H 10925 1750 50  0001 C CNN
	1    10925 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4500 2325 4500 2050
Wire Wire Line
	5100 2325 5100 2050
Wire Wire Line
	5100 2050 5000 2050
Connection ~ 4500 2050
Wire Wire Line
	4500 2050 4500 1750
Wire Wire Line
	5000 2325 5000 2050
Connection ~ 5000 2050
Wire Wire Line
	5000 2050 4900 2050
Wire Wire Line
	4900 2325 4900 2050
Connection ~ 4900 2050
Wire Wire Line
	4900 2050 4800 2050
Wire Wire Line
	4800 2325 4800 2050
Connection ~ 4800 2050
Wire Wire Line
	4800 2050 4700 2050
Wire Wire Line
	4700 2325 4700 2050
Connection ~ 4700 2050
Wire Wire Line
	4700 2050 4600 2050
Wire Wire Line
	4600 2325 4600 2050
Connection ~ 4600 2050
Wire Wire Line
	4600 2050 4500 2050
$Comp
L power:+3.3V #PWR0176
U 1 1 62B427B6
P 4500 1750
F 0 "#PWR0176" H 4500 1600 50  0001 C CNN
F 1 "+3.3V" H 4515 1923 50  0000 C CNN
F 2 "" H 4500 1750 50  0001 C CNN
F 3 "" H 4500 1750 50  0001 C CNN
	1    4500 1750
	1    0    0    -1  
$EndComp
Wire Bus Line
	13500 1850 13500 5425
Wire Bus Line
	13400 1650 13400 4925
$EndSCHEMATC
