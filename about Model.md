#writing #fundamental 

本文详细介绍了一种模拟故障轴承预期振动信号的算法。该模型基于Antoni的工作[11]，并进行了一些改进。用户可以设置的基本特性如下： • 选择故障位置（例如外圈、内圈等）， • 选择故障阶段（例如点状故障、分布式故障等）， • 信号的周期性， • 随机成分， • 确定性成分， • 机器中的谐振效应， • 工作条件（静态和非静态）。

该项目已在Creative Commons许可下开发，并且该项目的愿景是由条件监测研究人员社区接受的一组工具，用于初步验证新诊断技术。读者可以自由并立即使用附录A中的脚本来模拟不同的故障和不同的工作条件。该脚本适用于开源的Octave环境。本文充分详细介绍了振动模型的理论背景和数字实现。展示并评论了模拟故障轴承（局部故障和广义故障）的输出信号示例。

The vibration signal of a localized fault in a rolling element bearing can be reasonably modelled as 
![[Pasted image 20230927204944.png]]