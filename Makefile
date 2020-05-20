TOOLCHAIN_PREFIX := arm-none-eabi-
CC := $(TOOLCHAIN_PREFIX)gcc
LD := $(CC)
AS := $(CC)
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
STM32LOADER := stm32loader

# Try to autodetect the USB to UART adapter that's being used to program the device.
# When this variable is evaluated:
# - If SERIAL_PORT was given on the command line, use that.
# - Else, if there are any /dev/ttyUSB* (as seen on Ubuntu) or /dev/tty.usb* (as seen on macOS) devices, use one of those.
# - Else, quit with an error.
AUTODETECTED_SERIAL_PORT = $(or $(SERIAL_PORT), \
                                $(firstword $(wildcard /dev/ttyUSB*) $(wildcard /dev/tty.usb*)), \
                                $(error Couldn't find a USB UART adapter.  Make sure it's connected, or manually specify it with SERIAL_PORT))

SOURCE_DIRECTORY := .

C_SOURCES := $(shell find $(SOURCE_DIRECTORY) -name '*.c')
C_OBJECTS := $(C_SOURCES:.c=.o)
C_HEADER_DEPENDENCIES := $(C_SOURCES:.c=.d)

ASSEMBLY_SOURCES := $(shell find $(SOURCE_DIRECTORY) -name '*.s')
ASSEMBLY_OBJECTS := $(ASSEMBLY_SOURCES:.s=.o)

ALL_OBJECTS := $(C_OBJECTS) $(ASSEMBLY_OBJECTS)

Image.bin: Image.elf
	$(OBJCOPY) --output-target=binary $^ $@

Blinky.bin: Blinky.elf
	$(OBJCOPY) --output-target=binary $^ $@

Image.elf: $(ALL_OBJECTS) Link.ld
	$(LD) $(ALL_OBJECTS) $(LDFLAGS) -nostdlib -T Link.ld -o $@

Blinky.elf: Blinky.o
	$(LD) $< $(LDFLAGS) -Ttext=0x0 -nostdlib -o $@

$(C_OBJECTS): %.o: %.c %.d
	$(CC) -mcpu=cortex-m3 -mthumb -std=c11 -pedantic -Wall -Wextra -ffreestanding -Og -c -o $@ $(CFLAGS) $<

$(ASSEMBLY_OBJECTS): %.o: %.s
	$(AS) -mcpu=cortex-m3 -c -o $@ $(ASFLAGS) $<

# The sole dependency being %.c here only applies when the .d file is being made from scratch.
# If the .d file already exists, it will mention itself as a target that depends on the same headers
# that the .c file does.  This ensures that if one of the headers is modified in a way that changes
# the dependency tree, the .d file will be rebuilt to reflect that change.  (This is what the -MT option does.)
$(C_HEADER_DEPENDENCIES): %.d: %.c
	$(CC) -MM -MF $@ -MT '$*.o $@' $<

-include $(C_HEADER_DEPENDENCIES)

.PHONY: clean
clean:
	$(RM) $(SOURCE_DIRECTORY)/*.{o,d}
	$(RM) Image.elf
	$(RM) Image.bin
	$(RM) Blinky.o
	$(RM) Blinky.elf
	$(RM) Blinky.bin

.PHONY: push
push: Image.bin
	$(STM32LOADER) -p $(AUTODETECTED_SERIAL_PORT) -f F1 -ewv $^

.PHONY: push-blinky
push-blinky: Blinky.bin
	$(STM32LOADER) -p $(AUTODETECTED_SERIAL_PORT) -f F1 -ewv $^
