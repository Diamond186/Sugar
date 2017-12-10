@echo off

setlocal

set D6=D:\Delphi\ForCompiler\D6
set D7=D:\Delphi\ForCompiler\D7
set D2005=D:\Delphi\ForCompiler\D2005
set D2006=D:\Delphi\ForCompiler\D2006
set D2007=D:\Delphi\ForCompiler\D2007
set D2009=D:\Delphi\ForCompiler\D2009
set D2010=D:\Delphi\ForCompiler\D2010
set DXE=D:\Delphi\ForCompiler\XE
set DXE2=D:\Delphi\ForCompiler\XE2
set DXE3=D:\Delphi\ForCompiler\XE3
set DXE4=D:\Delphi\ForCompiler\XE4
set DXE5=D:\Delphi\ForCompiler\XE5
set DXE6=D:\Delphi\ForCompiler\XE6
set DXE7=D:\Delphi\ForCompiler\XE7
set DXE8=D:\Delphi\ForCompiler\XE8
set DSeattle=D:\Delphi\ForCompiler\Seattle
set DBerlin=D:\Delphi\ForCompiler\Berlin
set DTokyo=D:\Delphi\ForCompiler\Tokyo
set Path="..\Source\HTMLabel;..\Source\VT\Common;..\Source\VT\Source;..\Source\Gif;..\Source\Third"
set namespace=System;Xml;Data;Datasnap;Web;Soap;Winapi;System.Win;Data.Win;Web.Win;Soap.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell
set innoPath="C:\Program Files (x86)\Inno Setup 5"
set VirtualTree=""D:\Delphi\Virtual Treeview\Source""
set _UPX="D:\GitSource\SugarIDEDelphi\Setup"
set zip="D:\GitSource\SugarIDEDelphi\Setup"

echo - SugarRes.dll 
cd ..\res	
if errorlevel 1 goto failed
"%DTokyo%\bin\brcc32.exe" -fo.\SugarResResource.res SugarResResource.rc
"%DTokyo%\bin\dcc32.exe" --no-config -Q -B -H -W %1 -I"%DTokyo%\release;" -R.\* -U"%DTokyo%\release;" -E..\Setup\App -N..\dcu -NS"%namespace%" SugarRes.dpr
"%zip%\7z.exe" a "%zip%\App\SugarRes.zip" "%zip%\App\SugarRes.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - common.dll
cd ..\common
"%DTokyo%\bin\dcc32.exe" --no-config -Q -B -H -W %1 -I"%DTokyo%\release;" -R.\* -U"%DTokyo%\release;" -E..\Setup\App -N..\dcu -NS"%namespace%" common.dpr
"%zip%\7z.exe" a "%zip%\App\common.zip" "%zip%\App\common.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - SugarPM.exe
cd ..\SugarPM
"%DTokyo%\bin\dcc32.exe" --no-config -Q -B -H -W %1 -I"%DTokyo%\release;%VirtualTree%" -R.\* -U"%DTokyo%\release;%VirtualTree%" -E..\Setup\App -N..\dcu -NS"%namespace%" SugarPM.dpr
%_UPX%\upx.exe %_UPX%\App\SugarPM.exe
"%zip%\7z.exe" a "%zip%\App\SugarPM.zip" "%zip%\App\SugarPM.exe"
if errorlevel 1 goto failed
echo Success!
  
