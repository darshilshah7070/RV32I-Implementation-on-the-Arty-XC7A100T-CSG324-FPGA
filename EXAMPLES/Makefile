# Define the base directory for the toolchain (relative to the Makefile location)
TOOLCHAIN_DIR = FIRMWARE/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14

# Toolchain Paths
RV_TOOLCHAIN_PATH = $(TOOLCHAIN_DIR)/bin
RV_GCC_LIB_PATH = $(TOOLCHAIN_DIR)/lib/gcc/riscv64-unknown-elf/8.3.0/rv32i/ilp32

# Binaries in the toolchain
RV_BINARIES = $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-as \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-ld \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-objcopy \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-objdump \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-gcc \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-g++ \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-ar \
              $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-ranlib

# Toolchain flags
RVASFLAGS = -march=rv32i -mabi=ilp32
RVCFLAGS = -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax
RVLD = $(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-ld
RVTOOLCHAIN_GCC_LIB_DIR = $(RV_GCC_LIB_PATH)

# RAM size and object files
RAM_SIZE = 6144
LIBOBJECTS = putchar.o wait.o print.o memcpy.o errno.o perf.o

# Firmware directory
FIRMWARE_DIR = FIRMWARE

# Targets
TARGET = blinker.bram.hex
ELF_FILE = blinker.bram.elf

# Sources
ASM_SOURCES = blinker.S start.S putchar.S wait.S perf.S
C_SOURCES = print.c memcpy.c errno.c

# Rule to build the final target (blinker.bram.hex)
$(TARGET): $(ELF_FILE) $(FIRMWARE_DIR)/TOOLS/firmware_words
	$(FIRMWARE_DIR)/TOOLS/firmware_words $(ELF_FILE) -ram $(RAM_SIZE) -max_addr $(RAM_SIZE) -out $(TARGET)
	mkdir -p obj_dir
	cp $(TARGET) obj_dir/firmware.hex
	echo $(TARGET) > obj_dir/firmware.txt
	rm $(LIBOBJECTS) $(ELF_FILE)

# Rule to link the object files and create the ELF file
%.bram.elf: %.o start.o $(LIBOBJECTS) $(RV_BINARIES)
	$(RVLD) -T bram.ld -m elf32lriscv -nostdlib -norelax $< $(LIBOBJECTS) $(RVTOOLCHAIN_GCC_LIB_DIR)/libgcc.a -o $@

# Rule to convert ELF to HEX file
%.hex: %.elf $(FIRMWARE_DIR)/TOOLS/firmware_words
	$(FIRMWARE_DIR)/TOOLS/firmware_words $< -ram $(RAM_SIZE) -max_addr $(RAM_SIZE) -out $@
	mkdir -p obj_dir
	cp $@ obj_dir/firmware.hex
	echo $@ > obj_dir/firmware.txt

# Rule to assemble assembly files
%.o: %.S
	$(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-as $(RVASFLAGS) $< -o $@

# Rule to compile C files
%.o: %.c
	$(RV_TOOLCHAIN_PATH)/riscv64-unknown-elf-gcc $(RVCFLAGS) -c $< -o $@

# Clean up object files and ELF
clean:
	rm -f $(ASM_SOURCES:.S=.o) $(C_SOURCES:.c=.o) $(LIBOBJECTS) $(ELF_FILE) $(TARGET)

# Phony targets
.PHONY: clean

