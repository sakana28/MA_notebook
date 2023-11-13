#writing 


[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

This chapter introduces the software programs running on the PS-site in this work. As the hardware is designed to emulate the functionality of the KX134 accelerometer, the signal generator software completely covers the functionality of the signal recorder software.The code used for sensor configuration and reading acceleration data from the sample buffer in watermark interrupt mode is identical between the two design. Therefore, following sections focus only on the structure and implementation of the signal generator software.

在本章节中，首先会该软件实现的预期中的功能和算法的概览。之后会介绍Zynq上嵌入式软件的层次及在vitis中编写软件的流程。最后根据控制的硬件的不同，对软件进行了划分并详细介绍了各个部分的功能及使用的驱动APIs。

The software's major tasks in this system include initializing the peripherals, reading/writing text files from the SD card, converting fractions in the text to 16-bit binary (and vice versa), and handling interrupt signals. Additionally, as stated in section X, the system needs to provide some user interaction capabilities for flexible configuration of signal sources and runtime control, which can be accomplished through serial port communication.

### Layers of software on zynq
![[Pasted image 20231105220852.png]]
Chapter 3 introduces the Vivado design flow for hardware development. The synthesized hardware design exported from Vivado is referred to as the "hardware base system" or "hardware platform". As shown in Figure X, the software system consists of layered components built upon this foundation.

The lowest software layer is the Board Support Package (BSP), which contains hardware parameters, low-level drivers, and functions used by the operating system on the higher layer to communicate with the hardware.  Since the BSP is customized for a specific base system, any hardware design changes require re-importing the new design and regenerating the BSP in SDK.

The Operating System layer is positioned above the BSP. For Zynq platform, Xilinx supports various OS choices depending on application requirements, including fully-fledged options like Linux, real-time operating systems (RTOS) for time-critical application, or Xilinx Standalone – a lightweight “bare-metal” OS.

Standalone provides basic software modules to access processor-specific functions. For Zynq devices, Xilinx provides a Standalone platform that includes cache configuration, interrupt/exception handling, and other hardware-related functions. While Standalone allows for close control over code execution , it has limited capabilities suitable only for simple, repetitive software tasks. The application in this work fits these requirements and therefore is operated on the Standalone OS.

[8] Xilinx, Inc, “OS and Libraries Document Collection”, UG643
Xilinx Standalone Library Documentation: BSP and Libraries Document Collection UG643


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




