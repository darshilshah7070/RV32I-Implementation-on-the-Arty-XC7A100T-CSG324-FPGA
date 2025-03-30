#!/bin/bash

# Set the URL for the RISC-V toolchain tarball
TOOLCHAIN_URL="https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz"

# Set the directory where the toolchain should be installed
INSTALL_DIR="FIRMWARE"

# Set the name of the tarball file
TOOLCHAIN_TAR="riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz"

# Check if FIRMWARE directory exists, if not create it
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Creating directory $INSTALL_DIR..."
  mkdir -p "$INSTALL_DIR"
fi

# Download the toolchain tarball
echo "Downloading RISC-V toolchain..."
curl -L "$TOOLCHAIN_URL" -o "$INSTALL_DIR/$TOOLCHAIN_TAR"

# Check if download was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the RISC-V toolchain."
  exit 1
fi

# Extract the tarball
echo "Extracting RISC-V toolchain..."
tar -xzvf "$INSTALL_DIR/$TOOLCHAIN_TAR" -C "$INSTALL_DIR"

# Check if extraction was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to extract the RISC-V toolchain."
  exit 1
fi

# Remove the downloaded tarball to save space
rm "$INSTALL_DIR/$TOOLCHAIN_TAR"

echo "RISC-V toolchain installed successfully in $INSTALL_DIR."

