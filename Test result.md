#writing 

本章将介绍了对章节3和4介绍的系统进行测试的方法和结果。

测试1 与KX134连接，真实振动数据并可视化
测试2 去掉

This chapter presents the various tests performed during system development and their results, followed by an overall evaluation of the system. Firstly, the signal recorder was tested to configure the KX134 and capture real acceleration data. Secondly, the custom IP was tested without the AXI-DMA connection. A counter in the PL outputted its count results as data to the sample buffer. The data was read to PS and stored on the SD card. The last test was a loopback test. In this test, data from a text file was read as acceleration data from the SD card, transferred over I2C, and written back to the SD. All three tests achieved the expected results, confirming full system connectivity. After this, the system is evaluated in terms of FPGA resource utilization, power consumption, and suitability for real-world applications.



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

这项实验进行于custom IP的develop过程中。该IP核还未添加AXI-Stream接口。在涉及另一条数据通路前，应当先验证自定义的I2C从接口的功能，以降低潜在问题发生的风险。该测试系统中，custom IP内部的结构如下图所示。图中略去了reset信号。Signal Generator输出到buffer的数据来自其内置的counter。在每一个sample clock的上升沿，该counter都会记一次数。这样一来，一个递增的数列会被存入Buffer中并被读出。

This experiment was performed during the development of the custom IP core, before the AXI-Stream interface was added. Verifying the custom I2C slave functionality before adding another data path reduced the risk of potential problems. The internal structure of the custom IP under test is shown in Figure x, with reset signals omitted. The signal generator outputs counter data to the buffer. On each rising edge of the sample clock, the counter is incremented. Thus, an incrementing sequence is stored in the buffer and read out.
该实验中生成的txt文件会在下一个实验中被作为信号源使用。因为使用该信号源时，I2C总线上传输的数据应当是一个逐一递增的数列。这方便了验证系统传输准确性与排查错误原因。
The text file generated in this experiment is used as a signal source in the next experiment. Using this source, an incrementing data sequence should be transmitted on the I2C bus. This facilitates the verification of the transmission accuracy and the debugging.
![[generator_count.drawio.png]]

在实验中，J58 Pmod GPIO Header被如下图所示连接。SCL与SDA信号如章节x中所述，必须通过物理连接才能实现双向通信。而Interrupt信号则可以直接在block design中连接。此处将Interrupt信号映射到header上是为了方便通过Logic analyzer捕捉这一信号，验证中断处理系统是否如预期工作。而debounced SCL和debounced SCL 也是仅在测试中需要的信号。由于在于custom IP通信时，信号出现了明显的抖动，导致logic analyzer显示了错误的I2C信息。因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。在实际应用中，该实现只需要使用4个GPIO。
![[pinonboard.drawio 1.png]]
在logic analyzer上捕捉到了了与预期结果相同的波形。图X展示了Master对CNTL1（0x1B）和ODCNTL（0x21）进行配置的过程。本工作中，KX134的ADDR引脚被连接到VDD，即其从机地址的可编程部分为1，地址为0x1F。而Custom IP的从机地址也与此一致。从波形中可以看到，从机拉低了SDA，对主机发送的数据进行了正确的回应。

The logic analyzer captured waveforms that matched the expected results. Figure X shows the sequence of the master configuring the CNTL1 (0x1B) and ODCNTL (0x21) registers. In this work, the KX134 ADDR pin is connected to VDD, making the programmable part of its slave address 1 with a full address of 0x1F. The custom IP has the same slave address.  So the master first sends the slave address 0x1F with a write command, followed by the two data bytes that are the destination register address and value to be written. The waveform shows that the slave responds correctly to the command of the master by pulling SDA low to acknowledge the data. 


而图Y展示了当interrupt升高时，数据被读取的过程。Logic analyzer的D0展示了SCL,D1是SDA，D2是interrupt。Interrupt升高后，主机先像从机写入BUF_READ的register 地址0x63，再用START REPEAT信号使从机重新进入等待地址和命令的状态，并发起读事务。在图中可以看出，递增的数据信号在总线上被传输。

