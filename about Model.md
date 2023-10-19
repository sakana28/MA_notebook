#writing #fundamental 

11.10.23 first change in draft  
#### Cyclostationary
Cyclostationary signals are non-stationary signals with periodic time-varying mean and autocorrelation functions, for example, a random noise that is amplitude modulated by a periodic function. 这一概念在分析轴承故障信号时意义重大，因为Cyclostationary表明存在故障的迹象，这是由于旋转表面上的故障会导致重复的撞击。尽管vibration signals from localized faults are not exactly quasi-cyclostationary since the random slips are non-stationary in their nature （‘Differential Diagnosis）. However they concluded that the bearing signals could still be treated as pseudocyclostationary as a first approximation.
#### 振动模型
当转动的表面接触到局部故障时，会产生一个impulse并激发轴承或振动传感器本身的结构谐振。重复的impulse则会导致的一系列响应。该响应会由于系统的各种结构被amplitude modulated。基于上述理解，在早期的工作中，PRODUCED BY A SINGLE POINT DEFECT 的VIBRATION 被建模如下：
![[Pasted image 20231019223859.png]]
- h(t): the impulse response of a single impact measured by the sensor
- q(t): the modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement. It is periodic, i.e q(t)=q(t+T).
- T: the interval between successive impacts
- n(t): the background noise
这个模型通过多种因素导致的amplitude modulation阐明了振动信号的non-stationarity。（Differential Diagnosis）。而撞击发生的时间间隔T取决于故障的类型和轴承的几何形状。表格1展示了Typical fault frequencies，由此可以计算出该时间间隔。 （P.D. McFadden, J.D. Smith, Model for the vibration produced by a single point defect in a rolling element bearing）

然而，这个模型 neglected the random slips of the rolling elements. 因此它错误地假设了撞击发生的间隔时间是相同的。而微小的随机波动也会破坏上述模型的谐波结构。因此，Antoni基于早前多个工作提出了一种更加realistic的模型：（Antoni, Facts and fictions, 2006）


![[Pasted image 20231005065439.png]]

- τi: the inter-arrival time of the ith impact, accounting for randomness due to rolling element slips
其余的参数与（1）中含义相同。

而当缺陷spread over a large area后，产生的振动信号不再是由impulses引起的，而时间的随机抖动也不再有意义。这与局部故障导致的pseudo-cyclostationary 振动信号不同, 引起了一个purely cyclostationary process。
在这种情况下，vibration signal from a distributed fault in a bearing被表示为:  （‘Differential Diagnosis）
![[Pasted image 20231005065448.png]]

The two terms in the equation are: 
- p(t): the periodic components like shaft and stiffness variations
- B(t): the pure cyclostationary random component with an expected value of 0. [Estimation of Cyclic Cumulants of Machinery Vibration Signals in Non-stationary Operation]
#### Numerical implementation
Based on these models, algorithms and Octave script code for numerical implementation of simulated vibration signals have been proposed in the work of G. D'Elia.  (Step-by-step) Figure ( ) demonstrates the procedure for generating vibration signals from localized faults, while Figure ( ) depicts the same process for distributed faults, according to the proposed algorithms.

根据Ho and Randall [6]，model the bearing fault vibrations as a series of impulse responses of a single-degree-of-freedom(SDOF)system, where the timing between the impulses has a random component simulating the slippery effect. 在该数值实现中采用了这一模型。

该数值实现有以下可由用户定义的参数：
- rolling bearing的几何参数: bearing roller diameter , pitch circle diameter , contact angle, number of rolling elements 
- fault出现的位置：inner, outer or ball 
- 有关信号离散化的参数 : number of points per revolution与sample frequency of the time vector
- variance for the generation of the random contribution
- SDOF系统的stiffness， damping coefficient， natural frequency
![[Pasted image 20231005065627.png]]

![[Pasted image 20231005065536.png]]
The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.
