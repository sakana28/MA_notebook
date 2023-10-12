import matplotlib.pyplot as plt
import numpy as np

# Read data from the file
with open('3x.txt', 'r') as file:
    data = file.readlines()

data = [float(i) for i in data]

# FFT
fs =12800.0
T = 1.0 / fs
x_time = np.linspace(0.0, 10000*T, 10000, endpoint=False)
fft_result = np.fft.fft(data)
fft_magnitude =np.abs(fft_result)
freq_axis = np.linspace(0, fs, len(fft_magnitude))

# Plot the data
fig, (ori_data,fft_data) = plt.subplots(2, 1,figsize=(10,6))
ori_data.plot(x_time ,data)
ori_data.set_title('Plot from txt file data')
ori_data.set_ylim(-240,240)
ori_data.set_xlabel('Index')
ori_data.set_ylabel('Acceleration(m/s2))')

fft_data.plot(freq_axis,fft_magnitude)
fft_data.set_title('FFT result')
fft_data.set_xlabel('Frequency (Hz)')
fft_data.set_ylabel('Magnitude')

plt.show()
