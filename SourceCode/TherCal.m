function TherCal(varargin)             % 标定温度计拟合系数的主程序
%% 读取配置文件内容并导入数据
clear;                              % 清除工作空间的所有变量
close all;                          % 关闭所有的Figure窗口 
fid=fopen('TherCal.txt','r');       % 只读的方式打开配置文件TherCal.txt
filename=fgets(fid);                % 读取配置文件TherCal.txt内容
fclose(fid);                        % 关闭配置文件TherCal.txt

data = load(filename);              % 读取电阻-温度数据文件
Resistance = data(:,1);             % 数据文件的电阻值R，单位为 Ω
Temperature = data(:,2);            % 数据文件的温度T，单位 ℃


%% 判断温度计的类型
R = corrcoef(Resistance,Temperature);           % 计算电阻与温度的相关系数  
if (R(1,2)>0)                                   % Positive Temperature Coefficient 正相关系数
    PTC(Temperature,Resistance,filename)        % 进入PTC函数，并将数据文件的电阻值、温度和文件名传输入进去
end

if (R(1,2)<0)                                   % Negative Temperature Coefficient 负相关系数
    NTC(Temperature,Resistance,filename)        % 进入NTC函数，并将数据文件的电阻值、温度和文件名传输入进去
end

if (R(1,2)==0)                                  % 电阻与温度无关
    disp('电阻与温度无关，无法拟合')              % 对话框输出'电阻与温度无关，无法拟合'
    return                                      % 结束函数
end

disp(['Finished,please check the output file:  ',[filename(1:end-4) '_cal.txt']])  % 对话框输出输出文件名

end

function  PTC(Temperature,Resistance,filename)	% PTC函数
%% PTC型温度计进行标定
x = Resistance;                                 % x接收电阻值电阻值R，单位为 Ω
y = Temperature;                                % y接收温度T，单位 ℃
p = polyfit(x,y,1);                             % 基于最小二乘法曲线拟合原理对电阻和温度进行一次拟合
Function = @(x) p(1) * x + p(2);                % 构建PTC型温度计的拟合函数
y_calc = Function(x);                           % 标定后计算得到的温度，单位 ℃
R = corrcoef(y,y_calc);                         % 计算测量后的温度和标定后的温度之间相关系数
Dy = (y_calc - y) * 1000;                       % 计算残差，单位 mK
[n,~]=size(Dy);                                 % 残差的总个数
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;	% 计算标准差（Standard Deviation），单位 ℃
datenow=datestr(now,31);                        % 记录当前时间

%% 输出校准结果图像
figure                                          % 创建一个用来显示图形输出的窗口
set(gcf,'Position',[300 0 500 960 ]);           % 设置图像窗口在屏幕的位置、大小
whitebg([1 1 1])                                % 绘图区底色控制为白色
set(gcf,'color','w')                            % 窗口内部图形周围控制为白色
subplot 211                                     % 绘图窗口分成两行一列两块区域，下面在第一个绘图区绘图
plot(x,y,'*')                                   % 绘制电阻与测量得到的温度图像，标记符号为‘*’
hold on                                         % 保持图形不变，新画图像之后不覆盖原图
fplot(Function)                                 % 绘制Function函数曲线
axis([min(x) max(x) min(y) max(y)])             % 控制x轴和y轴的范围
grid on                                         % 绘制网格线
grid minor                                      % 绘制小的网格线
title('Results of Calibration','FontWeight','bold');    % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');    % 标注x轴内容
ylabel('Temperature/℃','FontWeight','bold');   % 标注y轴内容
legend('T\_ref','T\_calc','Location','northwest');      % 设置图例

subplot 212                                     % 绘图窗口分成两行一列两块区域，下面在第二个绘图区绘图
plot(x,Dy,'x')                                  % 绘制电阻与温度残差的图像，标记符号为‘x’
grid on                                         % 绘制网格线
grid minor                                      % 绘制小的网格线
title('Temperature residual','FontWeight','bold');    % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');    % 标注x轴内容
ylabel('Temperature residual/mK','FontWeight','bold');% 标注y轴内容
legend('T\_calc - T\_ref','Location','northwest');      % 设置图例

saveas(gca,[filename(1:end-4) '_cal.fig']);     % 保存图形*_cal.fig,便于后期更改
saveas(gcf,[filename(1:end-4) '_cal'],'bmp')    % 保存图形*_cal.bmp

