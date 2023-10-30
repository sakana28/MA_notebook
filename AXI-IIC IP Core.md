#writing 
该IP可被配置为Master or slave。本工作中，它是向KX134发起传输的Master.
The AXI IIC Bus Interface module provides the transaction interface to the AXI4-Lite interface. This core does not provide explicit electrical connectivity to the IIC bus. 这代表，该IP核与外界通信的信号并不是双向的。用户应该在设计中确保三态门缓冲和上拉电阻的存在，以符合协议要求。
![[iobuf.svg]]