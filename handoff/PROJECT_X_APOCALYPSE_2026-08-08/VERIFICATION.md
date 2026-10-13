# 验证说明

所有命令在以下目录运行：

```text
D:\Project X\Project X_Migration_2026-08-03
```

## 1. 引擎版本

```powershell
.\tools\godot\Godot.exe --version
```

预期包含：

```text
4.7.1.stable.official
```

## 2. 全量自动测试

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1
```

2026-08-08 最新结果：

```text
TESTS_PASSED assertions=895
```

已覆盖的新增闭环证据：

- 首袭准备充分：第 4 日结算为 `held`。
- 首袭准备不足：第 4 日结算为 `overrun`，生命 -20、`raid_wound`、区域威胁 +1。
- 结算消耗最多 5 电力。
- 首袭状态保存与恢复。
- 旧灾变快照缺少 `campaign` 时仍可恢复。
- 家园真实 UI 连续点击休息三次，目标板切换为结算状态。
- 自动保存后清空运行时会话，重新加载仍为第 4 日与同一结局。

## 3. 本地启动

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_godot.ps1
```

或双击 `启动游戏.bat`。

人工检查路径：

1. 家园左上目标板未遮挡热点，字体可读但不突兀。
2. 点击主屋，面板在 480×256 内完整显示标题、说明、发电、医疗、休息、返回按钮。
3. 休息后底部生命/饥饿/口渴/疲劳/体力读取真实会话，不再显示固定演示值。
4. 第 4 日结算页文本没有溢出，目标板切换为“首轮袭击已结算”。
5. B 背包、Esc/P 菜单、S 保存仍可用。
6. 家园热点悬停是低饱和灰绿弱提示，不是亮黄色高光。

当前自动化环境无法获得 Godot 可见窗口句柄，因此本次没有伪造人工视觉验收结果。这 6 项必须由新账号或用户在真实窗口补做。

## 已知非阻塞警告

测试末尾可能出现：

```text
ERROR: Failed to read the root certificate store.
```

当前它不影响 Godot 脚本编译和 `TESTS_PASSED`。如同时出现脚本错误、场景加载错误或 `TESTS_FAILED`，则不能忽略。
