#writing #fundamental 

11.10.23 first change in draft  

Cyclostationary signals are non-stationary signals with periodic time-varying mean and autocorrelation functions, for example, a random noise that is amplitude modulated by a periodic function. 这一概念在分析轴承故障信号时意义重大，因为Cyclostationary表明存在故障的迹象，这是由于旋转表面上的故障会导致重复的撞击。
#### 振动模型
在早期的工作中，PRODUCED BY A SINGLE POINT DEFECT 的VIBRATION 被建模如下：
![[Pasted image 20231019223859.png]]
- h(t): the impulse response of a single impact measured by the sensor
- q(t): the modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement. It is periodic, i.e q(t)=q(t+T).
- T: the interval between successive impacts
- n(t): the background noise

Earlier modeling works of vibration signals of rolling bearings often assumed to be stationary processes with autocorrelations independent of time, which neglected the inherently non-stationary nature of random slips of the rolling elements. (‘‘Differential Diagnosis of Gear and Bearing Faults,’’ Antoni, J., and Randall). *Antoni and Randall (2003) modeled vibrations produced by localized faults as cyclostationary processes, providing a basis for fault diagnosis. *![[Pasted image 20231011052234.png]]

*Building on the initial work of Antoni and Randall (2003), two important model equations have been proposed (Antoni, Facts and fictions, 2006) representing the vibration signals from localized and distributed faults in rolling element bearings.* Equation (1) models the vibration signal from a localized fault in a bearing:

Equation (1) contains several important parameters, including:
![[Pasted image 20231005065439.png]]

- τi: the inter-arrival time of the ith impact, accounting for randomness due to rolling element slips

Equation (2) models the vibration signal from a distributed fault in a bearing:
![[Pasted image 20231005065448.png]]

The two terms in the equation are: 
- p(t): the periodic components like shaft and stiffness variations
- B(t): the pure cyclostationary component, which means cyclostationary component with an expected value of 0. [Estimation of Cyclic Cumulants of Machinery Vibration Signals in Non-stationary Operation]

Based on these models, algorithms and Octave script code for numerical implementation of simulated vibration signals have been proposed in the work of G. D'Elia.  (Step-by-step) Figure ( ) demonstrates the procedure for generating vibration signals from localized faults, while Figure ( ) depicts the same process for distributed faults, according to the proposed algorithms.
![[Pasted image 20231005065627.png]]

![[Pasted image 20231005065536.png]]
The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.
