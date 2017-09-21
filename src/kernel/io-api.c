#include <io-api.h>
#include <io.h>

//kernel API to read sectors from disk
//uses low level IO API from io.c
void kread(int lba, char num_sectors, int targ_segm, int targ_offset){
	read(lba, num_sectors, targ_segm, targ_offset);
}

//kernel API to get character from keyboard
//uses low level IO API from io.c
char kgetchar() {
	return getchar();
}

//kernel API to print character to screen
//uses low level IO API from io.c
void kputchar(char in) {
	putchar(in);
}


//kernel API to print string
void kprintstr(char *buff) {
	int i = 0;
	while (buff[i] != 0) {
		//printing a single character
		kputchar(buff[i]);
		i++;
	}
}

//kernel API to get string
//gets the string up to 512 bytes
//while getting the characters, the method is also printing them
void kgetstr(char *buff){
	const int BUFF_SIZE = 512;
	int i = 0;
	while (1) {
				
		char curr = kgetchar();
		
		//ASCII of enter (13) or end of buffer
		if(curr == 13 || i == BUFF_SIZE -1){
			buff[i] = 0;
			break;
		}
		//backspace (ASCII of 8) on first position
		else if (curr == 8 && i == 0) {
				continue;
		}
		//backspace on non-first position
		else if (curr == 8) {
				kputchar(curr); //moves cursor back
				kputchar(' ');  //replaces the current char with whitespace (through print) - this also advances the cursor
				kputchar(curr); //moves cursor back again
				i--;
		}
		//any other character - so put in buffer and print the char
		else{			
			buff[i] = curr;
			//prints character
			kputchar(curr);
			i++;
		}		
	}
	return;
}





