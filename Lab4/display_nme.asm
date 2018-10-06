; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:
      mov P2,#00h
      mov P1,#00h
	  ;initial delay for lcd power up

	;here1:setb p1.0
      	  acall delay
	;clr p1.0
	  acall delay
	;sjmp here1


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
	  
	  acall store_name  ;call the subroutine which stores the name in upper ram
	  
	  ;calculation for centering
	  
	  mov r0, #90h ; 90H in indirectly addressable memory stores the length of the name
	  mov 2H, @r0 ; copy the length of the name to R2
	  
	 ; subtract length from 16 and divide by 2
	 mov a, #16 ; move 16 into accumulator
	 clr c ; clear carry before subtracting
	 subb a, r2 ; subtract r2 i.e. the length of the name from a i.e. 16
	 mov b, #2 ; move 2 into b
	 div ab ; divide a i.e. the result of the subtraction by b i.e. 2

	  ; take the bitwise OR of ACC, which store the number of spaces to be left
	  ; with C0H to get the command byte which needs to be sent to move the cursor
	  orl a, #0C0h
	  acall lcd_command
	  acall delay
	  mov r0, #80h ; name starts from here	
 
	; the following loop writes the name on the LCD character by character
	write_name:
		mov a, @r0
		acall lcd_senddata
		inc r0
		djnz r2, write_name

here: sjmp here				//stay here 

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
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret
	 
;------------- Upper RAM name string---------------------------------------------------------------
store_name:
	using 0
	push ar0
	mov r0, #80h
	mov @r0, #'D'
	inc r0
	mov @r0, #'e'
	inc r0
	mov @r0, #'b'
	inc r0
	mov @r0, #'a'
	inc r0
	mov @r0, #'r'
	inc r0
	mov @r0, #'n'
	inc r0
	mov @r0, #'a'
	inc r0
	mov @r0, #'b'
	inc r0
	mov r0, #90h
	mov @r0, #8
	pop ar0
	ret

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "EE 337 - Lab 2", 00H
my_string2:
		 DB   "Debarnab Mitra", 00H
end

