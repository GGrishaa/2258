.section .text.reset
.align 2
.global _start

_start:
    /* Инициализация стека */
    lui sp, %hi(0x00008000)
    addi sp, sp, %lo(0x00008000)
    
    /* Вызов main */
    call main
    
    /* Если main вернётся — зацикливаемся */
1:  j 1b

#define load_x      lw
#define store_x     sw
#define portWORD_SIZE   4

.extern xCriticalNesting
.extern pxCriticalNesting
.extern xISRStackTop
.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern vPortTickHandler

.section .text
.global pxPortInitialiseStack
pxPortInitialiseStack:
    
    li t0, 0
    
    /* mstatus */
    sw t0, 0(a0)
    /* mepc */
    sw a1, 4(a0)
    /* t0-t6 */
    sw t0, 8(a0)
    sw t0, 12(a0)
    sw t0, 16(a0)
    sw t0, 20(a0)
    sw t0, 24(a0)
    sw t0, 28(a0)
    sw t0, 32(a0)
    /* a0-a7 */
    sw t0, 36(a0)
    sw t0, 40(a0)
    sw a2, 44(a0)       /* pvParameters */
    sw t0, 48(a0)
    sw t0, 52(a0)
    sw t0, 56(a0)
    sw t0, 60(a0)
    sw t0, 64(a0)
    /* s0-s11 */
    sw t0, 68(a0)
    sw t0, 72(a0)
    sw t0, 76(a0)
    sw t0, 80(a0)
    sw t0, 84(a0)
    sw t0, 88(a0)
    sw t0, 92(a0)
    sw t0, 96(a0)
    sw t0, 100(a0)
    sw t0, 104(a0)
    sw t0, 108(a0)
    sw t0, 112(a0)
    /* ra */
    sw t0, 116(a0)
    /* critical nesting */
    sw t0, 120(a0)
    
    /* mstatus: MIE=1, MPIE=1 */
    li t0, 0x00001888
    sw t0, 0(a0)
    
    ret

.global xPortStartFirstTask
xPortStartFirstTask:
    load_x sp, pxCurrentTCB
    load_x sp, 0(sp)

    /* Восстанавливаем все регистры */
    load_x x1,  0 * portWORD_SIZE(sp)
    load_x x5,  1 * portWORD_SIZE(sp)
    load_x x6,  2 * portWORD_SIZE(sp)
    load_x x7,  3 * portWORD_SIZE(sp)
    load_x x8,  4 * portWORD_SIZE(sp)
    load_x x9,  5 * portWORD_SIZE(sp)
    load_x x10, 6 * portWORD_SIZE(sp)
    load_x x11, 7 * portWORD_SIZE(sp)
    load_x x12, 8 * portWORD_SIZE(sp)
    load_x x13, 9 * portWORD_SIZE(sp)
    load_x x14, 10 * portWORD_SIZE(sp)
    load_x x15, 11 * portWORD_SIZE(sp)
    load_x x16, 12 * portWORD_SIZE(sp)
    load_x x17, 13 * portWORD_SIZE(sp)
    load_x x18, 14 * portWORD_SIZE(sp)
    load_x x19, 15 * portWORD_SIZE(sp)
    load_x x20, 16 * portWORD_SIZE(sp)
    load_x x21, 17 * portWORD_SIZE(sp)
    load_x x22, 18 * portWORD_SIZE(sp)
    load_x x23, 19 * portWORD_SIZE(sp)
    load_x x24, 20 * portWORD_SIZE(sp)
    load_x x25, 21 * portWORD_SIZE(sp)
    load_x x26, 22 * portWORD_SIZE(sp)
    load_x x27, 23 * portWORD_SIZE(sp)
    load_x x28, 24 * portWORD_SIZE(sp)
    load_x x29, 25 * portWORD_SIZE(sp)
    load_x x30, 26 * portWORD_SIZE(sp)
    load_x x31, 27 * portWORD_SIZE(sp)
    
    /* mstatus */
    load_x t0, 28 * portWORD_SIZE(sp)
    csrw mstatus, t0
    
    /* mepc */
    load_x t0, 29 * portWORD_SIZE(sp)
    csrw mepc, t0
    
    /* critical nesting */
    load_x t0, 30 * portWORD_SIZE(sp)
    load_x t1, pxCriticalNesting
    sw t0, 0(t1)
    
    addi sp, sp, 32 * portWORD_SIZE
    ret

.section .text.freertos_risc_v_trap_handler
.align 4
.global freertos_risc_v_trap_handler
freertos_risc_v_trap_handler:
    csrr a0, mcause
    bge a0, x0, 1f          /* synchronous exception */
    
    /* === Асинхронное прерывание (таймер) === */
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

