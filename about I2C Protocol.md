#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock (SCL) and the serial data (SDA) lines. The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. Both lines are open-drain outputs, which means that they can be pulled to a logic low level, but cannot be driven high. Therefore, the pull-up resistor on the line is necessary to pull the line voltage up to logic high level when no device is pulling it low.

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 

### Open-drain and Duplex
The I2C protocol is a half-duplex bus that facilitates bidirectional communication, using the same transmission lines for both data transmission and reception. However, simultaneous data exchange between the communicating devices is not possible. Only one controller or target device can transmit data on the bus at a single time.


为了简洁地实现这种通信，I2C协议规定SDA和SCL都使用开漏线路。开漏指的是一种输出类型，即线路只能被驱动低电平或保持开路。如果没有 I2C 器件将其下拉，上拉电阻会将线路上拉至 Vcc。与开漏相对的是推挽。当总线上有多个从机时，如果使用推挽输出，当一个设备试图输出高电平，一个设备试图输出低电平时，就会发生短路。

To efficiently facilitate bidirectional communication, the I2C specification dictates that both SDA and SCL lines are open-drain. Open-drain refers to an output type in which the line can be pulled low or released high. When there is no I2C device actively pulling the line low, pull-up resistors will elevate the line to the Vcc level. This contrasts with push-pull arrangements, which can result in short-circuits when devices try to output conflicting high and low levels on the bus.
![[Pasted image 20231023032001.png]]
![[Pasted image 20231023023643.png]]
（from A Basic Guide to I2C）
另一方面，开漏输出便于实现线与逻辑。线与逻辑的真值表在表格1中展示。总线上任意一个器件输出低电平都会使总线为低电平。因此，当总线空闲时，SDA与SCL都保持高电平。先将总线电平拉低的器件可以获得总线的控制权。通过这种方式，I2C实现了在多个master devices之间的仲裁。
![[Pasted image 20231023025331.png]]
### START and STOPcondition 
All transactions begin with a START (S) and are terminated by a STOP (P).
After the master initiates a start condition, all slaves go from idle to active, waiting to receive an address.

next chapter:
[[custom I2C slave]]