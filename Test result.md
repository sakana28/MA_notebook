#writing 

本章将介绍了对章节3和4介绍的系统进行测试的方法和结果。

测试1 与KX134连接，真实振动数据并可视化
测试2 去掉

This chapter presents the various tests performed during system development and their results, followed by an overall evaluation of the system. Firstly, the signal recorder was tested to configure the KX134 and capture real acceleration data. Secondly, the custom IP was tested without the AXI-DMA connection. A counter in the PL outputted its count results as data to the sample buffer. The data was read to PS and stored on the SD card. The last test was a loopback test. In this test, data from a text file was read as acceleration data from the SD card, transferred over I2C, and written back to the SD. All three tests achieved the expected results, confirming full system connectivity. After this, the system is evaluated in terms of FPGA resource utilization, power consumption, and suitability for real-world applications.


![[pinonboard.drawio 1.png]]
在本系统中，系统的吞吐率没有特殊的要求。I2C的最大时钟1M ODR最大12800。但该系统应保证数据传输过程中的准确性。

在该系统的设计过程中，针对不同功能和应用场景进行了模块化的测试。

硬件系统的开发包括设计要在 PL 中实现的外设模块和其他逻辑，在这些模块和 PS 之间建立适当的连接，并对 PS 进行适当的配置。例如，硬件系统可能包括 CAN 总线接口、用于调试的 UART 接口和 GPIO 接口，以及支持在 ARM 上运行软件的硬件协处理器。图 3.3 展示了该系统。硬件系统的开发在 Xilinx Vivado IDE 开发套件中进行。设计人员可以利用源自 IP 库的模块勾勒出所需系统的草图，对模块进行参数化，并设计适当的内部连接和外部端口。这一过程使用 Vivado 的 IP Integrator 组件完成，本书稍后将在第 18 章详细介绍该组件。

The system development process followed the principles of top-down design and bottom-up testing. Each custom module was functionally verified using a test bench prior to integration into the overall system. Subsequently, three tests based on different application scenarios were performed to validate the functionality of the complete hardware-software co-design. The specific test contents and results are detailed in the following sections.



满足了上述的要求后，系统可以收集在一段时间内的连续振动信号。该时间只受到使用的SD容量的限制。而本工作中，在采集真实加速度数据的实验1中，一个iteration中会采集10000组样本。因为该实验中KX134采集到的加速度较小，因此采样时间应该较长，使实验结果的可视化能体现出传感器的往复运动。 在使用文本文件作为信号源的实验中，一个文本文件中含有的样本集较小，为960组。在该实验中，每次Master收到 Interrupt提示都会打印出对应的提示信息。一个iteration中应当打印16次来自Custom IP的中断提示信息，一次来自AXI-DMA的中断提示。通过串口的log可以体现出数据的传输方式。这一参数可由用户通过修改参数化的嵌入式C程序自定义。



而三个实验中，sample buffer都被配置为60。预想中的功能是sample buffer持续缓存新数据，不会overflow。下面的不等式展示了为实现这一目的应该如何选择sample buffer的阈值。
其中k是sample buffer的阈值。为实现上述目的，读出k组样本的时间必须小于采集k组样本的时间。该不等式忽略了START与START REPEAT, STOP信号需要的时间，并假设每次传输事务之间没有时间间隔。通过计算可以得出，当ODR为12800 Hz时，k只需大于1，即可满足要求。当ODR为25600 Hz时，自然数范围内没有满足条件的k值。因此该系统最高采样频率为12800 Hz。而阈值可以设为高于2的任意数字。此处设为60这一略高于buffer一半容量的数字。

In all three experiments, the sample buffer was configured to 60. The desired functionality is for the sample buffer to continuously cache new data without overflowing. The following inequality shows how the sample buffer threshold k should be chosen to achieve this:

T_readout < T_acquisition

where k is the sample buffer threshold. To achieve the above goal, the time to read out k samples must be less than the time to acquire k samples. This inequality ignores the time required for the START, START REPEAT, and STOP signals and assumes no gap between transactions. By calculation, if the ODR is 12800 Hz, k only needs to be greater than 1 to meet the requirement. When the ODR is 25600 Hz, there is no integer k that satisfies the condition. Therefore, the maximum sampling frequency of this system is 12800 Hz. The threshold can be set to any integer greater than 2. Here it is set to 60, which is slightly more than half the buffer capacity.

With the aforementioned requirements fulfilled, the system can continue to capture vibration signals for a certain period of time, which is only limited by the capacity of the SD card used. Since the accelerations sensed by the KX134 in this test are relatively small, data from a longer sampling period better demonstrates the motion of the sensor in the visualization.


## 测试一：使用KX134采集并存储真实加速度数据
This test provided an overall validation of the signal recorder system. First, KX134 was configured to watermark interrupt mode, then lightly shaken and set to operating mode. The device stored the three axis accelerations in the sample buffer and sent them to the PS master via I2C bus when an interruption was triggered. As soon as enough samples were gathered, the KX134 was set to standby mode and the samples were written to text files.

In this test, the three-axis acceleration data was stored separately and three files named "iteration+axis.txt" (e.g., 3x.txt) were generated after each sampling for visualization of the accelerations on each axis.

The results of visualization of raw acceleration data and FFT results for a single axis are shown in the figure below. A peak can be seen in the frequency domain acceleration data around 6Hz, which is corresponding to the actual conditions.

This experiment successfully validated the entire data path of the signal recorder, including the acquisition of data from the KX134, its transfer through the AXI-IIC interface, and its subsequent storage on the SD card. This validation also extends to the programmatic control of the AXI-IIC configuration process, confirming its accuracy.

![[Screenshot_2023-07-18_16-13-31.png]]
Sigrok 开源的logic analyzer framework Lecroy


## 实验二： Signal Generator without Signal source
由于连接后信号出现波动导致logic analyzer显示错误的I2C协议信息，因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。
这项实验进行于custom IP的develop过程中。该IP核还未添加AXI-Stream接口。在涉及另一条数据通路前，应当先验证自定义的I2C从接口的功能，以减少排查错误的难度。该测试系统中，custom IP内部的结构如下图所示。图中略去了reset信号。Signal Generator输出到buffer的数据来自其内置的counter。在每一个sample clock的上升沿，该counter都会记一次数。这样一来，一个递增的数列会被存入Buffer中并被Master读出。
![[test2.drawio 1.png]]

![[Screenshot_2023-09-22_15-52-59.png]]![[Screenshot_2023-09-22_15-54-24.png]]![[Screenshot_2023-09-22_15-55-06.png]]![[Screenshot_2023-10-12_17-22-29.png]]![[Screenshot_2023-11-09_15-13-36.png]]

![[Pasted image 20231112073327.png]]
![[Pasted image 20231112073418.png]]
![[Pasted image 20231112073611.png]]