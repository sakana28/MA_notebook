Tools: 
- Vivado v2021.1 (64-bit) 
- Vitis v2021.1 (64-bit)
In therminal : module load xilinx_vitis

## Use case 1 : Signal Recorder

1. Connect the Pmod GPIO J58 on ZC706 to the pins of the KX134-1211-EVB110 as shown in the figure below. Insert the SD card into the slot.![[recorder_pin.png]]
2. Connction JTAG-USB port  
3. Open Vitis, use folder software project/**workspace_copy** as workspace. 
4. Open the serial port corresponding to USB-JTAG in a serial terminal program such as Cutecom. Configure with the default baud rate of 115200, 8 bits data, no parity and 1 stop bit. 
5. right click application project **watermark_test** in explorer , select "run as-launch hardware" to download the compiled software and bitstream.
6. When the program is started, it prints messages about the configuration of specific registers for the KX134 via the I2C interface.  Within this message, the number indicates the number of bytes successfully transferred . This number should be 2.
![[Pasted image 20231130085907.png]]
5. In the serial terminal program, enter any character to trigger the KX134 to begin sampling. (Only one character should be entered, because this functionality is implemented through getchar( ), which reads a single character from the standard input stream. When the input buffer is empty, it blocks the program and waits for user input. Sending a string will cause characters to remain in the buffer after this iteration, so on the next loop, the program will not wait for user input, and will continue directly)
6. After the predefined number of samples have been processed in the program, the program sends a command to stop KX134 sampling and write the collected data to the SD card. The first run will generate three files named 1x.txt, 1y.txt, and 1z.txt, and so on.
### For rebuild and synthesis the vivado project
1. open project file signal_recorder.xpr in Vivado
2. click generate bitstream in Flow Navigator
3. click File / Export / Export hardware. The filename of the xsa file must be 

## Use case 2 : Signal Generator
### For test: 
1. Connect the ZC706 as shown in the diagram. Insert an SD card containing the source file. In the file, acceleration data from three directions is arranged in order of X, Y, Z, with each data point occupying one line.
![[testpin.png]]
![[Pasted image 20231130085316.png]]
2. right click application project  **custom_watermark_axis_test** in explorer , select "run as-launch hardware" to download the compiled software and bitstream.
3. After the program has been executed, the printed message about the initialization is the same as in use case 1, but there is an additional message about whether the AXI-DMA initialization was successful.
4. In a serial terminal program like Cutecom, enter the filename of the text file (without the file extension) to be used as the signal source.
5. Enter one character in Cutecom to enable the Custom IP to fill data into its internal buffer.
6. After the predefined number of samples have been processed in the program, the program sends a command to disable the Custom IP. Then the collected data is written to the SD card. 
7. The user can enter another filename to use a different signal source and start a new iteration.

### For rebuild and synthesis the vivado project
1. open project file signal_recorder.xpr in Vivado
2. click edit in the settings blank of project summary. Click IP/ Repository and add folder source code/ IP_repo as a IP repository. Applay the setting.
3. click generate bitstream in Flow Navigator
4. 