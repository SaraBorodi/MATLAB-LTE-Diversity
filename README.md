# OFDM & MIMO (Alamouti) Simulation in MATLAB

This project simulates and compares the performance of OFDM communication systems in SISO and MIMO configurations using the Alamouti space-time coding scheme.

The main objective is to analyze Bit Error Rate (BER) performance over different SNR values in a multipath channel environment.

---

## Project Description

The simulation includes:
- OFDM modulation and demodulation (IFFT/FFT)
- QPSK modulation (4-QAM)
- Cyclic Prefix insertion/removal
- Multipath channel effects
- AWGN noise
- Channel equalization
- MIMO Alamouti space-time coding
- BER performance evaluation

Two systems are compared:
- **SISO OFDM system**
- **2x1 MIMO OFDM system with Alamouti coding**

---

## Technologies Used

- MATLAB
- Digital Communications Theory
- OFDM systems
- MIMO Alamouti coding

---

## System Parameters

- Number of subcarriers: 64  
- Cyclic Prefix: 16  
- Modulation: QPSK (M = 4)  
- Number of OFDM symbols: 1000  
- Channel: multipath FIR  
- Noise: AWGN  
- SNR range: 0 to 20 dB  

---

## SISO OFDM System

Steps:
- Bit generation
- QPSK modulation
- OFDM modulation using IFFT
- Adding cyclic prefix
- Passing through multipath channel
- Adding AWGN noise
- FFT at receiver
- Channel equalization
- QAM demodulation

Output:
- Constellation diagram
- BER vs SNR curve

---

## MIMO Alamouti OFDM System

Steps:
- QPSK modulation
- Alamouti space-time encoding
- OFDM modulation per transmit antenna
- Channel transmission with two independent paths
- AWGN noise addition
- FFT processing at receiver
- Alamouti decoding
- Symbol and bit recovery

Output:
- Constellation diagram
- BER comparison with SISO system

---

## Results

The simulation shows:
- MIMO Alamouti system achieves lower BER compared to SISO
- Performance improves significantly at higher SNR values
- Clear constellation diagrams for both systems

---

## Key Concepts Demonstrated

- OFDM transmission system design
- QPSK modulation/demodulation
- Channel equalization in frequency domain
- Multipath fading channels
- Space-Time Block Coding (Alamouti scheme)
- BER performance analysis

---

## Comparison

- SISO: simpler but higher BER
- MIMO Alamouti: improved reliability and robustness
- MIMO shows better performance in noisy environments

---

## Author

Sara Borodi
