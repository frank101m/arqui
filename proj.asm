; ---------------------------------------<Directivas>---------------------------------------
; Procesado
.386
; Segmento de Pila
Stack Segment Para Stack Use16 'STACK'
	db 1024 dup(0)
Stack Ends
; Segmento de Código
Code Segment Para Use16 'Code' 
	Assume CS:Code
	Assume DS:Code
;Dirección de Inicio:
Org 0100H
Start:	;Comienzo de Programa
; ------------------------------------------------------------------------------------------------

; inicializar el modo texto
call init_texto
call init_grafico
call init_mem_preguntas
call init_pregunta
call pregunta_1

mov ax, 0000h
int 16h

mov ax, 4c00h
int 21h
; ------------------------------------------------------------------------------------------------

;--------------------------------------------------------
; Logica de las preguntas
;--------------------------------------------------------

init_mem_preguntas:
	;Preguntas contestadas
	mov al, 01d
	mov ds:[0220h], al

	;Preguntas por contestar
	mov al, 25d
	mov ds:[0221h], al

	;Valores de las preguntas
	mov al, 02d ; Indicador de pregunta sin contestar.
	mov si, 0000h

	llenar_contestadas:
		mov ds:[0300h + si], al
		inc si
		cmp si, 0025d
		jnz llenar_contestadas

	mov al, 01h
	mov ds:[0302h], al

	mov al, 01h
	mov ds:[0315h], al

	mov al, 00h
	mov ds:[0310h], al

	mov al, 00h
	mov ds:[0311h], al


	ret

pregunta_1:
	call barra_progreso
	call copiar_pregunta1
	call init_pregunta
	;call init_interface
	;call texto_pregunta
	call fin_texto_pregunta
	;call iconos
	;call icono_siguiente
	;call icono_anterior
	ret

init_pregunta:
	;Posicionar el cursor
	mov al, 00h
	mov ah, 02h
	mov bh, 00h

	;Filas y columnas iniciales para el texto de la pregunta
	mov dh, 01h
	mov dl, 02h

	;Limpiando acumuladores
	mov di, 0000h
	mov si, 0000h
	int 10h
	ret

texto_pregunta:
	mov al, 07fh
	call setear_color_texto
	; Copiar pregunta completa
	mov al, ds:[0500h + di]
	; El simbolo ; es el delimitador.
	cmp al, ';'
	je fin_texto_pregunta
	call poner_char
	inc di
	jmp texto_pregunta

; DS:[0180H]: columna para el texto
fin_texto_pregunta:
	call limpiar_reg
	mov dh, 02d
	mov di, 0000d

	;Espaciamiento inicial
	mov al, 06d
	mov ds:[0180h], al
	mov dl, ds:[0180h]

	mov al, 0ffh
	call setear_color_texto
	poner_resultado_pregunta:
		mov al, ds:[0300h + di]
		call color_codig_preg
		;Espaciamiento horizontal
		mov al, ' '
		call poner_char

		call palabra_pregunta

		;Numero de la pregunta
		mov ax, di
		inc ax

		mov ds:[0190h], al
		call num_a_texto

		;Espaciamiento horizontal
		mov dl, ds:[0180h]
		add dh, 02d

		;Pasar a la siguiente columna
		inc di
		mov ax, di
		mov bl, 10d
		div bl
		cmp ah, 00h
		jnz continuar_itr_res
		add dl, 25d
		mov ds:[0180h], dl
		mov dh, 02d
	continuar_itr_res:
		cmp di, 0025d
		jnz poner_resultado_pregunta

	call fin_etiquetas
	call calificacion_final
	ret

calificacion_final:
	mov si, 0000h
	mov al, 00d
	mov ds:[0190h], al
itr_calificacion_final:
	mov al, ds:[0300h + si]
	cmp al, 01h
	jnz continuar_itr_calificacion_final
	mov al, ds:[0190h]
	inc al
	mov ds:[0190h], al
