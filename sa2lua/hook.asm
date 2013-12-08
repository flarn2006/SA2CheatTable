; Assemble with nasm <http://www.nasm.us>
bits 32
LoadObject2: equ 0x46F610
StackCountStorage: equ 0x42C645 ; Start address of four bytes unused by SA2

; Store the address of the command region in ebp
push ebp
mov ebp,0xDEADBEEF ;will be overwritten by Lua script

; Push some registers to be restored later
push eax
push ecx
push esi
push edi

mov dword ebx,[ebp]			; Store the command to be executed in ebx
cmp ebx,1					; If the command = 1...
je SpawnObject				; ...jump to the object spawning code.
cmp ebx,2					; If the command = 2...
je CallFunction				; ...jump to the generic function calling code.

Done:
mov [ebp],ebx				; Change the opcode value in memory according to
							; ebx, which is where the jumps above store it.
							
; Restore the registers from above
pop edi
pop esi
pop ecx
pop eax
pop ebp

jmp ReplacedCode			; Jump to the sonic2app.exe code that was replaced

; What follows are the sections of code for specific commands.
; Command for spawning objects:
SpawnObject:
push ebx					; Save the opcode value for later
mov edi,[ebp+0x04]			; edi = object routine
mov eax,[ebp+0x08]			; eax = pointer to object name
mov ebx,[ebp+0x0C]			; Store the flags value...
and ebx,0xFF				; (we only want one byte)
push ebx					; ...and push it to the stack.
mov ecx,[ebp+0x0D]			; ecx = object list ID
mov ebx,LoadObject2			; Spawn the object; now eax -> ObjectMaster
call ebx					; (We need to put it in ebx so it's an absolute address.)
add esp,4					; Remove that flags value from the stack

; Now we need to add the object's parameters (rotation, position, scale.)
mov edi,[eax+0x34]			; edi = location to store parameters
test edi,edi				; Check if edi = 0...
jz NoSpawnParams			; ...if so, skip this part.
add edi,8					; Rot/Pos/Scl start at ObjData1 + 0x08
lea esi,[ebp+0x11]			; esi = source location for parameters

mov ecx,9					; Do the following 9 times:
SetParamsLoop:
mov ebx,[esi]				; Take the parameter from memory...
mov [edi],ebx				; ...and copy it to the object's parameters.
add esi,4					; Now move to the next parameter.
add edi,4					; ^
loop SetParamsLoop			; ...and do it again. (end of loop)

NoSpawnParams:				; we're done setting the parameters

; Many objects (such as enemies) require a certain structure pointed to by
; ObjectMaster + 0x30 or it will crash. This will take care of that:
; First, we'll allocate memory for the SETEntry structure it contains.

mov edi,eax					; Save the ObjectMaster pointer; we still need it!
mov eax,0x20				; The SETEntry structure is 32 bytes.
call AllocMem				; Allocate memory; store address in eax
mov word [eax],0			; Just set the object ID to zero
xor ebx,ebx					; Set ebx to 00000000
mov bx,[ebp+0x11]			; Take the X rotation value...(2 bytes)
mov [eax+0x02],bx			; ...and put it in the SETEntry structure.
mov bx,[ebp+0x15]			; Same with the Y rotation value.
mov [eax+0x04],bx			; ^
mov bx,[ebp+0x19]			; Same with the Z rotation value.
mov [eax+0x06],bx			; ^
mov ebx,[ebp+0x1D]			; Take the X position value...(4 bytes)
mov [eax+0x08],ebx			; ...and put it in the SETEntry structure.
mov ebx,[ebp+0x21]			; Same with the Y position value.
mov [eax+0x0C],ebx			; ^
mov ebx,[ebp+0x25]			; Same with the Z position value.
mov [eax+0x10],ebx			; ^
mov ebx,[ebp+0x29]			; Same with the X scale value.
mov [eax+0x14],ebx			; ^
mov ebx,[ebp+0x2D]			; Same with the Y scale value.
mov [eax+0x18],ebx			; ^
mov ebx,[ebp+0x31]			; Same with the Z scale value.
mov [eax+0x1C],ebx			; ...and the structure is full.

; Now we'll allocate the actual structure at 0x30. Only the parts of the struct
; that actually change each time it's filled will be identified.
mov esi,eax					; We'll need eax again, so save the SETEntry address.
mov eax,0x10				; This structure is 16 bytes.
call AllocMem				; Allocate memory; store address in eax
mov byte [eax],1
mov byte [eax+0x01],0
mov word [eax+0x02],0x8001
mov [eax+0x04],edi			; Store the ObjectMaster address
mov [eax+0x08],esi			; Store the SETEntry address
mov dword [eax+0x0C],0
mov [edi+0x30],eax			; And set ObjectMaster + 0x30 to point here.

; Done! Now we'll just finish up:
mov [ebp+0x04],edi			; Store the ObjectMaster address in memory
pop ebx						; Get our opcode back
neg ebx						; Negate it to let Cheat Engine know the address is there
jmp Done					; And jump back to the main code.

; Command for calling any function:
CallFunction:
push ebx					; Save the opcode value for later
push edx					; Preserve the value of edx
push ebp					; We'll also need to use ebp for another purpose.
mov ecx,[ebp+0x20]			; Set the loop counter to the stack count
mov [StackCountStorage],ecx	; Save the number of values we'll push
test ecx,ecx				; Check if we don't have anything to push...
jz NothingInStack			; ...if so, skip this part.
lea esi,[ebp+0x24]			; Store the address of the stack array
CFPushLoop:					; Stack-filling loop begins here
push dword [esi]			; Push the value from memory
add esi,4					; Move the pointer to the next value
loop CFPushLoop				; Loop according to ecx
NothingInStack:				; If there wasn't anything to push, start here.

; Now we'll fill the registers according to the values in memory.
mov eax,[ebp+0x08]
mov ebx,[ebp+0x0C]
mov ecx,[ebp+0x10]
mov edx,[ebp+0x14]
mov esi,[ebp+0x18]
mov edi,[ebp+0x1C]

; Since eax, ebx, ecx, edx, esi, and edi are used, we need to overwrite ebp.
mov ebp,[ebp+0x04]			; Store the function to call
call ebp					; Actually call said function

; Now we'll get our parameters out of the stack, but first we need to get the number
; of values we pushed back from memory.
mov ecx,[StackCountStorage]	; Put the stack count back in ecx
lea ecx,[ecx*4]			; Multiply it by 4
add esp,ecx					; Remove the values from the stack
pop ebp						; Restore the value of ebp
mov [ebp+0x08],eax			; Put the return value from calling the function in memory

; Now we'll just finish up.
pop edx						; Restore the value of edx
pop ebx						; Restore the opcode value (in ebx)
neg ebx						; Negate it to tell Cheat Engine the return value is in memory
jmp Done					; Jump back to the main code.

;-------------------------------------------------------------------------------------
ReplacedCode:
; The following five lines are from SA2's main code, and need to be here since
; the jump to my hook code replaces them in their original location.
push ecx
push ebx
push ebp
push esi
push edi
; And now jump back to sonic2app.exe
mov ebx,0x77E785
jmp ebx

AllocMem:
; This code just calls a function in SA2 to allocate a section of memory. Just
; set eax to the number of bytes you need, "call AllocMem", and then the address
; of the allocated memory will be stored in eax.
push ecx
push ebx
mov ebx,[0x1D19CAC]
mov ecx,[ebx]
push 0
push 0x8B9528
push eax
call ecx
add esp,12
pop ebx
pop ecx
ret