![[Screenshot_2023-09-22_15-52-59.png]]![[Screenshot_2023-09-22_15-54-24.png]]![[Screenshot_2023-09-22_15-55-06.png]]![[Screenshot_2023-10-12_17-22-29.png]]

![[Pasted image 20231112073327.png]]


##  Signal Generator with External Signal Source
This experiment thoroughly validates all expected functionalities of the signal generator. Building on the foundations of Experiment 2, the system has been extended to include the AXI-DMA IP core, and the AXI stream port has been added to the custom IP. The data stored in the buffer is no longer from the internal counter, but from the external SD card.

The logic analyzer signals recorded in this experiment were identical to the signals in Experiment 2, so they are not shown here.

Figure X shows the serial terminal log during the configuration of the custom IP. The numbers represent the actual number of bytes successfully transmitted over AXI-IIC. When the program requests the signal source file name, the user should enter it in the serial terminal without the file name extension. The file used in this test is named source.txt.

The log in Figure y shows that the DMA transmission completion interrupt is asserted just before the last custom IP interrupt is received, as expected. During the transfer, the CPU does not need to actively control the rate because the AXI-DMA/custom IP handshake ensures the data transfer according to the sample clock and only occurs when the IP is configured to work mode. This log contains 16 "GET KX134 INTR" messages, which is also as expected. After the test, a text file 1.txt can be found on the SD card, which is identical to source.txt. This verifies correct system data transfer and conversion.



![[Pasted image 20231112073611.png]]
![[Pasted image 20231112073418.png]]

## Evaluation
在该系统中，性能并不是重点。如章节x中所述，该系统收到I2C总线最高时钟频率的限制，数据最快以12800Hz的频率被生成。但是Resource Utilization和Power Consumption对于系统的实用性和长期运行的可能性有重要意义。该系统将从这两个方面被评估。

在xilinx的FPGA/zynq开发工具vivado中,在_Implement后_，可以看到所有器件的资源与估计的功耗，并且还提示预计结温（Junction Temperature）
![[Screenshot_2023-09-22_15-52-59.png]]![[Screenshot_2023-09-22_15-54-24.png]]![[Screenshot_2023-09-22_15-55-06.png]]

下图是实验3中被使用的source.txt文件和1.txt文件。它们的内容完全一致。原始数据0x12,0x34以此类推在正负32g的采样范围下被转换为小数。当前的设计中，signal generator生成的文本文件中，三轴的加速度数据以x轴、y轴、z轴的顺序交错存放在同一个文件。也可以通过简单修改write_sd_txt程序将其分开存放。

The x figure shows the contents of source.txt and 1.txt, which are identical. The original data 0x12, 0x34, etc. are converted to decimal values within the ±32g acceleration range. In the current design, the acceleration data on the three axes (x, y, z) are interleaved in the same text file generated by the signal generator. With simple modifications to the write_sd_txt function, they can also be stored in separate files.

由于一个加速度数据的整数部分的符号和位数不固定，因此无法准确计算数据占用的空间。通过包含960组数据的文本文件占用了32021 bytes，可以估计一组数据平均需要33.36 bytes。本实验中使用的SD卡的可用存储空间为7.4 Gibibyte，即约为7945689497.6 bytes，则该SD卡可以存储238180140组数据。系统中使用的ODR为12800 Hz，这代表一张SD卡可以连续生成或者存储18607秒，即310分钟的振动信号。

Since the integer part of the acceleration data does not have a fixed sign and length, the exact space occupied cannot be calculated. Therefore, based on 1.txt with 960 data sets that occupies  32021 bytes, each data set is estimated to occupy on average 33.36 bytes. The available space on the SD card used in this experiment is 7.4 Gibibytes, i.e. 7945689497.6 bytes. This means that the SD card can store 238180140 data groups. With the ODR of 12800 Hz used in this work, an SD card can continuously generate or store vibration signals for 18607 seconds, which is 310 minutes.

