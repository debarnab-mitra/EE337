ORG 00H
	LJMP DISPLAY

ORG 40H
	DISPLAY:
	
	LED EQU P1;
		
		USING 0
		PUSH PSW
		PUSH AR0
		PUSH AR1
	
		MOV 4FH, #02H
		MOV R1, 50H ; VALUE OF N
		MOV R0, 51H ; VALUE OF POINTER
		MOV LED,#00H
		
   LOOP:MOV A, @R0;
		ANL A, #00001111B
		MOV LED, A
		LCALL DELAY
		INC R0;
		DJNZ R1, LOOP
		
		
		POP AR1;
		POP AR0
		POP PSW
		
		;RET
		STOP: SJMP STOP
		
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
	
END	