clc;
clear;
close all;

%% PARAMETRI GENERALI

K = 64;
CP = 16;
numSymbols = 1000;
M = 4;
bitsPerSymbol = log2(M);

SNR_dB = 0:2:20;

numBits = numSymbols * K * bitsPerSymbol;

%% GENERARE BITI

bits = randi([0 1], numBits, 1);

%% MODULATIE QPSK

symbols = qammod(bits, M, ...
    'InputType','bit', ...
    'UnitAveragePower',true);

%% OFDM SISO

symbolsMatrix = reshape(symbols, K, []);

ofdmTime = ifft(symbolsMatrix, K);

cpPart = ofdmTime(end-CP+1:end,:);
ofdmTX = [cpPart; ofdmTime];

txSignal = ofdmTX(:);

%% CANAL (multipath FIR)

channelResponse = [1 0 0.3+0.3j];

BER_siso = zeros(size(SNR_dB));

%% =========================
% SISO OFDM 

for i = 1:length(SNR_dB)

    rxMatrix = zeros(K+CP, numSymbols);

    for k = 1:numSymbols
        idx = (k-1)*(K+CP)+1 : k*(K+CP);

        block = txSignal(idx);

        % canal aplicat PE FIECARE OFDM SYMBOL
        blockChan = conv(block, channelResponse);
        blockChan = blockChan(1:K+CP);

        rxMatrix(:,k) = blockChan;
    end

    rxMatrix = awgn(rxMatrix, SNR_dB(i), 'measured');

    rxNoCP = rxMatrix(CP+1:end,:);

    rxFreq = fft(rxNoCP, K);

    H = fft(channelResponse, K).';
    H_matrix = repmat(H,1,numSymbols);

    equalized = rxFreq ./ H_matrix;

    rxSymbols = equalized(:);

    rxBits = qamdemod(rxSymbols, M, ...
        'OutputType','bit', ...
        'UnitAveragePower',true);

    BER_siso(i) = sum(bits ~= rxBits) / numBits;
end

%% CONSTELATIE SISO

figure;
plot(real(rxSymbols(1:2000)), imag(rxSymbols(1:2000)), '.');
grid on;
title('Constelatie SISO OFDM');

%% BER SISO

figure;
semilogy(SNR_dB, BER_siso,'-o','LineWidth',2);
grid on;
title('SISO OFDM - BER');

%% =========================================================
%% MIMO ALAMOUTI OFDM 

BER_alamouti = zeros(size(SNR_dB));

for i = 1:length(SNR_dB)

    bits_mimo = bits;

    symbols_mimo = qammod(bits_mimo, M, ...
        'InputType','bit', ...
        'UnitAveragePower',true);

    s1 = symbols_mimo(1:2:end);
    s2 = symbols_mimo(2:2:end);

    x11 = s1;
    x21 = s2;

    x12 = -conj(s2);
    x22 = conj(s1);

    x11 = reshape(x11, K, []);
    x12 = reshape(x12, K, []);
    x21 = reshape(x21, K, []);
    x22 = reshape(x22, K, []);

    tx1_slot1 = ifft(x11, K);
    tx1_slot2 = ifft(x12, K);

    tx2_slot1 = ifft(x21, K);
    tx2_slot2 = ifft(x22, K);

    tx1_slot1 = [tx1_slot1(end-CP+1:end,:); tx1_slot1];
    tx1_slot2 = [tx1_slot2(end-CP+1:end,:); tx1_slot2];

    tx2_slot1 = [tx2_slot1(end-CP+1:end,:); tx2_slot1];
    tx2_slot2 = [tx2_slot2(end-CP+1:end,:); tx2_slot2];

    tx1_slot1 = tx1_slot1(:);
    tx1_slot2 = tx1_slot2(:);
    tx2_slot1 = tx2_slot1(:);
    tx2_slot2 = tx2_slot2(:);

    %% CANAL MIMO (FRECVENȚĂ FLAT)

    h1 = (randn + 1j*randn)/sqrt(2);
    h2 = (randn + 1j*randn)/sqrt(2);

    rx1 = h1*tx1_slot1 + h2*tx2_slot1;
    rx2 = h1*tx1_slot2 + h2*tx2_slot2;

    rx1 = awgn(rx1, SNR_dB(i), 'measured');
    rx2 = awgn(rx2, SNR_dB(i), 'measured');

    rx1 = reshape(rx1, K+CP, []);
    rx2 = reshape(rx2, K+CP, []);

    rx1 = rx1(CP+1:end,:);
    rx2 = rx2(CP+1:end,:);

    RX1 = fft(rx1, K);
    RX2 = fft(rx2, K);

    %% CANAL PE SUBPURTĂTOARE 

    H1 = fft(h1, K).';
    H2 = fft(h2, K).';

    H1 = repmat(H1,1,size(RX1,2));
    H2 = repmat(H2,1,size(RX1,2));

    s1_hat = conj(H1).*RX1 + H2.*conj(RX2);
    s2_hat = conj(H2).*RX1 - H1.*conj(RX2);

    denom = abs(H1).^2 + abs(H2).^2;

    s1_hat = s1_hat ./ denom;
    s2_hat = s2_hat ./ denom;

    s1_hat = s1_hat(:);
    s2_hat = s2_hat(:);

    rxSymbols_mimo = zeros(length(symbols_mimo),1);
    rxSymbols_mimo(1:2:end) = s1_hat;
    rxSymbols_mimo(2:2:end) = s2_hat;

    rxBits_mimo = qamdemod(rxSymbols_mimo, M, ...
        'OutputType','bit', ...
        'UnitAveragePower',true);

    BER_alamouti(i) = sum(bits_mimo ~= rxBits_mimo) / numBits;
end

%% COMPARATIV BER

figure;
semilogy(SNR_dB, BER_siso,'-o','LineWidth',2);
hold on;
semilogy(SNR_dB, BER_alamouti,'-s','LineWidth',2);
grid on;
legend('SISO','MIMO Alamouti');
title('BER Comparativ');

%% CONSTELAȚIE MIMO

figure;
plot(real(rxSymbols_mimo(1:2000)), imag(rxSymbols_mimo(1:2000)), '.');
grid on;
title('Constelatie MIMO Alamouti');