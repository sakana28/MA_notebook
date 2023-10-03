#writing #draft 
Cyclostationarity（*a random process with a periodic autocorrelation function.*（均值与自相关函数是t的周期函数 随机：均值和自相关是t的函数 平稳：均值与自相关和t无关）） encompasses a subclass of non-stationary signals which exhibit some cyclical behaviour. A typical example of a cyclostationary signal is a random noise that is amplitude modulated by a periodic function. A more versatile example is where different periodic modulations envelope each frequency component of the random noise. Cyclostationarity has been shown to ideally fit the property of many rotating and reciprocating machine vibrations, due to the inherent periodic modulations that these sustain during operation [5]. The recognition that a vibration signal is cyclostationary affords much more information than the usual and simplistic assumption of stationarity, since it provides the tools to simultaneously analyse the content of a signal (e.g. spectral content) along with the characterisation of how this content evolves periodically in time (e.g. within the machine cycle).

Cyclostationarity涵盖了一类表现出一定周期性行为的非平稳信号。一个典型的Cyclostationarity信号示例是由周期性函数调制的随机噪声。更多用途广泛的示例是不同周期性调制包络了随机噪声的每个频率分量。由于旋转和往复运动机器在运行过程中固有的周期性调制，Cyclostationarity已被证明非常适用于许多振动信号，这些信号通常包括机器周期内信号内容的同时分析工具（例如，频谱内容）以及如何定期随时间演变的特征（例如，在机器周期内）。与通常和简单的平稳性假设相比，认识到振动信号是Cyclostationary会提供更多信息。

Incipient faults in rolling-element bearings are usually the consequence of a local loss of material (pitting, spalling, corrosion, rubbing, contamination) on a matting surface (inner/outer race, rolling elements). When a rolling surface contacts the fault, this produces a short duration impulse which excites some structural resonance of the bearing or of the vibration transducer itself.3 The repetition of these impacts when the bearing is operating results in a series of impulse responses whose temporal spacing depends on the type of fault and on the geometry of the bearing. Table A.1 in the Appendix gives some typical fault frequencies, from which a diagnosis can be carried out. 

On top of that, the series of impulse responses produced by an incipient fault are possibly amplitude modulated due to the passing of the fault into and out of the load zone. Typically, for a stationary outer race and in the presence of a radial load, an outer race fault would experience an uniform amplitude modulation, an inner race a periodic amplitude modulation at the period of the inner race rotation, and a rolling-element fault a periodic amplitude modulation at the period of the cage rotation. Those modulation frequencies are also passing reported in Table A.1 of the Appendix—see e.g. Ref. [4] for a complete discussion on that topic. 

The above observations are well-known and have led in the past to the proposal of a simple harmonic4 model for the vibrations produced by single localised faults. Namely, let hðtÞ be the impulse response to a single impact as measured by the sensor, qðtÞ ¼ qðt þ PÞ the periodic modulation of period P due to the load distribution,5 T the inter-arrival time between two consecutive impacts on the fault; then the vibration signal xðtÞ was modelled as [14]:


起初，滚动轴承中的潜在故障通常是由于一侧的材料损失（如点蚀、剥落、腐蚀、摩擦、污染）而导致的，这些故障会发生在配合表面上（内圈/外圈、滚动体）。当滚动表面与故障接触时，会产生一个持续时间很短的冲击，激发了轴承或振动传感器本身的某种结构共振。当轴承运行时，这些冲击的重复会导致一系列脉冲响应，其时间间隔取决于故障的类型和轴承的几何形状。附录中的表A.1列出了一些典型的故障频率，可以用于诊断。

此外，潜在故障产生的一系列脉冲响应可能由于故障进入和离开负载区域而进行幅度调制。通常情况下，对于固定的外圈和径向负载存在的情况下，外圈故障将经历均匀的幅度调制，内圈将在内圈旋转周期内发生周期性的幅度调制，而滚动体故障则在保持架旋转周期内发生周期性的幅度调制。这些调制频率也在附录的表A.1中列出，可以参考文献[4]等进行详细讨论。

上述观察是众所周知的，并在过去提出了用于描述单一局部故障产生的振动的简单谐波模型。换句话说，假设h(t)是由传感器测量的单次冲击的脉冲响应，q(t) = q(t + P)是由于负载分布而产生的周期性调制，T是故障上连续两次冲击之间的间隔时间；然后，振动信号x(t)被建模为：


