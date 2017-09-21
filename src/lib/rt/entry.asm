.MODEL tiny
.CODE
ORG 0h   ; offset of this code within segment 0 to handle relocation
			; 8200h = 7c00h (start of the bootloader) + 200h (bootloader size) + 400h (kernel size defined by dd usage)

start: 		mov ax, cs ; saving code segment
			mov ds,ax ; 
			
COMMENT X		
prt:		mov  si, offset msg  ; print shell entry point message
			mov  ah, 0eh
chr:		lodsb
			or   al,al
			jz   call_main
			int  10h   ; call BIOS service to print next character
			jmp  chr
X
			
call_main:	call near ptr _main  ; call shell main function
retf
;db 0cbh ;retf code
			
			
extrn	_main:near  ;specifying that external label _main will be provided during linkage. This label is created by compiler for C function main() in shell.c
msg		db	'general entry point...',13,10,0
END start