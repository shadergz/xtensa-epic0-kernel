ENTRY(call_start_cpu0);

MEMORY
{
	iram_seg ( RX ) : ORIGIN = 0x40080400, len = 0xFC00
	dram_seg ( RW ) : ORIGIN = 0x3FFF0000, len = 0x1000
}

SECTIONS {
	.iram.text :
	{
		. = ALIGN(16);
		KEEP(*(.entry.text))
		*(.text)
		*(.text*)
		KEEP (*(.init))
		KEEP (*(.fini))
		*(.rodata)
		*(.rodata*)

		. = ALIGN(4);
		_etext = .;
	} >iram_seg

	_sidata = .;
	.data : AT(_sidata) 
	{
		. = ALIGN(4);
    		_sdata = .;
		*(.data)
		*(.data*)

    		. = ALIGN(4);
    		_edata = .;
	} >dram_seg

	.bss :
	{
		. = ALIGN(4);
		_sbss = .;
		*(.bss)
		*(.bss*)
		*(COMMON)

		. = ALIGN(4);
		_ebss = .;
	} >dram_seg

	. = ALIGN(4);
	PROVIDE ( end = . );
	PROVIDE ( _end = . );
}

