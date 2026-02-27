#include <stdint.h>
#include "FreeRTOS.h"
#include "task.h"

#define GPIO_BASE       0x10010000
#define GPIO_OUT        (*(volatile uint32_t *)GPIO_BASE)

#define TASK1_PRIORITY  2
#define TASK2_PRIORITY  1
#define TASK1_PERIOD_MS 200
#define TASK2_PERIOD_MS 500
#define TASK1_BIT       0
#define TASK2_BIT       1

static void delay_ms(uint32_t ms)
{
    volatile uint32_t delay = configCPU_CLOCK_HZ / 1000 * ms;
    while (delay--) { __asm volatile(""); }
}

static void vTask1(void *pvParameters)
{
    (void)pvParameters;
    for (;;) {
        GPIO_OUT ^= (1 << TASK1_BIT);
        delay_ms(TASK1_PERIOD_MS);
    }
}

static void vTask2(void *pvParameters)
{
    (void)pvParameters;
    for (;;) {
        GPIO_OUT ^= (1 << TASK2_BIT);
        delay_ms(TASK2_PERIOD_MS);
    }
}

int main(void)
{
    xTaskCreate(vTask1, "Task1", configMINIMAL_STACK_SIZE, NULL, TASK1_PRIORITY, NULL);
    xTaskCreate(vTask2, "Task2", configMINIMAL_STACK_SIZE, NULL, TASK2_PRIORITY, NULL);

    vTaskStartScheduler();

    for (;;);
    return 0;
}