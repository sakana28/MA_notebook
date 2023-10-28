#writing #structure

Design flow （zynq book） 

With an understanding of the KX134's fundamental features and communication protocols, the signal recorder system can now be constructed on the Zynq platform. This chapter will present a detailed discussion of the design flow for developing the system on the Zynq, the functionality implemented by the system, and key hardware design aspects. 



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
- Writing applications based on the BSP and compiling/debugging/running them

The system design and hardware development stages of the flow, as previously outlined, will be elaborated on in detail in this chapter. The process of software development conducted in Vitis IDE will be introduced in chapter 4.



![[Screenshot_2023-09-22_15-55-56.png]] (replaced later)


