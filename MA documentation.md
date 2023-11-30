## Use case 1 : Signal Recorder
1. Connect the Pmod GPIO J58 on ZC706 to the pins of the KX134-1211-EVB110 as shown in the figure below. Insert the SD card into the slot.![[recorder_pin.png]]
2. Open the serial port corresponding to USB-JTAG in a serial terminal program such as Cutecom. Configure with the default baud rate of 115200, 8 bits data, no parity and 1 stop bit. 
3. In Vitis, select "run as-launch hardware" to download the compiled software and bitstream.
4. In the serial terminal program, enter any character to trigger the KX134 to begin sampling. (Only one character should be entered, because this functionality is implemented through getchar( ), which reads a single character from the standard input stream. When the input buffer is empty, it blocks the program and waits for user input. Sending a string will cause characters to remain in the buffer after this iteration, so on the next loop, the program will not wait for user input, and will continue directly)
5. After the predefined number of samples have been processed in the program, the program sends a command to stop KX134 sampling and write the collected data to the SD card. The first run will generate three files named 1x.txt, 1y.txt, and 1z.txt, and so on.

## Use case 2 : Signal Generator

Use Case 2: Signal Generator  
1.Connect the ZC706 as shown in the diagram, insert an SD card with source file in it. In the file, 三个方向上的 acceleration data 以 X，Y，Z的顺序依次排列。一个数据占一行。

2.In Vitis, select "run as-launch hardware" to download the compiled software and bitstream.
3.In Cutecom or other serial terminal, enter the filename of the text file(without 后缀名)  which is  used as the signal source.  
4.Enter any character to put the Custom IP into operational mode.  
After 10,000 samples, the sampling run ends. Enter another filename to use a different signal source text file or terminate the program.  
View the output text file written to the SD card.![[testpin.png]]