# UE4.27 Build Log (Windows)

- Start: <!--TIMESTAMP-->
- UE path: `E:\\UnrealEngine-4.27.2-release`

## 1) Verify path and scripts
- Path exists: true
- Scripts present in root: `Setup.bat`, `GenerateProjectFiles.bat`
- `Engine\\Build\\BatchFiles` present: false
- `Build.bat` present: false

Next: Run `Setup.bat` to fetch dependencies and required files.

## 2) Check VS2019 & Windows SDK
- VS2019 installed: false
- Windows 10 SDK installed: false

Note: Build will require VS2019 with MSVC v142 and Windows 10 SDK.

## 3) Run `Setup.bat`
- Command: `Setup.bat`
- Result: Failed — `Engine\\Binaries\\DotNET\\GitDependencies.exe` not found
- Diagnosis: The `Engine` directory is missing from `E:\\UnrealEngine-4.27.2-release`.

## 4) Run `GenerateProjectFiles.bat`
- Command: `GenerateProjectFiles.bat -2019`
- Result: Failed — script reports not in UE4 root directory
- Diagnosis: Expected files/folders (e.g., `Engine`) are not present.

## Required Actions
- Ensure this path is a full UE4 source checkout that includes the `Engine` folder.
- Install Visual Studio 2019 (Desktop C++ workload, MSVC v142) and Windows 10 SDK.
- Then re-run: `Setup.bat` → `GenerateProjectFiles.bat -2019` → build.
