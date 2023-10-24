#writing #structure

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
