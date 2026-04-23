#ifndef __FREERTOS_RISC_V_EXTENSIONS_H__
#define __FREERTOS_RISC_V_EXTENSIONS_H__

#define portasmHAS_SIFIVE_CLINT           0
#define portasmHAS_MTIME                  1
#define portasmADDITIONAL_CONTEXT_SIZE    0

.macro portasmSAVE_ADDITIONAL_REGISTERS
   .endm

.macro portasmRESTORE_ADDITIONAL_REGISTERS
   .endm

#endif