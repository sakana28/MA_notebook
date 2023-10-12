import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d

def bearing_signal_model_dist(d, D, contact_angle, n, fault_type, fc, fd, fm, fr, N, fs, SNR_dB, q_fault, q_stiffness, q_rotation):
    """
    Generation of a simulated signal for distributed fault in rolling element bearing.

    Inputs:
        d (float): bearing roller diameter [mm]
        D (float): pitch circle diameter [mm]
        contact_angle (float): contact angle [rad]
        n (int): number of rolling elements
        fault_type (str): fault type selection: 'inner', 'outer', 'ball'
        fc (float): row vector containing the carrier component of the speed
        fd (float): row vector containing the frequency deviation
        fm (float): row vector containing the modulation frequency
        fr (list): rotation frequency profile
        N (int): number of points per revolution
        fs (float): sampling frequency [Hz]
        SNR_dB (float): signal to noise ratio [dB]
        q_fault (float): amplitude modulation at the fault frequency
        q_stiffness (float): amplitude value of the deterministic component related to the stiffness variation
        q_rotation (float): amplitude value of the deterministic component related to the bearing rotation

    Returns:
        tuple: (t, x, x_noise, fr_time)
            t (numpy.ndarray): time signal [s]
            x (numpy.ndarray): simulated bearing signal without noise
            x_noise (numpy.ndarray): simulated bearing signal with noise
            fr_time (numpy.ndarray): speed profile in the time domain [Hz]
    """

    if fault_type == 'inner':
        geometry_parameter = 1 / 2 * (1 + d / D * np.cos(contact_angle))
    elif fault_type == 'outer':
        geometry_parameter = 1 / 2 * (1 - d / D * np.cos(contact_angle))
    elif fault_type == 'ball':
        geometry_parameter = 1 / (2 * n) * (1 - (d / D * np.cos(contact_angle)) ** 2) / (d / D)
    

    Ltheta = len(fr)
    theta = np.arange(0, Ltheta) * 2 * np.pi / N
    theta_time = np.zeros(len(fr))

    for index in range(1, len(fr)):
        theta_time[index] = theta_time[index - 1] + (2 * np.pi / N) / (2 * np.pi * fr[index])

    L = int(np.floor(theta_time[-1] * fs))
    t = np.arange(0, L) / fs

    fr_time = interp1d(theta_time, fr, kind='cubic',fill_value="extrapolate")(t)
    #generating rotation frequency component
    x_rotation = q_rotation * np.cos(fc / fc * theta + fd / fc * (np.cumsum(np.cos(fm / fc * theta) / N)))
    x_rotation_time = interp1d(theta_time, x_rotation, kind='cubic',fill_value="extrapolate")(t)
    #generating stiffness variation  
    tau_stiffness = n / 2 * (1 - d / D * np.cos(contact_angle))
    x_stiffness = q_stiffness * np.cos(fc / fc * tau_stiffness * theta + fd / fc * tau_stiffness * (np.cumsum(np.cos(fm / fc * tau_stiffness * theta) / N)))
    x_stiffness_time = interp1d(theta_time, x_stiffness, kind='cubic',fill_value="extrapolate")(t)
    #amplitude modulation
    tau_fault = n * geometry_parameter
    q = 1 + q_fault * np.sin(fc / fc * tau_fault * theta + fd / fc * geometry_parameter * (np.cumsum(np.cos(fm / fc * geometry_parameter * theta) / N)))
    q_time = interp1d(theta_time, q, kind='cubic',fill_value="extrapolate")(t)
    x_fault_time = np.random.randn(1, L)
    x_fault_time = x_fault_time * q_time

    x = x_fault_time + x_stiffness_time + x_rotation_time

    SNR = 10 ** (SNR_dB / 10)
    Esym = np.sum(np.abs(x) ** 2) / L
    N0 = Esym / SNR
    noise_sigma = np.sqrt(N0)
    nt = noise_sigma * np.random.randn(1, L)
    x_noise = x + nt

    return t, x, x_noise, fr_time

# Example usage: TBD
d = 21.4
D = 203
contact_angle = 9*np.pi/180
n = 23
fault_type = 'inner'

# Speed profile
N = 2048
Ltheta = 10000 * N  
theta = np.arange(Ltheta) * 2 * np.pi / N
fc = np.array([10])
fd = 0.08 * fc
fm = 0.1 * fc
fr = fc + 2 * np.pi * fd * (np.cumsum(np.cos(fm * theta))/N)

fs = 20000
SNR_dB = 0
q_fault = 1
q_stiffness = 0.1
q_rotation = 0.1

t, x, x_noise, fr_time = bearing_signal_model_dist(d, D, contact_angle, n, fault_type, fc, fd, fm, fr, N, fs, SNR_dB, q_fault, q_stiffness, q_rotation)

fig, (no_noise,noise) = plt.subplots(2, 1, figsize=(13, 10))
no_noise.plot(t, x[0])
no_noise.set_xlim(0,0.5)
no_noise.set_xticks(np.arange(0, 0.51, 0.05))
no_noise.set_ylim(-11,11)
no_noise.set_yticks(np.arange(-10, 11, 2))
no_noise.set_xlabel('time')
no_noise.set_ylabel('amplitude')
no_noise.set_title('without noise')

noise.plot(t, x_noise[0])
noise.set_xlim(0,0.5)
noise.set_xticks(np.arange(0, 0.51, 0.05))
noise.set_ylim(-11,11)
noise.set_yticks(np.arange(-10, 11, 2))
noise.set_xlabel('time')
noise.set_ylabel('amplitude')
noise.set_title('with noise')

plt.show()