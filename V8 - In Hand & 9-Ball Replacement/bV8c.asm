; V8c - THIS VERSION INCLUDES:
		; - Collision physics
		; - Pockets
		; - Cue
		; - Fouls
		; - In hand - organized
		; - Draws the fouls
		; - Empty procedure for winning/losing the game
		; - BUG FOUND: IN HAND MAKES THE FOUL COUNTER ZERO
		


; SCREEN SIZE: 1024x768
; TABLE SIZE WITHOUT FRAME: 960X480 (from x=32 to x=991, y=144 to y=623)
; TABLE SIZE WITH FRAME: 1024X544 (from x=0 to x=1023, y=112 to y=655)
; balls RADIUS: 10px (1px center)
; SIDE POCKETS: 48px width (from x=488 to x=535)
; CORNER POCKETS: 30px + corner px


.386
IDEAL
MODEL small
STACK 100h
DATASEG
balls dw 17*5, 17+200, 8 dup(0), 40h, ?, 1, 3 dup(?)
	  dw 17*27, 17*6+128, 8 dup(0), 1fh, ?, 1, 3 dup(?)
	  dw 17*40, 17*20+128, 8 dup(0), 1dh, ?, 1, 3 dup(?)
	  dw 17*30, 17+300, 8 dup(0), 1bh, ?, 1, 3 dup(?)
	  dw 17*6, 17*15+128, 8 dup(0), 19h, ?, 1, 3 dup(?)
	  dw 17*15, 17*6+128, 8 dup(0), 17h, ?, 1, 3 dup(?)
	  dw 17*47, 17*7+128, 8 dup(0), 15h, ?, 1, 3 dup(?)
	  dw 500, 170, 8 dup(0), 13h, ?, 1, 3 dup(?)
	  dw 17*47, 17*15+128, 8 dup(0), 11h, ?, 1, 3 dup(?)
	  dw 596, 417, 8 dup(0), 0bh, ?, 1, 3 dup(?)
	  ; 640 bytes
; balls array: x,y,vel_x(1),vel_x(2),vel_y(1),vel_y(2),acc_x(1),acc_x(2),acc_y(1),acc_y(2), color, cell info (msb byte cell 0 address in grid, lsb byte 0123 mask), existence (1 if ball exists, 0 if not),?,?,?
previous_balls dw 20 dup(?)
grid dw 225 dup (0) ; 225 cells, 64x32 each, 15x15 cells. Each cell word :  000000 (unused) + 0000000000 (balls flags)
fpu_mem dd ?
friction dd 0.95
gamemode db 1 ; 0=balls moving, 1=Waiting for cue, 2=In hand
previous_cursor dw -1, -1 ; x, y of previous cursor location
cursor_backup db 49 dup (?)

foul db 0 ; 1 if a foul was committed, else 0. 2 if scratch
cue_collided db 0 ; 1 if the cue ball collided, else 0
rail dw 0 ; mask of which balls hit a rail
pocketed db 1 ; 1 if a ball was pocketed, else 0
current_player db 0
fouls_counter db 0, 0
nine_pocketed db 0

ball_template db 0,0,0,0,0,0,0,0,3,3,3,3,3,0,0,0,0,0,0,0,0, '$'
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
;$$ -------------------------Other Procedures-------------------------
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
	push ax bx cx dx
	;;;;;;;;
	mov ax, 4f02h
	mov bx, 0105h
	int 10h
	cmp ax, 004fh
	je ok
	mov ax, 4c00h
	int 21h
	ok:
	
	mov ax, 0007h
	mov cx, 3
	mov dx, 1020
	int 33h

	mov ax, 0008h
	mov cx, 3
	mov dx, 764
	int 33h

	mov ax, 0004h
	mov cx, 512
	mov dx, 384
	int 33h

	;;;;;;;;
	pop dx cx bx ax
	ret
	endp set_screen

; Exits if the q key is pressed.
; INPUT: None.
; OUTPUT: None.
proc check_exit
	push ax
		mov ah, 1
		int 16h
		jz buffer_empty
		xor ah, ah
		int 16h
		buffer_empty:
		
		cmp al, 'q'
		jne not_exiting
			add sp, 2
			mov ax, 4c00h
			int 21h
		not_exiting:
	pop ax
	ret
	endp check_exit
;%

;$$ -------------------------Math Procedures-------------------------
; gets an integer (32bit) and returns its square root (float, 32bit).
; INPUT: [bp+4]+[bp+6] integer number, [bp+8] fpu_mem offset
; OUTPUT: [bp+6]+[bp+8] 32bit float number
proc sqrt
	push bp
	mov bp, sp
	push eax di
	;;;;;;;;;;
		mov di, [bp+8] ; fpu_mem
		mov eax, [bp+4] ; integer number

		mov [di], eax
		fild [dword ptr di]

		fsqrt

		fstp [dword ptr di]
		mov eax, [di]

		mov [bp+6], eax

	;;;;;;;;;;
	pop di eax bp
	ret 2
	endp sqrt

; gets a number (32bit integer) and returns its inverse square root
; INPUT: [bp+4]+[bp+6] number, [bp+8] fpu_mem offset
; OUTPUT: [bp+6]+[bp+8] inverse square root (32bit float)
proc inverseSqrt
	push bp
	mov bp, sp
	push di eax ebx
	;;;;;;;;
		mov di, [bp+8] ; fpu_mem offset

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
	endp inverseSqrt

; gets two 16bit numbers and multiplies them by each other. outputs the result.
; INPUT: [bp+4] a, [bp+6] b
; OUTPUT: [bp+4]+[bp+6] 32bit result
proc multiply
	push bp
	mov bp, sp
	push eax edx
	;;;;;;;;;;

		xor eax, eax

		mov ax, [bp+4]
		mov dx, [bp+6]
		imul dx ; DX:AX holds result

		shl edx, 16
		or edx, eax

		mov [bp+4], edx
	;;;;;;;;;;
	pop edx eax bp
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
;%

;$$ -------------------------Vector Procedures-------------------------
; Gets a vector and returns its unit vector (32bit)
; INPUT: [bp+4] y0, [bp+6] x0, [bp+8] fpu_mem, [bp+10] JUNK
; OUTPUT: [bp+4]+[bp+6] x0, [bp+8]+[bp+10] y0
proc unit
	push bp
	mov bp, sp
	push eax edi esi bx
	;;;;;;;;;;
		mov ax, [bp+6] ; x0
		mov bx, [bp+4] ; y0
		movsx edi, ax
		movsx esi, bx
		
		mov ebx, [bp+8] ; fpu_mem
		
		push bx ; fpu_mem
		push di ; x
		push si ; y
		call inverseMagnitude
		pop eax

		cmp eax, 0
		je mag_is_0

		mov [bx], edi
		fild [dword ptr bx]
		mov [bx], eax
		fmul [dword ptr bx]
		fstp [dword ptr bp+4]

		mov [bx], esi
		fild [dword ptr bx]
		mov [bx], eax
		fmul [dword ptr bx]
		fstp [dword ptr bp+8]

		; return unit vector (x/mag, y/mag)

		jmp mag_is_not_0
		mag_is_0:
			xor edi, edi
			mov [bp+4], edi
			mov [bp+8], edi
			; return (0,0) if mag == 0
		mag_is_not_0:
	;;;;;;;;;;
	pop bx esi edi eax bp
	ret
	endp unit

; gets x,y of a vector (integers) and returns the vector's magnitude (float)
; INPUT; [bp+4] y, [bp+6] x, [bp+8] fpu_mem offset
; OUTPUT: [bp+6]+[bp+8] 32bit float number
proc magnitude
	push bp
	mov bp, sp
	push eax ebx di
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
	pop di ebx eax bp
	ret 2
	endp magnitude

; substracts two vectors.
; INPUT: [bp+4] y2, [bp+6] x2, [bp+8] y1, [bp+10] x1
; OUTPUT: [bp+8] x1-x2, [bp+10] y1-y2
proc subtract
	push bp
	mov bp, sp
	push ax bx di
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
	pop di bx ax bp
	ret 4
	endp subtract

; Gets 2 float vectors, subtracts them.
; INPUT: [bp+16]+[bp+18] x1, [bp+12]+[bp+14] y1, [bp+8]+[bp+10] x2, [bp+4]+[bp+6] y2
; OUTPUT: [bp+12]+[bp+14] x, [bp+16]+[bp+18] y
proc subtractFloat
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
	endp subtractFloat

; Gets 2 float vectors, adds them.
; INPUT: [bp+16]+[bp+18] x1, [bp+12]+[bp+14] y1, [bp+8]+[bp+10] x2, [bp+4]+[bp+6] y2
; OUTPUT: [bp+12]+[bp+14] x, [bp+16]+[bp+18] y
proc addFloat
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
	endp addFloat

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
; INPUT: [bp+8] fpu_mem, [bp+6] x, [bp+4] y
; OUTPUT: [bp+6]+[bp+8] magnitude (32bit float)
proc inverseMagnitude
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
		call inverseSqrt
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
	endp inverseMagnitude

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
;%

