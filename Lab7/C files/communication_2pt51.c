/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port


/* function prototype */
void Timer0_Init();
void Timer1_Init();
void Serial_Init();
void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_WriteString(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit test_pin = P1^7;




/*variable declaration */
unsigned char overflow = 0;
char to_be_transmited[16] = {"fghijklmnopabcde"};
int i = 0; //transmit_index
int j = 0; // receive index
char data_received = 'N';
bit parity = 0;
bit parity_received = 0;
bit switch_p1;
 
void main(void)
{	
	
		P2 = 0x00;											// Make Port 2 output
		P1 = 0x01;						//make it as input
		
	
	
		LCD_Init();
	
		LCD_CmdWrite(0x80);
		delay_ms(200);
		LCD_WriteString("Reciever",8);
		delay_ms(200);
		LCD_WriteString("  Data:",7);
		delay_ms(500);
		LCD_CmdWrite(0xC0);
		delay_ms(500);
		Timer1_Init();
		Timer0_Init();
		Serial_Init();
		TR1 = 1;
	
	//while(switch_p1 == 0){}
	//SBUF = to_be_transmited[0];
	//i++;
	TI = 1;
	while(1)												// endless 
	{		
		

		
  }
	

	
	
}


void ISR_Serial(void) interrupt 4 {

	if(TI == 1 && switch_p1 == 1){
				test_pin = ~test_pin;
				delay_ms(1);
		
		if(i < 16){SBUF = to_be_transmited[i];}
		
		i +=1;
		
		
		//SCON = 0x00;
					
		//delay_ms(500);
		//parity calculation for even case;
		// TB8 s.t total no of 1 bits in the frame = even 
		//ACC = to_be_transmited;
		//parity = PSW^0;
		//TB8 = parity;

		TI =0;
		
	
	}
	
	if(RI == 1){
		
		
		data_received = SBUF;
		j += 1;
		if( j  == 17){
		LCD_CmdWrite(0xC0);
		j = 0;}
		//parity_received = RB8; 
		

		LCD_DataWrite(data_received);
		//delay_ms(500);
		RI = 0;
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
	//P1 = ~P1;
	switch_p1 = P1^0;
	//RI = 1;
	
	//SCON = SCON || 0x01;
}


	/**
 * FUNCTION_PURPOSE:Timer Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */

void Timer0_Init()
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


void Timer1_Init()
{

	TMOD = 0x20;
	TH1 = 0xE8;
	TL0 = 0x00;
	
}


void Serial_Init()
{
	
	SCON = 0x90; // receive is disabled
	// serial interrupt
	EA = 1;
	ES = 1;
	ET1 = 0;
	
}



/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
	LCD_Ready();
	LCD_data=cmd;     			// Send the command to LCD
	LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  LCD_data=dat;	   				// Send the data to LCD
  LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
  LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}
/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_WriteString( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}


