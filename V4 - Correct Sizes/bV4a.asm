; V4a - THIS VERSION INCLUDES THE FINAL PHYSICS PART:
		; - Collision physics
		; - Correct table & balls sizes
		


; SCREEN SIZE: 1024x768
; TABLE SIZE WITHOUT FRAME: 960X480 (from x=32 to x=991, y=144 to y=623)
; TABLE SIZE WITH FRAME: 1024X544 (from x=0 to x=1023, y=112 to y=655)
; BALLS RADIUS: 10px (1px center)

.386
IDEAL
MODEL small
STACK 100h
DATASEG
Balls dw 17*5, 17+200, 6 dup(0), 15, 7 dup(?)
	  dw 17*27, 17*6+128, 6 dup(0), 1, 7 dup(?)
	  dw 17*40, 17*20+128, 6 dup(0), 4, 7 dup(?)
	  dw 17*30, 17+300, 6 dup(0), 5, 7 dup(?)
	  dw 17*6, 17*15+128, 6 dup(0), 13, 7 dup(?)
	  dw 17*15, 17*6+128, 6 dup(0), 14, 7 dup(?)
	  dw 17*47, 17*7+128, 6 dup(0), 9, 7 dup(?)
	  dw 17*38, 17*10+128, 6 dup(0), 10, 7 dup(?)
	  dw 17*47, 17*15+128, 6 dup(0), 11, 7 dup(?)
	  dw 17*50, 17+456, 6 dup(0), 12, 7 dup(?)
; Balls array: x,y,vel_x(1),vel_x(2),vel_y(1),vel_y(2),acc_x,acc_y, color, cell info (msb byte cell 0 address in grid, lsb byte 0123 mask),?,?,?,?,?,?

Grid dw 128 dup (0) ; 128 cells, 64x64 each, 16x8 cells. Each cell word :  000000 (unused) + 0000000000 (balls flags)
; 20x10 cells, 47x47 each is good enough
BallsPrevious dw 20 dup(?)
FPUmem dd ?
Friction dd 0.98
Ball_template db 0,0,0,0,0,0,0,0,3,3,3,3,3,0,0,0,0,0,0,0,0, '$'
			  db 0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0, '$'
			  db 0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0, '$'
  			  db 0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0, '$'
	  		  db 0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, '$'
			  db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, '$'
			  db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, '$'
			  db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, '$'
			  db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0, '$'
			  db 0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0, '$'
			  db 0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0, '$'
			  db 0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0, '$'
			  db 0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0, '$'
			  db 0,0,0,0,0,0,0,0,3,3,3,3,3,0,0,0,0,0,0,0,0, '#'


CODESEG
;-------------------------Other Procedures-----------------------------
; Creates a small delay.
; OUTPUT: None
; INPUT: None
proc delay
	push ax
	;;;;;;;;;;;;
	mov ax, 0ffffh
	delay_loop1:
		push ax
		mov ax, 10
		delay_loop2:
			dec ax
			jnz delay_loop2
		pop ax
		dec ax
		jnz delay_loop1
	;;;;;;;;;;;
	pop ax
	ret
	endp delay

; sets up a 1024x768 screen
; INPUT: None
; OUTPUT: None
proc set_screen
	push ax
	push bx
	push cx
	push dx
	;;;;;;;;
	mov ax, 4f02h
	mov bx, 0105h
	int 10h
	cmp ax, 004fh
	je ok
	mov ax, 4c00h
	int 21h
	ok:
	
	; xor ax, ax
	; int 33h
	
	mov ax, 0007h
	mov cx, 0
	mov dx, 1023
	int 33h

	mov ax, 0008h
	mov cx, 0
	mov dx, 767
	int 33h

	mov ax, 0004h
	mov cx, 512
	mov dx, 384
	int 33h

	;;;;;;;;
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	endp set_screen

;-------------------------Math Procedures-----------------------------
; gets an integer (32bit) and returns its square root (float, 32bit).
; INPUT: [bp+4]+[bp+6] integer number, [bp+8] FPUmem offset
; OUTPUT: [bp+6]+[bp+8] 32bit float number
proc sqrt
	push bp
	mov bp, sp
	push eax
	push di
	;;;;;;;;;;
		mov di, [bp+8] ; FPUmem
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

; gets a number (32bit integer) and returns its inverse square root
; INPUT: [bp+4]+[bp+6] number, [bp+8] FPUmem offset
; OUTPUT: [bp+6]+[bp+8] inverse square root (32bit float)
proc inverse_sqrt
	push bp
	mov bp, sp
	push di eax ebx
	;;;;;;;;
		mov di, [bp+8] ; FPUmem offset

		fld1
		fchs  ; load -1 for later use

		mov eax, 40400000h ; decimal 3.0
		mov [di], eax
		fld [dword ptr di] ; for later use

		mov eax, [bp+4]
		mov [di], eax
		fild [dword ptr di]
		fstp [dword ptr di]
		mov eax, [di] ; eax = float(x)

		push eax
		shr eax, 1
		mov ebx, 5f3759dfh
		sub ebx, eax ; ebx = y
		pop eax

		mov [di], ebx
		fld [dword ptr di]
		fmul [dword ptr di] ; ST(0) = y^2
		mov [di], eax
		fmul [dword ptr di] ; ST(0) = x*y^2
		fsubp ; ST(0) = 3-x*y^2
		mov [di], ebx
		fmul [dword ptr di] ; ST(0) = y(3-x*y^2)
		fscale ; decrease exponent => divide by 2

		fstp [dword ptr bp+6]
	;;;;;;;;
	pop ebx eax di bp
	ret 2
	endp inverse_sqrt

