TOOLCHAIN_PREFIX := arm-none-eabi-
CC := $(TOOLCHAIN_PREFIX)gcc
LD := $(CC)
AS := $(CC)
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
STM32LOADER := stm32loader
STM32LOADER_PORT := /dev/tty.usbserial-1410

Blinky.bin: Blinky.elf
	$(OBJCOPY) --output-target=binary $^ $@

Blinky.elf: Blinky.o
	$(LD) $< $(LDFLAGS) -Ttext=0x0 -nostdlib -o $@

Blinky.o: Blinky.s
	$(AS) -mcpu=cortex-m3 -c -o $@ $(ASFLAGS) $<

.PHONY: clean
clean:
	$(RM) Blinky.o
	$(RM) Blinky.elf
	$(RM) Blinky.bin

.PHONY: push-blinky
push-blinky: Blinky.bin
	$(STM32LOADER) -p $(STM32LOADER_PORT) -f F1 -ewv $^