%% 将校准结果输出至文本，便于查看校准结果
file_out = [filename(1:end-4) '_cal.txt'];           % 设置输出文件的名字
fid_T = fopen(file_out ,'w');                       % 以写入的方式打开输出文件
fprintf(fid_T,'Results of Calibration\r\n\r\n');    % 输出内容
fprintf(fid_T,'Calibration Date/time     :  %s\r\n',datenow);                               % 输出当前时间
fprintf(fid_T,'Resistance type           :  PTC (Positive Temperature Coefficient) \r\n');  % 输出内容
fprintf(fid_T,'Calibration function      :  T(℃) = k·R(Ω) + b \r\n');                        % 输出内容
fprintf(fid_T,'Fitting parameters(k b)   :  %12.10f   %12.10f \r\n',p);                     % 输出拟合参数

fprintf(fid_T,'Or\r\n');                            % 输出内容
fprintf(fid_T,'T&R relationship          :  R(Ω) = k''·T(℃) + b'' \r\n');                     % 输出内容
fprintf(fid_T,'Fitting parameters(k'' b'') :  %12.10f   %12.10f \r\n\r\n\r\n',1/p(1),-p(2)/p(1));   % 输出内容
fprintf(fid_T,'     Resistance/Ω       Measured/℃     Calculated/℃      Residual/mK\r\n');       % 输出内容
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x y y_calc Dy]');          % 电阻/Ω 测量温度/℃ 标定公式计算温度/℃ 温度残差/mK
fprintf(fid_T,'\r\n');                              % 输出内容
fprintf(fid_T,'Correlation coefficient   :  %12.10f \r\n',R(1,2));      % 输出相关系数
fprintf(fid_T,'Standard Deviation        :  %12.10f  ℃\r\n\r\n',Standard_Deviation);               % 输出标准差 单位 ℃
fclose(fid_T);                                      % 关闭输出文件

%% 将校准结果保存到*.mat(MATLAB的数据存储格式)，便于后续程序调用
file_matout = [filename(1:end-4) '_cal.mat'];           % 设置输出文件的名字
Result.filename = file_matout;                         % 将文件名输入至结构体Result
Result.type = 'PTC';                                % 将温度计类型输入至结构体Result
Result.Function = Function;                         % 将校准函数输入至结构体Result
Result.date = datenow;                              % 将校准时间输入至结构体Result
Result.parameters = p;                              % 将校准函数的校准参数输入至结构体Result
save(file_matout,'Result');          % 保存校准结果

end

function  NTC(Temperature,Resistance,filename)      % NTC函数
%% 输入电阻温度数据
x = Resistance;                                     % x接收电阻值电阻值R，单位为 Ω
y = Temperature + 273.15;                           % y接收温度T并转化单位，单位 K
[n,~] = size(x);                                    % 数据的总个数
datenow=datestr(now,31);                            % 记录当前时间

%% NTC型温度计进行标定 Steinhart and Hart(1968)
a11 = n;
a12 = sum(log(x));
a13 = sum((log(x)).^3);
a21 = a12;
a22 = sum((log(x)).^2);
a23 = sum((log(x)).^4);
a31 = a13;
a32 = a23;
a33 = sum((log(x)).^6);
b1 = sum(1./y);
b2 = sum(log(x)./y);
b3 = sum((((log(x)).^3)./y));
A = (a12*a23*b3 - a13*a22*b3 - a12*a33*b2 + a13*a32*b2 + a22*a33*b1 - a23*a32*b1)...        % 拟合参数A
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);
B = -(a11*a23*b3 - a13*a21*b3 - a11*a33*b2 + a13*a31*b2 + a21*a33*b1 - a23*a31*b1)...       % 拟合参数B
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);
C = (a11*a22*b3 - a12*a21*b3 - a11*a32*b2 + a12*a31*b2 + a21*a32*b1 - a22*a31*b1)...        % 拟合参数C
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);

Function_1968 = @(x) 1./(A + B * log(x) + C * (log(x).*log(x).*log(x))) - 273.15;           % 构建NTC型温度计的拟合函数 Steinhart and Hart(1968)
y_calc = Function_1968(x);                      % 标定后计算得到的温度，单位 ℃
R = corrcoef(Temperature,y_calc);               % 计算测量后的温度和标定后的温度之间相关系数
Dy = (y_calc - Temperature) * 1000;             % 计算残差，单位 mK
[n,~]=size(Dy);                                 % 残差的总个数
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;	% 计算标准差（Standard Deviation），单位 ℃


