#writing #fundamental 
Cyclostationary signals are stochastic processes with periodic time-varying mean and autocorrelation functions. Earlier modeling works of vibration signals of rolling bearings often assumedto be stationary processes with autocorrelations independent of time, which neglected the inherently non-stationary nature of random slips of the rolling elements.(‘‘Differential Diagnosis of Gear and Bearing Faults,’’ Antoni, J., and Randall). Antoni and Randall (2003) first modeled vibrations produced by localized faults as cyclostationary processes, providing a basis for fault diagnosis.

Building on the initial work of Antoni and Randall (2003), two important model equations have been proposed (Antoni, Facts and fictions, 2006) representing the vibration signals from localized and distributed faults in rolling element bearings. Equation (1) models the vibration signal from a localized fault in a bearing:

Equation (1) contains several important parameters, including:
![[Pasted image 20231005065439.png]]

h(t): the impulse response of a single impact measured by the sensor
q(t): the periodic modulation due to factors like load distribution, bearing imbalance, misalignment, and periodicity of fault movement
T: the interval between successive impacts
τi: the inter-arrival time of the ith impact, accounting for randomness due to rolling element slips
n(t): the background noise

Equation (2) models the vibration signal from a distributed fault in a bearing:
![[Pasted image 20231005065448.png]]

The two terms in the equation are: p(t): the periodic components like shaft and stiffness variations
B(t): the pure cyclostationary content with E{B(t)} = 0


Based on these models, algorithms and Octave script code for numerical implementation of simulated vibration signals have been proposed in the work of G. D'Elia.  (Step-by-step) Figure ( ) demonstrates the procedure for generating vibration signals from localized faults, while Figure ( ) depicts the same process for distributed faults, according to the proposed algorithms.

The algorithm enables users to freely generate simulated vibration signals from rolling element bearings with different defects and under different operating conditions. Users are able to modify various features, such as bearing geometry, fault location, stage of the fault, cyclostationarity of the signal, and random contributions.
