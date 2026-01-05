#!/usr/bin/env zsh

# A Zsh script to compile, image, and run a bootloader with QEMU.

# --- Validation ---
# Ensure an argument was provided.
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <filename_without_extension>"
    echo "Example: $0 hello"
    exit 1
fi

# --- Variables ---
BASENAME=$1
ASM_FILE="${BASENAME}.asm"
BIN_FILE="${BASENAME}.bin"
IMG_FILE="${BASENAME}.img"

# Check if the source assembly file exists.
if [[ ! -f "$ASM_FILE" ]]; then
    echo "Error: Source file not found at '$ASM_FILE'"
    exit 1
fi

# --- Build Process ---

# 1. Compile the assembly code with NASM
echo "
--- Compiling $ASM_FILE ---"
if ! nasm -f bin "$ASM_FILE" -o "$BIN_FILE"; then
    echo "Compilation failed."
    exit 1
fi
echo "Success: Created $BIN_FILE"


# 2. Create a 1.44MB floppy disk image and add the bootloader to it.
echo "
--- Creating Disk Image $IMG_FILE ---"
# Create an empty 1.44MB image file filled with zeros.
dd if=/dev/zero of="$IMG_FILE" bs=1024 count=1440 &> /dev/null

# Copy the bootloader binary to the beginning of the disk image.
dd if="$BIN_FILE" of="$IMG_FILE" conv=notrunc &> /dev/null
echo "Success: Wrote $BIN_FILE to $IMG_FILE"


# 3. Run the created image with QEMU
echo "
--- Booting with QEMU ---"
qemu-system-x86_64 -fda "$IMG_FILE"