;$$ -------------------------Physics Procedures-------------------------
;----------------------------BB Collision Response Procedures-----------------------------

; Changes the velocities of 2 balls after their collision.
; INPUT: [bp+4] balls offset, [bp+6] index of second ball, [bp+8] index of first ball, [bp+10] fpu_mem offset
; OUTPUT: None.
; v1' = v1-(dot(v1-v2, x1-x2)/(||x1-x2||^2))*(x1-x2)
; v2' = v2-(dot(v2-v1, x2-x1)/(||x2-x1||^2))*(x2-x1)
proc collisionResponseBB
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
		call subtractFloat
		pop ecx ; x of velocities difference vector
		pop edx ; y of the velocities difference vector

		push di
		push si
		push ecx
		push edx
		call dot
		pop eax ; eax = dot(v1-v2, x1-x2)
		
		mov bx, [bp+10] ; fpu_mem
		push bx ; fpu_mem
		push di
		push si
		call inverseMagnitude
		pop [dword ptr bx] ; pop the 1/mag to fpu_mem
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
		call subtractFloat
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
		call addFloat
		sub bx, 4
		pop [dword ptr bx]
		add bx, 4
		pop [dword ptr bx]

	;;;;;;;;;;;
	pop eax edx ecx si di bx bp
	ret 8
	endp collisionResponseBB

; Moves 2 colliding balls away from each other, so they don't erase each other.
; INPUT: [bp+4] balls offset, [bp+6] index of second ball, [bp+8] index of first ball, [bp+10] fpu_mem offset
; OUTPUT: None.
proc uncollBalls
	push bp
	mov bp, sp
	push edi esi eax ecx edx bx
	;;;;;;;;;
		xor edi, edi
		xor esi, esi
		mov bx, [bp+10] ; fpu_mem offset

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

		push bx ; fpu_mem offset
		push di
		push si
		call inverseMagnitude
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
	endp uncollBalls

;----------------------------Ball-Ball Collision Detection Procedures-----------------------------

;-----------------BB Narrow Phase-------------------

; checks if 2 balls collide.
; INPUT: [bp+4] index of b2 in the balls array, [bp+6] index of b1 in the balls array, [bp+8] balls offset, [bp+10] fpu_mem offset.
; OUTPUT: [bp+10] 1 of collision detected, 0 if not.
proc collisionDetectionNarrowPhase
	push bp
	mov bp, sp
	push eax bx si di
	;;;;;;;;
		mov ax, [bp+8] ; balls offset
		mov bx, [bp+10] ; fpu_mem offset

		mov di, [bp+4]
		shl di, 5 ; di*=32 (not 16 because word size)
		add di, ax ; di = b1 index

		mov si, [bp+6]
		shl si, 5 ; si*=32 (not 16 because word size)
		add si, ax ; si = b2 index

		push [word ptr di]
		push [word ptr di+2]

		push [word ptr si]
		push [word ptr si+2]

		call subtract
		pop di ; x of the difference vector
		pop si ; y of the difference vector

		push bx ; fpu_mem offset
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
	pop di si bx eax bp
	ret 6
	endp collisionDetectionNarrowPhase

;-------------------BB Broad Phase-------------------

; Gets balls offset, ball index, grid offset, and returns a word which is a mask of which balls have to be checked with the narrow phase.
; INPUT: [bp+8] balls offset, [bp+6] ball index, [bp+4] grid offset
; OUTPUT: mask of balls to be narrow checked
proc ballsInCommonCellsMask
	push bp
	mov bp, sp
	push ax di si
	;;;;;;;
		xor ax, ax
		mov di, [bp+6] ; balls index
		shl di, 5
		add di, [bp+8] ; di = offset of x of ball
		add di, 22 ; di = cell word, msb byte = location of 0 cell, lsb half-byte = 321 mask
		mov al, [di]
		shl ax, 1
		mov si, [bp+4] ; grid offset
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
		sub si, 30
		shr al, 1
		jnc not_cell_2_common
			or di, [si]
		not_cell_2_common:
		add si, 2
		shr al, 1
		jnc not_cell_3_common
			or di, [si]
		not_cell_3_common:
		
		mov di, 0ffffh
		mov [bp+8], di

	;;;;;;;
	pop si di ax bp
	ret 4
	endp ballsInCommonCellsMask

; Gets balls offset, the index of the ball, and grid offset. updates the cell in which the ball is. Also updates the cell value in the balls array.
; INPUT: [bp+8] balls offset, [bp+6] ball index, [bp+4] grid offset
; OUTPUT: None.
proc addBallToGrid
	push bp
	mov bp, sp
	push di si ax bx cx
	;;;;;;;;
		mov di, [bp+6]
		shl di, 5
		add di, [bp+8] ; di = address of x value of ball
		mov ax, [di]
		add di, 2
		mov cx, [di]
		sub ax, 32
		sub cx, 144
		; ax = x, cx = y

		add di, 20 ; cell address in balls array

		shr ax, 6 ; x/64
		shr cx, 5 ; y/32
		
		mov bx, cx
		shl cx, 4 ; (y/32)*16
		sub cx, bx ; (y/32)*15 (times 15 because of the rows) >>actually (y/32)*16-(y/32)=(y/32)(16-1)=15*(y-32)
		; cells: cx+ax, cx-15+ax, cx+ax-1, cx-15+ax-1


		mov bl, 0fh
		; 2 3
		; 1 0
		cmp ax, 0
		jne cell_x_not_0
			and bl, 11111100b ; makes 1,2 zero
		cell_x_not_0:

		cmp cx, 0
		jne cell_y_not_0
			and bl, 11111001b ; makes 2,3 zero
		cell_y_not_0:
		; this block checks if the ball is on the borders. in the end, bl holds which cells are valid.

		mov si, [bp+4] ; grid offset
		add ax, cx
		mov [di], al ; puts the 0 cell index in the balls array.
		shl ax, 1
		add si, ax
		; si = offset of ax+bx cell => 0 cell

		mov ax, 1
		mov cx, [bp+6]
		shl ax, cl
		; ax = ball index mask

		inc di ; di = 321 mask in balls array
		mov [di], bl
		
		or [si], ax ; turns on the according flag in the cell.
			; CELL AX+CX
		sub si, 2
		shr bl, 1
		jnc not_cell_1
			or [word ptr si], ax ; turns on the according flag in the cell.
			; CELL AX+CX-1
		not_cell_1:
		sub si, 30
		shr bl, 1
		jnc not_cell_2
			or [word ptr si], ax ; turns on the according flag in the cell.
			; CELL AX+CX-1-15
		not_cell_2:
		add si, 2
		shr bl, 1
		jnc not_cell_3
			or [word ptr si], ax ; turns on the according flag in the cell.
			; CELL AX+CX-15
		not_cell_3:
		; changes the cells
	;;;;;;;;
	pop cx bx ax si di bp
	ret 6
	endp addBallToGrid

; Gets PreviousBalls offset, the index of the ball, and grid offset. removes the balls from its previous cells.
; INPUT: [bp+10] balls offset, [bp+8] PreviousBalls offset, [bp+6] ball index, [bp+4] grid offset
; OUTPUT: None.
proc removeBallFromGrid
	push bp
	mov bp, sp
	push di ax bx cx
	;;;;;;;;

		mov di, [bp+6] ; ball index
		shl di, 5
		add di, [bp+10]
		add di, 22 ; di = cell part in balls array
		mov al, [di] ; cell 0 index

		inc di
		mov bl, [di]
		; bl = 321 mask

		mov di, [bp+4] ; grid offset
		shl ax, 1
		add di, ax
		; di = offset of ax+bx cell
		mov ax, 1
		mov cx, [bp+6]
		shl ax, cl
		not ax
		; ax = ball index mask

		and [di], ax ; turns off the according flag in the cell.
			; CELL AX+BX
		sub di, 2
		shr bl, 1
		jnc not_cell_1_remove
			and [di], ax ; turns off the according flag in the cell.
			; CELL AX+BX-1
		not_cell_1_remove:
		sub di, 30
		shr bl, 1
		jnc not_cell_2_remove
			and [di], ax ; turns off the according flag in the cell.
			; CELL AX+BX-1-15
		not_cell_2_remove:
		add di, 2
		shr bl, 1
		jnc not_cell_3_remove
			and [di], ax ; turns off the according flag in the cell.
			; CELL AX+BX-15
		not_cell_3_remove:
		; changes the cells
	;;;;;;;;
	pop cx bx ax di bp
	ret 8
	endp removeBallFromGrid

;---------------------BB Collision Detection--------

