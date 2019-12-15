#include "LED.h"

#include <stdint.h>
#include "RCC.h"

const uintptr_t GPIOC_BASE = 0x40011000;
const uintptr_t GPIO_CRH_OFFSET = 0x4;
const uintptr_t GPIO_ODR_OFFSET = 0xc;
const unsigned char CNF = 0x0; // General purpose, push-pull, output, maximum speed 10 MHz.
const unsigned char MODE = 0x1;

static const unsigned int GPIO_CRH_P13_SHIFT = 20;

static void enable_gpioc_clocking(void)
{
	const unsigned int RCC_APB2ENR_GPIOC_BIT = 4;
	rcc_enable_peripheral(RCC_BUS_APB2, RCC_APB2ENR_GPIOC_BIT, 1);
}

void led_initialize(void)
{
	enable_gpioc_clocking();
	
	volatile uint32_t* const gpioc_crh = (volatile uint32_t*)(GPIOC_BASE+GPIO_CRH_OFFSET);
	
	// Set CRH[GPIO_CRH_P13_SHIFT+3:GPIO_CRH_P13] to CNF,MODE.
	uint32_t crh_scratch = *gpioc_crh;
	crh_scratch &= ~((uint32_t)0xf << GPIO_CRH_P13_SHIFT);
	crh_scratch |= (uint32_t)((CNF<<2)|MODE) << GPIO_CRH_P13_SHIFT;
	*gpioc_crh = crh_scratch;
}

void led_set_state(bool on)
{
	volatile uint32_t* const gpioc_odr = (volatile uint32_t*)(GPIOC_BASE+GPIO_ODR_OFFSET);
	*gpioc_odr = on ? 0 : 1<<13;
}
