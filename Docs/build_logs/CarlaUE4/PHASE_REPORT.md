# CarlaUE4 on UE4.26 — Phase Status Report

Date: 2025-09-13

## Environment
- Engine: `E:\UnrealEngine-4.26.2-release`
- Toolchain: VS2019 (MSVC v142), Windows 10 SDK 10.0.22621
- Workspace: `E:\Project\AI\python\project\carla`

## VS Code Configuration
- Updated `.vscode/launch.json` and `.vscode/tasks.json` to target Carla only.
- Removed all AirSimMy/Blocks entries.
- Available tasks:
  - Build: CarlaUE4Editor (UE4.26/VS2019)
  - Build: Generate compile_commands (CarlaUE4)
- Available launch configs:
  - UE4.26 Editor: CarlaUE4 (Build + Debug)
  - UE4.26 Editor: CarlaUE4 (No Build)

## Dependencies & Libraries
- Third‑party (via Setup): zlib, libpng, rpclib, recast — installed under `Build/`.
- Boost 1.84.0 (msvc-14.2):
  - Built via installer; final staging done to:
    - Headers: `Build\boost-1.84.0-install\include\boost`
    - Libs: `Build\boost-1.84.0-install\lib\libboost_*.lib`
- LibCarla (server + client):
  - Server install → `Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies\{include,lib}`
  - Client install → `PythonAPI\carla\dependencies\{include,lib}`

## UTF‑8 Compile Flag Conflict (D8016) — Fixed
- Patch applied to avoid `/utf-8` and `/source-charset:utf-8` collision in MSVC.
- File: `Engine/Source/Programs/UnrealBuildTool/Platform/Windows/VCToolChain.cs`
  - Commented out: `Arguments.Add("/source-charset:utf-8");`
  - Kept: `Arguments.Add("/execution-charset:utf-8");`
- Rebuilt UBT (`UnrealBuildTool.exe`) using MSBuild.

### Reverting the patch (if ever needed)
- Re‑enable the line in `VCToolChain.cs`, rebuild UBT:
  1) Edit file and uncomment `/source-charset:utf-8`.
  2) Build: `MSBuild.exe UnrealBuildTool.csproj /p:Configuration=Development /p:Platform=AnyCPU /t:Build`

## Project Tweaks
- Temporarily disabled `CarlaTools` plugin to bypass StreetMap dependency:
  - `Unreal/CarlaUE4/CarlaUE4.uproject` → `"CarlaTools": { "Enabled": false }`
  - Re‑enable once `Plugins` repository and third‑party dependencies are present.

## Current Build Status
- UBT/Editor: Compiles large portions successfully after UTF‑8 fix.
- Remaining link warnings/errors are due to missing third‑party libs in CarlaDependencies:
  - `sqlite3.lib`, `xerces-c_3.lib`, `proj.lib`, `osm2odr.lib`
- Converters/SimReady warn about NVTT/MDL includes; if not needed, leave those plugins disabled.

## Next Actions (Recommended)
1) Install remaining third‑party for CarlaDependencies:
   - `Util\InstallersWin\install_sqlite3.bat --build-dir "E:\Project\AI\python\project\carla\Build"`
   - `Util\InstallersWin\install_xercesc.bat  --build-dir "E:\Project\AI\python\project\carla\Build"`
   - `Util\InstallersWin\install_proj.bat     --build-dir "E:\Project\AI\python\project\carla\Build"`
   - `Util\BuildTools\BuildOSM2ODR.bat        --generator "Visual Studio 16 2019"`
   - Verify `Unreal\CarlaUE4\Plugins\Carla\CarlaDependencies\lib` contains the above libs and headers under `include`.

2) Rebuild CarlaUE4Editor
   - Task: VS Code → Run Task → `Build: CarlaUE4Editor (UE4.26/VS2019)`
   - Or command: `Build.bat -2019 CarlaUE4Editor Win64 Development -Project="...\CarlaUE4.uproject" -WaitMutex -FromMsBuild -NoHotReloadFromIDE -Progress -NoUTF8Output`

3) (Optional) CarlaTools / Converters / SimReady
   - Clone `carla-plugins` (StreetMap etc.) into `Plugins` folder if required.
   - Re‑enable `CarlaTools` in `.uproject` and supply NVTT/MDL third‑party.

## Helper Scripts Added
- `carla_install_boost_vs2019.cmd` — VS2019 wrapper to install Boost (stages headers/libs).
- `carla_build_libcarla_vs2019.cmd` — Build & install LibCarla server/client for Windows.
- `build_carlaue4editor_once.cmd` — One‑shot CarlaUE4Editor build command.

## Notes
- The warnings "Library '...\sqlite3.lib' was not resolvable" mean UBT会退回到库路径搜索，影响依赖检查与增量，最终链接可能失败；请按“Next Actions”安装这些库。
- 若需要我自动执行第1步安装并重试构建，请告知。我会将完整日志记录到 `docs/build_logs/CarlaUE4/` 目录下。

