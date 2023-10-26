#writing #structure

Design flow （zynq book） 

在掌握KX134的基本功能和通信方式后，即可搭建signal recorder系统

### 使用zynq搭建系统的流程 

The overall process of building a system using the Zynq SoC can be divided into hardware logic implementation of the PL and software programming of the PS. 

The hardware logic design involves creating the required custom hardware environment in Vivado to meet the system requirements. This includes IP integration, module design, pin assignments, and bitstream programming. 

The software programming aims to control the operation of the PS through user code, in order to realize the expected system functionality. This can be done in Vitis, which is used to create, compile and debug applications running on the ARM Cortex-A9 processor. 

Methodologically, the hardware-software co-design flow for Zynq involves: 
- Writing specifications based on requirements 
- System design following top-down principles 
- Hardware development and testing using IP blocks 
- Software development and testing 
- System integration and testing 
 
 From a software workflow perspective, 设计步骤可以被分为以下几个步骤： 
 - 选择被使用的device并在Vivado中创建工程 
 - 在Vivado中完成hardware designs and exported in the Xilinx support archive (XSA) format which 包含对PS的配置和编程PL的bitstream. 
 - To create a new platform component in the Vitis IDE, the XSA is imported and select the operating system 
 - For lower level OS like FreeRTOS and Standalone, a Board Support Package (BSP) is created. 基于BSP write applications and compile/run them. 

### zynq ip CORE 
 
 The first step is to add the ZYNQ7 Processing System IP core, which unlike soft processor IPs such as MicroBlaze, serves as an interface to non-FPGA processing system components. The board definition file from the manufacturer automatically configures the Zynq PS IP with appropriate parameters and establishes connections between Multipurpose I/O (MIO) pins and board peripherals. Notably, the PL to PS interrupt required in this project must be manually enabled by the user. ### BSP The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
