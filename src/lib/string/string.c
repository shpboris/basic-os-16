#include <string.h> 
 
//The library provides string handling API to the user

int strcmp(char *a, char *b)
{
    while (*a && *b && *a == *b) { ++a; ++b; }
    return *a - *b;
}


int strlen(char *str)
{
        char *s;

        for (s = str; *s; ++s)
                ;
        return (s - str);
}


void reverse(char s[])
 {
     int i, j;
     char c;
 
     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
 }
 

int atoi(char *str)
{
    int res = 0; 
	int i;

    for (i = 0; str[i] != '\0'; ++i){
        res = res*10 + str[i] - '0';
	}

    return res;
}
 

char *itoa(int n)
 {
	static char buff[20];
	itoa_internal(n, buff);
	return buff;
 }
 
 
  void itoa_internal(int n, char s[])
 {
     int i, sign;
 
     if ((sign = n) < 0)  
         n = -n;          
     i = 0;
     do {      
         s[i++] = n % 10 + '0';  
     } while ((n /= 10) > 0);     
     if (sign < 0)
         s[i++] = '-';
     s[i] = '\0';
     reverse(s);
 }
 



void memcpy(void *dest, void *src, int n)
{
   int i;
   char *csrc = (char*)src;
   char *cdest = (char*)dest;
 
   for (i=0; i<n; i++){
       cdest[i] = csrc[i];
   }
}


 
 







