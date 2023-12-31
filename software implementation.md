#writing 


[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

This chapter introduces the software programs running on the PS-site in this work. As the hardware is designed to emulate the functionality of the KX134 accelerometer, the signal generator software completely covers the functionality of the signal recorder software.The code used for sensor configuration and reading acceleration data from the sample buffer in watermark interrupt mode is identical between the two design. Therefore, following sections focus only on the structure and implementation of the signal generator software.

在本章节中，首先会该软件实现的预期中的功能和算法的概览。之后会介绍Zynq上嵌入式软件的层次及在vitis中编写软件的流程。最后根据控制的硬件的不同，对软件进行了划分并详细介绍了各个部分的功能及使用的驱动APIs。

In this chapter, firstly, an overview of the expected functionalities and algorithms implemented in the software is provided. Next, the hierarchical structure of the embedded software on the Zynq platform is discussed, along with an exploration of the software development process within the Vitis environment. Finally, the software is segmented according to the hardware it controls, and a detailed description of the functions of each part and the driver APIs used is presented.


### main function and flowchart
The software's major tasks in this system include initializing the peripherals, reading/writing text files from the SD card, converting fractions in the text to 16-bit binary (and vice versa), and handling interrupt signals. Additionally, as stated in section X, the system needs to provide some user interaction capabilities for flexible configuration of signal sources and runtime control, which can be accomplished through serial port communication.
![[sw_flowchart.png]]
图x展示了该软件的flowchart。它实现了这样一种功能：用户将可执行软件下载到系统上后，KX134/Custom IP会被自动配置，使其buffer和interrupt被使能，其余重要参数被配置到本工作中的默认值，即，ODR为12800Hz，样本resolution为16bits，acceleration range 为 正负32g，Buffer threshold为60。在用户向串口输入任意字符后，程序才会继续运行，将KX134/Custom IP配置到工作模式，使其开始采样。每次收到watermark interrupt后，系统读取数据并将其转换为单位为m/s^2的小数后，会计算已处理的数据的数量。在该数量大于等于预先定义的一个文本文件中应当含有的sample size前，程序会持续等待下一个watermark interrupt。在完成全部处理后，软件会再次等待用户输入文件名并用任意按键激活采样。

Figure X shows the flow chart of the software that implements the following functions: Once the user downloads the executable software to the development board, the KX134/Custom IP is automatically configured. This configuration includes enabling the buffering function and the interrupt on pin INT1, while setting other important parameters to the defaults specified in this work. These defaults include an output data rate (ODR) of 12,800 Hz, a sample resolution of 16 bits, an acceleration range of ±32g, and a buffer threshold of 60. then The program waits for user input via the serial port, and only continues if any character input is received. At this point, the program configures the KX134/Custom IP into operational mode and begins the sampling process. Each time a watermark interrupt is received, the system reads the data, converts it to decimals with units of m/s^2, and counts the number of data processed. Before the processed data count reaches or exceeds a pre-defined sample size to be written to a text file, the program continues to wait for the next watermark interrupt. After all samples have been processed, the software again waits for the user to enter a file name and any character to start the sampling process.

### Layers of software on zynq
![[Pasted image 20231105220852.png]]
Chapter 3 introduces the Vivado design flow for hardware development. The synthesized hardware design exported from Vivado is referred to as the "hardware base system" or "hardware platform". As shown in Figure X, the software system consists of layered components built upon this foundation.

The lowest software layer is the Board Support Package (BSP), which contains hardware parameters, low-level drivers, and functions used by the operating system on the higher layer to communicate with the hardware.  Since the BSP is customized for a specific base system, any hardware design changes require re-importing the new design and regenerating the BSP in SDK.

The Operating System layer is positioned above the BSP. For Zynq platform, Xilinx supports various OS choices depending on application requirements, including fully-fledged options like Linux, real-time operating systems (RTOS) for time-critical application, or Xilinx Standalone – a lightweight “bare-metal” OS.

Standalone provides basic software modules to access processor-specific functions. For Zynq devices, Xilinx provides a Standalone platform that includes cache configuration, interrupt/exception handling, and other hardware-related functions. While Standalone allows for close control over code execution , it has limited capabilities suitable only for simple, repetitive software tasks. The application in this work fits these requirements and therefore is operated on the Standalone OS.

[8] Xilinx, Inc, “OS and Libraries Document Collection”, UG643
Xilinx Standalone Library Documentation: BSP and Libraries Document Collection UG643


### file structure

## AXI-I2C的使用
XIic_Send XIic_Recv
This function sends the data using polled I/O and blocks until the data has been sent. It only supports 7 bit addressing mode of operation. This function returns zero if bus is busy.  
此函数使用轮询的 I/O 和块发送数据，直到发送数据为止。它仅支持 7 位寻址操作模式。如果总线繁忙，则此函数返回零。Send data as a master on the IIC bus.

This function sends the data using polled I/O and blocks until the data has been sent. It only supports 7 bit addressing mode of operation. This function returns zero if bus is busy.

这是一组较为简单的api。由于本项目中总线上只有一个主机一个从机
## AXI-DMA的使用
### 应用中使用的驱动API

本应用程序中使用了如下用于操作AXI-DMA控制器的驱动函数：
XAxiDma_LookupConfig： 根据设备 ID 查找设备实例的硬件配置。这在具有多个 DMA 控制器的系统中至关重要。
AxiDma_CfgInitialize()：用通过XAxiDma_LookupConfig获得的配置参数初始化DMA控制器。在使用 DMA 引擎前必须调用该函数。初始化包括设置寄存器基地址、实例数据，并确保硬件处于静态。
XAxiDma_IntrEnable： 为 DMA 引擎启用中断。
XAxiDma_SimpleTransfer： 在 DMA 和设备之间发起Direct Register Mode下的传输事务。有从从 DMA 到设备和从设备到 DMA两个通道。设置缓冲区地址和传输字节长度即可启动传输。在上一次传输完成之前再次调用该函数将导致传输失败。因此，在询问用户下一个文件源之前，需要中断或轮询来确定传输已经完成。










XAxiDma_SimpleTransfer 函数为简单的一次性传输配置 DMA。它需要几个参数，包括发送和接收通道的缓冲区地址和长度。必须启用中断，以防止传输失败时过早重新调用该函数。


（Vitis Drivers API Documentation）
Simple DMA allows the application to define a single transaction between DMA and Device. It has two channels: one from the DMA to Device and the other from Device to DMA. Application has to set the buffer address and length fields to initiate the transfer in respective channel.
在应用中，驱动AXI-DMA控制器使用了以下API:
XAxiDma_LookupConfig 根据device ID, Look up the hardware configuration for a device instance. 在有复数个DMA控制器的系统中非常重要。
XAxiDma_CfgInitialize() 
This function must be called prior to using a DMA engine. Initializing a engine includes setting up the register base address, setting up the instance data, and ensuring the hardware is in a quiescent state.

XAxiDma_IntrEnable

XAxiDma_SimpleTransfer 当上一次传输尚未结束时，再次调用会使传输失败。因此需要interrupt确定传输结束 才能向用户询问下一个文件源
### comparison between AXI-DMA and AXI-Stream FIFO

The AXI-DMA IP block can read from DDR RAM independently and on its own after instruction to do so. It then streams the data out the AXI-Stream port.
The AXI Streaming FIFO IP block has internal memory that you can fill up under processor control and it then also streams the data out the AXI-Stream port. 

The process of transferring data from the PS to the PL using AXI Streaming FIFO consists of the following steps: Firstly, check available space using XLlFifo_TxPutWord. Next, write words one by one into the FIFO using XLlFifo_TxPutWord. Once all the data has been written, stream out the AXI-Stream data of a user-specified length byXLlFifo_iTxSetLen. Since the maximum depth of the FIFO buffer is not enough to hold all the vibration data, a complete vibration signal period consisting of 30000 samples needs to be divided into multiple batches for transmission. Moreover, frequent concurrent interrupts from the FIFO and custom IP's require interleaved data sending and reading, complicating the interrupt handling.

In contrast, AXI-DMA controller requires the processor to issue only one instruction that specifies the source address and transmission length. Data is automatically fetched  from memory and transmitted without the involvement of the processor. The IP's internal counter tracks the actual transfer length and generates a completion interrupt to notify the PS when the amount of data transferred has reached the configured length.

Using AXI DMA, it is straightforward to implement the following functionality: The application program reads a text file specified by the user, writes the data into the storage, then passes the first address of this storage block and length of the block to the DMA controller. The DMA controller independently streams data to the custom IP while the timing of transmission is also controlled by the READY signal of the custom IP as a AXI-Stream slave. The PS only need to handle the buffer watermark threshold interrupt from the custom IP. After the entire text file is sent, the application requests another filename from the user.




## SD读写
### Fatfs
## Interrupt
如章节\label{sec:recorder ips}中介绍过的一样，zynq的PS侧有硬件实现的general interrupt controller ,which is based on the non-vectored ARM General Interrupt Controller Architecture v1.0. Vitis中提供了Standalone OS下操作GIC的驱动scugic. 
Xparameter中的以下参数在本应用中会被用到 
XPAR_FABRIC_IRQ_F2P_0_INTR  Custom IP发出的中断的编号
XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR AXI-DMA的MM2S通道发出的中断的编号
XPAR_SCUGIC_SINGLE_DEVICE_ID GIC的器件编号

XScuGic_CfgInitialize
XScuGic_SetPriorityTriggerType
XScuGic_Connect
XScuGic_Enable


收到interrupt后先屏蔽，设置对应flag。并发出指令，从Sample Buffer中读出Threshold数量的加速度数据。处理程序中被使用的CallBackRef是存储区中接收读出的数据的缓冲区地址。
static void KX134_IntrHandler(void *CallBackRef) {
  u8 *Dataout_addr = (u8 *)CallBackRef;
  XScuGic_Disable(&Intc, KX134_INTR_ID);
  Watermark_flag = 1;
  xil_printf("GET KX134 INTR\r\n");
  XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, &BUF_READ_ADD, 1,
            XIIC_REPEATED_START);
  XIic_Recv(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, Dataout_addr, 360,
            XIIC_STOP);

  XScuGic_Enable(&Intc, KX134_INTR_ID);
}

