#writing  #hw_implementation #implementation 



# Introduction
Rolling bearings, also known as rolling element bearings, are critical mechanical components used in various engineering systems and industries. They facilitate the relative motion between components while reducing friction to ensure machinery functions optimally. Nevertheless, constant internal component movement can cause wear and tear leading to failures in the long haul. Thus, ensuring effectiveness in monitoring and detecting faults is essential for sustained reliability and longevity.

Vibration analysis is one of the most important and reliable techniques for monitoring the condition of rolling bearings. Through analysis of operational vibrations, engineers can identify unusual patterns, detect potential faults, and schedule maintenance before catastrophic failures. However, the lack of comprehensive experimental data sets hinders rigorous development and validation of the technique.

This has made simulated signals extremely useful for detecting faults in rolling bearings. Simulated signals are easily generated and convenient for validating new analysis techniques. The advantage of the use of simulated signals is obvious, as they are accessible within the same software environment in which the monitoring techniques are being developed, such as MATLAB. [*A tool for validating and benchmarking signal processing techniques applied to machine diagnosis*]

To develop a real-time monitoring system, it is crucial to have a signal generator and recorder as emulation platform that can seamlessly integrate simulated signals. In order to build such a system and facilitate adding or modifying features as needed, Field-Programmable Gate Arrays (FPGAs) were chosen as the solution. FPGAs are widely used due to their flexibility in implementing communication protocols and hardware functionalities, which enables rapid development for specific requirements.

The Xilinx Zynq system-on-chip (SoC), which combines FPGA fabric with ARM processors, offers extra advantages over traditional FPGA solutions. It not only provides the hardware flexibility of FPGAs but also integrates it with the software flexibility of ARM processors. This enables engineers to easily develop and implement complex dynamic control on their hardware design.

The goal of this work is to implement and evaluate a  Zynq-based signal generator and recorder, which is encompasses Python-based simulated signals models, embedded applications developed in C, and hardware modules  in VHDL. 

This work is organized as follows: Chapter 2 introduces the rolling bearing vibration signal model and provides basic insight into the Zynq architecture. Chapter 3 provides a brief overview of the functionality and operation of the evaluated KX134 accelerometer. This chapter also describes in detail the hardware components of the system developed to emulate the functionality of the KX134, including both IP cores provided by Xilinx and custom IP cores. Chapter 4 outlines the software development process for the system and explains its interaction with the hardware modules.In Chapter 5, a evaluation of the system is performed, taking into account factors such as power consumption, FPGA resource utilization, and overall performance. The final chapter provides the conclusion of this paper. 
# Fundamental
This chapter presents an overview of cyclostationary signals and introduces a vibration signal model for rolling element bearings. The model is based on the concept of cyclostationary signals and serves as the foundation for subsequent work. Next, the Zynq SoC architecture and the ZC706 development board used in this thesis are also introduced.
### Vibration signal model
[[about Model]]
#writing #fundamental 

11.10.23 first change in draft  
#### Cyclostationary
Cyclostationary signals are non-stationary signals with periodic time-varying mean and autocorrelation. An example of a cyclostationary signal is random noise that is amplitude modulated by a periodic function. This concept is important in the analysis of bearing fault signals, as cyclostationarity indicates the presence of a fault. This is because defects on a rotating surface produce repetitive impacts, causing the statistical properties of the resulting vibration signal to be periodic. While the slips between the bearing elements add randomness, the overall periodic pattern of impulses persists, rendering the signal pseudocyclostationary. This enables the use of cyclostationary analysis methods for diagnosing bearing defects. ("Differential Diagnosis")
#### Vibration signal models
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
#### Numerical implementation
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

The Zynq All Programmable System-on-Chip (APSoC) from Xilinx combines the adaptability of a general-purpose processor with the customizability of a field-programmable gate array (FPGA), resulting in a powerful platform that delivers high performance, flexibility, and scalability. One noteworthy feature of the Zynq architecture is its ability to program at the logic level, which includes logic processing units, signal processing blocks, and configurable memory areas tailored to specific tasks. This capability enables developers to create specific circuits, freeing up the processor for additional computational tasks.

The platform's structure, depicted in Figure {1.1}, consists of two primary parts: the Processing System (PS) and the Programmable Logic (PL). The FPGA fabric of the PL is based on the Artix®-7 and Kintex®-7 FPGAs and includes not only essential elements such as Configurable Logic Blocks (CLBs) and the switch matrix, but also DSPs and Block RAMs that extend the computational and memory capabilities.
![[Pasted image 20230928054544.png]]

（from Zynq 7000 datasheet）

The center of the PS consists of a dual-core ARM Cortex-A9 processor and a set of associated processing resources, including hardware floating point units, which together form the Application Processing Unit (APU). Furthermore, the PS includes peripheral interfaces, cache, memory interfaces, interconnect and clock generation circuitry.  [zedbook] This integrated system supports multiple real-time operating systems, such as Linux.

To facilitate high-speed communication between the PS and PL, Zynq provides several Advanced eXtensible Interface (AXI) ports, including General Purpose Ports and High-Performance Ports, which will be discussed in the following chapters. Furthermore, interrupt signals facilitate PL to activate events that interrupt the operation of the processor, which enables flexible interaction between hardware and software.

