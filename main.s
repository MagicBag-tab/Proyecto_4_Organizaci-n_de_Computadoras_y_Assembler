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


//Valores para configurar PORT C
.equ GPIOC_BASE,     	0x40020800
.equ GPIOC_MODER,		(GPIOC_BASE + GPIO_MODER_OFFSET)

//valores para configurar pines de salida
.equ GPIO_IDR_OFFSET,	0x10

//Para PORT C
.equ MODER8_IN,     	(1 << 16)
.equ MODER7_IN,     	(1 << 14)
.equ MODER6_IN,     	(1 << 12)

.equ GPIOC_IDR,      	(GPIOC_BASE + GPIO_IDR_OFFSET)

.equ BUTTON_OFF,        0x2000
.equ BUTTON_ON,			0x0000

.equ BTN_PIN8,			(1 << 8)		//velocidad 3
.equ BTN_PIN7,			(1 << 7)		//velocidad 2
.equ BTN_PIN6,			(1 << 6)		//velocidad 1

.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main

__main:


// Sección de datos
.section .data

//Directivas finales
.align
.end
