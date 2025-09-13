@echo off
setlocal enableextensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b 1
pushd "E:\Project\AI\python\project\carla"
set ROOT_PATH=E:/Project/AI/python/project/carla/
set INSTALLATION_DIR=E:/Project/AI/python/project/carla/Build
call ".\Util\BuildTools\Setup.bat" --generator "Visual Studio 16 2019" --boost-toolset msvc-14.2
popd
exit /b %errorlevel%
