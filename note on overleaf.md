
#writing 




Getting Started with Vivado and Vitis for Baremetal Software Projects
https://digilent.com/reference/programmable-logic/guides/getting-started-with-ipi


硬件补充
SCL尽管是I2C总线时钟信号，在该系统中不被当时钟使用。系统时钟远快于SCL，对SCL的上升下降沿进行检测，获得与系统时钟同步的上升下降沿信号。
消抖后检测上升下降沿 检测开始结束 状态机 
register map有另一个状态机 idle getdata writedata
在模块已经被写入一个有效的地址后
如果收到读请求 getdata  收到valid信号 writedata 并寄存当前的data_from_master_reg
getdata中检测当前地址是普通register还是BUF。是BUF的话将fifo_din的值给data_to_master_reg,否则从register map中取出对应值。
writedata中将被寄存的数值写进地址对应的寄存器中

尽管SCL提供了I2C总线的时序信息，但为了在系统中尽量避免跨时钟域问题，整个PL部分使用同一个时钟。由于应用的系统时钟远快于SCL，且作为从机，custom IP不需要驱动SCL，只需要获得SCL的时序信息，因此用对SCL进行边沿检测取代将SCL作为时钟信号是可行的。该边沿检测逻辑基于register延时，在SCL的上升沿或下降沿上，会生成对应的同步脉冲信号，供内部逻辑使用。
为了简化I2C状态机状态转移的判断条件，该模块中也会根据I2C协议的规定生成START与STOP脉冲信号。具体生成逻辑如下：


red req生成在get_address_and_cmd状态，只高一个时钟周期
data valid生成在读取最后一位的时钟周期，只高一个时钟周期 否则会多次激活读写operation。为保证数据的可靠性，应该在valid有效时寄存其值。




这一章节中介绍了对系统的开发过程中进行的多项测试及其结果，并对整个系统进行了评估。首先进行了对signal recorder进行配置后采集真实的加速度数据的实验，然后对Custom IP单独进行测试。不将其与AXI-DMA连接，而是在PL添加一个计数器，将计数结果作为测试数据存入Sample Buffer，并让主机读出并储存测试数据。最终连接整个系统，测试signal recorder从SD卡读出文本文件并作为加速度数据，加速度数据再被主机读出并写入SD卡的Loopback测试。这三项测试都获得了预想中的结果。然后本章评估了系统的FPGA resource utilization，power consumption和实际场景中的实用性。

在本系统中，系统的吞吐率没有特殊的要求。I2C的最大时钟1M ODR最大12800。但该系统应保证数据传输过程中的准确性。

Sigrok 开源的logic analyzer framework Lecroy

由于连接后信号出现波动导致logic analyzer显示错误的I2C协议信息，因此另外引出两个Pin用于显示消抖后的信号，用于测试分析。


fundenmental add


power report 1
Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Tool Version     : Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
| Date             : Wed Sep 20 16:02:20 2023
| Host             : pinsel running 64-bit Ubuntu 20.04.6 LTS
| Command          : report_power -file design_1_wrapper_power_routed.rpt -pb design_1_wrapper_power_summary_routed.pb -rpx design_1_wrapper_power_routed.rpx
| Design           : design_1_wrapper
| Device           : xc7z045ffg900-2
| Design State     : routed
| Grade            : commercial
| Process          : typical
| Characterization : Production
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

Power Report

Table of Contents
-----------------
1. Summary
1.1 On-Chip Components
1.2 Power Supply Summary
1.3 Confidence Level
2. Settings
2.1 Environment
2.2 Clock Constraints
3. Detailed Reports
3.1 By Hierarchy

1. Summary
----------

+--------------------------+--------------+
| Total On-Chip Power (W)  | 1.795        |
| Design Power Budget (W)  | Unspecified* |
| Power Budget Margin (W)  | NA           |
| Dynamic (W)              | 1.576        |
| Device Static (W)        | 0.219        |
| Effective TJA (C/W)      | 1.8          |
| Max Ambient (C)          | 81.8         |
| Junction Temperature (C) | 28.2         |
| Confidence Level         | Low          |
| Setting File             | ---          |
| Simulation Activity File | ---          |
| Design Nets Matched      | NA           |
+--------------------------+--------------+
* Specify Design Power Budget using, set_operating_conditions -design_power_budget <value in Watts>


1.1 On-Chip Components
----------------------

