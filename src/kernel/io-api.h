#ifndef IOAPI_H 

void kread(int lba, char num_sectors, int targ_segm, int targ_offset);
char kgetchar();
void kputchar(char in);
void kgetstr(char *buff);
void kprintstr(char *buff);


#define IOAPI_H
#endif




