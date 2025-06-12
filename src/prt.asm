00001 $0000                ; SWTPC PR-40 Diagnostic
00002 $0000                ; 
00003 $0000                ; Adapted for Sphere from SWTPC PR-40 manual by Ben Zotto, 2024.
00004 $0000                ;
00005 $0000                ; Prints constant alternating lines showing the full character set.  
00006 $0000                ;
00007 $0000                ; Uses the port B interface of the CPU's PIA. 
00008 $0000                ; CB1 for "data accepted" input, CB2 output for "data ready" strobe.
00009 $0000                ;
00010 $0000                ; Don't let this run indefinitely, the print head solenoids can overheat. 
00011 $0000                
00012 $0000                PRPIA   EQU     $F042       ; port B of the onboard PIA
00013 $0000                
00014 $0000                        ORG     $200
00015 $0200                        
00016 $0200  CE F0 42       START   LDX     #PRPIA      ; Setup PIA (assumes from reset!)
00017 $0203  C6 FF                  LDA B   #$FF
00018 $0205  E7 00                  STA B   0, X        ; all data bits to output
00019 $0207  86 3F                  LDA A   #$3F
00020 $0209  A7 01                  STA A   1, X        ; data reg; CB1 interrupt on +ve transition; CB2 high
00021 $020B                     
00022 $020B  86 0D          FSTLIN  LDA A   #$0D        
00023 $020D  8D 1A                  BSR     OUTCHR      ; emit carriage return
00024 $020F  86 20                  LDA A   #$20        ; first line starts with '!' char
00025 $0211  4C             LOOP1   INC A  
00026 $0212  81 40                  CMP A   #$40
00027 $0214  27 04                  BEQ     NXTLIN
00028 $0216  8D 11                  BSR     OUTCHR
00029 $0218  20 F7                  BRA     LOOP1
00030 $021A  86 0D          NXTLIN  LDA A   #$0D
00031 $021C  8D 0B                  BSR     OUTCHR
00032 $021E  86 3F                  LDA A   #$3F        ; second line starts with '@' char
00033 $0220  4C             LOOP2   INC A
00034 $0221  81 60                  CMP A   #$60
00035 $0223  27 E6                  BEQ     FSTLIN      ; restart with a first line
00036 $0225  8D 02                  BSR     OUTCHR
00037 $0227  20 F7                  BRA     LOOP2
00038 $0229                    
00039 $0229                ; OUTCHR - routine to emit one character (in A)
00040 $0229                ;   assumes PIA base is in X
00041 $0229                ;
00042 $0229  A7 00          OUTCHR  STA A   0, X        ; send char data
00043 $022B  C6 37                  LDA B   #$37
00044 $022D  E7 01                  STA B   1, X        ; bring CB2 (data ready strobe) low
00045 $022F  C6 3F                  LDA B   #$3F    
00046 $0231  E7 01                  STA B   1, X        ; return CB2 (data ready strobe) to high
00047 $0233  6D 01          LOOP3   TST     1, X        ; done printing this char?
00048 $0235  2A FC                  BPL     LOOP3
00049 $0237  E6 00                  LDA B   0, X        ; clear the interrupt
00050 $0239  39                     RTS