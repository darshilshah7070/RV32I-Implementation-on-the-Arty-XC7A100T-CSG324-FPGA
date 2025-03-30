# RISC-V Core Design

This project involves the implementation of a RISC-V core (RV32I) on the Arty XC7A100T-CSG324 FPGA using Vivado. The project demonstrates the basic principles of RISC-V architecture and its implementation using Verilog hardware description language (HDL).

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)

## Introduction

This core implements the basic RV32I instruction set of the RISC-V architecture. Users can generate the core based on their FPGA, as Verilog is used for the design. The core follows a multicycle pipeline flow. The design is primarily inspired by PicoRV32 and FemtoRV32 cores.

For implementation, this project uses the Arty XC7A100T-CSG324 FPGA. Vivado is employed for synthesis, place-and-route, and bitstream generation. While other tools such as Yosys, Nextpnr, OpenFPGALoader, and Project Xray can also be used, Vivado is typically more straightforward when working with XC7 devices. Therefore, Vivado is used in this case for simplicity.

The provided examples include `.c` and `.s` files, which are compiled into a `.hex` file by a Makefile and loaded onto the core. The output can be observed through UART. Users can also create their own C programs.

### Prerequisites

Before proceeding, ensure you have the following:

- **Vivado 2017.2 or later**: I am using Vivado 2017.2 for this project.
- **Linux-based OS**: The steps in this guide are based on Linux Mint 21.3. While you can use Windows, make sure all dependencies are properly installed. For this project, I am using Linux Mint.
- **Arty XC7A100T-CSG324**: This specific FPGA is used in this project, but other FPGAs can be used with modifications to the `.xdc` constraint file. Simulation tools like Icarus Verilog or Verilator can also be used if you wish to simulate the design.

![Arty FPGA](https://github.com/darshilshah7070/RV32I/blob/main/images/Arty_FPGA.png)

## Getting Started

This guide is based on Linux Mint 21.3. If you are using a different operating system, some steps may vary.

### Step 1: Update your system

Start by updating your system's package list and upgrading all installed packages:

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
In this Step We will be see how to make hex file from C/RV32i-Assembly.
Make Should be installed in your system because we will be using Makefile.

``` bash
sudo apt install make
```

Navigate to the `EXAMPLES` directory:
``` bash
cd EXAMPLES
```

Next, you need to install the RISC-V toolchain. To simplify this process, I have provided a script called [download_toolchain.sh](https://github.com/darshilshah7070/RV32I/blob/main/EXAMPLES/download_toolchain.sh) that will download the necessary toolchain into the FIRMWARE directory:
```bash
./download_toolchain.sh
```

After that, you can select any example program from the EXAMPLES directory (you can also write your own .c or .s files). In this case, we will use the [donut.c](https://github.com/darshilshah7070/RV32I/blob/main/EXAMPLES/donut.c) program, but you are free to choose any program.

The Makefile will convert the C code into a .hex file, which will then be loaded into the initial memory block of the design.
```verilog
initial begin
    $readmemh("firmware.hex", MEM);
end
```
To generate `firmware.hex` :

``` bash
make donut.bram.hex
```
this will create `firmware.hex` file into the `obj_dir`.

### Step 6 ###
Follow Basic Vivado Flow for FPGA design
- Open Vivado
- Make Project
- In the design file [SOC.v](https://github.com/darshilshah7070/RV32I/blob/main/DESIGN/SOC.v), [clockworks.v](https://github.com/darshilshah7070/RV32I/blob/main/DESIGN/clockworks.v), [emitter_uart.v](https://github.com/darshilshah7070/RV32I/blob/main/DESIGN/emitter_uart.v) and [mypll.v](https://github.com/darshilshah7070/RV32I/blob/main/DESIGN/mypll.v) should be there.
- Copy and paste `firmware.hex` from obj_dir to the Vivado src folder.(You can also change Makefile for avoiding Manual Copy-paste).
- Run synthesis.
- add constrain file.[arty.xdc](https://github.com/darshilshah7070/RV32I/blob/main/DESIGN/arty.xdc)
- Run implenetation
- Generate Bitstream
- Send Bitstream to FPGA
  

### Step 7 ###
To see the output:
- If it is FPGA's LED output You can see on the FPGA.
- If it is UART Based output

   in the `EXAMPLES` Directroy there is script called `uart.sh`.

  ``` bash
    ./uart.sh
    ```

 If everything has been set up correctly, the output for the donut.c program should appear, as shown below:
  ![Output](https://github.com/darshilshah7070/RV32I/blob/main/images/output_video.gif)


TO exit the from the script : `Control + a , Control + x`.

