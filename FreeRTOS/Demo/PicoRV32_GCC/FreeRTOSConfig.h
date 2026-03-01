#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

#define configUSE_PREEMPTION              1
#define configUSE_IDLE_HOOK               0
#define configUSE_TICK_HOOK               0
#define configCPU_CLOCK_HZ                10000000
#define configTICK_RATE_HZ                100
#define configMAX_PRIORITIES              5
#define configMINIMAL_STACK_SIZE          128
#define configTOTAL_HEAP_SIZE             4096
#define configMAX_TASK_NAME_LEN           16
#define configUSE_16_BIT_TICKS            0
#define configIDLE_SHOULD_YIELD           1
#define configUSE_TIME_SLICING            1

#define configUSE_MUTEXES                 0
#define configUSE_RECURSIVE_MUTEXES       0
#define configUSE_COUNTING_SEMAPHORES     0
#define configUSE_QUEUE_SETS              0

#define configSUPPORT_STATIC_ALLOCATION   0
#define configSUPPORT_DYNAMIC_ALLOCATION  1
//#define configNUMBER_OF_CORES             1
#define configCHECK_FOR_STACK_OVERFLOW    0
#define configUSE_TRACE_FACILITY          0
#define configGENERATE_RUN_TIME_STATS     0

#define configMTIME_BASE_ADDRESS          0
#define configMTIMECMP_BASE_ADDRESS       0

#define configUSE_TIMERS                  0
#define configTIMER_TASK_PRIORITY         0
#define configTIMER_QUEUE_LENGTH          0
#define configTIMER_TASK_STACK_DEPTH      0
#define configUSE_PORT_OPTIMISED_TASK_SELECTION    0

#endif /* FREERTOS_CONFIG_H */