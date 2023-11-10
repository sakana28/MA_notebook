#writing 

 
In this section, the desired functions of the Signal Recorder system are first discussed, followed by dividing the implementation of these functions into the PS- and PL-side. 

Firstly, to communicate with the KX134 accelerometer, an I2C interface is absolutely necessary. The ZC706 evaluation board implements one I2C port on both the PL- and PS-side of the Zynq SoC. However, they are connected to an existing I2C Bus in order to communicate with I2C devices (e.g. EEPROM) that are fixed on the board. Therefore, the KX134 can only connect to the PL-side of Zynq SoC through the GPIO Header. 

On the other hand, the recorded signals need to be stored for further analysis and processing, which can be conveniently done via the SD card slot on the ZC706 board. Thus, the acceleration data must be transferred to the PS-side to be written to the SD card. For this purpose, the AXI-IIC IP core is used for both the I2C interface implementation and the data transfer between PL and PS. 

Additionally, the signal recorder should allow the user to control sampling initiation at runtime. In Zynq embedded system, the scanf and printf functions in applications use the PS Uart by default. So controlling the program running on a PS from a PC is easily realized via the on-board USB-UART interface and a serial device port on the PC. 

Figure () shows the system block diagram for this signal recorder design. The configuration of KX134 is determined in the application program running in the PS and transmitted over the AXI4 bus to the AXI-IIC IP core. This IP core converts the configuration data to I2C signals and writes it to the specific registers of KX134. When the user inputs a specific command to the PS via the serial port on the PC, the PS writes a control signal to CNTL1 via the AXI-IIC to activate sampling. Once the number of samples in the Buffer reaches a threshold, the KX134 generates an interrupt on its INT1 pin. This pin is connected to the IRQ_F2P port on PS through a GPIO pin on PL, which will trigger the interrupt service routine in PS to read the acceleration data. Finally, the data is stored as text files in the SD card. 

### IP Core
Chapter 4 explains the software programming of the Zynq Embedded System in Vitis IDK. Following section focuses on the hardware modules that need to be integrated into Vivado to realize the functionality of the system, and how to configure them properly.

#### zynq ip CORE 
 
 The first step is to add the ZYNQ7 Processing System IP core in block design, which serves as an interface between the non-FPGA processing system components and the FPGA-implemented IP blocks, unlike soft processor IPs such as MicroBlaze. 
![[Pasted image 20231029205206.png]]
![[Pasted image 20231030021109.png]]
(from internet replace later)
It provides key capabilities including:
- Peripheral and AXI port configuration
- MIO pin allocation
- DDR memory and clock configuration
- Interrupts control configuration
- Interconnect logic between Vivado IP and PS
##### MIO
Within the PS component, the pins, apart from power, ground, clock, reset, and DDR-specific pins, are all designated as Multiuse I/O (MIO) pins. The PS can support a maximum of 54 MIO ports. The configuration wizard provides the user with the ability to select the peripheral ports to be connected to MIO ports. The flexibility of MIO greatly facilitates diverse board designs. If additional MIOs are required, designers can also enable EMIO, allowing the PS to utilize PL pins for peripheral connections.
##### Interrupt
PS IP core enables routing of interrupts from the PL peripherals and custom logic to trigger software handlers in the PS. Both private peripheral interrupts (PPI) and shared peripheral interrupts (SPI) are supported. the Generic Interrupt Controller (GIC) built into the PS manages interrupt handling for both cores. It ensures interrupts are handled sequentially by only one core based on configured priority levels. It also implements interrupt distribution schemes for multi-core coordination. PL peripherals and logic can leverage the GIC via the IRQ_F2P port on Zynq7 PS IP. In this project, SPI is used to notify the PS of buffer watermark events.



##### AXI-port

The ZYNQ chip internally implements the AXI bus protocol, featuring nine physical interfaces, including four AXI-GP interfaces, four AXI-HP interfaces, and one AXI-ACP interface.
The different AXI port types suit various applications:
- AXI General Purpose (GP) - master/slave ports for PS accessing PL peripherals or vice versa
- AXI High Performance (HP) - High-throughput slave ports allowing PL masters like DMA controller to access PS DDR memory or On-chip memory
- AXI Accelerator Coherency Port (ACP) - For hardware accelerators in the PL to access cached data in the PS

This signal recorder system utilizes the AXI GP master port for the PS to communicate with the I2C peripheral in the PL. The master initiates transactions via an AXI interconnect bridge to the I2C controller slave in the FPGA fabric.

##### configuration 
The PS configuration streamlines integration but requires configuring key parameters like interrupts, clocks, and AXI ports. The board definition file from the manufacturer  automatically customizes settings like MIO pin multiplexing and DDR configuration to match the base Zynq design for the target board. Notably, key settings like clocks, AXI ports and PL-PS interrupt required in this project must be manually specified. For this project, a 100 MHz clock is supplied to the PL fabric, which is generated by the PS. 


