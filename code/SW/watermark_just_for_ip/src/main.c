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

#include "SDoperation.h"
#include "platform.h"
#include "sleep.h"
#include "xiic_l.h"
#include "xil_printf.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xscugic.h"
#include <stdio.h>

/* Device hardware build related constants.*/

#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID
#define MEM_BASE_ADDR		(XPAR_PS7_DDR_0_S_AXI_BASEADDR + 0x10000000)

#define KX134_INTR_ID XPAR_FABRIC_IRQ_F2P_0_INTR
#define DMA_INTR_ID  XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR
#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID
#define INTC XScuGic
#define INTC_HANDLER XScuGic_InterruptHandler
#define IIC_BASE_ADDRESS XPAR_IIC_0_BASEADDR


#define TEST_DEVICE_ADDRESS 0x1F /* ADD of KX134 */
#define SAMPLE_SIZE 960

static float x_Buffer[SAMPLE_SIZE];
static float y_Buffer[SAMPLE_SIZE];
static float z_Buffer[SAMPLE_SIZE];
static int32_t SD_Buffer[SAMPLE_SIZE * 2*3];
static u8 BUF_READ_ADD = 0x63;


/*Device instance definitions*/
static XAxiDma AxiDma; /* Instance of the XAxiDma */
static INTC Intc; /* Instance of the Interrupt Controller */
volatile int Watermark_flag;
volatile int done_flag;
/************************** Function Prototypes ******************************/
static int SetupIntrSystem(INTC *IntcInstancePtr, u16 KX134_IntrId,
                           u16 FIFO_IntrId, u8 *Dataout_addr,
						   XAxiDma * AxiDmaPtr);
static void KX134_IntrHandler(void *CallBackRef);
static void DMA_IntrHandler(void *CallBackRef);


/*****************************************************************************/

int main() {

  init_platform();

  u8 CNTL1_OFF[2] = {0x1B, 0X00};
  u8 ODCNTL[2] = {0x21, 0X0E}; // default:0x06 25.6k:0x0F 12.8k:0x0E
  u8 INC1[2] = {0x22, 0X30};
  u8 INC4[2] = {0x25, 0X20};
  u8 BUF_CNTL1[2] = {0x5E, 0X3C}; // threshold = 60
  // u8 XOUT_L_ADD = 0x08;
  /*Schreibe 0xE0 in das Register BUF_CNTL2 (Buffer Control 2) um den Sample
Buffer zu aktivieren (BUFE = 1), die Auflösung der Beschleunigungsdaten auf
16-Bit zu setzen (BRES=1), den „Buffer Full Interrupt“ zu aktivieren (BFIE=1),
und den Modus auf „Sample Buffer to FIFO“ zu setzen (BM=0).*/
  u8 BUF_CNTL2[2] = {0x5F,
                     0XE0}; // buffer active, full_interrupt disable, mode:FIFO
  u8 CNTL_ON[2] = {0x1B, 0XD0}; // default 0xD0 32g 0xD0
  u8 DATAOUT[360];
  XAxiDma_Config *Config;

  char filename[30];
  int i = 0;
  int j = 0;
  int iterations = 0;
  int Status;
  unsigned returndata;
  float acc_factor = (1.0f / 32767.0f) * 32.0f * 9.81f;
  float xout_f;
  float yout_f;
  float zout_f;

  int16_t XOUT;
  int16_t YOUT;
  int16_t ZOUT;

  /*initialize AXI-FIFO*/

  Config = XAxiDma_LookupConfig(DMA_DEV_ID);
  if (!Config) {
    xil_printf("No config found for %d\r\n", DMA_DEV_ID);
    return XST_FAILURE;
  }

  /*
   * This is where the virtual address would be used, this example
   * uses physical address.
   */
  Status = XAxiDma_CfgInitialize(&AxiDma, Config);
  if (Status != XST_SUCCESS) {
  		xil_printf("Initialization failed %d\r\n", Status);
  		return XST_FAILURE;
  	}
  printf("finish Initialize AXI DMA \n");

  /*initialize and configure KX134*/
  printf("start\n");
  returndata =
      XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, CNTL1_OFF, 2, XIIC_STOP);
  printf("initialize:%u\n", returndata);
  returndata =
      XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, ODCNTL, 2, XIIC_STOP);
  printf("set sample rate:%u\n", returndata);
  returndata =
      XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, INC1, 2, XIIC_STOP);
  printf("enable physical interrupt:%u\n", returndata);
  XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, INC4, 2, XIIC_STOP);
  printf("set pin:%u\n", returndata);
  XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, BUF_CNTL1, 2, XIIC_STOP);
  printf("set threshold:%u\n", returndata);
  XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, BUF_CNTL2, 2, XIIC_STOP);
  printf("enable buffer:%u\n", returndata);



  mount_sd();
  printf("file name:\n");
  scanf("%s", filename);
  read_sd(SD_Buffer, SAMPLE_SIZE *3,filename);
  Xil_DCacheFlushRange((UINTPTR) SD_Buffer, 4 * SAMPLE_SIZE * 2*3);
  printf("finish read data from SD\n");
  /*txt file is already loaded in memory,start transfer to PL*/
  XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
  /* Disable all interrupts before setup */
  Status = SetupIntrSystem(&Intc, KX134_INTR_ID, DMA_INTR_ID, DATAOUT,
                           &AxiDma);
  if (Status != XST_SUCCESS) {
    xil_printf("set up Intr system failed %d\r\n", Status);
    return XST_FAILURE;
  }
  printf("finish setup intr system\n");
  XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

  /*start get sample from KX134
   * */
  printf("press any key to start\n\r");
  getchar();

  while (1) {
    if (iterations > 0) {
      xil_printf("Press any key to re-start ...\n\r");
      getchar();
    }
    iterations++;

    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR) SD_Buffer,
    			4 * SAMPLE_SIZE * 2*3, XAXIDMA_DMA_TO_DEVICE);//length in bytes
    	if (Status != XST_SUCCESS) {

    		xil_printf("Failed to initialize DMA TX\r\n");
    		return XST_FAILURE;
    	}
    xil_printf("set send request\r\n");


    returndata =
        XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, CNTL_ON, 2, XIIC_STOP);
    printf("CNTL_ON:%u\n", returndata);
    xil_printf("start sampling ...\n\r");

    while (i < SAMPLE_SIZE-1) {
      while (!Watermark_flag) {
        /* NOP */
      }
      Watermark_flag = 0;
      for (j = 0; j < 60; j++) {
    	i++;
    	if(i>=SAMPLE_SIZE) break;
        XOUT = (DATAOUT[1 + 6 * j] << 8) + DATAOUT[0 + 6 * j];
        YOUT = (DATAOUT[3 + 6 * j] << 8) + DATAOUT[2 + 6 * j];
        ZOUT = (DATAOUT[5 + 6 * j] << 8) + DATAOUT[4 + 6 * j];
        xout_f = XOUT;
        yout_f = YOUT;
        zout_f = ZOUT;
        x_Buffer[i] = xout_f * acc_factor;
        y_Buffer[i] = yout_f * acc_factor;
        z_Buffer[i] = zout_f * acc_factor;

      }
    }

    returndata = XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, CNTL1_OFF, 2,
                           XIIC_STOP);
    printf("CNTR_OFF:%u\n", returndata);
    xil_printf("end sampling \n\r");
    write_sd_txt(iterations, x_Buffer, y_Buffer,z_Buffer,SAMPLE_SIZE);

    i = 0;
    printf("END iteration:%d\n", iterations);
  }
  cleanup_platform();
  return 0;
}

