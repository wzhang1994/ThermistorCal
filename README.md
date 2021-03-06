# <p align="center">ThermistorCal</p>
高精密热敏电阻温度计校准软件/Calibration Software for High Accuracy and Resolution Thermistor Thermometer

# 1 系统功能简介与安装/卸载

## 1.1 软件功能简介
高精密热敏电阻温度计校准软件ThermistorCal，是为了准确标定电阻温度计（包括铂电阻和NTC电阻等）在中-低温（温度范围在-10℃-60℃）的拟合系数，可对标定函数分析绘图，并可利用标定文件计算温度，软件功能主要包括电阻-温度数据导入、电阻类型的判断、标定结果图形显示与查看、标定文件的生成和温度的解算等功能。

## 1.2 运行环境
要运行软件程序，需要在安装有MATLAB Runtime(Version 9.2) 的Windows 操作系统下才能实现全部功能。进一步的系统要求在MATLAB手册或官网中可找到。

## 1.3 技术特点
本软件用于准确标定电阻温度计拟合系数，功能主要包括标定文件的生成、温度的解算，并可查看标定结果。

# 2. 软件应用程序的说明

## 2.1 TherCal.exe 程序使用说明
程序功能：
	可根据准确测定的电阻温度计的电阻值、温度数据，再结合前人的标定格式进行标定，该程序可以自动判断温度计的类型，程序的结果可生成标定结果文本及图像，同时生成供下个程序调用的标定文件。


运行步骤及注意事项：<br>
1、先将本文件夹TherCal.exe可执行文件拷贝到需要标定的数据文件所在文件夹中，标定的数据文件格式如下（第一列为电阻/Ω，第二列为准确测量后的温度/℃）：<br>
961.1616165	-9.98752381<br>
980.7514747	-4.999<br>
1000.305346	-0.011722222<br>
1019.83393	4.9765<br>
1039.334168	9.966363636<br>
1058.799935	14.9574<br>
1078.236799	19.94944444<br>
1097.648081	24.942<br>
1117.032598	29.93617647<br>
1136.389342	34.93216667<br>

2、准备好TherCal.txt参数设置文件，该设置文件的格式和内容如下：

\#74.dat   /原始数据文件名，即某一温度计标定温度后获取的原始数据文件

3、直接运行TherCal.exe，可得到电阻温度计标定后的数据文件*_cal.txt、*_cal.mat和相应的标定图像以及残差分布图*_cal.bmp、*_cal.fig；

4、标定文件的结果查看

![图1 1854632C.dat标定结果图](./examples/1854631C/1854631C_cal.bmp)
<p align="center">图1 1854632C.dat标定结果图</p>


## 2.2 TempByCal.exe 程序使用说明
程序功能：
	根据上个程序生成的标定文件来准确计算电阻温度计的测量温度

运行步骤及注意事项：<br>
1、先将本文件夹TempByCal.exe可执行文件拷贝到需要计算温度的数据文件所在文件夹中，需要计算的数据文件格式如下（第一列为测量得到的电阻/Ω）：<br>
30792.911<br>
30794.155<br>
30796.641<br>
30799.128<br>
30800.371<br>
30802.858<br>
30804.101<br>
30807.831<br>
30809.075<br>
30810.318<br>
30812.805<br>
30815.292<br>
30816.536<br>
30819.023<br>
30820.267<br>
30822.755<br>
30822.755<br>
30826.486<br>

2、准备好TempByCal.txt参数设置文件，该文件的格式和内容如下（第一行是原始数据文件名，第二行是上个程序生成的*_cal.mat的文件名）：<br>
1854632C.dat <br>
\#74_cal.mat	<br>

3、直接运行TempByCal.exe，可得到温度计通过标定文件计算后的的温度数据文件*_TempByCal.txt
