#writing 
本章节展示了
[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

PS上运行的应用主要需要完成以下任务：初始化peripherals，读取或写入SD卡中的文本文件，将文本文件中的小数转换为16位二进制数或者反之亦然，处理中断信号。


这一应用运行在Standalone（又名baremetal）操作系统下。
A standalone OS, also known as a bare metal OS, is a simple OS that aims to provides a very low-level of software modules that the system can use to access processor-specific functions. Regarding the Zynq platform specifically, Xilinx provides a standalone OS platform that provides functions such as configuring caches, setting up interrupts and exceptions and other hardware related functions. The standalone platform sits directly below the OS layer and is used whenever an application requires to access processor features directly [8]. A standalone OS enables close control over code execution but is fairly limited in terms of functionality. It should only be used for applications where the software functions are straightforward and repetitive. The number of tasks being carried out by a standalone OS should be relatively small, as adding further tasks can increase the task management required by the standalone rapidly.

The Standalone platform is a single-threaded, simple operating system (OS) platform that provides the lowest layer of software modules used to access processor-specific functions. Some typical functions offered by the Standalone platform include setting up the interrupts and exceptions systems, configuring caches, and other hardware specific functions. The Hardware Abstraction Layer (HAL) is described in this document

Standalone BSP contains boot code, cache, exception handling, file and memory management, configuration, time and processor-specific include functions.

[8] Xilinx, Inc, “OS and Libraries Document Collection”, UG643
需要注意的是
#### BSP 
 
The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
 
PS端的
### fatfs
Xilffs is a generic FAT file system that is primarily added for use with SD/eMMC driver. The file system is open source and a glue layer is implemented to link it to the SD/eMMC driver. A link to the source of file system is provided in the PDF where the file system description can be found.
