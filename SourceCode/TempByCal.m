function TempByCal(varargin)
%% ��ȡ�����ļ����ݲ���������
clear;                                  % ��������ռ�����б���
close all;                              % �ر����е�Figure���� 
data = importdata('TempByCal.txt');     % ���������ļ�TempByCal.txt
data_filename = char(data(1,:));        % ��ȡ���������ļ���
calibration_filename = char(data(2,:)); % ��ȡУ׼�ļ���
load(calibration_filename)              % ��У׼�ļ���*_cal.mat�����ݶ��뵽matlab�Ĺ����ռ�

%% �ж��¶ȼƵ�����
if (Result.type=='PTC')                 % �¶ȼƵ��������ڡ�PTC��
    PTC(Result,data)                    % ����PTC����������У׼�ļ��������ļ������ȥ
end

if (Result.type=='NTC')                 % �¶ȼƵ��������ڡ�NTC��
    NTC(Result,data)                    % ����NTC����������У׼�ļ��������ļ������ȥ
end

disp(['Finished,please check the output file:  ',[data_filename(1:end-4) '_TempByCal.txt']])  % �Ի����������ļ���
end

function PTC(Result,data)
%% �������ݲ��Ҹ���У׼�ļ������¶�
data_filename = char(data(1,:));        % ��ȡ���������ļ���
Resistance = load(data_filename);       % �������ֵR����λΪ ��
Resistance = Resistance(:,1);

[n,~]=size(Resistance);                 % ���ݵ��ܸ���
p = Result.parameters;                  % ������ϲ���
Temp = Result.Function(Resistance);     % ����У׼�������Ϻ��������¶�
datenow = datestr(now,31);              % ��¼��ǰʱ��

%% ���¶Ƚṹ���������ı������ڲ鿴������
file_out = [data_filename(1:end-4) '_TempByCal.txt'];           % ��������ļ�������
fid_T = fopen(file_out ,'w');           % ��д��ķ�ʽ������ļ�
fprintf(fid_T,'Results of calculation  \r\n');    % �������
fprintf(fid_T,'Calculation Time         :  %s\r\n',datenow);	% �����ǰʱ��
fprintf(fid_T,'Total                    :  %d\r\n',n);          % �������
fprintf(fid_T,'Calibration Date/time    :  %s\r\n',Result.date);% ���У׼ʱ��
fprintf(fid_T,'CalibrationFile          :  %s\r\n',Result.filename);        % ���У׼���ļ���
fprintf(fid_T,'Calibration function     :  T(��) = k��R(��) + b \r\n'); 	  % �������
fprintf(fid_T,'Fitting parameters(k b)  :  %12.10f   %12.10f \r\n\r\n',p);	% �����ϲ���
fprintf(fid_T,'######################################################################\r\n');     % �������
fprintf(fid_T,'   Resistance/��   Temperature/��\r\n');         % �������
fprintf(fid_T,'%15.5f%15.5f\r\n',[Resistance Temp]');         % ����/�� ����У׼�ļ������¶�/�� 
fclose(fid_T);                                      % �ر�����ļ�
end

function NTC(Result,data)
%% �������ݲ��Ҹ���У׼�ļ������¶�
data_filename = char(data(1,:));        % ��ȡ���������ļ���
Resistance = load(data_filename);       % �������ֵR����λΪ ��
Resistance = Resistance(:,1);

[n,~]=size(Resistance);                 % ���ݵ��ܸ���
A = Result.parameters_1968(1);       % ������ϲ���
B = Result.parameters_1968(2);       % ������ϲ��� 
C = Result.parameters_1968(3);       % ������ϲ��� 
X = Result.parameters_1988;             % ������ϲ���   
Temp_1968 = Result.Function_1968(Resistance);     % ����У׼�������Ϻ��������¶� Steinhart and Hart(1968)
Temp_1988 = Result.Function_1988(Resistance);     % ����У׼�������Ϻ��������¶� Hoge(1988)
datenow = datestr(now,31);                        % ��¼��ǰʱ��

%% ���¶Ƚṹ���������ı������ڲ鿴������
file_out = [data_filename(1:end-4) '_TempByCal.txt'];           % ��������ļ�������
fid_T = fopen(file_out ,'w');                     % ��д��ķ�ʽ������ļ�
fprintf(fid_T,'Results of calculation  \r\n');    % �������
fprintf(fid_T,'Calculation Time            :  %s\r\n',datenow);	% �����ǰʱ��
fprintf(fid_T,'Total                       :  %d\r\n',n);          % �������
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',Result.date); 	% ���У׼ʱ��
fprintf(fid_T,'CalibrationFile             :  %s\r\n',Result.filename);   % ���У׼���ļ���
fprintf(fid_T,'(1)Calibration function     :  1/(T(K)) = A + B��lnR(��) + C��(lnR(��))^3 \r\n');   % �������
fprintf(fid_T,'CalibrationCoeff (A B C)    :%18.10e %18.10e %18.10e \r\n\r\n',Result.parameters_1968);    % �����ϲ��� Steinhart and Hart(1968)
fprintf(fid_T,'(2)Calibration function     :  1/(T(K)) = A + B��lnR(��) + C��(lnR(��))^2 + D��(lnR(��))^3 \r\n');   % �������
fprintf(fid_T,'CalibrationCoeff (A B C D)  :%18.10e %18.10e %18.10e %18.10e \r\n\r\n',Result.parameters_1988); % �����ϲ���Hoge(1988)
fprintf(fid_T,'######################################################################\r\n');    % �������
fprintf(fid_T,'   Resistance/��   (1)Temperature/��   (2)Temperature/��   \r\n');  % �������
fprintf(fid_T,'%15.5f%15.5f%15.5f\r\n',[Resistance Temp_1968 Temp_1988]');      % ����/�� ����У׼�ļ������¶ȣ����ַ�����/�� 

fprintf(fid_T,'\r\n\r\n\r\n');
fclose(fid_T);
end