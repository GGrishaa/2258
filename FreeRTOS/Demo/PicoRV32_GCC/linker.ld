MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

ENTRY(_start)

SECTIONS
{
    /* Вектор сброса - начинается с 0x00000000 */
    .text.reset 0x00000000 : {
        *(.text.reset)
    } > RAM

    /* Вектор прерываний - СТРОГО по адресу 0x00000010 */
    .text.irq 0x00000010 : {
        *(.text.freertos_risc_v_trap_handler)
    } > RAM

    /* Основной код начинается после векторов */
    .text : {
        *(.text.init)
        *(.text .text.*)
        *(.rodata .rodata.*)
    } > RAM

    .data : {
        *(.data .data.*)
    } > RAM

    .bss : {
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(16);
        _heap_end = .;
    } > RAM

    _stack_top = 0x00008000;
    PROVIDE(_stack_top_addr = _stack_top);
}