CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

OBJS = start.o hello.o

.PHONY: all
all: hello.hex hello.d

.PHONY: clean
clean:
	rm -f hello.d hello.hex hello.bin hello.elf *.o

%.o: %.S
	$(CC) -march=rv32i -mabi=ilp32 -c -o $@ $<

%.o: %.rs
	rustc --target riscv32i-unknown-none-elf -Copt-level=s --emit=obj $<

hello.elf: linker.ld $(OBJS)
	$(CC) -march=rv32i -mabi=ilp32 -Tlinker.ld -ffreestanding -nostdlib -Os -o $@ $(OBJS)

hello.bin: hello.elf
	$(OBJCOPY) -j .text -j .data -j .bss -O binary $< $@

hello.hex: hello.bin ../scripts/bin2hex.py
	python3 ../scripts/bin2hex.py $<

hello.d: hello.elf
	$(OBJDUMP) -d $< > $@
