#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

/*---------------------------------------------------------------------------*/
/* Основные настройки планировщика                                           */
/*---------------------------------------------------------------------------*/
#define configUSE_PREEMPTION                    1
#define configUSE_TIME_SLICING                  1
#define configUSE_IDLE_HOOK                     0
#define configUSE_TICK_HOOK                     0

/* Частота симуляции 100 МГц (при переходе на железо поменять на 12 МГц)    */
#define configCPU_CLOCK_HZ                      ( 100000000UL )

/* Частота системного тика (1000 Гц → период 1 мс)                           */
#define configTICK_RATE_HZ                      ( 1000 )

#define configMAX_PRIORITIES                    ( 5 )
#define configMINIMAL_STACK_SIZE                ( ( unsigned short ) 256 )
#define configTOTAL_HEAP_SIZE                   ( ( size_t ) ( 24 * 1024 ) )
#define configMAX_TASK_NAME_LEN                 ( 16 )
#define configUSE_16_BIT_TICKS                  0
#define configIDLE_SHOULD_YIELD                 1

/*---------------------------------------------------------------------------*/
/* Синхронизация и уведомления                                               */
/*---------------------------------------------------------------------------*/
#define configUSE_MUTEXES                       1
#define configUSE_RECURSIVE_MUTEXES             0
#define configUSE_COUNTING_SEMAPHORES           1
#define configUSE_QUEUE_SETS                    0
#define configUSE_TASK_NOTIFICATIONS            1

#define configSUPPORT_STATIC_ALLOCATION         0
#define configSUPPORT_DYNAMIC_ALLOCATION        1

/*---------------------------------------------------------------------------*/
/* Отладка                                                                   */
/*---------------------------------------------------------------------------*/
#define configCHECK_FOR_STACK_OVERFLOW          2
#define configGENERATE_RUN_TIME_STATS           0
#define configUSE_TRACE_FACILITY                0

/*---------------------------------------------------------------------------*/
/* Адреса таймера PicoRV32 (из picosoc.v)                                    */
/*---------------------------------------------------------------------------*/
#define configMTIME_BASE_ADDRESS        0x03000000UL
#define configMTIMECMP_BASE_ADDRESS     0x03000008UL

/*---------------------------------------------------------------------------*/
/* Файл расширений чипа                                                      */
/*---------------------------------------------------------------------------*/
#define configCHIP_SPECIFIC_EXTENSIONS_HEADER \
    "chip_specific_extensions/PicoRV32/freertos_risc_v_chip_specific_extensions.h"

/*---------------------------------------------------------------------------*/
/* Программные таймеры (не нужны)                                            */
/*---------------------------------------------------------------------------*/
#define configUSE_TIMERS                        0
#define configTIMER_TASK_PRIORITY               0
#define configTIMER_QUEUE_LENGTH                0
#define configTIMER_TASK_STACK_DEPTH            0

/*---------------------------------------------------------------------------*/
/* Оптимизация выбора задачи                                                 */
/*---------------------------------------------------------------------------*/
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 0

/*---------------------------------------------------------------------------*/
/* Assert                                                                    */
/*---------------------------------------------------------------------------*/
/* Если assert сработает - запишем 0xFFFFFFFF в GPIO и зависнем */
#define configASSERT( x ) \
    if( ( x ) == 0 ) { \
        (*(volatile uint32_t*)0x03000010) = 0xFFFFFFFF; \
        taskDISABLE_INTERRUPTS(); \
        for( ;; ); \
    }

/*---------------------------------------------------------------------------*/
/* Включаемые функции API                                                    */
/*---------------------------------------------------------------------------*/
#define INCLUDE_vTaskPrioritySet                1
#define INCLUDE_uxTaskPriorityGet               1
#define INCLUDE_vTaskDelete                     1
#define INCLUDE_vTaskSuspend                    1
#define INCLUDE_vTaskDelayUntil                 1
#define INCLUDE_vTaskDelay                      1
#define INCLUDE_xTaskGetCurrentTaskHandle       1
#define portasmHAS_MTIME                        1

#endif /* FREERTOS_CONFIG_H */