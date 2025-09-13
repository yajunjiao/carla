@echo off
setlocal enableextensions
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 exit /b 1
set ROOT=E:\Project\AI\python\project\carla
set BUILD=%ROOT%\Build
set SRCDIR=%ROOT%
set SERVER_BUILD=%BUILD%\libcarla-server-build
set CLIENT_BUILD=%BUILD%\libcarla-client-build

set BOOST_ROOT=%BUILD%\boost-1.84.0-install
set BOOST_INCLUDEDIR=%BOOST_ROOT%\boost-1_84
set BOOST_LIBRARYDIR=%BOOST_ROOT%\lib
set CMAKE_PREFIX_PATH=%BOOST_ROOT%;%BUILD%\rpclib-install;%BUILD%\recast-install;%BUILD%\libpng-1.2.37-install

if exist "%SERVER_BUILD%\CMakeCache.txt" (
  rmdir /s /q "%SERVER_BUILD%"
)
if not exist "%SERVER_BUILD%" mkdir "%SERVER_BUILD%"
pushd "%SERVER_BUILD%"
cmake -G "Visual Studio 16 2019" -A x64 ^
  -DCMAKE_BUILD_TYPE=Server ^
  -DCMAKE_INSTALL_PREFIX="%ROOT%\Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies" ^
  "%SRCDIR%"
if errorlevel 1 exit /b 1
cmake --build . --config Release --target install
if errorlevel 1 exit /b 1
popd

if exist "%CLIENT_BUILD%\CMakeCache.txt" (
  rmdir /s /q "%CLIENT_BUILD%"
)
if not exist "%CLIENT_BUILD%" mkdir "%CLIENT_BUILD%"
pushd "%CLIENT_BUILD%"
cmake -G "Visual Studio 16 2019" -A x64 ^
  -DCMAKE_BUILD_TYPE=Client ^
  -DCMAKE_INSTALL_PREFIX="%ROOT%\PythonAPI\carla\dependencies" ^
  "%SRCDIR%"
if errorlevel 1 exit /b 1
cmake --build . --config Release --target install
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