1:  /* === Синхронное исключение (ecall) === */
    li t0, 11                   /* 11 == ecall */
    bne a0, t0, 2f
    
    /* Сохраняем контекст текущей задачи */
    addi sp, sp, -32 * portWORD_SIZE
    
    store_x x1,  0 * portWORD_SIZE(sp)
    store_x x5,  1 * portWORD_SIZE(sp)
    store_x x6,  2 * portWORD_SIZE(sp)
    store_x x7,  3 * portWORD_SIZE(sp)
    store_x x8,  4 * portWORD_SIZE(sp)
    store_x x9,  5 * portWORD_SIZE(sp)
    store_x x10, 6 * portWORD_SIZE(sp)
    store_x x11, 7 * portWORD_SIZE(sp)
    store_x x12, 8 * portWORD_SIZE(sp)
    store_x x13, 9 * portWORD_SIZE(sp)
    store_x x14, 10 * portWORD_SIZE(sp)
    store_x x15, 11 * portWORD_SIZE(sp)
    store_x x16, 12 * portWORD_SIZE(sp)
    store_x x17, 13 * portWORD_SIZE(sp)
    store_x x18, 14 * portWORD_SIZE(sp)
    store_x x19, 15 * portWORD_SIZE(sp)
    store_x x20, 16 * portWORD_SIZE(sp)
    store_x x21, 17 * portWORD_SIZE(sp)
    store_x x22, 18 * portWORD_SIZE(sp)
    store_x x23, 19 * portWORD_SIZE(sp)
    store_x x24, 20 * portWORD_SIZE(sp)
    store_x x25, 21 * portWORD_SIZE(sp)
    store_x x26, 22 * portWORD_SIZE(sp)
    store_x x27, 23 * portWORD_SIZE(sp)
    store_x x28, 24 * portWORD_SIZE(sp)
    store_x x29, 25 * portWORD_SIZE(sp)
    store_x x30, 26 * portWORD_SIZE(sp)
    store_x x31, 27 * portWORD_SIZE(sp)
    
    /* mstatus и mepc */
    csrr t0, mstatus
    csrr t1, mepc
    store_x t0, 28 * portWORD_SIZE(sp)
    store_x t1, 29 * portWORD_SIZE(sp)
    
    /* critical nesting */
    load_x t0, pxCriticalNesting
    load_x t0, 0(t0)
    store_x t0, 30 * portWORD_SIZE(sp)
    
    /* Сохраняем SP в TCB */
    load_x t0, pxCurrentTCB
    store_x sp, 0(t0)
    
    /* Переключаем задачу */
    call vTaskSwitchContext
    
    /* Восстанавливаем контекст новой задачи */
    load_x sp, pxCurrentTCB
    load_x sp, 0(sp)
    
    /* mstatus и mepc */
    load_x t0, 28 * portWORD_SIZE(sp)
    load_x t1, 29 * portWORD_SIZE(sp)
    csrw mstatus, t0
    csrw mepc, t1
    
    /* critical nesting */
    load_x t0, 30 * portWORD_SIZE(sp)
    load_x t1, pxCriticalNesting
    store_x t0, 0(t1)
    
    /* Восстанавливаем регистры */
    load_x x1,  0 * portWORD_SIZE(sp)
    load_x x5,  1 * portWORD_SIZE(sp)
    load_x x6,  2 * portWORD_SIZE(sp)
    load_x x7,  3 * portWORD_SIZE(sp)
    load_x x8,  4 * portWORD_SIZE(sp)
    load_x x9,  5 * portWORD_SIZE(sp)
    load_x x10, 6 * portWORD_SIZE(sp)
    load_x x11, 7 * portWORD_SIZE(sp)
    load_x x12, 8 * portWORD_SIZE(sp)
    load_x x13, 9 * portWORD_SIZE(sp)
    load_x x14, 10 * portWORD_SIZE(sp)
    load_x x15, 11 * portWORD_SIZE(sp)
    load_x x16, 12 * portWORD_SIZE(sp)
    load_x x17, 13 * portWORD_SIZE(sp)
    load_x x18, 14 * portWORD_SIZE(sp)
    load_x x19, 15 * portWORD_SIZE(sp)
    load_x x20, 16 * portWORD_SIZE(sp)
    load_x x21, 17 * portWORD_SIZE(sp)
    load_x x22, 18 * portWORD_SIZE(sp)
    load_x x23, 19 * portWORD_SIZE(sp)
    load_x x24, 20 * portWORD_SIZE(sp)
    load_x x25, 21 * portWORD_SIZE(sp)
    load_x x26, 22 * portWORD_SIZE(sp)
    load_x x27, 23 * portWORD_SIZE(sp)
    load_x x28, 24 * portWORD_SIZE(sp)
    load_x x29, 25 * portWORD_SIZE(sp)
    load_x x30, 26 * portWORD_SIZE(sp)
    load_x x31, 27 * portWORD_SIZE(sp)
    
    addi sp, sp, 32 * portWORD_SIZE
    mret

2:  /* Другие исключения - заглушка */
    mret