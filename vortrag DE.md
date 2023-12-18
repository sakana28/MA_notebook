ich freue mich, Ihnen heute meine Masterarbeit zum Thema "Implementation and Optimization of an FPGA based Signal Generator for Fault Bearing in Non-Stationary Conditions" vorzustellen.

Zuerst möchte ich auf die Motivation dieses Projekts eingehen, also warum braucht man so einen Signalgenerator. Wälzlager sind eine wichtige mechanische Komponente. Durch die Analyse der Vibrationssignale von laufenden Wälzlagern kann man potenzielle Defekte frühzeitig erkennen. Bei der Entwicklung eines Echtzeit-Vibrationsanalysators zur Defekterkennung muss dessen Funktionen validiert werden. Ein typischer Prüfaufbau dafür ist in der Folie dargestellt. Mit einer FPGA-basierten Emulationsplattform lässt sich der Entwicklungsprozess vereinfachen, da die Validierung einfacher am Schreibtisch und ohne Prüfaufbau möglich ist.

Die Emulationsplattform muss folgende Anforderungen erfüllen: Sie muss in der Lage sein, sich bei der Kommunikation mit dem Analysator wie ein Beschleunigungssensor zu verhalten. Sie muss erfasste oder simulierte Vibrationen im gleichen Datenformat ausgeben wie ein Beschleunigungssensor.

dieser Vortrag wird in folgender Reihenfolge ablaufen: 

Zunächst werde auf die gestellten Aufgaben eingehen. Danach möchte ich  die Simulation der Vibrationssignale vorstellen. Anschließend  erläutere ich die Hardware sowie software Implementierung der Plattform. Dannach zeige ich  die Evaluierung des Gesamtsystems anhand mehrere Experimente. Die Präsentation schließt mit einer Zusammenfassung des Projekts.

Der erste Schritt war die Implementierung eines Algorithmus zur Erzeugung der Vibrationssignale in Python. Danach erfolgte die Entwicklung des Emulators auf einem Zynq System-on-Chip für die Signalübertragung im Format des Beschleunigungssensors. 
