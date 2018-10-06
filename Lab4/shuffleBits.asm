lcd_data equ p2
lcd_rs equ p0.0	;register select
lcd_rw equ p0.1	;read/write
lcd_en equ p0.2	;enable


org 00h
	ljmp start
	
org 200h

start:
	mov sp, #0cfh ;-- initialising stack pointer to CFH
	mov 50h, #3 ;-- 3 bytes to be read
	mov 51h, #60h ; storing them starting from 60H
	lcall read_values
	;mov 60h, #10101010b
	;mov 61h, #00000000b
	;mov 62h, #10101010b
	
	lcall shuffleBits;
	
	mov 51h, #70h ; changing the pointer value for displayValues
	;acall clear_lcd

	
	acall displayValues
	
	
	
	
	





here: sjmp here

shuffleBits:
	using 0
		
	push psw
	push ar4
		push ar3
		push ar2
		push ar1
		push ar0
		
	mov r1, #60h ; array pointer
	mov r3, 50h ; the value of k
	mov a, r1
	add a , r3
	mov r0,a
	mov a, @r1
	mov @r0, a
	
	
	mov r0, #70h
	shuffle_again:
	mov a, @r1
	mov r4, a
	
	inc r1;
	mov a, @r1
	dec r1;
	xrl a, r4
	mov @r0,a
	inc r0;
	inc r1;
	djnz r3, shuffle_again
	
	pop ar0
	pop ar1
	pop ar2
	pop ar3
	pop ar4
	pop psw
	ret

read_values:
	
	push psw
	push ar2
	push ar0
	mov r2, 50H ; the value of K -- K bytes to read
	mov r0, 51h ; value of p; have to read k values string from location p
	main_loop:
		lcall packNibble
		mov @r0,4fh;
		inc r0;
		djnz r2, main_loop
	pop ar0
	pop ar2
	pop psw
	
	ret

packnibble:
	
	push ar0
	
	lcall readNibble ;-- call readNibble to read the 4 bits and store it in lower 4 bits of 4EH
	mov a,  4EH ; this is the most signifcant bit
	swap a;
	anl a, #0f0h; ;-- ensuring that the value in the ACC has lower 4 bits as zeroes
	mov r0, a
	lcall readnibble ;-- call readNibble to read the 4 bits and store it in lower 4 bits of 4EH
	mov a, 4EH
	anl a , #0fh;
	orl 0, a; R0 = R0|ACC ,since R0 had upper 4 bits only and ACC had lower 4 bits
	mov 4fh, r0;
	pop ar0
	ret
	
	
	


readNibble:
	
	push ar0
	; Routine to read a nibble and confirm from user
	; First configure switches as input and LED’s as Output.
	; To configure port as Output clear it
	; To configure port as input, set it.
	; Logic to read a 4 bit number (nibble) and get confirmation from user
	;loop:
		;turn on all 4 leds (routine is ready to accept input)
		mov p1, #0ffh
		;wait for 5 sec during which user can give input through switches
		
		
		
		
		
		
		mov 4fh, #10 ;-- moving 10 to 4FH to generate a delay of 5 seconds from LCALL
		lcall delay1
		
		lcall lcd_init
		mov lcd_data, #81h	;moving the cursor to the first position
				clr lcd_rs
				clr lcd_rw
				setb lcd_en
				lcall delay
				clr lcd_en
				lcall delay
		mov a, #'1'
					mov lcd_data, a
					;inc r0
					;inc r2; incrementing r2 so as to check if it equals r2 which will decide the continuation of loop
					;now writing this data on lcd
					;----------------writing on lcd----------------------------------------------------------
					setb lcd_rs ; selected data register
					clr lcd_rw ;we are writing in the data register
					setb lcd_en ; enable h->l
					lcall delay
					clr lcd_en
					lcall delay
					lcall delayFor1sec
					lcall delayFor1sec
		;turn off all LEDS
		
		mov p1, #2fh
		;read the input from switches (nibble)
		mov 4fh, #10 ;-- moving 10 to 4FH to generate a delay of 5 seconds from LCALL
		lcall delay1
		mov r0, p1 ;-- P1 is saved in R0
		;wait for one sec
		mov 4fh, #2
		lcall delay1
		;show the read value on LEDs
		;mov a, r0 ;-- moving the read value from R0 to ACC
		;swap a
		;orl a, #0fh
		;mov p1, a
		;wait for 5 sec ( during this time delay User can put all switches to OFF
		;2position to signal that the read value is correct and routine can proceed to
		;next step)
		;mov 4fh, #10
		;lcall delay1
		;clear leds
		;mov p1, #0fh
		;read the input from switches
		;mov a, p1
		;if read value <> 0Fh go to loop
		;cjne a, #0fh, loop
	; return to caller with previously read nibble in location 4EH (lower 4 bits).
	mov 4eh, r0 ;-- moving the previously read nibble to lower bits of 4EH
	pop ar0
	ret
	
