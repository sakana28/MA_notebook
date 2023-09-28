#writing #fundamental 


This section describes the rolling bearing vibration signal models of interest in this paper, along with their numerical implementations. 

本文详细介绍了一种模拟故障轴承预期振动信号的算法。用户可以设置的基本特性如下： • 选择故障位置（例如外圈、内圈等）， • 选择故障阶段（例如点状故障、分布式故障等）， • 信号的周期性， • 随机成分， • 确定性成分， • 机器中的谐振效应， • 工作条件（静态和非静态）。


The vibration signal of a localized fault in a rolling element bearing can be  modelled as :
  
![[Pasted image 20230927204944.png]]

*where h(t) is the impulse response to a single impact as measured by the sensor, q(t) takes into account the periodic modulation due to the load distribution, possible bearing unbalance or misalignment, as well as the periodic changes in the impulse response as the fault moves towards and backwards the sensor, T is the inter-arrival time between two consecutive impacts, {taoi} accounts for the uncertainties on the inter-arrival time (jitters) of the ith impact due to the necessary random slip of the rolling elements and n(t) gathers the background noise.*

In this expression, h(t) is the impulse response to a single impact, as measured by the sensor. The term q(t) accounts for the cyclic modulation and the periodic changes in the impulse response. T is the inter-arrival time between successive impacts, and {τi​} accounts for the uncertainties in the inter-arrival times (jitters) of the ith impact. Lastly, n(t) is the background noise component within the signal. [step by step]

