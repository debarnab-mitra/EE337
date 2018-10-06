ORG 00H
	LJMP MEMCPY

ORG 40H
	
MEMCPY:
	
	USING 0
	PUSH PSW
	PUSH AR3
	PUSH AR2
	PUSH AR1
	PUSH AR0
	
	MOV R2, 50H; VALUE OF N
	MOV A,R2; SAVING THE VALUE OF N
	MOV R0 , 51H; VALUE OF READ POINTER
	MOV R1 , 52H; VALUE OF WRITE POINTER
	
	
	MOV A, R0;
	CLR C
	SUBB A,R1;

	JNC NORMALCOPY ;  IF CARY IS NOT SET A>B NORMALCOPY
	
	
	BACKCOPY:  ; ELSE BACK COPY
	MOV A, R0;
	ADD A,R2
	MOV R0, A
	MOV A,R1;
	ADD A ,R2	
	MOV R1,A
	DEC R0
	DEC R1
	LOOP_BACKCOPY:
		MOV A,@R0
		MOV @R1,A
		DEC R0
		DEC R1
		DJNZ R2, LOOP_BACKCOPY
	
	
	SJMP NEXT
	
	NORMALCOPY: 
	LOOP_NORMALCOPY:
	MOV A, @R0;
	MOV @R1, A;
	INC R0;
	INC R1;
	DJNZ R2, LOOP_NORMALCOPY
		
		
	NEXT: 
	POP AR0
	POP AR1
	POP AR2
	POP AR3
	POP PSW
	;RET
	
	STOP: SJMP STOP 	
	END