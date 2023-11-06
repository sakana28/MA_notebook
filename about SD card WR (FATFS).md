#writing 

### SD card operation


文本文件中，python生成的振动信号x以小数的形式存在于文本文件中，每个数占一行。 read_sd函数逐行读取并近似与g相关的整数并转换为16位二进制数，再将二进制数分别存放在两个32bit的存储单元中。Memory Map Data Width：AXI MM2S存储映射读取数据总线的数据位宽。有效值为32,64,128,256,512和1024。此处保持默认值32。

若f_gets报错如下：undefined reference to "f_gets",即表示f_gets未定义，
出现这个错误的原因是，在xiffls中我们没有使能字符串函数功能。use_strfunc

write_sd_txt程序则是反过程，将放在三个float类型buffer中的x,y,z三轴加速度数据写入文本文件中。
#### fatfs
Xilinx provides the Xil Fat File System (XilFFS) as a generic FAT file system implementation for file I/O operations. It integrates the open source FatFs FAT/exFAT file system module customized for embedded systems. XilFFS serves as a bridge between applications and underlying storage controllers, providing a higher level of abstraction above the drivers of devices such as SD/eMMC controllers. Applications should use the APIs in ff.h for file access.

This layered architecture separates the file system module from the specific interface drivers. Code built on the open standard APIs in the FatFs file system can remain unchanged, connecting different storage drivers through glue layers provided by different hardware. This allows applications on different platforms to maintain a common file access.
