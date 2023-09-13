
#base
![[Pasted image 20230427120229.png]]
![[Pasted image 20230427120254.png]]

I2C bus multiplexed to:

° Si570 user clock

° ADV7511 HDMI codec

° M24C08 EEPROM (1 kB)

° 1-To-16 TCA6416APWR port expander

° RTC-8564JE real time clock

° FMC1 LPC connector

° FMC2 LPC connector

° PMBUS data/clock

## PCA9548A
The PCA9548A is an octal bidirectional translating switch controlled via the I2C-bus. The  
SCL/SDA upstream pair fans out to eight downstream pairs, or channels. Any individual  
SCx/SDx channel or combination of channels can be selected, determined by the  
contents of the programmable control register.  

An active LOW reset input allows the PCA9548A to recover from a situation where one of  
the downstream I 2 C-buses is stuck in a LOW state. Pulling the RESET pin LOW resets  
the I 2C-bus state machine and causes all the channels to be deselected as does the  
internal Power-on reset function.  

The pass gates of the switches are constructed such that the VDD pin can be used to limit  
the maximum high voltage which will be passed by the PCA9548A. This allows the use of  
different bus voltages on each pair, so that 1.8 V or 2.5 V or 3.3 V parts can communicate  
with 5 V parts without any additional protection. External pull-up resistors pull the bus up  
to the desired voltage level for each channel. All I/O pins are 6 V tolerant.

PCA9548A是一种八路双向转换开关，通过I2C总线进行控制。SCL/SDA上行线可扇出至八个下行线，即通道。可通过可编程控制寄存器的内容选择任何单个SCx/SDx通道或通道组合。

通过一个低电平RESET输入引脚，PCA9548A可以恢复其中一个下行I2C总线处于低电平状态的情况。将RESET引脚拉低可以重置I2C总线状态机，并使所有通道取消选择，内部上电复位功能也可以实现此操作。

开关的通断由传导通道构成，可使用VDD引脚限制PCA9548A通过的最大高电平。这允许每对通道使用不同的总线电压，因此1.8V、2.5V或3.3V的部件可以与5V部件通信，而无需任何附加保护。外部上拉电阻将总线拉高至每个通道所需的电压级别。所有I/O引脚都具有6V的耐受能力。

https://support.xilinx.com/s/question/0D52E00006hpbkxSAA/connecting-a-sensor-via-i2c-to-zc702?language=en_US


So, you may access i2c on either FMC1, or 2 (to get to the A9 processor i2c interface)
As [@austintin7](https://support.xilinx.com/s/profile/0052E00000N39ZcQAJ "null") said, the "hard" I2C master in the Zynq PS is connected to a number of resources on the ZC702 board - none of them directly to any of the 2x6 or 1x6 header connectors.

The 2x6 header labelled "2x6 Male Pin I/O Header driven by I2C expander U80" are general purpose I/O provided by an I2C -> GPIO converter; so the connector itself is GPIO (not I2C).

The other 2x6 and 1x6 PMOD headers are connected to the PL - not the PS.

So, you cannot use the Zynq PS I2C master to talk to the PMOD headers (unless you reassign the PS I2C master to use EMIO - but that will leave all the other I2C peripherals on the ZC702 without a master).

However, you (through IP Integrator) instantiate a second I2C master. This master will be implemented in the PL and can be connected to any pin of the FPGA. Using this, you can drive either of the two PMOD connectors with the SDA/SCL required for I2C communication.

Avrum


## AXI-IIC IP
![[Pasted image 20230503151219.png]]

![[Pasted image 20230503151330.png]]

## IIC Grundkenntnis
https://www.cnblogs.com/fire909090/p/11594532.html
1.  以启动信号START来掌管总线，以停止信号STOP来释放总线；
2.  每次通讯以START开始，以STOP结束；
3.  启动信号START后紧接着发送一个地址字节，其中7位为被控器件的地址码，一位为读/写控制位R/W,R. /W位为0表示由主控向被控器件写数据，R/W为1表示由主控向被控器件读数据；
4.  当被控器件检测到收到的地址与自己的地址相同时，在第9个时钟期间反馈应答信号；
5.  每个数据字节在传送时都是高位(MSB)在前；

SDA 和SCL 都是双向线路，都通过一个电流源或上拉电阻连接到正的电源电压（见图3）当总线空闲时，这两条线路都是高电平。
当**SCL为高电平时，SDA应该保持不变**，并且此时SDA的信号即为有效，**当SCL为低电平时，SDA才可以改变**。
	SCL high but SDA falling -> start
	SCL high but SDA rising -> start

## Zynq connection with sensor

https://blog.csdn.net/weixin_41445387/article/details/113743678

