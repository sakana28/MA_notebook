#writing 
![[signal_generator.drawio (1) 1.svg]]

本节首先讨论信号生成器系统的预期功能并对功能的实现进行初步设计。
该系统在在信号recorder的基础上去掉了KX134 accelerometer。取而代之的是一个自定义的IP核。该IP核应可与KX134一样通过I2C被配置或被读取数据。即，Signal recorder系统中的软件也应可以用于从signal generator获得加速度信息并记录。
SD卡在该系统中是signal generator的信号源。软件读取SD卡中的文本文件，将其通过AXI4总线传输入PL。Custom IP核将获取到的信号与KX134一致的方式处理为I2C总线信号。为了测试，整个系统也集成了signal recorder的一部分。I2C总线上的信息会被AXI-IIC IP读取，传输回PS并存储在SD卡中。整个系统实现了一个回环。实验结束时，SD卡中应有两个完全一致的文本文件，即加速度信号源与加速度信息采集结果。
而在该系统中

此外，信号记录器应允许用户在运行时控制采样启动。在 Zynq 嵌入式系统中，应用程序中的 scanf 和 printf 函数默认使用 PS Uart。因此，通过板载 USB-UART 接口和 PC 上的串行设备端口，就能轻松实现从 PC 控制 PS 上运行的程序。

图（）显示了该信号记录器设计的系统框图。KX134 的配置由 PS 中运行的应用程序确定，并通过 AXI4 总线传输到 AXI-IIC IP 核。该 IP 核将配置数据转换为 I2C 信号，并写入 KX134 的特定寄存器。当用户通过 PC 上的串行端口向 PS 输入特定命令时，PS 会通过 AXI-IIC 向 CNTL1 写入控制信号，以激活采样。一旦缓冲器中的采样数量达到阈值，KX134 就会在其 INT1 引脚上产生一个中断。该引脚通过 PL 上的 GPIO 引脚连接到 PS 上的 IRQ_F2P 端口，从而触发 PS 中的中断服务例程以读取加速数据。最后，数据以文本文件的形式存储在 SD 卡中。
