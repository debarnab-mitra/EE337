LED EQU P1

ORG 00H
	LJMP MAIN
	
ORG 200H

bin_2_EXCESS3: 

	USING 0
		PUSH PSW
		MOV LED, #0FH
		LOOP:	
		
		MOV LED, #0FFH   ; SET THE PINS P1.7-P1.0 
		MOV 4FH , #10
		LCALL DELAY ; WAIT FOR 5 SECS IN WHICH THE USER CAN GIVE INPUT THROUGH SWITCHES
			
		;CLEAR P1.7- P1.4
		MOV A, LED
		ANL A, #0FH
		MOV LED, A
		
		
		MOV 4FH, #2
		LCALL DELAY ; WAIT FOR 1 SEC
		
		MOV A, LED ; READ THE INPUT ON P1.3- P1.0	
		
	VALUE_CHANGED:
		MOV 4EH, A

		CLR C
		ANL A, #0FH
		SUBB A, #10
		
		JC NEXT ; NO IS LESS 3 
		; ELSE BLINK ALL LEDS WITH A 5 SEC DELAY BETWEEN THEN TWICE
		MOV A , #0FFH
		MOV LED , A;
		MOV 4FH , #2
		LCALL DELAY
		MOV A, #00H
		MOV LED, A
		LCALL DELAY
		MOV A , #0FFH
		MOV LED , A;
		SJMP NEXT1
		
		
		
		NEXT: 
		MOV A, 4EH
		ADD A ,#03
		SWAP A;
		ORL A, #0FH
		
		
		
		MOV LED, A;
		MOV 4FH , #10
		LCALL DELAY 
		
	NEXT1:	MOV A, LED
	SJMP LOOP
	;	
	;;	ANL A, #0FH
	;	CJNE A,#0FH , LOOP
		
;	DISPLAY_OLD:	
;		MOV A, 4EH
;;		SWAP A;
	;	ORL A, #0FH;
	;	MOV LED, A;
	;;	MOV 4FH , #10
		;LCALL DELAY 
	;	MOV A, LED;
	;	ANL A, #0FH
	;	CJNE A,#0FH, VALUE_CHANGED;
	;	SJMP DISPLAY_OLD	
		
		
		
		
		
		
		POP PSW
		
		
			
		


RET

; SUNROUTINE WHICH GIVES DELAY OF 5 SECS
DELAY:

	USING 0
	PUSH PSW
	PUSH AR3
	PUSH AR2
	PUSH AR1
	PUSH AR0

	MOV R3, 4FH
	
	
	BACK2: 
		MOV R0, #0AH
		BACK10:
			MOV R2, #200
			BACK1:
				MOV R1 , #0FFH
				BACK:
					DJNZ R1, BACK
				DJNZ R2, BACK1
			DJNZ R0, BACK10	
		DJNZ R3,BACK2		

	POP AR0
	POP AR1
	POP AR2
	POP AR3
	POP PSW
	
	RET




ORG 40H
MAIN: 
	
	LCALL bin_2_EXCESS3
	STOP : SJMP STOP
	
END	