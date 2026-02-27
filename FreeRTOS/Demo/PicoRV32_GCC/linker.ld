MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

ENTRY(main)

SECTIONS
{
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
    } > RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}