%% 输出校准结果图像 Steinhart and Hart(1968)
figure                                          % 创建一个用来显示图形输出的窗口
set(gcf,'Position',[300 0 500*2 960 ]);         % 设置图像窗口在屏幕的位置、大小
whitebg([1 1 1])                                % 绘图区底色控制为白色
set(gcf,'color','w')                            % 窗口内部图形周围控制为白色

subplot 221                                     % 绘图窗口分成两行两列两块区域，下面在第一个绘图区绘图
plot(x,Temperature,'*')                         % 绘制电阻与测量得到的温度图像，标记符号为‘*’
hold on                                         % 保持图形不变，新画图像之后不覆盖原图                   
fplot(Function_1968)                            % 绘制Function_1968函数曲线
axis([min(x) max(x) min(Temperature) max(Temperature)]) % 控制x轴和y轴的范围
grid on                                         % 绘制网格线
grid minor                                      % 绘制小的网格线
title('Results of Calibration by Steinhart and Hart(1968)','FontWeight','bold');    % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');    % 标注x轴内容
ylabel('Temperature/℃','FontWeight','bold');   % 标注y轴内容
legend('T\_ref','T\_calc','Location','northeast');      % 设置图例

subplot 223                                     % 绘图窗口分成两行两列两块区域，下面在第三个绘图区绘图
plot(x,Dy,'x')                                  % 绘制电阻与温度残差的图像，标记符号为‘x’
grid on                                         % 绘制网格线
grid minor                                      % 绘制小的网格线
title('Temperature residual','FontWeight','bold');    % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');    % 标注x轴内容
ylabel('Temperature residual/mK','FontWeight','bold');  % 标注y轴内容
legend('T\_calc - T\_ref','Location','northeast');      % 设置图例

%% 将校准结果输出至文本，便于查看校准结果 Steinhart and Hart(1968)
file_out = [filename(1:end-4) '_cal.txt'];           % 设置输出文件的名字
fid_T = fopen(file_out ,'w');                       % 以写入的方式打开输出文件
fprintf(fid_T,'Results of Calibration by Steinhart and Hart(1968)\r\n\r\n');    % 输出内容
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',datenow);                               % 输出当前时间
fprintf(fid_T,'Resistance type             :  NTC (Negative Temperature Coefficient) \r\n');  % 输出内容
fprintf(fid_T,'Calibration function        :  1/(T(K)) = A + B·lnR(Ω) + C·(lnR(Ω))^3 \r\n');   % 输出内容
fprintf(fid_T,'Fitting parameters(A B C)   :%18.10e %18.10e %18.10e \r\n\r\n',A,B,C);             % 输出内容

fprintf(fid_T,'     Resistance/Ω       Measured/℃     Calculated/℃      Residual/mK\r\n');      % 输出内容
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x Temperature y_calc Dy]');               % 电阻/Ω 测量温度/℃ 标定公式计算温度/℃ 温度残差/mK
fprintf(fid_T,'\r\n');                              % 输出内容
fprintf(fid_T,'Correlation coefficient     :%14.10f \r\n',R(1,2));      % 输出相关系数
fprintf(fid_T,'Standard Deviation          :%14.10f  ℃\r\n\r\n',Standard_Deviation);               % 输出标准差 单位 ℃
fprintf(fid_T,'\r\n\r\n');                          % 输出内容
fclose(fid_T);                                      % 关闭输出文件

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NTC型温度计进行标定 Hoge(1988)
AA = [n sum(log(x)) sum((log(x)).^2) sum((log(x)).^3)                   % 构建矩阵
    sum(log(x)) sum((log(x)).^2) sum((log(x)).^3) sum((log(x)).^4)
    sum((log(x)).^2) sum((log(x)).^3) sum((log(x)).^4) sum((log(x)).^5)
    sum((log(x)).^3) sum((log(x)).^4) sum((log(x)).^5) sum((log(x)).^6)];
BB = [sum(1./y)                                                         % 构建结果矩阵
    sum(log(x)./y)
    sum((((log(x)).^2)./y))
    sum((((log(x)).^3)./y))];
X = AA\BB;                                          % 拟合参数X
Function_1988  =@(x) 1./(X(1) + X(2) * log(x) + X(3) * (log(x).*log(x)) + X(4) * (log(x).*log(x).*log(x)))-273.15;    % 构建NTC型温度计的拟合函数 Hoge(1988)
y_calc = Function_1988(x);                          % 标定后计算得到的温度，单位 ℃
R = corrcoef(Temperature,y_calc);                   % 计算测量后的温度和标定后的温度之间相关系数
Dy = (y_calc - Temperature) * 1000;                 % 计算残差，单位 mK
[n,~]=size(Dy);                                     % 残差的总个数
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;       % 计算标准差（Standard Deviation），单位 ℃

