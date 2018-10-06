/**
 SPI HOMEWORK2 , LABWORK2 (SAME PROGRAM)
 */

/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"


/* function prototype */
void Timer_Init();


/*variable declaration */
unsigned char overflow = 0;

 
void main(void)
{	
	P1 = 0x00;
	
	Timer_Init();
	
	while(1)												// endless 
	{		
		
  }
}


void timer0_ISR (void) interrupt 1
{
	//Initialize TH0
	//Initialize TL0
	//Increment Overflow 
	//Write averaging of 10 samples code here
	TH0 = 0x3C;
	TL0 = 0xB0;
	TF0 = 0;
	overflow = overflow+1;
	P1 = ~P1;
	

}


	/**
 * FUNCTION_PURPOSE:Timer Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */

void Timer_Init()
{
	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
	// 65536 depending upon the calues of TH0 and TL0
	// The timer counts 65536 processor cycles. A processor cycle is 
	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
    
	//Initialize TH0
	//Initialize TL0
	//Configure TMOD 
	//Set ET0
	//Set TR0
	
	TH0 = 0x3C;
	TL0 = 0xB0;
	TMOD = 0x01;
	EA = 1;
	ET0 = 1;
	TR0 = 1;
	
	
}

