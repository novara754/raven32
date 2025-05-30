SECTIONS
{
    . = 0;
    .text : {
        *(.text*)
    }
    .data : {
        *(.data*)
        *(.rodata*)
    }
    .bss : {
        *(COMMON)
        *(.bss*)
    }
}
