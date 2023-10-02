#writing #fundamental 


This section describes the rolling bearing vibration signal models of interest in this paper, along with their numerical implementations. 

本文详细介绍了一种模拟故障轴承预期振动信号的算法。用户可以设置的基本特性如下： • 选择故障位置（例如外圈、内圈等）， • 选择故障阶段（例如点状故障、分布式故障等）， • 信号的周期性， • 随机成分， • 确定性成分， • 机器中的谐振效应， • 工作条件（静态和非静态）。


The vibration signal of a localized fault in a rolling element bearing can be modelled as :
  
![[Pasted image 20230927204944.png]]

*where h(t) is the impulse response to a single impact as measured by the sensor, q(t) takes into account the periodic modulation due to the load distribution, possible bearing unbalance or misalignment, as well as the periodic changes in the impulse response as the fault moves towards and backwards the sensor, T is the inter-arrival time between two consecutive impacts, {taoi} accounts for the uncertainties on the inter-arrival time (jitters) of the ith impact due to the necessary random slip of the rolling elements and n(t) gathers the background noise.*

In this expression, h(t) is the impulse response to a single impact, as measured by the sensor. The term q(t) accounts for the cyclic modulation and the periodic changes in the impulse response. T is the inter-arrival time between successive impacts, and {τi​} accounts for the uncertainties in the inter-arrival times (jitters) of the ith impact. Lastly, n(t) is the background noise component within the signal. [step by step]

And the vibration signal of a distributed fault can be modelled as: 
![[Pasted image 20230928085715.png]]
where p(t) accounts for the periodic component such as shaft and stiffness variation periodicities and B(t) for the purely cyclostationary content with E{B(t)} = 0. [step by step]


Cyclostationarity encompasses a subclass of non-stationary signals which exhibit some cyclical behaviour. A typical example of a cyclostationary signal is a random noise that is amplitude modulated by a periodic function. A more versatile example is where different periodic modulations envelope each frequency component of the random noise. Cyclostationarity has been shown to ideally fit the property of many rotating and reciprocating machine vibrations, due to the inherent periodic modulations that these sustain during operation [5]. The recognition that a vibration signal is cyclostationary affords much more information than the usual and simplistic assumption of stationarity, since it provides the tools to simultaneously analyse the content of a signal (e.g. spectral content) along with the characterisation of how this content evolves periodically in time (e.g. within the machine cycle).

[[what is non-stationary]]