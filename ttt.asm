segment code:
..start:
    mov 		ax,data
    mov 		ds,ax
    mov 		ax,stack
    mov 		ss,ax
    mov 		sp,stacktop
    
; salvar modo corrente de video(vendo como est� o modo de video da maquina)
    mov  		ah,0Fh
    int  		10h
    mov  		[modo_anterior],al   

; alterar modo de video para gr�fico 640x480 16 cores
    mov     	al,12h
   	mov     	ah,0
    int     	10h

    call        blank_screen
	call		get_three_chars


; aguarda tecla e retorna
    mov    	ah,08h
	int     21h
	mov  	ah,0   			; set video mode
	mov  	al,[modo_anterior]   	; modo anterior
	int  	10h
	mov     ax,4c00h
	int     21h


get_three_chars:
    push    ax
    push    bx
    push    cx
    push    dx
    
    
    ; Read the first character
	mov byte[cor], azul_claro
    mov     dh, 27
    mov     dl, 30
	call cursor
    mov     ah, 7
    int     21h
    call    caracter
	inc dl
    
    ; Read the second character
    call cursor
	mov     ah, 7
    int     21h
    call    caracter
    inc dl

    ; Read the third character
	call cursor
    mov     ah, 7
    int     21h
    call    caracter
    
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

draw_cross:
    push    ax
    push    bx
    push    cx
    push    dx
    
    ; Draw the first line of the cross
    mov     ax, 62
    push    ax
    mov     ax, 25
    push    ax
    mov     ax, 577
    push    ax
    mov     ax, 360
    push    ax
    call    line
    
    ; Draw the second line of the cross
    mov     ax, 62
    push    ax
    mov     ax, 360
    push    ax
    mov     ax, 577
    push    ax
    mov     ax, 25
    push    ax
    call    line
    
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

clear_screen:
    mov     ah, 0
    mov     al, 3
    int     10h
    ret

blank_screen:
; left tik tak toe bar
    mov		byte[cor],branco_intenso
	mov		ax,232
	push		ax
	mov		ax,180
	push		ax
	mov		ax,232
	push		ax
	mov		ax,450
	push		ax
	call		line
; right tik tak toe bar
	mov		ax,407
	push		ax
	mov		ax,180
	push		ax
	mov		ax,407
	push		ax
	mov		ax,450
	push		ax
	call		line
; lower tik tak toe bar
    mov		ax,62
    push		ax
    mov		ax,266
    push		ax
    mov		ax,577
    push		ax
    mov		ax,266
    push		ax
    call		line
; upper tik tak toe bar
    mov		ax,62
    push		ax
    mov		ax,360
    push		ax
    mov		ax,577
    push		ax
    mov		ax,360
    push		ax
    call		line
; comand zone square
    mov		ax,62
    push		ax
    mov		ax,25
    push		ax
    mov		ax,577
    push		ax
    mov		ax,25
    push		ax
    call		line
    mov		ax,62
    push		ax
    mov		ax,55
    push		ax
    mov		ax,577
    push		ax
    mov		ax,55
    push		ax
    call		line
    mov		ax,62
    push		ax
    mov		ax,90
    push		ax
    mov		ax,577
    push		ax
    mov		ax,90
    push		ax
    call		line
    mov		ax,62
    push		ax
    mov		ax,120
    push		ax
    mov		ax,577
    push		ax
    mov		ax,120
    push		ax
    call		line
; other zone square
    mov		ax,62
    push		ax
    mov		ax,25
    push		ax
    mov		ax,62
    push		ax
    mov		ax,55
    push		ax
    call		line
    mov		ax,577
    push		ax
    mov		ax,25
    push		ax
    mov		ax,577
    push		ax
    mov		ax,55
    push		ax
    call		line
    mov		ax,62
    push		ax
    mov		ax,90
    push		ax
    mov		ax,62
    push		ax
    mov		ax,120
    push		ax
    call		line
    mov		ax,577
    push		ax
    mov		ax,90
    push		ax
    mov		ax,577
    push		ax
    mov		ax,120
    push		ax
    call		line
;  comand zone string
    mov     	cx,16			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,23			;linha 0-29
    mov     	dl,10			;coluna 0-79
printcommand:
    call	cursor
    mov     al,[bx+campo_comando]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    printcommand
;  message zone string
    mov     	cx,18			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,27			;linha 0-29
    mov     	dl,10			;coluna 0-79
printmsg:
    call	cursor
    mov     al,[bx+campo_mensagem]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    printmsg
; zone 11 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,2			;linha 0-29
    mov     	dl,8			;coluna 0-79
print11:
    call	cursor
    mov     al,[bx+campo_11]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print11
; zone 12 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,2			;linha 0-29
    mov     	dl,30			;coluna 0-79
print12:
    call	cursor
    mov     al,[bx+campo_12]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print12
; zone 13 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,2			;linha 0-29
    mov     	dl,52			;coluna 0-79
print13:
    call	cursor
    mov     al,[bx+campo_13]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print13
; zone 21 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,8			;linha 0-29
    mov     	dl,8			;coluna 0-79
print21:
    call	cursor
    mov     al,[bx+campo_21]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print21
; zone 22 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,8			;linha 0-29
    mov     	dl,30			;coluna 0-79
print22:
    call	cursor
    mov     al,[bx+campo_22]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print22
; zone 23 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,8			;linha 0-29
    mov     	dl,52			;coluna 0-79
print23:
    call	cursor
    mov     al,[bx+campo_23]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print23
; zone 31 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,14			;linha 0-29
    mov     	dl,8			;coluna 0-79
print31:
    call	cursor
    mov     al,[bx+campo_31]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print31
; zone 22 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,14			;linha 0-29
    mov     	dl,30			;coluna 0-79
print32:
    call	cursor
    mov     al,[bx+campo_32]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print32
; zone 33 string
    mov     	cx,2			;n�mero de caracteres
    mov     	bx,0
    mov     	dh,14			;linha 0-29
    mov     	dl,52			;coluna 0-79
print33:
    call	cursor
    mov     al,[bx+campo_33]
    call	caracter
    inc     bx			;proximo caracter
    inc		dl			;avanca a coluna
    loop    print33
    ret     0

;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub		dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
    		mov     	ah,9
    		mov     	bh,0
    		mov     	cx,1
   		mov     	bl,[cor]
    		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret

segment data

cor		db		branco_intenso
preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0	
campo_comando    	db  		'Campo de comando'
campo_mensagem    	db  		'Campo de mensagens'
campo_11    	db  		'11'
campo_12    	db  		'12'
campo_13    	db  		'13'
campo_21    	db  		'21'    
campo_22    	db  		'22'
campo_23    	db  		'23'
campo_31    	db  		'31'
campo_32    	db  		'32'
campo_33    	db  		'33'
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:
