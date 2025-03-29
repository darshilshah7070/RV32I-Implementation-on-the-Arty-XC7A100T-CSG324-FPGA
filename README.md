# RISC-V Core Design

This project contains the implementation of a RISC-V core(RV32I) on Arty XC7A100T-CSG324 using Vivado. The project demonstrates the basic principles of RISC-V architecture and its implementation using verilog hardware description languages (HDL).

## Table of Contents

- [Introduction](#introduction)
- [Architecture](#architecture)
- [Features](#features)
- [Design Overview](#design-overview)
- [Getting Started](#getting-started)
- [Simulation and Testing](#simulation-and-testing)
- [Licensing](#licensing)
- [Contributing](#contributing)

## Introduction


This core is using basic RV32I instruction set of RISC-V. User can Generate core based on their FPGA because verilog is used. The core is using multicycle flow. The design is mainly inspired by PicoRV32 and FemtoRV32. 
Here i am using Arty XC7A100T-CSG324 FPGA  for Implementation and for Synthesis, Place&Route and bit-stream generation Vivado is Used (User can use Yosys ,Nextpnr,OpenFPGALoader and Project Xray but for XC7 it is little dificult to use Open Source Softwares than Vivado so here i am using Vivado for simplicity).
Examples contain .c files and .s files which will be converted to hex file By Makefile and dumped to the core. Output can be viewed by the UART. User can create their own C files also.

### Prerequisites

- **Vivado2017.2>=**: I am using Vivado 2017.2
- **Linux Based OS**: For easy Flow(user can also use windows but all the dependacies should be installed). I am uisng Linux Mint here.
- **Arty XC7A100T-CSG324**: Can be any FPGA but modification of the xdc file required.(iverilog or verilator can also be used if user want to simulae. 


## Getting Started



### Prerequisites

- **Verilog/VHDL Compiler**: The design is written in Verilog. Ensure you have a suitable simulator like ModelSim or XSIM.
- **Testbench**: The project includes testbenches to simulate the core's behavior.
- **Development Environment**: You can use any HDL development environment that supports Verilog.

### Clone the Repository

```bash
git clone https://github.com/yourusername/riscv-core-design.git
cd riscv-core-design
