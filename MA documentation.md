
ZC706的连接方式  
本项目中使用JTAG配置FPGA ，SW4和SW11必须如图所示  
usecase1. signal recorder  
1.按照图片连接并将SD卡插入卡槽  
2.vitis中运行程序  
3.在cutecom或其他terminal中输入任意键以开启KX134的采样功能  
4.采集10000个样本后本次采样结束，如果再次输入任意键会开启下一次采样  
5.查看SD卡中获得的文本文件  
usecase 2. signal generator  
1.按照图片连接并将SD卡插入卡槽，SD卡中应该已经装有符合要求的文本文档  
2.在vitis中运行程序  
3.在cutecom或其他terminal中输入作为信号源的文件名  
4.输入任意键使Custom IP进入工作模式  
5.采集10000个样本后本次采样结束，再次输入作为信号源的文件名或结束  
6.查看SD卡中获得的文本文件  

1. Usecase: Signall Recorder
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