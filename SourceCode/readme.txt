标定的数据文件格式（如：#74.dat）如下（第一列为电阻/Ω，第二列为准确测量后的温度/℃）：
961.1616165	-9.98752381
980.7514747	-4.999
1000.305346	-0.011722222
1019.83393	4.9765
1039.334168	9.966363636
1058.799935	14.9574
1078.236799	19.94944444
1097.648081	24.942
1117.032598	29.93617647
1136.389342	34.93216667


MATLAB Compiler

1. Prerequisites for Deployment 

. Verify the MATLAB Runtime is installed and ensure you    
  have installed version 9.2 (R2017a).   

. If the MATLAB Runtime is not installed, do the following:
  (1) enter
  
      >>mcrinstaller
      
      at MATLAB prompt. The MCRINSTALLER command displays the 
      location of the MATLAB Runtime installer.

  (2) run the MATLAB Runtime installer.

Or download the Windows 64-bit version of the MATLAB Runtime for R2017a 
from the MathWorks Web site by navigating to

   http://www.mathworks.com/products/compiler/mcr/index.html
   
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
Package and Distribute in the MATLAB Compiler documentation  
in the MathWorks Documentation Center.    


NOTE: You will need administrator rights to run MCRInstaller. 


2. Files to Deploy and Package

Files to package for Standalone 
================================
-TempByCal.exe
-MCRInstaller.exe 
   -if end users are unable to download the MATLAB Runtime using the above  
    link, include it when building your component by clicking 
    the "Runtime downloaded from web" link in the Deployment Tool
-This readme file 

3. Definitions

For information on deployment terminology, go to 
http://www.mathworks.com/help. Select MATLAB Compiler >   
Getting Started > About Application Deployment > 
Deployment Product Terms in the MathWorks Documentation 
Center.