delay1:
	USING 0
	PUSH psw
	PUSH AR0 ;-- pushing the registers which are going to be
	PUSH AR1 ;-- used by this subroutine
	PUSH AR2
	MOV A, 4FH ;-- Move the value of D from 4FH to A
	MOV B, #10 ;-- Load 10 in B
	MUL AB     ;-- Multiply 10 with D to get the number of iterations for the 50ms loop
	MOV R0, A  ;-- Move the result to R0 which is used as the iterator in the loop
	BACK1:
		;-- the following is a nested loop which generates a
		;-- delay of 50ms. This delay has been iterated 10D
		;-- times to get a total delay of 500Dms = D/2 seconds
		MOV R2,#200
		BACK2:
			MOV R1,#0FFH
			BACK3:
				DJNZ R1, BACK3
			DJNZ R2, BACK2
		DJNZ R0, BACK1
	POP AR2 ;-- popping the register in the exact reverse order before
	POP AR1 ;-- exiting from the subroutine
	POP AR0
	POP psw
	RET	
;------------------	code for display values
	displayValues:
		push psw
		push ar2
		push ar1
		push ar0
		mov p2, #00h
		mov p0, #00h
		again:lcall lcd_init
			mov r0, 51h;r0 stores the pointer
			mov r1, 50h; r1 stores the value of k
			
			;getting the input from the switch
			mov a, #0ffh
			mov p1, a
			mov a, p1
			
			anl a, #00001111b
			
			mov r2, a
			clr c
			;--checking if the value is greater than or equal to k
			
			subb a, r1
			jnc invalid_input
			valid_input:
				mov a, r2;restoring the value of input
				add a, r0
				mov r0, a;storing the start index of the number in r0
				;--------------------------lcd command-------------------------------------------------------
				mov lcd_data, #81h	;moving the cursor to the first position
				clr lcd_rs
				clr lcd_rw
				setb lcd_en
				lcall delay
				clr lcd_en
				lcall delay
				
				loop_reading_bytes:
					mov 55h, r0;
					mov 40h, #45h
					lcall BIN2ASCII
					
					
					
					mov a, 45h
					mov lcd_data, a
					;inc r0
					;inc r2; incrementing r2 so as to check if it equals r2 which will decide the continuation of loop
					;now writing this data on lcd
					;----------------writing on lcd----------------------------------------------------------
					setb lcd_rs ; selected data register
					clr lcd_rw ;we are writing in the data register
					setb lcd_en ; enable h->l
					lcall delay
					clr lcd_en
					lcall delay
					lcall delayFor1sec
					lcall delayFor1sec
					
					mov a, 46h
					mov lcd_data,a
					
					;----------------writing on lcd----------------------------------------------------------
					setb lcd_rs ; selected data register
					clr lcd_rw ;we are writing in the data register
					setb lcd_en ; enable h->l
					lcall delay
					clr lcd_en
					lcall delay
					lcall delayFor1sec
					lcall delayFor1sec
					;mov a, r2
					;cjne a, 50h, loop_reading_bytes
				jmp stop
			invalid_input:
				lcall clear_lcd
				
			stop : sjmp again
		pop ar0
		pop ar1
		pop ar2
		pop psw
		ret			
			
;-------------------lcd_initialization---------------------------------------------------------------------------------------
lcd_init:
;---telling which mode to operate on
mov lcd_data, #038h;function set- 1 line, 8-bit, 5x7 font
clr lcd_rs; selected command register
clr lcd_rw; wiriting in the instruction register
setb lcd_en; enable high->low
lcall delay;
clr lcd_en
lcall delay

;turning on the display with cursor off
mov lcd_data, #0ch; function set - display on cursor off
clr lcd_rs; selected command register
clr lcd_rw; wiriting in the instruction register
setb lcd_en; enable high->low
lcall delay;
clr lcd_en
lcall delay


lcall clear_lcd

mov lcd_data, #0fh;entry mode, auto increment with no shift
clr lcd_rs; selected command register
clr lcd_rw; wiriting in the instruction register
setb lcd_en; enable high->low
lcall delay;
clr lcd_en
lcall delay

ret
;-----------------------------------------------------------------------











;-------------------lcd clearing instructions----------------------
clear_lcd:
	mov lcd_data, #01h;clear lcd
	clr lcd_rs; selected command register
	clr lcd_rw; wiriting in the instruction register
	setb lcd_en; enable high->low
	lcall delay;
	clr lcd_en
	lcall delay
ret
;---------------------------------------------------------------------
delayFor1sec:
	using 0
	push AR7
	push AR6
	push AR5
	mov r7, #20
			back2_1sec:
				mov r6, #200;this loop gives a delay of 50msec
				back1_1sec:
					mov r5, #0ffh
					back_1sec:
						djnz r5, back_1sec
					djnz r6, back1_1sec
				djnz r7, back2_1sec
	pop AR5
	pop AR6
	pop AR7
	ret
;--------------------------------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2_delay:	 mov r1,#255
	 loop1_delay:	 djnz r1, loop1_delay
	 djnz r0, loop2_delay
	 pop 1
	 pop 0 
	 ret
	 
	 
;---------------------------BIn to ascii
BIN2ASCII:
	
	USING 0
	PUSH PSW
	PUSH AR4
	PUSH AR3
	PUSH AR2
	PUSH AR1
	PUSH AR0
	MOV R2, #1;50H; VALUE OF N
	MOV R0 , 55H; VALUE OF READ POINTER
	MOV R1 , 40H; VALUE OF WRITE POINTER


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
	 
	 
	
end	