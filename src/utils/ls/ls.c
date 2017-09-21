#include <stdio.h>
#include <string.h>
#include <fslib.h>

//****** LS UTIL ********

//uses the following APIs that BasicOS 16 provides
//printstr(str) - to print output to the screen
//list_files() - to get files list
//serves as a tool to get list of files (programs) on BasicOS
 
void main() {		
	char *str = list_files();	
	printstr(str);
	printstr("\r\n");
	return;
}