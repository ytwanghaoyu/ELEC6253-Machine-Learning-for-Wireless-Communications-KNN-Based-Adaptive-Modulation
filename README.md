# KNN-Based-Adaptive-Modulation

**Main Idea: Use KNN and thresholds to implement an adaptive modulation system.**

**主要思想:利用KNN或者SNR阈值来制作两个自适应的调制系统.**

In this project, I implement four .m files. Let me explain the tasks and functions of these functions one by one in the logical order of implementing the entire system.

## 1.BERvsSNR.m
In this file, we can have a clear understanding of the BER of the nine different modulation methods under different SNRs. These nine methods can be split into three * three. Thery are BPSK QPSK 16QAM used in White Gaussian Noise Channel, White Gaussian Noise with Rayleigh Fading Channel, White Gaussian Noise with Rayleigh  Fading Channel after Equalize.
Note that the initial N value is relatively large and can be adjusted by yourself.
在这个文件中,我们可以对九种不同调制方式在不同SNR下的BER情况有一个清楚的认知. 这九种方式可以拆分成三成三. BPSK QPSK 16QAM 在 White Gaussian Noise, White Gaussian Noise with Rayleigh, White Gaussian Noise with Rayleigh after Equalize.
注意,初始的N值比较大,可以自行调整.

## 2.Adaptive_Modulation.m
In this file, we set an acceptable maximum BER value. With this value as the limit, we find the lowest SNR that can meet the requirements under different modulation methods. And set an adaptive modulation system based on this SNR value.
在这个文件中,我们设定了一个可以接受的最高BER值.并以这个值为界限,分别找到不同调制方式下可以满足要求的最低SNR. 并根据此SNR值设定一个自适应调制系统.

## 3.Output_Data.m
Here we output the data points that will be used to train the KNN classifier. A larger dynamic range is obtained by reducing the value of N. At the same time, the Rayleigh channel parameters are modified to obtain more possible points. Then the data is rearranged to BER SNR / CLASS is output as a .mat file
输出将用于训练KNN分类器的数据点. 通过降低N的值获得更大的动态范围. 同时修改Rayleigh信道参数来获取更多可能的点. 之后对数据进行重新排列, 以BER SNR / CLASS 的方式输出为.mat文件

## 4.KNN.m
Filter the data, discard the points that do not meet the BER requirements, train the KNN classifier, and predict different SNRs. Use the predicted results to select different modulation methods. Increase the BER control. When the required BER value is exceeded, change Use a lower level of modulation. Output comparison figure.
对数据进行筛选,抛去不符合BER要求的点, 训练KNN分类器,并对不同的SNR进行预测. 使用预测的结果选择不同的调制方式. 增加BER控制,对于超过要求BER值的时候,改用较低一级的调制方式. 输出对比图.
