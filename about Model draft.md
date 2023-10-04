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

本章首先介绍了周期非平稳信号的概念，以及基于这一概念的滚珠轴承的振动信号模型。这一模型的数值实现是后续工作的基础。然后，本章提供了Zynq Soc结构以及本论文中使用的ZC706开发板的overview。

周期非平稳信号，即其均值和自相关函数是周期函数的stochastic process。在早期的建模工作中，滚动轴承的振动信号常常被建模为自相关函数与时间无关的平稳信号。然而，rolling elements 的the random slips are non-stationary in their nature. Antoni and Randall首次将vibration produced by localized faults建模为周期非平稳信号（antoni2003），为故障诊断提供了基础。

（antoni2003）（Anton Facts and fictions） 中提出了两个重要的模型方程，分别表示滚动轴承中局部故障和分布式故障的振动信号。方程（1）建模了vibration signal of a localized fault in a rolling element bearing：

其中的重要参数包括：
- h(t)：由传感器测得的单次冲击的脉冲响应。
- q(t)：考虑了由于负载分布、轴承不平衡、错位以及随着故障移动而发生的周期调制等因素而引起的周期调制。
- T：连续冲击之间的间隔时间。
- ⌧i：考虑了第i次冲击的间隔时间（抖动）由于滚动元件的随机滑动而存在的不确定性。
- n(t)：表示背景噪声。

方程（3）建模了vibration signal of a distrubuted fault in a rolling element bearing：
而其中的两项分别对应了：
- p(t)：捕捉了周期性成分，如轴和刚度变化的周期性。
- B(t)：代表了纯粹的周期非平稳内容，其期望值为E{B(t)} = 0。

（Step-by-step）提出了数值实现这两个模型的算法以及根据该算法的Octave script code。图片（）和（）分别表示了获取局部与分布故障产生的振动信号的模拟信号的流程：


根据这一算法可以获得不同工况下滚动轴承的振动信号。用户可以调整rolling bearing的几何尺寸，fault的位置，the stage of the fault， cyclostationarity of the signal, random contributions等features。




