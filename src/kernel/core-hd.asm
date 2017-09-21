.MODEL tiny
.CODE
ORG 0h      ; offset of this code within segment 1000h to handle relocation
			; cant write all kernel code in C - location of methods can easily change. Also not sure what would happen with relocation of all labels.
			; so this assembly wrapper defines offset of 0h for relocation and also allows to call C functions by their labels and not addresses.
			; this assembly code itself is called by its address - but it is not a problem as it has a clear structure and all addresses are known in advance.
						
global _farcall
buff_size EQU 256

start: 	

kern_init:	jmp startk ;kernel starts here - jump to startk label, bypassing interrupt handler code below !

COMMENT %

********* GENERAL POINTS ON INTERRUPT HANDLER BELOW AND CONTROL REGISTERS USAGE *********

1.
When running in user space, all the registers (SS, SP, DS, CS) point to users space.
Also when running in kernel space, all the registers (SS, SP, DS, CS) point to kernel space.

2.
The only exception out of rule #1 is the interrupt handler below and farcall function - both deal with
switching between user and kernel mode. So despite this code belongs to kernel, some portions of it executes when DS, SS, SP
still point to user space.

3.
The result of rule #1 is that when interrupt happens, user (!) stack is used for saving return address
from the interrupt. Which means that in order to be able to return to the user code after finishing interrupt handling (iret instruction),
all the registers should point to user space. But between start of interrupt handling and its finish, the 
registers (SS, SP, DS) should pointto kernel spaceso the kernel stack is used and kernel memory is accessed. 
That explains the chain of changes of registers - user->kernel->user.

4.
The result of #3 is that the registers should be backed up in order to be able to change registers in 
user->kernel->user chain. I.e once the switch to kernel registers was done, the user registers should be saved
so we can restore them later in order to return back to user program.

The registers are not saved in memory variable per register, but in stack per reister (usr_ss_stack, usr_sp_stack)!
To understand why stack is used consider the following nested flow: 

4.1
Shell executes exec interrupt to run user program - all shell registers must be saved in order to return back to shell
after user program returns.

4.2
Farcall is executed from kernel and makes user program to run.

4.3
User program issues print interrupt to print something - all user program registers must be saved in order to return back to user
program after print is done. But user registers must not destroy our first backup of shell registers. Hence stack is used.
So user registers pushed to stacks.

4.4
Once print is done, user program registers are restored (popped) and the control returns to user program.

4.5
User program's main finishes, returns to entry point, retf is issued and control returns to farcall function
that called user program from shell exec interrupt handler. Farcall restores all registers back to kernel and returns
to shell interrupt handler.

4.6
Shell registers are restored from stack to allow return to shell. Then iret is executed and control returns from shell.


%			
					 ;interrupt handler start
					 ;the address of interrupt handling code below within segm 1000h is 2h (0h is the start of the code + size of jmp instruction is 2h = 2h) 
interrupt:  cli      ;disable hardware interrupts 



			;USER TO KERNEL COPY. REGS (SS, SP, DS) STILL POINT TO USER SPACE
			mov  di,offset params ; DI is used by stosw below as offset for copy
			mov  ax,cs
			mov	 es,ax            ; ES is used by stosw below as segm for copy
			mov cx, buff_size	  ; CX is used by lodsw and stosw below as buffer size indication
			mov dx, si ;temporarily backup user buff location, as si value is changed by lodsw below
			cld                   ; copy direction is forward
