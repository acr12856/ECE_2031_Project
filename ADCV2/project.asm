; IODemo.asm
; Produces a "bouncing" animation on the LEDs.
; The LED pattern is initialized with the switch state.

ORG 0

	; Get and store the switch values
showValue:
	IN     ADC
	OUT    LEDs
	OUT    Hex0
	STORE  Pattern
	JUMP   showValue

; Variables
Pattern:   DW 0

; Useful values
Bit0:      DW &B0000000001
Bit9:      DW &B1000000000
Bit2:	   DW &B0000000100

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
ADC:	   EQU 192
ADCWrite:  EQU 193