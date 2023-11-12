#writing 

本章将介绍了对章节3和4介绍的系统进行测试的方法和结果。

测试1 与KX134连接，真实振动数据并可视化
测试2 去掉

This chapter presents the various tests performed during system development and their results, followed by an overall evaluation of the system. Firstly, the signal recorder was tested to configure the KX134 and capture real acceleration data. Secondly, the custom IP was tested without the AXI-DMA connection. A counter in the PL outputted its count results as data to the sample buffer. The data was read to PS and stored on the SD card. The last test was a loopback test. In this test, data from a text file was read as acceleration data from the SD card, transferred over I2C, and written back to the SD. All three tests achieved the expected results, confirming full system connectivity. After this, the system is evaluated in terms of FPGA resource utilization, power consumption, and suitability for real-world applications.


![[pinonboard.drawio 1.png]]
在本系统中，系统的吞吐率没有特殊的要求。I2C的最大时钟1M ODR最大12800。但该系统应保证数据传输过程中的准确性。

在该系统的设计过程中，针对不同功能和应用场景进行了模块化的测试。

硬件系统的开发包括设计要在 PL 中实现的外设模块和其他逻辑，在这些模块和 PS 之间建立适当的连接，并对 PS 进行适当的配置。例如，硬件系统可能包括 CAN 总线接口、用于调试的 UART 接口和 GPIO 接口，以及支持在 ARM 上运行软件的硬件协处理器。图 3.3 展示了该系统。硬件系统的开发在 Xilinx Vivado IDE 开发套件中进行。设计人员可以利用源自 IP 库的模块勾勒出所需系统的草图，对模块进行参数化，并设计适当的内部连接和外部端口。这一过程使用 Vivado 的 IP Integrator 组件完成，本书稍后将在第 18 章详细介绍该组件。
在本系统的设计过程中，Top-Down-design与bottom-up-testing的原则被遵守。每个自定义模块在被集成入系统前都先通过testbench对其功能进行了验证。之后根据应用场景的不同，进行了三个测试，以验证对整个软硬件co-design的功能。具体的测试内容和测试结果将在下面的sections中被详细描述。
在所有三个测试中，一个文本文件中含有10000组样本。这一样本数可由用户通过修改参数化的嵌入式C程序自定义。而三个实验中，sample buffer都被配置为60。
测试一：使用KX134采集并存储真实加速度数据
这个测试是对signal recorder的整体测试。在这个实验中，KX134会先被配置到watermark interrupt模式，然后被轻微摇晃并进入工作模式。它在三个方向上的加速度会被存储入sample buffer中。
![[Screenshot_2023-07-18_16-13-31.png]]
Sigrok 开源的logic analyzer framework Lecroy

由于连接后信号出现波动导致logic analyzer显示错误的I2C协议信息，因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。

![[Screenshot_2023-09-22_15-52-59.png]]![[Screenshot_2023-09-22_15-54-24.png]]![[Screenshot_2023-09-22_15-55-06.png]]![[Screenshot_2023-10-12_17-22-29.png]]![[Screenshot_2023-11-09_15-13-36.png]]

![[Pasted image 20231112073327.png]]
![[Pasted image 20231112073418.png]]
![[Pasted image 20231112073611.png]]