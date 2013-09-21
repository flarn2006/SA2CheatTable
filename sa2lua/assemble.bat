rem - This requires nasm (Netwide Assembler) to be in your path directory.
rem - If you don't know what that means, you probably don't need this (no offense!)
@echo off
for %%F in (*.asm) do (
	@nasm -o %%~nF.bin %%F
	if errorlevel 1 goto error
)
goto end
:error
pause
:end