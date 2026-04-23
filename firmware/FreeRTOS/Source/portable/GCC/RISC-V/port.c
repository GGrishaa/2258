#include "FreeRTOS.h"
#include "task.h"
#include "portmacro.h"
#include "../../../../../FreeRTOSConfig.h"
#include <string.h>

#define portasmADDITIONAL_CONTEXT_SIZE    0
#ifdef configCLINT_BASE_ADDRESS
    #warning "configCLINT_BASE_ADDRESS deprecated. Use configMTIME_BASE_ADDRESS."
#endif

#ifndef configMTIME_BASE_ADDRESS
    #warning "configMTIME_BASE_ADDRESS must be defined. Set to 0 if no timer."
#endif

#ifndef configMTIMECMP_BASE_ADDRESS
    #warning "configMTIMECMP_BASE_ADDRESS must be defined. Set to 0 if no timer."
#endif

#ifdef configTASK_RETURN_ADDRESS
    #define portTASK_RETURN_ADDRESS configTASK_RETURN_ADDRESS
#else
    #define portTASK_RETURN_ADDRESS 0
#endif

#define configISR_STACK_SIZE_WORDS 256
static __attribute__((aligned(16))) StackType_t xISRStack[configISR_STACK_SIZE_WORDS] = {0};
const StackType_t xISRStackTop = (StackType_t)&(xISRStack[configISR_STACK_SIZE_WORDS & ~portBYTE_ALIGNMENT_MASK]);
#define portISR_STACK_FILL_BYTE 0xee

uint64_t ullNextTime = 0ULL;
const uint64_t *pullNextTime = &ullNextTime;
const size_t uxTimerIncrementsForOneTick = (size_t)((configCPU_CLOCK_HZ) / (configTICK_RATE_HZ));
UBaseType_t const ullMachineTimerCompareRegisterBase = configMTIMECMP_BASE_ADDRESS;
volatile uint64_t *pullMachineTimerCompareRegister = NULL;

size_t xCriticalNesting = (size_t)0xaaaaaaaa;
size_t *pxCriticalNesting = &xCriticalNesting;
size_t xTaskReturnAddress = (size_t)portTASK_RETURN_ADDRESS;

void vPortSetupTimerInterrupt(void) __attribute__((weak));
extern void xPortStartFirstTask(void);

StackType_t *pxPortInitialiseStack(StackType_t *pxTopOfStack, TaskFunction_t pxCode, void *pvParameters)
{
    /* 🔍 МАРКЕР: какая задача инициализируется */
    (*(volatile uint32_t*)0x03000010) = 0x1000 | ((uint32_t)pxCode & 0xFFF);

    pxTopOfStack -= 32;
    pxTopOfStack = (StackType_t *)((uint32_t)pxTopOfStack & ~0xF);
    for(int i = 0; i < 32; i++) pxTopOfStack[i] = 0;

    pxTopOfStack[0]  = (StackType_t)pxCode;       /* sp[0]: PC */
    pxTopOfStack[1]  = (StackType_t)0x00001880;   /* mstatus */
    pxTopOfStack[2]  = (StackType_t)0;            /* x1 (ra) */
    pxTopOfStack[8]  = (StackType_t)pvParameters; /* x10 (a0) */
    pxTopOfStack[30] = (StackType_t)0;            /* Critical Nesting */
    
    return pxTopOfStack;
}

void vPortSetupTimerInterrupt(void)
{
    uint32_t period = (uint32_t)uxTimerIncrementsForOneTick;
    __asm__ volatile (
        "li a0, %0\n\t"
        ".word 0x0A05000B\n\t"
        : : "i"(period) : "a0"
    );
}

BaseType_t xPortStartScheduler(void)
{
    extern void xPortStartFirstTask(void);

    #if (configASSERT_DEFINED == 1)
    {
        configASSERT((xISRStackTop & portBYTE_ALIGNMENT_MASK) == 0);
        #ifdef configISR_STACK_SIZE_WORDS
        {
            memset((void *)xISRStack, portISR_STACK_FILL_BYTE, sizeof(xISRStack));
        }
        #endif
    }
    #endif

    vPortSetupTimerInterrupt();
    __asm__ volatile (".word 0x0600000B");  /* maskirq: разрешаем прерывания */
    xPortStartFirstTask();
    return pdFAIL;
}

void vPortEndScheduler(void)
{
    for (;;);
}