ich freue mich, Ihnen heute meine Masterarbeit zum Thema "Implementation and Optimization of an FPGA based Signal Generator for Fault Bearing in Non-Stationary Conditions" vorzustellen.

Zuerst möchte ich auf die Motivation dieses Projekts eingehen, also warum braucht man so einen Signalgenerator. Wälzlager sind eine wichtige mechanische Komponente. Durch die Analyse der Vibrationssignale von laufenden Wälzlagern kann man potenzielle Defekte frühzeitig erkennen. Bei der Entwicklung eines Echtzeit-Vibrationsanalysators zur Defekterkennung muss dessen Funktionen validiert werden. Ein typischer Prüfaufbau dafür ist in der Folie dargestellt. Mit einer FPGA-basierten Emulationsplattform lässt sich der Entwicklungsprozess vereinfachen, da die Validierung einfacher am Schreibtisch und ohne Prüfaufbau möglich ist.

Die Emulationsplattform muss folgende Anforderungen erfüllen: Sie muss in der Lage sein, sich bei der Kommunikation mit dem Analysator wie ein Beschleunigungssensor zu verhalten. Sie muss erfasste oder simulierte Vibrationen im gleichen Datenformat ausgeben wie ein Beschleunigungssensor.

dieser Vortrag wird in folgender Reihenfolge ablaufen: 

Zunächst werde auf die gestellten Aufgaben eingehen. Danach möchte ich  die Simulation der Vibrationssignale vorstellen. Anschließend  erläutere ich die Hardware sowie software Implementierung der Plattform. Dannach zeige ich  die Evaluierung des Gesamtsystems anhand mehrere Experimente. Die Präsentation schließt mit einer Zusammenfassung des Projekts.

Der erste Schritt war die Implementierung eines Algorithmus zur Erzeugung der Vibrationssignale in Python. Danach erfolgte die Entwicklung des Emulators auf einem Zynq System-on-Chip für die Signalübertragung im Format des Beschleunigungssensors.  Weil Zynq einen Dual-Core ARM-Prozessor mit  FPGA kombiniert, umfasst die Implementierung auf dem Zynq sowohl FPGA-basierte Hardware-Designs als auch eingebettet-C-Software auf dem ARM

Die Python-Implementierung basiert auf dem Algorithmus aus dem hier zitierten Artikel. Sie besteht aus zwei Teilprogrammen, welche Vibrationssignale für Lager mit lokale Punktdefekt bzw. verteilten Defekt erzeugen.

Die Abbildung zeigt ein Wälzlager mit einem Punktdefekt. Bei jeder Umdrehung des Lagers kommt es an der Stelle des Defekts zu einem Stoß. Die Zeitabstände zwischen aufeinanderfolgenden Stößen werden zufällig beeinflusst, aufgrund des Gleitens der Wälzkörper im Lager.  Ein wichtiger Teil des Algorithmus ist die Erzeugung einer Impulsfolge, die diesen Zufallsanteil berücksichtigt. Diese Impulsfolge dient dann als Eingangssignal für die Berechnung der Systemantwort. 

Die dargestellte Abbildung zeigt ein Wälzlager mit auf der Lauffläche verteilten Defekten. Im Gegensatz zum Punktdefekt entsteht hier kein Stossimpuls. Vielmehr entsteht durch die zufälligen Positionen der Wälzkörper auf der geschädigten Oberfläche bei der Drehung ein moduliertes Zufallssignal.  Beide vorgestellten Teilprogramme  sind in der Lage, je nach Bedarf sowohl rauschfreie als auch rauschbehaftete Signale zu erzeugen.  


Neben den bereits erwähnten Parametern Schadenstyp und Rauschstärke bietet die Implementierung weiterer Einstellmöglichkeit. Dadurch kann der Entwickler auf einfache Weise reproduzierbare Versuchsdaten erzeugen und die Parameter anpassen, ohne den Testaufbau jedes Mal neu einstellen zu müssen.

Schauen wir uns nun den zu emulierenden Beschleunigungssensor KX134 an. Über  I2C-Bus kann der Anwender Konfigurationsdaten in die Steuerregister schreiben und die Beschleunigungsdaten von bestimmten Adressen auslesen. Der Emulator imitiert das Verhalten des Sensors im Watermark-Interrupt-Modus.  Das heißt, die aufgenommenen Daten werden nicht sofort vom Host ausgelesen, sondern zuerst im Sample Buffer zwischengespeichert. Erreicht die Datenmenge einen benutzerdefinierten Schwellwert, löst der Sensor ein Interrupt-Signal aus, um den Host zum Auslesen aufzufordern.

Nun zur Implementierung auf Zynq. Als ersten Entwicklungsschritt habe ich einen Signalrekorder entworfen, der reale Beschleunigungsdaten aufzeichnen kann. Dazu verwende ich einen AXI-I2C IP-Core von Xilinx. Über diesen kann der Sensor KX134 konfiguriert und ausgelesen werden. Die I2C Schnittstelle sowie die Interrupt Pins habe ich auf die GPIO Header des ZC706 Entwicklungsboards gemappt. Ein Embedded Programm verarbeitet dann die über AXI-I2C empfangenen Daten und schreibt diese in eine Textdatei auf der SD-Karte.
