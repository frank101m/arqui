; Procesador
.386
; Segmento de Pila
Stack Segment Para Stack Use16 'STACK'
	db 2048 dup(0)
Stack Ends
Code Segment Para Use16 'Code' 
	Assume CS:Code
	Assume DS:Code
Org 0100H
Start:	;Comienzo de Programa
; ------------------------------------------------------------------------------------------------

; inicializar el modo texto
call init_texto
call init_grafico
call init_mem_preguntas
call init_pregunta

; manejo del mouse
mov ax, 0000h
int 33h

jmp pregunta_1

;mov ax, 0000h
;int 16h

fin_programa:
mov ax, 4c00h
int 21h

; ------------------------------------------------------------------------------------------------

;--------------------------------------------------------
; Logica de las preguntas
;--------------------------------------------------------

init_mem_preguntas:
	;Posicion de la pregunta
	mov al,00d
	mov ds:[0220h], al

	;Total de preguntas
	mov al,25d
	mov ds:[0221h], al

	;Valores de las preguntas
	mov al,02d ; Indicador de pregunta sin contestar.
	mov si, 0000h

	;0300h - 0300h + 25d: respuestas del usuario
	; 00h: incorrecto
	; 01h: correcto
	; 02h: sin contestar
	llenar_respuesta:
		mov ds:[0300h + si], al
		inc si
		cmp si, 0025d
		jnz llenar_respuesta

	mov si, 0000h

	; para la visualizacion de la opcion
	llenar_opcion_escogida:
		mov ds:[0350h + si], al
		inc si
		cmp si, 0025d
		jnz llenar_opcion_escogida


	ret

;--------------------------------------------------------
; PREGUNTA 1
;--------------------------------------------------------

btn_opt:
	; leer opcion escogida de la memoria
	mov al, ds:[0350h + si]

	;01h: codigo de boton verdadero
	cmp al, 01h
	je dibujar_btn_verdadero

	;00h: codigo de boton falso
	cmp al, 00h
	je dibujar_btn_falso

	;si no es ninguno, esta sin contestar
	jne dibujar_btn_sin_contestar

dibujar_btn_verdadero:
	call btn_falso
	call btn_verdadero_act
	jmp salir_btn_opt
dibujar_btn_falso:
	call btn_falso_act
	call btn_verdadero
	jmp salir_btn_opt
dibujar_btn_sin_contestar:
	call btn_falso
	call btn_verdadero
salir_btn_opt:
	ret

pregunta_1:
	; Pregunta actual: 01h
	mov al,01h
	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	; copiar pregunta 1 a la memoria
	call cp1
	call init_pregunta
	call texto_pregunta
	call barra_progreso

	; botones activos para la pregunta actual
	call btn_siguiente

mov si, 0000h
	call btn_opt

p1_manejar_clic:
	; esperar un clic izquierdo
	call manejar_clic

	; dejar que el controlador identifique el boton
	call buscar_btn

	; 0275h: codigo de boton  presionado
	mov al,ds:[0275h]
	; 10h: boton de falso
	cmp al,10h
	je p1_btn_falso

	; 11h: boton de verdadero
	cmp al,11h
	je p1_btn_verdadero

	; 13h: boton de siguiente
	cmp al,13h
	je pregunta_2

	; volver a esperar clic
	jmp p1_manejar_clic

p1_btn_verdadero:
	; Evaluar la respuesta
	mov al,01h
	mov ds:[0300h+si], al

	; Escoger la respuesta
	; restaltar botones
	mov al,01h
	mov ds:[0350h+si], al
	call btn_opt

	; volver a esperar clic
	jmp p1_manejar_clic

p1_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al,00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p1_manejar_clic


;--------------------------------------------------------
; PREGUNTA 2
;--------------------------------------------------------

pregunta_2:
	; Pregunta actual: 01h
	mov al,02h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp2
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0001h
	call btn_opt
p2_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p2_btn_falso
	cmp al,11h
	je p2_btn_verdadero
	cmp al,12h
	je pregunta_1
	cmp al,13h
	je pregunta_3
	jmp p2_manejar_clic

p2_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p2_manejar_clic
p2_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p2_manejar_clic
;--------------------------------------------------------
; PREGUNTA 3
;--------------------------------------------------------

pregunta_3:
	mov al,03h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp3
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0002h
	call btn_opt
