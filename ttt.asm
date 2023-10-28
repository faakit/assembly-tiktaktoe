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

; loop principal do jogo
loop_principal:
    call        imprime_tela
	call		entrar_jogada
	call 		ler_jogada
	call 		alterar_jogador
	call        limpar_tela
	jmp			loop_principal

; inicia a sequencia de fechamento do jogo
sair:
	mov  	ah,0   			; set video mode
	mov  	al,[modo_anterior]   	; modo anterior
	int  	10h
	mov     ax,4c00h
	int     21h

; realiza a leitura da jogada armazenada no buffer
ler_jogada:
	push    ax
    push    bx
    push    cx
    push    di

	cmp		byte [buffer], 's'
	je 		sair
	cmp		byte [buffer], 'r'
	jne     fazer_jogada
	; limpa as posições do jogo da velha (opcao de reset)
	mov cx, 9
limpa_status_campos:
	mov di, cx
	sub di, 1
	mov byte[campo_status+di], 0
	loop limpa_status_campos

	pop 	di
	pop 	cx
	pop 	bx
	pop 	ax
	ret
fazer_jogada:	
	mov     al, [buffer+1]
	sub		al, '0'
	sub 	al, 1
	mov		bx, 3
	mul		bx
	movzx   ax, al
	mov     di, ax
	mov	    bl, [buffer+2]
	sub		bl, '0'
	sub 	bl, 1
	movzx   bx, bl
	add		di, bx
	cmp     byte [buffer], 'x'
	je      ler_jogada_x
	mov		byte [campo_status+di], 2
	mov     cx, 3
	mov     di, 0
	jmp     limpa_buffer
ler_jogada_x:
	mov     byte [campo_status+di], 1
	; clean buffer
	mov     cx, 3
	mov     di, 0
limpa_buffer:
	mov byte[buffer+di], ' '
	loop limpa_buffer

	pop 	di
	pop 	cx
	pop 	bx
	pop 	ax
	ret

; altera o jogador atual (usado ao final de cada rodada)
alterar_jogador:
	cmp		byte [jogador_atual], 1
	je 		alterar_jogador_o
	mov		byte [jogador_atual], 1
	ret
alterar_jogador_o:
	mov		byte [jogador_atual], 2
	ret

; funcao que verifica se algum dos jogadores venceu
verifica_vencedores:
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	di

	;verifica se o jogador 1 venceu
	;verificar se o jogador 1 possui campo 11, se sim, checar 12 e 13, ou 21 e 31, ou 22 e 33
	cmp		byte [campo_status], 1
	jne 	verifica_vencedor_do_12_vertical
	cmp		byte [campo_status+1], 1
	jne 	verifica_vencedor_do_13_vertical
	mov		byte [campo_status+2], 1
	jne 	verifica_vencedor_do_11_diagonal
	mov     byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_12_vertical:
	cmp 	byte [campo_status+1], 1
	jne 	verifica_vencedor_do_13_vertical
	cmp 	byte [campo_status+4], 1
	jne 	verifica_vencedor_do_13_vertical
	mov		byte [campo_status+7], 1
	jne 	verifica_vencedor_do_13_vertical
	mov     byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_13_vertical:
	cmp 	byte [campo_status+2], 1
	jne 	verifica_vencedor_do_11_diagonal
	mov		byte [campo_status+5], 1
	jne 	verifica_vencedor_do_11_diagonal
	mov		byte [campo_status+8], 1
	jne 	verifica_vencedor_do_11_diagonal
	mov     byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_11_diagonal:
	cmp 	byte [campo_status], 1
	jne 	verifica_vencedor_do_11_vertical
	cmp 	byte [campo_status+4], 1
	jne 	verifica_vencedor_do_11_vertical
	cmp 	byte [campo_status+8], 1
	jne 	verifica_vencedor_do_11_vertical
	mov     byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_11_vertical:
	cmp 	byte [campo_status], 1
	jne 	verifica_vencedor_do_21_horizontal
	cmp 	byte [campo_status+3], 1
	jne 	verifica_vencedor_do_21_horizontal
	cmp 	byte [campo_status+6], 1
	jne 	verifica_vencedor_do_21_horizontal
	mov 	byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_21_horizontal:
	cmp 	byte [campo_status+3], 1
	jne 	verifica_vencedor_do_31_horizontal
	cmp 	byte [campo_status+4], 1
	jne 	verifica_vencedor_do_31_horizontal
	mov 	byte [campo_status+5], 1
	jne 	verifica_vencedor_do_31_horizontal
	mov 	byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_31_horizontal:
	cmp 	byte [campo_status+6], 1
	jne 	verifica_vencedor_do_31_diagonal
	cmp 	byte [campo_status+7], 1
	jne 	verifica_vencedor_do_31_diagonal
	mov 	byte [campo_status+8], 1
	jne 	verifica_vencedor_do_31_diagonal
	mov 	byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_vencedor_do_31_diagonal:
	cmp 	byte [campo_status+6], 1
	jne     verifica_empate
	cmp 	byte [campo_status+4], 1
	jne     verifica_empate
	cmp 	byte [campo_status+2], 1
	jne     verifica_empate
	mov 	byte [jogador_vencedor], 1
	call 	termina_verifica_vencedores
