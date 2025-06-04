/*
**********************************************************************************************
*@file      main.s
*@authors
*			Kristel Castillo - Yu Fong Chen - Sarah Estrada
*@date		June 2025
*@brief     Contador de 0 a 7 en display 7 segmentos con control de velocidad
*@details   Versión corregida con solución para segmentos G y B
**********************************************************************************************
*/

/* --- Definiciones de registros --- */
.equ RCC_BASE,       0x40023800
.equ AHB1ENR_OFFSET, 0x30
.equ RCC_AHB1ENR,    (RCC_BASE + AHB1ENR_OFFSET)
.equ GPIOA_EN,       (1 << 0)
.equ GPIOB_EN,       (1 << 1)
.equ GPIOC_EN,       (1 << 2)

/* --- Configuración GPIOA (Display 7 segmentos) --- */
.equ GPIOA_BASE,     0x40020000
.equ GPIOA_MODER,    (GPIOA_BASE + 0x00)
.equ GPIOA_ODR,      (GPIOA_BASE + 0x14)

/* Segmentos del display - CORREGIDO para segmentos G y B */
.equ SEG_A,         (1 << 9)   // PA9
.equ SEG_B,         (1 << 10)  // PA10 - Segmento B
.equ SEG_C,         (1 << 11)  // PA11
.equ SEG_D,         (1 << 12)  // PA12
.equ SEG_E,         (1 << 15)  // PA15
.equ SEG_F,         (1 << 7)   // PA7
.equ SEG_G,         (1 << 6)   // PA6 - Segmento G

/* --- Configuración GPIOB (LEDs de velocidad) --- */
.equ GPIOB_BASE,    0x40020400
.equ GPIOB_MODER,   (GPIOB_BASE + 0x00)
.equ GPIOB_ODR,     (GPIOB_BASE + 0x14)
.equ LED_VEL1,      (1 << 6)   // PB6 - LED velocidad mínima
.equ LED_VEL2,      (1 << 7)   // PB7
.equ LED_VEL3,      (1 << 8)   // PB8

/* --- Configuración GPIOC (Botones) --- */
.equ GPIOC_BASE,    0x40020800
.equ GPIOC_MODER,   (GPIOC_BASE + 0x00)
.equ GPIOC_IDR,     (GPIOC_BASE + 0x10)
.equ GPIOC_PUPDR,   (GPIOC_BASE + 0x0C)
.equ BTN_UP_PIN,    0x2000     // PC13
.equ BTN_DOWN_PIN,  0x1000     // PC12

/* --- Inicialización --- */
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main

__main:
    /* Habilitar relojes para GPIOA, GPIOB y GPIOC */
    BL reloj_config

    /* Configurar pines de LED de velocidad como salidas */
    LDR R0, =GPIOB_MODER
    LDR R1, [R0]
    /* PB6, PB7, PB8 como salidas (01) */
    BIC R1, #((3 << 12) | (3 << 14) | (3 << 16))  // Limpiar bits
    ORR R1, #((1 << 12) | (1 << 14) | (1 << 16))  // Configurar como salidas
    STR R1, [R0]

    /* Inicializar LEDs de velocidad apagados */
    LDR R0, =GPIOB_ODR
    MOV R1, #0
    STR R1, [R0]

    /* Configurar pines de 7 segmentos como salidas - CORREGIDO */
    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    /* Limpiar configuraciones previas para los pines que usaremos */
    BIC R1, #(0xFF << 12)  // Limpia PA6,PA7,PA9,PA10
    BIC R1, #(0xF << 22)   // Limpia PA11,PA12
    BIC R1, #(3 << 30)     // Limpia PA15
    /* Configurar como salidas (01) */
    ORR R1, #(0x55 << 12)  // PA6,PA7,PA9,PA10 como salidas (01010101)
    ORR R1, #(0x5 << 22)   // PA11,PA12 como salidas (0101)
    ORR R1, #(1 << 30)     // PA15 como salida (01)
    STR R1, [R0]

    /* Configurar botones con pull-up */
    LDR R0, =GPIOC_MODER
    LDR R1, [R0]
    BIC R1, #(3 << 24)       // PC12 como entrada
    BIC R1, #(3 << 26)       // PC13 como entrada
    STR R1, [R0]

    LDR R0, =GPIOC_PUPDR
    LDR R1, [R0]
    BIC R1, #(3 << 24)       // Limpiar configuración previa PC12
    BIC R1, #(3 << 26)       // Limpiar configuración previa PC13
    ORR R1, #(1 << 24)       // Pull-up para PC12
    ORR R1, #(1 << 26)       // Pull-up para PC13
    STR R1, [R0]

    /* Inicializar variables */
    LDR R4, =contador
    MOV R5, #0
    STR R5, [R4]

    LDR R0, =delay_var
    LDR R1, =500000         // Valor inicial más lento
    STR R1, [R0]

    /* Mostrar dígito inicial (0) */
    BL display_0

/* --- Loop principal --- */
main_loop:
    BL actualizar_leds_velocidad
    BL leer_botones
    BL incrementar_contador
    BL mostrar_digito
    BL delay
    B main_loop

/* --- Subrutinas --- */

/* Configurar relojes */
reloj_config:
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, #(GPIOA_EN | GPIOB_EN | GPIOC_EN)
    STR R1, [R0]
    BX LR

