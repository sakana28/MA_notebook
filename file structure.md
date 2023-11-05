#writing 
![[sw_structure.drawio.png]]
The main program of the application relies  on the following header files:
- ff.h: Includes all the FAT file system APIs.
- xparameters.h: Contains hardware parameters such as interrupt IDs and address maps, as well as peripheral configurations for the system. This file is generated from the Vivado hardware platform.
- SDoperation.h: Contains custom functions related to SD card read/write operations.
- stdio.h: C standard library. Used here for standard input/output.
- xscugic.h: Includes drivers for the ARM Generic Interrupt Controller under Standalone OS.

