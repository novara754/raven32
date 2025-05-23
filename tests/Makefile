CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

TEST_OBJS = $(addsuffix .o, $(basename $(notdir $(wildcard insts/*.S))))

$(info TEST_OBJS = $(TEST_OBJS))

.PHONY: all
all: firmware.hex firmware.d

.PHONY: clean
clean:
	rm -f firmware.d firmware.hex firmware.bin firmware.elf start.o $(TEST_OBJS)

start.o: start.S
	$(CC) -march=rv32i -mabi=ilp32 -c -o $@ $<

%.o: insts/%.S insts/riscv_test.h insts/test_macros.h
	$(CC) -march=rv32i -mabi=ilp32 -c -o $@ -I. \
	-DTEST_FUNC_NAME='"$(notdir $(basename $<))"' -DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

firmware.elf: linker.ld start.o $(TEST_OBJS)
	$(CC) -march=rv32i -mabi=ilp32 -Tlinker.ld -ffreestanding -nostdlib -o $@ start.o $(TEST_OBJS)

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin bin2hex.py
	python3 bin2hex.py $<

firmware.d: firmware.elf
	$(OBJDUMP) -M numeric -d $< > $@
