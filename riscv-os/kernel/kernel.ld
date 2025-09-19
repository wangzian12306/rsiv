OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS {
    . = 0x80200000;
    
    .text : {
        *(.text.entry)
        *(.text .text.*)
    }
    
    .rodata : {
        *(.rodata .rodata.*)
    }
    
    .data : {
        *(.data .data.*)
    }
    
    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    }
    
    .stack : {
        *(.bss.stack)
    }
    
    PROVIDE(etext = .);
    PROVIDE(edata = .);
    PROVIDE(end = .);
}

