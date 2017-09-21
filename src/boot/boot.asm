BITS 16
									
org	0x7c00  ; offset within a segment to handle relocation

start:
        mov ax, 0 
        mov ss, ax     ;put stack segment and data segment to 0
		mov ds, ax
		mov sp, 0x7c00 ;put stack pointer to bootloader start and grow down from there
		
		
		;mov sp, 0xffff  ;put stack pointer to the top of 64K

        mov si, text_boot_start     ; put string position into SI
        call print_string       ; call string-printing routine

load_kern:

        mov si, text_kern_load_start     ; put string position into SI
        call print_string       ; call string-printing routine
		
		mov  ah,0x02 ; read sectors from drive service
		mov  al,0x22 ; load 34 sectors. bootloader, kernel and fs use 36 sectors to fit into single floppy cylinder(1 - bootloader, 34 - kernel, 1 - fs map)
		mov	 ch,0x00 ; cylinder (always 0 for floppy)
		mov  cl,0x02 ; start from sector 2 (sector 1 is the bootloader code already loaded by BIOS)
		mov  dh,0x00 ; head 0
		;skipping set of drive number as BIOS will set it in DL register on its own (0x00 - floppy, 0x80 - hard drive, booting from USB will do hard drive emulation and use 0x80)
		mov  bx, 1000h 
        mov es, bx   ; specify the memory segment 1000h to load the code (second 64K slice)
        mov bx, 0h  ;specify offset 0h within a segment 1000h to load the code							
		int  13h ; call BIOS to read sectors
		
		
	    jmp 0x1000:0x0 ;jump to kernel entry point which is defined by core-hd.asm and located right at the start of second 64K


		text_boot_start db 'booting...',13,10, 0
		text_kern_load_start db 'loading kernel...',13,10,0


print_string:                   ; routine: output string in SI to screen
        mov ah, 0Eh             ; int 10h 'print char' function

.repeat:
        lodsb                   ; get character from string
        cmp al, 0
        je .done                ; if char is zero, end of string
        int 10h                 ; otherwise, print it
        jmp .repeat

.done:
        ret


        times 510-($-$$) db 0   ; pad remainder of boot sector with 0s
        dw 0xAA55               ; the standard PC boot signature
