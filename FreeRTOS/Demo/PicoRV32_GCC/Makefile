CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy

SRC_DIR = ../../Source

CFLAGS = -march=rv32izicsr -mabi=ilp32 -Os -ffreestanding -nostdlib -Wall
CFLAGS += -I../../Source/include
CFLAGS += -I../../Source/portable/GCC/PicoRV32
CFLAGS += -I../../Source/portable/GCC/RISC-V/chip_specific_extensions/PicoRV32_CSR
CFLAGS += -I.

ASFLAGS = -march=rv32i -mabi=ilp32 -x assembler-with-cpp $(CFLAGS)
LDFLAGS = -nostdlib -Wl,-T,linker.ld,-Map=firmware.map

KERNEL_C = $(SRC_DIR)/tasks.c \
           $(SRC_DIR)/list.c \
           $(SRC_DIR)/queue.c \
           $(SRC_DIR)/portable/MemMang/heap_4.c \
           $(SRC_DIR)/portable/GCC/PicoRV32/port.c

KERNEL_S = $(SRC_DIR)/portable/GCC/PicoRV32/portASM.S

APP_C = main.c

OBJS = tasks.o list.o queue.o heap_4.o port.o portASM.o main.o

all: firmware.mem
	cp firmware.mem ../../../

firmware.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -lgcc

tasks.o: $(SRC_DIR)/tasks.c
	$(CC) $(CFLAGS) -c -o $@ $<

list.o: $(SRC_DIR)/list.c
	$(CC) $(CFLAGS) -c -o $@ $<

queue.o: $(SRC_DIR)/queue.c
	$(CC) $(CFLAGS) -c -o $@ $<

heap_4.o: $(SRC_DIR)/portable/MemMang/heap_4.c
	$(CC) $(CFLAGS) -c -o $@ $<

port.o: $(SRC_DIR)/portable/GCC/PicoRV32/port.c
	$(CC) $(CFLAGS) -c -o $@ $<

portASM.o: $(SRC_DIR)/portable/GCC/PicoRV32/portASM.S
	$(AS) $(ASFLAGS) -c -o $@ $<

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.mem: firmware.bin
	python3 ../../../firmware/makehex.py $< 4096 > $@

clean:
	rm -f $(OBJS) firmware.elf firmware.bin firmware.mem firmware.map
	clear

.PHONY: all clean