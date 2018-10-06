/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"


/* function prototype */
void Timer1_Init();
void Serial_Init();
void delay_ms(int delay);


/*variable declaration */
unsigned char overflow = 0;
char to_be_transmited = 'A';
bit parity = 0;

 
void main(void)
{	
	
	Timer1_Init();
	Serial_Init();
	TR1 = 1;
	ACC = to_be_transmited;
	ACC = ACC + 0; // will set the parity flag
	parity = PSW^0;
	TB8 = parity;
	SBUF = to_be_transmited;
	while(1)												// endless 
	{		
		
		
  }
}


void ISR_Serial(void) interrupt 4 {

	if(TI == 1){
				P1 = ~P1;
				//delay_ms(1000);
		
		
		TB8 = parity;
		SBUF = to_be_transmited;
	
		//parity calculation for even case;
		// TB8 s.t total no of 1 bits in the frame = even 
		//ACC = to_be_transmited;
		
		

		TI =0;
	
	}
	
	
}


void timer0_ISR (void) interrupt 1
{
}


	/**
 * FUNCTION_PURPOSE:Timer Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */

void Timer1_Init()
{

	TMOD = 0x20;
	TH1 = 0xCC;
	TL0 = 0x00;
	
}


void Serial_Init()
{
	
	SCON = 0x90; // receive is disabled
	// serial init
	EA = 1;
	ES = 1;
	
	
}


void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}

