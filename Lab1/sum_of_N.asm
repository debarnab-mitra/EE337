org 0H

 
ljmp MAIN
 
org 100H
	
MAIN:
	
	using 0; using the 0th register bank
		
	MOV 50H,#08H;
	
	MOV R0, 50H ; storing the value of N in R0;
	MOV R1, #51H ; R1 has the address of the location where the partial sum has to be stored
	MOV R2, #0H ; R2 has the no. to be added to A
	MOV A, #0H; initialising A
	LOOP:
		
		INC R2;
		ADD A, R2; 
		MOV @R1 , A ;
		INC R1;
		DJNZ R0, LOOP ;
		
STOP: JMP STOP

END
		
		