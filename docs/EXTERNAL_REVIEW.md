# Project X 外部 AI Coding 内测评审

本仓库提供当前 Godot 末日生存原型的源码、可编辑场景、运行美术、领域测试与开发记录。默认入口为 `scenes/startup/apocalypse_start.tscn`，仓库默认分支为 `main`。

## 启动

1. 克隆 `https://github.com/Aschere1/Project-X.git`，进入仓库目录。
2. 使用 Godot 4.7.1 标准版导入 `project.godot`，等待首次资源导入完成，按 F5 启动默认新游戏/继续入口。
3. Windows 用户也可将 Godot 可执行文件放到 `tools/godot/Godot.exe` 后双击 `启动游戏.bat`。该本机工具目录不随仓库分发；或者设置 `GODOT_EXE` 指向自己的可执行文件。
4. 点击“开始新游戏”，使用鼠标点击家园热点与县域地点。B 打开背包，Esc/P 打开系统菜单。

## 评审路径

- 庇护所 → 大门 → 县域地图 → 村卫生室/县城市场/工业仓库 → 搜索并领取物资 → 返回并整理仓储。
- 家园准备电力、急救包与武器；主屋休息推进日期；检查第 4 日袭击和第 5—7 日公开选择事件。
- 点击鸡棚、三联牲畜棚进行每日维护；主屋面板进入室内，检查床、工作台、医疗角、应急电源与出口。
- 退出后通过“继续游戏”检查物资、地点搜索、事件选择与设施维护恢复。

当前动物设施交付到每日维护基础，界面明确说明蛋、奶、毛、肉等生产链尚未接入。菜地及居民保留未完成边界，详见 `APOCALYPSE_VERTICAL_SLICE.md`。

## 自动验证

先完成 Godot 资源导入，再在仓库目录运行：

```powershell
# 将 GODOT_EXE 设置为自己的 Godot 4.7.1 可执行文件。
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1 -PublicReview
```

隔离可视化 E2E 驱动正式场景和按钮，覆盖新游戏、三个地点、第 4—7 日事件、设施及继续恢复。实现见 `tests/capture_apocalypse_e2e.gd`；设施审查画面见 `review_images/`。

`-PublicReview` 运行当前末日主线与共享时间、存档、库存领域回归。原有不带参数的全量测试继续保留；其中旧牧场视觉回归依赖本地私有素材，在公开克隆中会报告素材缺失，不能把它当成公开版本的验收入口。

2026-10-13 干净公开副本验证：`PUBLIC_REVIEW_TESTS_PASSED suites=21 assertions=783`。本地包含私有素材时的历史全量基线为 1133 条断言；两个数字覆盖范围不同。

## 阅读顺序与发布范围

先读根目录 `README.md`、`AGENTS.md`、`docs/APOCALYPSE_VERTICAL_SLICE.md`，再读 `task_plan.md`、`findings.md`、`progress.md` 和 `HANDOFF.md`。交接文档含历史状态，以最新章节为准。

源码与行为通过稳定 ID 和纯值快照连接；地图热点、布局与美术引用保存为 Godot 场景/资源。旧生活模拟模块作为历史代码保留。

公开版本不包含 `assets/private/`、玩家存档、交接 ZIP、本机工具及缓存。第三方素材来源与许可见 `assets/third_party/`；生成美术来源见 `assets/art/apocalypse/README.md`。本次公开用于项目查看与评审，未新增全仓库开源许可证或商业再分发授权。