continuar_itr_calificacion_final:
	inc si
	cmp si, 25d
	jnz itr_calificacion_final

	;Texto inicial
	mov dh, 25d
	mov dl, 40d

	mov al, ' '
	call poner_char
	call palabra_calificacion

	mov bh, 04d
	mov al, ds:[0190h]
	mul bh
	mov ds:[0190h], al
	call num_a_texto

	mov al, '/'
	call poner_char

	mov al, 100d
	mov ds:[0190h], al
	call num_a_texto

	ret
fin_etiquetas:
	mov al, 0fh
	call setear_color_texto

	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 0368d
	mov ds:[0244h], ax
	mov ax, 0383d
	mov ds:[0246h], ax

	mov al, 02h
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 23d
	mov dl, 05d
	mov al, ' '
	call poner_char

	call palabra_correcta

	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 00400d
	mov ds:[0244h], ax
	mov ax, 00415d
	mov ds:[0246h], ax

	mov al, 04h
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 25d
	mov dl, 05d
	mov al, ' '
	call poner_char

	call palabra_fallida

	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 00431d
	mov ds:[0244h], ax
	mov ax, 00446d
	mov ds:[0246h], ax

	mov al, 0eh
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 27d
	mov dl, 05d
	mov al, ' '
	call poner_char

	call palabra_sin_contestar

	ret

color_codig_preg:
	cmp al, 00h
	je color_rojo
	cmp al, 01h
	je color_verde
	cmp al, 02h
	je color_amarillo
	ret

color_rojo:
	mov al, 0f4h
	call setear_color_texto
	ret
color_verde:
	mov al, 0f2h
	call setear_color_texto
	ret
color_amarillo:
	mov al, 0feh
	call setear_color_texto
	ret
;--------------------------------------------------------
; Configuracion de los distintos modos de texto y video.
;--------------------------------------------------------

limpiar_reg:
	mov ax, 0000h
	mov bx, 0000h
	mov cx, 0000h
	mov dx, 0000h
	mov bp, 0000h
	mov si, 0000h
	mov di, 0000h
	ret

init_grafico:
	mov ah, 00h
	mov al, 12h
	int 10h
	ret

poner_pixel:
	mov ah, 0ch
	mov al, ds:[0210h]
	mov bh, 00h
	int 10h
	ret

setear_color_texto:
	mov ds:[0205h], al
	ret

setear_color_pixel:
	mov ds:[0210h], al
	ret

; en DS:[0240] debe estar el inicio en x
; en DS:[0242] debe estar el fin en x
; en DS:[0244] debe estar el inicio en y
; en DS:[0246] debe estar el fin en y
dibujar_rectangulo:
	mov cx, ds:[0240h]
	mov si, ds:[0242h]
	mov dx, ds:[0244h]
	mov di, ds:[0246h]

dibujar_rectangulo_y:
	cmp dx, di
	je fin_dibujar_rectangulo
	mov cx, ds:[0240h]
	dibujar_rectangulo_x:
		cmp cx, si
		je fin_dibujar_rectangulo_x
		call poner_pixel
		inc cx
		jmp dibujar_rectangulo_x
fin_dibujar_rectangulo_x:
	inc dx
	jmp dibujar_rectangulo_y
fin_dibujar_rectangulo:
	ret

; DS:[0220h] preguntas contestadas
; DS:[0221h] preguntas totales
barra_progreso:
	;Primer rectangulo
	mov cx, 0000d
	mov ds:[0240h], cx

	;En y
	mov cx, 00000d
	mov ds:[0244h], cx
	mov cx, 0010d
	mov ds:[0246h], cx

	;Porcentaje actual
	;Regla de 3
	mov ax, 0640d
	mov bl, ds:[0221h]
	div bl
	mov bl, ds:[0220h]
	mul bl
	mov ds:[0242h], ax

	mov al, 0bh
	call setear_color_pixel
	call dibujar_rectangulo

	;Porcentaje restante
	mov cx, ds:[0242h] ; donde termino el primer rectangulo.
	mov ds:[0240h], cx
	mov cx, 0640d ; fin de la pantalla
	mov ds:[0242h], cx

	mov al, 03h
	call setear_color_pixel
	call dibujar_rectangulo

	ret

