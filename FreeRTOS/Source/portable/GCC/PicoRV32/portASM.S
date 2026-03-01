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
    
    /* === 0x430: Перед переключением контекста === */
    li t1, 0x10010000
    li t0, 0x00000430
    sw t0, 0(t1)

    la t0, pxCurrentTCB
    lw t0, 0(t0)
    li t1, 0x10010000
    sw t0, 0(t1)  
    
    /* Вызываем переключатель контекста */
    call vTaskSwitchContext
    
    /* === 0x431: После переключения контекста === */
    li t1, 0x10010000
    li t0, 0x00000431
    sw t0, 0(t1)

    la t0, pxCurrentTCB
    lw t0, 0(t0)
    li t1, 0x10010000
    sw t0, 0(t1)

    la t0, pxCurrentTCB
    lw t0, 0(t0)           /* t0 = pxCurrentTCB */

    li t1, 0x10010000
    sw t0, 0(t1)           /* <-- Покажи адрес TCB */
    
    lw sp, 0(t0)           /* sp = pxTopOfStack */

    li t1, 0x10010000
    li t0, 0x00000433
    sw t0, 0(t1)
    
    /* Восстанавливаем регистры */
    lw ra,   0*4(sp)
    lw gp,   1*4(sp)
    lw tp,   2*4(sp)
    lw t0,   3*4(sp)
    lw t1,   4*4(sp)
    lw t2,   5*4(sp)
    lw a0,   6*4(sp)
    lw a1,   7*4(sp)
    lw a2,   8*4(sp)
    lw a3,   9*4(sp)
    lw a4,  10*4(sp)
    lw a5,  11*4(sp)
    lw a6,  12*4(sp)
    lw a7,  13*4(sp)
    lw s0,  14*4(sp)
    lw s1,  15*4(sp)
    lw s2,  16*4(sp)
    lw s3,  17*4(sp)
    lw s4,  18*4(sp)
    lw s5,  19*4(sp)
    lw s6,  20*4(sp)
    lw s7,  21*4(sp)
    lw s8,  22*4(sp)
    lw s9,  23*4(sp)
    lw s10, 24*4(sp)
    lw s11, 25*4(sp)
    lw t3,  26*4(sp)
    lw t4,  27*4(sp)
    lw t5,  28*4(sp)
    lw t6,  29*4(sp)
    
    li t1, 0x10010000
    li t0, 0x00000434
    sw t0, 0(t1)

    li t1, 0x10010000
    sw ra, 0(t1)
    
    li t1, 0x10010000
    sw sp, 0(t1)
    
    la t0, pxCurrentTCB
    lw t0, 0(t0)
    li t1, 0x10010000
    sw t0, 0(t1)

    /* Возврат в задачу */
    jalr x0, ra, 0

    li t1, 0x10010000
    li t0, 0x00000435
    sw t0, 0(t1)
1:  j 1b

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
    /* === 0x1100: Вход === */
    li t1, 0x10010000
    li t0, 0x00001100
    sw t0, 0(t1)
    
    /* Отладка: покажем входные параметры */
    li t1, 0x10010000
    sw a0, 0(t1)       /* a0 = pxTopOfStack (вершина) */
    li t1, 0x10010000
    sw a1, 0(t1)       /* a1 = pxCode (адрес задачи) */
    li t1, 0x10010000  
    sw a2, 0(t1)       /* a2 = pvParameters */
    
    /* 
     * Стек растёт вниз. 
     * pxTopOfStack (a0) — это максимальный адрес.
     * Записываем 32 регистра по 4 байта = 128 байт.
     * Смещения ОТРИЦАТЕЛЬНЫЕ: от вершины вниз.
     */
    
    li t0, 0  /* Значение "ноль" для большинства регистров */
    
    /* [31] x2/sp — сохраняем ИСХОДНУЮ вершину стека */
    sw a0, -1*4(a0)
    
    /* [30] critical nesting */
    sw t0, -2*4(a0)
    
    /* [29] x9/t6 */  sw t0, -3*4(a0)
    /* [28] x8/t5 */  sw t0, -4*4(a0)
    /* [27] x31/t4 */ sw t0, -5*4(a0)
    /* [26] x30/t3 */ sw t0, -6*4(a0)
    /* [25] x29/s11 */ sw t0, -7*4(a0)
    /* [24] x28/s10 */ sw t0, -8*4(a0)
    /* [23] x27/s9 */  sw t0, -9*4(a0)
    /* [22] x26/s8 */  sw t0, -10*4(a0)
    /* [21] x25/s7 */  sw t0, -11*4(a0)
    /* [20] x24/s6 */  sw t0, -12*4(a0)
    /* [19] x23/s5 */  sw t0, -13*4(a0)
    /* [18] x22/s4 */  sw t0, -14*4(a0)
    /* [17] x21/s3 */  sw t0, -15*4(a0)
    /* [16] x20/s2 */  sw t0, -16*4(a0)
    /* [15] x19/s1 */  sw t0, -17*4(a0)
    /* [14] x18/s0 */  sw t0, -18*4(a0)
    /* [13] x17/a7 */  sw t0, -19*4(a0)
    /* [12] x16/a6 */  sw t0, -20*4(a0)
    /* [11] x15/a5 */  sw t0, -21*4(a0)
    /* [10] x14/a4 */  sw t0, -22*4(a0)
    /* [9]  x13/a3 */  sw t0, -23*4(a0)
    /* [8]  x12/a2 */  sw t0, -24*4(a0)
    /* [7]  x11/a1 */  sw t0, -25*4(a0)
    /* [6]  x10/a0 = pvParameters */  sw a2, -26*4(a0)
    /* [5]  x7/t2 */   sw t0, -27*4(a0)
    /* [4]  x6/t1 */   sw t0, -28*4(a0)
    /* [3]  x5/t0 */   sw t0, -29*4(a0)
    /* [2]  x4/tp */   sw t0, -30*4(a0)
    /* [1]  x3/gp */   sw t0, -31*4(a0)
    /* [0]  x1/ra = entry point (адрес задачи) */  sw a1, -32*4(a0)
    
    /* === 0x1104: Выход === */
    li t1, 0x10010000
    li t0, 0x00001104
    sw t0, 0(t1)
    
    /* Возвращаем указатель на НИЖНЮЮ границу фрейма (где лежит ra) */
    addi a0, a0, -32*4
    ret

