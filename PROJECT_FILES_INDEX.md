# Project X 本地文件索引

整理日期：2026-08-09  
唯一桌面项目入口：`D:\Archer\Project X`

## 当前结构

- `project.godot`、`src/`、`scenes/`、`assets/` 等：当前 Godot 主工程。
- `project_materials/asset_staging/`：候选素材暂存，557 个文件。
- `project_materials/captures/`：视觉检查与验收截图，221 个文件。
- `project_materials/external_assets/`：外部素材包及检查副本，682 个文件。
- `project_materials/private_sources/`：不可公开的参考源文件，5 个文件。
- `project_materials/temp/`：历史临时诊断目录，目前没有文件。
- `project_materials/pre_migration_generated_2026-08-09/`：旧工程生成缓存和测试输出的可回收备份。
- `archives/`：迁移包和交接包，只归档，不自动覆盖当前工程。
- `assets/art/apocalypse/backgrounds/`：本轮用户提供的三张原创生成背景；庇护所入口与县城市场已接入，工业仓库暂存待后续地点开放。

`project_materials/` 与 `archives/` 已写入 `.gitignore`，并各自包含 `.gdignore`，避免本地素材、私有参考和大型归档被 Godot 资源扫描或误提交。

## 压缩包说明

### `PROJECT_X_APOCALYPSE_2026-08-08.zip`

- 类型：末日主线上下文交接包，不是完整源码。
- 内容：`README.md`、`STATUS.md`、`VERIFICATION.md`、`NEXT_ACCOUNT_PROMPT.md`、`PACKAGE_MANIFEST.md`，共 5 项。
- SHA-256：`52C6B3498F8FEB08C9D84A24F0642E07B9EDC199D195E464819DF2933DB2F279`

### `Project_X_Complete_Migration_2026-08-09.zip`

- 类型：完整工程迁移快照。
- 根目录：`Project X_Migration_2026-08-03/`。
- 内容：源码、场景、美术资源、测试、文档、启动脚本和 Godot 4.7.1，共 1175 项。
- SHA-256：`748562777C2136F5F7835D10F0A28C41CE8B9A28BDF1E8B7567A00EA467BD256`
- 处理：已完成隔离导入、无头启动和全量测试，并提升为当前主工程；原 ZIP 保持原样。

### `Project X_Migration_2026-08-03.zip`

- 类型：较早的完整迁移归档，共 1059 项。
- SHA-256：`888DCC23F0F36A352CB43D525BEA71F589D201011D32AAFBA02E3A5C8CE04DAE`
- 处理：保持 ZIP 原样，未解压合并。

### `Project_X_Live_PreMigration_2026-08-09.zip`

- 类型：本次切换前桌面工程的回滚归档。
- 内容：当前旧工程源码和文档；排除可重新生成的 `.godot/`、`tmp/`、`test_output/`，以及已单独整理的本地素材和迁移归档。
- 处理：保留在 `archives/`，用于需要时恢复迁移前版本。

## 原桌面目录对应关系

- `D:\Archer\Project X Asset Staging` → `project_materials/asset_staging/`
- `D:\Archer\Project X Captures` → `project_materials/captures/`
- `D:\Archer\Project X External Assets` → `project_materials/external_assets/`
- `D:\Archer\Project X Private Sources` → `project_materials/private_sources/`
- `D:\Archer\Project X Temp` → `project_materials/temp/`
- `D:\Archer\Project X_Migration_2026-08-03.zip` → `archives/Project X_Migration_2026-08-03.zip`

项目文档中引用上述旧路径的地方已同步更新。桌面只保留 `D:\Archer\Project X` 这一个 Project X 入口。

当前主工程已经切换到 8 月 9 日完整迁移版本；最新验证结果为 `TESTS_PASSED assertions=925`，默认入口为 `res://scenes/startup/apocalypse_start.tscn`。入口场景为新游戏/继续选择，县域地图 `Market` 标记进入 `res://scenes/reviews/apocalypse_market_review.tscn`。