; gets balls offset, ball index, grid offset, and previous_balls offset. Handles the collision detection stuff between balls. (call for each moving ball)
; INPUT: [bp+18] cue_collided offset, [bp+16] Foul offset, [bp+14] Balls_template offset, [bp+12] fpu_mem offset, [bp+10] balls offset, [bp+8] ball index, [bp+6] grid offset, [bp+4] previous_balls offset
; OUTPUT: None.
proc collisionBB
	push bp
	mov bp, sp
	push ax bx di si
	;;;;;;;;
		push [word ptr bp+10] ; balls offset
		push [word ptr bp+4] ; previous_balls offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; grid offset
		call removeBallFromGrid ; removes the ball from its previous cells

		push [word ptr bp+10] ; balls offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; grid offset
		call addBallToGrid ; updates the cells

		push [word ptr bp+10] ; balls offset
		push [word ptr bp+8] ; ball index
		push [word ptr bp+6] ; grid offset
		call ballsInCommonCellsMask
		pop ax ; ax = mask of balls to check

		xor bx, bx
		collision_bb_loop:

			shr ax, 1
			jnc not_this_ball_collision_bb
			cmp bx, [bp+8]
			je not_this_ball_collision_bb
			mov di, bx
			shl di, 5
			add di, [bp+10]
			cmp [word ptr di+24], 0
			je not_this_ball_collision_bb
			
					push [word ptr bp+12] ; fpu_mem
					push [word ptr bp+10] ; balls offset
					push [word ptr bp+8] ; ball index - b2 index
					push bx ; index of b1
					call collisionDetectionNarrowPhase
					pop di
					test di, di
					je not_this_ball_collision_bb

						cmp [word ptr bp+8], 0
						jne no_foul_committed_bad_hit
							mov di, [bp+18] ; cue_collided offset
							cmp [byte ptr di], 1
							je no_foul_committed_bad_hit
								mov [byte ptr di], 1
								
								push [word ptr bp+10] ; balls offset
								call getLowestBall
								pop di
								cmp di, bx
								je no_foul_committed_bad_hit ; no foul committed
								
								mov di, [word ptr bp+16] ; foul offset
								mov [byte ptr di], 1

						no_foul_committed_bad_hit:
						
						push [word ptr bp+12] ; fpu_mem
						push [word ptr bp+8] ; b1 index
						push bx ; b2 index
						push [word ptr bp+10] ; balls offset
						call uncollBalls

						push [word ptr bp+12] ; fpu_mem
						push [word ptr bp+8] ; b1 index
						push bx ; b2 index
						push [word ptr bp+10] ; balls offset
						call collisionResponseBB

			not_this_ball_collision_bb:
			inc bx
			cmp bx, 10
			jb collision_bb_loop

	;;;;;;;;
	pop si di bx ax bp
	ret 16
	endp collisionBB


;-----------------------------------------Ball-Wall Collision Procedures-----------------------------
; Handles collisions between a ball and a wall. (Call for each moving ball)
; INPUT: [bp+4] balls offset, [bp+6] ball index, [bp+8] rail offset
; OUTPUT: None.
proc collisionBW
	push bp
	mov bp, sp
	push di si cx
	;;;;;;;
		xor si, si
		
		mov di, [bp+6] ; Ball index
		shl di, 5
		add di, [bp+4] ; di=x of the ball
		mov cx, [di]

		cmp cx, 32+10
		jnb not_colliding_with_west_wall
			;
			; COLLIDING WITH WEST WALL
			mov si, 1
			
			mov cx, 32+10
			mov [di], cx

			fld [dword ptr di+4]
			fchs
			fstp [dword ptr di+4]

			jmp not_colliding_with_east_wall
			;
		not_colliding_with_west_wall:

		cmp cx, 991-10
		jna not_colliding_with_east_wall
			;
			; COLLIDING WITH EAST WALL
			mov si, 1
			
			mov cx, 991-10
			mov [di], cx

			fld [dword ptr di+4]
			fchs
			fstp [dword ptr di+4]
			;
		not_colliding_with_east_wall:
		
		add di, 2
		mov cx, [di] ; y of the ball

		cmp cx, 144+10
		jnb not_colliding_with_north_wall
			
			; COLLIDING WITH NORTH WALL
			mov si, 1
			
			mov cx, 144+10
			mov [di], cx

			add di, 6
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			jmp not_colliding_with_south_wall
			;
		not_colliding_with_north_wall:

		cmp cx, 623-10
		jna not_colliding_with_south_wall
			;
			; COLLIDING WITH SOUTH WALL
			mov si, 1
			
			mov cx, 623-10
			mov [di], cx

			add di, 6
			fld [dword ptr di]
			fchs
			fstp [dword ptr di]
			;
		not_colliding_with_south_wall:
		
		mov cx, [bp+6] ; ball index
		shl si, cl
		mov di, [word ptr bp+8] ; rail offset
		or [word ptr di], si

	;;;;;;;
	pop cx si di bp
	ret 6
	endp collisionBW
;%

;$$ -------------------------Cue Procedures-------------------------
; Handles the cue response.
; INPUT: [bp+14] balls offset, [bp+12] fpu_mem offset, [bp+10] click x, [bp+8] click y, [bp+6] released x, [bp+4] released y
; OUTPUT: [bp+8]+[bp+10] acc_x, [bp+12]+[bp+14] acc_y
proc cue
	push bp
	mov bp, sp
	push ax bx cx dx edi esi
	;;;;;;;;;;
		; acc=Unit(p1)/(inv_mag(p1-p2)*const) = unit(p1)*mag(p1-p2)/const
		
		mov bx, [bp+12] ; fpu_mem
		
		mov di, [bp+14] ; balls offset
		push [word ptr bp+10] ; click x
		push [word ptr bp+8] ; click y
		push [word ptr di]
		push [word ptr di+2]
		call subtract
		pop di
		pop si
		; (di, si) is the direction vector before the normalization.
		
		push ax ; junk
		push bx ; fpu_mem
		push di ; direction x
		push si ; direction y
		call unit
		pop edi
		pop esi
		; (edi, esi) unit vector
		
		push [word ptr bp+10] ; click x
		push [word ptr bp+8] ; click y
		push [word ptr bp+6] ; released x
		push [word ptr bp+4] ; released y
		call subtract
		pop cx
		pop dx
		; (cx, dx) is the vector that determines the force magnitude.
		
		push bx ; fpu_mem
		push cx
		push dx
		call inverseMagnitude
		pop [dword ptr bx] ; inv_mag
		fld [dword ptr bx]
		mov [dword ptr bx], 30 ; can have the user change this number.
		fimul [dword ptr bx] ; ST(0) = Force
		
		mov [bx], edi
		fld [dword ptr bx]
		fdiv ST(0), ST(1)
		fstp [dword ptr bp+8] ; acc_x
		
		mov [bx], esi
		fld [dword ptr bx]
		fdiv ST(0), ST(1)
		fstp [dword ptr bp+12] ; acc_y
		
	;;;;;;;;;;
	pop esi edi dx cx bx ax bp
	ret 4
	endp cue
	
;%

;$$ -------------------------Pockets Procedures-------------------------

; This procedure handles all of the pocket stuff for a moving ball.
; INPUT: [bp+18] nine_pocketed offset, [bp+16] foul offset, [bp+14] pocketed offset, [bp+12] grid offset, [bp+10] previous_balls offset, [bp+8] Balls_template offset, [bp+6] balls offset, [bp+4] ball index
; OUTPUT: [bp+18] 0 if the ball entered a pocket, 1 if not.
proc pockets
	push bp
	mov bp, sp
	push di bx
	;;;;;;;;;;
		push [word ptr bp+6] ; balls offset
		push [word ptr bp+4] ; ball index
		call detectPocket
		pop bx
		cmp bx, -1
		je didnt_enter_any_pocket
			push [word ptr bp+8] ; Balls_template offset
			push [word ptr bp+10] ; previous_balls
			push [word ptr bp+4] ; Ball index
			call clearBall
			
			push [word ptr bp+6] ; balls offset
			push [word ptr bp+8] ; previous_balls offset
			push [word ptr bp+4] ; Ball index
			push [word ptr bp+12] ; grid offset
			call removeBallFromGrid
			
			mov di, [bp+14] ; pocketed offset
			mov [byte ptr di], 1
			
			cmp [word ptr bp+4], 0
			jne no_foul_committed_scratch
				mov di, [word ptr bp+16] ; foul offset
				mov [byte ptr di], 2
			no_foul_committed_scratch:
			
			cmp [word ptr bp+4], 9
			jne no_nine_pocketed
				mov di, [word ptr bp+18] ; nine_pocketed offset
				mov [byte ptr di], 1
			no_nine_pocketed:
			
			mov di, [bp+4]
			shl di, 5
			add di, [bp+6]
			xor bx, bx
			mov [di+24], bx ; doesnt exist anymore XD
			mov [bp+18], bx
			
			jmp entered_a_pocket
		didnt_enter_any_pocket:
			mov bx, 1
			mov [bp+18], bx
		entered_a_pocket:
	;;;;;;;;;;
	pop bx di bp
	ret 14
	endp pockets

