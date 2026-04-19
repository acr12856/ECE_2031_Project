; Psuedocode for our SCOMP application to test our VHDL implementation

; THE IDEA IS TO TAKE A VALUE FROM THE SWITCHES AND DISPLAY IN ON THE LED'S
; THEN WE USE THE POTENTIOMETER AND LET THE USER TRY TO HONE IN ON IT

;;
;; Hex1: the difference between our score and the ADC value
;;

ORG 0

WAITFORALLDOWN:
;; We're ready for a game reset. Wait for the user to put all switches down before the game begins
	LOAD ChIn2
	OUT ADC
    LOAD AllZeros
    STORE numberOfGuesses
    OUT Hex0 ; start with a clean sheet
    OUT Hex1
    IN Switches
    OUT LEDs ;; light up lights above switches
    JNZ WAITFORALLDOWN ;; keep looping if all switches aren't yet down
ADCGOALSET1:
;; user sets switches to input a pattern, and only submit this pattern when ACD hits 0
	IN Switches
    STORE Pattern
    OUT LEDs
    IN ADC
    SUB fffmem
    JNEG ADCGOALSET1
ADCGOALSET2:
;; user sets switches to input a pattern, and only submit this pattern when ACD hits 0
	IN Switches
    STORE Pattern
    OUT LEDs
    IN ADC
   
    ADDI -16 ;; to check if we're within 15 of 0
    JPOS ADCGOALSET2 ;; if its negative we were > 15 away

TAKEDIALINPUT:
    LOAD ChIn0
    OUT ADC
    IN ADC ;; get our value
    SHIFT -2 ;; to match 10 bit resolution
    OUT Hex0 ;; just to show our value changing for the demo i guess
    STORE userInput
    IN Switches
    JNZ TAKEDIALINPUT ;; user didn't wish to submit, keep going
    JUMP SUBMISSION
   
SUBMISSION:
;; User wants to submit their current ADC value
;; increment their guess counter and check if they succeeded
	LOAD numberOfGuesses
    ADDI 1
    STORE numberOfGuesses
    LOAD userInput ;; from ADC conversion
    SUB Pattern ;; get the difference between our value and the goal
    JNEG MAKE_POSITIVE   ; If AC is negative, we need to flip it
    JUMP CHECK_RANGE
  MAKE_POSITIVE:
      STORE Temp    ; Save the negative difference
      LOADI 0       ; AC = 0
      SUB Temp      ; AC = 0 - (-Difference) = Positive Difference
   
  CHECK_RANGE:
  ; --- Boundary Check (+/- 10) ---
  ; We win if Distance <= 10.
      OUT Hex0 ; (AC = distance_from_target) => Hex0 Display
      ADDI -11             ; AC = Distance - 11
      JNEG WIN_STATE       ; If AC < 0 (Distance was 0-10), they win!
      JUMP WRONG_GUESS
    WRONG_GUESS:
    ;; I want to make it clear they got it wrong. maybe turn all of the lights off?
    ;; how should they exit purgatory? answer: by flicking any of the switches back up
        LOAD AllZeros
        OUT LEDs
        IN Switches
        JZERO  WRONG_GUESS;;  wait for them to flick any switches up before exiting
        JUMP TAKEDIALINPUT ;; ready to try again

;; --- To have reached this point, we must have gotten the correct value ---
WIN_STATE:
;; I think it'd be fun if we flash the lights a bunch
    LOAD numberOfGuesses
    OUT Hex1 ;; display how many guesses it took them to get it right
    LOAD AllOnes
    OUT LEDs
    LOAD ChIn2
	OUT ADC
LOOP1:
	OUT Timer ;; reset to 0
    LOAD blinkStatus
	XOR AllOnes
    STORE blinkStatus
  FLASH:
 	LOAD blinkStatus
	OUT LEDs
  RESTARTCHECK1:
	IN ADC
	OUT Hex0
	SUB fffmem
	JPOS LOOP2
	JZERO LOOP2
    IN Timer
    SUB Hella
    JNEG FLASH
    JUMP LOOP1
LOOP2:
	OUT Timer ;; reset to 0
    LOAD blinkStatus
	XOR AllOnes
    STORE blinkStatus
	FLASH2:
    	LOAD blinkStatus
        OUT LEDs
    RESTARTCHECK2:
    	IN ADC
    	OUT Hex0
    	ADDI -16 ;; to check if we're within 15 of 0
    	JNEG WAITFORALLDOWN
    	JZERO  WAITFORALLDOWN
 		IN Timer
      	SUB Hella
      	JNEG FLASH2
      	JUMP LOOP2
   
   
; Variables
ORG &H100
	Pattern:   DW 0
    userInput: DW 0
    AllZeros: DW &B0000000000
    AllOnes: DW &B1111111111
    ChIn0:   DW &B100010000000
    ChIn2:   DW &B100110000000
    fffmem: DW &HFFF
    numberOfGuesses: DW 0

    Temp: DW 0
    read_result_channel: DW 0
    lastTimerBlink: DW 0
    blinkStatus: DW &B0000000000
    Hella: DW 1
   

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
ADC:   EQU 192;; our peripheral......