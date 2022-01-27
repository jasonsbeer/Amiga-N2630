EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
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
L CPLD_Xilinx:XC9572XL-TQ100 U?
U 1 1 61F042BD
P 3700 4225
AR Path="/61D9C8DC/61F042BD" Ref="U?"  Part="1" 
AR Path="/634ECC15/61F042BD" Ref="U?"  Part="1" 
AR Path="/61EF4CC7/61F042BD" Ref="U?"  Part="1" 
F 0 "U?" H 3700 4300 50  0000 C CNN
F 1 "XC9572XL-TQ100" H 3700 4150 50  0000 C CNN
F 2 "Package_QFP:TQFP-100_14x14mm_P0.5mm" H 3700 4225 50  0001 C CNN
F 3 "http://www.xilinx.com/support/documentation/data_sheets/ds057.pdf" H 3700 4225 50  0001 C CNN
	1    3700 4225
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 7025 3400 7200
Wire Wire Line
	3400 7200 3500 7200
Wire Wire Line
	4100 7200 4100 7025
Wire Wire Line
	3500 7025 3500 7200
Connection ~ 3500 7200
Wire Wire Line
	3500 7200 3600 7200
Wire Wire Line
	3600 7025 3600 7200
Connection ~ 3600 7200
Wire Wire Line
	3600 7200 3700 7200
Wire Wire Line
	3700 7025 3700 7200
Connection ~ 3700 7200
Wire Wire Line
	3700 7200 3800 7200
Wire Wire Line
	3800 7025 3800 7200
Connection ~ 3800 7200
Wire Wire Line
	3800 7200 3900 7200
Wire Wire Line
	3900 7025 3900 7200
Connection ~ 3900 7200
Wire Wire Line
	3900 7200 4000 7200
Wire Wire Line
	4000 7025 4000 7200
Connection ~ 4000 7200
Wire Wire Line
	4000 7200 4100 7200
$Comp
L power:GND #PWR?
U 1 1 61F042D8
P 4100 7200
AR Path="/61D9C8DC/61F042D8" Ref="#PWR?"  Part="1" 
AR Path="/634ECC15/61F042D8" Ref="#PWR?"  Part="1" 
AR Path="/61EF4CC7/61F042D8" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 4100 6950 50  0001 C CNN
F 1 "GND" H 4105 7027 50  0000 C CNN
F 2 "" H 4100 7200 50  0001 C CNN
F 3 "" H 4100 7200 50  0001 C CNN
	1    4100 7200
	1    0    0    -1  
$EndComp
Connection ~ 4100 7200
Wire Wire Line
	4000 1525 4000 1325
Wire Wire Line
	4000 1325 3900 1325
Wire Wire Line
	3400 1325 3400 1525
Wire Wire Line
	3500 1525 3500 1325
Connection ~ 3500 1325
Wire Wire Line
	3500 1325 3400 1325
Wire Wire Line
	3600 1525 3600 1325
Connection ~ 3600 1325
Wire Wire Line
	3600 1325 3500 1325
Wire Wire Line
	3700 1525 3700 1325
Connection ~ 3700 1325
Wire Wire Line
	3700 1325 3600 1325
Wire Wire Line
	3800 1525 3800 1325
Connection ~ 3800 1325
Wire Wire Line
	3800 1325 3700 1325
Wire Wire Line
	3900 1525 3900 1325
Connection ~ 3900 1325
Wire Wire Line
	3900 1325 3800 1325
$Comp
L power:+3.3V #PWR?
U 1 1 61F042F1
P 3400 1325
AR Path="/61D9C8DC/61F042F1" Ref="#PWR?"  Part="1" 
AR Path="/634ECC15/61F042F1" Ref="#PWR?"  Part="1" 
AR Path="/61EF4CC7/61F042F1" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 3400 1175 50  0001 C CNN
F 1 "+3.3V" H 3415 1498 50  0000 C CNN
F 2 "" H 3400 1325 50  0001 C CNN
F 3 "" H 3400 1325 50  0001 C CNN
	1    3400 1325
	1    0    0    -1  
$EndComp
Connection ~ 3400 1325
Wire Wire Line
	4700 2525 5475 2525
Wire Wire Line
	4700 2625 5475 2625
Wire Wire Line
	4700 2725 5475 2725
Wire Wire Line
	4700 2825 5475 2825
Wire Wire Line
	4700 2925 5475 2925
Text GLabel 5475 2525 2    50   Input ~ 0
CDAC
Text GLabel 5475 2625 2    50   Input ~ 0
_C1
Text GLabel 5475 2725 2    50   Input ~ 0
_C3
Text GLabel 5475 2825 2    50   Input ~ 0
B2000
Text GLabel 5475 2925 2    50   Input ~ 0
A7M
Text Notes 6250 2800 2    118  ~ 0
U708
Text GLabel 5475 3025 2    50   Input ~ 0
_S7MDIS
Text Notes 5850 3075 0    51   ~ 0
U503
Text GLabel 5475 3125 2    50   Input ~ 0
S_7MDIS
Text Notes 5850 3175 0    51   ~ 0
U503
Wire Wire Line
	5475 3125 4700 3125
Wire Wire Line
	4700 3025 5475 3025
Wire Wire Line
	4700 3225 5475 3225
Text GLabel 5475 3225 2    50   Input ~ 0
_ASEN
Text Notes 5775 3275 0    51   ~ 0
U503
Wire Wire Line
	4700 3325 5475 3325
Text GLabel 5475 3325 2    50   Input ~ 0
SCLK
Wire Wire Line
	4700 3425 5475 3425
Text Notes 5500 3450 0    51   ~ 0
TO U505-2
Wire Wire Line
	4700 3525 5475 3525
Wire Wire Line
	4700 3625 5475 3625
Text GLabel 5475 3525 2    50   Output ~ 0
_IVMA
Text Notes 5750 3550 0    51   ~ 0
TO U606
$EndSCHEMATC