; gets two 16bit numbers and multiplies them by each other. outputs the result.
; INPUT: [bp+4] a, [bp+6] b
; OUTPUT: [bp+4]+[bp+6] 32bit result
proc multiply
	push bp
	mov bp, sp
	push eax
	push edx
	;;;;;;;;;;

		xor eax, eax

		mov ax, [bp+4]
		mov dx, [bp+6]
		imul dx ; DX:AX holds result

		shl edx, 16
		or edx, eax

		mov [bp+4], edx
	;;;;;;;;;;
	pop edx
	pop eax
	pop bp
	ret
	endp multiply

; gets a number n and returns n^2
; INPUT: [bp+4] n, [bp+6] junk
; OUTPUT: [bp+4]+[bp+6] 32bit result n^2
proc pow2
	push bp
	mov bp, sp
	push eax edx
	;;;;;;;;;;
		xor eax, eax
		mov ax, [bp+4]
		imul ax ; result in dx:ax
		shl edx, 16
		or edx, eax
		mov [bp+4], edx
	;;;;;;;;;;
	pop edx eax bp
	ret
	endp pow2

;----------------------------Vector Procedures-----------------------------

; gets x,y of a vector (integers) and returns the vector's magnitude (float)
; INPUT; [bp+4] y, [bp+6] x, [bp+8] FPUmem offset
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
proc subtract
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
	endp subtract

; Gets 2 float vectors, subtracts them.
; INPUT: [bp+16]+[bp+18] x1, [bp+12]+[bp+14] y1, [bp+8]+[bp+10] x2, [bp+4]+[bp+6] y2
; OUTPUT: [bp+12]+[bp+14] x, [bp+16]+[bp+18] y
proc subtract_float
	push bp
	mov bp, sp
	;;;;;;;
		fld [dword ptr bp+16] ; x1
		fsub [dword ptr bp+8] ; x2
		; now ST(0) = x1-x2
		fld [dword ptr bp+12] ; y1
		fsub [dword ptr bp+4] ; y2
		; now ST(1)=x1-x2, ST(0)=y1-y2
		fstp [dword ptr bp+16]
		fstp [dword ptr bp+12]
	;;;;;;;
	pop bp
	ret 8
	endp subtract_float

; Gets 2 float vectors, adds them.
; INPUT: [bp+16]+[bp+18] x1, [bp+12]+[bp+14] y1, [bp+8]+[bp+10] x2, [bp+4]+[bp+6] y2
; OUTPUT: [bp+12]+[bp+14] x, [bp+16]+[bp+18] y
proc add_float
	push bp
	mov bp, sp
	;;;;;;;
		fld [dword ptr bp+16] ; x1
		fadd [dword ptr bp+8] ; x2
		; now ST(0) = x1+x2
		fld [dword ptr bp+12] ; y1
		fadd [dword ptr bp+4] ; y2
		; now ST(1)=x1+x2, ST(0)=y1+y2
		fstp [dword ptr bp+16]
		fstp [dword ptr bp+12]
	;;;;;;;
	pop bp
	ret 8
	endp add_float

; gets an integer vector and a scalar, and multiplies them
; INPUT: [bp+4]+[bp+6] scalar, [bp+8] y0, [bp+10] x0
; OUTPUT: [bp+4]+[bp+6] x, [bp+8]+[bp+10] y
proc mult
	push bp
	mov bp, sp
	;;;;;;;

		fild [word ptr bp+10] ; x0
		fmul [dword ptr bp+4] ; multiply by scalar

		fild [word ptr bp+8] ; y0
		fmul [dword ptr bp+4] ; multiply by scalar

		fstp [dword ptr bp+8] ; new multiplied y
		fstp [dword ptr bp+4] ; new multiplied x

	;;;;;;;
	pop bp
	ret
	endp mult

; gets x, y and returns the inverse magnitude of the vector
; INPUT: [bp+8] FPUmem, [bp+6] x, [bp+4] y
; OUTPUT: [bp+6]+[bp+8] magnitude (32bit float)
proc inverse_mag
	push bp
	mov bp, sp
	push eax ebx
	;;;;;;;;;
		mov ax, [bp+6]
		push ax ax
		call pow2
		pop eax

		mov bx, [bp+4]
		push bx bx
		call pow2
		pop ebx
		add eax, ebx

		cmp eax, 0
		je inverse_magnitude_0
		push [word ptr bp+8]
		push eax
		call inverse_sqrt
		pop eax
		mov [bp+6], eax
		jmp inverse_magnitude_not_0

		inverse_magnitude_0:
			xor eax, eax
			mov [bp+4], eax
			mov [bp+6], eax
		inverse_magnitude_not_0:
	;;;;;;;;;
	pop ebx eax bp
	ret 2
	endp inverse_mag

