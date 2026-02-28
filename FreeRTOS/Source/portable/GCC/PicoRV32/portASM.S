/* ============================================================ */
/* RESET VECTOR - ДОЛЖЕН БЫТЬ ПЕРВЫМ В .text СЕКЦИИ */
/* ============================================================ */
.section .text.reset
.align 2
.global _start

_start:
    /* Инициализация стека: используем _stack_top из linker.ld */
    lui sp, %hi(0x00008000)
    addi sp, sp, %lo(0x00008000)
    
    /* Опционально: инициализация gp, tp если нужно */
    /* la gp, __global_pointer$ */
    
    /* Вызов main */
    call main
    
    /* Если main вернётся — зацикливаемся */
1:  j 1b

#include "portContext.h"
#include "freertos_risc_v_chip_specific_extensions.h"

/* Явно отключаем CLINT-зависимый код */
#define portasmHAS_MTIME            0
#define portasmHAS_SIFIVE_CLINT     0

/* Макросы загрузки/сохранения для RV32 */
#if __riscv_xlen == 32
    #define load_x      lw
    #define store_x     sw
    #define portWORD_SIZE   4
#else
    #define load_x      ld
    #define store_x     sd
    #define portWORD_SIZE   8
#endif

/* Объявление внешних переменных */
.extern xCriticalNesting
.extern pxCriticalNesting
.extern xISRStackTop
.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern vPortTickHandler

/* Заглушки для CLINT-переменных (чтобы не было ошибок линковки) */
.section .data
.global pullMachineTimerCompareRegister
.global pullNextTime
.global uxTimerIncrementsForOneTick
.global xTaskReturnAddress
pullMachineTimerCompareRegister: .word 0
pullNextTime: .word 0
uxTimerIncrementsForOneTick: .word 0
xTaskReturnAddress: .word 0

.section .text

.global pxPortInitialiseStack
pxPortInitialiseStack:
    li t0, 0x10010000
    li t1, 0x0000000C
    sw t1, 0(t0)
    addi a0, a0, -portWORD_SIZE
    store_x x0, 0(a0)                   /* critical nesting = 0 */

#ifdef __riscv_32e
    addi a0, a0, -(6 * portWORD_SIZE)
#else
    addi a0, a0, -(22 * portWORD_SIZE)  /* x10-x31 */
#endif
    store_x a2, 0(a0)                   /* pvParameters -> x10 */

    addi a0, a0, -(6 * portWORD_SIZE)   /* x5-x9 + ra */
    load_x t0, xTaskReturnAddress
    store_x t0, 0(a0)                   /* return address */

    csrr t0, mstatus
    andi t0, t0, ~0x8
    li t1, 0x188
    slli t1, t1, 4
    or t0, t0, t1
    addi a0, a0, -portWORD_SIZE
    store_x t0, 0(a0)                   /* mstatus */

    addi a0, a0, -portWORD_SIZE
    store_x a1, 0(a0)                   /* pxCode (entry point) */
    ret

/*-----------------------------------------------------------*/
/* Запуск первой задачи */
.global xPortStartFirstTask
xPortStartFirstTask:
    load_x sp, pxCurrentTCB
    load_x sp, 0(sp)

    load_x x1, 0(sp)                    /* ra */
    portasmRESTORE_ADDITIONAL_REGISTERS

    load_x x5, 1 * portWORD_SIZE(sp)    /* mstatus */
    addi x5, x5, 0x08                   /* set MIE */
    csrw mstatus, x5

    /* Восстанавливаем регистры x7-x31 */
    load_x x7,  5  * portWORD_SIZE(sp)
    load_x x8,  6  * portWORD_SIZE(sp)
    load_x x9,  7  * portWORD_SIZE(sp)
    load_x x10, 8  * portWORD_SIZE(sp)
    load_x x11, 9  * portWORD_SIZE(sp)
    load_x x12, 10 * portWORD_SIZE(sp)
    load_x x13, 11 * portWORD_SIZE(sp)
    load_x x14, 12 * portWORD_SIZE(sp)
    load_x x15, 13 * portWORD_SIZE(sp)
#ifndef __riscv_32e
    load_x x16, 14 * portWORD_SIZE(sp)
    load_x x17, 15 * portWORD_SIZE(sp)
    load_x x18, 16 * portWORD_SIZE(sp)
    load_x x19, 17 * portWORD_SIZE(sp)
    load_x x20, 18 * portWORD_SIZE(sp)
    load_x x21, 19 * portWORD_SIZE(sp)
    load_x x22, 20 * portWORD_SIZE(sp)
    load_x x23, 21 * portWORD_SIZE(sp)
    load_x x24, 22 * portWORD_SIZE(sp)
    load_x x25, 23 * portWORD_SIZE(sp)
    load_x x26, 24 * portWORD_SIZE(sp)
    load_x x27, 25 * portWORD_SIZE(sp)
    load_x x28, 26 * portWORD_SIZE(sp)
    load_x x29, 27 * portWORD_SIZE(sp)
    load_x x30, 28 * portWORD_SIZE(sp)
    load_x x31, 29 * portWORD_SIZE(sp)
#endif

    /* Восстанавливаем critical nesting */
    load_x x5, 30 * portWORD_SIZE(sp)
    load_x x6, pxCriticalNesting
    store_x x5, 0(x6)

    /* Восстанавливаем t0, t1 */
    load_x x5, 3 * portWORD_SIZE(sp)
    load_x x6, 4 * portWORD_SIZE(sp)

    addi sp, sp, 32 * portWORD_SIZE
    ret

/*-----------------------------------------------------------*/
/* Trap handler - диспетчеризация прерываний */
.section .text.freertos_risc_v_trap_handler
.align 4
.global freertos_risc_v_trap_handler
freertos_risc_v_trap_handler:
    csrr a0, mcause
    bge a0, x0, 1f          /* synchronous exception */
    
    /* Асинхронное прерывание - вызываем наш обработчик */
    addi sp, sp, -8 * portWORD_SIZE
    store_x x1, 1 * portWORD_SIZE(sp)
    store_x x5, 3 * portWORD_SIZE(sp)
    store_x x6, 4 * portWORD_SIZE(sp)
    store_x x7, 5 * portWORD_SIZE(sp)
    store_x x10, 8 * portWORD_SIZE(sp)
    store_x x11, 9 * portWORD_SIZE(sp)
    
    load_x sp, xISRStackTop
    call vPortTickHandler
    
    load_x x1, 1 * portWORD_SIZE(sp)
    load_x x5, 3 * portWORD_SIZE(sp)
    load_x x6, 4 * portWORD_SIZE(sp)
    load_x x7, 5 * portWORD_SIZE(sp)
    load_x x10, 8 * portWORD_SIZE(sp)
    load_x x11, 9 * portWORD_SIZE(sp)
    addi sp, sp, 8 * portWORD_SIZE
    mret

1:  /* Синхронное исключение - ecall для переключения задач */
    li t0, 11                   /* 11 == ecall */
    bne a0, t0, 2f
    call vTaskSwitchContext
    mret
2:
    /* Другие исключения - заглушка */
    mret