p3_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p3_btn_falso
	cmp al,11h
	je p3_btn_verdadero
	cmp al,12h
	je pregunta_2
	cmp al,13h
	je pregunta_4
	jmp p3_manejar_clic

p3_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p3_manejar_clic
p3_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p3_manejar_clic

;--------------------------------------------------------
; PREGUNTA 4
;--------------------------------------------------------

pregunta_4:
	mov al,04h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp4
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0003h
	call btn_opt
p4_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p4_btn_falso
	cmp al,11h
	je p4_btn_verdadero
	cmp al,12h
	je pregunta_3
	cmp al,13h
	je pregunta_5
	jmp p4_manejar_clic

p4_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p4_manejar_clic
p4_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p4_manejar_clic

;--------------------------------------------------------
; PREGUNTA 5
;--------------------------------------------------------

pregunta_5:
	mov al,05h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp5
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0004h
	call btn_opt
p5_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p5_btn_falso
	cmp al,11h
	je p5_btn_verdadero
	cmp al,12h
	je pregunta_4
	cmp al,13h
	je pregunta_6
	jmp p5_manejar_clic

p5_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p5_manejar_clic
p5_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p5_manejar_clic

;--------------------------------------------------------
; PREGUNTA 6
;--------------------------------------------------------

pregunta_6:
	mov al,06h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp6
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0005h
	call btn_opt
p6_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p6_btn_falso
	cmp al,11h
	je p6_btn_verdadero
	cmp al,12h
	je pregunta_5
	cmp al,13h
	je pregunta_7
	jmp p6_manejar_clic

p6_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p6_manejar_clic
p6_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p6_manejar_clic

;--------------------------------------------------------
; PREGUNTA 7
;--------------------------------------------------------

pregunta_7:
	mov al,07h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp7
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0006h
	call btn_opt
p7_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p7_btn_falso
	cmp al,11h
	je p7_btn_verdadero
	cmp al,12h
	je pregunta_6
	cmp al,13h
	je pregunta_8
	jmp p7_manejar_clic

p7_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p7_manejar_clic
p7_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p7_manejar_clic

;--------------------------------------------------------
; PREGUNTA 8
;--------------------------------------------------------

pregunta_8:
	mov al,08h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp8
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0007h
	call btn_opt
p8_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p8_btn_falso
	cmp al,11h
	je p8_btn_verdadero
	cmp al,12h
	je pregunta_7
	cmp al,13h
	je pregunta_9
	jmp p8_manejar_clic

p8_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p8_manejar_clic
p8_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p8_manejar_clic


;--------------------------------------------------------
; PREGUNTA 9
;--------------------------------------------------------

pregunta_9:
	mov al,09h

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp9
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0008h
	call btn_opt
p9_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p9_btn_falso
	cmp al,11h
	je p9_btn_verdadero
	cmp al,12h
	je pregunta_8
	cmp al,13h
	je pregunta_10
	jmp p9_manejar_clic

p9_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p9_manejar_clic
p9_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p9_manejar_clic

;--------------------------------------------------------
; PREGUNTA 10
;--------------------------------------------------------

pregunta_10:
	mov al,010d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp10
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0009d
	call btn_opt
p10_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p10_btn_falso
	cmp al,11h
	je p10_btn_verdadero
	cmp al,12h
	je pregunta_9
	cmp al,13h
	je pregunta_11
	jmp p10_manejar_clic

p10_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p10_manejar_clic
p10_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p10_manejar_clic

;--------------------------------------------------------
; PREGUNTA 11
;--------------------------------------------------------

pregunta_11:
	mov al,11d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp11
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0010d
	call btn_opt
p11_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p11_btn_falso
	cmp al,11h
	je p11_btn_verdadero
	cmp al,12h
	je pregunta_10
	cmp al,13h
	je pregunta_12
	jmp p11_manejar_clic

p11_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p11_manejar_clic
p11_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p11_manejar_clic

;--------------------------------------------------------
; PREGUNTA 12
;--------------------------------------------------------

pregunta_12:
	mov al,12d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp12
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0011d
	call btn_opt
p12_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p12_btn_falso
	cmp al,11h
	je p12_btn_verdadero
	cmp al,12h
	je pregunta_11
	cmp al,13h
	je pregunta_13
	jmp p12_manejar_clic

p12_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p12_manejar_clic
p12_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p12_manejar_clic

;--------------------------------------------------------
; PREGUNTA 13
;--------------------------------------------------------

pregunta_13:
	mov al,13d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp13
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0012d
	call btn_opt
p13_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p13_btn_falso
	cmp al,11h
	je p13_btn_verdadero
	cmp al,12h
	je pregunta_12
	cmp al,13h
	je pregunta_14
	jmp p13_manejar_clic

p13_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p13_manejar_clic
p13_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p13_manejar_clic

;--------------------------------------------------------
; PREGUNTA 14
;--------------------------------------------------------

pregunta_14:
	mov al,14d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp14
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0013d
	call btn_opt
p14_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p14_btn_falso
	cmp al,11h
	je p14_btn_verdadero
	cmp al,12h
	je pregunta_13
	cmp al,13h
	je pregunta_15
	jmp p14_manejar_clic

p14_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p14_manejar_clic
p14_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p14_manejar_clic


;--------------------------------------------------------
; PREGUNTA 15
;--------------------------------------------------------

pregunta_15:
	mov al,15d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp15
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0014d
	call btn_opt
p15_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p15_btn_falso
	cmp al,11h
	je p15_btn_verdadero
	cmp al,12h
	je pregunta_14
	cmp al,13h
	je pregunta_16
	jmp p15_manejar_clic

p15_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p15_manejar_clic
p15_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p15_manejar_clic

;--------------------------------------------------------
; PREGUNTA 16
;--------------------------------------------------------

pregunta_16:
	mov al,16d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp16
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0015d
	call btn_opt
p16_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p16_btn_falso
	cmp al,11h
	je p16_btn_verdadero
	cmp al,12h
	je pregunta_15
	cmp al,13h
	je pregunta_17
	jmp p16_manejar_clic

p16_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p16_manejar_clic
p16_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p16_manejar_clic

;--------------------------------------------------------
; PREGUNTA 17
;--------------------------------------------------------

pregunta_17:
	mov al,17d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp17
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0016d
	call btn_opt
p17_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p17_btn_falso
	cmp al,11h
	je p17_btn_verdadero
	cmp al,12h
	je pregunta_16
	cmp al,13h
	je pregunta_18
	jmp p17_manejar_clic

p17_btn_verdadero:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p17_manejar_clic
p17_btn_falso:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p17_manejar_clic

;--------------------------------------------------------
; PREGUNTA 18
;--------------------------------------------------------

pregunta_18:
	mov al,18d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp18
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0017d
	call btn_opt
p18_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p18_btn_falso
	cmp al,11h
	je p18_btn_verdadero
	cmp al,12h
	je pregunta_17
	cmp al,13h
	je pregunta_19
	jmp p18_manejar_clic

p18_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p18_manejar_clic
p18_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p18_manejar_clic

;--------------------------------------------------------
; PREGUNTA 19
;--------------------------------------------------------

pregunta_19:
	mov al,19d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp19
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0018d
	call btn_opt
p19_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p19_btn_falso
	cmp al,11h
	je p19_btn_verdadero
	cmp al,12h
	je pregunta_18
	cmp al,13h
	je pregunta_20
	jmp p19_manejar_clic

p19_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p19_manejar_clic
p19_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p19_manejar_clic

;--------------------------------------------------------
; PREGUNTA 20
;--------------------------------------------------------

pregunta_20:
	mov al,20d

	; A utilizar para la barra de progreso
	mov ds:[0220h], al
	call init_grafico
	call limpiar_reg
	call cp20
	call init_pregunta
	call texto_pregunta
	call barra_progreso
	call btn_anterior
	call btn_siguiente

mov si, 0019d
	call btn_opt
p20_manejar_clic:

	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je p20_btn_falso
	cmp al,11h
	je p20_btn_verdadero
	cmp al,12h
	je pregunta_19
	cmp al,13h
	;je pregunta_21
	je pantalla_fin
	jmp p20_manejar_clic

p20_btn_verdadero:
	mov al,00h
	mov ds:[0300h+si], al
	mov al, 01h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p20_manejar_clic
p20_btn_falso:
	mov al,01h
	mov ds:[0300h+si], al
	mov al, 00h
	mov ds:[0350h+si], al
	call btn_opt
	jmp p20_manejar_clic
;-----------------------------
;-----------------------------
; 
init_pregunta:
	;Posicionar el cursor
	mov al,00h
	mov ah, 02h
	mov bh, 00h

	;Filas y columnas iniciales para el texto de la pregunta
	mov dh, 01h
	mov dl, 02h
	int 10h

	;Limpiando acumuladores
	mov di, 0000h
	mov si, 0000h
	ret

texto_pregunta:
	; color gris
	mov al,07fh
	call setear_color_texto
	mov dh, 05d
	mov dl, 10d
	mov al, ' '
	call pc

itr_texto_pregunta:
	; Copiar pregunta completa
	mov al,ds:[0500h + di]
	; El simbolo ; es el delimitador.
	cmp al,';'
	je fin_texto_pregunta
	call pc
	inc di
	jmp itr_texto_pregunta
fin_texto_pregunta:
	ret

; DS:[0180H]: columna para el texto
pantalla_fin:
	call limpiar_reg
	call init_grafico
	call limpiar_reg
	mov dh, 02d
	mov di, 0000d

	;Espaciamiento inicial
	mov al,06d
	mov ds:[0180h], al
	mov dl, ds:[0180h]

	mov al,0ffh
	call setear_color_texto
	poner_resultado_pregunta:
		mov al,ds:[0300h + di]
		call color_codig_preg
		;Espaciamiento horizontal
		mov al,' '
		call pc

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
		;solo si llegamos a la decima
		inc di
		mov ax, di
		mov bl, 10d
		div bl

		; multiplo de 10
		cmp ah, 00h
		jnz continuar_itr_res

		; agregar espaciamiento
		add dl, 25d

		; actualizar espaciamiento en memori
		mov ds:[0180h], dl
		mov dh, 02d
	continuar_itr_res:
		cmp di, 0025d
		jnz poner_resultado_pregunta

	;etiquetas indicadoras
	call fin_etiquetas

	;calcular puntaje final
	call calificacion_final

	;TODO: boton de salida
	;ignorar por el momento
pantalla_fin_manejar_clic:
	call manejar_clic
	call buscar_btn

	mov al,ds:[0275h]
	cmp al,10h
	je pantalla_fin_btn_salir
	cmp al,11h
	je pantalla_fin_btn_salir
	jmp pantalla_fin_manejar_clic

pantalla_fin_btn_salir:
	jmp fin_programa


; ---------------
; Calcular calificacion final
; ---------------

calificacion_final:
	mov si, 0000h
	mov al,00d
	mov ds:[0190h], al
itr_calificacion_final:
	mov al,ds:[0300h + si]
	cmp al,01h
	jnz continuar_itr_calificacion_final
	mov al,ds:[0190h]
	inc al
	mov ds:[0190h], al
continuar_itr_calificacion_final:
	inc si
	cmp si, 25d
	jnz itr_calificacion_final

	;Texto inicial
	mov dh, 25d
	mov dl, 40d

	;agregar un espacio
	mov al,' '
	call pc
	call palabra_calificacion

	; tanto
	; regla de 3
	mov bh, 04d
	mov al,ds:[0190h]
	mul bh
	mov ds:[0190h], al
	call num_a_texto

	mov al,'/'
	call pc

	; de 100
	mov al,100d
	mov ds:[0190h], al
	call num_a_texto

	ret

;-----------------------------------------------------------------------------------
; Colocar las etiquetas de colores para cada tipo de respuesta
;-----------------------------------------------------------------------------------
fin_etiquetas:

	; para el cuadro verde de respuesta correcta
	mov al,0fh
	call setear_color_texto

	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 0368d
	mov ds:[0244h], ax
	mov ax, 0383d
	mov ds:[0246h], ax

	mov al,02h
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 23d
	mov dl, 05d
	mov al,' '
	call pc

	call palabra_correcta

	; para el cuadro rojo de respuesta incorrecta
	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 00400d
	mov ds:[0244h], ax
	mov ax, 00415d
	mov ds:[0246h], ax

	mov al,04h
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 25d
	mov dl, 05d
	mov al,' '
	call pc

	call palabra_fallida

	; para el cuadro amarillo de sin contestar
	mov ax, 0010d
	mov ds:[0240h], ax
	mov ax, 0040d
	mov ds:[0242h], ax
	mov ax, 00431d
	mov ds:[0244h], ax
	mov ax, 00446d
	mov ds:[0246h], ax

	mov al,0eh
	call setear_color_pixel
	call dibujar_rectangulo

	mov dh, 27d
	mov dl, 05d
	mov al,' '
	call pc

	call palabra_sin_contestar

	ret

; asignar color al texto segun se contesto la pregunta
color_codig_preg:
	cmp al,00h
	je color_rojo
	cmp al,01h
	je color_verde
	cmp al,02h
	je color_amarillo
	ret

color_rojo:
	mov al,0f4h
	call setear_color_texto
	ret
color_verde:
	mov al,0f2h
	call setear_color_texto
	ret
color_amarillo:
	mov al,0feh
	call setear_color_texto
	ret

;--------------------------------------------------------
; Controlador de botones
;--------------------------------------------------------

; iteracion que esperar clic derecho
manejar_clic:
	mov al,00h
	mov ds:[0275h], al
	mov ax, 0005h
	mov bx, 0000h	; clic izquierdo
	int 33h 		; interrupcion de manejo de mouse

	cmp bx, 0001h
	jne manejar_clic
	ret

; llamar a los botones posibles
buscar_btn:
	call verificar_btn_siguiente
	call verificar_btn_anterior
	call verificar_btn_verdadero
	call verificar_btn_falso
	ret

verificar_btn_siguiente:
	;580 - 640 en x
	;240 - 270 en y
	cmp cx, 0580d
	jb salir_verificar_btn_verdadero
	cmp cx, 0640d
	ja salir_verificar_btn_verdadero
	cmp dx, 0240d
	jb salir_verificar_btn_verdadero
	cmp dx, 0270d
	ja salir_verificar_btn_verdadero
	mov al,13h
	mov ds:[0275h], al
	ret

verificar_btn_anterior:
	;000 - 060 en x
	;240 - 270 en y
	cmp cx, 0000d
	jb salir_verificar_btn_verdadero
	cmp cx, 060d
	ja salir_verificar_btn_verdadero
	cmp dx, 0240d
	jb salir_verificar_btn_verdadero
	cmp dx, 0270d
	ja salir_verificar_btn_verdadero
	mov al,12h
	mov ds:[0275h], al
	ret

verificar_btn_verdadero:
	;310 - 405 en x
	;405 - 435 en y
	cmp cx, 0310d
	jb salir_verificar_btn_verdadero
	cmp cx, 0405d
	ja salir_verificar_btn_verdadero
	cmp dx, 0405d
	jb salir_verificar_btn_verdadero
	cmp dx, 0435d
	ja salir_verificar_btn_verdadero
	mov al,11h
	mov ds:[0275h], al
salir_verificar_btn_verdadero:
	ret

verificar_btn_falso:
	;430 - 525 en x
	;405 - 435 en y
	cmp cx, 0430d
	jb salir_verificar_btn_falso
	cmp cx, 0525d
	ja salir_verificar_btn_falso
	cmp dx, 0405d
	jb salir_verificar_btn_falso
	cmp dx, 0435d 
	ja salir_verificar_btn_falso
	mov al,10h
	mov ds:[0275h], al
salir_verificar_btn_falso:
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
	; modo grafico 640x480
	mov ah, 00h
	mov al,12h
	int 10h

	; mostrar el puntero
	mov ax, 0001h
	int 33h

	ret

; DS:[0210h], color del pixel en 8 bits
poner_pixel:
	mov ah, 0ch
	mov al,ds:[0210h]
	mov bh, 00h
	int 10h
	ret


; DS:[0205h], color del texto en 8 bits
setear_color_texto:
	mov ds:[0205h], al
	ret

; DS:[0210h], color del pixel en 8 bits
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

	mov al,0bh
	call setear_color_pixel
	call dibujar_rectangulo

	;Porcentaje restante
	mov cx, ds:[0242h] ; donde termino el primer rectangulo.
	mov ds:[0240h], cx
	mov cx, 0640d ; fin de la pantalla
	mov ds:[0242h], cx

	mov al,03h
	call setear_color_pixel
	call dibujar_rectangulo

	ret

; inicializar modo texto
init_texto:
	mov ah, 00h
	mov al,03h
	int 10h
	ret

; DS:[0190h] ; digito original
; DS:[0195h] ; 1er digito
; DS:[0196h] ; 2do digito
; DS:[0197h] ; 3er digito

num_a_texto:
	mov al,00h

	; limpiar celdas de memoria
	mov ds:[0195h], al
	mov ds:[0196h], al
	mov ds:[0197h], al

	; dato a imprimir
	mov al,ds:[0190h]
	mov si, 0003h
sacar_digito:
	; formato decimal
	mov bh, 10d
	mov ah, 00h
	div bh
	mov bl, ah
	add bl, 30h
	; llenar desde atras hacia adelante
	mov ds:[0195h+si], bl
	dec si
	; ya no se puede descomponer el numero
	cmp al,00h
	je mostrar_digitos
	cmp si, 0000h
	jnz sacar_digito
mostrar_digitos:
	; llenar desde adelante hacia atras
	mov al,ds:[0195h+si]
	inc si
	call pc
	cmp si, 0004h
	jnz mostrar_digitos
	ret

; colocar caracter en pantalla
pc:
	mov ah, 09h
	mov bh, 00h
	
	;leer el color previamente asignado
	mov bl, ds:[0205h]
	mov cx, 0001h
	int 10h
	call avanzar
	ret

avanzar:
	mov al,00h
	mov ah, 02h
	mov bh, 00h
	;Pasar a la siguiente fila
	cmp dl, 70d
	jne fin_avanzar
	mov dl, 10d
	inc dh
fin_avanzar:
	inc dl
	int 10h
	ret

;------------------------------
; Logica de los botones y graficos
;------------------------------

;---- Boton de Siguiente ----


; dibujar boton siguiente
btn_siguiente:
	mov al,03h
	call setear_color_pixel

	; ver subrutina de dibujar_rectangulo
	mov ax, 0580d
	mov ds:[0240h], ax
	mov ax, 0640d
	mov ds:[0242h], ax
	mov ax, 0240d
	mov ds:[0244h], ax
	mov ax, 0270d
	mov ds:[0246h], ax

	call dibujar_rectangulo
	ret
btn_anterior:
	mov al,03h
	call setear_color_pixel
	mov ax, 0000d
	mov ds:[0240h], ax
	mov ax, 0060d
	mov ds:[0242h], ax
	mov ax, 0240d
	mov ds:[0244h], ax
	mov ax, 0270d
	mov ds:[0246h], ax

	call dibujar_rectangulo
	ret

;para el boton de falso
blanco:
	mov cx, 425d ;columna
	mov dx, 405d  ;fila

sigo:
	call poner_pixel
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
	call poner_pixel
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
	call linea_arriba
	call linea_vertical2
	call linea_arriba2

	call btn_verdadero
	call btn_falso
	ret

; botones seleccionados
btn_falso_act:
	; fondo blanco
	mov al,1111b
	call setear_color_pixel
	call blanco
	call letras2
	ret

btn_verdadero_act:
	mov al,1111b
	call setear_color_pixel
	call blancof
	call letras
	ret


; botones sin seleccionar
btn_falso:
	; fnodo gris
	mov al,0111b
	call setear_color_pixel
	call blanco
	call letras2
	ret

btn_verdadero:
	mov al,0111b
	call setear_color_pixel
	call blancof
	call letras
	ret

;este es para las lineas del efecto 3d
pixel3: 
	mov ah, 0ch
mov al,1111b ;color blanco
mov bh, 00 ;la pagina en la que estoy trabajando
int 10h
ret

letras:                 
	;posicion inicial del cursor
	mov dh, 77d
	mov dl, 55d
	call mover
	mov al,"v"
	call caracter
	call mover

	mov al,"e"
	call caracter
	call mover

	mov al,"r"
	call caracter
	call mover 

	mov al,"d"
	call caracter
	call mover

	mov al,"a"
	call caracter
	call mover

	mov al,"d"
	call caracter
	call mover

	mov al,"e"
	call caracter
	call mover

	mov al,"r"
	call caracter
	call mover

	mov al,"o"
	call caracter
	call mover
	ret
            
letras2:                 
	;posicion inicial del cursor
	mov dh, 77d
	mov dl, 72d
	call mover
	mov al,"f"
	call caracter
	call mover

	mov al,"a"
	call caracter
	call mover

	mov al,"l"
	call caracter
	call mover 

	mov al,"s"
	call caracter
	call mover

	mov al,"o"
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

gc:
	mov ds:[0500h + di], al
	inc di
	ret

palabra_calificacion:
    mov al,'C'
    call pc
    mov al,'a'
    call pc
    mov al,'l'
    call pc
    mov al,'i'
    call pc
    mov al,'f'
    call pc
    mov al,'i'
    call pc
    mov al,'c'
    call pc
    mov al,'a'
    call pc
    mov al,'c'
    call pc
    mov al,'i'
    call pc
    mov al,'o'
    call pc
    mov al,'n'
    call pc
    mov al,':'
    call pc
    mov al,' '
    call pc
    ret

palabra_correcta:
	mov al,'C'
	call pc
	mov al,'o'
	call pc
	mov al,'r'
	call pc
	mov al,'r'
	call pc
	mov al,'e'
	call pc
	mov al,'c'
	call pc
	mov al,'t'
	call pc
	mov al,'a'
	call pc
	ret
palabra_fallida:
    mov al,'F'
    call pc
    mov al,'a'
    call pc
    mov al,'l'
    call pc
    mov al,'l'
    call pc
    mov al,'i'
    call pc
    mov al,'d'
    call pc
    mov al,'a'
    call pc
    ret
palabra_sin_contestar:
    mov al,'S'
    call pc
    mov al,'i'
    call pc
    mov al,'n'
    call pc
    mov al,' '
    call pc
    mov al,'c'
    call pc
    mov al,'o'
    call pc
    mov al,'n'
    call pc
    mov al,'t'
    call pc
    mov al,'e'
    call pc
    mov al,'s'
    call pc
    mov al,'t'
    call pc
    mov al,'a'
    call pc
    mov al,'r'
    call pc
    ret
palabra_pregunta:
	mov al,'P'
	call pc
	mov al,'r'
	call pc
	mov al,'e'
	call pc
	mov al,'g'
	call pc
	mov al,'u'
	call pc
	mov al,'n'
	call pc
	mov al,'t'
	call pc
	mov al,'a'
	call pc
	mov al,' '
	call pc
	ret

cp1:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'0'
call gc
mov al,'2'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'I'
call gc
mov al,'N'
call gc
mov al,'T'
call gc
mov al,' '
call gc
mov al,'1'
call gc
mov al,'0'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'L'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp2:
mov al,'R'
call gc
mov al,'O'
call gc
mov al,'M'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'I'
call gc
mov al,'O'
call gc
mov al,'S'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'f'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,' '
call gc
mov al,'P'
call gc
mov al,'C'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp3:
mov al,'U'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'f'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,'b'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'b'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'v'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp4:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'b'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'b'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'I'
call gc
mov al,'S'
call gc
mov al,'R'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'2'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'y'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'g'
call gc
mov al,'u'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'x'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'2'
call gc
mov al,'5'
call gc
mov al,'6'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,';'
call gc

	ret
cp5:
mov al,'E'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,'b'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'v'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'h'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'d'
call gc
mov al,'w'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'g'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'8'
call gc
mov al,'0'
call gc
mov al,'5'
call gc
mov al,'9'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'j'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'l'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'v'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'A'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'h'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'v'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,';'
call gc

	ret
cp6:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'0'
call gc
mov al,'D'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,' '
call gc
mov al,'1'
call gc
mov al,'0'
call gc
mov al,'H'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'x'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'0'
call gc
mov al,'C'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'v'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'u'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'f'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,':'
call gc
mov al,' '
call gc
mov al,'E'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'L'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'x'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'C'
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'x'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'x'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,';'
call gc

	ret
cp7:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'j'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'b'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,':'
call gc
mov al,' '
call gc
mov al,'P'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'R'
call gc
mov al,'e'
call gc
mov al,'d'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'o'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'P'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'g'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'z'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'F'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'A'
call gc
mov al,'y'
call gc
mov al,'u'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp8:
mov al,'E'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'R'
call gc
mov al,'O'
call gc
mov al,'M'
call gc
mov al,' '
call gc
mov al,'g'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'h'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'g'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'o'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp9:
mov al,'L'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'0'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'1'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'2'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'3'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'8'
call gc
mov al,'0'
call gc
mov al,'8'
call gc
mov al,'6'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'b'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp10:
mov al,'I'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'p'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'R'
call gc
mov al,'E'
call gc
mov al,'S'
call gc
mov al,'E'
call gc
mov al,'T'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'g'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'z'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,'b'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'F'
call gc
mov al,'0'
call gc
mov al,'0'
call gc
mov al,'0'
call gc
mov al,'0'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'I'
call gc
mov al,'N'
call gc
mov al,'T'
call gc
mov al,'E'
call gc
mov al,'L'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp11:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'0'
call gc
mov al,'6'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,' '
call gc
mov al,'1'
call gc
mov al,'0'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'h'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'j'
call gc
mov al,'o'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'b'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'A'
call gc
mov al,'L'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'v'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'H'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'b'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'C'
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'l'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp12:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'x'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'R'
call gc
mov al,'A'
call gc
mov al,'M'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'f'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'A'
call gc
mov al,'S'
call gc
mov al,'C'
call gc
mov al,'I'
call gc
mov al,'I'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'b'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp13:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'h'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'u'
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'z'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'R'
call gc
mov al,'A'
call gc
mov al,'M'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp14:
mov al,'E'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'8'
call gc
mov al,'0'
call gc
mov al,'8'
call gc
mov al,'6'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'u'
call gc
mov al,'b'
call gc
mov al,'u'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'('
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,')'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'E'
call gc
mov al,'U'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'I'
call gc
mov al,'U'
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'g'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'f'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp15:
mov al,'E'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'k'
call gc
mov al,' '
call gc
mov al,'S'
call gc
mov al,'S'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'k'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'j'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'j'
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'S'
call gc
mov al,'P'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'p'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'z'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'u'
call gc
mov al,'g'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'x'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp16:
mov al,'E'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'v'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'/'
call gc
mov al,'w'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp17:
mov al,'E'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'8'
call gc
mov al,'0'
call gc
mov al,'8'
call gc
mov al,'5'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'n'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'1'
call gc
mov al,'6'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'j'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp18:
mov al,'E'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'E'
call gc
mov al,'N'
call gc
mov al,'I'
call gc
mov al,'A'
call gc
mov al,'C'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'v'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'n'
call gc
mov al,'e'
call gc
mov al,'w'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'s'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'p'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'g'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'y'
call gc
mov al,' '
call gc
mov al,'p'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'i'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'t'
call gc
mov al,'u'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'u'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,'r'
call gc
mov al,'n'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp19:
mov al,'E'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'m'
call gc
mov al,'i'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'l'
call gc
mov al,'o'
call gc
mov al,'c'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'d'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'m'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'m'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'y'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'e'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'t'
call gc
mov al,'e'
call gc
mov al,'n'
call gc
mov al,'i'
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'e'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'S'
call gc
mov al,'I'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'D'
call gc
mov al,'I'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'r'
call gc
mov al,'e'
call gc
mov al,'g'
call gc
mov al,'i'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'o'
call gc
mov al,'s'
call gc
mov al,' '
call gc
mov al,'b'
call gc
mov al,'a'
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'B'
call gc
mov al,'P'
call gc
mov al,'.'
call gc
mov al,';'
call gc

	ret
cp20:
mov al,'L'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,' '
call gc
mov al,'J'
call gc
mov al,'A'
call gc
mov al,'E'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'d'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'a'
call gc
mov al,'l'
call gc
mov al,'t'
call gc
mov al,'o'
call gc
mov al,' '
call gc
mov al,'h'
call gc
mov al,'a'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'i'
call gc
mov al,'n'
call gc
mov al,'s'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'u'
call gc
mov al,'c'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'i'
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'u'
call gc
mov al,'m'
call gc
mov al,'p'
call gc
mov al,'l'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'q'
call gc
mov al,'u'
call gc
mov al,'e'
call gc
mov al,' '
call gc
mov al,'u'
call gc
mov al,'n'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'Y'
call gc
mov al,','
call gc
mov al,' '
call gc
mov al,'s'
call gc
mov al,'e'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'m'
call gc
mov al,'a'
call gc
mov al,'y'
call gc
mov al,'o'
call gc
mov al,'r'
call gc
mov al,' '
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'o'
call gc
mov al,'t'
call gc
mov al,'r'
call gc
mov al,'a'
call gc
mov al,' '
call gc
mov al,'c'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,'d'
call gc
mov al,'i'
call gc
mov al,'c'
call gc
mov al,'i'
call gc
mov al,'o'
call gc
mov al,'n'
call gc
mov al,' '
call gc
mov al,'X'
call gc
mov al,' '
call gc
mov al,' '
call gc
mov al,'"'
call gc
mov al,'Y'
call gc
mov al,' '
call gc
mov al,'>'
call gc
mov al,' '
call gc
mov al,'X'
call gc
mov al,'"'
call gc
mov al,'.'
call gc
mov al,' '
call gc
mov al,';'
call gc

ret

Code Ends
End Start