DMA中interrupt原因更复杂，收到interrupt后通过读对应IRQ寄存器确定Interrupt类型，如果是传输完成则清除interrupt，否则报错
static void DMA_IntrHandler(void *CallBackRef) {
	u32 IrqStatus;
		XAxiDma *AxiDmaInst = (XAxiDma *) CallBackRef;
		xil_printf("GET MM2S INTR\r\n");
		/* Read pending interrupts */
		IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);
		/* Acknowledge pending interrupts */
		XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);
		if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
			xil_printf("send done\n");
			XScuGic_Disable(&Intc, DMA_INTR_ID);
		}
		else {
			xil_printf("Error in DMA RX \r\n");
		}
}


SCUGIC
The general interrupt controller is based on the non-vectored ARM General Interrupt 
Controller Architecture v1.0.
The controller manages interrupts that are sent to the CPUs from the PS and the PL. It is 
a centralised resource, and is capable of enabling, disabling, masking and prioritising 
interrupt sources, sending them to the appropriate CPU(s) in a programmed manner as the 
next interrupt is accepted by the CPU interface [5]. The controller also supports security 
extension for the implementation of a security-aware system [5].
GIC registers are accessed via the CPU private bus which ensures fast read/write 
response times by avoiding bottlenecks and temporary blockages in the interconnect [5]. 
All interrupt sources are centralised by the interrupt distributor before the one with the 
highest priority is dispatched to the individual CPUs. The GIC also ensures that an interrupt that targets more than one CPU can only be taken by a single CPU at a time. A 
unique interrupt ID number identifies each interrupt source, and have their own configurable priority and list of targeted CPUs [5]. 
Further information on the GIC can be obtained from the ARM Generic Interrupt 
Controller Architecture Specification [1]

