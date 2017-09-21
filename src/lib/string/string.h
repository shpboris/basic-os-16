#ifndef STRING_H //prevents multiple inclusions

//in general, the library provides string handling API to the user

//defines a list of methods provided by string.c library
int strcmp(char *a, char *b);
int atoi(char *str);
char *itoa(int n);
void itoa_internal(int n, char s[]);
void reverse(char s[]);
int strlen(char *str);
void memcpy(void *dest, void *src, int n);

#define STRING_H
#endif




