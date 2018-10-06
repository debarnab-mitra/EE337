; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
LJMP start

ORG 200H
init:
	MOV R1,#60H
	MOV A,#0
	MOV R2,#16
store:
	MOV @R1,A
	INC R1
	INC A
	DJNZ R2,store
	RET
	
start:
	LCALL init
main:
	MOV SP,#0CFH
	
	LCALL display_LCD
	MOV A,#82					;shows R for read mode
	acall lcd_senddata	  
	
	LCALL readNibble
	LCALL Delay_1s
	SWAP A
	MOV R1,A
	;LCALL readNibble
	;CJNE A,R1,main
	
	LCALL display_LCD
	MOV A,#87					;shows W for write/display
	acall lcd_senddata
	MOV P1,#00H
		
	LCALL displayValues
	LCALL Delay_5s
	LCALL displayValues
	LCALL Delay_5s
	SJMP main

display_LCD:
	USING 0
	PUSH ACC
	acall delay
	acall delay
	acall lcd_init      ;initialise LCD
	acall delay
	acall delay
	acall delay
	mov A,#81H		 ;Put cursor on first row,1 column
	acall lcd_command	 ;send command to LCD
	acall delay
	POP ACC
	ret	

displayValues:
	MOV R2,#4
	MOV R3,#81H
	ACALL display_LCD

more:
	mov A,R3		 		;Put cursor on first row,2 column
	acall lcd_command	 	;send command to LCD
	MOV A,@R1
	ACALL bin2ascii
	MOV A,R6
	ACALL lcd_senddata
	acall delay
	acall delay
	acall delay
	INC R3
	mov A,R3		 		;Put cursor on first row,1 column
	acall lcd_command	 	;send command to LCD
	acall delay
	MOV A,R7
	ACALL lcd_senddata
	MOV A,R3
	ADD A,#3
	MOV R3,A
	INC R1
	DJNZ R2,more
	
	MOV R2,#4
	MOV R3,#0C1H
	
onemore:
	mov A,R3		 		;Put cursor on first row,2 column
	acall lcd_command	 	;send command to LCD
	MOV A,@R1
	ACALL bin2ascii
	MOV A,R6
	ACALL lcd_senddata
	acall delay
	acall delay
	acall delay
	INC R3
	mov A,R3		 		;Put cursor on first row,1 column
	acall lcd_command	 	;send command to LCD
	acall delay
	MOV A,R7
	ACALL lcd_senddata
	MOV A,R3
	ADD A,#3
	MOV R3,A
	INC R1
	DJNZ R2,onemore
	
	RET
		
readNibble:
	ORL P1,#0FFH
	ACALL Delay_5s
	MOV A,P1			
	ANL A,#0FH
	RET

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 	 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

bin2ascii:
	MOV A,@R1
	ANL A,#0F0H
	SWAP A
	LCALL convert
	MOV R6,A
	
	MOV A,@R1
	ANL A,#0FH
	LCALL convert
	MOV R7,A
	RET

convert:
	USING 0
	PUSH AR5
	ADD A,#30H
	MOV R5,A
	CLR C
	SUBB A,#3AH
	JC done
	CLR C
	MOV A,R5
	ADD A,#07H
	MOV R5,A
done:
	MOV A,R5
	POP AR5
	RET

DELAY_5s:
	USING 0
	PUSH PSW
	PUSH AR3
	MOV R3,#5
	LOOP_3s: 
		LCALL DELAY_1s
		DJNZ R3,LOOP_3s
	POP AR3
	POP PSW
	RET

DELAY_1s:
	USING 0
	PUSH PSW
	PUSH AR1
	PUSH AR2
	PUSH AR3
	MOV R3,#20
	LOOP_1s: 
		LCALL DELAY_50ms
		DJNZ R3,LOOP_1s
	POP AR3
	POP AR2
	POP AR1
	POP PSW
	RET

DELAY_50ms:
	USING 0
	MOV R2,#200
	BACK1:
		MOV R1,#0FFH
	BACK:
		DJNZ R1, BACK
		DJNZ R2, BACK1
	RET

delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret

END