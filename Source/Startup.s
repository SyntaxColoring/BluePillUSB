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
main:
@ To do: Enable APB2 bus, enable and configure GPIOC.
	b spin

.thumb_func
spin:
	b spin
