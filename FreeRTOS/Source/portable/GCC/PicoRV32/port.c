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
    
    GPIO_OUT = 0x00000501;

    xSwitchRequired = xTaskIncrementTick();
    GPIO_OUT = (uint32_t)xSwitchRequired;
    GPIO_OUT = 0x00000502;
    
    /* Переключение задачи если нужно */
    if( xSwitchRequired != pdFALSE )
    {
        GPIO_OUT = 0x00000502A;
        portYIELD_FROM_ISR( xSwitchRequired );
        GPIO_OUT = 0x00000502B;
    } else {
        GPIO_OUT = 0x00000502C;
    }
    GPIO_OUT = 0x00000503;
}

/*-----------------------------------------------------------*/

void vPortSetupTimerInterrupt(void)
{
    #define GPIO_OUT (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000100;

    __asm volatile(".word 0x0600000B");

    GPIO_OUT = 0x00000101;
    
    GPIO_OUT = 0x00000300;
}

/*-----------------------------------------------------------*/

/* Запуск планировщика */
BaseType_t xPortStartScheduler(void)
{
    GPIO_OUT = 0x00000440;
    
    vPortSetupTimerInterrupt();
    
    GPIO_OUT = 0x00000441;
    
    GPIO_OUT = 0x00000442;
    xPortStartFirstTask();
    
    GPIO_OUT = 0x00000443;
    return pdFAIL;
}

/*-----------------------------------------------------------*/

void vPortEndScheduler(void)
{
    /* Не поддерживается */
}