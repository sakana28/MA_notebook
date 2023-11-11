#writing 

本章将介绍了对章节3和4介绍的系统进行测试的方法和结果。

测试1 与KX134连接，真实振动数据并可视化
测试2 去掉

This chapter presents the tests performed during system development and their results, and provides an overall evaluation of the system. 


这一章节中介绍了对系统的开发过程中进行的多项测试及其结果，并对整个系统进行了评估。首先进行了对signal recorder进行配置后采集真实的加速度数据的实验，然后对Custom IP单独进行测试。不将其与AXI-DMA连接，而是在PL添加一个计数器，将计数结果作为测试数据存入Sample Buffer，并让主机读出并储存测试数据。最终连接整个系统，测试signal recorder从SD卡读出文本文件并作为加速度数据，加速度数据再被主机读出并写入SD卡的Loopback测试。这三项测试都获得了预想中的结果。然后本章评估了系统的FPGA resource utilization，power consumption和实际场景中的实用性。

在本系统中，系统的吞吐率没有特殊的要求。I2C的最大时钟1M ODR最大12800。但该系统应保证数据传输过程中的准确性。

Sigrok 开源的logic analyzer framework Lecroy

由于连接后信号出现波动导致logic analyzer显示错误的I2C协议信息，因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。