%% 输出校准结果图像 Hoge(1988)
subplot 222                                         % 绘图窗口分成两行两列两块区域，下面在第二个绘图区绘图
plot(x,Temperature,'*')                             % 绘制电阻与测量得到的温度图像，标记符号为‘*’
hold on                                             % 保持图形不变，新画图像之后不覆盖原图
fplot(Function_1988)                                % 绘制Function_1988函数曲线
axis([min(x) max(x) min(Temperature) max(Temperature)])  % 控制x轴和y轴的范围
grid on                                             % 绘制网格线
grid minor                                          % 绘制小的网格线
title('Results of Calibration by Hoge(1988）','FontWeight','bold');    % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');        % 标注x轴内容
ylabel('Temperature/℃','FontWeight','bold');       % 标注y轴内容
legend('T\_ref','T\_calc','Location','northeast');  % 设置图例

subplot 224                                         % 绘图窗口分成两行两列两块区域，下面在第四个绘图区绘图
plot(x,Dy,'bx')                                     % 绘制电阻与温度残差的图像，标记符号为‘x’
grid on                                             % 绘制网格线
grid minor                                          % 绘制小的网格线
title('Temperature residual','FontWeight','bold');  % 添加图像标题
xlabel('Resistance/Ω','FontWeight','bold');        % 标注x轴内容
ylabel('Temperature residual/mK','FontWeight','bold');  % 标注y轴内容
legend('T\_calc - T\_ref','Location','northeast');  % 设置图例

saveas(gca,[filename(1:end-4) '_cal.fig']);     % 保存图形*_cal.fig,便于后期更改
saveas(gcf,[filename(1:end-4) '_cal'],'bmp')    % 保存图形*_cal.bmp

%% 将校准结果输出至文本，便于查看校准结果 Hoge(1988)
fid_T = fopen(file_out ,'at');                       % 设置输出文件的名字
fprintf(fid_T,'######################################################################\r\n');    % 输出内容
fprintf(fid_T,'Results of Calibration by Hoge(1988)\r\n\r\n'); % 输出内容
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',datenow);                         % 输出当前时间
fprintf(fid_T,'Resistance type             :  NTC (Negative Temperature Coefficient) \r\n');    % 输出内容
fprintf(fid_T,'Calibration function        :  1/(T(K)) = A + B·lnR(Ω) + C·(lnR(Ω))^2 + D·(lnR(Ω))^3 \r\n'); % 输出内容
fprintf(fid_T,'Fitting parameters(A B C D) :%18.10e %18.10e %18.10e %18.10e \r\n\r\n',X);           % 输出拟合参数
fprintf(fid_T,'     Resistance/Ω       Measured/℃     Calculated/℃      Residual/mK\r\n');       % 输出内容
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x Temperature y_calc Dy]');       % 电阻/Ω 测量温度/℃ 标定公式计算温度/℃ 温度残差/mK
fprintf(fid_T,'\r\n');                              % 输出内容
fprintf(fid_T,'Correlation coefficient     :%14.10f \r\n',R(1,2));      % 输出相关系数
fprintf(fid_T,'Standard Deviation          :%14.10f  ℃\r\n\r\n',Standard_Deviation);               % 输出标准差 单位 ℃
fprintf(fid_T,'\r\n\r\n\r\n');                      % 输出内容
fclose(fid_T);                                      % 关闭输出文件

%% 将两种方法的校准结果保存到*.mat(MATLAB的数据存储格式)，便于后续程序调用
file_matout = [filename(1:end-4) '_cal.mat'];           % 设置输出文件的名字
Result.filename = file_matout;                         % 将文件名输入至结构体Result
Result.type = 'NTC';                                % 将温度计类型输入至结构体Result

Result.Function_1968 = Function_1968;                         % 将校准函数Steinhart and Hart(1968)输入至结构体Result
Result.parameters_1968 = [A B C];                              % 将校准函数的校准参数Steinhart and Hoge(1988)输入至结构体Result

Result.Function_1988 = Function_1988;                         % 将校准函数Hoge(1988)输入至结构体Result
Result.parameters_1988 = X;                              % 将校准函数的校准参数Hoge(1988)输入至结构体Result
Result.date = datenow;                              % 将校准时间输入至结构体Result
save(file_matout,'Result');          % 保存校准结果
end