/* ============================================ */
.global xPortStartFirstTask
xPortStartFirstTask:
    /* === 0x666: Старт === */
    li t1, 0x10010000
    li t0, 0x00000666
    sw t0, 0(t1)
    
    /* Загружаем pxCurrentTCB и извлекаем pxTopOfStack */
    la t0, pxCurrentTCB
    lw t0, 0(t0)           /* t0 = pointer to TCB */
    lw sp, 0(t0)           /* sp = pxTopOfStack (теперь это НИЖНЯЯ граница фрейма) */
    
    /* === 0x777: Перед восстановлением === */
    li t1, 0x10010000
    li t0, 0x00000777
    sw t0, 0(t1)
    
    /* Восстанавливаем регистры (смещения ПОЛОЖИТЕЛЬНЫЕ от нижней границы) */
    lw ra,   0*4(sp)      /* x1/ra */
    lw gp,   1*4(sp)      /* x3/gp */
    lw tp,   2*4(sp)      /* x4/tp */
    lw t0,   3*4(sp)      /* x5/t0 */
    lw t1,   4*4(sp)      /* x6/t1 */
    lw t2,   5*4(sp)      /* x7/t2 */
    lw a0,   6*4(sp)      /* x10/a0 = pvParameters */
    lw a1,   7*4(sp)      /* x11/a1 */
    lw a2,   8*4(sp)      /* x12/a2 */
    lw a3,   9*4(sp)      /* x13/a3 */
    lw a4,  10*4(sp)      /* x14/a4 */
    lw a5,  11*4(sp)      /* x15/a5 */
    lw a6,  12*4(sp)      /* x16/a6 */
    lw a7,  13*4(sp)      /* x17/a7 */
    lw s0,  14*4(sp)      /* x18/s0 */
    lw s1,  15*4(sp)      /* x19/s1 */
    lw s2,  16*4(sp)      /* x20/s2 */
    lw s3,  17*4(sp)      /* x21/s3 */
    lw s4,  18*4(sp)      /* x22/s4 */
    lw s5,  19*4(sp)      /* x23/s5 */
    lw s6,  20*4(sp)      /* x24/s6 */
    lw s7,  21*4(sp)      /* x25/s7 */
    lw s8,  22*4(sp)      /* x26/s8 */
    lw s9,  23*4(sp)      /* x27/s9 */
    lw s10, 24*4(sp)      /* x28/s10 */
    lw s11, 25*4(sp)      /* x29/s11 */
    lw t3,  26*4(sp)      /* x30/t3 */
    lw t4,  27*4(sp)      /* x31/t4 */
    lw t5,  28*4(sp)      /* x8/t5 */
    lw t6,  29*4(sp)      /* x9/t6 */
    
    li t1, 0x10010000
    li t0, 0x00000669
    sw t0, 0(t1)
    
    li t1, 0x10010000
    sw ra, 0(t1)

    jalr x0, ra, 0
    
    /* === 0x999: Если вернулись (ошибка!) === */
    li t1, 0x10010000
    li t0, 0x00000999
    sw t0, 0(t1)
1:  j 1b

