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

next chapter Hardware system design
在掌握KX134的基本功能和通信方式后，即可搭建signal recorder系统



The AXI IIC Bus Interface module provides the transaction interface to the AXI4-Lite interface. This core does not provide explicit electrical connectivity to the IIC bus. 这代表，该IP核与外界通信的信号并不是双向的。用户应该在设计中确保三态门缓冲和上拉电阻的存在，以符合协议要求。

  
BSP目录下的xparameters.h，里面列出了各个外设对应的地址、Device_ID、中断号，等等宏定义，被用于对硬件外设进行寻址。


