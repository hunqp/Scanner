/*
******************************************************************************
**
**  File        : stm32xx_ld.ld
**
**  Author		: HungPNQ
**
**  Abstract    : Linker script for STM32L151C8T6 series
**                64Kbytes FLASH and 16Kbytes RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32 Application
*****************************************************************************
*/

ENTRY	(Reset_Handler)

/* Specify the memory areas */
MEMORY {
	FLASH (rx)	: ORIGIN = 0x08000000, LENGTH = 64K
	SRAM (rwx)	: ORIGIN = 0x20000000, LENGTH = 16K
}

/* Heap memory size */
HEAP_SIZE = 512;

/* Define output sections */
SECTIONS {
	. = ALIGN(4);

	/* Start of FLASH */
	.start_flash : {
		_start_flash = .;
	} > FLASH

	/* The startup code goes first into FLASH */
	.isr_vector : {
		_isr_vector = .;
		KEEP(*(.isr_vector))
		. = ALIGN(4);
	} > FLASH

	/* The program code and other data goes into FLASH */
	.text : {
		*(.text)
		*(.text*)
		*(.rodata)
		*(.rodata*)
		*(.glue_7) /* glue arm to thumb */
		*(.glue_7t)/* glue thumb to arm */

		KEEP (*(.init))
		KEEP (*(.fini))

		_etext = .;
	} > FLASH

	/* Constructor data for object C++ */
	.preinit_array : {
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP (*(SORT(.preinit_array.*)))
		KEEP (*(.preinit_array*))
		PROVIDE_HIDDEN (__preinit_array_end = .);
	} > FLASH

	.init_array : {
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array*))
		PROVIDE_HIDDEN (__init_array_end = .);
	} > FLASH

	.fini_array : {
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP (*(.fini_array*))
		KEEP (*(SORT(.fini_array.*)))
		PROVIDE_HIDDEN (__fini_array_end = .);
	} > FLASH

	/* End of FLASH */
	.end_flash : {
		_end_flash = .;
	} > FLASH

	/* Start SRAM */
	.start_ram : {
		_start_ram = . ;
	} > SRAM

	/* Initialized data sections goes into RAM, load LMA copy after code */
	.data : AT(_end_flash) {
		_data = .;
		_ldata = LOADADDR (.data);
		*(vtable)
		*(.data)
		*(.data*)
		*(.RamFunc)
		*(.RamFunc*)
		_edata = .;
	} > SRAM

	/* Non clear RAM */
	.non_clear_ram : {
		_non_clear_ram = .;
		KEEP (*(.non_clear_ram))
		KEEP (*(.non_clear_ram*))
		_enon_clear_ram = .;
	} > SRAM

	/* Uninitialized data section */
	.bss : {
		_bss = .;
		*(.bss)
		*(.bss*)
		*(COMMON)
		_ebss = .;
	} > SRAM

	/* User_heap_stack section, used to check that there is enough RAM left */
	.heap : {
		__heap_start__ = . ;
		. = . + HEAP_SIZE;
		. = ALIGN(4);
		__heap_end__ = . ;
	} > SRAM

	/* End of SRAM */
	.end_ram : {
		_end_ram = . ;
	} > SRAM

	_estack = ORIGIN(SRAM) + LENGTH(SRAM);

	/* Remove information from the standard libraries */
	/DISCARD/ : {
		libc.a ( * )
		libm.a ( * )
		libg.a ( * )
		libgcc.a ( * )
	}
}

