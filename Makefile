ASM=nasm
BUILD=build
SRC=src

all: $(BUILD)/main.img

#
### Bootloader
#
bootloader: $(BUILD)/bootloader.bin
$(BUILD)/bootloader.bin : $(SRC)/bootloader/boot.asm
	@mkdir -p $(BUILD)
	$(ASM) -f bin $(SRC)/bootloader/boot.asm -o $(BUILD)/bootloader.bin

#
### Kernel
#
kernel: $(BUILD)/kernel.bin
$(BUILD)/kernel.bin : $(SRC)/kernel/main.asm
	$(ASM) -f bin $(SRC)/kernel/main.asm -o $(BUILD)/kernel.bin

#
### Floppy disk image
#
floppyImage: $(BUILD)/main.img
$(BUILD)/main.img : bootloader kernel
	dd if=/dev/zero of=$(BUILD)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "UNMADEOS" $(BUILD)/main.img
	dd if=$(BUILD)/bootloader.bin of=$(BUILD)/main.img conv=notrunc
	mcopy -i $(BUILD)/main.img $(BUILD)/kernel.bin "::kernel.bin"