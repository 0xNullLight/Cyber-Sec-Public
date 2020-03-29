MODE 100,40
echo off
:menu
cls
echo DISCLAIMER!!!
echo The information gathered using this application is used for general purposes only.
echo It should not be used to commit any act of crime.
echo.
pause
cls
echo This program is meant to gather specific network information on a target's computer.
echo The output of this file will be located within whatever directory you ran this application in.
echo.
echo Please select an action
echo 1: IPInfo
echo 2: netstat
echo 3: tracert (1.1.1.1)
echo 4: nslookup (1.1.1.1)
echo 5: All the above
echo.
set /p action=""

if %action%==1 (goto:IPInfo)
if %action%==2 (goto:netstat)
if %action%==3 (goto:tracert)
if %action%==4 (goto:nslookup)
if %action%==5 (goto:all)
Else (goto:menu)

:IPInfo
ipconfig /all > "%~dp0Output.txt"
netsh interface show interface >> "%~dp0Output.txt"
cls
goto:end

:netstat
netstat -ano  >  "%~dp0Output.txt"
cls
goto:end

:tracert
tracert 1.1.1.1 >  "%~dp0Output.txt"
cls
goto:end

:nslookup
NSlookup 1.1.1.1 >  "%~dp0Output.txt"
cls
goto:end

:all
ipconfig /all > "%~dp0Output.txt"
netsh interface show interface >> "%~dp0Output.txt"
netstat -ano  >>  "%~dp0Output.txt"
tracert 1.1.1.1 >>  "%~dp0Output.txt"
NSlookup 1.1.1.1 >>  "%~dp0Output.txt"
cls

:end
echo Do you want to open the output file?
echo 1: Yes
echo 2: No
echo.
set /p action=""
if %action%==1 (goto:yes)
if %action%==2 (goto:no)
:yes
start ./output.txt
:no
cls

:: The purpose of the quotes around %~dp0 is to map drive automatically regardless if it's a UNC Path
