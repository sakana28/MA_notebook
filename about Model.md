#writing #fundamental 

11.10.23 first change in draft  
#### Cyclostationary
Cyclostationary signals are non-stationary signals with periodic time-varying mean and autocorrelation. An example of a cyclostationary signal is random noise that is amplitude modulated by a periodic function. This concept is important in the analysis of bearing fault signals, as cyclostationarity indicates the presence of a fault. This is because defects on a rotating surface produce repetitive impacts, causing the statistical properties of the resulting vibration signal to be periodic. While the slips between the bearing elements add randomness, the overall periodic pattern of impulses persists, rendering the signal pseudocyclostationary. This enables the use of cyclostationary analysis methods for diagnosing bearing defects. ("Differential Diagnosis")
#### 振动模型
When a rotating surface contacts a localized fault, it generates an impulse that excites the structural resonances of the bearing or the vibration sensor itself. The repetitive impulses lead to a sequence of responses that are amplitude modulated due to the various structural modes of the system. Based on this understanding, in early work, the vibration produced by a single point defect was modeled as follows: (P.D. McFadden, J.D. Smith, Model for the vibration produced by a single point defect in a rolling element bearing)
![[Pasted image 20231019223859.png]]
- h(t): the impulse response of a single impact measured by the sensor
- q(t): the modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement. It is periodic, i.e q(t)=q(t+T).
- T: the interval between successive impacts
- n(t): the background noise
This model explains the non-stationarity of the vibration signal by amplitude modulation due to different factors (differential diagnosis). The interval T between impacts is determined by both the type of fault and the bearing geometry. To calculate this period, Table 1 shows typical fault frequencies (P.D. McFadden, J.D. Smith, Model for the vibration produced by a single point defect in a rolling element bearing). 

However, the model neglected the random slips of the rolling elements. It wrongly assumed that the impact intervals were identical. In fact, even small random fluctuations would disrupt the harmonic structure of the above model. Therefore, based on earlier work, Antoni proposed a more realistic model (Antoni, Facts and fictions, 2006):

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

Local fault 的振动信号模型数值实现有以下可由用户定义的参数：
- Speed profile
- rolling bearing的几何参数: bearing roller diameter , pitch circle diameter , contact angle, number of rolling elements 
- fault出现的位置：inner, outer or ball 
- 有关信号离散化的参数 : number of points per revolution与sample frequency of the time vector
- variance for the generation of the random contribution
- SDOF系统的stiffness， damping coefficient， natural frequency，length of the SDOF response
- signal to noise ratio (SNR) of background noise
- amplitude modulation due to the load

![[Pasted image 20231005065627.png]]
Distributed fault 的振动信号模型数值实现则额外需要以下参数：
- amplitude modulation at the fault frequency
- amplitude value of the deterministic component related to the stiffness variation
- amplitude value of the deterministic component related to the bearing rotation

![[Pasted image 20231005065536.png]]
The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.

In this work, operations like quadratic interpolation and generating random numbers from specified distributions are required to produce the desired signals. These operations are difficult to implement on an FPGA. Moreover, there is no need in subsequent work to dynamically configure the generated signals during system operation. Therefore, instead of generating the signals directly on the FPGA, a software-hardware codesign approach is taken. The stimulus signals are first generated in Python. The samples are stored as text files, which are then read by the Zynq PS through the SD card interface. The stored samples serve as the signal source for the signal generator implemented in programmable logic. Thus, the waveform generation and storage is separated from the real-time playback on the FPGA. Users can modify signal generation relevanted parameters in Python while the hardware interface remains unchanged. New stimuli files can be deployed by simply copying them to the SD card. 