+--------------------------+-----------+----------+-----------+-----------------+
| On-Chip                  | Power (W) | Used     | Available | Utilization (%) |
+--------------------------+-----------+----------+-----------+-----------------+
| Clocks                   |     0.005 |        3 |       --- |             --- |
| Slice Logic              |    <0.001 |     6473 |       --- |             --- |
|   LUT as Logic           |    <0.001 |     2049 |    218600 |            0.94 |
|   CARRY4                 |    <0.001 |       67 |     54650 |            0.12 |
|   Register               |    <0.001 |     3218 |    437200 |            0.74 |
|   LUT as Shift Register  |    <0.001 |      124 |     70400 |            0.18 |
|   F7/F8 Muxes            |    <0.001 |      156 |    218600 |            0.07 |
|   Others                 |     0.000 |      347 |       --- |             --- |
|   LUT as Distributed RAM |     0.000 |        2 |     70400 |           <0.01 |
| Signals                  |     0.001 |     4871 |       --- |             --- |
| Block RAM                |    <0.001 |      1.5 |       545 |            0.28 |
| I/O                      |    <0.001 |        8 |       362 |            2.21 |
| PS7                      |     1.569 |        1 |       --- |             --- |
| Static Power             |     0.219 |          |           |                 |
| Total                    |     1.795 |          |           |                 |
+--------------------------+-----------+----------+-----------+-----------------+


1.2 Power Supply Summary
------------------------

+-----------+-------------+-----------+-------------+------------+-------------+-------------+------------+
| Source    | Voltage (V) | Total (A) | Dynamic (A) | Static (A) | Powerup (A) | Budget (A)  | Margin (A) |
+-----------+-------------+-----------+-------------+------------+-------------+-------------+------------+
| Vccint    |       1.000 |     0.065 |       0.007 |      0.058 |       NA    | Unspecified | NA         |
| Vccaux    |       1.800 |     0.040 |       0.000 |      0.040 |       NA    | Unspecified | NA         |
| Vcco33    |       3.300 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vcco25    |       2.500 |     0.001 |       0.000 |      0.001 |       NA    | Unspecified | NA         |
| Vcco18    |       1.800 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vcco15    |       1.500 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vcco135   |       1.350 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vcco12    |       1.200 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vccaux_io |       1.800 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vccbram   |       1.000 |     0.002 |       0.000 |      0.002 |       NA    | Unspecified | NA         |
| MGTAVcc   |       1.000 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| MGTAVtt   |       1.200 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| MGTVccaux |       1.800 |     0.000 |       0.000 |      0.000 |       NA    | Unspecified | NA         |
| Vccpint   |       1.000 |     0.737 |       0.719 |      0.018 |       NA    | Unspecified | NA         |
| Vccpaux   |       1.800 |     0.084 |       0.074 |      0.010 |       NA    | Unspecified | NA         |
| Vccpll    |       1.800 |     0.017 |       0.014 |      0.003 |       NA    | Unspecified | NA         |
| Vcco_ddr  |       1.500 |     0.459 |       0.457 |      0.002 |       NA    | Unspecified | NA         |
| Vcco_mio0 |       1.800 |     0.004 |       0.003 |      0.001 |       NA    | Unspecified | NA         |
| Vcco_mio1 |       1.800 |     0.002 |       0.001 |      0.001 |       NA    | Unspecified | NA         |
| Vccadc    |       1.800 |     0.020 |       0.000 |      0.020 |       NA    | Unspecified | NA         |
+-----------+-------------+-----------+-------------+------------+-------------+-------------+------------+


1.3 Confidence Level
--------------------

+-----------------------------+------------+--------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| User Input Data             | Confidence | Details                                                | Action                                                                                                             |
+-----------------------------+------------+--------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------+
| Design implementation state | High       | Design is routed                                       |                                                                                                                    |
| Clock nodes activity        | Low        | User specified less than 75% of clocks                 | Provide missing clock activity with a constraint file, simulation results or by editing the "By Clock Domain" view |
| I/O nodes activity          | Low        | More than 75% of inputs are missing user specification | Provide missing input activity with simulation results or by editing the "By Resource Type -> I/Os" view           |
| Internal nodes activity     | Medium     | User specified less than 25% of internal nodes         | Provide missing internal nodes activity with simulation results or by editing the "By Resource Type" views         |
| Device models               | High       | Device models are Production                           |                                                                                                                    |
|                             |            |                                                        |                                                                                                                    |
| Overall confidence level    | Low        |                                                        |                                                                                                                    |
+-----------------------------+------------+--------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------+


2. Settings
-----------

2.1 Environment
---------------

