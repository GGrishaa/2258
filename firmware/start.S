#include "portContext.h"

.section .text.reset_vector
.globl _start
_start:
    j real_start

.section .text.irq_vector
.globl irq_vector
irq_vector:
    j real_irq_handler

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

.section .text.irq_real
.align 2
.global real_irq_handler
real_irq_handler:
    addi sp, sp, -128

    .word 0x0000028B
    sw   x5, 0(sp)
    
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

    lw   x5, pxCriticalNesting
    sw   x5, 120(sp)
    lw   x5, pxCurrentTCB
    sw   sp, 0(x5)

    call xTaskIncrementTick
    beqz x10, 1f
    call vTaskSwitchContext
1:
    lw   x5, pxCurrentTCB
    lw   sp, 0(x5)

    lw   a1, pxCurrentTCB
    lw   a1, 0(a1)

    lw   x5, 120(sp)
    lw   x6, pxCriticalNesting
    sw   x5, 0(x6)

    li   a0, 100000
    .word 0x0A05000B

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

    lw   x1, 0(sp)
    and  x1, x1, -2

    addi sp, sp, 128
    .word 0x0200800B
    .word 0x0400000B

    j .