Interrupts between the PS and PL are controlled by the Generic Interrupt Controller 
(GIC), which supports 64 interrupt lines. Six interrupts are driven from within the APU, 
including the L1 parity fail, L2 interrupt and Performance Monitor Unit (PMU) interrupt (zynq book)

查找相应配置并初始化GIC，配置两个Interrupt,此处两个都设置为 Rising edge sensitive 。而watermark interrupt具有更高的优先级。
XScuGic_Connect 用于Makes the connection between the Int_Id of the interrupt source and the associated handler that is to run when the interrupt is recognized.

The argument provided in this call as the Callbackref is used as the argument for the handler when it is called.



#   
Getting Started with Vivado and Vitis for Baremetal Software Projects
https://digilent.com/reference/programmable-logic/guides/getting-started-with-ipi


硬件补充
SCL尽管是I2C总线时钟信号，在该系统中不被当时钟使用。系统时钟远快于SCL，对SCL的上升下降沿进行检测，获得与系统时钟同步的上升下降沿信号。
消抖后检测上升下降沿 检测开始结束 状态机 
register map有另一个状态机 idle getdata writedata
在模块已经被写入一个有效的地址后
如果收到读请求 getdata  收到valid信号 writedata 并寄存当前的data_from_master_reg
getdata中检测当前地址是普通register还是BUF。是BUF的话将fifo_din的值给data_to_master_reg,否则从register map中取出对应值。
writedata中将被寄存的数值写进地址对应的寄存器中

