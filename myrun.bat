d:
rem The current file is run from DosBox 0.74 that is installed on Win7 - can't be run directly from Windows because tcc, tasm and tlink
rem tools that is used here should be run on 16 bits machine!
rem So basically DosBox is the compilation environment and just has pointers (mounts) for code/script and compiling tools.
rem Imagine the code being run in DosBox and having all the tools, code and current script inside of it - that is similar to what happens here.
rem The following is added to the end of DosBox options file - so drives d (to access all the code), s to access code and c (to access tcc, tasm and tlink) are defined 
rem and we can use them as below. Also tasm, tcc and tlink binaries are added to the path !

rem Note - the project's code is located at C:\os-dev\basic-os-16, but basic-os-16 is too long for folder so using basic-~1 instead

rem ********************************
rem mount c: C:\os-dev\env\tcasm
rem mount d: C:\os-dev
rem mount s: C:\os-dev\basic-~1\src
rem set path=%path%;c:\tc\bin;c:\tasm\bin
rem D:
rem cd basic-~1
rem ********************************

rem this is now a current directory - so tasm, tcc and tlink output go to d:\basic-os-16\obj
cd d:\basic-~1\obj
del *.obj
rem clean up old stuff
del *.map > NUL
del *.bin
del *.asm




rem run tasm assembler on .asm files: > redirect output to myout.txt and override the contents, >> add output to the end of the file
tasm  s:\kernel\core-hd.asm > myout.txt
tasm  s:\lib\rt\entry.asm >> myout.txt

rem  compile io
tcc -Is:\io -Is:\lib\string -mt -S s:\io\io.c >> myout.txt
tcc -Is:\io -Is:\lib\string -mt -c s:\io\io.c >> myout.txt

rem compile io-api
tcc -Is:\kernel -Is:\io -mt -S s:\kernel\io-api.c >> myout.txt
tcc -Is:\kernel -Is:\io -mt -c s:\kernel\io-api.c >> myout.txt

rem compile fs
tcc -Is:\lib\string -Is:\kernel -Is:\fs -mt -S s:\fs\fs.c >> myout.txt
tcc -Is:\lib\string -Is:\kernel -Is:\fs -mt -c s:\fs\fs.c >> myout.txt

rem compile kernel: -S produce intermediate assembly, -c compile only without linkage to standard libraries
tcc -Is:\lib\string -Is:\fs -Is:\kernel -mt -S s:\kernel\core.c >> myout.txt
tcc -Is:\lib\string -Is:\fs -Is:\kernel -mt -c s:\kernel\core.c >> myout.txt




rem compile stdio lib
tcc -Is:\lib\string -Is:\lib\stdio -mt -S s:\lib\stdio\stdio.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\stdio -mt -c s:\lib\stdio\stdio.c >> myout.txt

rem compile string lib
tcc -Is:\lib\string -mt -S s:\lib\string\string.c >> myout.txt
tcc -Is:\lib\string -mt -c s:\lib\string\string.c >> myout.txt

rem compile exec lib
tcc -Is:\lib\string -Is:\lib\exec -mt -S s:\lib\exec\exec.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\exec -mt -c s:\lib\exec\exec.c >> myout.txt

rem compile fslib lib
tcc -Is:\lib\string -Is:\lib\fslib -mt -S s:\lib\fslib\fslib.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\fslib -mt -c s:\lib\fslib\fslib.c >> myout.txt




rem compile shell (and the user libraries together) - each file can be compiled separately if needed. Compiling together is not required.
rem -S produce intermediate assembly, -c compile only without linkage to standard libraries, -I specifies include folder that contains .h files
tcc -Is:\lib\string -Is:\lib\stdio -Is:\lib\exec -mt -S s:\shell\shell.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\stdio -Is:\lib\exec -mt -c s:\shell\shell.c >> myout.txt



rem compile user progs
tcc -Is:\lib\string -Is:\lib\stdio -mt -c s:\opt\hello\hello.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\stdio -mt -c s:\opt\calc\calc.c >> myout.txt
tcc -Is:\lib\string -Is:\lib\stdio -Is:\lib\fslib -mt -c s:\utils\ls\ls.c >> myout.txt


rem critical point - shell and user programs don't require ANY linkage to kernel artifacts, only user libraries are required !


rem linkage is done for kernel files - previously .asm and .c
tlink /t /s core-hd.obj string.obj io.obj io-api.obj fs.obj core.obj , kern.bin >> myout.txt

rem linkage is done for shell and user libraries files - previously .asm and .c
tlink /t /s entry.obj stdio.obj string.obj exec.obj shell.obj, shell.bin >> myout.txt

rem linkage is done for user programs, utilities  and their required user libraries files - previously .asm and .c
tlink /t /s entry.obj stdio.obj string.obj hello.obj, hello.bin >> myout.txt
tlink /t /s entry.obj stdio.obj string.obj calc.obj, calc.bin >> myout.txt
tlink /t /s entry.obj stdio.obj string.obj fslib.obj ls.obj, ls.bin >> myout.txt



