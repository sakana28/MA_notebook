#writing 

 
In this section, the desired functions of the Signal Recorder system are first discussed, followed by dividing the implementation of these functions into the PS- and PL-side. 

Firstly, to communicate with the KX134 accelerometer, an I2C interface is absolutely necessary. The ZC706 evaluation board implements one I2C port on both the PL- and PS-side of the Zynq SoC. However, they are connected to an existing I2C Bus in order to communicate with I2C devices (e.g. EEPROM) that are fixed on the board. Therefore, the KX134 can only connect to the PL-side of Zynq SoC through the GPIO Header. 

On the other hand, the recorded signals need to be stored for further analysis and processing, which can be conveniently done via the SD card slot on the ZC706 board. Thus, the acceleration data must be transferred to the PS-side to be written to the SD card. For this purpose, the AXI-IIC IP core is used for both the I2C interface implementation and the data transfer between PL and PS. 

Additionally, the signal recorder should allow the user to control sampling initiation at runtime. In Zynq embedded system, the scanf and printf functions in applications use the PS Uart by default. So controlling the program running on a PS from a PC is easily realized via the on-board USB-UART interface and a serial device port on the PC. 

Figure () shows the system block diagram for this signal recorder design. The configuration of KX134 is determined in the application program running in the PS and transmitted over the AXI4 bus to the AXI-IIC IP core. This IP core converts the configuration data to I2C signals and writes it to the specific registers of KX134. When the user inputs a specific command to the PS via the serial port on the PC, the PS writes a control signal to CNTL1 via the AXI-IIC to activate sampling. Once the number of samples in the Buffer reaches a threshold, the KX134 generates an interrupt on its INT1 pin. This pin is connected to the IRQ_F2P port on PS through a GPIO pin on PL, which will trigger the interrupt service routine in PS to read the acceleration data. Finally, the data is stored as text files in the SD card. 

### IP Core
Chapter 4 explains the software programming of the Zynq Embedded System in Vitis IDK. Following section focuses on the hardware modules that need to be integrated into Vivado to realize the functionality of the system, and how to configure them properly.

#### zynq ip CORE 
 
 The first step is to add the ZYNQ7 Processing System IP core, which unlike soft processor IPs such as MicroBlaze, serves as an interface between non-FPGA processing system components and the FPGA-implemented IPs. 
![[Pasted image 20231029205206.png]]
![[Pasted image 20231030021109.png]]
(from internet replace later)
 该IP核主要具有以下功能：
 - Enable/Disable I/O Peripherals (IOP)
- Enable/Disable AXI I/O ports (AIO)
- MIO Configuration
- Extended MULTIPLE USE I/Os (EMIO)
- DDR Configuration
- Security and Isolation Configuration  
- Interconnect Logic for Vivado IP - PS interface
- PL Clocks and Interrupts
##### MIO
PS部分的引脚除了电源、地、时钟、复位和DDR专用引脚外均为Multiuse I/O(MIO)引脚. PS最多处最多可提供 54 个 MIO 端口。The wizard allows user to choose the peripheral ports to be connected to MIO ports。如果需要更多MIO，用户还可以开启EMIO，即使PS端使用PL端的管脚与peripheral连接。
##### Interrupt
PL 可异步向 PS 发出多达 20 个中断信号。其中4个中断属于private peripheral interrupt (PPI) ，该中断只对指定的core有效，其余16 个中断信号是shared peripheral interrupt(SPI),该中断来源于外设并映射到中断控制器，每个中断信号可以被设置优先级，且可以对所有的core有效。还有一类中断 Software Generated Interrupt（SGI）不来自于PL。软件向PS中的Generic Interrupt Controller(GIC)的指定寄存器中写入信息可以生成这样的中断。GIC确保针对多个CPU的中断一次只能由一个CPU执行，且优先级较高的中断先被执行。本工作中使用的中断是SPI。


The board definition file from the manufacturer automatically configures the Zynq PS IP with appropriate parameters and establishes connections between Multipurpose I/O (MIO) pins and board peripherals. Notably, the PL to PS interrupt required in this project must be manually enabled by the user. 


#### BSP 
 
The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
 
PS端的
fatfs在软件章节

Vitisprintf