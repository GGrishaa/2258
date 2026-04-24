#include "FreeRTOS.h"
#include "task.h"
#include <stdint.h>

#define GPIO (*(volatile uint32_t*)0x03000010)

void vTaskBlink1(void *pv) {
    for(;;) {
        GPIO = 0xAAAAAAAA;
        for(int d=0; d<2000; d++);
        GPIO = 0xAAAAFFFF;
        for(int t=0; t<2000; t++);
    }
}

void vTaskBlink2(void *pv) {
    for(;;) {
        GPIO = 0x22222222;
        for(int d=0; d<2000; d++);
        GPIO = 0x22222200;
        for(int t=0; t<2000; t++);
    }
}

void vTaskBlink3(void *pv) {
    for(;;) {
        GPIO = 0xCCCCCCCC;
        for(int d=0; d<2000; d++);
        GPIO = 0xCCCCCCCD;
        for(int t=0; t<2000; t++);
    }
}

int main(void) {
    GPIO = 0xBBBBBBBB;
    xTaskCreate(vTaskBlink1, "B1", 256, NULL, 1, NULL);
    xTaskCreate(vTaskBlink2, "B2", 256, NULL, 1, NULL);
    xTaskCreate(vTaskBlink3, "B3", 256, NULL, 1, NULL);
    vTaskStartScheduler();
    GPIO = 0xDEADDEAD;
    for(;;);
}