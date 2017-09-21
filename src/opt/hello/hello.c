#include <stdio.h>
#include <string.h>

//****** HELLO WORLD PROGRAM ********

//uses the following APIs that BasicOS 16 provides
//printstr(str) - to print output to the screen
//the most primitive test to run a program on top of BasicOS
 
void main() {		
	char *str = "Hello World!\r\n";	
	printstr(str);
	return;
}