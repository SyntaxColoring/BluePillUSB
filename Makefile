TOOLCHAIN_PREFIX := arm-none-eabi-
CC := $(TOOLCHAIN_PREFIX)gcc
LD := $(CC)
AS := $(CC)
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
STM32LOADER := stm32loader
STM32LOADER_PORT := /dev/tty.usbserial-1410

SOURCE_DIRECTORY := Source

C_SOURCES := $(shell find $(SOURCE_DIRECTORY) -name '*.c')
C_OBJECTS := $(C_SOURCES:.c=.o)
C_HEADER_DEPENDENCIES := $(C_SOURCES:.c=.d)

ASSEMBLY_SOURCES := $(shell find $(SOURCE_DIRECTORY) -name '*.s')
ASSEMBLY_OBJECTS := $(ASSEMBLY_SOURCES:.s=.o)

ALL_OBJECTS := $(C_OBJECTS) $(ASSEMBLY_OBJECTS)

Image.bin: Image.elf
	$(OBJCOPY) --output-target=binary $^ $@

Image.elf: $(ALL_OBJECTS) Link.ld
	$(LD) $(ALL_OBJECTS) $(LDFLAGS) -nostdlib -T Link.ld -o $@

$(C_OBJECTS): %.o: %.c %.d
	$(CC) -std=c11 -pedantic -Wall -Wextra -ffreestanding -Og -c -o $@ $(CFLAGS) $<

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

.PHONY: push
push: Image.bin
	$(STM32LOADER) -p $(STM32LOADER_PORT) -f F1 -ewv $^
