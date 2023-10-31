#writing  #hw_implementation #implementation 



# Introduction
Rolling bearings, also known as rolling element bearings, are critical mechanical components used in various engineering systems and industries. They facilitate the relative motion between components while reducing friction to ensure machinery functions optimally. Nevertheless, constant internal component movement can cause wear and tear leading to failures in the long haul. Thus, ensuring effectiveness in monitoring and detecting faults is essential for sustained reliability and longevity.

Vibration analysis is one of the most important and reliable techniques for monitoring the condition of rolling bearings. Through analysis of operational vibrations, engineers can identify unusual patterns, detect potential faults, and schedule maintenance before catastrophic failures. However, the lack of comprehensive experimental data sets hinders rigorous development and validation of the technique.

This has made simulated signals extremely useful for detecting faults in rolling bearings. Simulated signals are easily generated and convenient for validating new analysis techniques. The advantage of the use of simulated signals is obvious, as they are accessible within the same software environment in which the monitoring techniques are being developed, such as MATLAB. [*A tool for validating and benchmarking signal processing techniques applied to machine diagnosis*]

To develop a real-time monitoring system, it is crucial to have a signal generator and recorder as emulation platform that can seamlessly integrate simulated signals. In order to build such a system and facilitate adding or modifying features as needed, Field-Programmable Gate Arrays (FPGAs) were chosen as the solution. FPGAs are widely used due to their flexibility in implementing communication protocols and hardware functionalities, which enables rapid development for specific requirements.

The Xilinx Zynq system-on-chip (SoC), which combines FPGA fabric with ARM processors, offers extra advantages over traditional FPGA solutions. It not only provides the hardware flexibility of FPGAs but also integrates it with the software flexibility of ARM processors. This enables engineers to easily develop and implement complex dynamic control on their hardware design.

The goal of this work is to implement and evaluate a  Zynq-based signal generator and recorder, which is encompasses Python-based simulated signals models, embedded applications developed in C, and hardware modules  in VHDL. 

This work is organized as follows: Chapter 2 introduces the rolling bearing vibration signal model and provides basic insight into the Zynq architecture. Chapter 3 provides a brief overview of the functionality and operation of the evaluated KX134 accelerometer. This chapter also describes in detail the hardware components of the system developed to emulate the functionality of the KX134, including both IP cores provided by Xilinx and custom IP cores. Chapter 4 outlines the software development process for the system and explains its interaction with the hardware modules.In Chapter 5, a evaluation of the system is performed, taking into account factors such as power consumption, FPGA resource utilization, and overall performance. The final chapter provides the conclusion of this paper. 
# Fundamentals
This chapter presents an overview of cyclostationary signals and introduces a vibration signal model for rolling element bearings. The model is based on the concept of cyclostationary signals and serves as the foundation for subsequent work. Next, the Zynq SoC architecture and the ZC706 development board used in this thesis are also introduced.
## Vibration signal model
[[about Model]]
#writing #fundamental 

11.10.23 first change in draft  
### Cyclostationary
Cyclostationary signals are non-stationary signals with periodic time-varying mean and autocorrelation. An example of a cyclostationary signal is random noise that is amplitude modulated by a periodic function. This concept is important in the analysis of bearing fault signals, as cyclostationarity indicates the presence of a fault. This is because defects on a rotating surface produce repetitive impacts, causing the statistical properties of the resulting vibration signal to be periodic. While the slips between the bearing elements add randomness, the overall periodic pattern of impulses persists, rendering the signal pseudocyclostationary. This enables the use of cyclostationary analysis methods for diagnosing bearing defects. ("Differential Diagnosis")
### Vibration signal models
When a rotating surface contacts a localized fault, it generates an impulse that excites the structural resonances of the bearing or the vibration sensor itself. The repetitive impulses lead to a sequence of responses that are amplitude modulated due to the various structural modes of the system. Based on this understanding, in early work, the vibration produced by a single point defect was modeled as follows: (P.D. McFadden, J.D. Smith, Model for the vibration produced by a single point defect in a rolling element bearing)
![[Pasted image 20231019223859.png]]
- h(t): the impulse response of a single impact measured by the sensor
- q(t): the modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement. It is periodic, i.e q(t)=q(t+T).
- T: the interval between successive impacts
- n(t): the background noise
This model explains the non-stationarity of the vibration signal by amplitude modulation due to different factors (differential diagnosis). The interval T between impacts is determined by both the type of fault and the bearing geometry. To calculate this period, Table 1 shows typical fault frequencies (P.D. McFadden, J.D. Smith, Model for the vibration produced by a single point defect in a rolling element bearing). 

