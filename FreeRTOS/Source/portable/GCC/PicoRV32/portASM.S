.section .text.reset
.align 2
.global _start

_start:
    /* Одна инструкция jal - перепрыгиваем через вектор прерываний (0x00-0x1F) */
    jal ra, _init_stack
    
    /* Заполнение до адреса 0x10 (вектор прерываний) */
    . = 0x00000010;

.section .text.freertos_risc_v_trap_handler
.align 4
.global freertos_risc_v_trap_handler
freertos_risc_v_trap_handler:
    li t1, 0x10010000
    li t0, 0x00000400
    sw t0, 0(t1)
    csrr a0, mcause
    bge a0, x0, 1f
    
    addi sp, sp, -8 * 4
    sw x1, 1 * 4(sp)
    sw x5, 3 * 4(sp)
    sw x6, 4 * 4(sp)
    sw x7, 5 * 4(sp)
    sw x10, 8 * 4(sp)
    sw x11, 9 * 4(sp)
    
    lw sp, xISRStackTop
    call vPortTickHandler
    
    lw x1, 1 * 4(sp)
    lw x5, 3 * 4(sp)
    lw x6, 4 * 4(sp)
    lw x7, 5 * 4(sp)
    lw x10, 8 * 4(sp)
    lw x11, 9 * 4(sp)
    addi sp, sp, 8 * 4
    mret

1:  /* === Синхронное исключение === */
    /* Временная заглушка - просто возвращаемся */
    mret

.section .text.init
_init_stack:
    /* Инициализация стека */
    lui sp, %hi(0x00008000)
    addi sp, sp, %lo(0x00008000)
    
    /* Вызов main */
    call main
    
    /* Если main вернётся — зацикливаемся */
1:  j 1b

/* ============================================ */
/* macros */
/* ============================================ */
#define load_x      lw
#define store_x     sw
#define portWORD_SIZE   4

/* ============================================ */
/* extern */
/* ============================================ */
.extern xCriticalNesting
.extern pxCriticalNesting
.extern xISRStackTop
.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern vPortTickHandler

/* ============================================ */
/* pxPortInitialiseStack */
/* ============================================ */
.section .text
.global pxPortInitialiseStack
pxPortInitialiseStack:
    
    li t0, 0
    
    /* x1, x5-x7, x10-x17, x18-x27, x28-x31 */
    sw t0, 0(a0)       /* x1  - ra */
    sw t0, 4(a0)       /* x5  - t0 */
    sw t0, 8(a0)       /* x6  - t1 */
    sw t0, 12(a0)      /* x7  - t2 */
    sw t0, 16(a0)      /* x10 - a0 */
    sw t0, 20(a0)      /* x11 - a1 */
    sw a2, 24(a0)      /* x12 - a2 (pvParameters) */
    sw t0, 28(a0)      /* x13 - a3 */
    sw t0, 32(a0)      /* x14 - a4 */
    sw t0, 36(a0)      /* x15 - a5 */
    sw t0, 40(a0)      /* x16 - a6 */
    sw t0, 44(a0)      /* x17 - a7 */
    sw t0, 48(a0)      /* x18 - s0 */
    sw t0, 52(a0)      /* x19 - s1 */
    sw t0, 56(a0)      /* x20 - s2 */
    sw t0, 60(a0)      /* x21 - s3 */
    sw t0, 64(a0)      /* x22 - s4 */
    sw t0, 68(a0)      /* x23 - s5 */
    sw t0, 72(a0)      /* x24 - s6 */
    sw t0, 76(a0)      /* x25 - s7 */
    sw t0, 80(a0)      /* x26 - s8 */
    sw t0, 84(a0)      /* x27 - s9 */
    sw t0, 88(a0)      /* x28 - s10 */
    sw t0, 92(a0)      /* x29 - s11 */
    sw t0, 96(a0)      /* x30 - t3 */
    sw t0, 100(a0)     /* x31 - t4 */
    
    /* x8, x9 */
    sw t0, 104(a0)
    sw t0, 108(a0)
    
    /* mstatus */
    li t0, 0x00001888
    sw t0, 112(a0)     /* Смещение 28 * 4 */
    
    /* mepc - точка входа задачи */
    sw a1, 116(a0)     /* Смещение 29 * 4 */
    
    /* critical nesting */
    li t0, 0
    sw t0, 120(a0)     /* Смещение 30 * 4 */
    
    ret

/* ============================================ */
/* xPortStartFirstTask */
/* ============================================ */
.global xPortStartFirstTask
xPortStartFirstTask:
    la t0, pxCurrentTCB
    lw sp, 0(t0)

    /* Восстанавливаем регистры в том же порядке, что и в pxPortInitialiseStack */
    lw x1,  0 * 4(sp)
    lw x5,  1 * 4(sp)
    lw x6,  2 * 4(sp)
    lw x7,  3 * 4(sp)
    lw x10, 4 * 4(sp)
    lw x11, 5 * 4(sp)
    lw x12, 6 * 4(sp)
    lw x13, 7 * 4(sp)
    lw x14, 8 * 4(sp)
    lw x15, 9 * 4(sp)
    lw x16, 10 * 4(sp)
    lw x17, 11 * 4(sp)
    lw x18, 12 * 4(sp)
    lw x19, 13 * 4(sp)
    lw x20, 14 * 4(sp)
    lw x21, 15 * 4(sp)
    lw x22, 16 * 4(sp)
    lw x23, 17 * 4(sp)
    lw x24, 18 * 4(sp)
    lw x25, 19 * 4(sp)
    lw x26, 20 * 4(sp)
    lw x27, 21 * 4(sp)
    lw x28, 22 * 4(sp)
    lw x29, 23 * 4(sp)
    lw x30, 24 * 4(sp)
    lw x31, 25 * 4(sp)
    
    /* x8, x9 */
    lw x8, 26 * 4(sp)
    lw x9, 27 * 4(sp)
    
    /* mstatus */
    lw t0, 28 * 4(sp)
    csrw mstatus, t0
    
    /* mepc */
    lw t0, 29 * 4(sp)
    csrw mepc, t0
    
    /* critical nesting */
    lw t0, 30 * 4(sp)
    la t1, pxCriticalNesting
    sw t0, 0(t1)
    
    addi sp, sp, 31 * 4
    mret