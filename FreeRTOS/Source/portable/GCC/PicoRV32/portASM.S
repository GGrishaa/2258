.section .text.reset
.align 2
.global _start

_start:
    jal ra, _init_stack
    . = 0x00000010;

.section .text.freertos_risc_v_trap_handler
.align 4
.global freertos_risc_v_trap_handler
freertos_risc_v_trap_handler:
    /* === 0x400: Вход в обработчик прерывания === */
    li t1, 0x10010000
    li t0, 0x00000400
    sw t0, 0(t1)
    
    /* Сохраняем временные регистры */
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw t3, 16(sp)
    sw t4, 20(sp)
    sw t5, 24(sp)
    sw t6, 28(sp)
    
    /* === 0x410: Переключаемся на ISR стек === */
    li t1, 0x10010000
    li t0, 0x00000410
    sw t0, 0(t1)
    
    lw sp, xISRStackTop
    
    /* === 0x420: Вызываем обработчик тика === */
    li t1, 0x10010000
    li t0, 0x00000420
    sw t0, 0(t1)
    
    call vPortTickHandler
    
    /* Восстанавливаем временные регистры */
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw t3, 16(sp)
    lw t4, 20(sp)
    lw t5, 24(sp)
    lw t6, 28(sp)
    addi sp, sp, 32
    
    /* === 0x430: Возврат через retirq === */
    li t1, 0x10010000
    li t0, 0x00000430
    sw t0, 0(t1)
    
    .word 0x04008013       /* retirq ra */

.section .text.init
_init_stack:
    lui sp, %hi(0x00008000)
    addi sp, sp, %lo(0x00008000)
    call main
1:  j 1b

/* ============================================ */
#define load_x      lw
#define store_x     sw
#define portWORD_SIZE   4

/* ============================================ */
.extern xCriticalNesting
.extern pxCriticalNesting
.extern xISRStackTop
.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern vPortTickHandler

/* ============================================ */
.section .text
.global pxPortInitialiseStack
pxPortInitialiseStack:
    /* === 0x1100: Вход в pxPortInitialiseStack === */
    li t1, 0x10010000
    li t0, 0x00001100
    sw t0, 0(t1)
    
    /* === 0x1101: Показываем адрес задачи === */
    li t1, 0x10010000
    
    /* Явно обнуляем верхние биты для 64-битного тулчейна */
    /* Копируем a1 в t2 и сдвигаем, чтобы гарантировать 32 бита */
    mv t2, a1
    sll t2, t2, 0      /* Это noop, но может "починить" тип */
    sw t2, 0(t1)       /* Показываем адрес! */
    
    li t0, 0
    
    /* x1 - ra (сюда запишем точку входа) - ИСПОЛЬЗУЕМ t2 вместо a1 */
    sw t2, 0 * 4(a0)
    /* x3 - gp */
    sw t0, 1 * 4(a0)
    /* x4 - tp */
    sw t0, 2 * 4(a0)
    /* x5 - t0 */
    sw t0, 3 * 4(a0)
    /* x6 - t1 */
    sw t0, 4 * 4(a0)
    /* x7 - t2 */
    sw t0, 5 * 4(a0)
    /* x10 - a0 = pvParameters */
    sw a2, 6 * 4(a0)
    /* x11 - a1 */
    sw t0, 7 * 4(a0)
    /* x12 - a2 */
    sw t0, 8 * 4(a0)
    /* x13 - a3 */
    sw t0, 9 * 4(a0)
    /* x14 - a4 */
    sw t0, 10 * 4(a0)
    /* x15 - a5 */
    sw t0, 11 * 4(a0)
    /* x16 - a6 */
    sw t0, 12 * 4(a0)
    /* x17 - a7 */
    sw t0, 13 * 4(a0)
    /* x18 - s0 */
    sw t0, 14 * 4(a0)
    /* x19 - s1 */
    sw t0, 15 * 4(a0)
    /* x20 - s2 */
    sw t0, 16 * 4(a0)
    /* x21 - s3 */
    sw t0, 17 * 4(a0)
    /* x22 - s4 */
    sw t0, 18 * 4(a0)
    /* x23 - s5 */
    sw t0, 19 * 4(a0)
    /* x24 - s6 */
    sw t0, 20 * 4(a0)
    /* x25 - s7 */
    sw t0, 21 * 4(a0)
    /* x26 - s8 */
    sw t0, 22 * 4(a0)
    /* x27 - s9 */
    sw t0, 23 * 4(a0)
    /* x28 - s10 */
    sw t0, 24 * 4(a0)
    /* x29 - s11 */
    sw t0, 25 * 4(a0)
    /* x30 - t3 */
    sw t0, 26 * 4(a0)
    /* x31 - t4 */
    sw t0, 27 * 4(a0)
    /* x8 - t5 */
    sw t0, 28 * 4(a0)
    /* x9 - t6 */
    sw t0, 29 * 4(a0)
    
    /* critical nesting */
    sw t0, 30 * 4(a0)
    
    /* === 0x1102: Выход из pxPortInitialiseStack === */
    li t1, 0x10010000
    li t0, 0x00001102
    sw t0, 0(t1)
    
    ret

