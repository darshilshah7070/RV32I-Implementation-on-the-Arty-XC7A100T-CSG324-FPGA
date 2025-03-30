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
In this Step We will be see how to make hex file from C/RV32i-Assembly.
Make Should be installed in your system because we will be using Makefile.

``` bash
sudo apt install make
```

now go to EXAMPLES directory 
``` bash
cd EXAMPLES
```

First you need to install RISC-V toolchain. Fot that i created [download_toolchain.sh](https://github.com/darshilshah7070/RV32I/blob/main/EXAMPLES/download_toolchain.sh). This will download toolchain in the FIRMWARE directory.
```bash
./download_toolchain.sh
```

Now you can choose whatever program you like from EXAMPLES.(You can also write your own .c / .s also). Here i am taking [donut.c](https://github.com/darshilshah7070/RV32I/blob/main/EXAMPLES/donut.c).
By the Makefile you can create .hex file which will be paste into the initial block of Memory of our design.
```verilog
initial begin
    $readmemh("firmware.hex", MEM);
end
```
To crete `firmware.hex` :

``` bash
make donut.bram.hex
```
this will create `firmware.hex` file into the obj_dir.

### Step 6 ###
Follow Basic Vivado Flow for FPGA design
- Open Vivado
- Make Project
- In the design file [SOC.v](https://github.com/darshilshah7070/RV32I/blob/main/SOC.v), [clockworks.v](https://github.com/darshilshah7070/RV32I/blob/main/clockworks.v), [emitter_uart.v](https://github.com/darshilshah7070/RV32I/blob/main/emitter_uart.v) and [mypll.v](https://github.com/darshilshah7070/RV32I/blob/main/mypll.v) should be there.
- Copy and paste `firmware.hex` from obj_dir to the Vivado src folder.(You can also change Makefile for avoiding Manual Copy-paste).
- Run synthesis.
- add constrain file.[arty.xdc](https://github.com/darshilshah7070/RV32I/blob/main/arty.xdc)
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

  If everything by far is worked the output should be(for donut.c):
  ![Video Description](https://github.com/darshilshah7070/RV32I/blob/main/output_video.mp4)


TO exit `Control + a , Control + x`.