; Calculates the dot product of two vectors - one float and the other integer.
; INPUT: [bp+14] x1, [bp+12] y1, [bp+8]+[bp+10] x2, [bp+4]+[bp+6] y2
; OUTPUT: [bp+12]+[bp+14] product
proc dot
	push bp
	mov bp, sp
	;;;;;;;
		fild [word ptr bp+14]
		fmul [dword ptr bp+8]
		; now ST(0) = x1*x2
		fild [word ptr bp+12]
		fmul [dword ptr bp+4]
		; now ST(0) = y1*y2, ST(1) = x1*x2
		faddp
		fstp [dword ptr bp+12]
	pop bp
	ret 8
	endp dot

;----------------------------BB Collision Response Procedures-----------------------------

; Changes the velocities of 2 balls after their collision.
; INPUT: [bp+4] Balls offset, [bp+6] index of second ball, [bp+8] index of first ball, [bp+10] FPUmem offset
; OUTPUT: None.
; v1' = v1-(dot(v1-v2, x1-x2)/(||x1-x2||^2))*(x1-x2)
; v2' = v2-(dot(v2-v1, x2-x1)/(||x2-x1||^2))*(x2-x1)
proc collision_response_bb
	push bp
	mov bp, sp
	push bx di si ecx edx eax
	;;;;;;;;;;;
		mov bx, [bp+8] ; b1 index
		shl bx, 5
		add bx, [bp+4] ; b1 x0 address
		push [word ptr bx] ; b1 x0
		add bx, 2
		push [word ptr bx] ; b1 y0
		mov bx, [bp+6] ; b2 index
		shl bx, 5
		add bx, [bp+4] ; b2 x0 address
		push [word ptr bx] ; b2 x0
		add bx, 2
		push [word ptr bx] ; b2 y0
		call subtract
		pop di
		pop si
		; (di, si) distance vector (b1-b2)

		mov bx, [bp+8] ; b1 index
		shl bx, 5
		add bx, [bp+4] ; b1 x0 address
		add bx, 4
		push [dword ptr bx] ; b1 vel_x
		add bx, 4
		push [dword ptr bx] ; b1 vel_y
		mov bx, [bp+6] ; b2 index
		shl bx, 5
		add bx, [bp+4] ; b2 x0 address
		add bx, 4
		push [dword ptr bx] ; b2 vel_x
		add bx, 4
		push [dword ptr bx] ; b2 vel_y
		call subtract_float
		pop ecx ; x of velocities difference vector
		pop edx ; y of the velocities difference vector

		push di
		push si
		push ecx
		push edx
		call dot
		pop eax ; eax = dot(v1-v2, x1-x2)
		
		mov bx, [bp+10] ; FPUmem
		push bx ; FPUmem
		push di
		push si
		call inverse_mag
		pop [dword ptr bx] ; pop the 1/mag to FPUmem
		fld [dword ptr bx]
		fmul [dword ptr bx] ; ST(0)=1/(||x1-x2||)^2

		mov [bx], eax
		fmul [dword ptr bx] ; ST(0)=dot(v1-v2, x1-x2)/(||x1-x2||)^2
		fstp [dword ptr bx]

		push di
		push si
		push [dword ptr bx]
		call mult
		pop ecx
		pop edx

		mov bx, [bp+8] ; b1 index
		shl bx, 5
		add bx, [bp+4] ; b1 x0 address
		add bx, 4
		push [dword ptr bx] ; b1 vel_x
		add bx, 4
		push [dword ptr bx] ; b1 vel_y
		push ecx
		push edx
		call subtract_float
		sub bx, 4
		pop [dword ptr bx]
		add bx, 4
		pop [dword ptr bx]
		
		mov bx, [bp+6] ; b2 index
		shl bx, 5
		add bx, [bp+4] ; b2 x address
		add bx, 4
		push [dword ptr bx]
		add bx, 4
		push [dword ptr bx]
		push ecx
		push edx
		call add_float
		sub bx, 4
		pop [dword ptr bx]
		add bx, 4
		pop [dword ptr bx]

	;;;;;;;;;;;
	pop eax edx ecx si di bx bp
	ret 8
	endp collision_response_bb

