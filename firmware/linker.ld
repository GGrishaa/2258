/* firmware/linker.ld */
OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    /* 
     * СЕКЦИЯ ВЕКТОРОВ:
     * Мы принудительно размещаем конкретные секции по конкретным адресам.
     */
    .text 0x0 : {
        *(.text.reset_vector)
        
        . = 0x10;
        
        *(.text.irq_vector)
        
        *(.text.real_start)
        
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : {
        *(.data*)
        *(.sdata*)
    } > RAM

    .bss : {
        _sbss = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        _ebss = .;
    } > RAM
    
    /* Стек в конце памяти */
    _estack = 0x00010000;
    __freertos_irq_stack_top = _estack - 1024;
}