fwd_copy:	lodsw ; copy next word from user space to AX : LODSW (DS:SI -> AX) and SI++, DS and SI still point to buffer locations in user space
			stosw ; copy next word from AX to kernel space : STOSW (AX -> ES:DI) and DI++, ES and DI were set just above to point to params buff in kernel
			loop fwd_copy
			
			
			;BACKUP USER SS, SP, USER BUFF LOCATION TO STACKS. INCREASE STACK INDEX. POINT REGS TO KERNEL SEGM
			mov ax, cs
			mov ds, ax ; ds points to kernel segm - first action (!) to do to allow access to kernel variables !
			mov [service], bx ; bx holds service id of interrupt. save it in service var, as bx will be used to hold index to all stacks below
			mov bx, [stack_ind] ;initially stack_ind is 0
			mov [usr_buff_stack + bx], dx ;backup user buff location (the location was initially in SI and moved to DX above) to usr_buff_stack 
			mov ax, ss
			mov [usr_ss_stack + bx], ax ;backup user ss to usr_ss_stack 
			mov ax, sp
			mov [usr_sp_stack + bx], ax ; backup user sp to usr_sp_stack 
			add [stack_ind], 2 ; increase stack index
			mov ax, [kern_ss_var] ;kernel ss restored on next
			mov ss, ax
			mov ax, [kern_sp_var] ;kernel sp restored on next
			mov sp, ax

			
			;CALL DISPATCH FUNCTION
			mov bx, [service] ;use bx to hold service id 
			mov  dx, offset params ;use dx to hold kernel buff location, kernel buff holds copied user data now
			push dx  ; passing dx value as function arg on kernel stack
			push bx  ; passing dx value as function arg on kernel stack
			call _do_dispatch ; calling do_dispatch function in core.c - the params are pushed to stack in reverse order to do_dispatch function parameters declaration !
			pop bx  ; return the stack to original state
			pop dx
			
			
			;KERNEL TO USER COPY. REGS (SS, SP, DS) STILL POINT TO KERNEL SPACE
			mov  si,offset params ; SI point to kernel params, DS was set to kernel space in code above
			sub [stack_ind], 2  ; decrease stack index to be able to access latest saved user data (SS and user buffer location), see below
			mov bx, [stack_ind] ; use bx for indexing
			mov  ax, [usr_ss_stack + bx]
			mov	 es,ax          ; ES is the same as backed up user SS
			mov di, [usr_buff_stack + bx]  ; DI is set to user buffer location
			mov cx,buff_size  ; buffer size for lodsw and stosw
			cld 
bwd_copy:	lodsw ; copy next word from kernel space to AX : LODSW (DS:SI -> AX) and SI++
			stosw ; copy next word from AX to user space : STOSW (AX -> ES:DI) and DI++
			loop bwd_copy
			
			
			;BACKUP KERNEL SS, SP. POINT REGS TO USER SEGM	
			mov ax, ss
			mov [kern_ss_var], ax ; backup kernel SS
			mov ax, sp
			mov [kern_sp_var], ax	;backup kernel SP
			mov ax, [usr_ss_stack + bx]
			mov ss, ax              ;restore user SS
			mov ax, [usr_sp_stack + bx]
			mov sp, ax               ;restor user SP
			mov ax, ss
			mov ds, ax               ;user DS is the same as user SS - restore it as well
			
			
			
inter_ex:   sti     ;enable hardware interrupts
			iret	;return from interrupt to user space


startk:		mov ax, cs ;initialize stack : SS=CS
			mov ss,ax ;SS=CS
			mov ax, 0FFFEh 
			mov sp,ax ; SP top of the segment
			mov bp,ax ; BP top of the segment
			mov ax, cs ; saving code segment
			mov ds,ax ; DS=CS

			
prt:		mov  si, offset msg  ;print kernel entry point msg start
			mov  ah, 0eh
chr:		lodsb
			or   al,al
			jz   set_ivt		;when printing is done, proceed to set interrupt handler address
			int  10h   			;call BIOS service to print next character
			jmp  chr            ;print kernel entry point msg start
			
set_ivt:						;IVT starts at address 0 and has 256 entries, each entry takes 4 bytes - 2 for specifying offset and 2 more for segment of interrupt handler. In total 256*4 = 1024.
			mov ax,0h			;I use entry #80 for my software interrupt - so the address for setting handler offset in IVT is 80*4 = 200 in hex. Then after 2 more bytes segment is located (202h)
			mov es,ax			; es is the segment and equals to 0 for all the handler setup code below.
						
			mov bx,200h			;address of the pointer to interrupt handler offset
			mov ax,2h		;interrupt handler offset (see explanation in the top of the page about how to find it out)
			mov es:[bx],ax  	;put offset of 2h to 0x0:0x200
			
			mov bx,202h			;address of the pointer to interrupt handler offset
			mov ax,1000h			;interrupt handler segment
			mov es:[bx],ax   	;put segment of 1000h to 0x0:0x202