; Moves 2 colliding balls away from each other, so they don't erase each other.
; INPUT: [bp+4] Balls offset, [bp+6] index of second ball, [bp+8] index of first ball, [bp+10] FPUmem offset
; OUTPUT: None.
proc uncoll_balls
	push bp
	mov bp, sp
	push edi esi eax ecx edx bx
	;;;;;;;;;
		xor edi, edi
		xor esi, esi
		mov bx, [bp+10] ; FPUmem offset

		mov di, [bp+8] ; b1 index
		shl di, 5
		add di, [bp+4] ; b1 x0 address
		push [word ptr di] ; b1 x0
		add di, 2
		push [word ptr di] ; b1 y0
		mov di, [bp+6] ; b2 index
		shl di, 5
		add di, [bp+4] ; b2 x0 address
		push [word ptr di] ; b2 x0
		add di, 2
		push [word ptr di] ; b2 y0
		call subtract
		pop di
		pop si
		; (di, si) distance vector (b1-b2)

		push bx ; FPUmem offset
		push di
		push si
		call inverse_mag
		pop eax ; eax = inverse of distance between b1 and b2 centers (FLOAT)

		push di
		push 10
		call multiply
		pop ecx
		; ecx = 10*x long
		push si
		push 10
		call multiply
		pop edx
		; edx = 10*y long
		sar di, 1 ; di=0.5x
		sar si, 1 ; si=0.5y

		mov [bx], eax
		fld [dword ptr bx] ; load 1/mag
		mov [bx], ecx
		fild [dword ptr bx]
		fmul ST(0), ST(1)
		fistp [dword ptr bx]
		mov ecx, [bx]
		sub ecx, edi ; add cx to x1, sub cx to x2

		mov [bx], edx
		fild [dword ptr bx]
		fmul ST(0), ST(1)
		fistp [dword ptr bx]
		mov edx, [bx]
		sub edx, esi ; add dx to y1, sub dx to y2

		mov bx, [bp+8] ; b1 index
		shl bx, 5
		add bx, [bp+4] ; bx = x0 of b1 address
		add [bx], cx
		add bx, 2
		add [bx], dx

		mov bx, [bp+6] ; b2 index
		shl bx, 5
		add bx, [bp+4] ; bx = x0 of b2 address
		sub [bx], cx
		add bx, 2
		sub [bx], dx
	;;;;;;;;
	pop bx edx ecx eax esi edi bp
	ret 8
	endp uncoll_balls

;----------------------------Ball-Ball Collision Detection Procedures-----------------------------

;-----------------BB Narrow Phase-------------------

; checks if 2 balls collide.
; INPUT: [bp+4] index of b2 in the Balls array, [bp+6] index of b1 in the balls array, [bp+8] Balls offset, [bp+10] FPUmem offset.
; OUTPUT: [bp+10] 1 of collision detected, 0 if not.
proc collision_detection_narrow_phase
	push bp
	mov bp, sp
	push eax
	push bx
	push si
	push di
	;;;;;;;;
		mov ax, [bp+8] ; Balls offset
		mov bx, [bp+10] ; FPUmem offset

		mov di, [bp+4]
		shl di, 5 ; di*=32 (not 16 because word size)
		add di, ax ; di = b1 index

		mov si, [bp+6]
		shl si, 5 ; si*=32 (not 16 because word size)
		add si, ax ; si = b2 index

		push [word ptr di]
		add di, 2
		push [word ptr di]

		push [word ptr si]
		add si, 2
		push [word ptr si]

		call subtract
		pop di ; x of the difference vector
		pop si ; y of the difference vector

		push bx ; FPUmem offset
		push di
		push si
		call magnitude
		pop eax ; eax now holds the magnitude of the difference vector.

		mov [bx], eax
		fld [dword ptr bx]; loads the magnitude to the FPU stack
		mov [dword ptr bx], 20 ; 20 = r1+r2 = 10+10
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
	endp collision_detection_narrow_phase

;-------------------BB Broad Phase-------------------

; Gets Balls offset, ball index, Grid offset, and returns a word which is a mask of which balls have to be checked with the narrow phase.
; INPUT: [bp+8] Balls offset, [bp+6] ball index, [bp+4] Grid offset
; OUTPUT: mask of balls to be narrow checked
proc balls_to_check_common_cells
	push bp
	mov bp, sp
	push ax
	push di
	push si
	;;;;;;;
		xor ax, ax
		mov di, [bp+6] ; Balls index
		shl di, 5
		add di, [bp+8] ; di = offset of x of ball
		add di, 18 ; di = cell word, msb byte = location of 0 cell, lsb half-byte = 321 mask
		mov al, [di]
		shl al, 1
		mov si, [bp+4] ; Grid offset
		add si, ax ; si = cell 0 address

		inc di
		mov al, [di] ; 321 mask

		xor di, di
		or di, [si]
		sub si, 2
		shr al, 1
		jnc not_cell_1_common
			or di, [si]
		not_cell_1_common:
		sub si, 32
		shr al, 1
		jnc not_cell_2_common
			or di, [si]
		not_cell_2_common:
		add si, 2
		shr al, 1
		jnc not_cell_3_common
			or di, [si]
		not_cell_3_common:

		mov [bp+8], di

	;;;;;;;
	pop si
	pop di
	pop ax
	pop bp
	ret 4
	endp balls_to_check_common_cells

