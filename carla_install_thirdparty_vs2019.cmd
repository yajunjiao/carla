@echo off
setlocal enableextensions
rem Install remaining third-party deps for Carla (sqlite3, xerces, proj, osm2odr) and stage into CarlaDependencies

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 (
  echo ERROR: Failed to init VS2019 environment
  exit /b 1
)

set ROOT=E:\Project\AI\python\project\carla
set BUILD=%ROOT%\Build
set GEN="Visual Studio 16 2019"

echo === Installing sqlite3 ===
call "%ROOT%\Util\InstallersWin\install_sqlite3.bat" --build-dir "%BUILD%"
if errorlevel 1 exit /b 1

echo === Installing xerces-c ===
call "%ROOT%\Util\InstallersWin\install_xercesc.bat" --build-dir "%BUILD%" --generator %GEN%
if errorlevel 1 exit /b 1

echo === Installing PROJ ===
call "%ROOT%\Util\InstallersWin\install_proj.bat" --build-dir "%BUILD%" --generator %GEN%
if errorlevel 1 exit /b 1

echo === Building OSM2ODR ===
set ROOT_PATH=%ROOT:/=/%/
set INSTALLATION_DIR=%BUILD%\
call "%ROOT%\Util\BuildTools\BuildOSM2ODR.bat" --build --generator %GEN%
if errorlevel 1 exit /b 1

echo === Installing Eigen ===
call "%ROOT%\Util\InstallersWin\install_eigen.bat" --build-dir "%BUILD%"
if errorlevel 1 exit /b 1

echo === Staging libraries into CarlaDependencies ===
set DEP=%ROOT%\Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies
if not exist "%DEP%\lib" mkdir "%DEP%\lib"
if not exist "%DEP%\include" mkdir "%DEP%\include"

rem sqlite3
if exist "%BUILD%\sqlite3-install\lib\sqlite3.lib" copy /y "%BUILD%\sqlite3-install\lib\sqlite3.lib" "%DEP%\lib" >nul
if exist "%BUILD%\sqlite3-install\include\sqlite3.h" copy /y "%BUILD%\sqlite3-install\include\sqlite3.h" "%DEP%\include" >nul

rem xerces (copy and also duplicate name to xerces-c_3.lib if needed)
if exist "%BUILD%\xerces-c-3.2.3-install\lib\xerces-c.lib" copy /y "%BUILD%\xerces-c-3.2.3-install\lib\xerces-c.lib" "%DEP%\lib" >nul
if exist "%BUILD%\xerces-c-3.2.3-install\lib\xerces-c.lib" copy /y "%BUILD%\xerces-c-3.2.3-install\lib\xerces-c.lib" "%DEP%\lib\xerces-c_3.lib" >nul
if exist "%BUILD%\xerces-c-3.2.3-install\include\xercesc" xcopy /e /i /y "%BUILD%\xerces-c-3.2.3-install\include\xercesc" "%DEP%\include\xercesc" >nul

rem proj
if exist "%BUILD%\proj-install\lib\proj.lib" copy /y "%BUILD%\proj-install\lib\proj.lib" "%DEP%\lib" >nul
if exist "%BUILD%\proj-install\include" xcopy /e /i /y "%BUILD%\proj-install\include" "%DEP%\include" >nul

rem zlib static (produced by Setup)
if exist "%BUILD%\zlib-source\build\zlibstatic.lib" copy /y "%BUILD%\zlib-source\build\zlibstatic.lib" "%DEP%\lib" >nul
if exist "%BUILD%\zlib-install\include" xcopy /e /i /y "%BUILD%\zlib-install\include" "%DEP%\include" >nul

rem rpclib/recast headers were staged by LibCarla; leave as is

rem eigen
if exist "%BUILD%\eigen-install\include\Eigen" xcopy /e /i /y "%BUILD%\eigen-install\include\Eigen" "%DEP%\include\Eigen" >nul
if exist "%BUILD%\eigen-install\include\unsupported" xcopy /e /i /y "%BUILD%\eigen-install\include\unsupported" "%DEP%\include\unsupported" >nul

echo Done staging third-party dependencies.
exit /b 0
