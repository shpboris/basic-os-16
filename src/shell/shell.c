#include <stdio.h>
#include <string.h>
#include <exec.h>

//************* SHELL *************

//uses the following APIs that BasicOS 16 provides
//printstr(str) - to print output to the screen
//getstr() - to get input from user
//exec(str) - to run the required program
//provides the interface to execute commands on BasicOS 16
 

 void main() {		
	char *str = "started shell...\r\n";
	
	printstr(str);
	printstr("\r\n");
	printstr("# "); //shows a simple prompt to user
	while(1){
		char *str = getstr();  //gets a string
		printstr("\r\n");
		
		if(strcmp(str,"exit") == 0){
			printstr("exiting shell ...\r\n");
			return;
		}
		else{
			exec(str); //ask kernel to run program
		}

		printstr("\r\n");
		printstr("# ");
	}
}
