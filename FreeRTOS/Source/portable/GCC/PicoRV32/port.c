/*
 * FreeRTOS Port for PicoRV32
 */

#include <stdlib.h>
#include <stdint.h>
#include "FreeRTOS.h"
#include "task.h"
#include "portmacro.h"

/*-----------------------------------------------------------*/

/* Критическая секция */
size_t xCriticalNesting = 0;
size_t *pxCriticalNesting = &xCriticalNesting;

/*-----------------------------------------------------------*/

/* Стек для прерываний */
static __attribute__((aligned(16))) StackType_t xISRStack[256];
const StackType_t xISRStackTop = (StackType_t)&xISRStack[256];

/*-----------------------------------------------------------*/

extern void freertos_risc_v_trap_handler(void);
extern void xPortStartFirstTask(void);

/* Заглушки для memcpy/memset (freestanding) */
void *memcpy(void *dest, const void *src, size_t n) {
    char *d = (char *)dest;
    const char *s = (const char *)src;
    while (n--) *d++ = *s++;
    return dest;
}

void *memset(void *s, int c, size_t n) {
    char *p = (char *)s;
    while (n--) *p++ = (char)c;
    return s;
}

/*-----------------------------------------------------------*/

/* Обработчик прерывания таймера PicoRV32 */
/*-----------------------------------------------------------*/

/* Обработчик прерывания таймера PicoRV32 */
void vPortTickHandler(void)
{
    BaseType_t xSwitchRequired;
    
    /* === 0x500: Вход в vPortTickHandler === */
    #define GPIO_OUT (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000500;
    
    /* ПЕРЕЗАГРУЗКА таймера (не авто-перезагружается!) */
    const uint32_t timer_period = configCPU_CLOCK_HZ / configTICK_RATE_HZ;
    /* Инструкция: timer x0, t0 */
    /* Encoding: funct7=0x05, rs1=t0(5), rd=x0(0), opcode=0x0B */
    __asm volatile(
        "mv t0, %0\n\t"      /* Копируем период в t0 */
        ".word 0x0A00200B\n\t"  /* timer x0, t0 */
        :
        : "r"(timer_period)
        : "t0"
    );
    
    GPIO_OUT = 0x00000501;
    
    /* Инкремент системного тика */
    xSwitchRequired = xTaskIncrementTick();
    
    GPIO_OUT = 0x00000502;
    
    /* Переключение задачи если нужно */
    if( xSwitchRequired != pdFALSE )
    {
        portYIELD_FROM_ISR( xSwitchRequired );
    }
    
    GPIO_OUT = 0x00000503;
}

/*-----------------------------------------------------------*/

void vPortSetupTimerInterrupt(void)
{
    #define GPIO_OUT (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000100;
    
    /* Рассчитываем период таймера: CPU_CLK / TICK_RATE */
    const uint32_t timer_period = configCPU_CLOCK_HZ / configTICK_RATE_HZ;
    /* Для 10 MHz / 100 Hz = 100000 тактов */
    
    /* Загружаем период через кастомную инструкцию timer */
    /* Инструкция: timer x0, t0 */
    __asm volatile(
        "mv t0, %0\n\t"      /* Копируем период в t0 */
        ".word 0x0A00200B\n\t"  /* timer x0, t0 */
        :
        : "r"(timer_period)
        : "t0"
    );
    
    GPIO_OUT = 0x00000101;
    
    /* Разрешаем глобальные прерывания через кастомную инструкцию maskirq */
    /* Encoding: 0x06000013 = maskirq x0 (разрешить все IRQ) */
    __asm volatile(".word 0x06000013");
    
    GPIO_OUT = 0x00000300;
}
#if 0
void vPortStartFirstTask(void)
{
    #define GPIO_OUT        (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000666;
    uint32_t ulCurrentTCB;
    uint32_t ulTopOfStack;
    uint32_t ulEntryPoint;
    
    /* Получаем адрес текущего TCB */
    __asm volatile ( "lw %0, pxCurrentTCB" : "=r" (ulCurrentTCB) );

    /* Первый элемент TCB - это pxTopOfStack */
    __asm volatile ( "lw %0, 0(%1)" : "=r" (ulTopOfStack) : "r" (ulCurrentTCB) );

    /* Читаем entry point из стека (смещение 31 * 4 байта) */
    __asm volatile ( "lw %0, 124(%1)" : "=r" (ulEntryPoint) : "r" (ulTopOfStack) );

    /* Записываем в mepc */
    __asm volatile ( "csrw mepc, %0" :: "r" (ulEntryPoint) );
    GPIO_OUT = 0x00000AAA;
    /* Включаем MIE в mstatus */
    __asm volatile ( "csrs mstatus, %0" :: "r" (0x00000008) );
    GPIO_OUT = 0x00000BBB;
    /* Возврат в задачу */
    __asm volatile ( "mret" );
    GPIO_OUT = 0x00000CCC;
    /* Недостижимый код */
    for (;;);
    GPIO_OUT = 0x00000DDD;
}
#endif

/*-----------------------------------------------------------*/

/* Запуск планировщика */
BaseType_t xPortStartScheduler(void)
{

    vPortSetupTimerInterrupt();
    #define GPIO_OUT        (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000444;
    xPortStartFirstTask();
    GPIO_OUT = 0x00000555;
    return pdFAIL;
}

/*-----------------------------------------------------------*/

void vPortEndScheduler(void)
{
    /* Не поддерживается */
}