; Checks if a ball entered a pocket.
; INPUT: [bp+6] balls offset, [bp+4] ball index
; OUTPUT: -1 if the ball didn't enter a pocket, pocket number if it did.
proc detectPocket
	push bp
	mov bp, sp
	push ax bx di si
	;;;;;;;;;;
		mov bx, [bp+4]
		shl bx, 5
		add bx, [bp+6] ; x0 address
		mov di, [bx]
		add bx, 2
		mov si, [bx]
		; (di, si) = ball coordinates
		add bx, 20 ; cell
		mov al, [bx] ; al = cell 0 number
		
		mov bx, -1
		mov [bp+6], bx
		
		cmp al, 0
		jne not_pocket_0
			cmp di, 32+10
			jnb not_detecting_pocket_0_first
			cmp si, 144+29
			jb detecting_pocket_0
			not_detecting_pocket_0_first:
			
			cmp si, 144+10
			jnb not_pocket_0
			cmp di, 32+29
			jb detecting_pocket_0
			jmp not_pocket_0
			
			detecting_pocket_0:
				xor di, di
				mov [bp+6], di
				jmp not_pocket_5
		not_pocket_0:
		
		cmp al, 7
		jne not_pocket_1
			cmp si, 144+10
			jnb not_pocket_1
			cmp di, 488
			jnae not_pocket_1
			cmp di, 535
			jnbe not_pocket_1
			
			; detecting_pocket_1:
				mov di, 1
				mov [bp+6], di
				jmp not_pocket_5
		not_pocket_1:
		
		cmp al, 14
		jne not_pocket_2
			cmp di, 991-10
			jna not_detecting_pocket_2_first
			cmp si, 144+29
			jb detecting_pocket_2
			not_detecting_pocket_2_first:
			
			cmp si, 144+10
			jnb not_pocket_2
			cmp di, 991-29
			ja detecting_pocket_2
			jmp not_pocket_2
			
			detecting_pocket_2:
				mov di, 2
				mov [bp+6], di
				jmp not_pocket_5
		not_pocket_2:
		
		cmp al, 210
		jne not_pocket_3
			cmp di, 32+10
			jnb not_detecting_pocket_3_first
			cmp si, 623-29
			ja detecting_pocket_3
			not_detecting_pocket_3_first:
			
			cmp si, 623-10
			jna not_pocket_3
			cmp di, 32+29
			jb detecting_pocket_3
			jmp not_pocket_3
			
			detecting_pocket_3:
				mov di, 3
				mov [bp+6], di
				jmp not_pocket_5
		not_pocket_3:
		
		cmp al, 217
		jne not_pocket_4
			cmp si, 623-10
			jna not_pocket_4
			cmp di, 488
			jnae not_pocket_4
			cmp di, 535
			jnbe not_pocket_4
			
			; detecting_pocket_4:
				mov di, 4
				mov [bp+6], di
				jmp not_pocket_5
		not_pocket_4:
		
		cmp al, 224
		jne not_pocket_5
			cmp di, 991-10
			jna not_detecting_pocket_5_first
			cmp si, 623-29
			ja detecting_pocket_5
			not_detecting_pocket_5_first:
			
			cmp si, 623-10
			jna not_pocket_5
			cmp di, 991-29
			ja detecting_pocket_5
			jmp not_pocket_5
			
			detecting_pocket_5:
				mov di, 5
				mov [bp+6], di
		not_pocket_5:
		
	;;;;;;;;;;
	pop si di bx ax bp
	ret 2
	endp detectPocket

; Draws pocket 5
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket5
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 623+21
		drawPocket5_corner_loop1:
			mov cx, 992
			drawPocket5_corner_loop2:
				int 10h
				inc cx
				cmp cx, 992+21-1
				jbe drawPocket5_corner_loop2
			dec dx
			cmp dx, 623+21-20
			jae drawPocket5_corner_loop1
		; dx = y one above square
		drawPocket5_sides_loop1:
			mov cx, 992
			drawPocket5_sides_loop2:
				int 10h
				
				push cx dx
				sub cx, 991
				sub dx, 623
				xchg cx, dx
				neg dx
				add cx, 991
				add dx, 623+22
				int 10h
				pop dx cx
				
				inc cx
				cmp cx, 992+21-1
				jbe drawPocket5_sides_loop2
			dec dx
			cmp dx, 623+21-20-29
			jae drawPocket5_sides_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket5

; Draws pocket 4
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket4
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 624
		drawPocket4_loop1:
			mov cx, 488
			drawPocket4_loop2:
				int 10h
				inc cx
				cmp cx, 535
				jbe drawPocket4_loop2
			inc dx
			cmp dx, 624+21-1
			jbe drawPocket4_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket4

; Draws pocket 3
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket3
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 623+21
		drawPocket3_corner_loop1:
			mov cx, 11
			drawPocket3_corner_loop2:
				int 10h
				inc cx
				cmp cx, 31
				jbe drawPocket3_corner_loop2
			dec dx
			cmp dx, 623+21-20
			jae drawPocket3_corner_loop1
		; dx = y one above square
		drawPocket3_sides_loop1:
			mov cx, 11
			drawPocket3_sides_loop2:
				int 10h
				
				push cx dx
				sub cx, 32
				sub dx, 623
				xchg cx, dx
				neg cx
				add cx, 32
				add dx, 623+22
				int 10h
				pop dx cx
				
				inc cx
				cmp cx, 31
				jbe drawPocket3_sides_loop2
			dec dx
			cmp dx, 623+21-20-29
			jae drawPocket3_sides_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket3

; Draws pocket 2
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket2
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 112+11
		drawPocket2_corner_loop1:
			mov cx, 992
			drawPocket2_corner_loop2:
				int 10h
				inc cx
				cmp cx, 992+21-1
				jbe drawPocket2_corner_loop2
			inc dx
			cmp dx, 112+11+21-1
			jbe drawPocket2_corner_loop1
		; dx = y one below square
		drawPocket2_sides_loop1:
			mov cx, 992
			drawPocket2_sides_loop2:
				int 10h
				
				push cx dx
				sub cx, 991
				sub dx, 144
				xchg cx, dx
				neg cx
				add cx, 991
				add dx, 144-22
				int 10h
				pop dx cx
				
				inc cx
				cmp cx, 992+21-1
				jbe drawPocket2_sides_loop2
			inc dx
			cmp dx, 112+32+29
			jbe drawPocket2_sides_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket2

; Draws pocket 1
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket1
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 143
		drawPocket1_loop1:
			mov cx, 488
			drawPocket1_loop2:
				int 10h
				inc cx
				cmp cx, 535
				jbe drawPocket1_loop2
			dec dx
			cmp dx, 143-21+1
			jae drawPocket1_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket1

; Draws pocket 0
; INPUT: [bp+4] color
; OUTPUT: None.
proc drawPocket0
	push bp
	mov bp, sp
	push ax cx dx
	;;;;;;;;;;
		mov ax, [bp+4] ; color
		mov ah, 0ch
		
		mov dx, 112+11
		drawPocket0_corner_loop1:
			mov cx, 11
			drawPocket0_corner_loop2:
				int 10h
				inc cx
				cmp cx, 31
				jbe drawPocket0_corner_loop2
			inc dx
			cmp dx, 112+11+20
			jbe drawPocket0_corner_loop1
		; dx = y one below square
		drawPocket0_sides_loop1:
			mov cx, 11
			drawPocket0_sides_loop2:
				int 10h
				
				push cx dx
				sub cx, 32
				sub dx, 144
				xchg cx, dx
				neg dx
				add cx, 32
				add dx, 144-22
				int 10h
				pop dx cx
				
				inc cx
				cmp cx, 31
				jbe drawPocket0_sides_loop2
			inc dx
			cmp dx, 112+32+29
			jbe drawPocket0_sides_loop1
	;;;;;;;;;;
	pop dx cx ax bp
	ret 2
	endp drawPocket0

