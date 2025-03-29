# RISC-V Core Design

This project contains the implementation of a RISC-V core(RV32I) on Arty XC7A100T-CSG324 using Vivado. The project demonstrates the basic principles of RISC-V architecture and its implementation using verilog hardware description languages (HDL).

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)

## Introduction


This core utilizes the basic RV32I instruction set of RISC-V. Users can generate the core based on their FPGA, as Verilog is used for the design. The core follows a multicycle flow. The design is primarily inspired by PicoRV32 and FemtoRV32.

For implementation, I am using the Arty XC7A100T-CSG324 FPGA. Vivado is employed for synthesis, place-and-route, and bit-stream generation. While users can opt for alternative tools such as Yosys, Nextpnr, OpenFPGALoader, and Project Xray, using Vivado is generally more straightforward for XC7 devices. Therefore, Vivado is used in this case for simplicity.

The provided examples include .c and .s files, which are converted to a hex file by a Makefile and loaded onto the core. The output can be viewed via UART. Users are also free to create their own C files.
### Prerequisites

- **Vivado2017.2>=**: I am using Vivado 2017.2
- **Linux Based OS**: For easy Flow(user can also use windows but all the dependacies should be installed). I am uisng Linux Mint here.
- **Arty XC7A100T-CSG324**: Can be any FPGA but modification of the xdc file required.(iverilog or verilator can also be used if user want to simulae. 


## Getting Started
All the steps are written based on Linux Mint 21.3.
### Step 1 ###
In the terminal write this commands.
```bash
sudo apt update
sudo apt upgrade
```
### Step 2 ###
make sure git is installed.
```bash
sudo apt install git
```

### Step 3 ###
clone this Repo.

```bash
git clone https://github.com/darshilshah7070/RV32I.git
cd RV32I
```
### Step 4 ###
Vivado should be installed from their [website](https://www.xilinx.com/support/download.html) (only Vivado is required not there SDK). Here i am using Vivado 2017.2

### Step 5 ###


