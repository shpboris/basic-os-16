#include <stdio.h>
#include <string.h>
 
//****** SIMPLISTIC CALCULATOR PROGRAM ********

//uses the following APIs that BasicOS 16 provides
//printstr(str) - to print output to the screen
//getstr() - to get input from user
//demonstrates the ability to run basic programs on to of BasicOS

void main() {	
	int p1;
	int p2;
	int res;
	char operarr[20]; 
	char strarr[20];
	char * oper = operarr;	
	char * str = strarr;	
	
	while(1){
		printstr("Enter operation code: ");	
		str = getstr(); 
		memcpy(oper, str, strlen(str) + 1);
		printstr("\r\n");
		
		if(strcmp(oper,"q") == 0){
			return;
		}
		
		printstr("Enter first param: ");	
		str = getstr(); 
		printstr("\r\n");
		p1 = atoi(str);
		
		printstr("Enter second param: ");	
		str = getstr(); 
		printstr("\r\n");
		p2 = atoi(str);
		
		if(strcmp(oper,"+") == 0){
			res = p1 + p2;
		}
		else if(strcmp(oper,"-") == 0){
			res = p1 - p2;
		} 
		else if(strcmp(oper,"/") == 0){
			res = p1 / p2;
		}
		else if(strcmp(oper,"*") == 0){
			res = p1 * p2;
		}
		
		str = itoa(res);
		
		printstr("Result: ");	
		printstr(str);
		printstr("\r\n");
		printstr("\r\n");
	}
	
	return;
}