; Gets balls offset, the index of the ball, and grid offset. updates the cell in which the ball is. Also updates the cell value in the Balls array.
; INPUT: [bp+8] Balls offset, [bp+6] ball index, [bp+4] Grid offset
; OUTPUT: None.
proc put_ball_in_cells
	push bp
	mov bp, sp
	push di
	push si
	push ax
	push bx
	push cx
	;;;;;;;;
		mov di, [bp+6]
		shl di, 5
		add di, [bp+8] ; di = address of x value of ball
		mov ax, [di]
		add di, 2
		mov cx, [di]
		sub cx, 128
		; ax = x, cx = y

		add di, 16 ; cell address in Balls array

		shr ax, 6 ; x/64
		shr cx, 6 ; y/64
		shl cx, 4 ; (y/64)*16 (times 16 because of the rows)
		; cells: cx+ax, cx-16+ax, cx+ax-1, cx-16+ax-1


		mov bl, 0fh
		; 2 3
		; 1 0
		cmp ax, 0
		jne cell_x_not_0
		and bl, 11111100b ; nakes 1,2 zero
		cell_x_not_0:

		cmp cx, 0
		jne cell_y_not_0
		and bl, 11111001b ; makes 2,3 zero
		cell_y_not_0:
		; this block checks if the ball is on the borders. in the end, bl holds which cells are valid.

		mov si, [bp+4] ; Grid offset
		add ax, cx
		mov [di], al ; puts the 0 cell index in the Balls array.
		shl ax, 1
		add si, ax
		; si = offset of ax+bx cell => 0 cell

		mov ax, 1
		mov cx, [bp+6]
		shl ax, cl
		; ax = ball index mask

		inc di ; di = 321 mask in Balls array

		or [si], ax ; turns on the according flag in the cell.
			; CELL AX+CX
		sub si, 2
		shr bl, 1
		jnc not_cell_1
			or [word ptr si], ax ; turns on the according flag in the cell.
			or [word ptr di], 1b
			; CELL AX+CX-1
		not_cell_1:
		sub si, 32
		shr bl, 1
		jnc not_cell_2
			or [word ptr si], ax ; turns on the according flag in the cell.
			or [word ptr di], 10b
			; CELL AX+CX-1-16
		not_cell_2:
		add si, 2
		shr bl, 1
		jnc not_cell_3
			or [word ptr si], ax ; turns on the according flag in the cell.
			or [word ptr di], 100b
			; CELL AX+CX-16
		not_cell_3:
		; changes the cells
	;;;;;;;;
	pop cx
	pop bx
	pop ax
	pop si
	pop di
	pop bp
	ret 6
	endp put_ball_in_cells

; Gets PreviousBalls offset, the index of the ball, and grid offset. removes the balls from its previous cells.
; INPUT: [bp+10] Balls offset, [bp+8] PreviousBalls offset, [bp+6] ball index, [bp+4] Grid offset
; OUTPUT: None.
proc remove_ball_from_cells
	push bp
	mov bp, sp
	push di
	push ax
	push bx
	push cx
	;;;;;;;;

		mov di, [bp+6] ; ball index
		shl di, 5
		add di, [bp+10]
		add di, 18 ; di = cell part in Balls array
		mov al, [di] ; cell 0 index

		inc di
		mov bl, [di]
		; bl = 321 mask

		mov di, [bp+4] ; Grid offset
		shl ax, 1
		add di, ax
		; di = offset of ax+bx cell
		mov ax, 1
		mov cx, [bp+6]
		shl ax, cl
		not ax
		; ax = ball index mask

		and [di], ax ; turns on the according flag in the cell.
			; CELL AX+BX
		sub di, 2
		shr bl, 1
		jnc not_cell_1_remove
			and [di], ax ; turns on the according flag in the cell.
			; CELL AX+BX-1
		not_cell_1_remove:
		sub di, 32
		shr bl, 1
		jnc not_cell_2_remove
			and [di], ax ; turns on the according flag in the cell.
			; CELL AX+BX-1-16
		not_cell_2_remove:
		add di, 2
		shr bl, 1
		jnc not_cell_3_remove
			and [di], ax ; turns on the according flag in the cell.
			; CELL AX+BX-16
		not_cell_3_remove:
		; changes the cells
	;;;;;;;;
	pop cx
	pop bx
	pop ax
	pop di
	pop bp
	ret 8
	endp remove_ball_from_cells

;---------------------BB Collision Detection--------

