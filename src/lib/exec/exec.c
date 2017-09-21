#include <exec.h>  
#include <string.h>

#define SERVICE_ID 2
#define BUFF_SIZE 512

//The library provides API to run the programs 

char *exec(char *str) {
	int service = SERVICE_ID; //exec service id
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
	return param;
}
