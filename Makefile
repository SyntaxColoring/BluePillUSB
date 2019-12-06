TOOLCHAIN_PREFIX := arm-none-eabi-
CC := $(TOOLCHAIN_PREFIX)gcc
LD := $(CC)
AS := $(CC)
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
STM32LOADER := stm32loader
STM32LOADER_PORT := /dev/tty.usbserial-1410

Image.bin: Image.elf
	$(OBJCOPY) --output-target=binary $^ $@

Image.elf: Blinky.o
	$(LD) $< $(LDFLAGS) -nostdlib -o $@

Blinky.o: Blinky.s
	$(AS) -mcpu=cortex-m3 -c -o $@ $(ASFLAGS) $<

.PHONY: clean
clean:
	$(RM) Blinky.o
	$(RM) Image.elf
	$(RM) Image.bin

.PHONY: push
push: Image.bin
	$(STM32LOADER) -p $(STM32LOADER_PORT) -f F1 -ewv $^
