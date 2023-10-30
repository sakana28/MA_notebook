#writing 

The AXI IIC Bus Interface module provides the transaction interface to the AXI4-Lite interface. 它可作为Master或者Slave工作，且支持Multi-master工作模式。
在本工作中，SCL被配置为1000KHz。
![[Pasted image 20231030225503.png]]
值得注意的是，This core does not provide explicit electrical connectivity to the IIC bus. 这代表，该IP核与外界通信的信号并不是双向的。用户应该在设计中确保三态门缓冲和上拉电阻的存在，以符合协议要求。
（from internet replace later)
![[iobuf.svg]]