#include <stdint.h>
#include <stddef.h>
#include "FreeRTOS.h"
#include "task.h"

#define GPIO_BASE       0x10010000
#define GPIO_OUT        (*(volatile uint32_t *)GPIO_BASE)

static void vTestTask(void *pvParameters)
{
    (void)pvParameters;
    
    /* === 0xBBBB: Вход в задачу === */
    GPIO_OUT = 0x0000BBBB;
    
    for (;;) {
        GPIO_OUT = 0x0000AAAA;
        
        /* Задержка */
        for (volatile int i = 0; i < 100000; i++) { __asm volatile("nop"); }
    }
}

void vApplicationIdleHook(void)
{
    static int count = 0;
    if (count++ % 1000 == 0) {
        GPIO_OUT = 0x0000CCCC;  /* Idle Task работает! */
    }
}

int main(void)
{
    TaskHandle_t xHandle = NULL;
    
    /* === 0x0001: Вход в main === */
    GPIO_OUT = 0x00000001;
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* === 0x0010: Перед xTaskCreate === */
    GPIO_OUT = 0x00000010;
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* Создаем задачу */
    BaseType_t xReturn = xTaskCreate(
        vTestTask,
        "Test",
        configMINIMAL_STACK_SIZE,
        NULL,
        1,
        &xHandle
    );
    
    /* === 0x0020 или 0x00EE: После xTaskCreate === */
    if (xReturn == pdPASS) {
        GPIO_OUT = 0x00000020;
    } else {
        GPIO_OUT = 0x000000EE;
    }
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* === 0x0030: Перед планировщиком === */
    GPIO_OUT = 0x00000030;
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* === 0x0040: Запуск планировщика === */
    GPIO_OUT = 0x00000040;
    vTaskStartScheduler();
    
    /* === 0x00FF: Планировщик вернулся (плохо!) === */
    GPIO_OUT = 0x000000FF;
    for (;;);
    
    return 0;
}