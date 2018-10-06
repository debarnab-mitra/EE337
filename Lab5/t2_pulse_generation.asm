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
	
org 02Bh
	ljmp it_timer2
	
	
main:

	ANL T2MOD,#0FCh; 				 /* T2OE=0;DCEN=1; */
	ORL T2MOD,#00h;
   CLR EXF2;                   /* reset flag */
   CLR TCLK;
   CLR RCLK;                   /* disable baud rate generator */

   CLR EXEN2;                  /* ignore events on T2EX */ 
   MOV TH2,#0E8h;	 /* Init msb_value */
   MOV TL2,#90h;	 /* Init lsb_value */
   MOV RCAP2H,#0E8h;/* reload msb_value */
   MOV RCAP2L,#90h;/* reload lsb_value */
   CLR C_T2;                   /* timer mode */
   CLR CP_RL2;                 /* reload mode */
   
   clr ET2
   SETB EA;                    /* interupt enable */
   SETB ET2;                   /* enable timer2 interrupt */
   SETB TR2;                   /* timer2 run */
   
   
   here: sjmp here
   
it_timer2:
	CLR TF2;						/* reset  interrupt flag */
	CPL P1.0;					/* P1.2 toggle when interrupt. */
   RETI

end
   