; gets Balls offset, ball index, Grid offset, and BallsPrevious offset. Handles the collision detection stuff between balls. (call for each moving ball)
; INPUT: [bp+12] FPUmem offset, [bp+10] Balls offset, [bp+8] ball index, [bp+6] Grid offset, [bp+4] BallsPrevious offset
; OUTPUT: None.
proc collision_bb
	push bp
	mov bp, sp
	push ax
	push bx
	push di
	push si
	;;;;;;;;

		push [word ptr bp+10] ; Balls offset
		push [word ptr bp+4] ; BallsPrevious offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; Grid offset
		call remove_ball_from_cells ; removes the ball from its previous cells

		push [word ptr bp+10] ; Balls offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; Grid offset
		call put_ball_in_cells ; updates the cells

		push [word ptr bp+10] ; Balls offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; Grid offset
		call balls_to_check_common_cells
		pop ax ; ax = mask of balls to check

		mov bx, -1
		collision_bb_loop:
			inc bx
			cmp bx, [bp+8]
			jne not_checking_with_same_ball_collision_bb
			shr ax, 1
			jmp collision_bb_loop
			not_checking_with_same_ball_collision_bb:

			shr ax, 1
			jnc not_this_ball_collision_bb
					push [word ptr bp+12] ; FPUmem
					push [word ptr bp+10] ; Balls offset
					push [word ptr bp+8] ; ball index - b2 index
					push bx ; index of b1
					call collision_detection_narrow_phase
					pop di
					cmp di, 1
					jne not_this_ball_collision_bb
						;
						;
						;
						; STUFF TO DO WHEN BALLS COLLIDE: BX B2 INDEX, [BP+8] B1 INDEX

						push [word ptr bp+12] ; FPUmem
						push [word ptr bp+8] ; b1 index
						push bx ; b2 index
						push [word ptr bp+10] ; Balls offset
						call uncoll_balls

						push [word ptr bp+12] ; FPUmem
						push [word ptr bp+8] ; b1 index
						push bx ; b2 index
						push [word ptr bp+10] ; Balls offset
						call collision_response_bb
						
						; push [word ptr bp+12]
						; push [word ptr bp+10]
						; push bx
						; push [word ptr bp+6]
						; push [word ptr bp+4]
						; call collision_bb
						
						push bx ; ball index
						push [word ptr bp+10] ; Balls offset
						call collision_bw
			
						push bx ; ball index
						push offset Ball_template ; Balls_template offset
						push offset BallsPrevious ; BallsPrevious offset
						push offset Balls ; Balls offset
						call redraw_ball

						jmp ball_collided_bb
						;
						;
						;
			not_this_ball_collision_bb:
					;
					;
					; STUFF TO DO WHEN BALLS NOT COLLIDING: BX B1 INDEX, [BP+8] B2 INDEX
					;
					;
					;
			ball_collided_bb:

			cmp bx, 10
			jnz collision_bb_loop

	;;;;;;;;
	pop si
	pop di
	pop bx
	pop ax
	pop bp
	ret 10
	endp collision_bb


;-----------------------------------------Ball-Wall Collision Procedures-----------------------------
; Handles collisions between a ball and a wall. (Call for each moving ball)
; INPUT: [bp+4] Balls offset, [bp+6] ball index
; OUTPUT: None.
proc collision_bw
	push bp
	mov bp, sp
	push di ax
	;;;;;;;
		mov di, [bp+6] ; Ball index
		shl di, 5
		add di, [bp+4] ; di=x0 of desired ball
		mov ax, [di]

		cmp ax, 32+10
		jnb not_colliding_with_west_wall
			;
			; COLLIDING WITH WEST WALL
			mov ax, 32+10
			mov [di], ax

			add di, 4
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			sub di, 4

			jmp not_colliding_with_east_wall
			;
		not_colliding_with_west_wall:

		cmp ax, 991-10
		jna not_colliding_with_east_wall
			;
			; COLLIDING WITH EAST WALL
			mov ax, 991-10
			mov [di], ax

			add di, 4
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			sub di, 4
			;
		not_colliding_with_east_wall:

		add di, 2
		mov ax, [di]

		cmp ax, 144+10
		jnb not_colliding_with_north_wall
			
			; COLLIDING WITH NORTH WALL
			mov ax, 144+10
			mov [di], ax

			add di, 6
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			jmp not_colliding_with_south_wall
			;
		not_colliding_with_north_wall:

		cmp ax, 623-10
		jna not_colliding_with_south_wall
			;
			; COLLIDING WITH SOUTH WALL
			mov ax, 623-10
			mov [di], ax

			add di, 6
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			;
		not_colliding_with_south_wall:
		
	;;;;;;;
	pop ax di bp
	ret 4
	endp collision_bw

;-----------------------Drawing Procedures-----------------------------

; draws the green part of the table
; INPUT: None
; OUTPUT: None
proc fill_table
	push ax
	push cx
	push dx
		mov al, 2
		mov ah, 0ch
		mov dx, 144
		fill_table_loop_y:
			mov cx, 32
			fill_table_loop_x:
				int 10h
				inc cx
				cmp cx, 991
				jbe fill_table_loop_x
			inc dx
			cmp dx, 623
			jbe fill_table_loop_y
	pop dx
	pop cx
	pop ax
	ret
	endp fill_table
	
; draws the frame of the table.
; INPUT: None.
; OUTPUT: None.
proc draw_frame
	push ax cx dx
	;;;;;;;;;;
		mov al, 6
		mov ah, 0ch
		mov dx, 112 ; y0
		draw_frame_loop_y:
			xor cx, cx ; x0
			draw_frame_loop_x:
				int 10h
				inc cx
				cmp cx, 1023 ; x1
				jbe draw_frame_loop_x
			inc dx
			cmp dx, 655 ; y1
			jbe draw_frame_loop_y
			
	;;;;;;;;;;
	pop dx cx ax
	ret
	endp draw_frame

; gets x0, y0, color and draws the ball.
; INPUT: [bp+10] Ball_template offset, [bp+8] x0, [bp+6] y0, [bp+4] color
; OUTPUT: None
proc draw_ball
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	;;;;;;;
		mov di, [bp+10]
		mov ax, [bp+4] ; color
		mov ah, 0ch
		mov dx, [bp+6] ; y0
		sub dx, 11
		draw_ball_loop_y:
			;call delay
			inc dx
			mov cx, [bp+8]
			sub cx, 11
			draw_ball_loop_x:
				inc cx
				mov bl, [di]
				inc di
				cmp bl, 0
				je draw_ball_loop_x
				cmp bl, '$'
				je draw_ball_loop_y
				cmp bl, '#'
				je finished_drawing_ball
				int 10h
				jmp draw_ball_loop_x

		finished_drawing_ball:
	;;;;;;;
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8
	endp draw_ball