; Draws a pocket
; INPUT: [bp+6] color, [bp+4] Pocket number (0/1/2/3/4/5)
; OUTPUT: None.
proc drawPocket
	push bp
	mov bp, sp
	push ax
	;;;;;;;;;;
		mov ax, [bp+4]
		cmp ax, 0
		jne dont_drawPocket0
			push [word ptr bp+6] ; color
			call drawPocket0
			jmp done_drawing_pocket
		dont_drawPocket0:
		cmp ax, 1
		jne dont_drawPocket1
			push [word ptr bp+6] ; color
			call drawPocket1
			jmp done_drawing_pocket
		dont_drawPocket1:
		cmp ax, 2
		jne dont_drawPocket2
			push [word ptr bp+6] ; color
			call drawPocket2
			jmp done_drawing_pocket
		dont_drawPocket2:
		cmp ax, 3
		jne dont_drawPocket3
			push [word ptr bp+6] ; color
			call drawPocket3
			jmp done_drawing_pocket
		dont_drawPocket3:
		cmp ax, 4
		jne dont_drawPocket4
			push [word ptr bp+6] ; color
			call drawPocket4
			jmp done_drawing_pocket
		dont_drawPocket4:
		cmp ax, 5
		jne done_drawing_pocket
			push [word ptr bp+6] ; color
			call drawPocket5
			jmp done_drawing_pocket
		done_drawing_pocket:

	;;;;;;;;;;
	pop ax bp
	ret 4
	endp drawPocket
	
; Draws all of the pockets.
; INPUT: None.
; OUTPUT: None.
proc drawPockets
	;;;;;;;;;;
			push 0d0h
			call drawPocket0
			push 0d0h
			call drawPocket1
			push 0d0h
			call drawPocket2
			push 0d0h			
			call drawPocket3
			push 0d0h			
			call drawPocket4
			push 0d0h		
			call drawPocket5
	;;;;;;;;;;
	ret
	endp drawPockets
;%

;$$ -------------------------Cursor Procedures-------------------------
; Draws the cursor.
; INPUT: [bp+6] x, [bp+4] y
; OUTPUT: None.
proc drawCursor
	push bp
	mov bp, sp
	push ax cx dx di si
	;;;;;;;;;;
		mov cx, [bp+6] ; x
		mov dx, [bp+4] ; y
		mov al, 4dh ; color
		mov ah, 0ch
		
		mov di, cx
		add di, 3
		mov si, dx
		add si, 3
		
		sub cx, 3
		draw_cursor_loop1:
			mov dx, [bp+4]
			sub dx, 3
			draw_cursor_loop2:
				int 10h
				inc dx
				cmp dx, si
				jbe draw_cursor_loop2
			inc cx
			cmp cx, di
			jbe draw_cursor_loop1
		
	;;;;;;;;;;
	pop si di dx cx ax bp
	ret 4
	endp drawCursor
	
; Backups the background behind the cursor.
; INPUT: [bp+8] cursor_backup address, [bp+6] x, [bp+4] y
; OUTPUT: None.
proc backupBehindCursor
	push bp
	mov bp, sp
	push ax bx cx dx di si
	;;;;;;;;;;
		mov bx, [bp+8] ; cursor_backup address
		mov cx, [bp+6] ; x
		mov dx, [bp+4] ; y
		mov ah, 0dh
		
		mov di, cx
		add di, 3
		mov si, dx
		add si, 3
		
		sub cx, 3
		backup_cursor_loop1:
			mov dx, [bp+4]
			sub dx, 3
			backup_cursor_loop2:
				int 10h
				mov [bx], al
				inc bx
				inc dx
				cmp dx, si
				jbe backup_cursor_loop2
			inc cx
			cmp cx, di
			jbe backup_cursor_loop1
	;;;;;;;;;;
	pop si di dx cx bx ax bp
	ret 6
	endp backupBehindCursor
	
; Draws the cursor backup (hides the cursor).
; INPUT: [bp+8] cursor_backup address, [bp+6] x, [bp+4] y
; OUTPUT: None.
proc hideCursor
	push bp
	mov bp, sp
	push ax bx cx dx di si
	;;;;;;;
		mov bx, [bp+8] ; cursor_backup address
		mov cx, [bp+6] ; x
		mov dx, [bp+4] ; y
		mov ah, 0ch
		
		mov di, cx
		add di, 3
		mov si, dx
		add si, 3
		
		sub cx, 3
		hide_cursor_loop1:
			mov dx, [bp+4]
			sub dx, 3
			hide_cursor_loop2:
				mov al, [bx]
				int 10h
				inc bx
				inc dx
				cmp dx, si
				jbe hide_cursor_loop2
			inc cx
			cmp cx, di
			jbe hide_cursor_loop1
	;;;;;;;
	pop si di dx cx bx ax bp
	ret 6
	endp hideCursor

; Redraws the cursor if it moved.
; INPUT: [bp+10] new x, [bp+8] new y, [bp+6] cursor_backup offset, [bp+4] previous_cursor offset
; OUTPUT: None.
proc redrawCursor
	push bp
	mov bp, sp
	push bx cx dx di si
	;;;;;;;
		mov cx, [bp+10]
		mov dx, [bp+8]
		
		mov bx, [bp+4]
		mov di, [bx] ; x
		add bx, 2
		mov si, [bx] ; y
		
		cmp di, cx
		jne cursor_needs_redrawing
		cmp si, dx
		je cursor_doesnt_need_redrawing
		cursor_needs_redrawing:
				push [word ptr bp+6]
				push di
				push si
				call hideCursor
				
				push [word ptr bp+6]
				push cx
				push dx
				call backupBehindCursor
				
				push cx
				push dx
				call drawCursor
				
				mov [bx], dx
				sub bx, 2
				mov [bx], cx
		cursor_doesnt_need_redrawing:
	;;;;;;;
	pop si di dx cx bx bp
	ret 8
	endp redrawCursor
;%

;$$ -------------------------Drawing Procedures-------------------------

; draws the green part of the table
; INPUT: None
; OUTPUT: None
proc fillTable
	push ax cx dx 
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
	pop dx cx ax
	ret
	endp fillTable
	
; draws the frame of the table.
; INPUT: None.
; OUTPUT: None.
proc drawFrame
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
	endp drawFrame

; gets x0, y0, color and draws the ball.
; INPUT: [bp+10] ball_template offset, [bp+8] x0, [bp+6] y0, [bp+4] color
; OUTPUT: None
proc drawBall
	push bp
	mov bp, sp
	push ax bx cx dx di
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
	pop di dx cx bx ax bp
	ret 8
	endp drawBall

; Clears the ball.
; INPUT: [bp+8] Balls_template offset, [bp+6] previous_balls offset, [bp+4] ball index
; OUTPUT: None.
proc clearBall
	push bp
	mov bp, sp
	push di
	;;;;;;;;;;
		push [word ptr bp+8] ; Balls_template offset
		mov di, [bp+4]
		shl di, 2
		add di, [bp+6]
		push [word ptr di] ; x
		add di, 2
		push [word ptr di] ; y
		push 2 ; color
		call drawBall
	;;;;;;;;;;
	pop di bp
	ret 6
	endp clearBall

; redraws the ball by drawing green on previous position and red on new position.
; INPUT: [bp+4] balls offset, [bp+6] previous_balls offset, [bp+8] ball_template offset, [bp+10] the ball's index
; OUTPUT: None
proc redrawBall
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
		call drawBall ; draw green on previous ball

		push [word ptr bp+8] ; Balls_template offset
		mov di, [bp+10]
		shl di, 5
		add di, [bp+4]
		push [word ptr di] ; x of the new position
		add di, 2
		push [word ptr di] ; y of the new position
		add di, 18
		push [word ptr di] ; color
		call drawBall ; draw red on new ball
		
	;;;;;;;
	pop di bp
	ret 8
	endp redrawBall

; Draws the current player
; INPUT: [bp+4] current_player offset
; OUTPUT: None.
proc drawPlayer
	push bp
	mov bp, sp
	push ax bx cx dx
	;;;;;;;;;;
		mov bx, [bp+4] ; current_player offset
		; p1 - 28h, p2 - 36h
		cmp [byte ptr bx], 0
		je draw_player_1
		cmp [byte ptr bx], 1
		je draw_player_2
		
		draw_player_1:
			mov al, 28h
			jmp draw_player_a
		draw_player_2:
			mov al, 36h
			jmp draw_player_a
		
		draw_player_a:
		
		mov dx, 31
		mov ah, 0ch
		
		draw_player_loop1:
			mov cx, 487
			draw_player_loop2:
				int 10h
				inc cx
				cmp cx, 536
				jbe draw_player_loop2
			inc dx
			cmp dx, 82
			jbe draw_player_loop1
			
			
	;;;;;;;;;;
	pop dx cx bx ax bp
	ret 2
	endp drawPlayer

