ORG 0000H
LJMP MAIN

;R0 and R1 should contain the address of two no.s
;location given by R0:- 	MSB of 1st no.
;location given by R0+1:-	LSB of 1st no.
;location given by R1:- 	MSB of 1st no.
;location given by R1+1:-	LSB of 1st no.
;location given by R0+2:- 	CARRY	
;location given by R0+3:-	MSB OF ANS	
;location given by R0+4:- 	LSB OF ANS

;---------------------------------------------------------;
;this function adds and stores result in appropriate location
ADDER_16BIT:

	;-- push the registers which will be affected by this subroutine 
	;	but will be needed later 	
	
	;-- perform the addition/subtraction of 2 16-bit no.s
	;-- you may use subroutine wrtten for addition of 2 8-bit no.s
	;-- remember the no.s are given in 2's complement form
	
	;-- take care when you set carry/borrow.
	
	;-- store the result at appropriate locations.
	using 0
		PUSH AR0  ; here we push all the registers which are affected by this subroutine
		PUSH AR1 ; will be poped back at the end
		MOV R0, #60H ; memory location of the MSB of 1st no.
		MOV R1, #70H ; memory location of the MSB of 2nd no.
		
		; first we have to add the LSB of the two numbers
		INC R0;	points to the memory location of the lsb of the 1st no. --61
		INC R1; points to the memory location of the lsb of the 2nd no. --71
		MOV A, @R0 ;
		ADD A, @R1 ; 
		INC R0; --62H
		MOV @R0,#00H ; Big endian form
		INC R0;  --63H
		INC R0;	 --64H
		MOV @R0,A ;

		; adding msb of the 2 no.s
		DEC R0; --63H
		DEC R0;  -- 62H
		DEC R0; --61H
		DEC R0; --60H  point to msb of 1st no.
		DEC R1; points to the msb of 2nd no. --70H
		CLR A;
		MOV A, @R0;
		ADDC A, @R1;
		MOV B, A;
		CLR A;
		ADDC A , #0H;
		MOV R7, A;
		MOV A, @R0;
		
		SUBB A, #7FH;
		JNC next
		MOV R4, #01H
		
next:   

		MOV A ,@R1;
		MOV R6, A;
		SUBB A, #7FH
		JNC next1
		MOV R5, #01H


next1:

		
		
		INC R0; 61H
		INC R0 ;-- 62H
		INC R0; --63H
		MOV @R0, B;
		CLR A;
		MOV A , R4;
		XRL A, R5;
		MOV R5,A;
		ADDC A , R7;
		XRL A, R5;
		ANL A, #01H;
		DEC R0; -- 62H
		MOV @R0, A;
		 
		
		
		
		
		
	
	RETURN:	
	POP AR1;
	POP AR0;
	;-- pop the registers
	RET

INIT:
	;-- store the numbers to be added/subtracted at appropriate location
	MOV 60H, #0FFH
	MOV 61H, #0F9H
	MOV 70H, #07FH
	MOV 71H, #0FFH
	; RESULT = 1FFFE;
	
	
	;MOV 60H, #80H
	;MOV 61H, #00H
	;MOV 70H, #00H
	;MOV 71H, #01H
	; RESULT = 18001
	
	;MOV 60H, #80H
	;MOV 61H, #00H
	;MOV 70H, #07FH
	;MOV 71H, #0FFH
	; RESULT = 1FFFF
	
	RET


ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	ACALL INIT
	ACALL ADDER_16BIT
	
	
	
	STOP: SJMP STOP	
END