; redraws the ball by drawing green on previous position and red on new position.
; INPUT: [bp+4] Balls offset, [bp+6] BallsPrevious offset, [bp+8] Ball_template offset, [bp+10] the ball's index
; OUTPUT: None
proc redraw_ball
	push bp
	mov bp, sp
	push di
	;;;;;;;
		push [word ptr bp+8] ; Balls_template offset
		mov di, [bp+10]
		shl di, 2
		add di, [bp+6]
		push [word ptr di] ; x of the previous position
		add di, 2
		push [word ptr di] ; y of the previous position
		push 2 ; background color
		call draw_ball ; draw green on previous ball

		push [word ptr bp+8] ; Balls_template offset
		mov di, [bp+10]
		shl di, 5
		add di, [bp+4]
		push [word ptr di] ; x of the new position
		add di, 2
		push [word ptr di] ; y of the new position
		add di, 14
		push [word ptr di] ; color
		call draw_ball ; draw red on new ball
	;;;;;;;
	pop di
	pop bp
	ret 8
	endp redraw_ball

;--------------------------Update Procedures-----------------------------------

; does collision detection and redraws every ball that moved since the last frame.
; INPUT: [bp+4] Balls offset, [bp+6] Balls_template offset, [bp+8] BallsPrevious offset, [bp+10] Grid offset, [bp+12] FPUmem offset
; OUTPUT: None.
proc for_every_moving_ball
	push bp
	mov bp, sp
	push di si ax cx dx
	;;;;;;;
		mov di, [bp+4] ; Balls offset
		mov si, [bp+8] ; BallsPrevious offset
		xor ax, ax
		check_if_ball_moved_loop:
			mov cx, [di]
			mov dx, [si]
			cmp cx, dx
			jne ball_moved

			add si, 2
			add di, 2
			mov cx, [di]
			mov dx, [si]
			sub si, 2
			sub di, 2
			cmp cx, dx
			jne ball_moved

			jmp ball_didnt_move

			ball_moved:
				; ax = index of the ball
				push [word ptr bp+12] ; FPUmem offset
				push [word ptr bp+4] ; Balls offset
				push ax ; ball index
				push [word ptr bp+10] ; Grid offset
				push [word ptr bp+8] ; BallsPrevious offset
				call collision_bb

				push ax ; ball index
				push [word ptr bp+4] ; Balls offset
				call collision_bw
				; ADD COLLISION_BB CHECK IF COLLIDES WITH WALL
				
				push ax ; ball index
				push [word ptr bp+6] ; Balls_template offset
				push [word ptr bp+8] ; BallsPrevious offset
				push [word ptr bp+4] ; Balls offset
				call redraw_ball

			ball_didnt_move:
			inc ax
			add si, 4
			add di, 32
			cmp ax, 10
			jb check_if_ball_moved_loop

	;;;;;;;
	pop dx cx ax si di bp
	ret 10
	endp for_every_moving_ball


; backups the balls' position from the Balls array to the BallsPrevious array.
; INPUT: [bp+4] Balls offset, [bp+6] BallsPrevious offset
proc move_to_previous
	push bp
	mov bp, sp
	push ax
	push si
	push di
	;;;;;;;
		mov di, [bp+6] ; BallsPrevious offset
		mov si, [bp+4] ; Balls offset
		mov ax, di
		add ax, 40
		move_to_previous_balls_array:
			push ax

			mov ax, [si]
			mov [di], ax ; moves the x

			add di, 2
			add si, 2
			mov ax, [si]
			mov [di], ax ; moves the y

			add di, 2
			add si, 30 ; continue to the next ball

			pop ax
			cmp di, ax
			jb move_to_previous_balls_array
	;;;;;;;
	pop di
	pop si
	pop ax
	pop bp
	ret 4
	endp move_to_previous

; Gets the velocity, and returns the new velocity after the decrease due to friction.
; INPUT: [bp+4]+[bp+6] velocity value, [bp+8] friction offset
; OUTPUT: New velocity (32bits)
proc change_vel_friction
	push bp
	mov bp, sp
	push di
	;;;;;;;;

		mov di, [bp+8] ; friction offset
		fld [dword ptr di]
		fmul [dword ptr bp+4]
		fstp [dword ptr bp+6]

	;;;;;;;;
	pop di bp
	ret 2
	endp change_vel_friction

