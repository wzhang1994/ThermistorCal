function TempByCal(varargin)
%% 读取配置文件内容并导入数据
clear;                                  % 清除工作空间的所有变量
close all;                              % 关闭所有的Figure窗口 
data = importdata('TempByCal.txt');     % 导入配置文件TempByCal.txt
data_filename = char(data(1,:));        % 读取电阻数据文件名
calibration_filename = char(data(2,:)); % 读取校准文件名
load(calibration_filename)              % 将校准文件（*_cal.mat）数据读入到matlab的工作空间

%% 判断温度计的类型
if (Result.type=='PTC')                 % 温度计的类型属于‘PTC’
    PTC(Result,data)                    % 进入PTC函数，并将校准文件和配置文件输入进去
end

if (Result.type=='NTC')                 % 温度计的类型属于‘NTC’
    NTC(Result,data)                    % 进入NTC函数，并将校准文件和配置文件输入进去
end

disp(['Finished,please check the output file:  ',[data_filename(1:end-4) '_TempByCal.txt']])  % 对话框输出输出文件名
end

function PTC(Result,data)
%% 导入数据并且根据校准文件计算温度
data_filename = char(data(1,:));        % 读取电阻数据文件名
Resistance = load(data_filename);       % 导入电阻值R，单位为 Ω
Resistance = Resistance(:,1);

[n,~]=size(Resistance);                 % 数据的总个数
p = Result.parameters;                  % 接收拟合参数
Temp = Result.Function(Resistance);     % 根据校准结果的拟合函数计算温度
datenow = datestr(now,31);              % 记录当前时间

%% 将温度结构结果输出至文本，便于查看计算结果
file_out = [data_filename(1:end-4) '_TempByCal.txt'];           % 设置输出文件的名字
fid_T = fopen(file_out ,'w');           % 以写入的方式打开输出文件
fprintf(fid_T,'Results of calculation  \r\n');    % 输出内容
fprintf(fid_T,'Calculation Time         :  %s\r\n',datenow);	% 输出当前时间
fprintf(fid_T,'Total                    :  %d\r\n',n);          % 输出内容
fprintf(fid_T,'Calibration Date/time    :  %s\r\n',Result.date);% 输出校准时间
fprintf(fid_T,'CalibrationFile          :  %s\r\n',Result.filename);        % 输出校准的文件名
fprintf(fid_T,'Calibration function     :  T(℃) = k·R(Ω) + b \r\n'); 	  % 输出内容
fprintf(fid_T,'Fitting parameters(k b)  :  %12.10f   %12.10f \r\n\r\n',p);	% 输出拟合参数
fprintf(fid_T,'######################################################################\r\n');     % 输出内容
fprintf(fid_T,'   Resistance/Ω   Temperature/℃\r\n');         % 输出内容
fprintf(fid_T,'%15.5f%15.5f\r\n',[Resistance Temp]');         % 电阻/Ω 根据校准文件计算温度/℃ 
fclose(fid_T);                                      % 关闭输出文件
end

function NTC(Result,data)
%% 导入数据并且根据校准文件计算温度
data_filename = char(data(1,:));        % 读取电阻数据文件名
Resistance = load(data_filename);       % 导入电阻值R，单位为 Ω
Resistance = Resistance(:,1);

[n,~]=size(Resistance);                 % 数据的总个数
A = Result.parameters_1968(1);       % 接收拟合参数
B = Result.parameters_1968(2);       % 接收拟合参数 
C = Result.parameters_1968(3);       % 接收拟合参数 
X = Result.parameters_1988;             % 接收拟合参数   
Temp_1968 = Result.Function_1968(Resistance);     % 根据校准结果的拟合函数计算温度 Steinhart and Hart(1968)
Temp_1988 = Result.Function_1988(Resistance);     % 根据校准结果的拟合函数计算温度 Hoge(1988)
datenow = datestr(now,31);                        % 记录当前时间

%% 将温度结构结果输出至文本，便于查看计算结果
file_out = [data_filename(1:end-4) '_TempByCal.txt'];           % 设置输出文件的名字
fid_T = fopen(file_out ,'w');                     % 以写入的方式打开输出文件
fprintf(fid_T,'Results of calculation  \r\n');    % 输出内容
fprintf(fid_T,'Calculation Time            :  %s\r\n',datenow);	% 输出当前时间
fprintf(fid_T,'Total                       :  %d\r\n',n);          % 输出内容
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',Result.date); 	% 输出校准时间
fprintf(fid_T,'CalibrationFile             :  %s\r\n',Result.filename);   % 输出校准的文件名
fprintf(fid_T,'(1)Calibration function     :  1/(T(K)) = A + B·lnR(Ω) + C·(lnR(Ω))^3 \r\n');   % 输出内容
fprintf(fid_T,'CalibrationCoeff (A B C)    :%18.10e %18.10e %18.10e \r\n\r\n',Result.parameters_1968);    % 输出拟合参数 Steinhart and Hart(1968)
fprintf(fid_T,'(2)Calibration function     :  1/(T(K)) = A + B·lnR(Ω) + C·(lnR(Ω))^2 + D·(lnR(Ω))^3 \r\n');   % 输出内容
fprintf(fid_T,'CalibrationCoeff (A B C D)  :%18.10e %18.10e %18.10e %18.10e \r\n\r\n',Result.parameters_1988); % 输出拟合参数Hoge(1988)
fprintf(fid_T,'######################################################################\r\n');    % 输出内容
fprintf(fid_T,'   Resistance/Ω   (1)Temperature/℃   (2)Temperature/℃   \r\n');  % 输出内容
fprintf(fid_T,'%15.5f%15.5f%15.5f\r\n',[Resistance Temp_1968 Temp_1988]');      % 电阻/Ω 根据校准文件计算温度（两种方法）/℃ 

fprintf(fid_T,'\r\n\r\n\r\n');
fclose(fid_T);
end