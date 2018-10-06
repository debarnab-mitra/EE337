org 00h
	ljmp main

org 000bh
	
	ljmp handle_T0_interrupt

main:	
	
	mov r7, #40
	lcall initialisation
	setb TR0 ; starting the timer
	
	
	
	here: sjmp here
	
initialisation: ; this will give a delay of 0.05 secs	
	
	mov TMOD ,#00000001b
	mov TH0 , #3Ch ; these values will give an interrupt signal after of 0.025 secs
	mov TL0 , #0B0h
	
	mov IE ,#82h ; enabling the interrupt corresponding to T0
	
	ret
	
handle_T0_interrupt:
	
	
	djnz r7 , load_again
		; else done 
		;clr tr0
		cpl p1.0
		mov r7, #40
		
			
	load_again:
		mov TH0 , #3Ch ; loading it again
		mov TL0 , #0B0h
		;mov IE ,#82h
		;setb TR0
	
	return:
		reti
		