However, the model neglected the random slips of the rolling elements. It wrongly assumed that the impact intervals were identical. In fact, even small random fluctuations would disrupt the harmonic structure of the above model. Therefore, based on earlier work, Antoni proposed a more realistic model (Antoni, Facts and fictions, 2006):

![[Pasted image 20231005065439.png]]

- τi: the inter-arrival time of the ith impact, accounting for randomness due to rolling element slips
The other parameters in (2) have the same meaning as in (1).

However, when a defect spreads over a large area, the resulting vibration signal is no longer caused by impulses and the random timing jitter is also meaningless. This differs from the pseudo-cyclostationary vibration signals caused by localized faults, leading to a purely cyclostationary process.
In this case, the vibration signal from a distributed fault in a bearing is expressed as:（‘Differential Diagnosis）
![[Pasted image 20231005065448.png]]

The two terms in the equation are: 
- p(t): the periodic components like shaft and stiffness variations
- B(t): the pure cyclostationary random component with an expected value of 0. [Estimation of Cyclic Cumulants of Machinery Vibration Signals in Non-stationary Operation]
### Numerical implementation
Based on these models, algorithms and Octave script code for numerical implementation of simulated vibration signals have been proposed in the work of G. D'Elia.  (Step-by-step) Figure ( ) demonstrates the procedure for generating vibration signals from localized faults, while Figure ( ) depicts the same process for distributed faults, according to the proposed algorithms.

As proposed by Ho and Randall (ho2000), the vibration signal from a localized bearing fault can be modeled as a series of impulse responses of a single-degree-of-freedom (SDOF) system. The timing between impulses has a random component to simulate the slippery effect. This model was adopted in G. D'Elia's work.(stepbystep)

The numerical implementation of the localized fault vibration signal model has the following user-defined parameters:
- Speed profile
- Bearing geometry parameters: bearing roller diameter , pitch circle diameter , contact angle, number of rolling elements 
- Fault location：inner, outer or ball 
- Signal discretization parameters : number of points per revolution与sample frequency of the time vector
- Variance for the generation of the random contribution
- SDOF system properties: stiffness， damping coefficient， natural frequency，length of the SDOF response
- Signal-to-noise ratio (SNR) of background noise
- Amplitude modulation due to load

![[Pasted image 20231005065627.png]]
The numerical implementation of the distributed fault vibration signal model requires the following additional parameters:
- Amplitude modulation at the fault frequency
- Amplitude value of the deterministic component related to the stiffness variation
- Amplitude value of the deterministic component related to the bearing rotation

![[Pasted image 20231005065536.png]]
The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.

In this work, operations like quadratic interpolation and generating random numbers from specified distributions are required to produce the desired signals. These operations are difficult to implement on an FPGA. Moreover, there is no need in subsequent work to dynamically configure the generated signals during system operation. Therefore, instead of generating the signals directly on the FPGA, a software-hardware codesign approach is taken. The stimulus signals are first generated in Python. The samples are stored as text files, which are then read by the Zynq PS through the SD card interface. The stored samples serve as the signal source for the signal generator implemented in programmable logic. Thus, the waveform generation and storage is separated from the real-time playback on the FPGA. Users can modify signal generation relevanted parameters in Python while the hardware interface remains unchanged. New stimuli files can be deployed by simply copying them to the SD card. 
## Zynq soc
The Zynq All Programmable System-on-Chip (APSoC) from Xilinx combines the adaptability of a general-purpose processor with the customizability of a field-programmable gate array (FPGA), resulting in a powerful platform that delivers high performance, flexibility, and scalability. One noteworthy feature of the Zynq architecture is its ability to program at the logic level, which includes logic processing units, signal processing blocks, and configurable memory areas tailored to specific tasks. This capability enables developers to create specific circuits, freeing up the processor for additional computational tasks.

