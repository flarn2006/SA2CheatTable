; linedraw.asm
; Use as object routine, and manually set ObjectMaster+0x34 to an allocated address for the list of lines.
DrawLine3D equ 0x44B770

bits 32
push eax
mov eax,[esi+0x38]
push dword [eax]
call DrawLinesFromMemory
add esp,4
pop eax
ret

DrawLinesFromMemory:
; Save the values of the registers on the stack.
push ebx
push ecx
push esi

; Get the address of the line data from the stack.
mov esi,[esp+0x10]
test esi,esi
jz ExitFunction

; Loop through the lines.
mov ecx,[esi]
test ecx,ecx
jz ExitFunction
add esi,4

DrawLinesLoop:
push ecx ;the function overwrites ecx
push 1
; Right now ESI contains the address of the first line's coordinates.
; But first we need to push the color pointer, which is 24 bytes away.
lea ebx,[esi+24]
push ebx
push esi
; Now we'll call the function.
mov ebx,DrawLine3D
call ebx
add esp,12
pop ecx
; Now just shift ESI 28 bytes forward for the next line and loop.
add esi,28
loop DrawLinesLoop

ExitFunction:
pop esi
pop ecx
pop ebx
ret
