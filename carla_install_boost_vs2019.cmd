@echo off
setlocal enableextensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b 1
set ROOT=E:\Project\AI\python\project\carla
set BUILD=%ROOT%\Build
set JOBS=%NUMBER_OF_PROCESSORS%
if "%JOBS%"=="" set JOBS=8
echo Installing Boost 1.84.0 into %BUILD% with msvc-14.2, jobs=%JOBS%
call "%ROOT%\Util\InstallersWin\install_boost.bat" --build-dir "%BUILD%" --version 1.84.0 --toolset msvc-14.2 -j %JOBS%
exit /b %errorlevel%

