#writing #structure

The signal generator developed in this work is aimed to emulate the functionality of the KX134 accelerometer. Therefore, this section provides background information on the basic capabilities and interface of the KX134 that are relevant to reproducing its operation. 
## KX134
The KX134 is a triaxial accelerometer from Kionix that is capable of measuring acceleration forces along the X, Y, and Z axes. The KX134 enables user interaction, such as configuring its settings or reading acceleration data, via I2C or SPI protocols. By writing data into specific registers, users can configure various features, including sensor range, output data rate, triggering options, and buffer size.
## Pin assignments and description
The pins of the KX134 accelerometer are shown in Table 1 below.
![[Pasted image 20231010054814.png]]
This work uses the KX134-1211-EVK-001 evaluation board to connect the sensor with other development platforms. A ribbon cable is utilized to connect the accelerometer evaluation board to the FPGA development board.
## Embedded Registers

The KX134 accelerometer has 128 8-bit registers that are mostly userprogrammable. Table 1 lists the available registers and their addresses.
![[Pasted image 20231010060519.png]]The upcoming section will provide a detailed description of the configuration registers associated with this project.

The Watermark Interrupt mode is an operating mode of the Accelerometer. samples are first stored in a buffer. Once the number of samples in the buffer reaches a user-defined threshold, a hardware interrupt is generated. In signal recorder, KX134 works in this mode. In signal generator, the behavior of the KX134 in this mode is emulated. Therefore, the registers that require to be configured in this mode will be introduced next.