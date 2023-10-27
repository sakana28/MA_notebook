#writing 

在本章节，首先需要讨论该Signal recorder系统应有的功能，并对这些功能进行PS-PL实现的划分。 为了与KX134进行通信，首先一定需要I2C接口。通过查询ZC706的User Guide可知，ZC706 evaluation board implements PL-和PS-side 各自一个 I2C port on the Zynq SoC,但它们接入了板上已有的I2C Bus中，用于与固定在板上的I2C器件如EEPROM通信。因此，KX134与Zynq Soc只能通过连接到PL端的GPIO Header实现。
 
另一方面，被采集到的信号应当被存储起来，方便进行进一步的分析处理。这一目的可以通过ZC706板子上的SD卡槽实现。因此，被读取的KX134的数据必须进入PS区，以被写入SD卡中。所以应当使用AXI-IIC IP核，同时完成I2C接口实现与数据在PL-PS间传输两项任务。 除此之外，该Signal recorder应可以由用户在程序运行时控制采样的开始。在Zynq PS中，应用程序中的scanf和printf函数都会默认使用PS Uart.因此，通过板上的usb-uart接口和PC中的serial device terminal可以简单地实现PC端对PS上程序的控制。

图（）展示了该Signal recorder设计的block diagramm。KX134的配置信息在运行在PS中的Application中被定义，并通过AXI4总线被传送到AXI-IIC IP核中，再被转换为I2C信号写入KX134中。通过USB-UART接口，用户可以在PC上的 serial device terminal中控制加速度信号采集的开始。而加速度信号被画面最右端的KX134采集，当Buffer中的样本达到阈值是，KX134的INT1 pin上生成一个高电平的interrupt。该Interrupt通过FPGA上的GPIO Pin连接到PS端的IRQ_F2P port。它会激活PS中相对应的interrupt service routine，以对KX134的Buffer中的加速度数据进行读取。读取出的数据会以文本文档的形式存储在SD卡中。 
 
In this section, the desired functions of the Signal Recorder system are first discussed, followed by dividing the implementation of these functions into the PS- and PL-side. 

Firstly, to communicate with the KX134 accelerometer, an I2C interface is absolutely necessary. The ZC706 evaluation board implements one I2C port on both the PL- and PS-side of the Zynq SoC. However, they are connected to an existing I2C Bus in order to communicate with I2C devices (e.g. EEPROM) that are fixed on the board. Therefore, the KX134 can only connect to the PL-side of Zynq SoC through the GPIO Header. 

On the other hand, the recorded signals need to be stored for further analysis and processing, which can be conveniently done via the SD card slot on the ZC706 board. Thus, the acceleration data must be transferred to the PS-side to be written to the SD card. For this purpose, the AXI-IIC IP core is used for both the I2C interface implementation and the data transfer between PL and PS. 

Additionally, the signal recorder should allow the user to control sampling initiation at runtime. In Zynq embedded system, the scanf and printf functions in applications use the PS Uart by default. So controlling the program running on a PS from a PC is easily realized via the on-board USB-UART interface and a serial device port on the PC. 

Figure () shows the system block diagram for this signal recorder design. The configuration of KX134 is determined in the application program running in the PS and transmitted over the AXI4 bus to the AXI-IIC IP core. This IP core converts the configuration data to I2C signals and writes it to the specific registers of KX134. When the user inputs a specific command to the PS via the serial port on the PC, the PS writes a control signal to CNTL1 via the AXI-IIC to activate sampling. Once the number of samples in the Buffer reaches a threshold, the KX134 generates an interrupt on its INT1 pin. This pin is connected to the IRQ_F2P port on PS through a GPIO pin on PL, which will trigger the interrupt service routine in PS to read the acceleration data. Finally, the data is stored as text files in the SD card. 

关于如何在Zynq嵌入式系统中对SD卡进行读写将会在第四章节中详细阐述。接下来将着重介绍为了实现该设计，在Vivado中应当添加哪些硬件模块，并如何对其配置。

PS端的
fatfs在软件章节 PS PS PS部分除电源引脚外的引脚信息如下图所示。从这里可以看出来，PS部分的引脚除了电源、地、时钟、复位和DDR专用引脚外均为Multiuse I/O(MIO)引脚. 

Vitisprintf