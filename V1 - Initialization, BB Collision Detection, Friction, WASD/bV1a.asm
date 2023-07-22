; V1a - THIS VERSION INCLUDES THE BB NARROW PHASE COLLISION DETECTION SYSTEM, WITHOUT THE SCREEN.



; SCREEN SIZE: 1024x768
; TABLE SIZE: 1024x512 (from y=128 to y=639)
; BALLS RADIUS: 17px (1px center)



.386
IDEAL
MODEL small
STACK 100h
DATASEG
fldMem dd ?
Balls dw 17*1, 17+128, 6 dup(0), 17*3+1, 17+128, 6 dup(0), 17*5, 17+128, 6 dup(0), 17*7, 17+128, 6 dup(0), 17*9, 17+128, 6 dup(0), 17*11, 17+128, 6 dup(0), 17*13, 17+128, 6 dup(0), 17*15, 17+128, 6 dup(0), 17*17, 17+128, 6 dup(0), 17*19, 17+128, 6 dup(0),'$'
CODESEG
;-------------------------Math Procedures-----------------------------
; gets an integer (32bit) and returns its square root (float, 32bit).
; INPUT: [bp+4]+[bp+6] integer number, [bp+8] fldMem offset
; OUTPUT: [bp+6]+[bp+8] 32bit float number
proc sqrt
	push bp
	mov bp, sp
	push eax
	push di
	;;;;;;;;;;
		mov di, [bp+8] ; fldMem
		mov eax, [bp+4] ; integer number
		
		mov [di], eax
		fild [dword ptr di]
		
		fsqrt
		
		fstp [dword ptr di]
		mov eax, [di]
		
		mov [bp+6], eax
		
	;;;;;;;;;;
	pop di
	pop eax
	pop bp
	ret 2
	endp sqrt

; gets two 16bit numbers and multiplies them by each other. outputs the result.
; INPUT: [bp+4] a, [bp+6] b
; OUTPUT: [bp+4]+[bp+6] 32bit result
proc multiply
	push bp
	mov bp, sp
	push eax
	push edx
	;;;;;;;;;;
		
		mov ax, [bp+4]
		mov dx, [bp+6]
		imul dx ; DX:AX holds result
		
		shl edx, 16
		add edx, eax
		
		mov [bp+4], edx
	;;;;;;;;;;
	pop edx
	pop eax
	pop bp
	ret
	endp multiply
;----------------------------Vector Procedures-----------------------------

; gets x,y of a vector (integers) and returns the vector's magnitude (float)
; INPUT; [bp+4] y, [bp+6] x, [bp+8] fldMem offset
; OUTPUT: [bp+6]+[bp+8] 32bit float number
proc magnitude
	push bp
	mov bp, sp
	push eax
	push ebx
	push di
	;;;;;;;;
		
		mov ax, [bp+4]
		push ax
		push ax
		call multiply
		pop eax
		
		mov ebx, eax
		
		mov ax, [bp+6]
		push ax
		push ax
		call multiply
		pop eax
		
		add ebx, eax
		
		mov ax, [bp+8]
		push ax
		push ebx
		call sqrt
		pop ebx
		mov [bp+6], ebx
		
	;;;;;;;;
	pop di
	pop ebx
	pop eax
	pop bp
	ret 2
	endp magnitude

; substracts two vectors.
; INPUT: [bp+4] y2, [bp+6] x2, [bp+8] y1, [bp+10] x1
; OUTPUT: [bp+8] x, [bp+10] y
proc substract
	push bp
	mov bp, sp
	push ax
	push bx
	push di
	;;;;;;;;;;;
		mov ax, [bp+10]
		mov bx, [bp+6]
		sub ax, bx
		mov di, ax ; di = x1-x2
		
		mov ax, [bp+8]
		mov bx, [bp+4]
		sub ax, bx ; ax = y1-y2
		
		mov [bp+10], ax
		mov [bp+8], di
		
	;;;;;;;;;;;
	pop di
	pop bx
	pop ax
	pop bp
	ret 4
	endp substract
	
;----------------------------Collision Detection Procedures-----------------------------

; checks if 2 balls collide.
; INPUT: [bp+4] index of b2 in the Balls array, [bp+6] index of b1 in the balls array, [bp+8] Balls offset, [bp+10] fldMem offset.
; OUTPUT: [bp+8] 1 of collision detected, 0 if not.
proc collision_detection_bb
	push bp
	mov bp, sp
	push eax
	push bx
	push si
	push di
	;;;;;;;;
		mov ax, [bp+8] ; Balls offset
		mov bx, [bp+10] ; fldMem offset
		
		mov di, [bp+4]
		shl di, 4 ; di*=16 (not 8 because word size)
		add di, ax ; di = b1 index
		
		mov si, [bp+6]
		shl si, 4 ; si*=16 (not 8 because word size)
		add si, ax ; si = b2 index
		
		push [word ptr di]
		add di, 2
		push [word ptr di]
		
		push [word ptr si]
		add si, 2
		push [word ptr si]
		
		call substract
		pop di ; x of the difference vector
		pop si ; y of the difference vector
		
		push bx ; fldMem offset
		push di
		push si
		call magnitude
		pop eax ; eax now holds the magnitude of the difference vector.
		
		mov [bx], eax
		fld [dword ptr bx]; loads the magnitude to the FPU stack
		mov [dword ptr bx], 34 ; 34 = r1+r2 = 17+17
		fild [dword ptr bx] ; loads r1+r2 to the FPU stack
		; now ST(0)=34, ST(1)=mag
		fcom ; compares 34 to the magnitude
		fnstsw ax ; moves the FPU flag register to ax
		sahf ; moves ax to the flag register
		jae collision_detected_bb ; if r1+r2>=mag 
			xor ax, ax
			mov [bp+10], ax ; returns 0
			jmp collision_not_detected_bb
		collision_detected_bb:
			mov ax, 1
			mov [bp+10], ax ; returns 1
		collision_not_detected_bb:
	;;;;;;;;
	pop di
	pop si
	pop bx
	pop eax
	pop bp
	ret 6
	endp collision_detection_bb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov ax, @data
	mov ds, ax
	
	push offset fldMem
	push offset Balls
	push 0
	push 1
	call collision_detection_bb
	pop ax
	

exit:
	mov ax, 4c00h
	int 21h
END start