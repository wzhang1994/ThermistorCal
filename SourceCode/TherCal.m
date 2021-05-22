function TherCal(varargin)             % �궨�¶ȼ����ϵ����������
%% ��ȡ�����ļ����ݲ���������
clear;                              % ��������ռ�����б���
close all;                          % �ر����е�Figure���� 
fid=fopen('TherCal.txt','r');       % ֻ���ķ�ʽ�������ļ�TherCal.txt
filename=fgets(fid);                % ��ȡ�����ļ�TherCal.txt����
fclose(fid);                        % �ر������ļ�TherCal.txt

data = load(filename);              % ��ȡ����-�¶������ļ�
Resistance = data(:,1);             % �����ļ��ĵ���ֵR����λΪ ��
Temperature = data(:,2);            % �����ļ����¶�T����λ ��


%% �ж��¶ȼƵ�����
R = corrcoef(Resistance,Temperature);           % ����������¶ȵ����ϵ��  
if (R(1,2)>0)                                   % Positive Temperature Coefficient �����ϵ��
    PTC(Temperature,Resistance,filename)        % ����PTC���������������ļ��ĵ���ֵ���¶Ⱥ��ļ����������ȥ
end

if (R(1,2)<0)                                   % Negative Temperature Coefficient �����ϵ��
    NTC(Temperature,Resistance,filename)        % ����NTC���������������ļ��ĵ���ֵ���¶Ⱥ��ļ����������ȥ
end

if (R(1,2)==0)                                  % �������¶��޹�
    disp('�������¶��޹أ��޷����')              % �Ի������'�������¶��޹أ��޷����'
    return                                      % ��������
end

disp(['Finished,please check the output file:  ',[filename(1:end-4) '_cal.txt']])  % �Ի����������ļ���

end

function  PTC(Temperature,Resistance,filename)	% PTC����
%% PTC���¶ȼƽ��б궨
x = Resistance;                                 % x���յ���ֵ����ֵR����λΪ ��
y = Temperature;                                % y�����¶�T����λ ��
p = polyfit(x,y,1);                             % ������С���˷��������ԭ��Ե�����¶Ƚ���һ�����
Function = @(x) p(1) * x + p(2);                % ����PTC���¶ȼƵ���Ϻ���
y_calc = Function(x);                           % �궨�����õ����¶ȣ���λ ��
R = corrcoef(y,y_calc);                         % �����������¶Ⱥͱ궨����¶�֮�����ϵ��
Dy = (y_calc - y) * 1000;                       % ����в��λ mK
[n,~]=size(Dy);                                 % �в���ܸ���
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;	% �����׼�Standard Deviation������λ ��
datenow=datestr(now,31);                        % ��¼��ǰʱ��

%% ���У׼���ͼ��
figure                                          % ����һ��������ʾͼ������Ĵ���
set(gcf,'Position',[300 0 500 960 ]);           % ����ͼ�񴰿�����Ļ��λ�á���С
whitebg([1 1 1])                                % ��ͼ����ɫ����Ϊ��ɫ
set(gcf,'color','w')                            % �����ڲ�ͼ����Χ����Ϊ��ɫ
subplot 211                                     % ��ͼ���ڷֳ�����һ���������������ڵ�һ����ͼ����ͼ
plot(x,y,'*')                                   % ���Ƶ���������õ����¶�ͼ�񣬱�Ƿ���Ϊ��*��
hold on                                         % ����ͼ�β��䣬�»�ͼ��֮�󲻸���ԭͼ
fplot(Function)                                 % ����Function��������
axis([min(x) max(x) min(y) max(y)])             % ����x���y��ķ�Χ
grid on                                         % ����������
grid minor                                      % ����С��������
title('Results of Calibration','FontWeight','bold');    % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');    % ��עx������
ylabel('Temperature/��','FontWeight','bold');   % ��עy������
legend('T\_ref','T\_calc','Location','northwest');      % ����ͼ��

subplot 212                                     % ��ͼ���ڷֳ�����һ���������������ڵڶ�����ͼ����ͼ
plot(x,Dy,'x')                                  % ���Ƶ������¶Ȳв��ͼ�񣬱�Ƿ���Ϊ��x��
grid on                                         % ����������
grid minor                                      % ����С��������
title('Temperature residual','FontWeight','bold');    % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');    % ��עx������
ylabel('Temperature residual/mK','FontWeight','bold');% ��עy������
legend('T\_calc - T\_ref','Location','northwest');      % ����ͼ��

saveas(gca,[filename(1:end-4) '_cal.fig']);     % ����ͼ��*_cal.fig,���ں��ڸ���
saveas(gcf,[filename(1:end-4) '_cal'],'bmp')    % ����ͼ��*_cal.bmp

%% ��У׼���������ı������ڲ鿴У׼���
file_out = [filename(1:end-4) '_cal.txt'];           % ��������ļ�������
fid_T = fopen(file_out ,'w');                       % ��д��ķ�ʽ������ļ�
fprintf(fid_T,'Results of Calibration\r\n\r\n');    % �������
fprintf(fid_T,'Calibration Date/time     :  %s\r\n',datenow);                               % �����ǰʱ��
fprintf(fid_T,'Resistance type           :  PTC (Positive Temperature Coefficient) \r\n');  % �������
fprintf(fid_T,'Calibration function      :  T(��) = k��R(��) + b \r\n');                        % �������
fprintf(fid_T,'Fitting parameters(k b)   :  %12.10f   %12.10f \r\n',p);                     % �����ϲ���

fprintf(fid_T,'Or\r\n');                            % �������
fprintf(fid_T,'T&R relationship          :  R(��) = k''��T(��) + b'' \r\n');                     % �������
fprintf(fid_T,'Fitting parameters(k'' b'') :  %12.10f   %12.10f \r\n\r\n\r\n',1/p(1),-p(2)/p(1));   % �������
fprintf(fid_T,'     Resistance/��       Measured/��     Calculated/��      Residual/mK\r\n');       % �������
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x y y_calc Dy]');          % ����/�� �����¶�/�� �궨��ʽ�����¶�/�� �¶Ȳв�/mK
fprintf(fid_T,'\r\n');                              % �������
fprintf(fid_T,'Correlation coefficient   :  %12.10f \r\n',R(1,2));      % ������ϵ��
fprintf(fid_T,'Standard Deviation        :  %12.10f  ��\r\n\r\n',Standard_Deviation);               % �����׼�� ��λ ��
fclose(fid_T);                                      % �ر�����ļ�

%% ��У׼������浽*.mat(MATLAB�����ݴ洢��ʽ)�����ں����������
file_matout = [filename(1:end-4) '_cal.mat'];           % ��������ļ�������
Result.filename = file_matout;                         % ���ļ����������ṹ��Result
Result.type = 'PTC';                                % ���¶ȼ������������ṹ��Result
Result.Function = Function;                         % ��У׼�����������ṹ��Result
Result.date = datenow;                              % ��У׼ʱ���������ṹ��Result
Result.parameters = p;                              % ��У׼������У׼�����������ṹ��Result
save(file_matout,'Result');          % ����У׼���

end

function  NTC(Temperature,Resistance,filename)      % NTC����
%% ��������¶�����
x = Resistance;                                     % x���յ���ֵ����ֵR����λΪ ��
y = Temperature + 273.15;                           % y�����¶�T��ת����λ����λ K
[n,~] = size(x);                                    % ���ݵ��ܸ���
datenow=datestr(now,31);                            % ��¼��ǰʱ��

%% NTC���¶ȼƽ��б궨 Steinhart and Hart(1968)
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
A = (a12*a23*b3 - a13*a22*b3 - a12*a33*b2 + a13*a32*b2 + a22*a33*b1 - a23*a32*b1)...        % ��ϲ���A
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);
B = -(a11*a23*b3 - a13*a21*b3 - a11*a33*b2 + a13*a31*b2 + a21*a33*b1 - a23*a31*b1)...       % ��ϲ���B
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);
C = (a11*a22*b3 - a12*a21*b3 - a11*a32*b2 + a12*a31*b2 + a21*a32*b1 - a22*a31*b1)...        % ��ϲ���C
    /(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31);

Function_1968 = @(x) 1./(A + B * log(x) + C * (log(x).*log(x).*log(x))) - 273.15;           % ����NTC���¶ȼƵ���Ϻ��� Steinhart and Hart(1968)
y_calc = Function_1968(x);                      % �궨�����õ����¶ȣ���λ ��
R = corrcoef(Temperature,y_calc);               % �����������¶Ⱥͱ궨����¶�֮�����ϵ��
Dy = (y_calc - Temperature) * 1000;             % ����в��λ mK
[n,~]=size(Dy);                                 % �в���ܸ���
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;	% �����׼�Standard Deviation������λ ��


%% ���У׼���ͼ�� Steinhart and Hart(1968)
figure                                          % ����һ��������ʾͼ������Ĵ���
set(gcf,'Position',[300 0 500*2 960 ]);         % ����ͼ�񴰿�����Ļ��λ�á���С
whitebg([1 1 1])                                % ��ͼ����ɫ����Ϊ��ɫ
set(gcf,'color','w')                            % �����ڲ�ͼ����Χ����Ϊ��ɫ

