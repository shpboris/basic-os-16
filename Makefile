#This script is creating a SINGLE binary file named mydisk.img that contains bootloader, kernel, shell and also user programs (ls\hello\calc) code. 
#Logically the binary file represents the contents of floppy disk or hard disk. The file is created out of
#the following separate binary files that reside within Win7 machine and are output of running myrun.bat 
#in DosBox - myboot.bin, KERN.BIN, SHELL.BIN, LS.BIN, HELLO.BIN, CALC.BIN. 

#To create mydisk.img file Linux dd utility is used from within VBox Ubuntu VM. To allow dd to access the binary files in Win7 env
#the Vbox shared folder C:\os-dev\basic-os-16 is created and auto mounted by VirtualBox under media folder - /media/sf_basic-os-16.

#So finally to run this file, change to /media/sf_basic-os-16 in Ubuntu and execute  make command.

all:
	@echo copying map.conf file to obj directory
	cp ./conf/fs/map.conf ./obj/map.conf
	@echo compiling boot loader
	nasm -f bin ./src/boot/boot.asm -o ./obj/myboot.bin 
	@echo creating image
	dd if=/dev/zero of=./obj/mydisk.img bs=1440K count=1
	@echo copying boot loader to sector 1
	dd if=./obj/myboot.bin of=./obj/mydisk.img conv=notrunc bs=512 seek=0 count=1
	@echo copying kernel to sectors 2 - 35
	dd if=./obj/KERN.BIN of=./obj/mydisk.img conv=notrunc bs=512 seek=1 count=34
	@echo copying map.conf to sector 36
	dd if=./obj/map.conf of=./obj/mydisk.img conv=notrunc bs=512 seek=35 count=1
	@echo copying shell to sectors 37 - 54
	dd if=./obj/SHELL.BIN of=./obj/mydisk.img conv=notrunc bs=512 seek=36 count=18
	@echo copying ls to sectors 55 - 72
	dd if=./obj/LS.BIN of=./obj/mydisk.img conv=notrunc bs=512 seek=54 count=18
	@echo copying hello to sectors 73 - 92
	dd if=./obj/HELLO.BIN of=./obj/mydisk.img conv=notrunc bs=512 seek=72 count=18
	@echo copying calc to sectors 93 and 110
	dd if=./obj/CALC.BIN of=./obj/mydisk.img conv=notrunc bs=512 seek=90 count=18
	
