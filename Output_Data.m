%% Start
clc
close all
clear

%% Initialize
SNR=1:1:40;                 %Range of SNR in dB
%SNR1=0.5*(10.^(SNR/10));    %Convert SNR into rectangular coordinates
%we decrease the N here in order to get a bigger data range
N=2^12;                  %Number of bits to simulate
thresholds = 5*10^-3;       %Define the thresholds
max_iter=10;                %Define the maximum iteration
M1=2;                       %BPSK
M2=4;                       %QPSK
M3=16;                      %16QAM
Data_BPSK=[];
Data_QPSK=[];
Data_16QAM=[];
Output_Data_BPSK_BER=[];
Output_Data_BPSK_SNR=[];
Output_Data_BPSK=[];
Output_Data_QPSK_BER=[];
Output_Data_QPSK_SNR=[];
Output_Data_QPSK=[];
Output_Data_16QAM_BER=[];
Output_Data_16QAM_SNR=[];
Output_Data_16QAM=[];
Output_Data_BER_SNR=[];
Output_Data_Class=[];

%% Generate Data
for iter=1:1:max_iter
    
    if iter<=7
        R=raylrnd(0.5,1,N);         %Produce the Rayleigh signal
    else
        R=raylrnd(0.8,1,N);         %Produce another Rayleigh signal
    end
    
    x1=randi([0,M1-1],1,N);     %Produce the random signal
    x2=randi([0,M2-1],1,N);
    x3=randi([0,M3-1],1,N);
    h1=pskmod(x1,M1);            %BPSK Modulation
    h2=pskmod(x2,M2);            %QPSK Modulation
    h3=qammod(x3,M3);            %16QAM Modulation
    H1=h1.*R;                   %BPSK with Rayleigh Channel
    H2=h2.*R;                   %QPSK with Rayleigh Channel
    H3=h3.*R;                   %16QAM with Rayleigh Channel

    for i=1:length(SNR)

        yREn1=R.\awgn(H1,SNR(i),'measured');
        yRE1=pskdemod(yREn1,M1);     
        [bit_RE1,ratio1]=biterr(x1,yRE1);
        BPSK_Ray_Equalize(i)=ratio1;

        yREn2=R.\awgn(H2,SNR(i),'measured');
        yRE2=pskdemod(yREn2,M2);     
        [bit_RE2,ratio2]=biterr(x2,yRE2);
        QPSK_Ray_Equalize(i)=ratio2;

        yREn3=R.\awgn(H3,SNR(i),'measured');
        yRE3=qamdemod(yREn3,M3);     
        [bit_RE3,ratio3]=biterr(x3,yRE3);
        QAM_Ray_Equalize(i)=ratio3;

    end
    Data_BPSK=[BPSK_Ray_Equalize;Data_BPSK];
    Data_QPSK=[QPSK_Ray_Equalize;Data_QPSK];
    Data_16QAM=[QAM_Ray_Equalize;Data_16QAM];

end

%% Plot
figure(1)
semilogy(SNR,Data_BPSK,'ro');hold on;grid on; %BPSK
% semilogy(SNR,Data_BPSK(2,:),'ro');
% semilogy(SNR,Data_BPSK(3,:),'ro');
% semilogy(SNR,Data_BPSK(4,:),'ro');
% semilogy(SNR,Data_BPSK(5,:),'ro');
% semilogy(SNR,Data_BPSK(6,:),'ro');
% semilogy(SNR,Data_BPSK(7,:),'ro');
% semilogy(SNR,Data_BPSK(8,:),'ro');
% semilogy(SNR,Data_BPSK(9,:),'ro');
% semilogy(SNR,Data_BPSK(10,:),'ro');

semilogy(SNR,Data_QPSK(1,:),'go');%QPSK
semilogy(SNR,Data_QPSK(2,:),'go');
semilogy(SNR,Data_QPSK(3,:),'go');
semilogy(SNR,Data_QPSK(4,:),'go');
semilogy(SNR,Data_QPSK(5,:),'go');
semilogy(SNR,Data_QPSK(6,:),'go');
semilogy(SNR,Data_QPSK(7,:),'go');
semilogy(SNR,Data_QPSK(8,:),'go');
semilogy(SNR,Data_QPSK(9,:),'go');
semilogy(SNR,Data_QPSK(10,:),'go');

semilogy(SNR,Data_16QAM(1,:),'bo');%16QAM
semilogy(SNR,Data_16QAM(2,:),'bo');
semilogy(SNR,Data_16QAM(3,:),'bo');
semilogy(SNR,Data_16QAM(4,:),'bo');
semilogy(SNR,Data_16QAM(5,:),'bo');
semilogy(SNR,Data_16QAM(6,:),'bo');
semilogy(SNR,Data_16QAM(7,:),'bo');
semilogy(SNR,Data_16QAM(8,:),'bo');
semilogy(SNR,Data_16QAM(9,:),'bo');
semilogy(SNR,Data_16QAM(10,:),'bo');

line([0 40],[thresholds thresholds],'Color','red','LineStyle','--')
hold off;

%% Reshape data and output it
for i=1:40
    Output_Data_BPSK_BER=[Output_Data_BPSK_BER;Data_BPSK(:,i)];
    Output_Data_BPSK_SNR=[Output_Data_BPSK_SNR;i.*ones(10,1)];
    Output_Data_QPSK_BER=[Output_Data_QPSK_BER;Data_QPSK(:,i)];
    Output_Data_QPSK_SNR=[Output_Data_QPSK_SNR;i.*ones(10,1)];
    Output_Data_16QAM_BER=[Output_Data_16QAM_BER;Data_16QAM(:,i)];
    Output_Data_16QAM_SNR=[Output_Data_16QAM_SNR;i.*ones(10,1)];
end
%Output it in BER,SNR ~ CLASS style
Output_Data_BPSK=[Output_Data_BPSK_BER,Output_Data_BPSK_SNR];
Output_Data_QPSK=[Output_Data_QPSK_BER,Output_Data_QPSK_SNR];
Output_Data_16QAM=[Output_Data_16QAM_BER,Output_Data_16QAM_SNR];
Output_Data_BER_SNR=[Output_Data_BPSK;Output_Data_QPSK;Output_Data_16QAM];
Output_Data_Class=[repmat({'BPSK'},400,1);repmat({'QPSK'},400,1);repmat({'16QAM'},400,1)]

save('OutputData.mat','Output_Data_BER_SNR','Output_Data_Class')


