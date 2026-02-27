firm = firmware
risc_dir = /opt/homebrew/
all:
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Os -ffreestanding -nostdlib -o ./firmware/firmware.elf ./firmware/firmware.S ./firmware/$(firm).c --std=gnu99 -Wl,-Bstatic,-T,./firmware/firmware.lds,-Map,firmware.map,--strip-debug -lgcc
	riscv64-unknown-elf-objcopy -O binary ./firmware/firmware.elf ./firmware/firmware.bin
	python3 ./firmware/makehex.py ./firmware/firmware.bin 4096 > ./firmware/firmware.hex
	mv ./firmware/firmware.hex firmware.mem
	./sim_make.sh

clean:
	rm -f firmware.elf firmware.bin firmware.mem firmware.map
	rm -f qqq system.vcd

rebuild: clean all