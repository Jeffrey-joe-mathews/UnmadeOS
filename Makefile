ASM=nasm
BUILD=build
SRC=src

all: $(BUILD)/main.img

$(BUILD)/main.bin : $(SRC)/main.asm
	@mkdir -p $(BUILD)										# we silence the output by using @ because it is repetitive
	$(ASM) -f bin $(SRC)/main.asm -o $(BUILD)/main.bin

$(BUILD)/main.img : $(BUILD)/main.bin
	cp $(BUILD)/main.bin $(BUILD)/main.img
	truncate -s 1440k $(BUILD)/main.img