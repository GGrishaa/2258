#include <stdint.h>
#include <stddef.h>
#include "FreeRTOS.h"
#include "task.h"

#define GPIO_BASE       0x10010000
#define GPIO_OUT        (*(volatile uint32_t *)GPIO_BASE)

static volatile int task1_iterations = 0;

static void vTestTask(void *pvParameters)
{
    (void)pvParameters;

    GPIO_OUT = 0xBBBB0000;
    for (volatile int i = 0; i < 10000; i++) { __asm volatile("nop"); }
    
    for (;;) {
        GPIO_OUT = 0xAAAA0000;

        task1_iterations++;
        if (task1_iterations % 50 == 0) {
            GPIO_OUT = task1_iterations & 0xFFF;
            for (volatile int i = 0; i < 1000; i++) { __asm volatile("nop"); }
        }
        else for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
        
        GPIO_OUT = 0xDDDD0000;
        for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    }
}

static void vTestTask2(void *pvParameters)
{
    (void)pvParameters;
    
    GPIO_OUT = 0x0000CCCC;
    for (volatile int i = 0; i < 10000; i++) { __asm volatile("nop"); }
    
    for (;;) {
        GPIO_OUT = 0x0000EEEE;
        for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
        GPIO_OUT = 0x0000FFFF;
        for (volatile int i = 0; i < 100; i++) { __asm volatile("nop"); }
    }
}

int main(void)
{
    TaskHandle_t xHandle1 = NULL;
    TaskHandle_t xHandle2 = NULL;
    
    GPIO_OUT = 0x00000001;  /* Вход в main */
    
    /* Создаём ПЕРВУЮ задачу */
    xTaskCreate(vTestTask, "Test1", configMINIMAL_STACK_SIZE, NULL, 1, &xHandle1);
    GPIO_OUT = 0x00000002;  /* После создания Task1 */
    
    /* Создаём ВТОРУЮ задачу */
    xTaskCreate(vTestTask2, "Test2", configMINIMAL_STACK_SIZE, NULL, 1, &xHandle2);
    GPIO_OUT = 0x00000003;  /* После создания Task2 */

    vTaskStartScheduler();
    
    GPIO_OUT = 0x000000FF;  /* Сюда не дойдём */
    for (;;);
}
