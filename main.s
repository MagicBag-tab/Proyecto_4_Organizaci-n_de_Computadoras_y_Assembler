/*
**********************************************************************************************
*@file      main.s
*@author    Sarah Estrada
*			Kristel Castillo
*			Yu-Fong Chen
*@date      May, 2025 - June 2025
*@brief     Proyecto 4, Programa contador de 0 a 7 en Assembly al que se le puede
*           aumentar o disminuir la velocidad.
*@details
*			-
**********************************************************************************************
*/

//Valores para habilitar el CLK AHB1 PORT A y PORT B y PORT C
.equ RCC_BASE,       	0x40023800
.equ AHB1ENR_OFFSET, 	0x30
.equ RCC_AHB1ENR,    	(RCC_BASE + AHB1ENR_OFFSET)
.equ GPIOA_EN,       	(1 << 0)
.equ GPIOB_EN,       	(1 << 1)
.equ GPIOC_EN,       	(1 << 2)

//Valores para configurar los pines de salida
.equ GPIO_MODER_OFFSET, 0x00
.equ GPIO_ODR_OFFSET,	0x14

//Para el PORT A
.equ GPIOA_BASE,     	0x40020000
.equ GPIOA_MODER,    	(GPIOA_BASE + GPIO_MODER_OFFSET)

.equ MODER15_OUT,     	(1 << 30)
.equ MODER14_OUT,     	(1 << 28)
.equ MODER13_OUT,     	(1 << 26)
.equ MODER12_OUT,     	(1 << 24)
.equ MODER11_OUT,     	(1 << 22)
.equ MODER10_OUT,     	(1 << 20)
.equ MODER9_OUT,     	(1 << 18)

.equ GPIOA_ODR,      	(GPIOA_BASE + GPIO_ODR_OFFSET)

.equ LED15_ON,        	(1 << 15)		//segmento g
.equ LED15_OFF,       	(0 << 15)		//segmento g
.equ LED14_ON,        	(1 << 14)		//segmento f
.equ LED14_OFF,       	(0 << 14)		//segmento f
.equ LED13_ON,        	(1 << 13)		//segmento e
.equ LED13_OFF,       	(0 << 13)		//segmento e
.equ LED12_ON,        	(1 << 12)		//segmento d
.equ LED12_OFF,       	(0 << 12)		//segmento d
.equ LED11_ON,        	(1 << 11)		//segmento c
.equ LED11_OFF,       	(0 << 11)		//segmento c
.equ LED10_ON,        	(1 << 10)		//segmento b
.equ LED10_OFF,       	(0 << 10)		//segmento b
.equ LED9_ON,        	(1 << 9)		//segmento a
.equ LED9_OFF,       	(0 << 9)		//segmento a

//Para el PORT B
.equ GPIOB_BASE,		0x40020400
.equ GPIOB_MODER,		(GPIOB_BASE + GPIO_MODER_OFFSET)

.equ MODER8_OUT,     	(1 << 16)
.equ MODER7_OUT,     	(1 << 14)
.equ MODER6_OUT,     	(1 << 12)

.equ GPIOB_ODR,      	(GPIOB_BASE + GPIO_ODR_OFFSET)

.equ LED8_ON,        	(1 << 8)		//velocidad 3
.equ LED8_OFF,       	(0 << 8)		//velocidad 3
.equ LED7_ON,        	(1 << 7)		//velocidad 2
.equ LED7_OFF,       	(0 << 7)		//velocidad 2
.equ LED6_ON,        	(1 << 6)		//velocidad 1
.equ LED6_OFF,       	(0 << 6)		//velocidad 1

//Valores Habilitar Puerto C
.equ GPIOC_BASE,			0x40020800
.equ GPIOC_MODER_OFFSET,	0x00
.equ GPIOC_MODER,			(GPIOC_BASE + GPIOC_MODER_OFFSET)

//Valores configurar PORT 13C Y 14C
.equ IDR_OFFSET, 			0x10
.equ GPIOC_IDR, 			(GPIOC_BASE + IDR_OFFSET)

.equ BTN_UP_PIN,			0x2000 //PC13
.equ BTN_DOWN_PIN,			0x1000	//PC12

.equ BUTTON_PRESSED,		0x0000

//Inicial código
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main

__main:
    // Habilitar relojes para los puertos
    BL reloj

    // Configurar pines de LED de velocidad como salidas
    LDR R0, =GPIOB_MODER
    LDR R1, [R0]
    ORR R1, #(MODER6_OUT | MODER7_OUT | MODER8_OUT)
    STR R1, [R0]

    // Inicializar LEDs de velocidad apagados
    LDR R0, =GPIOB_ODR
    MOV R1, #(LED6_OFF | LED7_OFF | LED8_OFF)
    STR R1, [R0]

    // Configurar pines de 7 segmentos como salidas
    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    ORR R1, #(MODER9_OUT | MODER10_OUT)  // Configurar PA9 y PA10
    ORR R1, #(MODER11_OUT | MODER12_OUT) // Configurar PA11 y PA12
    ORR R1, #(MODER13_OUT | MODER14_OUT) // Configurar PA13 y PA14
    ORR R1, #MODER15_OUT                  // Configurar PA15
    STR R1, [R0]

    // Configurar pines de botones como entradas (00 en MODER para PC12 y PC13)
    LDR R0, =GPIOC_MODER
    LDR R1, [R0]
    BIC R1, #(3 << 24) // Limpiar bits para PC12
    BIC R1, #(3 << 26) // Limpiar bits para PC13
    STR R1, [R0]

    // Inicializar contador
    LDR R4, =contador
    MOV R5, #0
    STR R5, [R4]

    // Mostrar dígito inicial (0)
    BL estado_0

loop:
    // Actualizar LEDs de velocidad según delay_var
    BL actualizar_leds_velocidad

    // Leer estado de los botones
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]

    // Verificar botones
    TST R1, #BTN_UP_PIN
    BEQ boton_subir
    TST R1, #BTN_DOWN_PIN
    BEQ boton_bajar

    // Incrementar contador
    LDR R4, =contador
    LDR R5, [R4]
    ADD R5, R5, #1
    CMP R5, #8
    IT GE
    MOVGE R5, #0 // Reiniciar a 0 si llega a 8
    STR R5, [R4]

    // Mostrar dígito según contador
    CMP R5, #0
    BEQ estado_0
    CMP R5, #1
    BEQ estado_1
    CMP R5, #2
    BEQ estado_2
    CMP R5, #3
    BEQ estado_3
    CMP R5, #4
    BEQ estado_4
    CMP R5, #5
    BEQ estado_5
    CMP R5, #6
    BEQ estado_6
    CMP R5, #7
    BEQ estado_7

    // Aplicar retardo
    BL delay

    B loop

estado_0: // Enciende a, b, c, d, e, f (0)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON) // Encender a, b, c, d, e, f
    STR R1, [R0]
    BX LR

estado_1: // Enciende b, c (1)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED10_ON | LED11_ON) // Encender b, c
    STR R1, [R0]
    BX LR

estado_2: // Enciende a, b, d, e, g (2)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED10_ON | LED12_ON | LED13_ON | LED15_ON) // Encender a, b, d, e, g
    STR R1, [R0]
    BX LR

estado_3: // Enciende a, b, c, d, g (3)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED15_ON) // Encender a, b, c, d, g
    STR R1, [R0]
    BX LR

estado_4: // Enciende b, c, f, g (4)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED10_ON | LED11_ON | LED14_ON | LED15_ON) // Encender b, c, f, g
    STR R1, [R0]
    BX LR

estado_5: // Enciende a, c, d, f, g (5)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED11_ON | LED12_ON | LED14_ON | LED15_ON) // Encender a, c, d, f, g
    STR R1, [R0]
    BX LR

estado_6: // Enciende a, c, d, e, f, g (6)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Encender a, c, d, e, f, g
    STR R1, [R0]
    BX LR

estado_7: // Enciende a, b, c (7)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    ORR R1, #(LED9_ON | LED10_ON | LED11_ON) // Encender a, b, c
    STR R1, [R0]
    BX LR

apagado_total: // Apaga todas las LEDs de los segmentos
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    BIC R1, #(LED9_ON | LED10_ON | LED11_ON | LED12_ON | LED13_ON | LED14_ON | LED15_ON) // Apagar todos
    STR R1, [R0]
    BX LR

boton_subir:
    LDR R5, =delay_var
    LDR R6, [R5]
    LDR R7, =delay_min
    LDR R8, [R7]
    LDR R9, =step_value
    LDR R9, [R9]          // Cargar paso de incremento/decremento
    SUBS R6, R6, R9
    CMP R6, R8
    BGT subir_vel
    MOV R6, R8
subir_vel:
    STR R6, [R5]
    B wait_release

boton_bajar:
    LDR R5, =delay_var
    LDR R6, [R5]
    LDR R7, =delay_max
    LDR R8, [R7]
    LDR R9, =step_value
    LDR R9, [R9]          // Cargar paso de incremento/decremento
    ADDS R6, R6, R9
    CMP R6, R8
    BLT bajar_vel
    MOV R6, R8
bajar_vel:
    STR R6, [R5]
    B wait_release

wait_release:
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    TST R1, #BTN_UP_PIN
    BEQ wait_release
    TST R1, #BTN_DOWN_PIN
    BEQ wait_release
    B loop

// Subrutina para actualizar LEDs de velocidad
actualizar_leds_velocidad:
    LDR R0, =delay_var
    LDR R1, [R0]
    LDR R2, =delay_min
    LDR R2, [R2]
    LDR R3, =delay_max
    LDR R3, [R3]

    // Calcular rango de velocidad
    SUB R4, R3, R2        // Rango total
    MOV R7, #3
    UDIV R4, R4, R7       // Dividir en 3 partes iguales

    // Configurar LEDs según velocidad
    LDR R5, =GPIOB_ODR
    LDR R6, [R5]

    // Apagar todos los LEDs de velocidad primero
    BIC R6, #(LED6_ON | LED7_ON | LED8_ON)

    // Determinar qué LED encender
    ADD R7, R2, R4        // Límite inferior para velocidad media
    ADD R8, R7, R4        // Límite superior para velocidad media

    // Comparaciones para determinar la velocidad
    CMP R1, R7
    BLS velocidad_lenta    // Si R1 <= R7 (delay grande), velocidad lenta

    CMP R1, R8
    BLS velocidad_media    // Si R1 <= R8, velocidad media

    // Si no, velocidad rápida
    ORR R6, #LED8_ON
    B fin_actualizacion

velocidad_lenta:
    ORR R6, #LED6_ON
    B fin_actualizacion

velocidad_media:
    ORR R6, #LED7_ON

fin_actualizacion:
    // Aplicar cambios
    STR R6, [R5]
    BX LR

reloj:
    // Habilitar relojes para los puertos
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, #(GPIOA_EN | GPIOB_EN | GPIOC_EN)
    STR R1, [R0]
    BX LR

delay:
    LDR R0, =delay_var
    LDR R1, [R0]
delay_loop:
    SUBS R1, R1, #1
    BNE delay_loop
    BX LR

// Sección de datos
.section .data
delay_var: .word 150000     // Valor de delay inicial 1.5s
delay_min: .word 50000      // Delay min de 0.5s
delay_max: .word 300000     // Delay max de 3.0s
contador: .word 0           // Variable para el contador
step_value: .word 50000     // Paso de incremento/decremento

// Directivas finales
.align
.end
