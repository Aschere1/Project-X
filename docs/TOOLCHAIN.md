# Project X 工具链

## Godot

- 版本：4.7.1 stable standard build（GDScript）
- 官方构建标识：`4.7.1.stable.official.a13da4feb`
- 本机路径：`D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe`
- 项目启动脚本：`scripts/run_godot.ps1`
- 下载文件 SHA-256：`C7A289051EAEFB460B0106B60E9CD5BEE0EF55FD102DCB2BED1EB356CF3D90A1`
- 来源：https://godotengine.org/download/windows/

Godot 使用自包含的 Windows 标准构建，不依赖 C#/.NET。程序目录包含 `_sc_` 便携标记；项目启动脚本还会为当前进程把 `APPDATA`、`LOCALAPPDATA`、`TEMP` 和 `TMP` 重定向到 `D:\Archer\Tools\Godot\4.7.1\project_x_profile`。它不会修改系统级环境变量。

所有开发启动和自动化验证都应通过项目脚本：

```powershell
.\scripts\run_godot.ps1 --editor --path "D:\Archer\Project X"
.\scripts\run_godot.ps1 --headless --path "D:\Archer\Project X" --quit-after 2
```

## Git

- 版本：2.54.0.windows.1
- 项目仓库：`D:\Archer\Project X\.git`
- 当前限制：尚未配置 `user.name` 与 `user.email`，因此暂不创建提交。

## Aseprite

- 当前未安装或未发现。
- Phase 1–2 不依赖 Aseprite；占位素材可以先使用 Godot 基础图形或许可清晰的公开素材。

## Pixelorama

- 版本：v1.1.10-stable
- 路径：`D:\Archer\Tools\Pixelorama\Pixelorama-Windows-64bit\Pixelorama.exe`
- 用途：制作 16×16 瓦片、32×32 角色、动画、图标和可替换源图；不负责 Godot 场景、碰撞或 UI 布局。
- 许可证：Pixelorama 软件为 MIT；生成的 Project X 资产仍需按本项目原创骨架、逐像素整理和资源登记流程复核。
- 下载压缩包：`D:\Archer\Tools\_downloads\Pixelorama-v1.1.10-Windows-64bit.zip`

## Godot Skills

已安装到 Codex Skills：

- `godot-ui-theming`：Theme、StyleBoxFlat、像素 UI 缩放和焦点状态。
- `godot-ui-containers`：HBox/VBox/Grid/Margin/Split 等容器布局。
- `godot-input-handling`：InputMap、设置重绑定、输入隔离和设备提示。

只按具体任务加载这些模块，不全量加载外部 Skills，也不使用它们生成正式地图或 UI 场景。

## Kenney 外部素材

Kenney 的 CC0 候选统一放在 `D:\Archer\Project X External Assets` 或单独评估目录，不直接复制进正式工程。当前优先评估 Pixel UI Pack、Pattern Pack Pixel、Pixel Pack、Pixel Platformer Farm Expansion 和 Animal Pack Remastered；18×18 或风格不匹配的资源只作参考。
