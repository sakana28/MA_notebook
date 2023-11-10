#writing #fundamental


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

### HwSW co design 
合理分割Generally speaking, software (on the PS) will be used to implement general purpose sequential processing tasks, an operating system, user applications and GUIs, while computationally intensive data flow parts of the design are more suitably realised in the PL. (zynq book)