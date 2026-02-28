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
size_t xCriticalNesting = 0xaaaaaaaa;
size_t *pxCriticalNesting = &xCriticalNesting;

/*-----------------------------------------------------------*/

/* Стек для прерываний */
static __attribute__((aligned(16))) StackType_t xISRStack[256];
const StackType_t xISRStackTop = (StackType_t)&xISRStack[256];

/*-----------------------------------------------------------*/

extern void freertos_risc_v_trap_handler(void);

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
void vPortTickHandler(void)
{
    BaseType_t xSwitchRequired;
    
    /* Сброс pending бита таймера PicoRV32 (CSR 0xcc2) */
    __asm volatile("csrw 0xcc2, zero");
    
    /* Инкремент системного тика */
    xSwitchRequired = xTaskIncrementTick();
    
    /* Переключение задачи если нужно */
    if( xSwitchRequired != pdFALSE )
    {
        portYIELD_FROM_ISR( xSwitchRequired );
    }
}

/*-----------------------------------------------------------*/

void vPortSetupTimerInterrupt(void)
{
    __asm volatile("csrw 0x305, %0" :: "r"(&freertos_risc_v_trap_handler));
    
    __asm volatile("csrw 0xcc1, %0" :: "r"(0x00000001));
    
    uint32_t timer_period = configCPU_CLOCK_HZ / configTICK_RATE_HZ;
    __asm volatile("csrw 0xcc0, %0" :: "r"(timer_period));
    
    __asm volatile("csrs mstatus, %0" :: "r"(0x00000008));
    __asm volatile("csrs mie, %0" :: "r"(0x00000001));
}


/* Запуск первой задачи */
void vPortStartFirstTask(void)
{
    /* === ОТЛАДКА: перед mret === */
    #define GPIO_OUT (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000800;  /* Bit 11 */
    for (volatile int i = 0; i < 50; i++) { __asm volatile("nop"); }
    /* ============================ */

    __asm volatile("csrs mstatus, %0" :: "r"(0x00000008));
    __asm volatile("mret");
}

/*-----------------------------------------------------------*/

/* Запуск планировщика */
BaseType_t xPortStartScheduler(void)
{
    #define GPIO_OUT (*(volatile uint32_t *)0x10010000)
    
    /* Маркер: вход в xPortStartScheduler */
    GPIO_OUT = 0x00000600;  /* Bit 10+9 */
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }

    vPortSetupTimerInterrupt();
    
    /* Маркер: перед vPortStartFirstTask */
    GPIO_OUT = 0x00000700;  /* Bit 10+9+8 */
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }

    vPortStartFirstTask();  /* ← здесь вызывается mret */
    
    /* Если вернётся — ошибка */
    GPIO_OUT = 0x00000EEE;  /* ОШИБКА: mret вернулся */
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    return pdFAIL;
}

/*-----------------------------------------------------------*/

void vPortEndScheduler(void)
{
    /* Не поддерживается */
}