; Upon booting, a computer first enters the BIOS(Basic Input Output System)
; what a bios does is, it seraches throught the memory of bootable debices and loads it into the memory of 0x7c00 which is the Origin(ORG)
;   and then checks for this signature 0xAA55 to verify if it is a bootable image.

BITS 16                     ; Tells the assembler to generate 16-bit code; required for real mode execution
ORG  0x7c00                 ; sets the origin at the address... so that all operation start from that address
                            ; Tells the assembler the code will be loaded at that partivular address
main:
    HLT

halt:
    JMP halt 

TIMES 510-($-$$) DB 0       ; the bootloader must be exactly 512 bytes... 510 for code and data, 2 for signature
                            ; $$ is the address at the start of the file and $ is the current address
DW 0xAA55                   ; the boot signature exactly at the end of the file


; how to run?
; well we already have a 'Makefile' so just run "$make" to setup the image
; then run "$qemu-system-i386 -fda build/main.img"
; if it does not work check if qemu has a gui... it may or may not be pre-installed based on your OS
; check if you have a GUI for qemu by using "$qemu-system-i386 -display help"