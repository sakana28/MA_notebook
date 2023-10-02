/******************************************************************************
 *
 * Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <math.h>
#include "platform.h"
#include "xil_printf.h"
#include "integer.h"
#include "string.h"

#include "ff.h"


static FATFS fatfs;

void mount_sd()
{
	BYTE work[FF_MAX_SS];
		FRESULT status;
		//在 FatFs 模块上注册 /注销一个工作区 (文件系统对象 )
		printf("mounting\n");
		status = f_mount(&fatfs, "", 0);
		if (status != FR_OK) {
			xil_printf("volume is not FAT format\n");
			//格式化SD卡
			f_mkfs("", FM_FAT32, 0, work, sizeof work);
			f_mount(&fatfs, "", 0);
		}
		printf("finish mounting\n");
}


void write_sd_txt(int iterations,  float  *data_x, float  *data_y, float  *data_z, int data_number) //float=4byte

{

    xil_printf("start writing file\n\r");
    char filename[10];

	FIL fil;

	UINT bw;
	int i;
    char buffer[100];

	sprintf(filename, "%d.txt", iterations);  // turn int and char to string
	f_open(&fil, filename, FA_CREATE_ALWAYS | FA_WRITE);
	f_lseek(&fil, 0);  	//move pointer to 0 position
	for(i=0;i<data_number;i++)
	 {
    sprintf(buffer, "%f\n", *(data_x+i));
    f_write(&fil, buffer,  strlen(buffer), &bw);
    sprintf(buffer, "%f\n", *(data_y+i));
       f_write(&fil, buffer,  strlen(buffer), &bw);
       sprintf(buffer, "%f\n", *(data_z+i));
          f_write(&fil, buffer,  strlen(buffer), &bw);

	 }
    xil_printf("end writing file\n\r");
	f_close(&fil);
}

