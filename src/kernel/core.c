#include <core.h>
#include <string.h>
#include <fs.h>
#include <io-api.h>

#define SHELL_SEGM 0x2000
#define SHELL_OFFSET 0x0
#define PROG_SEGM 0x3000
#define PROG_OFFSET 0x0



void run_shell();
void run_program(int targ_segm, int targ_offset);
extern void farcall(int seg,int ofs);
void exec(char *params);


//general function to initiate all kernel activities like
//init IO system
//init file system
//start shell
void start_kernel() {
	kprintstr("started kernel...");
	kprintstr("\r\n");
	
	init_io();
	init_fs();	
	run_shell();
	
	kprintstr("system shut down");
	kprintstr("\r\n");	
}



void run_shell(){
  int segm = SHELL_SEGM;
  int offset = SHELL_OFFSET;
  load("sys_shell", segm, offset);
  run_program(segm, offset);
}





//this is the interrupt handler that is called from core-hd.asm
void do_dispatch(int service,char *params) {
	switch (service) {
		case 0:
			kprintstr(params);
			break;
		case 1:
			kgetstr(params);
			break;
		case 2:
			exec(params);
			break;
		case 3:
			list_files(params);
			break;
		default:
			break;
	}
	return;
}


//function to run user programs
//uses fs.c load function to load the program's code to memory
//then calls this code run_program  
void exec(char *params){
	int segm = PROG_SEGM;
	int offset = PROG_OFFSET;
	int is_loaded = load(params, segm, offset);
	if(is_loaded){
		run_program(segm, offset);
	}	
	else{
		kprintstr("Undefined command: ");
		kprintstr(params);   //prints the string no matter if it is valid command or not
		kprintstr("\r\n");
	}
}


//runs the code that is located at specific segment/offset in memory
//calls core-hd.asm farcall function
void run_program(int targ_segm, int targ_offset){
	farcall(targ_offset, targ_segm);
	
}