; Draws the fouls.
; INPUT: [bp+4] fouls_counter offset
; OUTPUT: None.
proc drawFouls
	push bp
	mov bp, sp
	push ax bx cx di si
	;;;;;;;;;;
		mov ah, 0ch
		mov di, [bp+4]
		;p1=28h, p2=36h

		mov bx, 1
		draw_fouls_p1:
			mov si, bx
			shl si, 3
			add si, 665
			mov dx, si
			add si, 4
			
			cmp bl, [di]
			jbe has_this_foul_p1
			jmp doesnt_have_this_foul_p1
			
			has_this_foul_p1:
				mov al, 28h
				jmp draw_fouls_p1_loop1
			doesnt_have_this_foul_p1:
				xor al, al
				
			draw_fouls_p1_loop1:
				mov cx, 11
				draw_fouls_p1_loop2:
					int 10h
					inc cx
					cmp cx, 30
					jbe draw_fouls_p1_loop2
				inc dx
				cmp dx, si
				jbe draw_fouls_p1_loop1
			inc bx
			cmp bx, 3
			jbe draw_fouls_p1
		
		mov bx, 1
		draw_fouls_p2:
			mov si, bx
			shl si, 3
			add si, 665
			mov dx, si
			add si, 4
			
			cmp bl, [di+1]
			jbe has_this_foul_p2
			jmp doesnt_have_this_foul_p2
			
			has_this_foul_p2:
				mov al, 36h
				jmp draw_fouls_p2_loop1
			doesnt_have_this_foul_p2:
				xor al, al
				
			draw_fouls_p2_loop1:
				mov cx, 995
				draw_fouls_p2_loop2:
					int 10h
					inc cx
					cmp cx, 1014
					jbe draw_fouls_p2_loop2
				inc dx
				cmp dx, si
				jbe draw_fouls_p2_loop1
			inc bx
			cmp bx, 3
			jbe draw_fouls_p2

	;;;;;;;;;;
	pop si di cx bx ax bp
	ret 2
	endp drawFouls

;%

;$$ -------------------------Update Procedures-------------------------

; does collision detection and redraws every ball that moved since the last frame.
; INPUT: [bp+4] balls offset, [bp+6] Balls_template offset, [bp+8] previous_balls offset, [bp+10] grid offset, [bp+12] fpu_mem offset, [bp+14] gamemode offset, [bp+16] foul offset, [bp+18] cue_collided offset, [bp+20] rail offset, [bp+22] pocketed offset, [bp+24] nine_pocketed offset
; OUTPUT: None.
proc updateMovingBalls
	push bp
	mov bp, sp
	push di si ax bx cx dx
	;;;;;;;
		mov bx, [bp+14] ; gamemode offset
		mov [byte ptr bx], 1
		
		mov di, [bp+4] ; balls offset
		mov si, [bp+8] ; previous_balls offset
		xor ax, ax
		check_if_ball_moved_loop:
			mov cx, [di+24]
			test cx, cx
			je ball_didnt_move
			
			mov cx, [di]
			mov dx, [si]
			cmp cx, dx
			jne ball_moved

			mov cx, [di+2]
			mov dx, [si+2]
			cmp cx, dx
			jne ball_moved

			jmp ball_didnt_move
			
			ball_moved:
				
				mov [byte ptr bx], 0 ; keep the mode balls_moving
				
				push [word ptr bp+24] ; nine_pocketed offset
				push [word ptr bp+16] ; foul offset
				push [word ptr bp+22] ; pocketed offset
				push [word ptr bp+10] ; grid offset
				push [word ptr bp+8] ; previous_balls offset
				push [word ptr bp+6] ; Balls_template offset
				push [word ptr bp+4] ; balls offset
				push ax ; ball index
				call pockets
				pop cx
				test cx, cx
				je ball_didnt_move ; the ball entered a pocket and so it doesnt exist anymore.
				
				; ax = index of the ball
				push [word ptr bp+18] ; cue_collided offset
				push [word ptr bp+16] ; Foul offset
				push [word ptr bp+6] ; Balls_template offset
				push [word ptr bp+12] ; fpu_mem offset
				push [word ptr bp+4] ; balls offset
				push ax ; ball index
				push [word ptr bp+10] ; grid offset
				push [word ptr bp+8] ; previous_balls offset
				call collisionBB
				
				push [word ptr bp+20] ; rail offset
				push ax ; ball index
				push [word ptr bp+4] ; balls offset
				call collisionBW

			ball_didnt_move:
			inc ax
			add si, 4
			add di, 32
			cmp ax, 10
			jb check_if_ball_moved_loop


		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
		mov di, [bp+4] ; balls offset
		mov si, [bp+8] ; previous_balls offset
		xor ax, ax
		check_if_ball_moved_loop2:
			mov cx, [di+24]
			test cx, cx
			je ball_didnt_move2
			
			mov cx, [di]
			mov dx, [si]
			cmp cx, dx
			jne ball_moved2

			mov cx, [di+2]
			mov dx, [si+2]
			cmp cx, dx
			jne ball_moved2

			jmp ball_didnt_move2
			
			ball_moved2:
				
					push ax ; ball index
					push [word ptr bp+6] ; Balls_template offset
					push [word ptr bp+8] ; previous_balls offset
					push [word ptr bp+4] ; balls offset
					call redrawBall

			ball_didnt_move2:
			inc ax
			add si, 4
			add di, 32
			cmp ax, 10
			jb check_if_ball_moved_loop2
	;;;;;;;
	pop dx cx bx ax si di bp
	ret 22
	endp updateMovingBalls


; backups the balls' position from the balls array to the previous_balls array.
; INPUT: [bp+4] balls offset, [bp+6] previous_balls offset
proc backupBalls
	push bp
	mov bp, sp
	push ax bx cx si di
	;;;;;;;
		mov di, [bp+6] ; previous_balls offset
		mov si, [bp+4] ; balls offset
		; mov bx, di
		; add bx, 40
		mov cx, 10
		move_to_previous_balls_array:
			mov ax, [si+24]
			test ax, ax
			je didnt_backup_this_ball
			
			mov ax, [si]
			mov [di], ax ; moves the x

			mov ax, [si+2]
			mov [di+2], ax ; moves the y

			didnt_backup_this_ball:
			; cmp di, bx
			; jb move_to_previous_balls_array
			add di, 4
			add si, 32 ; continue to the next ball
			loop move_to_previous_balls_array
	;;;;;;;
	pop di si cx bx ax bp
	ret 4
	endp backupBalls

; Gets the velocity, and returns the new velocity after the decrease due to friction.
; INPUT: [bp+4]+[bp+6] velocity value, [bp+8] friction offset
; OUTPUT: [bp+6][bp+8] New velocity (32bits)
proc changeVelocityFriction
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
	endp changeVelocityFriction
	
; Changes the pos_x,pos_y,vel_x,vel_y of every ball according to its acceleration.
; INPUT: [bp+6] friction offset, [bp+4] balls offset
; OUTPUT: None.
proc reposition
	push bp
	mov bp, sp
	push di ax cx
	;;;;;;;;;;

		mov di, [bp+4] ; balls offset
		; add di, 32*10 ; di = pos_x address of after the last ball (does not actually exist).
		mov cx, 10
		reposition_every_ball:
			mov ax, [di+24]
			test ax, ax
			je didnt_reposition_this_ball
			

			fld [dword ptr di+16] ; acc_y
			fadd [dword ptr di+8] ; vel_y
			fstp [dword ptr di+8]
			; updates vel_y

			push [word ptr bp+6] ; friction offset
			push [dword ptr di+8]
			call changeVelocityFriction
			pop [dword ptr di+8]
			; updtaes vel_y after friction

			fld [dword ptr di+8]
			frndint
			fiadd [word ptr di+2] ; pos_y
			fistp [word ptr di+2]
			; updates pos_y


			fld [dword ptr di+12] ; acc_x
			fadd [dword ptr di+4] ; vel_x
			fstp [dword ptr di+4]
			; updates vel_x

			push [word ptr bp+6] ; friction offset
			push [dword ptr di+4]
			call changeVelocityFriction
			pop [dword ptr di+4]
			; updtaes vel_x after friction

			fld [dword ptr di+4]
			frndint
			fiadd [word ptr di] ; pos_x
			fistp [word ptr di]
			; updates pos_x
			
			mov [dword ptr di+12], 0
			mov [dword ptr di+16], 0
			
			didnt_reposition_this_ball:
			add di, 32
			loop reposition_every_ball
	;;;;;;;;;;
	pop cx ax di bp
	ret 4
	endp reposition
;%

;$$ -------------------------Game Procedures-------------------------

; Outputs the index of the lowest numbered ball on the table.
; INPUT: [bp+4] balls offset
; OUTPUT: [bp+4] ball index
proc getLowestBall
	push bp
	mov bp, sp
	push ax bx di
	;;;;;;;;;;
		mov di, [bp+4] ; balls offset
		add di, 32 ; start from the second ball (since the first ball is the cue ball)
		mov bx, 1
		get_lowest_ball_loop:
			mov ax, [di+24]
			test ax, ax
			je is_not_lowest_ball
				mov [bp+4], bx
				jmp found_lowest_ball
			is_not_lowest_ball:
			add di, 32
			inc bx
			cmp bx, 9
			jbe get_lowest_ball_loop
		
		found_lowest_ball:
	;;;;;;;;;;
	pop di bx ax bp
	ret
	endp getLowestBall

; Handles the fouls - changes the turn if needed.
; INPUT: [bp+18] nine_pocketed offset, [bp+16] gamemode offset, [bp+14] fouls_counter offset, [bp+12] cue_collided offset, [bp+10] rail offset, [bp+8] pocketed offset, [bp+6] foul offset, [bp+4] current_player offset
; OUTPUT: None.
proc handleFouls
	push bp
	mov bp, sp
	push ax di
	;;;;;;;;;;
		xor ax, ax
		
		mov di, [word ptr bp+6] ; foul offset
		cmp [byte ptr di], 2
		jne no_scratch
			mov di, [word ptr bp+16] ; gamemode offset
			mov [byte ptr di], 2 ; change to in hand gamemode
		no_scratch:
		
		mov di, [bp+12] ; cue_collided offset
		cmp [byte ptr di], al
		je no_foul_committed_no_rail
			mov di, [bp+10] ; rail offset
			cmp [word ptr di], ax
			jne no_foul_committed_no_rail
				mov di, [bp+8] ; pocketed offset
				cmp [byte ptr di], al
				jne no_foul_committed_no_rail
					mov di, [bp+6] ; foul offset
					mov [byte ptr di], 1
		no_foul_committed_no_rail:
		; no_rail foul 
		
		mov di, [bp+8] ; pocketed offset
		cmp [byte ptr di], al
		jne no_miss
			mov di, [bp+6] ; foul offset
			cmp [byte ptr di], al
			jne miss_and_foul
				mov di, [bp+4] ; current_player offset
				mov al, [di] ; al = current player
				mov di, [bp+14] ; fouls_counter offset
				add di, ax
				mov [byte ptr di], 0 ; resets the foul counter
			
				xor al, al
				jmp didnt_lose_yet
			miss_and_foul:
			mov di, [bp+6] ; foul offset
			mov [byte ptr di], 1
		no_miss:
		; miss foul
			
		mov di, [bp+6] ; foul offset
		cmp [byte ptr di], al
		je no_foul_committed
			mov di, [bp+4] ; current_player offset
			mov al, [di] ; al = current player
			mov di, [bp+14] ; fouls_counter offset
			add di, ax
			inc [byte ptr di] ; increases the foul counter
			cmp [byte ptr di], 3
			jb didnt_lose_yet
				push ax
				call finishGame
			didnt_lose_yet:
			
			
			mov di, [bp+4] ; current_player offset
			xor [byte ptr di], 1 ; changes the player
			
			jmp foul_committed
		no_foul_committed:
			mov di, [bp+4] ; current_player offset
			mov al, [di] ; al = current player
			mov di, [bp+14] ; fouls_counter offset
			add di, ax
			mov [byte ptr di], 0 ; make the foul counter zero
			
			mov di, [bp+18] ; nine_pocketed offset
			cmp [byte ptr di], 1
			jne foul_committed ; nine ball wasnt pocketed
				push ax
				call finishGame
		foul_committed:
		
		xor ax, ax
		mov di, [bp+6] ; foul offset
		mov [byte ptr di], al
		mov di, [bp+12] ; cue_collided offset
		mov [byte ptr di], al
		mov di, [bp+10] ; rail offset
		mov [word ptr di], ax
		mov di, [bp+8] ; pocketed offset
		mov [byte ptr di], al
		; resets all the foul variables
		
		push offset fouls_counter
		call drawFouls
		push offset current_player
		call drawPlayer
	;;;;;;;;;;
	pop di ax bp
	ret 16
	endp handleFouls

; checks if the player who has the ball in hand can put it in this location.
; INPUT: [bp+10] x of location, [bp+8] y of location, [bp+6] balls offset, [bp+4] fpu_mem offset.
; OUTPUT: [bp+10] 1 if collision detected, 0 if not.
proc canPutBall
	push bp
	mov bp, sp
	push eax bx cx dx si di
	;;;;;;;;
		mov bx, [bp+4] ; fpu_mem offset
		mov dx, [bp+10]
		xor ax, ax
		mov [bp+10], ax ; returns 0
		
		mov cx, 9
		can_put_ball_loop:
			mov di, cx
			shl di, 5
			add di, [bp+6]
			cmp [word ptr di+24], 0
			je collision_not_detected_in_hand_b ; ball doesnt exist
			
			push [word ptr di]
			push [word ptr di+2]
			push dx ; x
			push [word ptr bp+8] ; y
			call subtract
			pop di ; x of the difference vector
			pop si ; y of the difference vector

			push bx ; fpu_mem offset
			push di
			push si
			call magnitude
			pop eax ; eax now holds the magnitude of the difference vector.

			mov [bx], eax
			fld [dword ptr bx]; loads the magnitude to the FPU stack
			mov [dword ptr bx], 30 ; 20 = r1+r2 = 10+10
			fild [dword ptr bx] ; loads r1+r2 to the FPU stack
			; now ST(0)=20, ST(1)=mag
			fcom ; compares 20 to the magnitude
			fnstsw ax ; moves the FPU flag register to ax
			sahf ; moves ax to the flag register
			jnae collision_not_detected_in_hand_b ; if r1+r2>=mag
				mov ax, 1
				mov [bp+10], ax ; returns 1
				jmp finished_checking_can_put_ball
			collision_not_detected_in_hand_b:
			loop can_put_ball_loop
			
		mov ax, 1
		cmp dx, 32+10
		jnb not_colliding_with_west_wall_cue
			mov [bp+10], ax
			jmp finished_checking_can_put_ball
			
		not_colliding_with_west_wall_cue:

		cmp dx, 991-10
		jna not_colliding_with_east_wall_cue
			mov [bp+10], ax
			jmp finished_checking_can_put_ball

		not_colliding_with_east_wall_cue:

		cmp [word ptr bp+8], 144+10
		jnb not_colliding_with_north_wall_cue
			mov [bp+10], ax
			jmp finished_checking_can_put_ball

		not_colliding_with_north_wall_cue:

		cmp [word ptr bp+8], 623-10
		jna finished_checking_can_put_ball
			mov [word ptr bp+10], ax

		finished_checking_can_put_ball:

	;;;;;;;;
	pop di si dx cx bx eax bp
	ret 6
	endp canPutBall

; Returns the cue ball to the game.
; INPUT: [bp+12] x, [bp+10] y, [bp+8] balls offset, [bp+6] grid offset, [bp+4] ball_template offset
; OUTPUT: None.
proc returnCueBall
	push bp
	mov bp, sp
	push eax di
	;;;;;;;;;;
		mov di, [bp+8]
		mov ax, [bp+12]
		mov [di], ax
		mov ax, [bp+10]
		mov [di+2], ax
		; sets the coordinates
		
		mov ax, 1
		mov [di+24], ax ; changes the existence property
		
		xor eax, eax
		mov [di+4], eax
		mov [di+8], eax
		mov [di+12], eax
		mov [di+16], eax
		; resets the velocity & acceleration
		
		push [word ptr bp+8] ; balls offset
		push 0
		push [word ptr bp+6] ; grid offset
		call addBallToGrid ; adds the ball to the grid
		
		push [word ptr bp+4] ; ball_template offset
		push [word ptr bp+12] ; x
		push [word ptr bp+10] ; y
		push [word ptr di+20] ; color
		call drawBall ; draws the ball
		
	;;;;;;;;;;
	pop di eax bp
	ret 10
	endp returnCueBall

; End of the game
; INPUT: [bp+4] winner
; OUTPUT: None.
proc finishGame
	push bp
	mov bp, sp
	push ax
	;;;;;;;;;;
		mov ax, 4c00h
		int 21h
	;;;;;;;;;;
	pop ax bp
	ret 2
	endp finishGame

;%

;$$ -------------------------Gamemodes Handlers Procedures-------------------------

; Handles gamemode 0 - balls moving, physics, etc.
; INPUT: [bp+26] nine_pocketed offset, [bp+24] pocketed offset, [bp+22] rail offset, [bp+20] cue_collided offset, [bp+18] foul offset, [bp+16] previous_balls offset, [bp+14] balls offset, [bp+12] friction offset, [bp+10] gamemode offset, [bp+8] fpu_mem offset, [bp+6] grid offset, [bp+4] ball_template offset
; OUTPUT: None.
proc handleGamemode0
	push bp
	mov bp, sp
	;;;;;;;;;;
		call check_exit

		push [word ptr bp+16] ; previous_balls offset
		push [word ptr bp+14]; balls offset
		call backupBalls
			
		push [word ptr bp+12] ; friction offset
		push [word ptr bp+14] ; balls offset
		call reposition
		
		push [word ptr bp+26] ; nine_pocketed offset
		push [word ptr bp+24] ; pocketed offset
		push [word ptr bp+22] ; rail offset
		push [word ptr bp+20] ; cue_collided offset
		push [word ptr bp+18] ; foul offset
		push [word ptr bp+10] ; gamemode offset
		push [word ptr bp+8] ; fpu_mem offset
		push [word ptr bp+6] ; grid offset
		push [word ptr bp+16] ; previous_balls offset
		push [word ptr bp+4] ; ball_template offset
		push [word ptr bp+14] ; balls offset
		call updateMovingBalls

		call delay
	;;;;;;;;;;
	pop bp
	ret 24
	endp handleGamemode0

