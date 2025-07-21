; Upon booting, a computer first enters the BIOS(Basic Input Output System)
; what a bios does is, it seraches throught the memory of bootable debices and loads it into the memory of 0x7c00 which is the Origin(ORG)
;   and then the bootloader at 0x700c checks for thie signature 0xAA55 to verify if it is a bootable image.

BITS 16                     ; Tells the assembler to generate 16-bit code; required for real mode execution
ORG  0x7c00                 ; sets the origin at the address... so that all operation start from that address
                            ; Tells the assembler the code will be loaded at that partivular address
main:
    XOR ax, ax              ; sets ax to 0
    MOV ds, ax              ; assigns the data segment space to 0 (for loading data)
    MOV es, ax              ; assigns the etra segment to zero (for doing operations like MOV)
    MOV ss, ax              ; assigns stack segment to zero (for stack operations)

    MOV sp, 0x7b00          ; assigns the stack pointer to an arbitrary address away from the memory (stack memory offset)
    MOV si, os_boot_msg     ; initializes the address of the os_boot_msg
    CALL print              
    HLT

halt:
    JMP halt 

print:
    PUSH si                 ; saves all the three register values just in case for future use
    PUSH ax
    PUSH bx

print_loop:
    LODSB                   ; LOaDs a String Byte into al from the address si and increments si to point to the next character of the string
    OR al,al                ; triggers a zero flag(ZF) if and only if al is zero
    JZ print_end            ; Jump if string end has been reached

    MOV ah, 0x0e            ; BIOS teletype function code for printing onto the BIOS
    MOV bh, 0               ; sets the page number. useful when working with many monitors or pages
    INT 0x10                ; sets a BIOS video interrupt

    JMP print_loop          ; loops

print_end: 
    POP bx                  ; retrieve the threee datas back to its original registers
    POP ax
    POP si
    RET

os_boot_msg: DB "Unmade OS :: initializing -> Hollow shell",10,0

TIMES 510-($-$$) DB 0       ; the bootloader must be exactly 512 bytes... 510 for code and data, 2 for signature
                            ; $$ is the address at the start of the file and $ is the current address
DW 0xAA55                   ; the boot signature exactly at the end of the file


; how to run?
; well we already have a 'Makefile' so just run "$make" to setup the image
; then run "$qemu-system-i386 -fda build/main.img"
; if it does not work check if qemu has a gui... it may or may not be pre-installed based on your OS
; check if you have a GUI for qemu by using "$qemu-system-i386 -display help"