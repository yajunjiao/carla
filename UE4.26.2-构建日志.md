# UE4.26.2 源码构建日志（Windows）

- 路径: `E:\\UnrealEngine-4.26.2-release`
- 平台: Windows 64-bit
- 记录: 一步一步执行并记录关键输出与结论

## 步骤 1：验证目录与关键脚本
- 根目录存在: 是
- 根目录脚本: `Setup.bat`, `GenerateProjectFiles.bat`
- `Engine` 目录: 存在
- `Engine\\Build\\BatchFiles` 目录: 存在
- 关键脚本: `Engine\\Build\\BatchFiles\\Build.bat`: 存在
- 依赖工具: `Engine\\Binaries\\DotNET\\GitDependencies.exe`: 存在

结论：结构完整，可以开始执行依赖下载与生成工程文件。

## 步骤 2：检查 VS2019 与 Windows 10 SDK
- VS2019: 未检测到（需要 VS2019 + MSVC v142）
- Windows 10 SDK: 未检测到（建议 10.0.18362+ 或 10.0.19041）

## 步骤 3：运行 Setup.bat 下载依赖
- 开始时间: 2025-09-13 10:15:20

## 步骤 4：运行 GenerateProjectFiles.bat
- 开始时间: 2025-09-13 10:15:47

## 步骤 5：命令行编译 UE4Editor（Win64 Development）
- 开始时间: 2025-09-13 10:15:57

## 结论与下一步
- 当前阻塞：`Setup.bat` 通过 `GitDependencies.exe` 下载第三方依赖时返回 403 Forbidden，无法继续。
- 可能原因：
  - 未完成 Epic 账号登录/EULA 确认（`--prompt` 需要图形交互）
  - 公司/地区网络限制或代理未配置
  - CDN 临时拒绝/限流
- 建议操作：
  - 在本机图形界面直接双击运行 `E:\UnrealEngine-4.26.2-release\Setup.bat`，按提示登录 Epic 账号并同意条款；完成后重试。
  - 在受限网络环境，配置系统代理或设置 `HTTP_PROXY`/`HTTPS_PROXY` 后再运行。
  - 可从已完成 Setup 的机器拷贝离线依赖（如 `.ue4dependencies` 缓存或 `Engine/Source/ThirdParty` 等目录），放到相同路径后再运行。
  - 安装 Visual Studio 2019（含 MSVC v142）与 Windows 10 SDK（10.0.18362+ 或 10.0.19041）。
- 依赖就绪后的命令顺序：
  1. `GenerateProjectFiles.bat -2019`
  2. `Engine\Build\BatchFiles\Build.bat UE4Editor Win64 Development -WaitMutex`
