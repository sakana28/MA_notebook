
# Zybo Z7: Zynq-7000 ARM/FPGA SoC Development Board
| Board    | LUT    | FF     | DSP | BRAM   | DDR    | ADC | Processor                      |
| -------- | ------ | ------ | --- | ------ | ------ | --- | ------------------------------ |
| ZYBO     | 17600  | 35200  | 80  | 2.1 Mb | 512 MB | n   | dual core ARM Cortex-A9 MPcore |
| Zedboard | 53200  | 106400 | 220 | 4.9 Mb | 512MB  | n   | dual core ARM Cortex-A9 MPcore |
| ZC706    | 218600 | 437200 | 900 | 26.5Mb |  DDR3 Component Memory 1GB (PS) DDR3 SODIM Memory 1GB (PL)   | n   | dual core ARM Cortex-A9 MPcore | 

表格x展示了三种主流的FPGA开发板的资源对比。可以看到，三种开发板的处理器相同，ZC706具有最多的FPGA资源和存储。本工作中由于ZC706可用，故在该开发板上进行设计、测试。后续资源使用分析会证明本工作的系统也可以部署在有更少FPGA资源的Zynq开发板中。

![[Pasted image 20230510165950.png]]
![[Pasted image 20230510172856.png]]
# Zedboard

FPGA Part XC7Z020-1CLG484C
![[Pasted image 20230510170846.png]]
![[Pasted image 20230621161935.png]]
![[Pasted image 20230510171058.png]]
![[Pasted image 20230510172652.png]]
# ZC706
![[Pasted image 20230510171355.png]]


结合表格x中的信息，估计当前设计在表格中最廉价的zybo上的资源使用率，得到 LUT 使用率为14.1% Filp-Flop使用率为 9.9% ，BRAM使用率为3.4% 。仍然是一个规模较小的设计。

为验证系统传输的准确性，需要对作为信号源的文件source.txt和系统记录获得的信号的文件1.txt进行比对，通过读入一行字符串并将其转为小数的方式，根据following公式计算Mean Squared Error()