/* Leer estado de botones */
leer_botones:
    /* Guardamos LR en R10 */
    MOV R10, LR

    LDR R0, =GPIOC_IDR
    LDR R1, [R0]

    TST R1, #BTN_UP_PIN
    BEQ boton_aumentar

    TST R1, #BTN_DOWN_PIN
    BEQ boton_disminuir

    /* Restauramos LR desde R10 */
    BX R10

/* Manejo de botón aumentar */
boton_aumentar:
    LDR R0, =delay_var
    LDR R1, [R0]
    LDR R2, =delay_min
    LDR R2, [R2]
    LDR R3, =step_value
    LDR R3, [R3]

    SUBS R1, R1, R3
    CMP R1, R2
    BGT guardar_delay
    MOV R1, R2

guardar_delay:
    STR R1, [R0]
    BL wait_release
    BX R10

/* Manejo de botón disminuir */
boton_disminuir:
    LDR R0, =delay_var
    LDR R1, [R0]
    LDR R2, =delay_max
    LDR R2, [R2]
    LDR R3, =step_value
    LDR R3, [R3]

    ADDS R1, R1, R3
    CMP R1, R2
    BLT guardar_delay
    MOV R1, R2
    B guardar_delay

/* Esperar a soltar botón con debounce */
wait_release:
    /* Usamos R11 para el contador de debounce */
    LDR R11, =100000       // Valor para delay de debounce
wait_loop:
    LDR R0, =GPIOC_IDR
    LDR R1, [R0]
    TST R1, #BTN_UP_PIN
    BEQ wait_loop
    TST R1, #BTN_DOWN_PIN
    BEQ wait_loop
    SUBS R11, #1
    BNE wait_loop
    BX LR

/* Incrementar contador (0-7) */
incrementar_contador:
    LDR R0, =contador
    LDR R1, [R0]
    ADDS R1, #1
    CMP R1, #8
    BNE no_reset
    MOV R1, #0
no_reset:
    STR R1, [R0]
    BX LR

/* Mostrar dígito según contador */
mostrar_digito:
    LDR R0, =contador
    LDR R1, [R0]

    CMP R1, #0
    BEQ display_0
    CMP R1, #1
    BEQ display_1
    CMP R1, #2
    BEQ display_2
    CMP R1, #3
    BEQ display_3
    CMP R1, #4
    BEQ display_4
    CMP R1, #5
    BEQ display_5
    CMP R1, #6
    BEQ display_6
    CMP R1, #7
    BEQ display_7
    BX LR

/* Patrones para display de 7 segmentos - CORREGIDOS para segmentos G y B */
display_0:  // a, b, c, d, e, f
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_B | SEG_C | SEG_D | SEG_E | SEG_F)
    STR R1, [R0]
    BX LR

display_1:  // b, c
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_B | SEG_C)
    STR R1, [R0]
    BX LR

display_2:  // a, b, g, e, d
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_B | SEG_G | SEG_E | SEG_D)
    STR R1, [R0]
    BX LR

display_3:  // a, b, g, c, d
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_B | SEG_G | SEG_C | SEG_D)
    STR R1, [R0]
    BX LR

display_4:  // f, g, b, c
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_F | SEG_G | SEG_B | SEG_C)
    STR R1, [R0]
    BX LR

display_5:  // a, f, g, c, d
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_F | SEG_G | SEG_C | SEG_D)
    STR R1, [R0]
    BX LR

display_6:  // a, f, g, c, d, e
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_F | SEG_G | SEG_C | SEG_D | SEG_E)
    STR R1, [R0]
    BX LR

display_7:  // a, b, c
    LDR R0, =GPIOA_ODR
    MOV R1, #(SEG_A | SEG_B | SEG_C)
    STR R1, [R0]
    BX LR

/* Actualizar LEDs de velocidad - CORREGIDO para PB6 */
actualizar_leds_velocidad:
    LDR R0, =delay_var
    LDR R1, [R0]
    LDR R2, =delay_min
    LDR R2, [R2]
    LDR R3, =delay_max
    LDR R3, [R3]

    SUB R4, R3, R2        // Rango total
    MOV R5, #3
    UDIV R4, R4, R5       // Dividir en 3 partes

    ADD R5, R2, R4        // Límite inferior velocidad media
    ADD R6, R5, R4        // Límite superior velocidad media

    LDR R7, =GPIOB_ODR
    LDR R8, [R7]          // Leer estado actual
    BIC R8, #(LED_VEL1 | LED_VEL2 | LED_VEL3)  // Apagar todos los LEDs de velocidad

    CMP R1, R5
    BLS velocidad_lenta

    CMP R1, R6
    BLS velocidad_media

    // Velocidad rápida - encender LED_VEL3 (PB8)
    ORR R8, #LED_VEL3
    B fin_velocidad

velocidad_lenta:
    // Velocidad lenta - encender LED_VEL1 (PB6)
    ORR R8, #LED_VEL1
    B fin_velocidad

velocidad_media:
    // Velocidad media - encender LED_VEL2 (PB7)
    ORR R8, #LED_VEL2

fin_velocidad:
    STR R8, [R7]          // Escribir nuevos valores
    BX LR

/* Retardo variable */
delay:
    LDR R0, =delay_var
    LDR R1, [R0]
delay_loop:
    SUBS R1, #1
    BNE delay_loop
    BX LR

/* --- Sección de datos --- */
.section .data
.align 4
delay_var:    .word 15000000    // Valor inicial (0.5s aprox)
delay_min:    .word 1000000     // Mínimo
delay_max:    .word 30000000    // Máximo
step_value:   .word 100000     // Paso de cambio
contador:     .word 0          // Contador actual

.align
.end
