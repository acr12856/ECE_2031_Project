; Psuedocode for our SCOMP application to test our VHDL implementation

; THE IDEA IS TO TAKE A VALUE FROM THE SWITCHES AND DISPLAY IN ON THE LED'S
; THEN WE USE THE POTENTIOMETER AND LET THE USER TRY TO HONE IN ON IT

;;
;; Hex1: the difference between our score and the ADC value
;;

ORG 0
;CH1TEST:
;LOAD ChIn0
;OUT ADCWrite
;IN ADC
    ;OUT Hex0
   ; JUMP CH1TEST
    ;ADDI -20
   ; OUT Hex0
   ; JPOS CH1TEST
   
 ;CH2TEST:
    ;LOAD ChIn2
    ;OUT ADCWrite
    ;IN ADC
   ; ADDI -20
    ;OUT Hex0
    ;JPOS  CH2TEST
   
;; TODO: change state transition logic from adcgoalset -> takedialinput to be when ch2 goes to FFF and back to 0



WAITFORALLDOWN:
;; We're ready for a game reset. Wait for the user to put all switches down before the game begins
LOAD ChIn2
OUT ADC
   
    LOAD AllZeros
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
    OUT Hex1
    SUB fffmem
    JNEG ADCGOALSET1
ADCGOALSET2:
;; user sets switches to input a pattern, and only submit this pattern when ACD hits 0
IN Switches
    STORE Pattern
    OUT LEDs
   
    IN ADC
    OUT Hex1
   
    ADDI -16 ;; to check if we're within 15 of 0
    JPOS ADCGOALSET2 ;; if its negative we were > 15 away

TAKEDIALINPUT:
LOAD ChIn0
OUT ADC
   
    IN ADC ;; get our value
    SHIFT -2 ;; to match 10 bit resolution
    STORE userInput
    OUT Hex1 ;; debug, remove later
    IN Switches
    OUT Hex1 ;; debug
    JNZ TAKEDIALINPUT ;; user didn't wish to submit, keep going
    JUMP SUBMISSION
   
SUBMISSION:
;; User wants to submit their current ADC value
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
    ; JUMP TAKEDIALINPUT   ;try again --------- NO, I should be putting them in purgatory state for the wrong guess..
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
IN Timer
    STORE lastTimerBlink
    OUT Hex1
    LOAD AllOnes
    OUT LEDs
LOOP:
OUT Timer ;; reset to 0
    LOAD blinkStatus
XOR AllOnes
    STORE blinkStatus
  FLASHON:
 LOAD blinkStatus
      OUT LEDs
      IN Timer
      SUB Hella
      JNEG FLASHON
  JUMP LOOP
   
   
   
; Variables
ORG &H50

Pattern:   DW 0
    userInput: DW 0
    AllZeros: DW &B0000000000
    AllOnes: DW &B1111111111
    ;lastSwitch: DW &B0000000001
    ;totalScore: DW 0
    ;SUBMISSION_LENGTH: DW 1000 ; 1 second?
    ;submissionStartTime: DW 0
    ;submissionStatus: DW 0
    ChIn0:   DW &B100010000000
   ; ChIn2:   DW &B1001100000000 what we expect it to be
    ChIn2:   DW &B100110000000
    fffmem: DW &HFFF
   

    Temp: DW 0
    read_result_channel: DW 0
    lastTimerBlink: DW 0
    blinkStatus: DW &B0000000000
    Hella: DW 2
   

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
ADC:   EQU 192;; our peripheral......