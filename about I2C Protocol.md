#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf 

The I^2C protocol is a two-wire serial communication bus. Each Device on the bus have a specific address and is assigned as master or slave device. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock line(SCL) and the serial data line (SDA). The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. 

A fundamental contribution of this work is to implement an I^s2C Slave on FPGA. Therefore, the behavior of devices on the I2C bus during data transfer and the logic transition on both lines will be introduced next. 
### Open-drain and Duplex 
The I2C protocol is a half-duplex bus that facilitates bidirectional communication, using the same transmission lines for both data transmission and reception. However, simultaneous data exchange between the communicating devices is not possible. Only one controller or target device can transmit data on the bus at a single time. 

To efficiently facilitate bidirectional communication, the I2C specification dictates that both SDA and SCL lines are open-drain. Open-drain refers to an output type in which the line can be pulled low or released high. When there is no I2C device actively pulling the line low, pull-up resistors will elevate the line to the VDD level. This differs from push-pull outputs, whichcan result in short-circuits when multiple devices attempt to output conflicting high and low levels on the I2C bus at the same time. 
![[Pasted image 20231023032001.png]] ![[Pasted image 20231023023643.png]] （from A Basic Guide to I2C）

On the other hand, open-drain outputs facilitate the implementation of wired-AND logic. The truth table for the wired-AND logic is shown in Table 1. A low output from any device connected to the bus will pull the whole bus low. Therefore, both SDA and SCL remain at high level when the bus is idle. The device that first pulls the bus level down gains control over the bus. If multiple masters try to transmit a 0 bit, the bus state will remain low as expected. When multiple masters attempt to initiate transmission, the bus state will remain low as expected if they all transmit low. However, if one master transmits a high while another transmits a low, the low bit will dominate and pull the bus low, indicating a collision. The master transmitting the 1 bit will detect this discrepancy and know that it lost arbitration, so it will stop transmitting. In this way, arbitration between multiple master devices is achieved in I2C.
![[Pasted image 20231023025331.png]] 

During pin assignment in hardware design, the I/O pins of the Zynq PL fabric can be configured with internal pull-up elements that pull undriven pins to a logic high state. Together with tri-state buffers, this implements the open-drain output required for I2C operation. However, the internal pull-up resistor and the pin parasitic capacitance, primarily from the package and PCB trace, form an unintentional resistive-capacitive (RC) delay element. This RC delay slows the signal edge transitions compared to a push-pull output with similar drive strength. That result in that I2C used for communication between low-speed devices. On the ZC706 board, the Zynq I/O pins connect to headers through a TXS0108E 8-bit bi-directional level shifter. According to the datasheet, this device supports maximum data rates of 110 Mbps for push-pull outputs versus only 1.2 Mbps for open-drain outputs. This speed limitation directly restricts the maximum SCL rate for this project. 



### Timing Sequence 
According to the I2C specification, data read operations occur when SCL is high, while SDA can change when SCL is low. Therefore, during data transmission, SDA should remain stable when SCL is high to avoid erroneous data sampling. 

### START and STOP Conditions 
SDA can only change when SCL is high during START and STOP conditions. A high-to-low transition of SDA when SCL is high indicates a START condition. A low-to-high transition of SDA when SCL is high indicates a STOP condition. The START condition occurs at the beginning of a transmission to wake up idle slaves on the bus. After the master initiates a START, all slaves transition from idle to active, waiting to receive an address. The STOP condition releases the bus for the next idle state after completing the transmission. In addition to the initial START, a Repeated START (Sr) condition can also occur. It is similar to a regular START but happens when the bus is busy instead of idle. The master uses it to initiate a new transmission while preserving control of the bus between transfers. 

### Byte Format
Each byte on the SDA data line must consist of 8 bits, with no limit on the number of bytes per transmission. After each data byte (8 bits), an acknowledgement (ACK) bit follows as the 9th bit. The byte order is most significant bit first. For a slave address byte, it comprises 7 address bits and 1 read/write control bit. Slave addresses are predefined and should be unique on the bus. Some I2C devices have configurable address bits, allowing multiple identical devices on the bus. 

### Acknowledgement
The protocol requires acknowledgements (ACKs) during data transfer. The receiver sends an ACK to indicate successful reception of a byte, after which the transmitter can send the next byte. There are two types of acknowledgement:
- A LOW level on the 9th acknowledge bit indicates an ACK. 
- A HIGH level on the 9th bit indicates a NACK (no acknowledge). 

When the master sends data, the slave generates the ACK. If SDA remains high when SCL is high during the 9th clock, the master can directly generate a STOP or ReSTART for a new transmission. When the slave sends data, the master generates the ACK. An ACK from the master means more data is expected. Once all desired data is received, the master sends NACK to tell the slave to stop sending data and release the bus and then sends a STOP to terminate the read operation. 

next chapter: [[custom I2C slave]]