%% Start
clc
close all
clear

%% Prepare and Define and Modulation
SNR=0:1:40;                 %Range of SNR in dB
%SNR1=0.5*(10.^(SNR/10));    %Convert SNR into rectangular coordinates
N=2^20;                  %Number of bits to simulate
thresholds = 5*10^-3;       %Define the thresholds
M1=2;                       %BPSK
M2=4;                       %QPSK
M3=16;                      %16QAM
x1=randi([0,M1-1],1,N);     %Produce the random signal
x2=randi([0,M2-1],1,N);
x3=randi([0,M3-1],1,N);
R=raylrnd(0.5,1,N);         %Produce the Rayleigh signal
%R_rice=sqrt(K/(K+1))+sqrt(1/(K+1))*R;     %Rice channel
h1=pskmod(x1,M1);            %BPSK Modulation
h2=pskmod(x2,M2);            %QPSK Modulation
h3=qammod(x3,M3);            %16QAM Modulation
H1=h1.*R;                   %BPSK with Rayleigh Channel
H2=h2.*R;                   %QPSK with Rayleigh Channel
H3=h3.*R;                   %16QAM with Rayleigh Channel

%% Demodulation
for i=1:length(SNR)
    yAn1=awgn(h1,SNR(i),'measured'); 
    yA1=pskdemod(yAn1,M1);     
    [number,ratio]=biterr(x1,yA1); 
    BPSK_AWGN(i)=ratio;
    
    yAn2=awgn(h2,SNR(i),'measured'); 
    yA2=pskdemod(yAn2,M2);     
    [bit_A2,~]=biterr(x2,yA2); 
    QPSK_AWGN(i)=bit_A2/N;
    
    yAn3=awgn(h3,SNR(i),'measured'); 
    yA3=qamdemod(yAn3,M3);     
    [bit_A3,~]=biterr(x3,yA3); 
    QAM_AWGN(i)=bit_A3/N;
    
    yRn1=awgn(H1,SNR(i),'measured');
    yR1=pskdemod(yRn1,M1);     
    [bit_R1,~]=biterr(x1,yR1);
    BPSK_Ray(i)=bit_R1/N; 
    
    yRn2=awgn(H2,SNR(i),'measured');
    yR2=pskdemod(yRn2,M2);     
    [bit_R2,~]=biterr(x2,yR2);
    QPSK_Ray(i)=bit_R2/N; 
    
    yRn3=awgn(H3,SNR(i),'measured');
    yR3=qamdemod(yRn3,M3);     
    [bit_R3,~]=biterr(x3,yR3);
    QAM_Ray(i)=bit_R3/N;
    
    yREn1=R.\yRn1
    yRE1=pskdemod(yREn1,M1);     
    [bit_RE1,ratio1]=biterr(x1,yRE1);
    BPSK_Ray_Equalize(i)=ratio1;
    
    yREn2=R.\yRn2
    yRE2=pskdemod(yREn2,M2);     
    [bit_RE2,ratio2]=biterr(x2,yRE2);
    QPSK_Ray_Equalize(i)=ratio2;
    
    yREn3=R.\yRn3
    yRE3=qamdemod(yREn3,M3);     
    [bit_RE3,ratio3]=biterr(x3,yRE3);
    QAM_Ray_Equalize(i)=ratio3;
    
end
% QPSK_ther_AWGN=1/2*erfc(sqrt(10.^(SNR/10)/2));   %AWGN信道下QPSK理论误码率
% QPSK_ther_Ray= -(1/4)*(1-sqrt(SNR1./(SNR1+1))).^2+(1-sqrt(SNR1./(SNR1+1)));%Rayleigh信道下QPSK理论误码率

%% Plot
figure(1)
semilogy(SNR,BPSK_AWGN,'ro');hold on;
semilogy(SNR,QPSK_AWGN,'go');
semilogy(SNR,QAM_AWGN,'bo');
semilogy(SNR,BPSK_Ray,':r*');
semilogy(SNR,QPSK_Ray,':g*'); 
semilogy(SNR,QAM_Ray,':b*'); 
grid on;
axis([-1 40 10^-5 1.2]);
line([0 40],[thresholds thresholds],'Color','red','LineStyle','--')
legend('BPSK-AWGN','QPSK-AWGN','16QAM-AWGN','BPSK-Rayleigh','QPSK-Rayleigh','16QAM-Rayleigh');
title('BER vs SNR in BPSK&QPSK&16QAM AWGN&Ray');
xlabel('SNR（dB）');ylabel('BER');

figure(2)
semilogy(SNR,BPSK_Ray_Equalize,':rx');hold on;
semilogy(SNR,QPSK_Ray_Equalize,':gx');
semilogy(SNR,QAM_Ray_Equalize,':bx');
grid on;
axis([-1 40 10^-5 1.2]);
line([0 40],[thresholds thresholds],'Color','red','LineStyle','--')
legend('BPSK Ray Equalize','QPSK Ray Equalize','16QAM Ray Equalize');
title('BER vs SNR in BPSK&QPSK&16QAM Ray Equalized');
xlabel('SNR（dB）');ylabel('BER');