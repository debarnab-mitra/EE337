org 0H

 
ljmp ADD8
 
org 100H

ADD8:
	
	MOV 50H, #11H;
	MOV 60H, #11H;
	MOV A, 50H ; 
	MOV R1, 60H ;
	ADD A, R1 ;
	MOV 70H, A ;
	
STOP: JMP STOP
	
END
	