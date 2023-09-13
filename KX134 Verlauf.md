#HW 
![[Pasted image 20230531155445.png]]


![[Pasted image 20230531161414.png]]
Asynchrones Auslesen 0XC0 11000000
Synchrones Auslesen mit Hardware Interrupt 0xE0 11100000
![[Pasted image 20230531161758.png]]

**??? KX134 nachmachen: 4 verschiedene Verhalten mit verschiedenen Konfigurationen?(Verschiedene Auflösung oder bestimmte Auflösung)**
	*Selbst entscheidung, mit asynchrone Auslesen anfang*

![[Pasted image 20230531163055.png]]

in Seminararbeit: asynchrone Auslesen

Daten: 2’s complement format

resolution of the samples data was set to 16-bit: the data is recorded in the following order:
X_L, X_H, Y_L, Y_H, Z_L and Z_H with the **oldest** data point read first as the buffer is in FIFO
mode

**asynchrone Auslesen: Mechanismus von Aktualisierung??** 
To reduce the duplicate sensor data, wait at least 1/ODR period before reading the next sample. **(?)**