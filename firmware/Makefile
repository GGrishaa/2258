CROSS = riscv-none-elf-
CC = $(CROSS)gcc
AS = $(CROSS)gcc
LD = $(CROSS)ld
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump

CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -Os -ffunction-sections -fdata-sections -Wall -nostdlib
CFLAGS += -I./FreeRTOS/Source/include
CFLAGS += -I./FreeRTOS/Source/portable/GCC/RISC-V
CFLAGS += -I./FreeRTOS/Source/portable/GCC/RISC-V/chip_specific_extensions/PicoRV32
CFLAGS += -I.

ASFLAGS = $(CFLAGS)

LDFLAGS = -T linker.ld -nostdlib

SRC_C = main.c \
        FreeRTOS/Source/tasks.c \
        FreeRTOS/Source/queue.c \
        FreeRTOS/Source/list.c \
        FreeRTOS/Source/portable/MemMang/heap_4.c \
        FreeRTOS/Source/portable/GCC/RISC-V/port.c \
		utils.c

SRC_ASM = start.S \
          FreeRTOS/Source/portable/GCC/RISC-V/portASM.S

OBJ = $(SRC_C:.c=.o) $(SRC_ASM:.S=.o)

TARGET = firmware

all: $(TARGET).elf $(TARGET).bin $(TARGET).hex

$(TARGET).elf: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).bin
	hexdump -v -e '1/4 "%08x\n"' $< > $@

clean:
	rm -f $(OBJ) $(TARGET).elf $(TARGET).bin $(TARGET).hex
	clear

rebuild: clean all

.PHONY: all clean