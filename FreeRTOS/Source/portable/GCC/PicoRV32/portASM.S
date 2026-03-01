.section .text.reset
.align 2
.global _start

_start:
    jal ra, _init_stack
    . = 0x00000010;

/* ============================================ */
/* ОБРАБОТЧИК ПРЕРЫВАНИЙ */
/* ============================================ */
.section .text.freertos_risc_v_trap_handler
.align 4
.global freertos_risc_v_trap_handler
freertos_risc_v_trap_handler:
    /* === 0x400: Вход === */
    li t1, 0x10010000
    li t0, 0x00000400
    sw t0, 0(t1)
    
    /* 1. Переключаемся на ISR-стек */
    la t0, xISRStackTop
    lw sp, 0(t0)
    addi sp, sp, -128
    
    /* 2. Сохраняем ВСЕ регистры (ПОРЯДОК ВАЖЕН!) */
    /* Индекс 0 = ra, Индекс 31 = t6 */
    sw ra,  0*4(sp)
    sw gp,  1*4(sp)
    sw tp,  2*4(sp)
    sw t0,  3*4(sp)
    sw t1,  4*4(sp)
    sw t2,  5*4(sp)
    sw a0,  6*4(sp)
    sw a1,  7*4(sp)
    sw a2,  8*4(sp)
    sw a3,  9*4(sp)
    sw a4, 10*4(sp)
    sw a5, 11*4(sp)
    sw a6, 12*4(sp)
    sw a7, 13*4(sp)
    sw s0, 14*4(sp)
    sw s1, 15*4(sp)
    sw s2, 16*4(sp)
    sw s3, 17*4(sp)
    sw s4, 18*4(sp)
    sw s5, 19*4(sp)
    sw s6, 20*4(sp)
    sw s7, 21*4(sp)
    sw s8, 22*4(sp)
    sw s9, 23*4(sp)
    sw s10, 24*4(sp)
    sw s11, 25*4(sp)
    sw t3, 26*4(sp)
    sw t4, 27*4(sp)
    sw t5, 28*4(sp)
    sw t6, 29*4(sp)
    sw zero, 30*4(sp)
    sw zero, 31*4(sp)
    
    /* === 0x410: Сохранено === */
    li t1, 0x10010000
    li t0, 0x00000410
    sw t0, 0(t1)
    
    /* 3. Вызываем обработчик тика */
    call vPortTickHandler

    li t1, 0x10010000
    li t0, 0x44444444
    sw t0, 0(t1)
    
    /* 4. Переключаем контекст */
    //li a0, 0
    //call vTaskSwitchContext
    
    /* === 0x431: После переключения === */
    li t1, 0x10010000
    li t0, 0x00000431
    sw t0, 0(t1)
    
    /* 5. Загружаем стек НОВОЙ задачи */
    la t0, pxCurrentTCB
    lw t0, 0(t0)
    lw sp, 0(t0)           /* sp = pxTopOfStack (указывает на ra) */
    
    /* === 0x440: Загрузили стек === */
    li t1, 0x10010000
    li t0, 0x00000440
    sw t0, 0(t1)
    
    /* 6. Восстанавливаем ВСЕ регистры */
    lw ra,  0*4(sp)
    lw gp,  1*4(sp)
    lw tp,  2*4(sp)
    lw t0,  3*4(sp)
    lw t1,  4*4(sp)
    lw t2,  5*4(sp)
    lw a0,  6*4(sp)
    lw a1,  7*4(sp)
    lw a2,  8*4(sp)
    lw a3,  9*4(sp)
    lw a4, 10*4(sp)
    lw a5, 11*4(sp)
    lw a6, 12*4(sp)
    lw a7, 13*4(sp)
    lw s0, 14*4(sp)
    lw s1, 15*4(sp)
    lw s2, 16*4(sp)
    lw s3, 17*4(sp)
    lw s4, 18*4(sp)
    lw s5, 19*4(sp)
    lw s6, 20*4(sp)
    lw s7, 21*4(sp)
    lw s8, 22*4(sp)
    lw s9, 23*4(sp)
    lw s10, 24*4(sp)
    lw s11, 25*4(sp)
    lw t3, 26*4(sp)
    lw t4, 27*4(sp)
    lw t5, 28*4(sp)
    lw t6, 29*4(sp)
    
    /* 7. Корректируем sp (сдвигаем на 128 байт вверх) */
    addi sp, sp, 128
    
    /* === 0x460: Перед возвратом === */
    li t1, 0x10010000
    li t0, 0x00000460
    sw t0, 0(t1)
    
    /* === 0x461: ПОКАЗЫВАЕМ ra ПЕРЕД ПРЫЖКОМ === */
    li t1, 0x10010000
    sw ra, 0(t1)
    
    /* 8. Возврат в задачу */
    jalr x0, ra, 0
    
1:  j 1b

