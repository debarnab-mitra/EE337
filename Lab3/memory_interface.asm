

ORG 00H
	LJMP MAIN
	
ORG 40H

MAIN:

; SET ALL THE OUTPUTS PORTS


	MOV R0, #10H ; DPL
	MOV R1, #100;
	MOV R3, #00h

LOOP:
;READ
	
	setb p1.1;
	clr p3.6 ; 
	setb p3.7 ; 
	clr p1.0;
	MOV 83H, R0
	MOV 82H, #00H
	MOVX A, @DPTR;
	INC R0
	
;WRITE
	
	clr p3.7
	setb p3.6
	setb p1.0
	MOV 83H, R3
	MOV 82H, #00H
	MOVX @DPTR, A
	INC R3
	
	DJNZ R1,LOOP ;
	
	STOP: SJMP STOP	
	
END