### AXI4 
The Zynq contains three types of AXI buses:
(1) AXI4-FULL targets high-performance address-mapped transaction，支持突发传输 
(2) AXI4-LITE provides a lightweight address-mapped single transaction interface that occupies minimal logic 
(3) AXI4-Stream enables high-speed streaming data transfers without address information, allowing unlimited burst transmissions 

Both AXI4 and AXI4-LITE buses have identical components consisting of five channels: 
read address channel (ARVALID, ARADDR, ARREADY); 
write address channel (AWVALID, AWADDR, AWREADY); 
read data channel (RVALID, RDATA, RREADY, RRESP); 
write data channel (WVALID, WDATA, WSTRB, WREADY); 
write response channel (BVALID, BRESP, BREADY).

By separating read and write channels, AXI4 implements full-duplex communication, allowing simultaneous read and write operations between two devices. Each of the five read/write channels contains its own handshake signals, which are fundamental to AXI buses and enable both sender and receiver to control transmission rates. As shown in the figure below, a valid transfer occurs when both READY and VALID signals are high on the rising clock edge. 

### ZC706 evaluation board
[[about ZC706]]
![[Pasted image 20231006065127.png]]
Figure ( ) shows the development and testing setup with the Xilinx ZC706 Evaluation Kit. The ZC706 evaluation board by Xilinx offers a high-performance and flexible platform for developing a variety of embedded processing systems. The central component of the board is the XC7Z045 FFG900 - 2 SoC, featuring a dual-core ARM Cortex-A9 processor with 7-series programmable logic.  Key hardware specifications of the XC7Z045 comprise 218,600 lookup tables (LUTs), 437,200 flip-flops, 900 digital signal processor (DSP) slices, and 26.5 Mb block RAM, providing sufficient resources for complex digital systems.

The peripheral interfaces and connectivity of the ZC706 are crucial for data acquisition and generation applications. The board provides ample clock resources, diverse mainstream interface connectors, and User I/O. Key features utilized in this work include the Secure Digital (SD) card slot, DDR3 memory interfacing the processing system, serial communication through a USB-UART bridge, general-purpose input/output (GPIO) headers, and a JTAG port for FPGA programming.
## https://www.nxp.com/docs/en/user-guide/UM10204.pdf 

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock line(SCL) and the serial data line (SDA). The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. 

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 
### Open-drain and Duplex 
The I2C protocol is a half-duplex bus that facilitates bidirectional communication, using the same transmission lines for both data transmission and reception. However, simultaneous data exchange between the communicating devices is not possible. Only one controller or target device can transmit data on the bus at a single time. 

To efficiently facilitate bidirectional communication, the I2C specification dictates that both SDA and SCL lines are open-drain. Open-drain refers to an output type in which the line can be pulled low or released high. When there is no I2C device actively pulling the line low, pull-up resistors will elevate the line to the VDD level. This differs from push-pull outputs, whichcan result in short-circuits when multiple devices attempt to output conflicting high and low levels on the I2C bus at the same time. 
![[Pasted image 20231023032001.png]] ![[Pasted image 20231023023643.png]] （from A Basic Guide to I2C）

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

next chapter: [[custom I2C slave]]

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



Design flow （zynq book） 

在掌握KX134的基本功能和通信方式后，即可搭建signal recorder系统

使用zynq搭建系统的流程 

ZYNQ 的工程设计大体上可以分为 对硬件逻辑系统的设计 和 对 CPU 软件程序的设计 硬件逻辑系统设计：搭建一个满足用户需求的硬件环境，通过 Vivado 实现 CPU 程序设计：通过用户程序控制 CPU 工作，使整个系统达到预定的效果，该部分通过 Vitis 实现 

使用 Zynq SoC 构建系统的设计流程可分为硬件逻辑实现和处理系统 (PS) 的软件编程。 

硬件逻辑设计包括使用 Vivado 创建所需的定制硬件环境，以满足系统要求。这包括 IP 集成、模块设计、引脚分配和 FPGA 编程。 

软件编程的目标是通过用户代码控制 PS 的运行，以实现预期的系统功能。这可以在 Vitis 中完成，用于创建、编译和调试在 ARM Cortex-A9 处理器上运行的应用程序。

Vivado 和 Vitis 工具协同工作，生成完整的 Zynq 系统。Vivado 综合并实现 PL 硬件逻辑，该逻辑与 FPGA 位流中的 PS 初始化一起加载。Vitis 将软件编译成可执行文件，并在启动后加载到 PS 运行。 通过制造商提供的board file, automatically configure the Zynq PS IP core with the correct parameters 并正确分配Multipurpose IO (MIO)管脚和板上peripherals的连接关系。 


### zynq ip CORE 
The first step is to add the ZYNQ7 Processing System IP core, which unlike soft processor IPs such as MicroBlaze, serves as an interface to non-FPGA processing system components. The board definition file from the manufacturer automatically configures the Zynq PS IP with appropriate parameters and establishes connections between Multipurpose I/O (MIO) pins and board peripherals. Notably, the PL to PS interrupt required in this project must be manually enabled by the user.
