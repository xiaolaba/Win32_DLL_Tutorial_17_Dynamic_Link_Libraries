:: win10, 64 bit
:: 2018-MAY-25, xiaolaba, study DLL build and test
:: nmake did not works, install visual studio, copy nmake.exe to c:\masm32\bin if needed
:: so uses this build.bat
:: masam32 default installation, folder c:\masm32

set path=%PATH%;c:\masm32\bin

set NAME=DLLSkeleton
ml /c /coff /Cp %NAME%.asm
Link /DLL /DEF:%NAME%.def /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib %NAME%.obj
copy DLLSkeleton.dll .\1\
copy DLLSkeleton.dll .\2\
copy DLLSkeleton.lib .\1\
del *.obj
del *.exp
del *.lib
pause

set NAME=usedll
cd 1
ml /c /coff /Cp %NAME%.asm
Link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib %NAME%.obj
del *.obj
pause

cd..
cd 2
ml /c /coff /Cp %NAME%.asm
Link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib %NAME%.obj
del *.obj
pause