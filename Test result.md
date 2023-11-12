#writing 

本章将介绍了对章节3和4介绍的系统进行测试的方法和结果。

测试1 与KX134连接，真实振动数据并可视化
测试2 去掉

This chapter presents the various tests performed during system development and their results, followed by an overall evaluation of the system. Firstly, the signal recorder was tested to configure the KX134 and capture real acceleration data. Secondly, the custom IP was tested without the AXI-DMA connection. A counter in the PL outputted its count results as data to the sample buffer. The data was read to PS and stored on the SD card. The last test was a loopback test. In this test, data from a text file was read as acceleration data from the SD card, transferred over I2C, and written back to the SD. All three tests achieved the expected results, confirming full system connectivity. After this, the system is evaluated in terms of FPGA resource utilization, power consumption, and suitability for real-world applications.


![[pinonboard.drawio 1.png]]
在本系统中，系统的吞吐率没有特殊的要求。I2C的最大时钟1M ODR最大12800。但该系统应保证数据传输过程中的准确性。

在设计的过程中

Sigrok 开源的logic analyzer framework Lecroy

由于连接后信号出现波动导致logic analyzer显示错误的I2C协议信息，因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。

![[Screenshot_2023-09-22_15-52-59.png]]![[Screenshot_2023-09-22_15-54-24.png]]![[Screenshot_2023-09-22_15-55-06.png]]![[Screenshot_2023-10-12_17-22-29.png]]![[Screenshot_2023-11-09_15-13-36.png]]

![[Pasted image 20231112073327.png]]
![[Pasted image 20231112073418.png]]
![[Pasted image 20231112073611.png]]