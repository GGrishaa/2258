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
    #define GPIO_OUT        (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000100;
    
    GPIO_OUT = 0x00000200;  
    
    /* Отключаем несуществующие CSR таймера */
    /* __asm volatile("csrw 0xcc1, %0" :: "r"(0x00000001)); */
    /* __asm volatile("csrw 0xcc0, %0" :: "r"(timer_period)); */
    
    /* Включаем прерывания через PicoRV32 custom инструкцию maskirq */
    /* Encoding: funct7=0b0000011, rs1=x0 (маска 0), funct3=0, rd=0, opcode=0x13 */
    /* Это разрешает прерывания с маской 0 (все разрешены) */
    __asm volatile(".word 0x06000013");  /* maskirq x0 */
    
    GPIO_OUT = 0x00000300;
}


/* Запуск первой задачи */
void vPortStartFirstTask(void)
{
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
    
    /* Включаем MIE в mstatus */
    __asm volatile ( "csrs mstatus, %0" :: "r" (0x00000008) );
    
    /* Возврат в задачу */
    __asm volatile ( "mret" );
    
    /* Недостижимый код */
    for (;;);
}

/*-----------------------------------------------------------*/

/* Запуск планировщика */
BaseType_t xPortStartScheduler(void)
{

    vPortSetupTimerInterrupt();
    #define GPIO_OUT        (*(volatile uint32_t *)0x10010000)
    GPIO_OUT = 0x00000444;
    vPortStartFirstTask();
    GPIO_OUT = 0x00000555;
    return pdFAIL;
}

/*-----------------------------------------------------------*/

void vPortEndScheduler(void)
{
    /* Не поддерживается */
}