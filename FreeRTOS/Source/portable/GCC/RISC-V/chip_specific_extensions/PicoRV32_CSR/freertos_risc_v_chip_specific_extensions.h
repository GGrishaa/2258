#ifndef __FREERTOS_RISC_V_EXTENSIONS_H__
#define __FREERTOS_RISC_V_EXTENSIONS_H__

/* PicoRV32: нет стандартного CLINT (mtime/mtimecmp) */
#define portasmHAS_SIFIVE_CLINT     0
#define portasmHAS_MTIME            0

/* Дополнительные регистры контекста не требуются */
#define portasmADDITIONAL_CONTEXT_SIZE    0

/* Макросы-заглушки для сохранения/восстановления доп. регистров */
.macro portasmSAVE_ADDITIONAL_REGISTERS
    /* PicoRV32: нет дополнительных регистров для сохранения */
.endm

.macro portasmRESTORE_ADDITIONAL_REGISTERS
    /* PicoRV32: нет дополнительных регистров для восстановления */
.endm

#endif /* __FREERTOS_RISC_V_EXTENSIONS_H__ */