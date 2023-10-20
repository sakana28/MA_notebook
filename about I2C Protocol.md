#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock (SCL) and the serial data (SDA) lines. The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. Both lines are open-drain outputs, which means that they can be pulled to a logic low level, but cannot be driven high. Therefore, the pull-up resistor on the line is necessary to pull the line voltage up to logic high level when no device is pulling it low.

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 

### Open-drain and Duplex
I 2C 是半双工通信，即同一根传输线既作接收又作发送，数据可以在两个方向上传送，但通信双方不能同时收发数据。每次只有一个控制器或目标设备在总线上发送数据。
为了简洁地实现这种通信，I2C协议规定SDA和SCL都使用开漏线路，当总线上有多个从机时，如果使用推挽输出，当一个设备试图输出高电平，一个设备试图输出低电平时，就会发生短路。因此
开漏指的是一种输出类型，它既可以将总线拉低至某一电压（多数情况下为地），也可以 "释放 "总线，让上拉电阻将其拉高。
### START and STOPcondition 
All transactions begin with a START (S) and are terminated by a STOP (P).
After the master initiates a start condition, all slaves go from idle to active, waiting to receive an address.

next chapter:
[[custom I2C slave]]