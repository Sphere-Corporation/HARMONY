
; Assembled with sbasm3 (https://www.sbprojects.net/sbasm/)
; All directives are specific to sbasm3, and may need to be changed for other assemblers

;       PROGRAM AS ORIGINAL AS M.J. BAUER CONCEIVED IN 1981, 
;       MODIFIED FOR SPHERE-1 ANDREW SHAPTON 2025

        .CR 6800               ; LOAD MC6800 CROSS OVERLAY
        .TF snd.exe,BIN        ; OUTPUT FILE IN BINARY FORMAT
        .OR $0200              ; START OF ASSEMBLY ADDRESS
        .LI OFF                ; SWITCH OFF ASSEMBLY LISTING (EXCEPT ERRORS)
        .SF SYMBOLS.SYM        ; CREATE SYMBOL FILE

;       *
;       *******************************************************
;       *   DREAM-6800 SOUND-EFFECTS GENERATOR                *
;       *   TEST & DEMO PROGRAM +                             * 
;       *   LOW-LEVEL DRIVER SUBROUTINES.                     *
;       *          M.J. BAUER,  1981.                         *
;       *******************************************************
;       *
;
;               TITLE   76477 SOUND FX GEN DRIVERS
;       *
FXPIA   .EQU     $F040         ; Address of PIA for KBD/2       ORIGINAL : $8020
GETKEY  .EQU     $C2C4         ;                                ORIGINAL : $C2C4
KEYINP  .EQU     $C297         ;                                ORIGINAL : $C297
BADRED  .EQU     $0018         ;                                ORIGINAL : $0018
PAINZ   .EQU     $C287         ; INIZ KEYPAD                    ORIGINAL : $C287
ADDAI   .EQU     $C189         ; 16 BIT ADD A TO PTR (I)        ORIGINAL : $C189
I       .EQU     $26           ; 16 BIT POINTER
;       *


;       SPHERE-1 SPECIFIC
;        LDS     #$1FF          ; STACK BELOW PROGRAM
                               ; MUST BE FIRST LINE OF CODE

TESTFX  BSR     INIZFX
        BSR     DISAFX
        JSR     PAINZ
WAIT1   LDAA    $8011          ; WAIT FOR KEYDOWN
        BPL     WAIT1
        JSR     KEYINP         ; FETCH KEYCODE ==> A
        ASLA                   ; MULT BY 2
        LDX     #TABLE         ; USE TO LOOK UP TABLE
        STX     I
        JSR     ADDAI
        LDX     I
        LDAA    1,X            ; SET VCO FREQ
        STAA    FXPIA+2
        LDAA    0,X            ; SET PATCH & ENABLE FX
        BSR     ENABFX
WAIT2   JSR     KEYINP         ; WAIT FOR KEY RELEASE
        TST     BADRED
        BEQ     WAIT2
        BRA     TESTFX         ; AGAIN...        

;       *
        .NO $0230              ; LOOK-UP TABLE
;       * LOOK-UP TABLE:  DATA FOR PATCH & FREQ (16 X 2): 
;       *                 ***  KEY  ***  CONTINUOUS ENABLE:-
TABLE   .DA     $00FF          ; 0   VCO,  1kHz 
        .DA     $0040          ; 1   VCO,  5kHz
        .DA     $2000          ; 2   SLF,  AUDIO-1 (Preset)
        .DA     $4000          ; 3   NOISE
        .DA     $0440          ; 4   FM,  SLF AUDIO, VCO 5KHZ
        .DA     $06FF          ; 5   FM,  SLF LOW-1, VCO 1KHZ
        .DA     $C0FF          ; 6   AM,  SLF AUDIO-1, VCO 1KHZ
        .DA     $C183          ; 7   AM,  SLF AUDIO-2, VCO 23HZ
;       *                 ***  KEY  ***  ONE-SHOT ENVELOPE:-
        .DA     $161A          ; 8   FM,  SLF LOW-1, VCO 23KHZKHZ
        .DA     $1714          ; 9   FM,  SLF LOW-2, VCO 1.5K
        .DA     $7084          ; A   NOISE & VCO (30HZ)
        .DA     $D10D          ; B   AM,  SLF AUDIO-2, VCO 1K
;       *                 ***  KEY  ***  ATTACK/DECAY ENVELOPE:-
        .DA     $780D          ; C   NOISE & VCO (1KHZ)
        .DA     $1C70          ; D   FM,  SLF AUDIO-1, VCO 9KHZ
        .DA     $D987          ; E   AM,  SLF AUDIO-2, VCO 50HZ
        .DA     $DF20          ; F   EVERYTHIN! (well, almost)


;       * LOW-LEVEL DRIVER SUBROUTINES.

        .NO $0250              

;       * DISABLE SOUND EFFECTS GENERATOR.
DISAFX  LDAB    #$3C
        STAB    FXPIA+1
        RTS

;       * INITIALIZE SOUND-FX GEN (PIA-B DDR = VCO-FREQ)
INIZFX  LDAB    #4                     ; ACCESS O/P REG
        STAB    FXPIA+3
        CLR     FXPIA+2                ; O/P LINES LOW
        CLR     FXPIA+3                ; ACCESS DDR
;       * SET VCO FREQ & RANGE (ACC-A ==> DDR)
        STAA    FXPIA+2
        RTS
        
;       * ENABLE SOUND-FX GEN. (ACC-A ==> O/P REG)
ENABFX  LDX     #FXPIA                 ; GET PORT ADRS
        LDAB    #$38                   ; INHIBIT AND SEL DDR
        STAB    1,X
        LDAB    #$FF                   ; WRITE DDR (ALL OUTPUTS)
        STAB    0,X
        LDAB    #$3C                   ; SEL O/P REG
        STAB    1,X
        STAA    0,X                    ; WRITE O/P REG
        LDAB    #$34                   ; ENABLE FX
        STAB    1,X
        RTS