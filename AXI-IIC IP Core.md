#writing 

The AXI IIC Bus Interface module serves as the transaction interface between the I2C protocol and the AXI4-Lite bus. This IP block is capable of operating as either a master or slave, and supports multi-master configurations.
For this work, the SCL clock is configured to 1 MHz, within the I2C specification of up to 1 MHz.
![[Pasted image 20231030225503.png]]
It is important to note that this AXI IIC core does not provide explicit electrical connectivity to the I2C bus. This means the interface signals to and from the IP block are not bidirectional. The user must ensure external tristate buffers and pull-up resistors are incorporated in the design to fulfill the I2C electrical requirements.
（from internet replace later)
![[iobuf.svg]]