The platform's structure, depicted in Figure {1.1}, consists of two primary parts: the Processing System (PS) and the Programmable Logic (PL). The FPGA fabric of the PL is based on the Artix®-7 and Kintex®-7 FPGAs and includes not only essential elements such as Configurable Logic Blocks (CLBs) and the switch matrix, but also DSPs and Block RAMs that extend the computational and memory capabilities.
![[Pasted image 20230928054544.png]]

（from Zynq 7000 datasheet）

The center of the PS consists of a dual-core ARM Cortex-A9 processor and a set of associated processing resources, including hardware floating point units, which together form the Application Processing Unit (APU). Furthermore, the PS includes peripheral interfaces, cache, memory interfaces, interconnect and clock generation circuitry.  [zedbook] This integrated system supports multiple real-time operating systems, such as Linux.

To facilitate high-speed communication between the PS and PL, Zynq provides several Advanced eXtensible Interface (AXI) ports, including General Purpose Ports and High-Performance Ports, which will be discussed in the following chapters. Furthermore, interrupt signals facilitate PL to activate events that interrupt the operation of the processor, which enables flexible interaction between hardware and software.

### AXI4 

The AXI bus mentioned previously is part of the ARM AMBA® 3.0 open standard. It was originally developed by ARM and used for microcontrollers. Now it has become a widely adopted communication standard for SoCs. This bus is fully supported in the Xilinx development environment. Vivado provides numerous IP cores with AXI interfaces as well as interconnection controller IPs for arbitration.

The Zynq contains three types of AXI buses:
(1) AXI4-FULL targets high-performance address-mapped transaction，支持突发传输 
(2) AXI4-LITE provides a lightweight address-mapped single transaction interface that occupies minimal logic 
(3) AXI4-Stream enables high-speed streaming data transfers without address information, allowing unlimited burst transmissions 

The aforementioned address-mapped or memory-mapped means that when the master initiates a read or write operation, it must specify an address in the system memory space. Burst transmission means the Master only needs to specify the address of the first data word and burst length, etc. The Slave will then calculate the addresses of subsequent data based on this information.

Both AXI4 and AXI4-LITE buses have identical components consisting of five channels: 
read address channel (ARVALID, ARADDR, ARREADY); 
write address channel (AWVALID, AWADDR, AWREADY); 
read data channel (RVALID, RDATA, RREADY, RRESP); 
write data channel (WVALID, WDATA, WSTRB, WREADY); 
write response channel (BVALID, BRESP, BREADY).

By separating read and write channels, AXI4 implements full-duplex communication, allowing simultaneous read and write operations between two devices. Each of the five read/write channels contains its own handshake signals, which are fundamental to AXI buses and enable both sender and receiver to control transmission rates. As shown in the figure below, a valid transfer occurs at T3 when both READY and VALID signals are high on the rising clock edge. (AMBA AXI and ACE Protocol Specification)
![[Pasted image 20231031231242.png]]
## ZC706 evaluation board
[[about ZC706]]
![[Pasted image 20231006065127.png]]
Figure ( ) shows the development and testing setup with the Xilinx ZC706 Evaluation Kit. The ZC706 evaluation board by Xilinx offers a high-performance and flexible platform for developing a variety of embedded processing systems. The central component of the board is the XC7Z045 FFG900 - 2 SoC, featuring a dual-core ARM Cortex-A9 processor with 7-series programmable logic.  Key hardware specifications of the XC7Z045 comprise 218,600 lookup tables (LUTs), 437,200 flip-flops, 900 digital signal processor (DSP) slices, and 26.5 Mb block RAM, providing sufficient resources for complex digital systems.

