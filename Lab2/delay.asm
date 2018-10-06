

	LED	EQU P1.7	

		ORG 00H
		LJMP MAIN
		
;----------------------------------------------


	ORG 50H

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

;---------------------------------------------

MAIN:
		
		NOP
		MOV 4FH, #06H
		
  TASK1:SETB LED
		MOV 40H, #01H
		LCALL DELAY
		CLR LED
		MOV 40H, #00H
		LCALL DELAY
		SJMP TASK1
		
		
END		
		