subplot 221                                     % ��ͼ���ڷֳ����������������������ڵ�һ����ͼ����ͼ
plot(x,Temperature,'*')                         % ���Ƶ���������õ����¶�ͼ�񣬱�Ƿ���Ϊ��*��
hold on                                         % ����ͼ�β��䣬�»�ͼ��֮�󲻸���ԭͼ                   
fplot(Function_1968)                            % ����Function_1968��������
axis([min(x) max(x) min(Temperature) max(Temperature)]) % ����x���y��ķ�Χ
grid on                                         % ����������
grid minor                                      % ����С��������
title('Results of Calibration by Steinhart and Hart(1968)','FontWeight','bold');    % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');    % ��עx������
ylabel('Temperature/��','FontWeight','bold');   % ��עy������
legend('T\_ref','T\_calc','Location','northeast');      % ����ͼ��

subplot 223                                     % ��ͼ���ڷֳ����������������������ڵ�������ͼ����ͼ
plot(x,Dy,'x')                                  % ���Ƶ������¶Ȳв��ͼ�񣬱�Ƿ���Ϊ��x��
grid on                                         % ����������
grid minor                                      % ����С��������
title('Temperature residual','FontWeight','bold');    % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');    % ��עx������
ylabel('Temperature residual/mK','FontWeight','bold');  % ��עy������
legend('T\_calc - T\_ref','Location','northeast');      % ����ͼ��

%% ��У׼���������ı������ڲ鿴У׼��� Steinhart and Hart(1968)
file_out = [filename(1:end-4) '_cal.txt'];           % ��������ļ�������
fid_T = fopen(file_out ,'w');                       % ��д��ķ�ʽ������ļ�
fprintf(fid_T,'Results of Calibration by Steinhart and Hart(1968)\r\n\r\n');    % �������
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',datenow);                               % �����ǰʱ��
fprintf(fid_T,'Resistance type             :  NTC (Negative Temperature Coefficient) \r\n');  % �������
fprintf(fid_T,'Calibration function        :  1/(T(K)) = A + B��lnR(��) + C��(lnR(��))^3 \r\n');   % �������
fprintf(fid_T,'Fitting parameters(A B C)   :%18.10e %18.10e %18.10e \r\n\r\n',A,B,C);             % �������

fprintf(fid_T,'     Resistance/��       Measured/��     Calculated/��      Residual/mK\r\n');      % �������
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x Temperature y_calc Dy]');               % ����/�� �����¶�/�� �궨��ʽ�����¶�/�� �¶Ȳв�/mK
fprintf(fid_T,'\r\n');                              % �������
fprintf(fid_T,'Correlation coefficient     :%14.10f \r\n',R(1,2));      % ������ϵ��
fprintf(fid_T,'Standard Deviation          :%14.10f  ��\r\n\r\n',Standard_Deviation);               % �����׼�� ��λ ��
fprintf(fid_T,'\r\n\r\n');                          % �������
fclose(fid_T);                                      % �ر�����ļ�

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NTC���¶ȼƽ��б궨 Hoge(1988)
AA = [n sum(log(x)) sum((log(x)).^2) sum((log(x)).^3)                   % ��������
    sum(log(x)) sum((log(x)).^2) sum((log(x)).^3) sum((log(x)).^4)
    sum((log(x)).^2) sum((log(x)).^3) sum((log(x)).^4) sum((log(x)).^5)
    sum((log(x)).^3) sum((log(x)).^4) sum((log(x)).^5) sum((log(x)).^6)];
BB = [sum(1./y)                                                         % �����������
    sum(log(x)./y)
    sum((((log(x)).^2)./y))
    sum((((log(x)).^3)./y))];
X = AA\BB;                                          % ��ϲ���X
Function_1988  =@(x) 1./(X(1) + X(2) * log(x) + X(3) * (log(x).*log(x)) + X(4) * (log(x).*log(x).*log(x)))-273.15;    % ����NTC���¶ȼƵ���Ϻ��� Hoge(1988)
y_calc = Function_1988(x);                          % �궨�����õ����¶ȣ���λ ��
R = corrcoef(Temperature,y_calc);                   % �����������¶Ⱥͱ궨����¶�֮�����ϵ��
Dy = (y_calc - Temperature) * 1000;                 % ����в��λ mK
[n,~]=size(Dy);                                     % �в���ܸ���
Standard_Deviation=(sum((Dy/1000).^2)/n)^0.5;       % �����׼�Standard Deviation������λ ��

%% ���У׼���ͼ�� Hoge(1988)
subplot 222                                         % ��ͼ���ڷֳ����������������������ڵڶ�����ͼ����ͼ
plot(x,Temperature,'*')                             % ���Ƶ���������õ����¶�ͼ�񣬱�Ƿ���Ϊ��*��
hold on                                             % ����ͼ�β��䣬�»�ͼ��֮�󲻸���ԭͼ
fplot(Function_1988)                                % ����Function_1988��������
axis([min(x) max(x) min(Temperature) max(Temperature)])  % ����x���y��ķ�Χ
grid on                                             % ����������
grid minor                                          % ����С��������
title('Results of Calibration by Hoge(1988��','FontWeight','bold');    % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');        % ��עx������
ylabel('Temperature/��','FontWeight','bold');       % ��עy������
legend('T\_ref','T\_calc','Location','northeast');  % ����ͼ��

subplot 224                                         % ��ͼ���ڷֳ����������������������ڵ��ĸ���ͼ����ͼ
plot(x,Dy,'bx')                                     % ���Ƶ������¶Ȳв��ͼ�񣬱�Ƿ���Ϊ��x��
grid on                                             % ����������
grid minor                                          % ����С��������
title('Temperature residual','FontWeight','bold');  % ���ͼ�����
xlabel('Resistance/��','FontWeight','bold');        % ��עx������
ylabel('Temperature residual/mK','FontWeight','bold');  % ��עy������
legend('T\_calc - T\_ref','Location','northeast');  % ����ͼ��

saveas(gca,[filename(1:end-4) '_cal.fig']);     % ����ͼ��*_cal.fig,���ں��ڸ���
saveas(gcf,[filename(1:end-4) '_cal'],'bmp')    % ����ͼ��*_cal.bmp

%% ��У׼���������ı������ڲ鿴У׼��� Hoge(1988)
fid_T = fopen(file_out ,'at');                       % ��������ļ�������
fprintf(fid_T,'######################################################################\r\n');    % �������
fprintf(fid_T,'Results of Calibration by Hoge(1988)\r\n\r\n'); % �������
fprintf(fid_T,'Calibration Date/time       :  %s\r\n',datenow);                         % �����ǰʱ��
fprintf(fid_T,'Resistance type             :  NTC (Negative Temperature Coefficient) \r\n');    % �������
fprintf(fid_T,'Calibration function        :  1/(T(K)) = A + B��lnR(��) + C��(lnR(��))^2 + D��(lnR(��))^3 \r\n'); % �������
fprintf(fid_T,'Fitting parameters(A B C D) :%18.10e %18.10e %18.10e %18.10e \r\n\r\n',X);           % �����ϲ���
fprintf(fid_T,'     Resistance/��       Measured/��     Calculated/��      Residual/mK\r\n');       % �������
fprintf(fid_T,'%18.10f%18.10f%18.10f%18.7f\r\n',[x Temperature y_calc Dy]');       % ����/�� �����¶�/�� �궨��ʽ�����¶�/�� �¶Ȳв�/mK
fprintf(fid_T,'\r\n');                              % �������
fprintf(fid_T,'Correlation coefficient     :%14.10f \r\n',R(1,2));      % ������ϵ��
fprintf(fid_T,'Standard Deviation          :%14.10f  ��\r\n\r\n',Standard_Deviation);               % �����׼�� ��λ ��
fprintf(fid_T,'\r\n\r\n\r\n');                      % �������
fclose(fid_T);                                      % �ر�����ļ�

%% �����ַ�����У׼������浽*.mat(MATLAB�����ݴ洢��ʽ)�����ں����������
file_matout = [filename(1:end-4) '_cal.mat'];           % ��������ļ�������
Result.filename = file_matout;                         % ���ļ����������ṹ��Result
Result.type = 'NTC';                                % ���¶ȼ������������ṹ��Result

Result.Function_1968 = Function_1968;                         % ��У׼����Steinhart and Hart(1968)�������ṹ��Result
Result.parameters_1968 = [A B C];                              % ��У׼������У׼����Steinhart and Hoge(1988)�������ṹ��Result

Result.Function_1988 = Function_1988;                         % ��У׼����Hoge(1988)�������ṹ��Result
Result.parameters_1988 = X;                              % ��У׼������У׼����Hoge(1988)�������ṹ��Result
Result.date = datenow;                              % ��У׼ʱ���������ṹ��Result
save(file_matout,'Result');          % ����У׼���
end