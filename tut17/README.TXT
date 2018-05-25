This is the example from Iczelion's Win32 Assembly Tutorial part 17.
In order to assemble the example, you have to have ml.exe, link.exe and nmake.exe in your path.
If they're not in the path, you will have to edit makefile to include the full
path.
You'll have to edit the makefile to correct the path to import libraries in your PC.
Type nmake in the same directory as makefile and the assembly thread will
begin.
If you don't want to use the makefile, you can manually assemble the
example with the commands below:

ml /c /coff /Cp DLLSkeleton.asm
link /DLL /DEF:DLLSkeleton.def /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib DLLSkeleton.obj

Any problem: contact me at Iczelion@win32asm.cjb.net


:: win10, 64 bit
:: 2018-MAY-25, xiaolaba, study DLL build and test
:: nmake did not works, install visual studio, copy nmake.exe to c:\masm32\bin if needed
:: so uses this build.bat
:: masm32 default installation, folder c:\masm32

folder 1 demo, use .lib for exe gnernation
folder 2 demo, use loadlibrary(), no need .lib 