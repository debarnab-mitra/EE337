org 00h
	ljmp main
	
main:	

	back:
		cpl p1.0
		lcall delay1sec
		sjmp back
	
	here: sjmp here
	
initialisation: ; this will give a delay of 0.05 secs	

	mov TMOD ,#00000001b
	mov TH0 , #3Ch
	mov TL0 , #0B0h
	; these values will give a delay of 0.05 secs
	ret
	
delay1sec: 
	
	using 0
	push psw
	push ar7
	
	mov r7 ,#40
	again:
		lcall initialisation
	
		setb TR0	
	wait: 
		jnb TF0, wait
		; borrow is set 
	
	clr TF0
	clr TR0
	djnz r7 ,again
	
	
	pop ar7
	pop psw
	ret
	
end	