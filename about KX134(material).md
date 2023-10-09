#writing #hw_implementation

## from specification
The KX134-1211 is a tri-axis accelerometer designed to measure motion in multiple directions, with sensitivity options ranging from ±8g to ±64g. This device uses silicon-based technology and features a customizable three-part data handling system, known as the Advanced Data Path (ADP). The ADP includes a filter to remove noise, a second filter that can serve two purposes—either additional noise removal or emphasizing certain frequencies—and a calculation engine for averaging the signal.

One standout feature is the device's ability to detect both wake-up and return-to-sleep movements with high precision; it can even detect changes as small as 15.6 mg. The KX134-1211 also has a 512-byte data buffer, allowing it to store information even while that information is being read.

This accelerometer is equipped with built-in functions for detecting specific types of motion like orientation changes, single or double taps, and free-fall events. The core sensing element is made using Kionix's unique micromachining process. It senses acceleration through a change in electrical capacity, made more accurate through techniques that minimize common errors from manufacturing variations, temperature, and external stress. This sensing element is tightly sealed to keep out contaminants.

Alongside the sensing element, there is a separate chip that fine-tunes the signal and runs user-set programs for data analysis. This device offers less noise and better consistency over a range of temperatures compared to similar products. It comes in a small 12-pin package and operates within a voltage range of 1.7V–3.6V for general operation and 1.2V–3.6V for input/output operations. The device uses internal voltage regulators to ensure steady performance, even when the supply voltage changes.

For user interaction, the KX134-1211 supports commonly-used digital communication protocols, I2C and SPI, to set up the chip, read data, and get updates on built-in detection features. Two extra pins can be configured to signal the results of these built-in detection functions, providing an additional layer of user feedback.

## Watermark Interrupt (WMI)
This example configures enables the accelerometer to start outputting sensor data to the internal buffer until a watermark is reached. When the watermark is reached, a hardware interrupt is generated and data can then be read from the buffer. 

#### Interrupt Control 4 (INC4).
This register controls routing of an interrupt reporting to physical interrupt pin INT1. Note: that to properly change the value of this register, the PC1 bit in CNTL1 register must first be set to “0”.


![[Pasted image 20230913161357.png]]

WMI1 – Watermark interrupt reported on physical interrupt pin INT1
WMI1 = 0 – disable
WMI1 = 1 – enable
Note: WMI & BFI1 are level triggered interrupt source. If the valid condition persists, and the interrupt stays enabled, the interrupt will block any further interrupts from other sources from triggering the INT1 pin. To let other interrupt sources through, WMI/BFI1 needs to be cleared once detected.

#### INC1
This register controls the settings for the physical interrupt pin INT1.
Note that to properly change the value of this register, the PC1 bit in CNTL1 register must first be set to “0”.

![[Pasted image 20230913161907.png]]
set the polarity of the physical interrupt to active high and configure for latched operation.

#### BUF_CTNL1
Read/write control register that controls the buffer sample threshold. This register is On-The-Fly (OTF) register and can be written to while the KX134-1211 is enabled (PC1 bit in CNTL1 register is set to “1”) and the change will be accepted with no interruption in the operation.

![[Pasted image 20230913162939.png]]
SMP_TH[7:0] Sample Threshold – determines the number of samples that will trigger a watermark interrupt or will be saved prior to a trigger event. When BRES=1, the maximum number of samples is 86; when BRES=0, the maximum number of samples is 171. The minimum number of samples must be greater than or equal to 2. **set a watermark level**

#### BUF_CNTL2
Read/write control register that controls sample buffer operation. This register is On-The-Fly (OTF) register and can be written to while the KX134-1211 is enabled (PC1 bit in CNTL1 register is set to “1”) and the change will be accepted with no interruption in the operation.

![[Pasted image 20230913163207.png]]

 set the resolution of the acceleration data samples collected to 16-bit resolution (BRES=1) and set the operating mode of the sample buffer to FIFO (BM=0).
![[Pasted image 20230913163303.png]]