尽管SCL提供了I2C总线的时序信息，但为了在系统中尽量避免跨时钟域问题，整个PL部分使用同一个时钟。由于应用的系统时钟远快于SCL，且作为从机，custom IP不需要驱动SCL，只需要获得SCL的时序信息，因此用对SCL进行边沿检测取代将SCL作为时钟信号是可行的。该边沿检测逻辑基于register延时，在SCL的上升沿或下降沿上，会生成对应的同步脉冲信号，供内部逻辑使用。
为了简化I2C状态机状态转移的判断条件，该模块中也会根据I2C协议的规定生成START与STOP脉冲信号。具体生成逻辑如下：


red req生成在get_address_and_cmd状态，只高一个时钟周期
data valid生成在读取最后一位的时钟周期，只高一个时钟周期 否则会多次激活读写operation。为保证数据的可靠性，应该在valid有效时寄存其值。


## conversion
如章节x所述，本工作中的acceleration data 的范围被设置为正负32g， 此处g的取值为9.81。而Python中生成的振动信号是与g无关的，以m/s^2为单位的加速度。因此，无论是采集真实加速度数据，还是模仿KX134，将Python生成的振动信号最终输出到I2C总线上，都必须完成原始加速度数据和16bit数据之间的相互转换：

KX134中的16bits数据与原始加速度的关系在Range为32时是：

在本程序中，定义了一个 acc_factor = (1.0f / 32767.0f) * 32.0f * 9.81f; 通过AXI-IIC读取到u8（8bit unsigned）类型的数据后，对其进行如下处理：
XOUT = (DATAOUT[1 + 6 * j] << 8) + DATAOUT[0 + 6 * j];

        YOUT = (DATAOUT[3 + 6 * j] << 8) + DATAOUT[2 + 6 * j];

需要注意的是，XOUT,YOUT,ZOUT的类型是int16_t，即signed 16bits数据。而在将原始数据转化为两个8位的数据并装入与AXI-DMA线宽一致的32bit存储空间时，则要进行以下操作：          


其中rounded是来自c语言标准library中的mathematical function，能将小数四舍五入为整数。而atof可将字符串转换为double类型的小数。通过移位和位逻辑运算，使两个buffer数组中两个相邻的元素的最低八位分别为数据的高八位和低八位。

