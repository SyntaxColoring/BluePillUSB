#include "UART.h"
#include <stdint.h>


static const uintptr_t USART1_BASE = 0x40013800;

static volatile uint32_t USART_SR = *(volatile uint32_t*)(USART1_BASE+0x00);
static volatile uint32_t USART_BRR = *(volatile uint32_t*)(USART1_BASE+)

static const ptrdiff_t USART_BRR_OFFSET = 0x08;

static const ptrdiff_t USART_CR1_OFFSET = 0x0c;
static const unsigned USART_CR1_UE_BIT = 13;
static const unsigned USART_CR1_TE_BIT = 3;


static volatile uint32_t USART_CR1 = *(volatile_uint32_t*)()


// Output a single byte on the USART1 peripheral.
//
// The byte is output with the following settings:
// - 8 data bits.
// - No parity bit.
// - 1 stop bit.
// 
// This function blocks until the byte has gone out on the wire.
void uart_write_byte(const uint8_t to_write)
{
	
}
