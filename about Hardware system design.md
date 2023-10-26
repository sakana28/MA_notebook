#writing #structure

Design flow （zynq book） 

在掌握KX134的基本功能和通信方式后，即可搭建signal recorder系统

### 使用zynq搭建系统的流程 

The overall process of building a system using the Zynq SoC can be divided into hardware logic implementation of the PL and software programming of the PS. 

The hardware logic design involves creating the required custom hardware environment in Vivado to meet the system requirements. This includes IP integration, module design, pin assignments, and bitstream programming. 

The software programming aims to control the operation of the PS through user code, in order to realize the expected system functionality. This can be done in Vitis, which is used to create, compile and debug applications running on the ARM Cortex-A9 processor. 

Methodologically, the hardware-software co-design flow for Zynq consists of the following stages: 
- Writing specifications based on requirements 
- System design following top-down principles 
- Hardware development and testing using IP blocks 
- Software development and testing 
- System integration and testing 
 
In terms of software workflow, the design process can also be divided into the following steps:
- Selecting the target device and creating a project in Vivado
- Completing hardware designs in Vivado and exporting in the Xilinx support archive (XSA) format containing configuration for the PS and bitstream programming the PL
- Importing the XSA in Vitis IDE and selecting the operating system to create a new platform.
- Generating Board Support Package (BSP) for lower level OS like FreeRTOS and Standalone
- Writing applications based on the BSP and compiling/running them

### zynq ip CORE 
 
 The first step is to add the ZYNQ7 Processing System IP core, which unlike soft processor IPs such as MicroBlaze, serves as an interface to non-FPGA processing system components. The board definition file from the manufacturer automatically configures the Zynq PS IP with appropriate parameters and establishes connections between Multipurpose I/O (MIO) pins and board peripherals. Notably, the PL to PS interrupt required in this project must be manually enabled by the user. ### BSP The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
