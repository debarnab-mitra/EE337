org 00h
	ljmp main

org 100h
main:
	sjmp loop
old_data:
						;display data from 4eh
	lcall readnibble	;read the input on P1.0-P1.3 (nibble)
						;if read value != 0Fh go to loop
						;else return to caller with previously read nibble in location 4EH (lower 4 bits).
	
loop:
						;turn on all 4 leds (routine is ready to accept input)
						;wait for 5 sec during which user can give input 
						;clear pins P1.4 to P1.7
	lcall readnibble	;read the input on P1.0-P1.3 (nibble)
						;wait for one sec
						;show the read value on pins P1.4-P1.7
						;wait for 5 sec 
						;clear leds
						;read the input from switches
						;if read value != 0Fh go to loop
						;else return to caller with previously read nibble in location 4EH (lower 4 bits).
						
						
stop:
	sjmp stop
	
readnibble:
						; set pins 0-3 for configuring as input pins
						; read value on pins