The peripheral interfaces and connectivity of the ZC706 are crucial for data acquisition and generation applications. The board provides ample clock resources, diverse mainstream interface connectors, and User I/O. Key features utilized in this work include the Secure Digital (SD) card slot, DDR3 memory interfacing the processing system, serial communication through a USB-UART bridge, general-purpose input/output (GPIO) headers, and a JTAG port for FPGA programming.
## I2C Protocol

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock line(SCL) and the serial data line (SDA). The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. 

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 
### Open-drain and Duplex 
The I2C protocol is a half-duplex bus that facilitates bidirectional communication, using the same transmission lines for both data transmission and reception. However, simultaneous data exchange between the communicating devices is not possible. Only one controller or target device can transmit data on the bus at a single time. 

To efficiently facilitate bidirectional communication, the I2C specification dictates that both SDA and SCL lines are open-drain. Open-drain refers to an output type in which the line can be pulled low or released high. When there is no I2C device actively pulling the line low, pull-up resistors will elevate the line to the VDD level. This differs from push-pull outputs, whichcan result in short-circuits when multiple devices attempt to output conflicting high and low levels on the I2C bus at the same time. 
![[Pasted image 20231023032001.png]] ![[Pasted image 20231023023643.png]] Comparison Between Open-Drain and Push-Pull Contention
（from A Basic Guide to I2C）

On the other hand, open-drain outputs facilitate the implementation of wired-AND logic. The truth table for the wired-AND logic is shown in Table 1. A low output from any device connected to the bus will pull the whole bus low. Therefore, both SDA and SCL remain at high level when the bus is idle. The device that first pulls the bus level down gains control over the bus. If multiple masters try to transmit a 0 bit, the bus state will remain low as expected. When multiple masters attempt to initiate transmission, the bus state will remain low as expected if they all transmit low. However, if one master transmits a high while another transmits a low, the low bit will dominate and pull the bus low, indicating a collision. The master transmitting the 1 bit will detect this discrepancy and know that it lost arbitration, so it will stop transmitting. In this way, arbitration between multiple master devices is achieved in I2C.
![[Pasted image 20231023025331.png]] 

During pin assignment in hardware design, the I/O pins of the Zynq PL fabric can be configured with internal pull-up elements that pull undriven pins to a logic high state. Together with tri-state buffers, this implements the open-drain output required for I2C operation. However, the internal pull-up resistor and the pin parasitic capacitance, primarily from the package and PCB trace, form an unintentional resistive-capacitive (RC) delay element. This RC delay slows the signal edge transitions compared to a push-pull output with similar drive strength. That result in that I2C used for communication between low-speed devices. On the ZC706 board, the Zynq I/O pins connect to headers through a TXS0108E 8-bit bi-directional level shifter. According to the datasheet, this device supports maximum data rates of 110 Mbps for push-pull outputs versus only 1.2 Mbps for open-drain outputs. This speed limitation directly restricts the maximum SCL rate for this project. 

### Timing Sequence 
According to the I2C specification, data read operations occur when SCL is high, while SDA can change when SCL is low. Therefore, during data transmission, SDA should remain stable when SCL is high to avoid erroneous data sampling. 

### START and STOP Conditions 
SDA can only change when SCL is high during START and STOP conditions. A high-to-low transition of SDA when SCL is high indicates a START condition. A low-to-high transition of SDA when SCL is high indicates a STOP condition. The START condition occurs at the beginning of a transmission to wake up idle slaves on the bus. After the master initiates a START, all slaves transition from idle to active, waiting to receive an address. The STOP condition releases the bus for the next idle state after completing the transmission. In addition to the initial START, a Repeated START (Sr) condition can also occur. It is similar to a regular START but happens when the bus is busy instead of idle. The master uses it to initiate a new transmission while preserving control of the bus between transfers. 

