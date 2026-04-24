#include "portContext.h"

/* ==========================================================
 * ВЕКТОР СБРОСА
 * ========================================================== */
.section .text.reset_vector
.globl _start
_start:
    j real_start

/* ==========================================================
 * IRQ ВЕКТОР
 * ========================================================== */
.section .text.irq_vector
.globl irq_vector
irq_vector:
    j real_irq_handler

/* ==========================================================
 * СТАРТ СИСТЕМЫ
 * ========================================================== */
.section .text.real_start
real_start:
    .option push
    .option norelax
    la sp, _estack
    .option pop

    la a0, _sbss
    la a1, _ebss
    bgeu a0, a1, 1f
0:
    sw zero, 0(a0)
    addi a0, a0, 4
    bltu a0, a1, 0b
1:
    jal ra, main
2:
    j 2b

/* ==========================================================
* ОБРАБОТЧИК ПРЕРЫВАНИЙ
* ========================================================== */
.section .text.irq_real
.align 2
.global real_irq_handler
real_irq_handler:
    li   a0, 0x03000010
    li   a1, 0xEEEEEEEE
    sw   a1, 0(a0)
    addi sp, sp, -128

    /* 🔑 1. Читаем PC прерванной задачи из q1 и кладём в sp[0] */
    .word 0x0000028B      /* getq x5, q1 */
    sw   x5, 0(sp)

    /* 2. Сохраняем x1 и остальные регистры */
    sw   x1,  8(sp)
    sw   x6,  16(sp)
    sw   x7,  20(sp)
    sw   x8,  24(sp)
    sw   x9,  28(sp)
    sw   x10, 32(sp)
    sw   x11, 36(sp)
    sw   x12, 40(sp)
    sw   x13, 44(sp)
    sw   x14, 48(sp)
    sw   x15, 52(sp)
#ifndef __riscv_32e
    sw   x16, 56(sp)
    sw   x17, 60(sp)
    sw   x18, 64(sp)
    sw   x19, 68(sp)
    sw   x20, 72(sp)
    sw   x21, 76(sp)
    sw   x22, 80(sp)
    sw   x23, 84(sp)
    sw   x24, 88(sp)
    sw   x25, 92(sp)
    sw   x26, 96(sp)
    sw   x27, 100(sp)
    sw   x28, 104(sp)
    sw   x29, 108(sp)
    sw   x30, 112(sp)
    sw   x31, 116(sp)
#endif

    /* 3. Critical nesting и TCB */
    lw   x5, pxCriticalNesting
    sw   x5, 120(sp)
    lw   x5, pxCurrentTCB
    sw   sp, 0(x5)

    /* 4. FreeRTOS tick & switch */
    call xTaskIncrementTick
    beqz x10, 1f
    call vTaskSwitchContext
1:
    /* 5. Загружаем стек новой задачи */
    lw   x5, pxCurrentTCB
    lw   sp, 0(x5)

    /* 6. Восстанавливаем Critical nesting */
    lw   x5, 120(sp)
    lw   x6, pxCriticalNesting
    sw   x5, 0(x6)

    li   a0, 100000
    .word 0x0A05000B

    /* 7. Восстанавливаем регистры */
    lw   x1,  8(sp)
    lw   x6,  16(sp)
    lw   x7,  20(sp)
    lw   x8,  24(sp)
    lw   x9,  28(sp)
    lw   x10, 32(sp)
    lw   x11, 36(sp)
    lw   x12, 40(sp)
    lw   x13, 44(sp)
    lw   x14, 48(sp)
    lw   x15, 52(sp)
#ifndef __riscv_32e
    lw   x16, 56(sp)
    lw   x17, 60(sp)
    lw   x18, 64(sp)
    lw   x19, 68(sp)
    lw   x20, 72(sp)
    lw   x21, 76(sp)
    lw   x22, 80(sp)
    lw   x23, 84(sp)
    lw   x24, 88(sp)
    lw   x25, 92(sp)
    lw   x26, 96(sp)
    lw   x27, 100(sp)
    lw   x28, 104(sp)
    lw   x29, 108(sp)
    lw   x30, 112(sp)
    lw   x31, 116(sp)
#endif

    /* 🔑 8. Берём PC новой задачи из sp[0], кладём в q0 и выходим */
    lw   x1, 0(sp)
    addi sp, sp, 128
    .word 0x0200800B     /* setq q0, x1 */
    .word 0x0400000B     /* retirq */

    j .