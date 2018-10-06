ORG 00H
LJMP MAIN

ORG 100H
	
ZEROOUT:

	USING 0
	PUSH PSW
	PUSH AR0
	PUSH AR1
	
	
	MOV R1, 50H ; VALUE OF N
	MOV R0, 51H ; VALUE OF POINTER
	LOOP:
		MOV @R0, #00H
		INC R0
		DJNZ R1, LOOP
		
	POP AR1
	POP AR0
	POP PSW
	
	RET

BIN2ASCII:
	
	USING 0
	PUSH PSW
	PUSH AR4
	PUSH AR3
	PUSH AR2
	PUSH AR1
	PUSH AR0
	MOV R2, 50H; VALUE OF N
	MOV R0 , 51H; VALUE OF READ POINTER
	MOV R1 , 52H; VALUE OF WRITE POINTER


	LOOP_BIN2ASCII:
	MOV A, @R0;
	MOV R3, A;  TEMPORARILY STORING THE VALUE OF A
	ANL A, #0FH ; MAKING THE UPPER NIBBLE 0000
	MOV R4, A; STORING THE LOWER NIBBLE
	
	SUBB A, #0AH ; TO CHECK IF THE LOWER NIBBLE IS DIGIT OR ALPHABET
	JNC ALPHA ;-- if carry is not set then the nibble was an alphabet
	
	MOV A, R4;
	ADD A, #30H ; ESLE ITS A DIGIT; CONVERTING THE LOWER NIBBLE TO ASCII
	INC R1
	MOV @R1, A
	DEC R1
	JMP NEXT
	
	ALPHA: MOV A, R4;
	ADD A, #37H
	INC R1
	MOV @R1,A
	DEC R1
	
	NEXT:
	MOV A, R3;
	ANL A,#0F0H ; MAKING THE LOWER NIBBLE 0000
	SWAP A; SWAPPING THE UPPER AND LOWER NIBBLE
	MOV R4,A; TEMPORARILY STORING THE UPPER NIBBLE
	SUBB A, #0AH
	JNC BETA ;-- if carry is not set then the nibble was an alphabet

	MOV A,R4
	ADD A, #30H ;ELSE THE NIBBLE IS A DIGIT
	
	MOV @R1,A
	INC R1
	JMP NEXT1
	
	BETA: MOV A, R4;
	ADD A, #37H
	MOV @R1,A
	INC R1
	
	NEXT1:
	INC R0
	INC R1
	DJNZ R2, LOOP_BIN2ASCII
	
	POP AR0
	POP AR1
	POP AR2
	POP AR3
	POP AR4
	POP PSW
	
	RET
	
	
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
	
	
	;MOVE INTO STACK
	
	LOOP_MEMCPY: 
		MOV B, @R0
		MOV R3, B
		PUSH AR3
		INC R0
		INC R1
		DJNZ R2, LOOP_MEMCPY
		
	;POP INTO NEW LOCATION
	DEC R1
	MOV R2, A
	LOOP1_MEMCPY:
		
		POP AR3
		MOV B,R3
		MOV @R1,B
		DEC R1
		DJNZ R2, LOOP1_MEMCPY
		
	POP AR0
	POP AR1
	POP AR2
	POP AR3
	POP PSW
	
	RET
	
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
		
   LOOP_DISPLAY:MOV A, @R0;
		ANL A, #00001111B
		MOV LED, A
		MOV 88H, A
		LCALL DELAY
		INC R0;
		DJNZ R1, LOOP_DISPLAY
		
		
		POP AR1;
		POP AR0
		POP PSW
		
		RET
		
		
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


MAIN: 

	MOV SP , #0CFH;
	MOV 50H, #0EH ; ARRAY A IS CLEARED
	MOV 51H, #60H
	LCALL ZEROOUT;
	
	MOV 50H, #0EH ; ARRAY B IS CLEARED
	MOV 51H, #70H
	LCALL ZEROOUT;
	
	MOV 50H, #0EH ; FILLING A WITH ASCII NO.S
	MOV 51H, #40H
	MOV 52H ,#60H
	LCALL BIN2ASCII;
	
	MOV 50H, #0EH ; COPYING A TO B
	MOV 51H, #60H
	MOV 52H ,#70H
	LCALL MEMCPY;
	
	MOV 50H, #0EH ; LED
	MOV 51H, #70H
	MOV 4FH ,#02H
	LCALL DISPLAY;
	

	STOP: SJMP STOP 	
	END