### Byte Format
Each byte on the SDA data line must consist of 8 bits, with no limit on the number of bytes per transmission. After each data byte (8 bits), an acknowledgement (ACK) bit follows as the 9th bit. The byte order is most significant bit first. For a slave address byte, it comprises 7 address bits and 1 read/write control bit. Slave addresses are predefined and should be unique on the bus. Some I2C devices have configurable address bits, allowing multiple identical devices on the bus. 

### Acknowledgement
The protocol requires acknowledgements (ACKs) during data transfer. The receiver sends an ACK to indicate successful reception of a byte, after which the transmitter can send the next byte. There are two types of acknowledgement:
- A LOW level on the 9th acknowledge bit indicates an ACK. 
- A HIGH level on the 9th bit indicates a NACK (no acknowledge). 

When the master sends data, the slave generates the ACK. If SDA remains high when SCL is high during the 9th clock, the master can directly generate a STOP or ReSTART for a new transmission. When the slave sends data, the master generates the ACK. An ACK from the master means more data is expected. Once all desired data is received, the master sends NACK to tell the slave to stop sending data and release the bus and then sends a STOP to terminate the read operation. 

# hardware implementation

The signal generator mimics the key features of the KX134 accelerometer to generate artificial vibration data. As the KX134 is also utilized in the signal recorder for real vibration data acquisition, it is necessary to first discuss the specifications and interface of the actual sensor. After covering the KX134 background, this chapter will describe in detail the Zynq hardware realizations of both the signal recorder and signal generator systems implemented on the Zynq SoC. The individual hardware blocks and interconnect will be elaborated separately for each system.
## KX134 
The signal generator developed in this work emulates the functionality of the KX134-1211 accelerometer, which is also used for vibration data acquisition in the signal recorder. Therefore, this section provides background information on the basic capabilities and interface of the KX134 that are relevant to reproducing its operation. 

The KX134 from Kionix is a triaxial accelerometer from Kionix that is capable of measuring acceleration forces along the X, Y, and Z axes. User interaction with the KX134, including configuration and data acquisition, is enabled through either I2C or SPI communication protocols. By writing to specific registers, users can configure various parameters such as sensor range, output data rate, triggering options, and buffer size. 
### Pin assignments and description 
The pins of the KX134 accelerometer are shown in Table 1 below. 
![[Pasted image 20231101014816.png]]This work uses the KX134-1211-EVK-001 evaluation board to connect the sensor with other development platforms. A ribbon cable connects the sensor evaluation board to the FPGA development board.
### Embedded Registers 
The KX134 accelerometer has 128 8-bit registers that are mostly userprogrammable. Table 1 lists the available registers and their addresses. ![[Pasted image 20231010060519.png]]The upcoming section will provide a detailed description of the configuration registers associated with this project. 

### Registers configuration for watermark Interrupt mode
The Watermark Interrupt mode is an operating mode of the Accelerometer. samples are first stored in a buffer. Once the number of samples in the buffer reaches a user-defined threshold, a hardware interrupt is generated. In signal recorder, KX134 works in this mode. In signal generator, the behavior of the KX134 in this mode is emulated. Therefore, the registers that require to be configured in this mode will be introduced next. 
#### CNTL1 
The CNTL1 control register controls the main features of KX134. Before configuring other registers, CNTL1 must be used to set the accelerometer to stand-by mode. Once configuration is complete, CNTL1 is used to start data acquisition. The following bits are configured: 
![[Pasted image 20231026211805.png]]
- PC1: controls the operating mode.
	PC1 = 0 – stand-by mode 
	PC1 = 1 – High-Performance or Low Power mode
- RES: determines the performance mode of the KX134.
	RES = 0 – Low Power mode (higher noise, lower current, 16-bit output data) 
	RES = 1 – High-Performance mode (lower noise, higher current, 16-bit output data)
