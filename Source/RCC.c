#include "RCC.h"

#include <stdint.h>

const uintptr_t RCC_BASE = 0x40021000;

void rcc_enable_peripheral(const enum RCCBus bus, const unsigned peripheral_number, const bool enable)
{
	// RCC_APB1ENR or RCC_APB2ENR depending on the value of bus.
	volatile uint32_t* const rcc_apbenr = (uint32_t*)(RCC_BASE+bus);
	
	uint32_t mask = 1 << peripheral_number;
	
	if (enable) *rcc_apbenr |= mask;
	else *rcc_apbenr &= ~mask;
}
