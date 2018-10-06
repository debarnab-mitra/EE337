lcd_data equ p2
lcd_rs equ p0.0	;register select
lcd_rw equ p0.1	;read/write
lcd_en equ p0.2	;enable
	
	
; Defining Timer-2 registers 
	T2CON DATA 0C8H 
	T2MOD DATA 0C9H 
	RCAP2L DATA 0CAH 
	RCAP2H DATA 0CBH 
	TL2 DATA 0CCH 
	TH2 DATA 0CDH 
; Defining interrupt enable (IE) bit 
	ET2 BIT 0ADH 
; Defining interrupt priority (IP) bit 
	PT2 BIT 0BDH 
; Defining P1 
	T2EX BIT 91H 
	T2 BIT 90H 
; Defining timer control (T2CON) register bits 
	TF2 BIT 0CFH 
	EXF2 BIT 0CEH 
	RCLK BIT 0CDH 
	TCLK BIT 0CCH 
	EXEN2 BIT 0CBH 
	TR2 BIT 0CAH 
	C_T2 BIT 0C9H 
	CP_RL2 BIT 0C8H	

org 00h
	ljmp main
	
org 0003h ; interupt service routine for ex0
		ljmp external_interrupt

org 000bh
		ljmp T0_overflow_interrupt

org 02bh
		ljmp T2_overflow_control


main:
	
	mov sp, #0cfh ;-- initialising stack pointer to CFH
	mov r7, #0000h ; will be incremented each time TF1 is set
	;setb p3.2 ; set it as input port
	
	
		acall lcd_init      ;initialise LCD
	
		acall delay
		acall delay
		acall delay

		mov a,#81h		 ;Put cursor on first row,1 column
		acall lcd_command	 ;send command to LCD
		acall delay
		mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
		acall lcd_sendstring	   ;call text strings sending routine
		acall delay
		
		lcall initialization
		lcall T2_init
		
		
		;mov p1, #00h
		setb tr2
		
		
		
		


here: sjmp here
	
T2_init:
	
	ANL T2MOD,#0FCh; 				 /* T2OE=0;DCEN=1; */
	ORL T2MOD,#00h;
   CLR EXF2;                   /* reset flag */
   CLR TCLK;
   CLR RCLK;                   /* disable baud rate generator */

   CLR EXEN2;                  /* ignore events on T2EX */ 
   MOV TH2,#0FCh;	 /* Init msb_value */
   MOV TL2,#018h;	 /* Init lsb_value */
   MOV RCAP2H,#0FCh;/* reload msb_value */
   MOV RCAP2L,#018h;/* reload lsb_value */
   CLR C_T2;                   /* timer mode */
   CLR CP_RL2;                 /* reload mode */
   ;SETB PT2
   ;clr ET2
   SETB EA;                    /* interupt enable */
   SETB ET2;                   /* enable timer2 interrupt */
   SETB TR2;          
		
		ret
		
T2_overflow_control:
		
		clr TF2
		mov T2MOD,#02h;
		cpl p1.0
		cpl p1.7
		mov T2MOD,#00h;
		reti

initialization:	
		
		mov TMOD ,#00001001b ; gate enabled mode 1
		mov TH0, #00h
		mov TL0, #00h
		;setb p3.2
		
		wait_new_pulse:
			;jb p3.2 , wait_new_pulse
			
		; interrupt configuration
		mov TCON, #01h
		mov IE,#83h ; EA =1; T0 =1; EX0 = 1
		setb TR0
		ret
		
		
T0_overflow_interrupt:	
		inc r7;
		mov TH0, #00h
		mov TL0, #00h
		reti

external_interrupt:

		;stop the timer
		clr TR0;
		read: 
			mov R1, TH0;
			mov R0, TL0;
			
			
		;-------
		
		
		;--------
			
		mov a, #0C0h
		acall lcd_command	 ;send command to LCD
		acall delay
		mov   dptr,#my_string2   ;Load DPTR with sring1 Addr
		acall lcd_sendstring	   ;call text strings sending routine
		acall delay
		;acall lcd_command
		acall delay
		
		mov 60h, R7; store the value in r7	
		mov 55h, #60h ; tell the bintoascii to read from 60h
		mov 40h, #45h ; result will be written in 45h and 46h
		lcall BIN2ASCII
		mov a,45h
		acall lcd_senddata
		mov a, 46h
		acall lcd_senddata 
		
		mov 60h, R1; store the value in r7	
		mov 55h, #60h ; tell the bintoascii to read from 60h
		mov 40h, #45h ; result will be written in 45h and 46h
		lcall BIN2ASCII
		mov a,45h
		acall lcd_senddata
		mov a, 46h
		acall lcd_senddata 
		
		mov 60h, R0; store the value in r7	
		mov 55h, #60h ; tell the bintoascii to read from 60h
		mov 40h, #45h ; result will be written in 45h and 46h
		lcall BIN2ASCII
		mov a,45h
		acall lcd_senddata
		mov a, 46h
		acall lcd_senddata 
		
		
		reti
		
;------------------------LCD Initialisation routine---------------------------------------------------
lcd_init: 
	mov LCD_data,#38H ;Function set: 2 Line, 8-bit, 5x7 dots 
	clr LCD_rs ;Selected command register 
	clr LCD_rw ;We are writing in instruction register 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en 
	acall delay

	mov LCD_data,#0CH ;Display on, Curson off 
	clr LCD_rs ;Selected instruction register 
	clr LCD_rw ;We are writing in instruction register 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en
	acall delay

	mov LCD_data,#01H ;Clear LCD 	
	clr LCD_rs ;Selected command register 
	clr LCD_rw ;We are writing in instruction register 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en
	acall delay

	mov LCD_data,#06H ;Entry mode, auto increment with no shift 
	clr LCD_rs ;Selected command register 
	clr LCD_rw ;We are writing in instruction register 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en
	acall delay
	ret ;Return from routine



;-----------------------command sending routine------------------------------------
lcd_command: 
	mov LCD_data,A ;Move the command to LCD port 
	clr LCD_rs ;Selected command register 
	clr LCD_rw ;We are writing in instruction register 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en 
	acall delay
	ret

;-----------------------data sending routine------------------------------------
lcd_senddata: 
	mov LCD_data,A ;Move the command to LCD port 
	setb LCD_rs ;Selected data register 
	clr LCD_rw ;We are writing 
	setb LCD_en ;Enable H->L 
	acall delay 
	clr LCD_en 
	acall delay 
	acall delay 
	ret ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine
		 
		 
;----------------------delay routine----------------------------------------------------
delay: 
USING 0 
	PUSH AR0 
	PUSH AR1 
	mov r0,#1 
	loop2: 
	mov r1,#255 
	loop1: djnz r1, loop1 
	djnz r0,loop2 
	POP AR1 
	POP AR0 
	ret
;----------------------- CONVERSION TO ASCII ---------------
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
	
;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "PULSE WIDTH:", 00H
my_string2:
		 DB   "COUNT_IS: ", 00H
end	
	