verifica_empate:
	mov cx, 9
verifica_empate_loop:
	mov di, cx
	sub di, 1
	cmp byte [campo_status+di], 0
	je 	termina_verifica_vencedores
	loop verifica_empate_loop
	mov byte [jogador_vencedor], 3
termina_verifica_vencedores:
	pop		di
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret

; le os comandos do jogador e armazena no buffer
entrar_jogada:
    push    ax
    push    bx
    push    cx
    push    dx
    
    ; ler o primeiro caractere
ler_buffer1:
	mov byte[cor], azul_claro
    mov     dh, 27
    mov     dl, 30
	call cursor
    mov     ah, 7
    int     21h
	cmp		al, 'x'
	je 		continue_buffer1
	cmp		al, 'c'
	je 		continue_buffer1
	cmp		al, 's'
	je 		sair_or_reset
	cmp		al, 'r'
	je 		sair_or_reset
	jmp 	ler_buffer1
sair_or_reset:
	mov     byte[buffer], al
    call    caracter
sair_or_reset_after_print:
	mov     ah, 7
    int     21h
	cmp		al, kb_backspace
	jne 	after_sair_or_reset_backspace
	mov		byte[buffer], ' '
	call	cursor
	call 	caracter
	jmp 	ler_buffer1
after_sair_or_reset_backspace:
	cmp		al, kb_enter
	jne 	sair_or_reset_after_print

	pop     dx
    pop     cx
    pop     bx
    pop     ax
	ret
continue_buffer1:
    mov     byte[buffer], al
    call    caracter
	inc dl
    
    ; ler o segundo caractere
    call cursor
ler_buffer2:
	mov     ah, 7
    int     21h
	cmp		al, kb_backspace
	jne 	after_buffer2_backspace
	sub 	dl, 1
	mov		byte[buffer], ' '
	call	cursor
	call 	caracter
	jmp 	ler_buffer1
after_buffer2_backspace:
	sub     al, '0'          ; convert from ASCII to binary
    cmp     al, 1
    jb      ler_buffer2
    cmp     al, 3
    ja      ler_buffer2
	add 	al, '0'
    mov     byte[buffer+1], al
    call    caracter
    inc dl

    ; ler the third character
	call cursor
ler_buffer3:
    mov     ah, 7
    int     21h
	cmp		al, kb_backspace
	jne 	after_buffer3_backspace
	sub 	dl, 1
	mov		byte[buffer+1], ' '
	call	cursor
	call 	caracter
	jmp 	ler_buffer2
after_buffer3_backspace:
	sub     al, '0'          ; convert from ASCII to binary
    cmp     al, 1
    jb      ler_buffer3
    cmp     al, 3
    ja      ler_buffer3
	add 	al, '0'
    mov     byte[buffer+2], al
    call    caracter
buffer_end:
    mov     ah, 7
    int     21h
	cmp		al, kb_backspace
	jne 	after_buffer_end_backspace
	mov		byte[buffer+2], ' '
	call	cursor
	call 	caracter
	jmp 	ler_buffer3
after_buffer_end_backspace:
	cmp     al, kb_enter
	jne     buffer_end
    
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret


;_____________________________________________________________________________
;    fun��o circle
;	 push xc; push yc; call draw_circle;  (xc+30<639,yc+30<479)
; cor definida na variavel cor
draw_circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+6]    ; resgata xc
	mov		bx,[bp+4]    ; resgata yc
	mov		cx,30
	
	mov 	dx,bx	
	add		dx,cx       ;ponto extremo superior
	push    ax			
	push	dx
	call plot_xy
	
	mov		dx,bx
	sub		dx,cx       ;ponto extremo inferior
	push    ax			
	push	dx
	call plot_xy
	
	mov 	dx,ax	
	add		dx,cx       ;ponto extremo direita
	push    dx			
	push	bx
	call plot_xy
	
	mov		dx,ax
	sub		dx,cx       ;ponto extremo esquerda
	push    dx			
	push	bx
	call plot_xy
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si			;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si			;coloca a ordenada y+yc na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si			;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do s�timo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc+x na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si			;coloca a ordenada yc+y na pilha
	call plot_xy		;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		4

    ; função para desenhar um X
    ;  push x; push y; call draw_cross;
