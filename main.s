/*
**********************************************************************************************
*@file      main.s
*@author    Sarah Estrada
*			Kristel Castillo
*			Yu-Fong Chen
*@date      May, 2025 - June 2025
*@brief     Proyecto 4, Programa contador de 0 a 9 en Assembly al que se le puede
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
.equ GPIOA_MODER,    	(GPIODA_BASE + GPIO_MODER_OFFSET)

.equ MODER15_OUT,     	(1 << 30)
.equ MODER14_OUT,     	(1 << 28)
.equ MODER13_OUT,     	(1 << 26)
.equ MODER12_OUT,     	(1 << 24)
.equ MODER11_OUT,     	(1 << 22)
.equ MODER10_OUT,     	(1 << 20)
.equ MODER9_OUT,     	(1 << 18)

.equ GPIODA_ODR,      	(GPIOA_BASE + GPIO_ODR_OFFSET)

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
.equ GPIOB_MODER,		(GPIODB_BASE + GPIO_MODER_OFFSET)

.equ MODER8_OUT,     	(1 << 16)
.equ MODER7_OUT,     	(1 << 14)
.equ MODER6_OUT,     	(1 << 12)

.equ GPIODB_ODR,      	(GPIOB_BASE + GPIO_ODR_OFFSET)

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

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main


__main:

loop:
	//Leer el estado de los botones
	LDR R0, =GPIOC_IDR
	LDR R1, [R0]

	//Verifica si es el boton de subir
	TST R1, #BTN_UP_PIN
    BEQ boton_subir

    ////Verifica si es el boton de bajar
    TST R1, #BTN_DOWN_PIN
    BEQ boton_bajar

	B loop

boton_subir:
	LDR R5, =delay_var
	LDR R6, [R5]
	SUB R6, R6, #50000
	LDR R7, =delay_min
	LDR R8, [R7]
	BGT subir_vel
	MOV R6, R8

subir_vel:
	STR R6, [R5]
    B wait_release


boton_bajar:
	LDR R5, =delay_var
	LDR R6, [R5]
	ADD R6, R6, #50000
	LDR R7, =delay_max
	LDR R8, [R7]
	BLT bajar_vel
	MOV R6, R8

bajar_vel:
	STR R6, [R5]
	B wait_release

wait_release:
	LDR R0, =GPIOC_IDR
	LDR R1, [R0]
	TST R1, #BTN_UP_PIN
    BEQ wait_release	//Si sigue presionado el boton de subir va a repetir ciclo
    TST R1, #BTN_DOWN_PIN
    BEQ wait_release	//Si sigue presionado el boyon de bakar va a repetir ciclo
    B loop				// ambos estan suelto, va a regresar al loop

end:
    B end

reloj:


// Sección de datos
.section .data
delay_var: .word 150000     // Valor de delay inicial 1.5s
delay_min: .word 50000      // Delay min de 0.5s
delay_max: .word 3000000 	// Delay max de 3.0s


//Directivas finales
.align
.end
