@echo off
setlocal enableextensions
REM Build AirLib and deps with VS2019 toolchain for UE4.26 linking

set ROOT_DIR=%~dp0
pushd "%ROOT_DIR%"

REM Locate VS2019 (16.x) with C++ toolset
set VSWHERE="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist %VSWHERE% (
  echo ERROR: vswhere.exe not found at %VSWHERE%
  exit /b 1
)

for /f "usebackq tokens=* delims=" %%I in (`%VSWHERE% -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -version "[16.0,17.0)" -property installationPath`) do set VSINSTALL=%%I
if not defined VSINSTALL (
  echo ERROR: Visual Studio 2019 not found.
  exit /b 1
)

set VCVARS="%VSINSTALL%\VC\Auxiliary\Build\vcvars64.bat"
if not exist %VCVARS% (
  echo ERROR: vcvars64.bat not found at %VCVARS%
  exit /b 1
)

call %VCVARS%
if errorlevel 1 (
  echo ERROR: Failed to init VS2019 environment
  exit /b 1
)

REM Ensure PowerShell exists
set powershell=powershell
where powershell > nul 2>&1
if errorlevel 1 (
  echo ERROR: PowerShell not found in PATH
  exit /b 1
)

REM Check/Install cmake
call check_cmake.bat
if errorlevel 1 (
  call check_cmake.bat
  if errorlevel 1 (
    echo ERROR: cmake is not available
    exit /b 1
  )
)

REM Prepare rpclib
set RPC_DIR=external\rpclib\rpclib-2.3.0
if not exist external\rpclib mkdir external\rpclib
if not exist %RPC_DIR% (
  echo Downloading rpclib v2.3.0...
  %powershell% -command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr https://github.com/rpclib/rpclib/archive/v2.3.0.zip -OutFile external\rpclib.zip }"
  if errorlevel 1 exit /b 1
  %powershell% -command "Expand-Archive -Path external\rpclib.zip -DestinationPath external\rpclib"
  del /q external\rpclib.zip
)

REM Reconfigure and build rpclib with VS2019 generator
if exist %RPC_DIR%\build rmdir /s /q %RPC_DIR%\build
mkdir %RPC_DIR%\build
pushd %RPC_DIR%\build
cmake -G"Visual Studio 16 2019" ..
if errorlevel 1 exit /b 1
cmake --build . --config Debug
if errorlevel 1 exit /b 1
cmake --build . --config Release
if errorlevel 1 exit /b 1
popd

REM Stage rpclib headers and libs
set RPCLIB_TARGET_LIB=AirLib\deps\rpclib\lib\x64
set RPCLIB_TARGET_INCLUDE=AirLib\deps\rpclib\include
if not exist %RPCLIB_TARGET_LIB% mkdir %RPCLIB_TARGET_LIB%
if not exist %RPCLIB_TARGET_INCLUDE% mkdir %RPCLIB_TARGET_INCLUDE%
robocopy /MIR %RPC_DIR%\include %RPCLIB_TARGET_INCLUDE% >nul
robocopy /MIR %RPC_DIR%\build\Debug %RPCLIB_TARGET_LIB%\Debug >nul
robocopy /MIR %RPC_DIR%\build\Release %RPCLIB_TARGET_LIB%\Release >nul

REM Ensure Eigen
if not exist AirLib\deps mkdir AirLib\deps
if not exist AirLib\deps\eigen3 (
  %powershell% -command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.zip -OutFile eigen3.zip }"
  %powershell% -command "Expand-Archive -Path eigen3.zip -DestinationPath AirLib\deps"
  %powershell% -command "Move-Item -Path AirLib\deps\eigen* -Destination AirLib\deps\del_eigen"
  mkdir AirLib\deps\eigen3
  move AirLib\deps\del_eigen\Eigen AirLib\deps\eigen3\Eigen >nul
  rmdir /s /q AirLib\deps\del_eigen
  del eigen3.zip
)
if not exist AirLib\deps\eigen3 (
  echo ERROR: Eigen fetch failed
  exit /b 1
)

REM Build AirSim.sln (AirLib + MavLinkCom) with VS2019
set CL=/utf-8 /wd4819 /WX-
msbuild -version >nul 2>&1
if errorlevel 1 (
  echo ERROR: msbuild not available in environment
  exit /b 1
)

msbuild /m /p:Platform=x64 /p:Configuration=Debug /p:TrackFileAccess=false AirSim.sln
if errorlevel 1 exit /b 1
msbuild /m /p:Platform=x64 /p:Configuration=Release /p:TrackFileAccess=false AirSim.sln
if errorlevel 1 exit /b 1

REM Copy outputs to Unreal plugin folder
if not exist Unreal\Plugins\AirSim\Source\AirLib mkdir Unreal\Plugins\AirSim\Source\AirLib
robocopy /MIR AirLib Unreal\Plugins\AirSim\Source\AirLib /XD temp *. /njh /njs /ndl /np >nul
copy /y AirSim.props Unreal\Plugins\AirSim\Source\AirLib >nul

echo VS2019 build completed.
popd
exit /b 0

