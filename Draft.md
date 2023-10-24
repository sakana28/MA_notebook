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

### Zynq Soc
[[about Zynq]]
The Zynq All Programmable System-on-Chip (APSoC) [add quelle]from Xilinx combines the adaptability of a general-purpose processor with the customizability of a field-programmable gate array (FPGA), resulting in a powerful platform that delivers high performance, flexibility, and scalability. *One noteworthy feature of the Zynq architecture is its ability to program at the logic level, which includes logic processing units, signal processing blocks, and configurable memory areas tailored to specific tasks.* This capability enables developers to create specific circuits, freeing up the processor for additional computational tasks.

The platform's structure, depicted in Figure {1.1}, consists of two primary parts: the Processing System (PS) and the Programmable Logic (PL). The FPGA fabric of the PL is based on the Artix®-7 and Kintex®-7 FPGAs and includes not only essential elements such as Configurable Logic Blocks (CLBs) and the switch matrix, but also DSPs and Block RAMs that extend the computational and memory capabilities.
![[Pasted image 20231006055255.png]]
（cited from Zynq 7000 datasheet） **Replace it with a simpler diagram**

The center of the PS consists of a dual-core ARM Cortex-A9 processor and a set of associated processing resources, including hardware floating point units, which together form the Application Processing Unit (APU). Furthermore, the PS includes peripheral interfaces, cache, memory interfaces, interconnect and clock generation circuitry.  (cite zedbook) This integrated system supports multiple real-time operating systems, such as Linux.

To facilitate high-speed communication between the PS and PL, Zynq provides several Advanced eXtensible Interface (AXI) ports, including General Purpose Ports and High-Performance Ports, which will be discussed in the following chapters. Furthermore, interrupt signals facilitate programmable logic to activate events that interrupt the operation of the processor, which makes Zynq an *incredible* platform for hardware-software co-designs.
### ZC706 evaluation board
[[about ZC706]]
![[Pasted image 20231006065127.png]]
Figure ( ) shows the development and testing setup with the Xilinx ZC706 Evaluation Kit. The ZC706 evaluation board by Xilinx offers a high-performance and flexible platform for developing a variety of embedded processing systems. The central component of the board is the XC7Z045 FFG900 - 2 SoC, featuring a dual-core ARM Cortex-A9 processor with 7-series programmable logic.  Key hardware specifications of the XC7Z045 comprise 218,600 lookup tables (LUTs), 437,200 flip-flops, 900 digital signal processor (DSP) slices, and 26.5 Mb block RAM, providing sufficient resources for complex digital systems.

The peripheral interfaces and connectivity of the ZC706 are crucial for data acquisition and generation applications. The board provides ample clock resources, diverse mainstream interface connectors, and User I/O. Key features utilized in this work include the Secure Digital (SD) card slot, DDR3 memory interfacing the processing system, serial communication through a USB-UART bridge, general-purpose input/output (GPIO) headers, and a JTAG port for FPGA programming.