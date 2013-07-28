rem - This requires nasm (Netwide Assembler) to be in your path directory.
rem - If you don't know what that means, you probably don't need this (no offense!)
nasm -o hook.bin hook.asm
@echo off
if errorlevel 1 goto error
goto end
:error
pause
:end