+-----------------------+--------------------------+
| Ambient Temp (C)      | 25.0                     |
| ThetaJA (C/W)         | 1.8                      |
| Airflow (LFM)         | 250                      |
| Heat Sink             | medium (Medium Profile)  |
| ThetaSA (C/W)         | 3.3                      |
| Board Selection       | medium (10"x10")         |
| # of Board Layers     | 12to15 (12 to 15 Layers) |
| Board Temperature (C) | 25.0                     |
+-----------------------+--------------------------+


2.2 Clock Constraints
---------------------

+------------+-------------------------------------------------------------+-----------------+
| Clock      | Domain                                                      | Constraint (ns) |
+------------+-------------------------------------------------------------+-----------------+
| clk_fpga_0 | design_1_i/processing_system7_0/inst/FCLK_CLK_unbuffered[0] |            20.0 |
+------------+-------------------------------------------------------------+-----------------+


3. Detailed Reports
-------------------

3.1 By Hierarchy
----------------

+--------------------------+-----------+
| Name                     | Power (W) |
+--------------------------+-----------+
| design_1_wrapper         |     1.576 |
|   design_1_i             |     1.576 |
|     axi_dma_0            |     0.002 |
|       U0                 |     0.002 |
|     axi_iic_0            |     0.001 |
|       U0                 |     0.001 |
|     processing_system7_0 |     1.569 |
|       inst               |     1.569 |
|     ps7_0_axi_periph     |     0.003 |
|       s00_couplers       |     0.002 |
+--------------------------+-----------+



utilization report 1

Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-----------------------------------------------------------------------------------------------------------------------------
| Tool Version : Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
| Date         : Wed Sep 20 16:01:36 2023
| Host         : pinsel running 64-bit Ubuntu 20.04.6 LTS
| Command      : report_utilization -file design_1_wrapper_utilization_placed.rpt -pb design_1_wrapper_utilization_placed.pb
| Design       : design_1_wrapper
| Device       : 7z045ffg900-2
| Design State : Fully Placed
-----------------------------------------------------------------------------------------------------------------------------

Utilization Design Information

Table of Contents
-----------------
1. Slice Logic
1.1 Summary of Registers by Type
2. Slice Logic Distribution
3. Memory
4. DSP
5. IO and GT Specific
6. Clocking
7. Specific Feature
8. Primitives
9. Black Boxes
10. Instantiated Netlists

1. Slice Logic
--------------

+----------------------------+------+-------+------------+-----------+-------+
|          Site Type         | Used | Fixed | Prohibited | Available | Util% |
+----------------------------+------+-------+------------+-----------+-------+
| Slice LUTs                 | 2175 |     0 |          0 |    218600 |  0.99 |
|   LUT as Logic             | 2049 |     0 |          0 |    218600 |  0.94 |
|   LUT as Memory            |  126 |     0 |          0 |     70400 |  0.18 |
|     LUT as Distributed RAM |    2 |     0 |            |           |       |
|     LUT as Shift Register  |  124 |     0 |            |           |       |
| Slice Registers            | 3218 |     0 |          0 |    437200 |  0.74 |
|   Register as Flip Flop    | 2186 |     0 |          0 |    437200 |  0.50 |
|   Register as Latch        | 1032 |     0 |          0 |    437200 |  0.24 |
| F7 Muxes                   |  104 |     0 |          0 |    109300 |  0.10 |
| F8 Muxes                   |   52 |     0 |          0 |     54650 |  0.10 |
+----------------------------+------+-------+------------+-----------+-------+


1.1 Summary of Registers by Type
--------------------------------

+-------+--------------+-------------+--------------+
| Total | Clock Enable | Synchronous | Asynchronous |
+-------+--------------+-------------+--------------+
| 0     |            _ |           - |            - |
| 0     |            _ |           - |          Set |
| 0     |            _ |           - |        Reset |
| 0     |            _ |         Set |            - |
| 0     |            _ |       Reset |            - |
| 0     |          Yes |           - |            - |
| 11    |          Yes |           - |          Set |
| 1091  |          Yes |           - |        Reset |
| 85    |          Yes |         Set |            - |
| 2031  |          Yes |       Reset |            - |
+-------+--------------+-------------+--------------+


2. Slice Logic Distribution
---------------------------

