#writing 
![[signal_generator.drawio (1) 1.svg]]

This section first discusses the intended functionality of the signal generator system and provides a preliminary design.

The system removes the KX134 accelerometer used in the signal recorder, replacing it with a custom IP core. This IP core can be configured and read via I2C like the KX134, allowing reuse of the signal recorder software to acquire and log acceleration data from the signal generator.

The SD card serves as the signal source for the generator. Software reads a text file from the SD card and transfers it to the PL over the AXI4 bus. The custom IP core buffers the acquired data. When the buffered data reaches a threshold configured via I2C, the IP asserts an interrupt to notify the PS to read out the samples. For testing, the system also integrates part of the signal recorder. The AXI-IIC IP handles I2C communication to configure and read the custom IP, sending the data back to the PS for storage on the SD card. This realizes a loopback between the acceleration signal source and the recorded data. After the experiment, there should be two identical text files on the SD card.

The AXI-DMA module bridges data transfer between the custom IP and PS. Direct memory access (DMA) moves data between memory and the custom IP without processor involvement. The AXI-Stream protocol is efficient for the custom IP. And DMA offloads the PS so PS can deal with signal transmission and acquisition at the same time.

Figure ()  shows a block diagram of the signal generator system. Two AXI4 buses connect the PS GP and HP ports to the PL. The AXI-IIC and custom IPs are mapped to pins connected to the GPIO header and joined by jumper wires to create the I2C bus. Both the AXI-DMA and custom IP generate interrupts to activate handlers in the PS.