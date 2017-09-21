#ifndef IO_H 

void init_io();
void read(int lba, char num_sectors, int targ_segm, int targ_offset);
char getchar();
void putchar(char in);



#define IO_H
#endif