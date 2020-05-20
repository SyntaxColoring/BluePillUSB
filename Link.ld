
MEMORY
{
	/*
	To do: These sections should have flags (like "r" for read-only), but I don't fully understand
	the flags' meanings and implications yet.
	*/
	rom : ORIGIN = 0x0,        LENGTH = 64k
	ram : ORIGIN = 0x20000000, LENGTH = 20k
}


SECTIONS
{
	startup_interrupt_vector_table :
	{
		*(startup_interrupt_vector_table)
	} >rom AT>rom

	/* 
	Standard ELF sections, from the ELF specification.  This is far from comprehensive.  If you pass
	LDFLAGS=-Wl,--orphan-handling=warn to make, you can see a bunch of sections that this listing
	doesn't account for.
	*/

	.rodata :
	{
		*(.rodata)
	} >rom AT>rom

	.data :
	{
		*(.data)
	} >ram AT>rom

	.text :
	{
		*(.text)
	} >rom AT>rom

	.bss :
	{
		*(.bss)
	} >ram
	
	image_data_ram_origin = ADDR(.data);
	image_data_ram_end = image_data_ram_origin + SIZEOF(.data);
	image_data_rom_origin = LOADADDR(.data);
	
	image_bss_ram_origin = ADDR(.bss);
	image_bss_ram_end = image_bss_ram_origin + SIZEOF(.bss);
}
