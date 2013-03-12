nasm -o hook.bin hook.asm
@echo off
if errorlevel 1 goto error
goto end
:error
pause
:end