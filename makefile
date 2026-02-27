firm = firmware
risc_dir = /opt/homebrew/
all:
	~/riscv-gnu-toolchain/installed-tools/bin/riscv32-unknown-elf-gcc -I$(risc_dir)/riscv-gnu-toolchain/binutils/gprofng/src -I$(risc_dir)/riscv-gnu-toolchain/binutils/gprofng/common -I$(risc_dir)/riscv-gnu-toolchain/binutils/include -Os -ffreestanding -nostdlib -o ./firmware/firmware.elf          ./firmware/firmware.S ./firmware/$(firm).c           --std=gnu99 -Wl,-Bstatic,-T,./firmware/firmware.lds,-Map,firmware.map,--strip-debug -lgcc
	~/riscv-gnu-toolchain/installed-tools/bin/riscv32-unknown-elf-objcopy -O binary ./firmware/firmware.elf ./firmware/firmware.bin
	python3 ./firmware/makehex.py ./firmware/firmware.bin 4096 > ./firmware/firmware.hex
	mv ./firmware/firmware.hex firmware.mem
