#include <stdint.h>

void enable_gpioc_clocking(void)
{
	const uintptr_t RCC_BASE = 0x40021000;
	const uintptr_t RCC_APB2ENR_OFFSET = 0x18;
	const unsigned int RCC_APB2ENR_GPIOC_BIT = 4;
	
	volatile uint32_t* const rcc_apb2enr = (uint32_t*)(RCC_BASE+RCC_APB2ENR_OFFSET);
	
	*rcc_apb2enr = 1<<RCC_APB2ENR_GPIOC_BIT;
}

void turn_on_pc13(void)
{
	const uintptr_t GPIOC_BASE = 0x40011000;
	const uintptr_t GPIO_CRH_OFFSET = 0x4;
	const uintptr_t GPIO_ODR_OFFSET = 0xc;
	const unsigned char CNF = 0x0; // General purpose, push-pull, output, maximum speed 10 MHz.
	const unsigned char MODE = 0x1;
	
	const unsigned int GPIO_CRH_P13_SHIFT = 20;
	
	volatile uint32_t* const gpioc_crh = (uint32_t*)(GPIOC_BASE+GPIO_CRH_OFFSET);
	volatile uint32_t* const gpioc_odr = (uint32_t*)(GPIOC_BASE+GPIO_ODR_OFFSET);
	
	// Set CRH[GPIO_CRH_P13_SHIFT+3:GPIO_CRH_P13] to CNF,MODE.
	uint32_t crh_scratch = *gpioc_crh;
	crh_scratch &= ~((uint32_t)0xf << GPIO_CRH_P13_SHIFT);
	crh_scratch |= (uint32_t)((CNF<<2)|MODE) << GPIO_CRH_P13_SHIFT;
	*gpioc_crh = crh_scratch;
	
	// Enable all pins.  Only P13 is configured as output, so that's the only one that's affected.
	*gpioc_odr = 0x0000;
}

void main(void)
{
	enable_gpioc_clocking();
	turn_on_pc13();
}