- GSEL 
#### ODCNTL 
The output data control register configures functionality and parameters related to the acceleration outputs. Most importantly, OSA[3:0] determines the sample rate of the accelerometer. 
![[Pasted image 20231026211835.png]]
![[Pasted image 20231026211927.png]]
#### INC1 
The interrupt control register configures the settings for the physical interrupt pin INT1. The following bits are configured: 
IEN1 
IEA1 
IEL1
![[Pasted image 20231026212033.png]]
#### INC4 
This register controls routing of an interrupt to the physical interrupt pin INT1. The following bit is configured for watermark interrupt mode: WMI1.
![[Pasted image 20231026213900.png]]
#### BUF_CNTL1 
This register contains the buffer sample threshold SMP_TH[7:0]. For 8-bit samples the maximum number of samples is 171, for 16-bit samples the maximum is 86.
![[Pasted image 20231026213915.png]]
#### BUF_CNTL2 
This register controls sample buffer operation. The following bits are configured: 
BUFE 
BRES
BM[1:0].
![[Pasted image 20231026215325.png]]
### communication via I2C 
As mentioned previously, the KX134 accelerometer communicates with host via I2C bus protocol. The 7-bit slave address of the KX134 consists of a 6-bit fixed portion and a 1-bit programmable section based on the logic level of the ADDR pin. Specifically, the accelerometer can be configured for an address of 0x1E when ADDR is grounded or 0x1F when ADDR is connected to VDD. Read and write transactions comply with to the I2C timing diagrams and format described earlier. Furthermore, the sequence shown in Figure () must be followed when accessing the KX134's internal registers. 

Notably, the KX134 supports an auto-increment feature for simplified sequential register access. During multiple read or write operations, the register address does not need to be resent as the pointer automatically increments to the next register. However, this feature is disabled when reading from the BUF_READ register (0x63) so that the host can continuously read samples from the buffer. 
![[Pasted image 20231026223543.png]]

## Hardware System design flow

With an understanding of the KX134's fundamental features and communication protocols, the signal recorder system can now be constructed on the Zynq platform. This section will present a detailed introduction of the design flow for developing the system on the Zynq, the implemented functionality , and key hardware design components.

### workflow

The overall process of building a system using the Zynq SoC can be divided into hardware logic implementation of the PL and software programming of the PS. In general, the software domain is well-suited for implementing sequential processing tasks, an operating system, user applications, and graphical user interfaces. In contrast, computationally intensive data flow elements of the system are more appropriately realized in the PL hardware. (zynq book)

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

## Signal Recorder
### General functions of the system
In this section, the desired functions of the signal recorder system are first discussed, followed by dividing the implementation of these functions into the PS- and PL-side. 

Firstly, to communicate with the KX134 accelerometer, an I2C interface is absolutely necessary. The ZC706 evaluation board implements one I2C port on both the PL- and PS-side of the Zynq SoC. However, they are connected to an existing I2C Bus in order to communicate with I2C devices (e.g. EEPROM) that are fixed on the board. Therefore, the KX134 can only connect to the PL-side of Zynq SoC through the GPIO Header. 

On the other hand, the recorded signals need to be stored for further analysis and processing, which can be conveniently done via the SD card slot on the ZC706 board. Thus, the acceleration data must be transferred to the PS-side to be written to the SD card. For this purpose, the AXI-IIC IP core is used for both the I2C interface implementation and the data transfer between PL and PS. 

Additionally, the signal recorder should allow the user to control sampling initiation at runtime. In Zynq embedded system, the scanf and printf functions in applications use the PS Uart by default. So controlling the program running on a PS from a PC is easily realized via the on-board USB-UART interface and a serial device port on the PC. 

