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
	@ Enable GPIOC clocking on the APB2 bus.
	.equ RCC_BASE, 0x40021000
	.equ RCC_APB2ENR_OFFSET, 0x18
	.equ RCC_APB2ENR_GPIOC_BIT, 4
	ldr r0, =(RCC_BASE+RCC_APB2ENR_OFFSET)
	ldr r1, =(1<<RCC_APB2ENR_GPIOC_BIT)
	str r1, [r0]
	
	@ Configure GPIO port C13.
	.equ GPIOC_BASE, 0x40011000
	.equ GPIO_CRH_OFFSET, 0x4
	.equ PC13_CNF_MODE, 0b0001 @ General purpose, push-pull, output, maximum speed 10 MHz.
	.equ GPIO_CRH_P13_SHIFT, 20 @ Index of the LSb of the [CNF,MODE] bits corresponding to port 13, in GPIOC_CRH.
	.equ GPIO_ODR_OFFSET, 0xc
	ldr r0, =(GPIOC_BASE+GPIO_CRH_OFFSET)
	ldr r1, [r0]
	mov r2, PC13_CNF_MODE
	bfi r1, r2, GPIO_CRH_P13_SHIFT, 4
	str r1, [r0]
	
	@ RM0008 7.2.6 "After a system reset, the HSI oscillator is selected as system clock."
	@ HSI is 8 MHz.  But, by default, the SysTick clock source is divided by 8 (PM0056 4.5.1).
	.equ CLOCKS_PER_SECOND, 1000000
	.equ CLOCKS_PER_STATE_CHANGE, CLOCKS_PER_SECOND / 4 @ 2 blinks per second.
	.equ STK_LOAD, 0xe000e014
	.equ STK_CTRL, 0xe000e010
	
	ldr r0, =STK_LOAD
	ldr r1, =CLOCKS_PER_STATE_CHANGE
	str r1, [r0]
	ldr r0, =STK_CTRL
	mov r1, 1
	str r1, [r0]
	
change_led_state:
	ldr r0, =STK_LOAD
wait_for_systick:
	ldr r1, [r0]
	tst r1, (1<<16)
	mov r1, 1
	str r1, [r0]
	beq wait_for_systick

	ldr r0, =(GPIOC_BASE+GPIO_ODR_OFFSET)
	ldr r1, [r0]
	eor r1, (1<<13)
	str r1, [r0]
	
.thumb_func
spin:
	b spin
