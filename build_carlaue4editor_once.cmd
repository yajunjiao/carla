@echo off
setlocal enableextensions
set CL=
"E:\UnrealEngine-4.26.2-release\Engine\Build\BatchFiles\Build.bat" -2019 CarlaUE4Editor Win64 Development -Project="E:\Project\AI\python\project\carla\Unreal\CarlaUE4\CarlaUE4.uproject" -WaitMutex -FromMsBuild -NoHotReloadFromIDE -Progress -NoUTF8Output