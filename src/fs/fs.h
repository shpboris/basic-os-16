#ifndef FS_H //prevents multiple inclusions

void init_fs();
int load(char *params, int segm, int offset);
void list_files(char *buff);


#define FS_H
#endif