Figure () shows the system block diagram for this signal recorder design. The configuration of KX134 is determined in the application program running in the PS and transmitted over the AXI4 bus to the AXI-IIC IP core. This IP core converts the configuration data to I2C signals and writes it to the specific registers of KX134. When the user inputs a specific command to the PS via the serial port on the PC, the PS writes a control signal to CNTL1 via the AXI-IIC to activate sampling. Once the number of samples in the Buffer reaches a threshold, the KX134 generates an interrupt on its INT1 pin. This pin is connected to the IRQ_F2P port on PS through a GPIO pin on PL, which will trigger the interrupt service routine in PS to read the acceleration data. Finally, the data is stored as text files in the SD card. 

![[signal_recorder.drawio (1).svg]]
### IP Core
Chapter 4 will explain the software programming of the Zynq Embedded System in Vitis IDK. Following section focuses on the hardware modules that need to be integrated into Vivado to realize the functionality of the system, and how to configure them properly.

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
#### AXI IIC IP Core
The AXI IIC Bus Interface module serves as the transaction interface between the I2C protocol and the AXI4-Lite bus. This IP block is capable of operating as either a master or slave, and supports multi-master configurations.
For this work, the SCL clock is configured to 1 MHz, within the I2C specification of up to 1 MHz.
![[Pasted image 20231030225503.png]]
（from internet replace later)
It is important to note that this AXI IIC core does not provide explicit electrical connectivity to the I2C bus. This means the interface signals to and from the IP block are not bidirectional. The user must ensure external tristate buffers and pull-up resistors are incorporated in the design to fulfill the I2C electrical requirements.

![[iobuf.svg]]
## Signal Generator
### General functions of the system

![[signal_generator.drawio (1) 1.svg]]

The system removes the KX134 accelerometer used in the signal recorder, replacing it with a custom IP core. This IP core can be configured and read via I2C like the KX134, allowing reuse of the signal recorder software to acquire and log acceleration data from the signal generator.

The SD card serves as the signal source for the generator. Software reads a text file from the SD card and transfers it to the PL over the AXI4 bus. The custom IP core buffers the acquired data. When the buffered data reaches a threshold configured via I2C, the IP asserts an interrupt to notify the PS to read out the samples. For testing, the system also integrates part of the signal recorder. The AXI-IIC IP handles I2C communication to configure and read the custom IP, sending the data back to the PS for storage on the SD card. This realizes a loopback between the acceleration signal source and the recorded data. After the experiment, there should be two identical text files on the SD card.

The AXI-DMA module bridges data transfer between the custom IP and PS. Direct memory access (DMA) moves data between memory and the custom IP without processor involvement. The AXI-Stream protocol is efficient for the custom IP. And DMA offloads the PS so PS can deal with signal transmission and acquisition at the same time.

Figure ()  shows a block diagram of the signal generator system. Two AXI4 buses connect the PS GP and HP ports to the PL. The AXI-IIC and custom IPs are mapped to pins connected to the GPIO header and joined by jumper wires to create the I2C bus. Both the AXI-DMA and custom IP generate interrupts to activate handlers in the PS.

### Custom I2C Slave IP Core
#### Block diagramm

![[Pasted image 20231031194805.png]]
（replace later）
上图展示了Custom I2C IP内部的结构框图。该IP核有以下ports与外界连接：
- AXI-Stream接口： axis_data [31:0],axis_valid,axis_ready
- 系统信号: reset与clock
- I2C接口：scl_i,scl_o,scl_t,sda_i,sda_o,sda_t
- interrupt

该IP主要有以下components:
- signal generator
- clock divider
- signal debounce
- I2C slave
- sample buffer
这些部件将在下面的章节被详细介绍

