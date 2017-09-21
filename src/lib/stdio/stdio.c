#include <stdio.h> 
#include <string.h>

//The library provides IO API to the user

#define PRINT_SERVICE_ID 0
#define GET_SERVICE_ID 1
#define BUFF_SIZE 512



//the library method to print string to screen
void printstr(char *str) {
	int service = PRINT_SERVICE_ID;  //print service id
	int buff_length;
	static char buff[BUFF_SIZE];          
	static char * param = buff;
	buff_length = strlen(str);
	memcpy(buff, str, buff_length + 1);
	asm {
		mov si,[param]      //puts the param parameter to SI register so it will be accessible in interrupt handler wrapper in core-hd.asm
		mov bx, [service]   //puts the service number to BX so it will be accessible in interrupt handler wrapper in core-hd.asm
		int 80h             //calling my software defined interrupt handler - see the corresponding configuration of IVT 
		                    //in core-hd.asm to understand why 0x80 is used. The handler "understands" what to do based on values of BX and SI
							//registers that are set here
	}
}

//the library method to get string from keyboard
char *getstr(){
	int service = GET_SERVICE_ID;  //get string service id
	static char str[BUFF_SIZE];         
	static char * param = str;    
	                              
	asm {					//the code below is the same as for printstr() method - see explanations above
		mov si,[param]
		mov bx, [service]
		int 80h
	}
	return str;
}