echo .
echo - Delphi Tokyo
cd ..\dll
if errorlevel 1 goto failed
"%DTokyo%\bin\dcc32.exe" --no-config -Q -B -H -W %1 -I"%DTokyo%\release;%Path%" -U"%DTokyo%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarTokyo.dll
"%zip%\7z.exe" a "%zip%\App\SugarTokyo.zip" "%zip%\App\SugarTokyo.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi Berlin
cd ..\..\dll
if errorlevel 1 goto failed
"%DBerlin%\bin\dcc32.exe" -$D0 -$L- -$Y- --no-config -B -Q -DRELEASE;DLL %1 -I"%DTokyo%\release;%Path%" -U"%DBerlin%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarBerlin.dll
"%zip%\7z.exe" a "%zip%\App\SugarBerlin.zip" "%zip%\App\SugarBerlin.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi Seattle
cd ..\..\dll
if errorlevel 1 goto failed
"%DSeattle%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DSeattle%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarSeattle.dll
"%zip%\7z.exe" a "%zip%\App\SugarSeattle.zip" "%zip%\App\SugarSeattle.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE8
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE8%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE8%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE8.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE8.zip" "%zip%\App\SugarXE8.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE7
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE7%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE7%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE7.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE7.zip" "%zip%\App\SugarXE7.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE6
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE6%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE6%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE6.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE6.zip" "%zip%\App\SugarXE6.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE5
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE5%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE5%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE5.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE5.zip" "%zip%\App\SugarXE5.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE4
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE4%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE4%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE4.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE4.zip" "%zip%\App\SugarXE4.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE3
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE3%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE3%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE3.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE3.zip" "%zip%\App\SugarXE3.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE2
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE2%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE2%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" -NS"%namespace%" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE2.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE2.zip" "%zip%\App\SugarXE2.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi XE
cd ..\..\dll
if errorlevel 1 goto failed
"%DXE%\bin\dcc32.exe" --no-config  -Q -B -H -W %1 -U"%DXE%\release;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarXE.dll
"%zip%\7z.exe" a "%zip%\App\SugarXE.zip" "%zip%\App\SugarXE.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D2010
cd ..\..\dll
if errorlevel 1 goto failed
"%D2010%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D2010%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD2010.dll
"%zip%\7z.exe" a "%zip%\App\SugarD2010.zip" "%zip%\App\SugarD2010.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D2009
cd ..\..\dll
if errorlevel 1 goto failed
"%D2009%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D2009%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD2009.dll
"%zip%\7z.exe" a "%zip%\App\SugarD2009.zip" "%zip%\App\SugarD2009.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D2007
cd ..\..\dll
if errorlevel 1 goto failed
"%D2007%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D2007%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD2007.dll
"%zip%\7z.exe" a "%zip%\App\SugarD2007.zip" "%zip%\App\SugarD2007.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D2006
cd ..\..\dll
if errorlevel 1 goto failed
"%D2006%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D2006%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD2006.dll
"%zip%\7z.exe" a "%zip%\App\SugarD2006.zip" "%zip%\App\SugarD2006.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D2005
cd ..\..\dll
if errorlevel 1 goto failed
"%D2005%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D2005%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD2005.dll
"%zip%\7z.exe" a "%zip%\App\SugarD2005.zip" "%zip%\App\SugarD2005.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D7
cd ..\..\dll
if errorlevel 1 goto failed
"%D7%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D7%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD7.dll
"%zip%\7z.exe" a "%zip%\App\SugarD7.zip" "%zip%\App\SugarD7.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - Delphi D6
cd ..\..\dll
if errorlevel 1 goto failed
"%D6%\bin\dcc32.exe" -Q -B -H -W %1 -U"%D6%\lib;%Path%" -E..\Setup\App -N..\dcu -LU"designide;" Sugar.dpr
if errorlevel 1 goto failed
cd ..\Setup\App
if errorlevel 1 goto failed
move Sugar.dll SugarD6.dll
"%zip%\7z.exe" a "%zip%\App\SugarD6.zip" "%zip%\App\SugarD6.dll"
if errorlevel 1 goto failed
echo Success!

echo .
echo - build update file
cd ..\
if errorlevel 1 goto failed
%innoPath%\iscc.exe "Updater\Updater.iss"
"%zip%\7z.exe" a "%zip%\Updater\Update\Update.zip" "%zip%\Updater\Update\Update.exe"
rem %innoPath%\Compil32.exe /cc "SugarSetup.iss"
echo Success!

echo .
echo - build setup file
if errorlevel 1 goto failed
%innoPath%\iscc.exe "SugarSetup.iss"
rem %innoPath%\Compil32.exe /cc "SugarSetup.iss"
echo Success!

goto exit

:failed
echo *** FAILED ***
cd ..
:failed2
exit /b 1

:exit