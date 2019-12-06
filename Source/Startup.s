.syntax unified
.thumb

@ Minimal interrupt vector table, according to TRM 5.9.1.
@ "a" so the section takes up space.
.section startup_interrupt_vector_table, "a"
.4byte 0x20005000 @ Initial top of stack.
.4byte main       @ Reset vector.
.4byte spin       @ Non-maskable interrupt handler.
.4byte spin       @ Hard fault handler.


.text

.thumb_func
startup:
	@ Copy .data from ROM to RAM.
	ldr r0, =image_data_ram_origin
	ldr r1, =image_data_ram_end
	ldr r2, =image_data_rom_origin
data_copy_loop:
	cmp r0, r1
	ittt lo
	ldrblo r3, [r0], 1
	strblo r3, [r2], 1
	blo data_copy_loop
	
	@ Zero out the part of RAM corresponding to .bss.
	ldr r0, =image_bss_ram_origin
	ldr r1, =image_bss_ram_end
	mov r2, 0
bss_copy_loop:
	cmp r0, r1
	itt lo
	strblo r2, [r0], 1
	blo bss_copy_loop
	
	@ Jump into C.
	ldr r0, =main
	bx r0
	
	@ In case main() ever returns.
	b spin
	
.thumb_func
spin:
	b spin