上文中介绍了在软件如何setups the interrupt system，正确配置interrupt并将其与对应的handler连接。接下来，系统中两个中断发生后，软件要在handler中如何处理它们会被介绍。
The custom IP/KX134 handler performs several tasks upon receiving an interrupt. 首先，该中断会被暂时masked，避免多次触发中断处理程序。Then 它通过 AXI-IIC的驱动向从机地址0X1F写入0x63，在START REPEAT后再从该地址读出6 bytes*THRESHOLD个数据，然后it sets the Watermark\_flag to 1,以通知主程序有 new data avaliable for process,最后重新使能该中断。在前文所述的u8 to float conversion开始后，watermark_flag会在主程序内被回置为0。

对 DMA engine interrupt handling的标准流程 is more complex due to the multiple potential causes of an interrupt. 在进行MM2S传输时，有DMA Internal Error，DMA Slave Error，DMA Decode Error和transfer Complete四种中断原因。通过读取MM2S_STATUS，可以确定导致中断发生的event，然后需要通过把对应的位数置为0以deassert该中断。在完成上述任务并确定导致中断的原因是transfer Complete后，程序会打印一条信息以通知用户. Otherwise 它打印一条信息以 reports an error. （PG021）

### section{Data Processing and Software Control}
在对PL端的模块和PS自身的硬件进行配置与控制的基础上，软件还要完成用户交互、复杂的控制和难以在FPGA上实现的运算。这些内容将在本section中被介绍。
The previous section introduces how the software sets up the interrupt system, configures interrupts correctly, and connects them to the corresponding handlers. The following section focuses on the handling of these interrupts within the system, in particular the operations within the handlers.

The IP/KX134 custom interrupt handler performs a number of tasks when an interrupt is received. First, it temporarily masks the interrupt to prevent multiple triggering of the interrupt handler. It then communicates with the slave address 0x1F through the AXI-IIC driver, writing 0x63 to the slave device as a register address and then reading 6 bytes * THRESHOLD data from this address after a START REPEAT signal. Then it sets the watermark flag to 1, notifying the main program that new data is available for processing. Finally, it re-enables the interrupt. During the u8 to float conversion described before, the watermark_flag is reset to 0 within the main program. 该handler中的Callbackref是用于接受从AXI-IIC中读到的 6 bytes * THRESHOLD个数据的buffer的地址。

The standard procedure for handling DMA engine interrupt is more complicated due to the different possible causes of an interrupt. During MM2S transfers, there are four possible interrupt sources: DMA Internal Error, DMA Slave Error, DMA Decode Error, and Transfer Complete. By reading the MM2S_STATUS register, the event causing the interrupt can be identified and the corresponding bit must be cleared by writing the corresponding bit to 0 to de-assert the interrupt. Once these tasks are completed and it is determined that the cause of the interrupt is a Transfer Complete event, the program prints an informational message to notify the user. Otherwise, it prints an error message (PG021). 该handler中的Callbackref是主程序中AXI-DMA Instance结构体的指针。

在zynq平台上，软件的标准输入输出会被映射到板上的UART控制器。将ZC706板上的USB-UART port用microusb-usb线与host PC连接，通过serial port therminal，正确设置Baud率后即可接收到软件中打印的信息，或者向软件输入信息。该程序中，输入输出除了打印调试信息外，还给用户runtime配置提供了可能。首先，用户会被要求输入作为信号源的文本文件的名字。在完成对KX134的配置后， getchar()。这个standard C function会从标准输入（stdin）中读取一个字符，当stdin buffer是空的时，该函数会等待直到用户输入任意字符。这使用户有能力控制KX134何时开始采样，或者signal generator何时开始生成数据，如\ref所述。

软硬件联合设计中，软件的首要任务是对硬件进行初始化，并通过AXI-Lite端口读写硬件的寄存器，完成对硬件的控制。如上文所述，在Standalone OS中，vitis根据导入的硬件生成了一系列可供用户调用的API，使用户无需从寄存器层面确定对硬件进行配置的流程和信息。下文将介绍软件实现中针对硬件进行的操作：