init_texto:
	mov ah, 00h
	mov al, 03h
	int 10h
	ret

; DS:[0190h] ; digito original
; DS:[0195h] ; 1er digito
; DS:[0196h] ; 2do digito
; DS:[0197h] ; 3er digito

num_a_texto:
	mov al, 00h

	mov ds:[0195h], al
	mov ds:[0196h], al
	mov ds:[0197h], al

	mov al, ds:[0190h]
	mov si, 0003h
sacar_digito:
	mov bh, 10d
	mov ah, 00h
	div bh
	mov bl, ah
	add bl, 30h
	mov ds:[0195h+si], bl
	dec si
	cmp al, 00h
	je mostrar_digitos
	cmp si, 0000h
	jnz sacar_digito
mostrar_digitos:
	mov al, ds:[0195h+si]
	inc si
	call poner_char
	cmp si, 0004h
	jnz mostrar_digitos
	ret

poner_char:
	mov ah, 09h
	mov bh, 00h
	mov bl, ds:[0205h]
	mov cx, 0001h
	int 10h
	call avanzar
	ret

avanzar:
	mov al, 00h
	mov ah, 02h
	mov bh, 00h
	;Pasar a la siguiente fila
	cmp dl, 78d
	jne fin_avanzar
	mov dl, 02d
	inc dh
fin_avanzar:
	inc dl
	int 10h
	ret

;------------------------------
; Logica de los botones y graficos
;------------------------------

;para el boton de falso
blanco:
	mov cx, 425d ;columna
	mov dx, 405d  ;fila

sigo:
	call pixel
	inc cx
	cmp cx, 525d
	jne sigo

	mov cx,425d
	inc dx
	cmp dx,435d
	jne sigo
	ret

;para el boton de verdadero
blancof:
	mov cx, 310d
	mov dx, 405d

sigo2:
	call pixel2
	inc cx
	cmp cx, 405d
	jne sigo2

	mov cx,310d
	inc dx
	cmp dx,435d
	jne sigo2
	ret

;para la linea 3d del boton verdadero
linea_arriba:
	mov cx, 310d ;columna
	mov dx, 404d ;fila                        

;para la linea 3d del boton deverdadero
sigo3:
	call pixel3
	inc cx 
	cmp cx, 405d 
	jne sigo3   
	ret

linea_arriba2:
	mov cx, 425d ;columna
	mov dx, 404d ;fila

sigo4:
	call pixel3
	inc cx ;para que avance mi pixel
	cmp cx, 525d ;hasta aqui llegara mi pixel
	jne sigo4 ;si no he llegado sigo!            
	ret

;para la linea vertical 3d del boton falso
linea_vertical2:
	mov cx, 429d ;columna
	mov dx, 404d ;fila
                        
sigo5: call pixel3 ;pixel blanco
	inc dx 
	cmp dx, 435d 
	jne sigo5
ret

;para la linea vertical 3d del boton verdadero
linea_vertical:
            mov cx, 309d ;columna
            mov dx, 404d ;fila
                        
sigo6: call pixel3 ;el pixel blanco
            inc dx 
            cmp dx, 435d 
            jne sigo6
ret

init_interface:
call linea_vertical
call linea_vertical2
call linea_arriba
call linea_arriba2
call blanco
call blancof
call letras
call letras2
ret

pixel:
mov ah,0ch
mov bl ,00h
mov al,0111b
mov bh,00h
int 10h
ret

pixel2:
mov ah,0ch
mov bl ,00h
mov al,0111b
mov bh,00h
int 10h
ret

