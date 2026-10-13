# Project X 迁移执行计划

目标：以 `Project_X_Complete_Migration_2026-08-09.zip` 为唯一主工程版本，保留当前桌面工程的可回滚归档，并在提升前完成导入、无头启动和自动测试验证。

## 阶段

- [complete] 1. 读取现有计划并完成迁移前检查。
- [complete] 2. 将当前工程源码打包为回滚归档。
- [complete] 3. 在隔离目录解压完整迁移包。
- [complete] 4. 使用迁移包自带 Godot 完成导入、启动和全量测试。
- [complete] 5. 将已验证迁移包提升为主工程，保留本地素材、归档、Git 和回滚资料。
- [complete] 6. 清理迁移临时目录，更新三份规划文档并完成最终校验。

## 安全边界

- 不删除 `archives/`、`project_materials/`、`.git/` 或 `.codex-remote-attachments/`。
- 不覆盖迁移包本身。
- 任何需要覆盖的当前源码都必须先进入回滚 ZIP。
- 不修改游戏玩法代码；本次只切换已验证工程版本和文档状态。

## 验收

- 回滚 ZIP 可以读取，且包含当前工程源码。
- 迁移包 SHA-256 保持不变。
- 迁移包 Godot 版本为 4.7.1 stable。
- 迁移包首次导入成功。
- 全量测试输出 `TESTS_PASSED assertions=895`。
- 默认入口为 `res://scenes/world/apocalypse_shelter.tscn`。
- 主工程不再依赖隔离临时目录。

最终结果：当前主工程已为 8 月 9 日完整迁移版本；隔离目录已送入 Windows 回收站，原始完整包和迁移前回滚包仍在 `archives/`。

## 错误记录

| Error | Attempt | Resolution |
|---|---:|---|
| 当前旧测试包装器返回错误码，但日志显示 `TESTS_PASSED assertions=599` | 1 | 保留为迁移前现状证据；采用完整包内更新后的测试链路重新验证 |
| 解压后的 PowerShell 校验表达式把 `if` 写在字符串连接中 | 1 | 解压本身已成功；改用独立 `Test-Path` 检查，不重复错误表达式 |
| 直接执行 `Godot_v4.7.1-stable_win64_console.exe` 找不到同目录主程序 | 1 | 该文件是控制台启动器；改用迁移包内的 `tools/godot/Godot.exe` 主程序 |
| 首次导入命令的 PowerShell `foreach` 数组括号不匹配 | 1 | 改为先建立 `$dirs` 数组，再执行循环；Godot 尚未启动 |
| 提升镜像过滤器漏排临时目录 `tmp_migration_profile` | 1 | 该目录由本轮验证生成；移除根目录副本，并把旧 `.godot`、`tmp`、`test_output` 移入可回收备份目录 |
| 主工程全量测试在根目录等待超过 120 秒且没有 stdout/stderr | 1 | 临时工程同一测试通过；根目录含本地素材/ZIP资料目录，增加 `project_materials/.gdignore` 与 `archives/.gdignore` 后重新导入验证 |
| 提升迁移包覆盖了本地 `.gitignore` 两条资料目录规则 | 1 | 重新补回 `project_materials/` 与 `archives/` 忽略规则；不影响游戏代码或测试 |
