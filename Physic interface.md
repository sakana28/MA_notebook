#writing 
It is necessary to connect the custom I2C IP core and AXI IIC IP core via jumper wires on the development board instead of directly in the block design. As mentioned previously, the AXI-IIC IP core does not provide explicit electrical connectivity to the I2C bus. Additionally, FPGAs lack internal tristate components. However, the Input/Output Blocks (IOBs), located at each FPGA pin, contain tristate circuitry.

Thus, the signals that the custom I2C module reads or drives are scli, sclo, sclt, sdai, sdao and sdat. During synthesis, Vivado recognizes that the top-level I2C interface requires bidirectional signaling and automatically infers the tri-state buffer IOBUF. 

![[iobuf.drawio.svg]]