;este es para las lineas del efecto 3d
pixel3: 
	mov ah, 0ch
mov al, 1111b ;color blanco
mov bh, 00 ;la pagina en la que estoy trabajando
int 10h
ret

letras:                 
	;posicion inicial del cursor
	mov dh, 77d
	mov dl, 55d
	call mover
	mov al, "v"
	call caracter
	call mover

	mov al, "e"
	call caracter
	call mover

	mov al, "r"
	call caracter
	call mover 

	mov al, "d"
	call caracter
	call mover

	mov al, "a"
	call caracter
	call mover

	mov al, "d"
	call caracter
	call mover

	mov al, "e"
	call caracter
	call mover

	mov al, "r"
	call caracter
	call mover

	mov al, "o"
	call caracter
	call mover
	ret
            
letras2:                 
	;posicion inicial del cursor
	mov dh, 77d
	mov dl, 72d
	call mover
	mov al, "f"
	call caracter
	call mover

	mov al, "a"
	call caracter
	call mover

	mov al, "l"
	call caracter
	call mover 

	mov al, "s"
	call caracter
	call mover

	mov al, "o"
	call caracter
	call mover
	ret

caracter:
	mov ah, 09h
	mov bh, 00h
	mov bl, 0f7h
	mov cx, 0001h
	int 10h
	ret
mover:
	mov ah, 02h
	mov bh, 00h
	inc dl
	int 10h
	ret

;--------------------------------------------------------
; Caracteres que conforman las preguntas.
;--------------------------------------------------------

guardar_char:
	mov ds:[0500h + di], al
	inc di
	ret

palabra_calificacion:
    mov al, 'C'
    call poner_char
    mov al, 'a'
    call poner_char
    mov al, 'l'
    call poner_char
    mov al, 'i'
    call poner_char
    mov al, 'f'
    call poner_char
    mov al, 'i'
    call poner_char
    mov al, 'c'
    call poner_char
    mov al, 'a'
    call poner_char
    mov al, 'c'
    call poner_char
    mov al, 'i'
    call poner_char
    mov al, 'o'
    call poner_char
    mov al, 'n'
    call poner_char
    mov al, ':'
    call poner_char
    mov al, ' '
    call poner_char
    ret

palabra_correcta:
	mov al, 'C'
	call poner_char
	mov al, 'o'
	call poner_char
	mov al, 'r'
	call poner_char
	mov al, 'r'
	call poner_char
	mov al, 'e'
	call poner_char
	mov al, 'c'
	call poner_char
	mov al, 't'
	call poner_char
	mov al, 'a'
	call poner_char
	ret
palabra_fallida:
    mov al, 'F'
    call poner_char
    mov al, 'a'
    call poner_char
    mov al, 'l'
    call poner_char
    mov al, 'l'
    call poner_char
    mov al, 'i'
    call poner_char
    mov al, 'd'
    call poner_char
    mov al, 'a'
    call poner_char
    ret
palabra_sin_contestar:
    mov al, 'S'
    call poner_char
    mov al, 'i'
    call poner_char
    mov al, 'n'
    call poner_char
    mov al, ' '
    call poner_char
    mov al, 'c'
    call poner_char
    mov al, 'o'
    call poner_char
    mov al, 'n'
    call poner_char
    mov al, 't'
    call poner_char
    mov al, 'e'
    call poner_char
    mov al, 's'
    call poner_char
    mov al, 't'
    call poner_char
    mov al, 'a'
    call poner_char
    mov al, 'r'
    call poner_char
    ret
palabra_pregunta:
	mov al, 'P'
	call poner_char
	mov al, 'r'
	call poner_char
	mov al, 'e'
	call poner_char
	mov al, 'g'
	call poner_char
	mov al, 'u'
	call poner_char
	mov al, 'n'
	call poner_char
	mov al, 't'
	call poner_char
	mov al, 'a'
	call poner_char
	mov al, ' '
	call poner_char
	ret

