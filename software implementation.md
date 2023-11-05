#writing 


[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

This chapter introduces the software programs running on the PS-site in this work. As the hardware is designed to emulate the functionality of the KX134 accelerometer, the signal generator software completely covers the functionality of the signal recorder software.The code used for sensor configuration and reading acceleration data from the sample buffer in watermark interrupt mode is identical between the two design. Therefore, following sections focus only on the structure and implementation of the signal generator software.

The software's major tasks in this system include initializing the peripherals, reading/writing text files from the SD card, converting fractions in the text to 16-bit binary (and vice versa), and handling interrupt signals. Additionally, as stated in section X, the system needs to provide some user interaction capabilities for flexible configuration of signal sources and runtime control, which can be accomplished through serial port communication.

### Layers of software on zynq
![[Pasted image 20231105220852.png]]
Chapter 3 introduces the Vivado design flow for hardware development. The synthesized hardware design exported from Vivado is referred to as the "hardware base system" or "hardware platform". As shown in Figure X, the software system consists of layered components built upon this foundation.

The lowest software layer is the Board Support Package (BSP), which contains hardware parameters, low-level drivers, and functions used by the operating system on the higher layer to communicate with the hardware.  Since the BSP is customized for a specific base system, any hardware design changes require re-importing the new design and regenerating the BSP in SDK.

The Operating System layer is positioned above the BSP. For Zynq platform, Xilinx supports various OS choices depending on application requirements, including fully-fledged options like Linux, real-time operating systems (RTOS) for time-critical application, or Xilinx Standalone – a lightweight “bare-metal” OS.

Standalone provides basic software modules to access processor-specific functions. For Zynq devices, Xilinx provides a Standalone platform that includes cache configuration, interrupt/exception handling, and other hardware-related functions. While Standalone allows for close control over code execution , it has limited capabilities suitable only for simple, repetitive software tasks. The application in this work fits these requirements and therefore is operated on the Standalone OS.

[8] Xilinx, Inc, “OS and Libraries Document Collection”, UG643
Xilinx Standalone Library Documentation: BSP and Libraries Document Collection UG643



### comparison between AXI-DMA and AXI-Stream FIFO

The AXI-DMA IP block can read from DDR RAM independently and on its own after instruction to do so. It then streams the data out the AXI-Stream port.
The AXI Streaming FIFO IP block has internal memory that you can fill up under processor control and it then also streams the data out the AXI-Stream port. 

The process of transferring data from the PS to the PL using AXI Streaming FIFO consists of the following steps: Firstly, check available space using XLlFifo_TxPutWord. Next, write words one by one into the FIFO using XLlFifo_TxPutWord. Once all the data has been written, stream out the AXI-Stream data of a user-specified length byXLlFifo_iTxSetLen. Since the maximum depth of the FIFO buffer is not enough to hold all the vibration data, a complete vibration signal period consisting of 30000 samples needs to be divided into multiple batches for transmission. Moreover, frequent concurrent interrupts from the FIFO and custom IP's require interleaved data sending and reading, complicating the interrupt handling.

In contrast, AXI-DMA controller requires the processor to issue only one instruction that specifies the source address and transmission length. Data is automatically fetched  from memory and transmitted without the involvement of the processor. The IP's internal counter tracks the actual transfer length and generates a completion interrupt to notify the PS when the amount of data transferred has reached the configured length.

Using AXI DMA, it is straightforward to implement the following functionality: The application program reads a text file specified by the user, writes the data into the storage, then passes the first address of this storage block and length of the block to the DMA controller. The DMA controller independently streams data to the custom IP while the timing of transmission is also controlled by the READY signal of the custom IP as a AXI-Stream slave. The PS only need to handle the buffer watermark threshold interrupt from the custom IP. After the entire text file is sent, the application requests another filename from the user.








 


#   
Getting Started with Vivado and Vitis for Baremetal Software Projects
https://digilent.com/reference/programmable-logic/guides/getting-started-with-ipi



SCUGIC

Interrupts between the PS and PL are controlled by the Generic Interrupt Controller 
(GIC), which supports 64 interrupt lines. Six interrupts are driven from within the APU, 
including the L1 parity fail, L2 interrupt and Performance Monitor Unit (PMU) interrupt (zynq book)

查找相应配置并初始化GIC，配置两个Interrupt,此处两个都设置为 Rising edge sensitive 。而watermark interrupt具有更高的优先级。
XScuGic_Connect 用于Makes the connection between the Int_Id of the interrupt source and the associated handler that is to run when the interrupt is recognized.

The argument provided in this call as the Callbackref is used as the argument for the handler when it is called.

硬件补充
SCL尽管是I2C总线时钟信号，在该系统中不被当时钟使用。系统时钟远快于SCL，对SCL的上升下降沿进行检测，获得与系统时钟同步的上升下降沿信号。
消抖后检测上升下降沿 检测开始结束 状态机 
register map有另一个状态机 idle getdata writedata
在模块已经被写入一个有效的地址后
如果收到读请求 getdata  收到valid信号 writedata 并寄存当前的data_from_master_reg
getdata中检测当前地址是普通register还是BUF。是BUF的话将fifo_din的值给data_to_master_reg,否则从register map中取出对应值。
writedata中将被寄存的数值写进地址对应的寄存器中

尽管SCL提供了I2C总线的时序信息，但为了在系统中尽量避免跨时钟域问题，整个PL部分使用同一个时钟。由于应用的系统时钟远快于SCL，且作为从机，custom IP不需要驱动SCL，只需要获得SCL的时序信息，因此用对SCL进行边沿检测取代将SCL作为时钟信号是可行的。该边沿检测逻辑基于register延时，在SCL的上升沿或下降沿上，会生成对应的同步脉冲信号，供内部逻辑使用。


red req生成在get_address_and_cmd状态，只高一个时钟周期
data valid生成在读取最后一位的时钟周期，只高一个时钟周期 否则会多次激活读写operation。为保证数据的可靠性，应该在valid有效时寄存其值。



