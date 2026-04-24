#include "portContext.h"

#if defined( portasmHAS_CLINT ) && defined( portasmHAS_MTIME )
    #error The portasmHAS_CLINT constant has been deprecated.
#endif

#ifdef portasmHAS_CLINT
    #warning The portasmHAS_CLINT constant has been deprecated.
    #define portasmHAS_MTIME portasmHAS_CLINT
    #define portasmHAS_SIFIVE_CLINT portasmHAS_CLINT
#endif

#ifndef portasmHAS_MTIME
    #error freertos_risc_v_chip_specific_extensions.h must define portasmHAS_MTIME
#endif

#ifndef portasmHAS_SIFIVE_CLINT
    #define portasmHAS_SIFIVE_CLINT 0
#endif

.global xPortStartFirstTask
.global freertos_risc_v_trap_handler
.global freertos_risc_v_exception_handler
.global freertos_risc_v_interrupt_handler
.global freertos_risc_v_mtimer_interrupt_handler

.extern vTaskSwitchContext
.extern xTaskIncrementTick
.extern pullMachineTimerCompareRegister
.extern pullNextTime
.extern uxTimerIncrementsForOneTick
.extern xTaskReturnAddress
.extern pxCurrentTCB
.extern pxCriticalNesting

.weak freertos_risc_v_application_exception_handler
.weak freertos_risc_v_application_interrupt_handler

.macro portUPDATE_MTIMER_COMPARE_REGISTER
    load_x a0, pullMachineTimerCompareRegister
    load_x a1, pullNextTime

    #if( __riscv_xlen == 32 )
        li a4, -1
        lw a2, 0(a1)
        lw a3, 4(a1)
        sw a4, 0(a0)
        sw a3, 4(a0)
        sw a2, 0(a0)
        lw t0, uxTimerIncrementsForOneTick
        add a4, t0, a2
        sltu t1, a4, a2
        add t2, a3, t1
        sw a4, 0(a1)
        sw t2, 4(a1)
    #endif

    #if( __riscv_xlen == 64 )
        ld t2, 0(a1)
        sd t2, 0(a0)
        ld t0, uxTimerIncrementsForOneTick
        add t4, t0, t2
        sd t4, 0(a1)
    #endif
.endm

xPortStartFirstTask:
    lw    sp, pxCurrentTCB
    lw    sp, 0(sp)

    lw    x1,  0(sp)
    lw    x5,  12(sp)
    lw    x6,  16(sp)
    lw    x7,  20(sp)
    lw    x8,  24(sp)
    lw    x9,  28(sp)
    lw    x10, 32(sp)
    lw    x11, 36(sp)
    lw    x12, 40(sp)
    lw    x13, 44(sp)
    lw    x14, 48(sp)
    lw    x15, 52(sp)
#ifndef __riscv_32e
    lw    x16, 56(sp)
    lw    x17, 60(sp)
    lw    x18, 64(sp)
    lw    x19, 68(sp)
    lw    x20, 72(sp)
    lw    x21, 76(sp)
    lw    x22, 80(sp)
    lw    x23, 84(sp)
    lw    x24, 88(sp)
    lw    x25, 92(sp)
    lw    x26, 96(sp)
    lw    x27, 100(sp)
    lw    x28, 104(sp)
    lw    x29, 108(sp)
    lw    x30, 112(sp)
    lw    x31, 116(sp)
#endif
    lw    x5, 120(sp)
    lw    x6, pxCriticalNesting
    sw    x5, 0(x6)

    addi  sp, sp, 128
    jr    x1