copiar_pregunta1:
	;Comienza la pregunta 1
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '2'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'N'
	call guardar_char
	mov al, 'T'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '1'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'L'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 1

copiar_pregunta2:
	;Comienza la pregunta 2
	mov al, 'R'
	call guardar_char
	mov al, 'O'
	call guardar_char
	mov al, 'M'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'O'
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'P'
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 2

copiar_pregunta3:
	;Comienza la pregunta 3
	mov al, 'U'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 3

copiar_pregunta4:
	;Comienza la pregunta 4
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '2'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '2'
	call guardar_char
	mov al, '5'
	call guardar_char
	mov al, '6'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 4

copiar_pregunta5:
	;Comienza la pregunta 5
	mov al, 'E'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'w'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '5'
	call guardar_char
	mov al, '9'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 5

copiar_pregunta6:
	;Comienza la pregunta 6
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '1'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ':'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'L'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 6

copiar_pregunta7:
	;Comienza la pregunta 7
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ':'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'P'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'P'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'z'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'F'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 7

copiar_pregunta8:
	;Comienza la pregunta 8
	mov al, 'E'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, 'O'
	call guardar_char
	mov al, 'M'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 8

copiar_pregunta9:
	;Comienza la pregunta 9
	mov al, 'L'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, '1'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, '2'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, '3'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '6'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 9

copiar_pregunta10:
	;Comienza la pregunta 10
	mov al, 'I'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'T'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'z'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'F'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'N'
	call guardar_char
	mov al, 'T'
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'L'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 10

copiar_pregunta11:
	;Comienza la pregunta 11
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '6'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '1'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'L'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'H'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 11

copiar_pregunta12:
	;Comienza la pregunta 12
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'M'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 12

copiar_pregunta13:
	;Comienza la pregunta 13
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'z'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'R'
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'M'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 13

copiar_pregunta14:
	;Comienza la pregunta 14
	mov al, 'E'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '6'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '('
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ')'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'U'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'U'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'f'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 14

copiar_pregunta15:
	;Comienza la pregunta 15
	mov al, 'E'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'k'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'k'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'P'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'z'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'x'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 15

copiar_pregunta16:
	;Comienza la pregunta 16
	mov al, 'E'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, '/'
	call guardar_char
	mov al, 'w'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 16

copiar_pregunta17:
	;Comienza la pregunta 17
	mov al, 'E'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '0'
	call guardar_char
	mov al, '8'
	call guardar_char
	mov al, '5'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '1'
	call guardar_char
	mov al, '6'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'j'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 17

copiar_pregunta18:
	;Comienza la pregunta 18
	mov al, 'E'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, 'N'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'C'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'v'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'w'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 18

copiar_pregunta19:
	;Comienza la pregunta 19
	mov al, 'E'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'S'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'D'
	call guardar_char
	mov al, 'I'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'g'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'b'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'B'
	call guardar_char
	mov al, 'P'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 19

copiar_pregunta20:
	;Comienza la pregunta 20
	mov al, 'L'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'J'
	call guardar_char
	mov al, 'A'
	call guardar_char
	mov al, 'E'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'h'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'p'
	call guardar_char
	mov al, 'l'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'q'
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'u'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'Y'
	call guardar_char
	mov al, ','
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 's'
	call guardar_char
	mov al, 'e'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'm'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, 'y'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 't'
	call guardar_char
	mov al, 'r'
	call guardar_char
	mov al, 'a'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, 'd'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'c'
	call guardar_char
	mov al, 'i'
	call guardar_char
	mov al, 'o'
	call guardar_char
	mov al, 'n'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '"'
	call guardar_char
	mov al, 'Y'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, '>'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, 'X'
	call guardar_char
	mov al, '"'
	call guardar_char
	mov al, '.'
	call guardar_char
	mov al, ' '
	call guardar_char
	mov al, ';'
	call guardar_char

	ret
	;Termina la pregunta 20
Code Ends
End Start