+--------------------------------------------+------+-------+------------+-----------+-------+
|                  Site Type                 | Used | Fixed | Prohibited | Available | Util% |
+--------------------------------------------+------+-------+------------+-----------+-------+
| Slice                                      | 1169 |     0 |          0 |     54650 |  2.14 |
|   SLICEL                                   |  667 |     0 |            |           |       |
|   SLICEM                                   |  502 |     0 |            |           |       |
| LUT as Logic                               | 2049 |     0 |          0 |    218600 |  0.94 |
|   using O5 output only                     |    0 |       |            |           |       |
|   using O6 output only                     | 1574 |       |            |           |       |
|   using O5 and O6                          |  475 |       |            |           |       |
| LUT as Memory                              |  126 |     0 |          0 |     70400 |  0.18 |
|   LUT as Distributed RAM                   |    2 |     0 |            |           |       |
|     using O5 output only                   |    0 |       |            |           |       |
|     using O6 output only                   |    2 |       |            |           |       |
|     using O5 and O6                        |    0 |       |            |           |       |
|   LUT as Shift Register                    |  124 |     0 |            |           |       |
|     using O5 output only                   |    0 |       |            |           |       |
|     using O6 output only                   |   89 |       |            |           |       |
|     using O5 and O6                        |   35 |       |            |           |       |
| Slice Registers                            | 3218 |     0 |          0 |    437200 |  0.74 |
|   Register driven from within the Slice    | 1216 |       |            |           |       |
|   Register driven from outside the Slice   | 2002 |       |            |           |       |
|     LUT in front of the register is unused | 1450 |       |            |           |       |
|     LUT in front of the register is used   |  552 |       |            |           |       |
| Unique Control Sets                        |  254 |       |          0 |     54650 |  0.46 |
+--------------------------------------------+------+-------+------------+-----------+-------+
* * Note: Available Control Sets calculated as Slice * 1, Review the Control Sets Report for more information regarding control sets.


3. Memory
---------

+-------------------+------+-------+------------+-----------+-------+
|     Site Type     | Used | Fixed | Prohibited | Available | Util% |
+-------------------+------+-------+------------+-----------+-------+
| Block RAM Tile    |  1.5 |     0 |          0 |       545 |  0.28 |
|   RAMB36/FIFO*    |    1 |     0 |          0 |       545 |  0.18 |
|     RAMB36E1 only |    1 |       |            |           |       |
|   RAMB18          |    1 |     0 |          0 |      1090 |  0.09 |
|     RAMB18E1 only |    1 |       |            |           |       |
+-------------------+------+-------+------------+-----------+-------+
* Note: Each Block RAM Tile only has one FIFO logic available and therefore can accommodate only one FIFO36E1 or one FIFO18E1. However, if a FIFO18E1 occupies a Block RAM Tile, that tile can still accommodate a RAMB18E1


4. DSP
------

+-----------+------+-------+------------+-----------+-------+
| Site Type | Used | Fixed | Prohibited | Available | Util% |
+-----------+------+-------+------------+-----------+-------+
| DSPs      |    0 |     0 |          0 |       900 |  0.00 |
+-----------+------+-------+------------+-----------+-------+


5. IO and GT Specific
---------------------

+-----------------------------+------+-------+------------+-----------+--------+
|          Site Type          | Used | Fixed | Prohibited | Available |  Util% |
+-----------------------------+------+-------+------------+-----------+--------+
| Bonded IOB                  |    8 |     8 |          0 |       362 |   2.21 |
|   IOB Master Pads           |    4 |       |            |           |        |
|   IOB Slave Pads            |    4 |       |            |           |        |
| Bonded IPADs                |    0 |     0 |          0 |        50 |   0.00 |
| Bonded OPADs                |    0 |     0 |          0 |        32 |   0.00 |
| Bonded IOPADs               |  130 |   130 |          0 |       130 | 100.00 |
| PHY_CONTROL                 |    0 |     0 |          0 |         8 |   0.00 |
| PHASER_REF                  |    0 |     0 |          0 |         8 |   0.00 |
| OUT_FIFO                    |    0 |     0 |          0 |        32 |   0.00 |
| IN_FIFO                     |    0 |     0 |          0 |        32 |   0.00 |
| IDELAYCTRL                  |    0 |     0 |          0 |         8 |   0.00 |
| IBUFDS                      |    0 |     0 |          0 |       348 |   0.00 |
| GTXE2_COMMON                |    0 |     0 |          0 |         4 |   0.00 |
| GTXE2_CHANNEL               |    0 |     0 |          0 |        16 |   0.00 |
| PHASER_OUT/PHASER_OUT_PHY   |    0 |     0 |          0 |        32 |   0.00 |
| PHASER_IN/PHASER_IN_PHY     |    0 |     0 |          0 |        32 |   0.00 |
| IDELAYE2/IDELAYE2_FINEDELAY |    0 |     0 |          0 |       400 |   0.00 |
| ODELAYE2/ODELAYE2_FINEDELAY |    0 |     0 |          0 |       150 |   0.00 |
| IBUFDS_GTE2                 |    0 |     0 |          0 |         8 |   0.00 |
| ILOGIC                      |    0 |     0 |          0 |       362 |   0.00 |
| OLOGIC                      |    0 |     0 |          0 |       362 |   0.00 |
+-----------------------------+------+-------+------------+-----------+--------+


