org 0h
LED	EQU P1
ljmp main

org 50H
	

readnibble:
	;MOV A,LED
	ANL A,#0FH
	MOV LED,A
	RET

main : 
         ;MOV LED, #0FFH
		 MOV A,LED
		 LCALL readnibble
		 MOV R0,A
		 SUBB A,#10
		 JC LOOP 
		 MOV A,#0F0H
		 MOV LED,A
		 lcall Delay
		 MOV A,#0EFH
		 MOV LED, A
		 LCALL Delay
		 SJMP main
		 LOOP : 
		 MOV A,R0
		 ADD A,#3
		 MOV R3,#4
		 SHIFT : 
		 RLC A
		 DJNZ R3,SHIFT
		 ANL A,#0F0H
		 MOV LED,A
		 lcall Delay
		 ;MOV A,R0
		 ;MOV LED,A
		 MOV A, #0EFH
		 MOV LED, A
		 LCALL Delay
		 SJMP main
		 HERE : SJMP HERE
		 
		 Delay:
		 using 0
	     push ar0
		 push ar1
		 push ar2
		 push ar3
    ;MOV A,#0CH
    ;MOV LED,A 
	MOV R3,#10
	
	LOC3:
		MOV R0, #10
		LOC2:
		MOV R2, #200
		BACK3:
		MOV R1, #0FFH
		BACK2:
		DJNZ R1, BACK2
		DJNZ R2, BACK3
		DJNZ R0, LOC2
		DJNZ R3, LOC3
		
		pop ar3
		pop ar2
		pop ar1
		pop ar0
	RET
		END	  
		 
		 
		 
		 