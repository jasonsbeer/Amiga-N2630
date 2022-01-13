EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 5
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
L 74xx:74HCT04 U?
U 4 1 620A8B8C
P 1325 1300
AR Path="/61D79EBC/620A8B8C" Ref="U?"  Part="1" 
AR Path="/6209FB19/620A8B8C" Ref="U204"  Part="4" 
F 0 "U204" H 1325 1617 50  0000 C CNN
F 1 "74HCT04" H 1325 1526 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 1325 1300 50  0001 C CNN
F 3 "https://assets.nexperia.com/documents/data-sheet/74HC_HCT04.pdf" H 1325 1300 50  0001 C CNN
F 4 "296-31832-1-ND" H 1325 1300 50  0001 C CNN "Digikey"
	4    1325 1300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0123
U 1 1 620AFB56
P 1025 1600
F 0 "#PWR0123" H 1025 1350 50  0001 C CNN
F 1 "GND" H 1030 1427 50  0000 C CNN
F 2 "" H 1025 1600 50  0001 C CNN
F 3 "" H 1025 1600 50  0001 C CNN
	1    1025 1600
	1    0    0    -1  
$EndComp
NoConn ~ 1625 1300
Wire Wire Line
	1025 1600 1025 1300
$EndSCHEMATC