; Handles gamemode 1 - cue, cursor, etc.
; INPUT: [bp+12] cursor_backup offset, [bp+10] previous_cursor offset, [bp+8] balls offset, [bp+6] fpu_mem offset, [bp+4] gamemode offset
; OUTPUT: None.
proc handleGamemode1
	push bp
	mov bp, sp
	push ax bx cx dx di
	;;;;;;;;;;
		
		mov di, [word ptr bp+10] ; previous_cursor offset
		push [word ptr bp+12]
		push [word ptr di]
		push [word ptr di+2]
		call backupBehindCursor
		
		gamemode1_waiting_for_click:
			call check_exit
				
			mov ax, 0003h
			int 33h
			
			push cx
			push dx
			push [word ptr bp+12]; cursor_Backup
			push [word ptr bp+10] ; previous_cursor
			call redrawCursor
				
			shr bx, 1
			jnc gamemode1_waiting_for_click
			
		;;;;;;;;;;;;;; After click ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		push cx
		push dx
					
		waiting_for_force:
					
			; STUFF TO DO WHEN LEFT CLICK IS PRESSED
			push cx
			push dx
			push [word ptr bp+12]; cursor_Backup
			push [word ptr bp+10] ; previous_cursor
			call redrawCursor
						
			mov ax, 0003h
			int 33h
						
			shr bx, 1
			jc waiting_for_force
		
		;;;;;;;;;;;;;; After release ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov di, [word ptr bp+10] ; previous_cursor
		push [word ptr bp+12] ; cursor_backup
		push [word ptr di]
		push [word ptr di+2]
		call hideCursor
					
		pop bx ; y of direction
		pop ax ; x of direction
		
		cmp ax, cx
		jne cursor_moved
		cmp bx, dx
		jne cursor_moved
			push cx
			push dx
			call drawCursor
			jmp gamemode1_waiting_for_click
		cursor_moved:
		; checks if the cursor even moved
					
		push [word ptr bp+8] ; balls offset
		push [word ptr bp+6] ; fpu_mem
		push ax
		push bx
		push cx
		push dx
		call cue
					
		mov di, [word ptr bp+8] ; balls offset
					
		pop [dword ptr di+12] ; acc_x
		pop [dword ptr di+16] ; acc_y
		
		mov di, [word ptr bp+4] ; gamemode offset
		mov [byte ptr di], 0

	;;;;;;;;;;
	pop di dx cx bx ax bp
	ret 10
	endp handleGamemode1

; Handles gamemode 2 - cue in hand
; INPUT: [bp+18] previous_cursor offset, [bp+16] cursor_backup offset, [bp+14] balls offset, [bp+12] fpu_mem offset, [bp+10] grid offset, [bp+8] ball_template offset, [bp+6] gamemode offset, [bp+4] pocketed offset
; OUTPUT: None.
proc handleGamemode2
	push bp
	mov bp, sp
	push di ax cx dx
	;;;;;;;;;;
		mov di, [word ptr bp+18] ; previous_cursor offset
		push [word ptr bp+16] ; cursor_backup offset
		push [word ptr di]
		push [word ptr di+2]
		call backupBehindCursor
			
		gamemode2_waiting_for_click:
			call check_exit
				
			mov ax, 0003h
			int 33h
					
			push cx
			push dx
			push [word ptr bp+16] ; cursor_backup offset
			push [word ptr bp+18] ; previous_cursor offset
			call redrawCursor
					
					
			shr bx, 1
			jnc gamemode2_waiting_for_click
			
		;;;;;;;;;;;;;; After click ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		push cx
		push dx
		push [word ptr bp+14] ; balls offset
		push [word ptr bp+12] ; fpu_mem offset
		call canPutBall
		pop ax
		test ax, ax
		jne gamemode2_waiting_for_click
			
			
		push cx
		push dx
		push [word ptr bp+14] ; balls offset
		push [word ptr bp+10] ; grid offset
		push [word ptr bp+8] ; ball_template offset
		call returnCueBall
			
		mov di, [word ptr bp+6] ; gamemode offset
		mov [byte ptr di], 1
			
		checking_that_left:
						
			mov ax, 0003h
			int 33h
							
			shr bx, 1
			jc checking_that_left
			
		mov di, [word ptr bp+4] ; pocketed offset
		mov [byte ptr di], 1 ; pocketed has to be equal 1 when entering cue mode not after a turn
	
	;;;;;;;;;;
	pop dx cx ax di bp
	ret 16
	endp handleGamemode2
;%

;$$ -------------------------Initial Procedures-------------------------

; Initiates the grid.
; INPUT: [bp+6] balls offset, [bp+4] grid offset
; OUTPUT: None.
proc initializeGrid
	push bp
	mov bp, sp
	push di
	;;;;;;;;;;
		xor di, di
		initial_cell_division_loop:
			push [word ptr bp+6] ; balls offset
			push di
			push [word ptr bp+4] ; grid offset
			call addBallToGrid

			inc di
			cmp di, 10
			jne initial_cell_division_loop
	;;;;;;;;;;
	pop di bp
	ret 4
	endp initializeGrid

; Draws all of the balls.
; INPUT: [bp+6] balls offset, [bp+4] Balls_template offset
; OUTPUT: None
proc initializeBalls
	push bp
	mov bp, sp
	push di cx
	;;;;;;;;;
		mov di, [bp+6] ; balls offset
		mov cl, 10
		draw_all_balls_loop:

			push [word ptr bp+4] ; ball_template offset
			push [word ptr di] ; x0
			add di, 2
			push [word ptr di] ; y0
			add di, 18
			push [word ptr di] ; color
			call drawBall

			add di, 12
			loop draw_all_balls_loop

	;;;;;;;;;
	pop cx di bp
	ret 4
	endp initializeBalls

; Initiates everything - screen, table, balls, grid.
; INPUT: [bp+10] cursor_backup offset, [bp+8] ball_template offset, [bp+6] balls offset, [bp+4] grid offset
; OUTPUT: None.
proc initializeTable
	push bp
	mov bp, sp
	push ax bx cx dx
	;;;;;;;
		call set_screen
		call drawFrame
		call fillTable
		call drawPockets
		
		push [word ptr bp+6]
		push [word ptr bp+8]
		call initializeBalls

		push [word ptr bp+6]
		push [word ptr bp+4]
		call initializeGrid
		
		mov ax, 0003h
		int 33h
		push [word ptr bp+10]
		push cx
		push dx
		call backupBehindCursor

	;;;;;;;
	pop dx cx bx ax bp
	ret 8
	endp initializeTable
;%

;$$ -------------------------Main-------------------------
start:
	mov ax, @data
	mov ds, ax
	
	push offset cursor_backup
	push offset ball_template
	push offset balls
	push offset grid
	call initializeTable
	
	push offset current_player
	call drawPlayer
	
	main_loop:
		mov di, offset gamemode
		cmp [byte ptr di], 0
		je gamemode_0_BallsMoving
		
		push offset nine_pocketed
		push offset gamemode
		push offset fouls_counter
		push offset cue_collided
		push offset rail
		push offset pocketed
		push offset foul
		push offset current_player
		call handleFouls
		
		cmp [byte ptr di], 1
		je gamemode_1_WaitingForCue
		cmp [byte ptr di], 2
		je gamemode_2_InHand
		jmp main_loop
		
		gamemode_0_BallsMoving:
			push offset nine_pocketed
			push offset pocketed
			push offset rail
			push offset cue_collided
			push offset foul
			push offset previous_balls
			push offset balls
			push offset friction
			push offset gamemode
			push offset fpu_mem
			push offset grid
			push offset ball_template
			call handleGamemode0
			jmp main_loop
			
		gamemode_1_WaitingForCue:
			
			push offset cursor_backup
			push offset previous_cursor
			push offset balls
			push offset fpu_mem
			push offset gamemode
			call handleGamemode1
			jmp main_loop
		
		gamemode_2_InHand:

			push offset previous_cursor
			push offset cursor_backup
			push offset balls
			push offset fpu_mem
			push offset grid
			push offset ball_template
			push offset gamemode
			push offset pocketed
			call handleGamemode2
			jmp main_loop
exit:
	mov ax, 4c00h
	int 21h
END start