; V1c - THIS VERSION INCLUDES THE NARROW PHASE BB COLLISION DETECTION SYSTEM, WITH THE SCREEN AND OPTIMIZED MOVEMENT.



; SCREEN SIZE: 1024x768
; TABLE SIZE: 1024x512 (from y=128 to y=639, x=0 to x=1023)
; BALLS RADIUS: 17px (1px center)



.386
IDEAL
MODEL small
STACK 100h
DATASEG
Balls dw 17*1, 17+128, 4 dup(0), 12, ?, 17*3+1, 17+128, 4 dup(0), 12, ?, 17*5, 17+128, 4 dup(0), 12, ?, 17*7, 17+128, 4 dup(0), 12, ?, 17*9, 17+128, 4 dup(0), 12, ?, 17*11, 17+128, 4 dup(0), 12, ?, 17*13, 17+128, 4 dup(0), 12, ?, 17*15, 17+128, 4 dup(0), 12, ?, 17*17, 17+128, 4 dup(0), 12, ?, 17*19, 17+128, 4 dup(0), 12, ?, '$'
BallsPrevious dw 20 dup(?)
; Balls array: x,y,vel_x,vel_y,acc_x,_acc_y, color, ?
FPUmem dd ?
Ball_template db 0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0, '$'
db 0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0, '$'
db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0, '$'
db 0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0, '$'
db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0, '$'
db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0, '$'
db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0, '$'
db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0, '$'
db 0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0, '$'
db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0, '$'
db 0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0, '$'
db 0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0,0, '$'
db 0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0,0,0,0,0, '#'

CODESEG

;-------------------------Other Procedures-----------------------------

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
	mov ax, 0007h
	mov cx, 0
	mov dx, 1023
	int 33h
	
	mov ax, 0008h
	mov cx, 0
	mov dx, 767
	int 33h
	;;;;;;;;
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	endp set_screen

; Creates a small delay.
; OUTPUT: None
; INPUT: None
proc delay
	push ax
	;;;;;;;;;;;;
	mov ax, 0ff0fh
	delay_loop1:
		push ax
		mov ax, 1
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
; INPUT: [bp+4] index of b2 in the Balls array, [bp+6] index of b1 in the balls array, [bp+8] Balls offset, [bp+10] FPUmem offset.
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
		mov bx, [bp+10] ; FPUmem offset
		
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
		
		push bx ; FPUmem offset
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
		
		mov dx, 128
		fill_table_loop_y:
			xor cx, cx
			fill_table_loop_x:
				int 10h
				inc cx
				cmp cx, 1024
				jb fill_table_loop_x
			inc dx
			cmp dx, 640
			jb fill_table_loop_y
	pop dx
	pop cx
	pop ax
	ret
	endp fill_table

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
		sub dx, 18
		draw_ball_loop_y:
			;call delay
			inc dx
			mov cx, [bp+8]
			sub cx, 18
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
; INPUT: [bp+4] the ball's Balls offset, [bp+6] the ball's BallsPrevious offset, [bp+8] Ball_template offset
; OUTPUT: None
proc redraw_ball
	push bp
	mov bp, sp
	push di
	;;;;;;;
		mov di, [bp+6]
		push [word ptr bp+8] ; BallsPrevious offset
		push [word ptr di] ; x of the previous position
		add di, 2
		push [word ptr di] ; y of the previous position
		push 2 ; background color
		call draw_ball ; draw green on previous ball
		
		mov di, [bp+4]
		push [word ptr bp+8] ; BallsPrevious offset
		push [word ptr di] ; x of the new position
		add di, 2
		push [word ptr di] ; y of the new position
		add di, 10
		push [word ptr di] ; color
		call draw_ball ; draw red on new ball
	;;;;;;;
	pop di
	pop bp
	ret 6
	endp redraw_ball

; draws everything. Balls offset and Ball_template offset as input, no output
; INPUT: [bp+4] Balls offset, [bp+6] Ball_template offset, [bp+8] BallsPrevious offset
; OUTPUT: None
proc update_draw
	push bp
	mov bp, sp
	push ax
	push bx
	push di
	push si
	;;;;;
		;call fill_table
		mov di, [bp+4]
		mov si, [bp+8]
		draw_balls_loop:
		
			mov ax, [di]
			mov bx, [si]
			cmp ax, bx
			jne draw_this_ball
			
			add di, 2
			add si, 2
			mov ax, [di]
			mov bx, [si]
			sub di, 2
			sub si, 2
			cmp ax, bx
			jne draw_this_ball
			
			jmp dont_draw_this_ball
			draw_this_ball:
			
			push [word ptr bp+6]
			push si
			push di
			call redraw_ball
			
			dont_draw_this_ball:
			add di, 16
			add si, 4
			mov ax, [di]
			cmp ax, '$'
			jne draw_balls_loop
	;;;;;
	pop si
	pop di
	pop bx
	pop ax
	pop bp
	ret 6
	endp update_draw

;--------------------------Update Procedures-----------------------------------

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
			add si, 14 ; continue to the next ball
			
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	mov ax, @data
	mov ds, ax
	
	call set_screen
	call fill_table
	
	
	push offset BallsPrevious
	push offset Ball_template
	push offset Balls
	call update_draw
	
	main_loop:
		mov ax, 03h
		int 33h
		cmp bx, 01h
		jne main_loop
		jmp after_first_click
		release:
		mov ax, 03h
		int 33h
		after_first_click:
		push bx
			
		push offset BallsPrevious
		push offset Balls
		call move_to_previous
		
		mov di, offset Balls
		mov [di], cx
		add di, 2
		mov [di], dx ; update Balls position to mouse position
		
		mov cx, 9
		add di, 10 ; color
		mov [word ptr di], 12
		collision_detection_bb_each:
			push offset FPUmem
			push offset Balls
			push 0
			push cx
			call collision_detection_bb
			pop ax
			cmp ax, 1
			jne ball_not_colliding
				mov [word ptr di], 14
			ball_not_colliding:
			loop collision_detection_bb_each
		
		push offset BallsPrevious
		push offset Ball_template
		push offset Balls
		call update_draw
		
		pop bx
		cmp bx, 00h
		jne release
		jmp main_loop

exit:
	mov ax, 4c00h
	int 21h
END start