init:	    call near ptr _start_kernel ;after IVT is set, the kernel is called to proceed with its activities. Logically, IVT setting code should be moved to kernel.
			jmp $
			

				
push_regs MACRO  
    pushf  ; [bp-2]
	push ax ;[bp-4]
	push bx ; [bp-6]
	push cx ; [bp-8]
	push dx ; [bp-10]
	push es ; [bp-12]
	push ds ; [bp-14]
	push si ; [bp-16]
	push di ; [bp-18]
ENDM push_regs	



pop_regs MACRO 
    pop di
	pop si
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	popf
ENDM pop_regs


COMMENT %

********* GENERAL POINTS ON FARCALL FUNCTION *********

1.
When jumpimg to user program, ALL the registers are changed to point to user program space.
SS, SP changed in farcall functio itself, DS changed inside entry.asm. CS is changed automatically.

2.
The call itself is done using user program stack! 

I.e  return address right after call dword ptr [bx] instruction is pushed 
to user stack. So when the user program completes and returns from main 
to entry point (entry.asm), the retf instruction in entry.asm will be able to fetch return address from
user(!) stack in order to return back.
 
 
******** CALCULATIONS IN FARCALL FUNCTION **********

1.
The function is called from core.c like this - farcall(targ_offset, targ_segm).
Params are pushed to stack right-to-left by convention - targ_segm first, then targ_offset.

2.
Stack grows down towards lower addresses so targ_offset gets lower address than targ_segm.
Segment and offset each takes 2 bytes - so if offset is placed at address 36 then segment will be at address 38.

3.
The far call instruction - call dword ptr [bx] below - is expecting offset and segment parameters exactly 
in this order as they are layed out in the stack per explanation in #2 - first offset then segment.

4.
When farcall function is called, by convention, after parameters the return address (takes 2 bytes) is placed on the stack.
Also bp is pushed in the beginning of farcal code itself (takes 2 bytes).

So to get to the first parameter we have to skip 4 bytes, hence the following will point bx to offset

mov bx, bp
add bx, 4

Then additional increment will point to segment -- bx + 2

%
			
_farcall:

	;new stack frame in kernel
	push bp ; push old bp
	mov  bp,sp ; bp and sp point to the old bp value on stack
	
	;save registers in kernel stack using macro
	push_regs
	
	;save kernel SS and SP in kernel data segm
	mov [kern_sp_var],sp
	mov [kern_ss_var],ss
	
	;change SS, SP to user space and  perform the actual call
	mov bx, bp
	add bx, 4 	; bx + 4 is offset param location - skip saved bp and skip return address on stack (2 + 2 = 4)
	mov ss, [bx + 2] ; set SS to the target code segment. stack segment
	mov sp, 0FFFEh ; user's top stack segment 	
	call dword ptr [bx]

	;returned from the user program call back to kernel - restore DS to kernel space 
	mov ax,cs
	mov ds,ax
	
	;restore SS and SP to kernel space
	mov sp,[kern_sp_var]
	mov ss,[kern_ss_var]
	
	;restore registers to their original values in kernel space pre user program call
	pop_regs
	
	pop bp
	RET


call_far_addr  dw 2 DUP(0)	
usr_buff_stack dw 6 DUP(0)
usr_ss_stack  dw 6 DUP(0)
usr_sp_stack  dw 6 DUP(0)
stack_ind  	dw 0
service dw 0
kern_sp_var	dw 0
kern_ss_var	dw 0	
params	db buff_size*2 DUP(0)			
extrn	_start_kernel:near      ;specifying that external label _start_kernel will be provided during linkage. This label is created by compiler for C function start_kernel() in kern.c
extrn   _do_dispatch:near		;same as above for do_dispatch() function
msg		db	'kernel entry point...',13,10,0
END start