draw_cross:
	push 	bp
	mov	 	bp,sp
	pushf                        
	push 	ax
	push 	bx
	push	cx
	push	dx
	
	mov		cx,[bp+6]    ; resgata x
	mov		dx,[bp+4]    ; resgata y
    
    ; desenha primeira linha da cruz
    mov     ax, cx
    add     ax, 30
    push    ax
    mov     ax, dx
    add     ax, 30
    push    ax
    mov     ax, cx
    sub     ax, 30
    push    ax
    mov     ax, dx
    sub     ax, 30
    push    ax
    call    line
    
    ; desenha segunda linha da cruz
    mov     ax, cx
    add     ax, 30
    push    ax
    mov     ax, dx
    sub     ax, 30
    push    ax
    mov     ax, cx
    sub     ax, 30
    push    ax
    mov     ax, dx
    add     ax, 30
    push    ax
    call    line

	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret     4
limpar_tela:
    mov     	al,12h
   	mov     	ah,0
    int     	10h
    ret

imprime_tela:
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
; if campo_11_status === 1 draw a cross
    cmp byte [campo_status], 1
    mov     bx, 400
    mov     ax, 150
    jne check_11
    push    ax
    push    bx
    call draw_cross
check_11:
		cmp byte [campo_status], 2
		jne jump_11
		push 		ax
		push 		bx
		call draw_circle
jump_11:
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
; if campo_12_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+1], 1
    mov     bx, 400
    mov     ax, 320
    jne check_12
    push    ax
    push    bx
    call draw_cross
check_12:
		cmp byte [campo_status+1], 2
		jne jump_12
		push 		ax
		push 		bx
		call draw_circle
jump_12:
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
; if campo_13_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+2], 1
    mov     bx, 400
    mov     ax, 500
    jne check_13
    push    ax
    push    bx
    call draw_cross
check_13:
		cmp byte [campo_status+2], 2
		jne jump_13
		push 		ax
		push 		bx
		call draw_circle
jump_13:
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
; if campo_21_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+3], 1
    mov     bx, 310
    mov     ax, 150
    jne check_21
    push    ax
    push    bx
    call draw_cross
check_21:
		cmp byte [campo_status+3], 2
		jne jump_21
		push 		ax
		push 		bx
		call draw_circle
jump_21:
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
; if campo_22_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+4], 1
    mov     bx, 310
    mov     ax, 320
    jne check_22
    push    ax
    push    bx
    call draw_cross
check_22:
		cmp byte [campo_status+4], 2
		jne jump_22
		push 		ax
		push 		bx
		call draw_circle
jump_22:
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
; if campo_23_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+5], 1
    mov     bx, 310
    mov     ax, 500
    jne check_23
    push    ax
    push    bx
    call draw_cross
check_23:
		cmp byte [campo_status+5], 2
		jne jump_23
		push 		ax
		push 		bx
		call draw_circle
jump_23:
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
; if campo_31_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+6], 1
    mov     bx, 220
    mov     ax, 150
    jne check_31
    push    ax
    push    bx
    call draw_cross
check_31:
		cmp byte [campo_status+6], 2
		jne jump_31
		push 		ax
		push 		bx
		call draw_circle
jump_31:
; zone 32 string
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
; if campo_32_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+7], 1
    mov     bx, 220
    mov     ax, 320
    jne check_32
    push    ax
    push    bx
    call draw_cross
check_32:
		cmp byte [campo_status+7], 2
		jne jump_32
		push 		ax
		push 		bx
		call draw_circle
jump_32:
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
; if campo_33_status === 1 draw a cross, if === 2, draw a circle
    cmp byte [campo_status+8], 1
    mov     bx, 220
    mov     ax, 500
    jne check_33
    push    ax
    push    bx
    call draw_cross
check_33:
		cmp byte [campo_status+8], 2
		jne jump_33
		push 		ax
		push 		bx
		call draw_circle
jump_33:

    ret     0
; **********************************************************


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
buffer          db          '   '
kb_backspace 			equ		8
kb_enter	 			equ		13
;0 : nada
;1 : X. 
;2 : O
; inicializa matriz 3x3 com 0
campo_status TIMES 9 db 0
; qual jogador está jogando
jogador_atual 		db 1
; 0: ninguém ganhou, jogo rolando
; 1: jogador 1 ganhou
; 2: jogador 2 ganhou
; 3: empate
jogador_vencedor 	db 0
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:
