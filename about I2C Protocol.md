#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock (SCL) and the serial data (SDA) lines. The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. Both lines are open-drain outputs, which means that they can be pulled to a logic low level, but cannot be driven high. Therefore, the pull-up resistor on the line is necessary to pull the line voltage up to logic high level when no device is pulling it low.

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 

### Open-drain and Duplex
The I2C protocol is a half-duplex bus that facilitates bidirectional communication, using the same transmission lines for both data transmission and reception. However, simultaneous data exchange between the communicating devices is not possible. Only one controller or target device can transmit data on the bus at a single time.

To efficiently facilitate bidirectional communication, the I2C specification dictates that both SDA and SCL lines are open-drain. Open-drain refers to an output type in which the line can be pulled low or released high. When there is no I2C device actively pulling the line low, pull-up resistors will elevate the line to the Vcc level. This differs from push-pull outputs, whichcan result in short-circuits when multiple devices attempt to output conflicting high and low levels on the I2C bus at the same time.
![[Pasted image 20231023032001.png]]
![[Pasted image 20231023023643.png]]
（from A Basic Guide to I2C）
On the other hand, open-drain outputs facilitate the implementation of wired-AND logic. The truth table for the wired-AND logic is shown in Table 1. A low output from any device connected to the bus will pull the whole bus low. Therefore, both SDA and SCL remain at high level when the bus is idle. The device that first pulls the bus level down gains control over the bus. If multiple masters try to transmit a 0 bit, the bus state will remain low as expected. When multiple masters attempt to initiate transmission, the bus state will remain low as expected if they all transmit low. However, if one master transmits a high while another transmits a low, the low bit will dominate and pull the bus low, indicating a collision. The master transmitting the 1 bit will detect this discrepancy and know that it lost arbitration, so it will stop transmitting. In this way, arbitration between multiple master devices is achieved in I2C.
![[Pasted image 20231023025331.png]]
### START and STOPcondition 


All transactions begin with a START (S) and are terminated by a STOP (P).
After the master initiates a start condition, all slaves go from idle to active, waiting to receive an address.



next chapter:
[[custom I2C slave]]