6. Clocking
-----------

+------------+------+-------+------------+-----------+-------+
|  Site Type | Used | Fixed | Prohibited | Available | Util% |
+------------+------+-------+------------+-----------+-------+
| BUFGCTRL   |    1 |     0 |          0 |        32 |  3.13 |
| BUFIO      |    0 |     0 |          0 |        32 |  0.00 |
| MMCME2_ADV |    0 |     0 |          0 |         8 |  0.00 |
| PLLE2_ADV  |    0 |     0 |          0 |         8 |  0.00 |
| BUFMRCE    |    0 |     0 |          0 |        16 |  0.00 |
| BUFHCE     |    0 |     0 |          0 |       168 |  0.00 |
| BUFR       |    0 |     0 |          0 |        32 |  0.00 |
+------------+------+-------+------------+-----------+-------+


7. Specific Feature
-------------------

+-------------+------+-------+------------+-----------+-------+
|  Site Type  | Used | Fixed | Prohibited | Available | Util% |
+-------------+------+-------+------------+-----------+-------+
| BSCANE2     |    0 |     0 |          0 |         4 |  0.00 |
| CAPTUREE2   |    0 |     0 |          0 |         1 |  0.00 |
| DNA_PORT    |    0 |     0 |          0 |         1 |  0.00 |
| EFUSE_USR   |    0 |     0 |          0 |         1 |  0.00 |
| FRAME_ECCE2 |    0 |     0 |          0 |         1 |  0.00 |
| ICAPE2      |    0 |     0 |          0 |         2 |  0.00 |
| PCIE_2_1    |    0 |     0 |          0 |         1 |  0.00 |
| STARTUPE2   |    0 |     0 |          0 |         1 |  0.00 |
| XADC        |    0 |     0 |          0 |         1 |  0.00 |
+-------------+------+-------+------------+-----------+-------+


8. Primitives
-------------

+----------+------+----------------------+
| Ref Name | Used |  Functional Category |
+----------+------+----------------------+
| FDRE     | 2031 |         Flop & Latch |
| LDCE     | 1032 |         Flop & Latch |
| LUT6     |  961 |                  LUT |
| LUT3     |  478 |                  LUT |
| LUT4     |  400 |                  LUT |
| LUT5     |  390 |                  LUT |
| LUT2     |  248 |                  LUT |
| BIBUF    |  130 |                   IO |
| MUXF7    |  104 |                MuxFx |
| SRL16E   |   92 |   Distributed Memory |
| FDSE     |   85 |         Flop & Latch |
| SRLC32E  |   67 |   Distributed Memory |
| CARRY4   |   67 |           CarryLogic |
| FDCE     |   59 |         Flop & Latch |
| MUXF8    |   52 |                MuxFx |
| LUT1     |   47 |                  LUT |
| FDPE     |   11 |         Flop & Latch |
| IBUF     |    5 |                   IO |
| OBUFT    |    4 |                   IO |
| OBUF     |    3 |                   IO |
| RAMD32   |    2 |   Distributed Memory |
| RAMB36E1 |    1 |         Block Memory |
| RAMB18E1 |    1 |         Block Memory |
| PS7      |    1 | Specialized Resource |
| BUFG     |    1 |                Clock |
+----------+------+----------------------+


9. Black Boxes
--------------

+----------+------+
| Ref Name | Used |
+----------+------+


10. Instantiated Netlists
-------------------------

+---------------------------------+------+
|             Ref Name            | Used |
+---------------------------------+------+
| design_1_xbar_0                 |    1 |
| design_1_rst_ps7_0_50M_0        |    1 |
| design_1_processing_system7_0_0 |    1 |
| design_1_axi_iic_0_0            |    1 |
| design_1_axi_dma_0_0            |    1 |
| design_1_auto_us_0              |    1 |
| design_1_auto_pc_1              |    1 |
| design_1_auto_pc_0              |    1 |
| design_1_KX134_V103_AXIS_0_0    |    1 |
+---------------------------------+------+



DMA VS FIFO FIFO Depth 130072

960 set data 31,3 KiB (32.021 bytes) 7,4 GiB space in SD card

in pic folder dmavsfifo and textfile .png