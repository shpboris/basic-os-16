#include <fslib.h>  //imports HERE the method declarations
#include <string.h>

#define SERVICE_ID 3
#define BUFF_SIZE 512

//The library provides API to list the files

char *list_files(){
	int service = SERVICE_ID;        //get files service id
	static char str[BUFF_SIZE];      
	static char * param = str;    
	                              

	asm {					
		mov si,[param]      //puts the param parameter to SI register so it will be accessible in interrupt handler wrapper in core-hd.asm
		mov bx, [service]   //puts the service number to BX so it will be accessible in interrupt handler wrapper in core-hd.asm
		int 80h             //calling my software defined interrupt handler - see the corresponding configuration of IVT 
		                    //in core-hd.asm to understand why 0x80 is used. The handler "understands" what to do based on values of BX and SI
							//registers that are set here
	}
	return str;
}
