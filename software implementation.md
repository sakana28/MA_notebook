#writing 
本章节展示了
[[file structure]]
[[about SD card WR (FATFS)]]
[[about interrupt on zynq]]
[[about AXI-DMA sw]]

PS上运行的应用主要需要完成以下任务：初始化peripherals，读取或写入SD卡中的文本文件，将文本文件中的小数转换为16位二进制数或者反之亦然，处理中断信号。

需要注意的是
#### BSP 
 
The BSP is customized for the base system and OS combination, and contains hardware parameters, device drivers, and low-level OS functions. (zynq book)
 
PS端的
fatfs在软件章节
