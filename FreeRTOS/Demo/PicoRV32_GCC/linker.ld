MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

ENTRY(_start)

SECTIONS
{
    .text.reset : {
        *(.text.reset)
        *(.text.startup)
    } > RAM

    .text : {
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
        _heap_end = .;  /* Конец BSS = начало кучи */
    } > RAM

    /* Явно вычисляем вершину стека: 0x00000000 + 32KB = 0x00008000 */
    _stack_top = 0x00008000;
    
    /* Символ для проверки в ассемблере */
    PROVIDE(_stack_top_addr = _stack_top);
}