/*****************************************************************************/
/*
 *
 * This function setups the interrupt system so interrupts can occur for the
 * DMA, it assumes INTC component exists in the hardware system.
 *
 * @param	IntcInstancePtr is a pointer to the instance of the INTC.
 * @param	AxiDmaPtr is a pointer to the instance of the DMA engine
 * @param	TxIntrId is the TX channel Interrupt ID.
 * @param	RxIntrId is the RX channel Interrupt ID.
 *
 * @return
 *		- XST_SUCCESS if successful,
 *		- XST_FAILURE.if not successful
 *
 * @note		None.
 *
 ******************************************************************************/
static int SetupIntrSystem(INTC *IntcInstancePtr, u16 KX134_IntrId,
                           u16 DMA_IntrId, u8 *Dataout_addr,
						   XAxiDma * AxiDmaPtr) {
  int Status;

  XScuGic_Config *IntcConfig;

  /*
   * Initialize the interrupt controller driver so that it is ready to
   * use.
   */
  IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
  if (NULL == IntcConfig) {
    return XST_FAILURE;
  }

  Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
                                 IntcConfig->CpuBaseAddress);
  if (Status != XST_SUCCESS) {
    return XST_FAILURE;
  }

  XScuGic_SetPriorityTriggerType(IntcInstancePtr, KX134_IntrId, 0xA0, 0x3);
  XScuGic_SetPriorityTriggerType(IntcInstancePtr, DMA_IntrId, 0x00, 0x3);

  /*
   * Connect the device driver handler that will be called when an
   * interrupt for the device occurs, the handler defined above performs
   * the specific interrupt processing for the device.
   */
  Status =
      XScuGic_Connect(IntcInstancePtr, KX134_IntrId,
                      (Xil_InterruptHandler)KX134_IntrHandler, Dataout_addr);
  if (Status != XST_SUCCESS) {
    return Status;
  }

  Status = XScuGic_Connect(
      IntcInstancePtr, DMA_IntrId, (Xil_InterruptHandler)DMA_IntrHandler,
	  AxiDmaPtr); // tbd write FIFO Handler, set right callback
  if (Status != XST_SUCCESS) {
    return Status;
  }

  XScuGic_Enable(IntcInstancePtr,
                 KX134_IntrId);
  XScuGic_Enable(IntcInstancePtr, DMA_INTR_ID);

  /* Enable interrupts from the hardware */

  Xil_ExceptionInit();
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)INTC_HANDLER,
                               (void *)IntcInstancePtr);

  Xil_ExceptionEnable();

  return XST_SUCCESS;
}

static void KX134_IntrHandler(void *CallBackRef) {
  u8 *Dataout_addr = (u8 *)CallBackRef;
  XScuGic_Disable(&Intc, KX134_INTR_ID);
  Watermark_flag = 1;
  xil_printf("GET KX134 INTR\r\n");
  XIic_Send(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, &BUF_READ_ADD, 1,
            XIIC_REPEATED_START);
  XIic_Recv(IIC_BASE_ADDRESS, TEST_DEVICE_ADDRESS, Dataout_addr, 360,
            XIIC_STOP);

  XScuGic_Enable(&Intc, KX134_INTR_ID);
}

static void DMA_IntrHandler(void *CallBackRef) {
	u32 IrqStatus;
		XAxiDma *AxiDmaInst = (XAxiDma *) CallBackRef;
		xil_printf("GET MM2S INTR\r\n");
		/* Read pending interrupts */
		IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);
		/* Acknowledge pending interrupts */
		XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);
		if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK)) {
			xil_printf("send done\n");
			XScuGic_Disable(&Intc, DMA_INTR_ID);
		}
		else {
			xil_printf("Error in DMA RX \r\n");
		}
}


