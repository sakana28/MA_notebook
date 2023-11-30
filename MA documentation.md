
1. Connect the Pmod GPIO to the pins of the KX134-EVAL as shown in the figure below. Insert the SD card into the slot.
2. Open the serial port corresponding to USB-JTAG in a serial terminal program such as Cutecom. Configure with the default baud rate of 115200, 8 bits data, no parity and 1 stop bit. 
3. In Vitis, select "run as-launch hardware" to download the compiled software and bitstream.

1. Use case: Signall Recorder
ZC706 Connection  
This project utilizes the JTAG interface to configure the FPGA on the ZC706. Switches SW4 and SW11 must be set to the positions shown in the diagram JTAG. 通过microUSB-USB线连接 usb-JTAG用于下载比特流和elf文件，usb-uart线用于与host pc通信。  
Use Case 1: Signal Recorder  
如下图所示，将Pmod GPIO与KX134-EVAL的pin连接。将 SD卡插入 into the slot.  
In Cutecom or other serial terminal programs 打开usbjtag对应的串口。配置使用默认Baud rate 115200,8 bits数据，no parity,1 stop bit.在vitis中对编译过的应用选择 run as-launch hardware。  
In Cutecom or other serial terminal programs, press any key to trigger the KX134 to begin sampling. (只能输入一个字符，该功能通过getchar()实现，功能是从缓冲区读取一个字符，如果缓冲区空就等待用户输入字符。输入字符串会导致本次运行后缓冲区有字符存在，在程序下一次循环时不会再等待用户输入，而是直接读取一个字符)  
After 程序中规定的 samples have been processed in program, 程序发送命令使KX134停止采样并将收集到的数据写入SD卡，第一次运行后会获得1x.txt 1y.txt 1z.txt三个文件，文件名中的数字随着运行次数递增. 在Terminal 再次出现"Press any key to start"message 后，在therminal中再次输入字符可以trigger another sampling.  
View the generates text file written to the SD card.  
Use Case 2: Signal Generator  
Connect the ZC706 as shown in the diagram and insert an SD card containing the desired text file to use as the signal source.  
Run the Vitis program.  
In Cutecom or another terminal program, enter the filename of the text file to use as the signal source.  
Press any key to put the Custom IP into operational mode.  
After 10,000 samples, the sampling run ends. Enter another filename to use a different signal source text file or terminate the program.  
View the output text file written to the SD card.