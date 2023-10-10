#writing #fundamental 
11.10.23 first change
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
Cyclostationary signals are stochastic processes with periodic time-varying mean and autocorrelation functions. Earlier modeling works of vibration signals of rolling bearings often assumedto be stationary processes with autocorrelations independent of time, which neglected the inherently non-stationary nature of random slips of the rolling elements. (‘‘Differential Diagnosis of Gear and Bearing Faults,’’ Antoni, J., and Randall). Antoni and Randall (2003) first modeled vibrations produced by localized faults as cyclostationary processes, providing a basis for fault diagnosis. ![[Pasted image 20231011052234.png]]

Building on the initial work of Antoni and Randall (2003), two important model equations have been proposed (Antoni, Facts and fictions, 2006) representing the vibration signals from localized and distributed faults in rolling element bearings. Equation (1) models the vibration signal from a localized fault in a bearing:

Equation (1) contains several important parameters, including:
![[Pasted image 20231005065439.png]]

- h(t): the impulse response of a single impact measured by the sensor
- q(t): the periodic modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement
- T: the interval between successive impacts
- τi: the inter-arrival time of the ith impact, accounting for randomness due to rolling element slips
- n(t): the background noise

Equation (2) models the vibration signal from a distributed fault in a bearing:
![[Pasted image 20231005065448.png]]

The two terms in the equation are: 
- p(t): the periodic components like shaft and stiffness variations
- B(t): the pure cyclostationary content with E{B(t)} = 0

Based on these models, algorithms and Octave script code for numerical implementation of simulated vibration signals have been proposed in the work of G. D'Elia.  (Step-by-step) Figure ( ) demonstrates the procedure for generating vibration signals from localized faults, while Figure ( ) depicts the same process for distributed faults, according to the proposed algorithms.
![[Pasted image 20231005065627.png]]

![[Pasted image 20231005065536.png]]
The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.

### Zynq Soc
[[about Zynq]]
The Zynq All Programmable System-on-Chip (APSoC) from Xilinx combines the adaptability of a general-purpose processor with the customizability of a field-programmable gate array (FPGA), resulting in a powerful platform that delivers high performance, flexibility, and scalability. One noteworthy feature of the Zynq architecture is its ability to program at the logic level, which includes logic processing units, signal processing blocks, and configurable memory areas tailored to specific tasks. This capability enables developers to create specific circuits, freeing up the processor for additional computational tasks.

The platform's structure, depicted in Figure {1.1}, consists of two primary parts: the Processing System (PS) and the Programmable Logic (PL). The FPGA fabric of the PL is based on the Artix®-7 and Kintex®-7 FPGAs and includes not only essential elements such as Configurable Logic Blocks (CLBs) and the switch matrix, but also DSPs and Block RAMs that extend the computational and memory capabilities.
![[Pasted image 20231006055255.png]]
（cited from Zynq 7000 datasheet）

The center of the PS consists of a dual-core ARM Cortex-A9 processor and a set of associated processing resources, including hardware floating point units, which together form the Application Processing Unit (APU). Furthermore, the PS includes peripheral interfaces, cache, memory interfaces, interconnect and clock generation circuitry.  (cite zedbook) This integrated system supports multiple real-time operating systems, such as Linux.

To facilitate high-speed communication between the PS and PL, Zynq provides several Advanced eXtensible Interface (AXI) ports, including General Purpose Ports and High-Performance Ports, which will be discussed in the following chapters. Furthermore, interrupt signals facilitate programmable logic to activate events that interrupt the operation of the processor, which makes Zynq an incredible platform for hardware-software co-designs.
### ZC706 evaluation board
[[about ZC706]]
![[Pasted image 20231006065127.png]]
Figure ( ) shows the development and testing setup with the Xilinx ZC706 Evaluation Kit. The ZC706 evaluation board by Xilinx offers a high-performance and flexible platform for developing a variety of embedded processing systems. The central component of the board is the XC7Z045 FFG900 - 2 SoC, featuring a dual-core ARM Cortex-A9 processor with 7-series programmable logic.  Key hardware specifications of the XC7Z045 comprise 218,600 lookup tables (LUTs), 437,200 flip-flops, 900 digital signal processor (DSP) slices, and 26.5 Mb block RAM, providing sufficient resources for complex digital systems.

The peripheral interfaces and connectivity of the ZC706 are crucial for data acquisition and generation applications. The board provides ample clock resources, diverse mainstream interface connectors, and User I/O. Key features utilized in this work include the Secure Digital (SD) card slot, DDR3 memory interfacing the processing system, serial communication through a USB-UART bridge, general-purpose input/output (GPIO) headers, and a JTAG port for FPGA programming.