#writing #structure

The signal generator developed in this work emulates the functionality of the KX134-1211 accelerometer, which is also used for vibration data acquisition in the signal recorder. Therefore, this section provides background information on the basic capabilities and interface of the KX134 that are relevant to reproducing its operation. 
# KX134 
The KX134 from Kionix is a triaxial accelerometer from Kionix that is capable of measuring acceleration forces along the X, Y, and Z axes. User interaction with the KX134, including configuration and data acquisition, is enabled through either I2C or SPI communication protocols. By writing to specific registers, users can configure various parameters such as sensor range, output data rate, triggering options, and buffer size. 
## Pin assignments and description 
The pins of the KX134 accelerometer are shown in Table 1 below. ![[Pasted image 20231010054814.png]] This work uses the KX134-1211-EVK-001 evaluation board to connect the sensor with other development platforms. A ribbon cable connects the sensor evaluation board to the FPGA development board.
## Embedded Registers 
The KX134 accelerometer has 128 8-bit registers that are mostly userprogrammable. Table 1 lists the available registers and their addresses. ![[Pasted image 20231010060519.png]]The upcoming section will provide a detailed description of the configuration registers associated with this project. 

## Registers configuration for watermark Interrupt mode
The Watermark Interrupt mode is an operating mode of the Accelerometer. samples are first stored in a buffer. Once the number of samples in the buffer reaches a user-defined threshold, a hardware interrupt is generated. In signal recorder, KX134 works in this mode. In signal generator, the behavior of the KX134 in this mode is emulated. Therefore, the registers that require to be configured in this mode will be introduced next. 
### CNTL1 
The CNTL1 control register enables the main features of the KX134. Before configuring other registers, CNTL1 must be used to set the accelerometer to stand-by mode. Once configuration is complete, CNTL1 is used to start data acquisition. 在工作中被配置了的位如下 PC1 RES (highperformence) GSEL 
### ODCNTL 
Output data control register可以配置与acceleration outputs有关的功能与参数。其中最重要的是OSA 3:0，它决定了该accelerometer的采样率 插入OSAODR表格 
### INC1 
Interrupt Control寄存器 controls the settings for the physical interrupt pin INT1. 工作中被配置了的位如下 IEN1 IEA1 IEL1 
### INC4 
This register controls routing of an interrupt reporting to physical interrupt pin INT1. 为了实现watermark模式配置了以下位 WMI1 
### BUF_CNTL1 
This register controls the buffer sample threshold. 其中的数据是SMP_TH[7:0]，即用户定义的样本数量阈值。当Sample为8位时，the maximum number of samples is 171；当Sample为16位时，the maximum number of samples is 86. 
### BUF_CNTL2 
This register controls sample buffer operation.其中以下位在本工作中被配置 BUFE BRES BM[1:0] 
## communication via I2C 
As mentioned previously, the KX134 accelerometer communicates with host via I2C bus protocol. The 7-bit slave address of the KX134 consists of a 6-bit fixed portion and a 1-bit programmable section based on the logic level of the ADDR pin. Specifically, the accelerometer can be configured for an address of 0x1E when ADDR is grounded or 0x1F when ADDR is connected to VDD. Read and write transactions comply with to the I2C timing diagrams and format described earlier. Furthermore, the sequence shown in Figure 3 must be followed when accessing the KX134's internal registers. 

Notably, the KX134 supports an auto-increment feature for simplified sequential register access. During multiple read or write operations, the register address does not need to be resent as the pointer automatically increments to the next register. However, this feature is disabled when reading from the BUF_READ register (0x63) so that the host can continuously read samples from the buffer. 

在掌握KX134的基本功能和通信方式后，即可搭建signal recorder系统

使用zynq搭建系统的流程 

ZYNQ 的工程设计大体上可以分为 对硬件逻辑系统的设计 和 对 CPU 软件程序的设计 硬件逻辑系统设计：搭建一个满足用户需求的硬件环境，通过 Vivado 实现 CPU 程序设计：通过用户程序控制 CPU 工作，使整个系统达到预定的效果，该部分通过 Vitis 实现 

使用 Zynq SoC 构建系统的设计流程可分为硬件逻辑实现和处理系统 (PS) 的软件编程。 

硬件逻辑设计包括使用 Vivado 创建所需的定制硬件环境，以满足系统要求。这包括 IP 集成、模块设计、引脚分配和 FPGA 编程。 

软件编程的目标是通过用户代码控制 PS 的运行，以实现预期的系统功能。这可以在 Vitis 中完成，用于创建、编译和调试在 ARM Cortex-A9 处理器上运行的应用程序。

Vivado 和 Vitis 工具协同工作，生成完整的 Zynq 系统。Vivado 综合并实现 PL 硬件逻辑，该逻辑与 FPGA 位流中的 PS 初始化一起加载。Vitis 将软件编译成可执行文件，并在启动后加载到 PS 运行。 通过制造商提供的board file, automatically configure the Zynq PS IP core with the correct parameters 并正确分配Multipurpose IO (MIO)管脚和板上peripherals的连接关系。 The AXI IIC Bus Interface module provides the transaction interface to the AXI4-Lite interface. This core does not provide explicit electrical connectivity to the IIC bus. 这代表，该IP核与外界通信的信号并不是双向的。用户应该在设计中确保三态门缓冲和上拉电阻的存在，以符合协议要求。