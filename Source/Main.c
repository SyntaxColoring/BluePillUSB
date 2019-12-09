#include <stdbool.h>
#include <stdint.h>
#include "LED.h"

void sleep(unsigned long int clock_cycles)
{
	const uintptr_t STK_BASE = 0xe000e010;
	const uintptr_t STK_CTRL_OFFSET = 0x0;
	const uintptr_t STK_LOAD_OFFSET = 0x4;
	const uintptr_t STK_VAL_OFFSET = 0x8;
	
	volatile uint32_t* stk_ctrl = (volatile uint32_t*)(STK_BASE+STK_CTRL_OFFSET);
	volatile uint32_t* stk_load = (volatile uint32_t*)(STK_BASE+STK_LOAD_OFFSET);
	volatile uint32_t* stk_val = (volatile uint32_t*)(STK_BASE+STK_VAL_OFFSET);
	
	if ((clock_cycles & 0x00ffffff) != clock_cycles || !clock_cycles)
	{
		// This function doesn't account for when clock_cycles doesn't fit into a 24-bit value, or when it's 0.
		// Spin forever to make the problem more obvious if that ever happens.
		while (true) { }
	}
	
	*stk_ctrl = 0; // Disable ticking while we set things up.
	*stk_load = clock_cycles; // Set the value to be reloaded when stk_val rolls below 0.
	*stk_val = 0; // Make sure stk_val rolls over immediately.  It will have junk in it from the last time sleep() was called.
	*stk_ctrl = 1; // Enable ticking again.  This also chooses the clock source and chooses not to enable the interrupt.
	
	// Wait until COUNTFLAG is set, indicating stk_val rolled from 1 to 0.
	while (((*stk_ctrl >> 16) & 1) == 0) { }
}

void main(void)
{
	led_initialize();
	
	while (true)
	{
		led_set_state(true);
		sleep(100000);
		led_set_state(false);
		sleep(900000);
	}
}