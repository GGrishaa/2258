#include <stdint.h>
#include "FreeRTOS.h"
#include "task.h"

#define GPIO_BASE       0x10010000
#define GPIO_OUT        (*(volatile uint32_t *)GPIO_BASE)

static void vTestTask(void *pvParameters)
{
    (void)pvParameters;
    for (;;) {
        GPIO_OUT = 0x0000AAAA;
    }
}

int main(void)
{
    TaskHandle_t xHandle = NULL;
    
    /* Маркер 1: вход в main */
    GPIO_OUT = 0x00000001;
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* Маркер 2: перед xTaskCreate */
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
    
    /* Маркер 3: после xTaskCreate */
    if (xReturn == pdPASS) {
        GPIO_OUT = 0x00000020;
    } else {
        GPIO_OUT = 0x000000EE;
    }
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    /* Маркер 4: перед планировщиком */
    GPIO_OUT = 0x00000030;
    for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    
    vTaskStartScheduler();
    
    /* Если вернется */
    GPIO_OUT = 0x000000FF;
    for (;;);
    return 0;
}