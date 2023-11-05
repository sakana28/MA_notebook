#writing 

### SD card operation


文本文件中，python生成的振动信号x以小数的形式存在于文本文件中，每个数占一行。 read_sd函数逐行读取并近似与g相关的整数并转换为16位二进制数，再将二进制数分别存放在两个32bit的存储单元中。Memory Map Data Width：AXI MM2S存储映射读取数据总线的数据位宽。有效值为32,64,128,256,512和1024。此处保持默认值32。

若f_gets报错如下：undefined reference to "f_gets",即表示f_gets未定义，
出现这个错误的原因是，在xiffls中我们没有使能字符串函数功能。use_strfunc

write_sd_txt程序则是反过程，将放在三个float类型buffer中的x,y,z三轴加速度数据写入文本文件中。
#### fatfs
Xilffs is a generic FAT file system that is primarily added for use with SD/eMMC driver. The file system is open source and a glue layer is implemented to link it to the SD/eMMC driver. A link to the source of file system is provided in the PDF where the file system description can be found.
对于文件读写操作，Xilinx提供了Xilffs这一generic FAT file system。它充当了应用和存储器控制中间的桥梁。在SD/eMMC driver提供了更高一层的抽象。编写程序时，Application should make use of APIs provided in ff.h.
FatFs is a generic FAT/exFAT filesystem module for small embedded systems. FatFs provides various filesystem functions for the applications 
The Xilinx fat file system (FFS) library consists of a file system and a glue layer. This FAT file system can be used with an interface supported in the glue layer. The file system code is open source and is used as it is. Currently, the Glue layer implementation supports the SD/eMMC interface and a RAM based file system. Application should make use of APIs provided in ff.h. These file system APIs access the driver functions through the glue layer. 
