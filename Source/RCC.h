/**
 * RCC: Reset and Clock Control.
 **/

#include <stdbool.h>

enum RCCBus
{
	// These values are the RCC_APB1ENR/RCC_APB2ENR register offsets from the RCC base address.
	RCC_BUS_APB1 = 0x1c,
	RCC_BUS_APB2 = 0x18
};

// Enables clocking to a peripheral.
// - bus is which bus the peripheral is on.  Consult the system architecture diagram in RM0008 section 3.1.
// - peripheral_number is the bit number corresponding to that peripheral in the RCC_APB1ENR or RCC_APB2ENR register.
//   Consult RM0008 sections 7.3.7 and 7.3.8.
void rcc_enable_peripheral(enum RCCBus bus, unsigned peripheral_number, bool enable);
