%% Start
clear all
close all
clc

%% Load and process data
load('OutputData.mat')
thresholds = 5*10^-3;       %Define the thresholds
index=find(Output_Data_BER_SNR(:,1)<=thresholds)
Require_Train_Data=Output_Data_BER_SNR(index,:)
Require_Train_Class=Output_Data_Class(index)

%% Train Data and make predictions on different SNR
KNNC = fitcknn(Require_Train_Data,Require_Train_Class,'NumNeighbors',20,'Standardize',1)
New_Sample=[]
%SNR under 17 won't meet the thresholds requirement
for Pred_SNR=1:1:40
    %Make predictions raw data set
    %Decrease the BER here to ensure meet the thresholds requirement
    New_Sample = [New_Sample;thresholds Pred_SNR];
end
%Get predictions
[label,score,cost] = predict(KNNC,New_Sample)

%% Generate Data
SNR=17:1:40;                 %Range of SNR in dB
N=2^20;                  %Number of bits to simulate
thresholds = 5*10^-3;       %Define the thresholds
M1=2;                       %BPSK
M2=4;                       %QPSK
M3=16;                      %16QAM
x1=randi([0,M1-1],1,N);     %Produce the random signal
x2=randi([0,M2-1],1,N);
x3=randi([0,M3-1],1,N);
R=raylrnd(0.5,1,N);         %Produce the Rayleigh signal

%% Modulation and go throuth Rayleigh channel
h1=pskmod(x1,M1);            %BPSK Modulation
h2=pskmod(x2,M2);            %QPSK Modulation
h3=qammod(x3,M3);            %16QAM Modulation
H1=h1.*R;                   %BPSK with Rayleigh Channel
H2=h2.*R;                   %QPSK with Rayleigh Channel
H3=h3.*R;                   %16QAM with Rayleigh Channel

%% KNN-AWGN and Demodulation
for SNR=17:1:40
    mod=label{SNR}
    if strcmp(mod,'BPSK')
        yREn1=R.\awgn(H1,SNR,'measured');
        yRE1=pskdemod(yREn1,M1);     
        [bit_RE1,ratio]=biterr(x1,yRE1);
        KNN_BER(SNR-16)=ratio;
    elseif strcmp(mod,'QPSK')
        yREn2=R.\awgn(H2,SNR,'measured');
        yRE2=pskdemod(yREn2,M2);     
        [bit_RE2,ratio]=biterr(x2,yRE2);
        if ratio > thresholds
            yREn1=R.\awgn(H1,SNR,'measured');
            yRE1=pskdemod(yREn1,M1);     
            [bit_RE1,ratio]=biterr(x1,yRE1);
            KNN_BER(SNR-16)=ratio;
            continue
        end
        KNN_BER(SNR-16)=ratio;
    elseif strcmp(mod,'16QAM')
        yREn3=R.\awgn(H3,SNR,'measured');
        yRE3=qamdemod(yREn3,M3);     
        [bit_RE3,ratio]=biterr(x3,yRE3);
        if ratio > thresholds
            yREn2=R.\awgn(H2,SNR,'measured');
            yRE2=pskdemod(yREn2,M2);     
            [bit_RE2,ratio]=biterr(x2,yRE2);
            KNN_BER(SNR-16)=ratio;
            continue
        end
        KNN_BER(SNR-16)=ratio;
    end
end

%% Old way-AWGN and Demodulation
for SNR=17:1:40

    yREn1=R.\awgn(H1,SNR,'measured');
    yRE1=pskdemod(yREn1,M1);     
    [bit_RE1,ratio1]=biterr(x1,yRE1);
    BPSK_Ray_Equalize(SNR-16)=ratio1;
    
    yREn2=R.\awgn(H2,SNR,'measured');
    yRE2=pskdemod(yREn2,M2);     
    [bit_RE2,ratio2]=biterr(x2,yRE2);
    QPSK_Ray_Equalize(SNR-16)=ratio2;
    
    yREn3=R.\awgn(H3,SNR,'measured');
    yRE3=qamdemod(yREn3,M3);     
    [bit_RE3,ratio3]=biterr(x3,yRE3);
    QAM_Ray_Equalize(SNR-16)=ratio3;
    
end

%% Adaptive Demodulation
for SNR=17:1:40
    if SNR <=17                       %Choose Modulation method
       continue;                     %Don't transmit data
    end
    if SNR>17 && SNR<=21
        yREn1=R.\awgn(H1,SNR,'measured');
        yRE1=pskdemod(yREn1,M1);     
        [bit_RE1,ratio]=biterr(x1,yRE1);
        ADAP_MOD(SNR-16)=ratio;
    elseif SNR>21 && SNR<=25
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
        ADAP_MOD(SNR-16)=ratio;
    elseif SNR>25
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
        ADAP_MOD(SNR-16)=ratio;
    end
end

%% Plot figure
SNR=17:1:40; 
semilogy(SNR,BPSK_Ray_Equalize,':rx');hold on;
semilogy(SNR,QPSK_Ray_Equalize,':gx');
semilogy(SNR,QAM_Ray_Equalize,':bx');
semilogy(SNR,KNN_BER,':ko'); %hold on;
semilogy(SNR,ADAP_MOD,':m*');

grid on;
axis([15 40 10^-5 1.2]);
line([0 40],[thresholds thresholds],'Color','red','LineStyle','--')
legend('BPSK Ray Equalize','QPSK Ray Equalize','16QAM Ray Equalize','KNN','Adaptive');
title('KNN method BER vs SNR in Ray Equalized');
xlabel('SNR（dB）');ylabel('BER');


