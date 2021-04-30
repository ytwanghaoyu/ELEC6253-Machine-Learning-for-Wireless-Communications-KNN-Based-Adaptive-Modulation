%% Start
clear all
close all
clc

%% Generate Data
SNR=1:1:40;                 %Range of SNR in dB
N=2^20;                  %Number of bits to simulate
thresholds = 5*10^-3;       %Define the thresholds
M1=2;                       %BPSK
M2=4;                       %QPSK
M3=16;                      %16QAM
x1=randi([0,M1-1],1,N);     %Produce the random signal
x2=randi([0,M2-1],1,N);
x3=randi([0,M3-1],1,N);
R=raylrnd(0.5,1,N);         %Produce the Rayleigh signal
BER_SNR_THROUGHPUT=[];

%% Modulation and go throuth Rayleigh channel
h1=pskmod(x1,M1);            %BPSK Modulation
h2=pskmod(x2,M2);            %QPSK Modulation
h3=qammod(x3,M3);            %16QAM Modulation
H1=h1.*R;                   %BPSK with Rayleigh Channel
H2=h2.*R;                   %QPSK with Rayleigh Channel
H3=h3.*R;                   %16QAM with Rayleigh Channel

%% Adaptive Demodulation
for SNR=1:1:40
    if SNR <=17                       %Choose Modulation method
       continue;                     %Don't transmit data
    end
    if SNR>17 && SNR<=21
        yREn1=R.\awgn(H1,SNR,'measured');
        yRE1=pskdemod(yREn1,M1);     
        [bit_RE1,ratio]=biterr(x1,yRE1);
        ADAP_MOD(SNR)=ratio;
    elseif SNR>21 && SNR<=26
        yREn2=R.\awgn(H2,SNR,'measured');
        yRE2=pskdemod(yREn2,M2);     
        [bit_RE2,ratio]=biterr(x2,yRE2);
%         if ratio > thresholds
%             yREn1=R.\awgn(H1,SNR,'measured');
%             yRE1=pskdemod(yREn1,M1);     
%             [bit_RE1,ratio]=biterr(x1,yRE1);
%             KNN_BER(SNR)=ratio;
%             continue
%         end
        ADAP_MOD(SNR)=ratio;
    elseif SNR>26
        yREn3=R.\awgn(H3,SNR,'measured');
        yRE3=qamdemod(yREn3,M3);     
        [bit_RE3,ratio]=biterr(x3,yRE3);
%         if ratio > thresholds
%             yREn2=R.\awgn(H2,SNR,'measured');
%             yRE2=pskdemod(yREn2,M2);     
%             [bit_RE2,ratio]=biterr(x2,yRE2);
%             KNN_BER(SNR)=ratio;
%             continue
%         end
        ADAP_MOD(SNR)=ratio;
    end
end

%% Old way-AWGN and Demodulation
for SNR=1:1:40

    yREn1=R.\awgn(H1,SNR,'measured');
    yRE1=pskdemod(yREn1,M1);     
    [bit_RE1,ratio1]=biterr(x1,yRE1);
    BPSK_Ray_Equalize(SNR)=ratio1;
    
    yREn2=R.\awgn(H2,SNR,'measured');
    yRE2=pskdemod(yREn2,M2);     
    [bit_RE2,ratio2]=biterr(x2,yRE2);
    QPSK_Ray_Equalize(SNR)=ratio2;
    
    yREn3=R.\awgn(H3,SNR,'measured');
    yRE3=qamdemod(yREn3,M3);     
    [bit_RE3,ratio3]=biterr(x3,yRE3);
    QAM_Ray_Equalize(SNR)=ratio3;
    
end

%% Plot figure
SNR=1:1:40; 
figure(1)
semilogy(SNR,BPSK_Ray_Equalize,':rx');hold on;
semilogy(SNR,QPSK_Ray_Equalize,':gx');
semilogy(SNR,QAM_Ray_Equalize,':bx');
semilogy(SNR,ADAP_MOD,':ko');
grid on;
axis([1 40 10^-5 1.2]);
line([0 40],[thresholds thresholds],'Color','red','LineStyle','--')
legend('BPSK Ray Equalize','QPSK Ray Equalize','16QAM Ray Equalize','Adaptive Modulation');
title('Adaptive Modulation BER vs SNR in Ray Equalized');
xlabel('SNR（dB）');ylabel('BER');

%% Throughput
NOData=0*ones(16,1);
BPSKData = 2*ones(21-16,1);
QPSKKData = 4*ones(26-21,1);
QAMData = 16*ones(40-26,1);
BER_SNR_THROUGHPUT = [NOData;BPSKData;QPSKKData;QAMData]

%% Plot
figure(2)
plot(SNR,BER_SNR_THROUGHPUT)
axis([0 40 0 20]);
legend('Throughput');
title('Throughput vs SNR in Adaptive Modulation');
xlabel('SNR（dB）');ylabel('Throughput');