/* ============================================ */
/* ИНИЦИАЛИЗАЦИЯ СТЕКА ЗАДАЧИ */
/* ============================================ */
.section .text
.global pxPortInitialiseStack
pxPortInitialiseStack:
    /* === 0x1100: Вход === */
    li t1, 0x10010000
    li t0, 0x00001100
    sw t0, 0(t1)
    
    li t1, 0x10010000
    sw a0, 0(t1)       /* pxTopOfStack */
    li t1, 0x10010000
    sw a1, 0(t1)       /* pxCode (адрес задачи) */
    li t1, 0x10010000  
    sw a2, 0(t1)       /* pvParameters */
    
    li t0, 0
    
    
    /* [31] t6 (верх стека) */  sw t0, -1*4(a0)
    /* [30] t5 */               sw t0, -2*4(a0)
    /* [29] t4 */               sw t0, -3*4(a0)
    /* [28] t3 */               sw t0, -4*4(a0)
    /* [27] s11 */              sw t0, -5*4(a0)
    /* [26] s10 */              sw t0, -6*4(a0)
    /* [25] s9 */               sw t0, -7*4(a0)
    /* [24] s8 */               sw t0, -8*4(a0)
    /* [23] s7 */               sw t0, -9*4(a0)
    /* [22] s6 */               sw t0, -10*4(a0)
    /* [21] s5 */               sw t0, -11*4(a0)
    /* [20] s4 */               sw t0, -12*4(a0)
    /* [19] s3 */               sw t0, -13*4(a0)
    /* [18] s2 */               sw t0, -14*4(a0)
    /* [17] s1 */               sw t0, -15*4(a0)
    /* [16] s0 */               sw t0, -16*4(a0)
    /* [15] a7 */               sw t0, -17*4(a0)
    /* [14] a6 */               sw t0, -18*4(a0)
    /* [13] a5 */               sw t0, -19*4(a0)
    /* [12] a4 */               sw t0, -20*4(a0)
    /* [11] a3 */               sw t0, -21*4(a0)
    /* [10] a2 */               sw t0, -22*4(a0)
    /* [9]  a1 */               sw t0, -23*4(a0)
    /* [8]  a0 = pvParameters */ sw a2, -24*4(a0)
    /* [7]  t2 */               sw t0, -25*4(a0)
    /* [6]  t1 */               sw t0, -26*4(a0)
    /* [5]  t0 */               sw t0, -27*4(a0)
    /* [4]  tp */               sw t0, -28*4(a0)
    /* [3]  gp */               sw t0, -29*4(a0)
    /* [2]  sp */               sw a0, -30*4(a0)
    /* [1]  ra = entry point */ sw a1, -31*4(a0)  /* ← АДРЕС ЗАДАЧИ */
    /* [0]  zero (НИЗ ФРЕЙМА) */ sw zero, -32*4(a0)
    
    /* === 0x1104: Выход === */
    li t1, 0x10010000
    li t0, 0x00001104
    sw t0, 0(t1)
    
    /* Возвращаем указатель на НИЖНЮЮ границу (где лежит zero) */
    /* При загрузке sp будет указывать сюда, а lw ra, 0*4(sp) прочитает zero */
    /* ОЙ! Это неверно! Нам нужно чтобы lw ra, 0*4(sp) прочитал ra! */
    /* Значит возвращаем адрес ячейки С ra, то есть -31*4 */
    
    addi a0, a0, -31*4
    ret

/* ============================================ */
/* ЗАПУСК ПЕРВОЙ ЗАДАЧИ */
/* ============================================ */
.global xPortStartFirstTask
xPortStartFirstTask:
    li t1, 0x10010000
    li t0, 0x00000666
    sw t0, 0(t1)
    
    la t0, pxCurrentTCB
    lw t0, 0(t0)
    lw sp, 0(t0)           /* sp = возвращённое значение pxPortInitialiseStack */
    
    li t1, 0x10010000
    li t0, 0x00000777
    sw t0, 0(t1)
    
    /* Восстанавливаем регистры */
    lw ra,  0*4(sp)        /* Должен прочитать ra (адрес задачи) */
    lw gp,  1*4(sp)
    lw tp,  2*4(sp)
    lw t0,  3*4(sp)
    lw t1,  4*4(sp)
    lw t2,  5*4(sp)
    lw a0,  6*4(sp)
    lw a1,  7*4(sp)
    lw a2,  8*4(sp)
    lw a3,  9*4(sp)
    lw a4, 10*4(sp)
    lw a5, 11*4(sp)
    lw a6, 12*4(sp)
    lw a7, 13*4(sp)
    lw s0, 14*4(sp)
    lw s1, 15*4(sp)
    lw s2, 16*4(sp)
    lw s3, 17*4(sp)
    lw s4, 18*4(sp)
    lw s5, 19*4(sp)
    lw s6, 20*4(sp)
    lw s7, 21*4(sp)
    lw s8, 22*4(sp)
    lw s9, 23*4(sp)
    lw s10, 24*4(sp)
    lw s11, 25*4(sp)
    lw t3, 26*4(sp)
    lw t4, 27*4(sp)
    lw t5, 28*4(sp)
    lw t6, 29*4(sp)
    
    /* Корректируем sp (сдвигаем на 128 байт вверх от низа фрейма) */
    addi sp, sp, 128
    
    li t1, 0x10010000
    li t0, 0x00000669
    sw t0, 0(t1)
    
    li t1, 0x10010000
    sw ra, 0(t1)
    
    jalr x0, ra, 0
    
1:  j 1b

/* ============================================ */
/* ИНИЦИАЛИЗАЦИЯ СТЕКА (C-часть) */
/* ============================================ */
.section .text.init
_init_stack:
    lui sp, %hi(0x00008000)
    addi sp, sp, %lo(0x00008000)
    call main
1:  j 1b

/* ============================================ */
/* ЭКСПОРТЫ */
/* ============================================ */
.extern xCriticalNesting
.extern pxCriticalNesting
.extern xISRStackTop
.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern vPortTickHandler