; FAT12 boot sector for 1.44M floppy disk
; Upon booting, a computer first enters the BIOS(Basic Input Output System)
; what a bios does is, it seraches throught the memory of bootable debices and loads it into the memory of 0x7c00 which is the Origin(ORG)
;   and then the bootloader at 0x700c checks for thie signature 0xAA55 to verify if it is a bootable image.

BITS 16                     ; Tells the assembler to generate 16-bit code; required for real mode execution
ORG  0x7c00                 ; sets the origin at the address... so that all operation start from that address
                            ; Tells the assembler the code will be loaded at that partivular address

JMP SHORT main              ; takes 2 bytes to jump rather than 3
NOP                         ; No-OPeration assembler uses this as a 1 byte placeholder
; OEM name                  ; these 2 lines align with the expected layout of the FAT12 spec
bdb_oem:    DB  "BANANA07"  ; Just for imformational branding. the name does'nt matter as long as it is 8 bytes

; BIOS Parameter Block (BPB)
bytesPerSector      DW 512          ; total number of bytes in one sector(512 for floppy)
sectorsPerCluster   DB 1            ; Number of sectors per cluster 
reservedSectors     DW 1            ; number of reserved sector before the FAT starts
fatCount            DB 2            ; number of file allocation tables(FATs) usually 2 for redundancy
maxRootEntries      DW 0xe0         ; max number of entries in the directory
totalSectors        DW 2880         ; total number of sectore on the disk (1.44MB = 512*2880)
mediaDescriptor     DB 0xf0         ; Media type of Floppy disk
sectorsPerFAT       DW 9            ; Number of sectors used by each FAT
sectorsPerTrack     DW 18           ; Number of Sectors per track
numHead             DW 2            ; Number of heads
hiddenSectors       DD 0            ; Usually 0 for floppy (used only for hard drives/partitions)
total32Sectors      DD 0            ; use only if totalSectors>65535. set to 0 for floppy

; EBR(Extended Boot Record) FAT12 specific
driveNumber         DB 0            ; Drive number passed by BIOS (0 for floppy 80h for hard disk)
reserved1           DB 0            ; just a reserved space
bootSignature       DB 0x29         ; Magic value that tells FAT that the next 3 fields exist
volumeID            DD 0x12345678   ; random ahh serial number
volumeName          DB "UNMADE OS  "; Volume label - 11 bytes
fileSystemType      DB "FAT12   "   ; filesystem type string - 8 bytes


main:
    XOR ax, ax              ; sets ax to 0
    MOV ds, ax              ; assigns the data segment space to 0 (for loading data)
    MOV es, ax              ; assigns the etra segment to zero (for doing operations like MOV)
    MOV ss, ax              ; assigns stack segment to zero (for stack operations)

    MOV sp, 0x7b00          ; assigns the stack pointer to an arbitrary address away from the bootloader space (stack memory offset)
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
    MOV bh, 0               ; sets the page number. useful when working with many buffers or pages
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