#### signal generator
IP的AXI-Stream接口连接在signal generator module上。因此需要首先详细介绍AXI-Stream总线。AXI-Stream数据传输时不需要地址，在主从设备之间直接连续读写数据。它的核心是 VALID和READY信号，在clock的上升沿时两个信号都为高则代表数据成功传输，可以更新下一组数据。对于signal generator模块这一从设备，正确生成ready非常重要。在IP模块仍然处于standby模式时，ready信号用于通知上游信号源停止传输；本系统中AXI-Stream的时钟远远快于采样时钟，ready用于调节两种不同的时钟间的传输速率。

 
``` VHDL
signal_gen : process (data_reg, sampling_en, sample_clk_rising)

    begin

        data_reg_nxt <= data_reg;

        wr_en_nxt <= '0';

        axis_ready <= '0';

        if (sampling_en = '1') then

            if (sample_clk_rising = '1') then

                axis_ready <= '1';

                if (axis_valid = '1') then

                    data_reg_nxt <= axis_data (7 downto 0);

                    wr_en_nxt <= '1';

                end if;

            end if;

        end if;

    end process signal_gen;
```

如上代码段所示，当IP模块被配置到工作模式时(sampling_en = '1')且检测到采样时钟的上升沿(sample_clk_rising = '1') ，无论valid为何值，ready信号都会为高一个时钟周期。而在满足上述条件的情况下，当valid为高时(axis_valid = '1')，axis接口的数据才会被写入模块内的寄存器中。值得注意的是ready信号的值不能与valid信号的值有逻辑关联，否则可能会导致死锁。

另一方面，由于系统时钟远远快于clock devider生成的采样时钟，因此可以用检测采样时钟上升沿的方式简化Sample Buffer异步读写的实现。Signal generator模块通过上文中生成的wr_en信号控制下游Sample buffer的写入频率。该上升沿检测逻辑由寄存器延时实现。这种边沿检测在之后介绍的模块中还会被多次使用。
``` VHDL

         sample_clk_rising <= (not sample_clk_dly) and (sample_clk);

```

#### clock divider
#### FSM of the IP Core
![[pladitor_diagram (1) 1.svg]]
This finite state machine (FSM) illustrates the operation of an I2C slave peripheral. The FSM begins in the “idle” state, waiting for the start of a communication cycle. Upon receiving a “START” signal, it transitions to the “get_address_and_cmd” state, where it acquires the address and command for the impending transaction. If the address does not match the predefined slave address of the custom IP, the FSM reverts to “idle”. Additionally, if the IP is instructed to perform a read operation without being assigned a target register address, the FSM also returns to “idle”.

After successfully matching the address, the FSM can transition to either “read” or “write” states based on the provided command. In the “write” state, the slave samples SDA on the rising edges of SCL and stores the data in the specified register. Once all bits are processed and the next SCL falling edge is detected, the system moves to the “after_write_ack” state. Here, the slave pulls SDA low until the subsequent SCL falling edge to acknowledge the completed write to the master. The FSM then returns to “write” to process more data or wait for a STOP signal to terminate the transfer.

In parallel, in the “read” state, the slave drives SDA low or release it based on the specified register data during SCL falling edges, ensuring SDA only changes when SCL is low. After processing all bits, the FSM transfers to “read_ack_start”. It then samples SDA on the SCL rising edge and transitions to “read_ack_got_rising”. Based on the acknowledgment received from the master (ACK or NACK), the system can either finish the read in “read_stop” or return to “read” on the next SCL falling edge.

Importantly, a START signal at any time moves the FSM to “get_address_and_cmd”, while a STOP signal transitions it to “idle”, beyond the explicit state transfer diagrammed.

### Physical Interface
It is necessary to connect the custom I2C IP core and AXI IIC IP core via jumper wires on the development board instead of directly in the block design. As mentioned previously, the AXI-IIC IP core does not provide explicit electrical connectivity to the I2C bus. Additionally, FPGAs lack internal tristate components. However, the Input/Output Blocks (IOBs), located at each FPGA pin, contain tristate circuitry.

Thus, the signals that the custom I2C module reads or drives are scli, sclo, sclt, sdai, sdao and sdat. During synthesis, Vivado recognizes that the top-level I2C interface requires bidirectional signaling and automatically infers the tri-state buffer IOBUF. 

![[iobuf.drawio.svg]]