/* ============================================ */
.global xPortStartFirstTask
xPortStartFirstTask:
    li t1, 0x10010000
    li t0, 0x00000666
    sw t0, 0(t1)
    
    li t1, 0x10010000
    li t0, 0x00000667
    sw t0, 0(t1)
    
    la t0, pxCurrentTCB
    lw t0, 0(t0)           /* t0 = pxCurrentTCB */
    lw sp, 0(t0)           /* sp = pxTopOfStack */
    
    /* === 0x777: Стек загружен === */
    li t1, 0x10010000
    li t0, 0x00000777
    sw t0, 0(t1)
    
    /* === 0x778: Показываем адрес из стека (должен совпадать с 0x1101) === */
    li t1, 0x10010000
    lw t0, 0 * 4(sp)       /* Читаем адрес задачи из стека */
    sw t0, 0(t1)           /* Показываем в GPIO! */
    
    /* Восстанавливаем регистры */
    lw ra,  0 * 4(sp)      /* x1 - адрес задачи */
    lw gp,  1 * 4(sp)      /* x3 */
    lw tp,  2 * 4(sp)      /* x4 */
    lw t0,  3 * 4(sp)      /* x5 */
    lw t1,  4 * 4(sp)      /* x6 */
    lw t2,  5 * 4(sp)      /* x7 */
    lw a0,  6 * 4(sp)      /* x10 - pvParameters */
    lw a1,  7 * 4(sp)      /* x11 */
    lw a2,  8 * 4(sp)      /* x12 */
    lw a3,  9 * 4(sp)      /* x13 */
    lw a4,  10 * 4(sp)     /* x14 */
    lw a5,  11 * 4(sp)     /* x15 */
    lw a6,  12 * 4(sp)     /* x16 */
    lw a7,  13 * 4(sp)     /* x17 */
    lw s0,  14 * 4(sp)     /* x18 */
    lw s1,  15 * 4(sp)     /* x19 */
    lw s2,  16 * 4(sp)     /* x20 */
    lw s3,  17 * 4(sp)     /* x21 */
    lw s4,  18 * 4(sp)     /* x22 */
    lw s5,  19 * 4(sp)     /* x23 */
    lw s6,  20 * 4(sp)     /* x24 */
    lw s7,  21 * 4(sp)     /* x25 */
    lw s8,  22 * 4(sp)     /* x26 */
    lw s9,  23 * 4(sp)     /* x27 */
    lw s10, 24 * 4(sp)     /* x28 */
    lw s11, 25 * 4(sp)     /* x29 */
    lw t3,  26 * 4(sp)     /* x30 */
    lw t4,  27 * 4(sp)     /* x31 */
    lw t5,  28 * 4(sp)     /* x8 */
    lw t6,  29 * 4(sp)     /* x9 */
    
    /* === 0x888: Перед jalr === */
    li t1, 0x10010000
    li t0, 0x00000888
    sw t0, 0(t1)

    jalr x0, ra, 0
    
    /* === 0x999: После jalr (недостижимо) === */
    li t1, 0x10010000
    li t0, 0x00000999
    sw t0, 0(t1)
1:  j 1b