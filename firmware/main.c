#include "FreeRTOS.h"
#include "task.h"
#include <stdint.h>

#define GPIO (*(volatile uint32_t*)0x03000010)

void vTaskBlink1(void *pv) {
    GPIO = 0xAAAAAAAA;
    for(;;) {
        GPIO ^= 0x1;
        volatile int d; for(d=0; d<100; d++);
    }
}

void vTaskBlink2(void *pv) {
    GPIO = 0x22222222;
    for(;;) {
        GPIO ^= (1 << 1);
        volatile int d; for(d=0; d<100; d++);
    }
}

int main(void) {
    GPIO = 0xBBBBBBBB;
    xTaskCreate(vTaskBlink1, "B1", 256, NULL, 1, NULL);
    xTaskCreate(vTaskBlink2, "B2", 256, NULL, 1, NULL);
    vTaskStartScheduler();
    GPIO = 0xDEADDEAD;
    for(;;);
}