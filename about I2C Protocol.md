#writing  #hw_implementation #implementation 




## https://www.nxp.com/docs/en/user-guide/UM10204.pdf

The I2C protocol is a two-wire serial communication bus. Devices on the bus have individual addresses and are assigned as master or slave devices. There must be at least one master device on the bus because only master devices can initiate communication. All devices are connected to the same two serial lines, the serial clock (SCL) and the serial data (SDA) lines. The master device controls the SCL line while the device currently writing data to the bus controls the SDA line. Both lines are open-drain outputs, which means that they can be pulled to a logic low level, but cannot be driven high. Therefore, the pull-up resistor on the line is necessary to pull the line voltage up to logic high level when no device is pulling it low.

next chapter:
[[custom I2C slave]]