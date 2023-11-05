#writing 


[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

This chapter introduces the software programs running on the PS-site in this work. As the hardware is designed to emulate the functionality of the KX134 accelerometer, the signal generator software completely covers the functionality of the signal recorder software.The code used for sensor configuration and reading acceleration data from the sample buffer in watermark interrupt mode is identical between the two design. Therefore, following sections focus only on the structure and implementation of the signal generator software.

The software's major tasks in this system include initializing the peripherals, reading/writing text files from the SD card, converting fractions in the text to 16-bit binary (and vice versa), and handling interrupt signals. Additionally, as stated in section X, the system needs to provide some user interaction capabilities for flexible configuration of signal sources and runtime control, which can be accomplished through serial port communication.
### SD card operation


文本文件中，python生成的振动信号x以小数的形式存在于文本文件中，每个数占一行。 read_sd函数逐行读取并近似与g相关的整数并转换为16位二进制数，再将二进制数分别存放在两个32bit的存储单元中。Memory Map Data Width：AXI MM2S存储映射读取数据总线的数据位宽。有效值为32,64,128,256,512和1024。此处保持默认值32。

若f_gets报错如下：undefined reference to "f_gets",即表示f_gets未定义，
出现这个错误的原因是，在xiffls中我们没有使能字符串函数功能。use_strfunc

write_sd_txt程序则是反过程，将放在三个float类型buffer中的x,y,z三轴加速度数据写入文本文件中。
#### fatfs
Xilffs is a generic FAT file system that is primarily added for use with SD/eMMC driver. The file system is open source and a glue layer is implemented to link it to the SD/eMMC driver. A link to the source of file system is provided in the PDF where the file system description can be found.
对于文件读写操作，Xilinx提供了Xilffs这一generic FAT file system。它充当了应用和存储器控制中间的桥梁。在SD/eMMC driver提供了更高一层的抽象。编写程序时，Application should make use of APIs provided in ff.h.
FatFs is a generic FAT/exFAT filesystem module for small embedded systems. FatFs provides various filesystem functions for the applications 
The Xilinx fat file system (FFS) library consists of a file system and a glue layer. This FAT file system can be used with an interface supported in the glue layer. The file system code is open source and is used as it is. Currently, the Glue layer implementation supports the SD/eMMC interface and a RAM based file system. Application should make use of APIs provided in ff.h. These file system APIs access the driver functions through the glue layer.

### comparison between AXI-DMA and AXI-Stream FIFO

The AXI-DMA IP block can read from DDR RAM independently and on its own after instruction to do so. It then streams the data out the AXI-Stream port.
The AXI Streaming FIFO IP block has internal memory that you can fill up under processor control and it then also streams the data out the AXI-Stream port. 

The process of transferring data from the PS to the PL using AXI Streaming FIFO consists of the following steps: Firstly, check available space using XLlFifo_TxPutWord. Next, write words one by one into the FIFO using XLlFifo_TxPutWord. Once all the data has been written, stream out the AXI-Stream data of a user-specified length byXLlFifo_iTxSetLen. Since the maximum depth of the FIFO buffer is not enough to hold all the vibration data, a complete vibration signal period consisting of 30000 samples needs to be divided into multiple batches for transmission. Moreover, frequent concurrent interrupts from the FIFO and custom IP's require interleaved data sending and reading, complicating the interrupt handling.

In contrast, AXI-DMA controller requires the processor to issue only one instruction that specifies the source address and transmission length. Data is automatically fetched  from memory and transmitted without the involvement of the processor. The IP's internal counter tracks the actual transfer length and generates a completion interrupt to notify the PS when the amount of data transferred has reached the configured length.

Using AXI DMA, it is straightforward to implement the following functionality: The application program reads a text file specified by the user, writes the data into the storage, then passes the first address of this storage block and length of the block to the DMA controller. The DMA controller independently streams data to the custom IP while the timing of transmission is also controlled by the READY signal of the custom IP as a AXI-Stream slave. The PS only need to handle the buffer watermark threshold interrupt from the custom IP. After the entire text file is sent, the application requests another filename from the user.



一些IP核需要由驱动程序进行初始化和控制。驱动程序基本上是一组接口协议，帮助与IP核通信。从Vivado导出的硬件平台时最基础的层级。在此之上，软件系统被视为一堆或一组需要建立在硬件基础系统之上的层。位于硬件基础系统之上的第一层是板支持包（BSP）层。板支持包（BSP）是一组低级驱动程序和函数。接下来的层，即操作系统，使用这些驱动程序和函数与IP核进行通信。最高级别的抽象是需要在操作系统上运行的软件应用程序。

这一应用运行在Standalone（又名baremetal）操作系统下。
A standalone OS, also known as a bare metal OS, is a simple OS that aims to provides a very low-level of software modules that the system can use to access processor-specific functions. Regarding the Zynq platform specifically, Xilinx provides a standalone OS platform that provides functions such as configuring caches, setting up interrupts and exceptions and other hardware related functions. The standalone platform sits directly below the OS layer and is used whenever an application requires to access processor features directly [8]. A standalone OS enables close control over code execution but is fairly limited in terms of functionality. It should only be used for applications where the software functions are straightforward and repetitive. The number of tasks being carried out by a standalone OS should be relatively small, as adding further tasks can increase the task management required by the standalone rapidly.

The Standalone platform is a single-threaded, simple operating system (OS) platform that provides the lowest layer of software modules used to access processor-specific functions. Some typical functions offered by the Standalone platform include setting up the interrupts and exceptions systems, configuring caches, and other hardware specific functions. The Hardware Abstraction Layer (HAL) is described in this document

Standalone BSP contains boot code, cache, exception handling, file and memory management, configuration, time and processor-specific include functions.

Hardware Abstraction Layer API.

[8] Xilinx, Inc, “OS and Libraries Document Collection”, UG643
Xilinx Standalone Library Documentation: BSP and Libraries Document Collection UG643
需要注意的是
#### BSP 
在上一章节中介绍了在Vivado中进行硬件设计的流程。Vivado中的工程文件被synthesis并打包导出后，即为hardware base system’ or ‘hardware platform’.


作为一种
![[Pasted image 20231105220852.png]]
 
The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
The BSP is tuned to the hardware base system, allowing an OS to operate efficiently on the given hardware. The BSP is customised to the combination of base system and operating system, and includes hardware parameters, device drivers, and low-level OS functions. Therefore, in terms of Vivado / SDK development, the BSP should be refreshed if changes are made to the hardware base system. SDK provides the environment for creating BSPs, and developing and testing software for deployment in the upper layers. It also supports the creation of BSPs for use in third party development tools such as ARM Development Studio 5 (DS-5), which may be used in place of Xilinx SDK if desired [33],


编程时主要使用Xilinx Hardware Abstraction Layer
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


red req生成在get_address_and_cmd状态，只高一个时钟周期
data valid生成在读取最后一位的时钟周期，只高一个时钟周期 否则会多次激活读写operation。为保证数据的可靠性，应该在valid有效时寄存其值。