本section中将基于vivado 的power report 估计并分析系统功耗。如下图所示，power report 展示了该系统总共的功耗、结温与热裕量。可以看到，该系统的功耗中动态功耗占据大多数。FPGA器件中，静态功耗指设计对器件进行配置后，外部未施加任何活动且内部也未生成任何活动的情况下的供电量，动态功耗指器件运行应用并执行开关活动，如时钟和数据翻转产生的功耗（UG949）。而从系统中不同部件的角度来看，PS系统的功耗几乎是整个系统的功耗。在PS configuration中disable了在ZC706的board file被配置但在本系统中未被使用的外设后，PS的功耗略微降低。整体而言，本系统的功耗较低。

本section中基于vivado 的resource utilization对系统进行了评估。图x中可以看到，该系统整体而言使用的FPGA资源量非常少。这利于该对系统未来进行拓展或者直接集成入振动信号处理系统，或者在一些应用场合中在一块开发板上例化多个相同设计，使其同时作为多个下游系统的信号源。

从图y的系统每个部件的资源使用报告中可以看到，Custom IP是使用了最多的LUT和Registers的模块。在设计中，Custom IP的资源使用量具有优化空间。在KX134中，有部分registers是reseverd，并无实际功能，且有大量 register在本设计中并未被使用。在该系统后续的改进中，如果减少Custom IP中registers的数量，增加地址译码模块，可以有效节省资源。

从上表中可以看到，AXI-DMA被配置为仅提供简单模式下MM2S传输和AXI Stream Fifo被配置为仅支持Transit stream data的模式时，二者需要的FPGA resource。在使用AXI-DMA的方案中，系统中还必须添加处理PS的Slave HP与DMA 的Master MM2S接口间的通信的AXI MEM Interconnection模块。因此，LUT和Registers使用量几乎是使用AXI-Stream FIFO的两倍。然而为了简化输出过程，需要将尽量多的数据存入模块内，再一次性启动stream传输，使得使用AXI-Stream FIFO的解决方案需要更多的Block RAM。


This section estimates and analyzes the power consumption of the system based on the Vivado Power Report. As shown in figure 5.8a, the power report displays important information such as total on-chip power, junction temperature, and thermal margin of the system. It can be seen that the dynamic power consumption takes up the largest part of the total power consumption，达到了88%. In an FPGA device, static power refers to the power consumed when the design is configured on the device and no activity is applied externally or generated internally; dynamic power refers to the power consumed when the device is running applications and performing switching activities such as clock and data toggling (UG949)

From the perspective of the various components in the system, the power consumption of the PS system accounts for almost all of the total system power consumption，占据了整体能耗的95%. In general, the power consumption of this system is relatively low，为1.795w。

通过报告信息，可知降低该系统功耗的重点在于降低PS的功耗。When peripherals configured in the ZC706 board file but not used in this system are disabled in the PS configuration, the power consumption of the PS is slightly reduced to 1.755w as in figure 5.8b. 


This section evaluates the system resource utilization based on the Vivado report. As shown in figure 5.10, the overall FPGA resource usage of the system is very low. This allows for future system expansion or direct integration into a vibration signal processing and analyzing system. It also allows multiple instances of the same design on a single development board to serve as signal sources for multiple downstream systems in some application scenarios. The resource usage report for each component in figure 5.9 shows that the custom IP module consumes the highest number of LUTs and registers. Within the design, there are potential optimizations for the Custom IP resource usage. In the KX134 sensor, several registers are reserved and serve no practical function, moreover, and a large number of registers remain unused in the current design. In future optimizations of this system, resource efficiency could be improved by reducing the number of registers to the actual need in the custom IP, combined with an extra address decoding module.