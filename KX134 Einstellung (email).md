für den Sensor soll eine Samplerate von 25,6 kHz Samplerate pro Channel (x,y,z) eingestellt werden. 
Die Auflösung soll auf 32 g gestellt werden. 
Auslesen kannst du das wie es dir und vom Timing her besser passt: Entweder immer ein Messwert auslesen, wenn der Trigger auslöst (dann müsstest du auch den Triggerport verbinden) oder du nutzt die FIFO und liest in bestimmten Zeitintervallen aus. Wie es dir lieber ist.

Wenn es möglich ist, sollte die Samplerate und die Beschleunigungsgenauigkeit (g) einstellbar sein, ist aber erst mal kein muss.