; Changes the pos_x,pos_y,vel_x,vel_y of every ball according to its acceleration.
; INPUT: [bp+6] Friction offset, [bp+4] Balls offset
; OUTPUT: None.
proc reposition
	push bp
	mov bp, sp
	push di ax
	;;;;;;;;;;

		mov di, [bp+4] ; Balls offset
		add di, 32*10 ; di = pos_x address of after the last ball (does not actually exist).
		reposition_every_ball:
			sub di, 18 ; acc_y

			fild [word ptr di]
			sub di, 6 ; vel_y
			fld [dword ptr di]
			faddp
			fstp [dword ptr di]
			; updates vel_y

			push [word ptr bp+6] ; Friction offset
			push [dword ptr di]
			call change_vel_friction
			pop [dword ptr di]
			; updtaes vel_y after friction

			fld [dword ptr di]
			frndint
			sub di, 6 ; pos_y
			fild [word ptr di]
			faddp
			fistp [word ptr di]
			; updates pos_y

			add di, 10 ; acc_x

			fild [word ptr di]
			sub di, 8 ; vel_x
			fld [dword ptr di]
			faddp
			fstp [dword ptr di]
			; updates vel_x

			push [word ptr bp+6] ; Friction offset
			push [dword ptr di]
			call change_vel_friction
			pop [dword ptr di]
			; updtaes vel_x after friction

			fld [dword ptr di]
			frndint
			sub di, 4 ; pos_x
			fild [word ptr di]
			faddp
			fistp [word ptr di]
			; updates pos_x

			cmp di, [bp+4]
			ja reposition_every_ball
	;;;;;;;;;;
	pop ax di bp
	ret 4
	endp reposition

;---------------------Input Procedures-----------------------------

; gets the keyboard input and changes the x,y acceleration of the first ball accordingly.
; INPUT: [bp+6] keyboard input, [bp+4] Balls offset
; OUTPUT: None.
; TEMPORARY PROCEDURE
proc change_ball_0_input
	push bp
	mov bp, sp
	push ax
	push bx
	push di
	;;;;;
		mov ax, [bp+6]
		mov di, [bp+4]
		add di, 12 ; acc_x offset

		xor bx, bx
		cmp ax, 'a'
		jne not_a
			mov bx, -1
			jmp not_d
		not_a:
		cmp ax, 'd'
		jne not_d
			mov bx, 1
		not_d:
		mov [di], bx

		xor bx, bx
		add di, 2 ; acc_y offset
		cmp ax, 'w'
		jne not_w
			mov bx, -1
			jmp not_s
		not_w:
		cmp ax, 's'
		jne not_s
			mov bx, 1
		not_s:
		mov [di], bx

	;;;;;
	pop di
	pop bx
	pop ax
	pop bp
	ret 4
endp change_ball_0_input

; gets an input from the user. the procedure has no input, outputs the user input.
proc get_input
	push bp
	mov bp, sp
	push ax
	;;;;;;;;;;;;
	mov ah, 1
	int 16h
	jz buffer_empty
	mov ah, 0
	int 16h
	buffer_empty:
	xor ah, ah
	mov [bp+4], ax
	;;;;;;;;;;;;;;
	pop ax
	pop bp
	ret
	endp get_input

;-------------------------Initial Procedures-----------------------------

; Initiates the grid.
; INPUT: [bp+6] Balls offset, [bp+4] Grid offset
; OUTPUT: None.
proc initial_cell_division
	push bp
	mov bp, sp
	push di
	;;;;;;;;;;
		xor di, di
		initial_cell_division_loop:
			push [word ptr bp+6] ; Balls offset
			push di
			push [word ptr bp+4] ; Grid offset
			call put_ball_in_cells

			inc di
			cmp di, 10
			jne initial_cell_division_loop
	;;;;;;;;;;
	pop di bp
	ret 4
	endp initial_cell_division

; Draws all of the balls.
; INPUT: [bp+6] Balls offset, [bp+4] Balls_template offset
; OUTPUT: None
proc draw_all_balls
	push bp
	mov bp, sp
	push di cx
	;;;;;;;;;
		mov di, [bp+6] ; Balls offset
		mov cl, 10
		draw_all_balls_loop:

			push [word ptr bp+4] ; Ball_template offset
			push [word ptr di] ; x0
			add di, 2
			push [word ptr di] ; y0
			add di, 14
			push [word ptr di] ; color
			call draw_ball

			add di, 16
			loop draw_all_balls_loop

	;;;;;;;;;
	pop cx di bp
	ret 4
	endp draw_all_balls

; Initiates everything - screen, table, balls, grid.
; INPUT: [bp+8] Ball_template offset, [bp+6] Balls offset, [bp+4] Grid offset
; OUTPUT: None.
proc initiate_table
	push bp
	mov bp, sp
	;;;;;;;
		call set_screen
		call draw_frame
		call fill_table

		push [word ptr bp+6]
		push [word ptr bp+8]
		call draw_all_balls

		push [word ptr bp+6]
		push [word ptr bp+4]
		call initial_cell_division

	;;;;;;;
	pop bp
	ret 6
	endp initiate_table

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov ax, @data
	mov ds, ax
	
	push offset Ball_template
	push offset Balls
	push offset Grid
	call initiate_table
	
	main_loop:
		xor ax, ax

		push offset BallsPrevious
		push offset Balls
		call move_to_previous

		push ax ; trash
		call get_input
		pop ax

		cmp al, 'q'
		je exit

		push ax
		push offset Balls
		call change_ball_0_input

		push offset Friction
		push offset Balls
		call reposition

		push offset FPUmem
		push offset Grid
		push offset BallsPrevious
		push offset Ball_template
		push offset Balls
		call for_every_moving_ball
	
		call delay

		jmp main_loop
		
exit:
	mov ax, 4c00h
	int 21h
END start