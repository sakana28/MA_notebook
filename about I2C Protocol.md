#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock (SCL) and the serial data (SDA) lines. The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. Both lines are open-drain outputs, which means that they can be pulled to a logic low level, but cannot be driven high. Therefore, the pull-up resistor on the line is necessary to pull the line voltage up to logic high level when no device is pulling it low.

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 

### Open-drain and Duplex
I 2C 是半双工通信，每次只有一个控制器或目标设备在总线上发送数据。

### START and STOPcondition 
All transactions begin with a START (S) and are terminated by a STOP (P).
After the master initiates a start condition, all slaves go from idle to active, waiting to receive an address.

next chapter:
[[custom I2C slave]]