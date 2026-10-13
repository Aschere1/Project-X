# Project X

Project X 当前是一款使用 Godot 4.7.1 与 GDScript 制作的单人离线末日生存原型。默认流程采用“静态家园地图热点 + 县域地点选择 + 固定场景搜刮 UI”，不在末日家园中显示可移动头像，也不使用 WASD、碰撞箱或靠近后按 E 的交互方式。

旧牧场/生活模拟代码、测试和素材仍保留为历史原型及可复用领域模块，但不再是默认入口，也不是近期开发路线。不要为了整理工程而删除它们。

外部 AI Coding 内测评审请先看 [启动与评审说明](docs/EXTERNAL_REVIEW.md)。公开仓库使用 `main` 分支，包含可直接导入 Godot 的源码与场景；本机工具、私有素材、个人存档与缓存不随仓库分发。

## 当前可玩闭环

玩家可以从第 1 日开始：

1. 在末日家园点击大门进入县域地图。
2. 进入村卫生室，搜索不同容器；搜索只揭示物资，由玩家逐件领取或全部领取。
3. 在县域地图进入县城市场，搜索柜台和后仓两个独立容器。
4. 进入工业仓库，搜索装卸台和维修笼；燃料、废金属、电线与撬棍使用独立地点状态。
5. 使用 6×4 背包并在家园 8×6 仓储中拖放、叠加、拆分、使用和装备物品。
6. 把燃料、急救包和武器带回家；使用发电机、医疗台和工作台。
7. 在主屋休息推进到下一日。
8. 第 4 日清晨根据三项公开准备结算首轮袭击：电力至少 10、家园急救包至少 1、背包或仓储至少 1 件武器。完成任意 2 项即可守住；准备不足会受伤但仍完成演示流程。
9. 每次关键操作自动保存；首轮袭击结果以及市场、工业仓库的搜索进度可以退出并恢复。
10. 休息进入第 5 日后处理“断续的无线电信号”：消耗 5 电力监听，或登上屋顶并承担疲劳、压力各 +1；处理前不能继续跳日。
11. 休息进入第 6 日后处理“屋檐外的悬包”：承担疲劳、压力各 +1，回收 2 份饮用水；或放弃物资，安全结束事件。两项后果均在选择前公开。
12. 休息进入第 7 日后处理“松动的仓储雨棚”：消耗 1 根电线加固，或徒手转移物资并承担疲劳、压力各 +1；两项后果均在选择前公开，处理后可继续休息并保存。
13. 点击鸡棚或三联牲畜棚进行每日维护：鸡群为 4 只，牲畜为黄牛、山羊、猪各 1 只；维护会消耗真实时间与体力并自动保存。当前明确不产出鸡蛋、奶、毛、肉等物资。
14. 在主屋功能面板选择“进入主屋室内”，可点击床铺、屋内工作台、医疗角、应急电源或出口；行为复用现有休息、制作、治疗和供电规则。

这是“第 1—7 日事件切片演示”，不是完整的 7 日生活系统版。更多地点、NPC、种植/料理、实时战斗和长期剧情尚未完成。

## 启动与验证

项目目录：`D:\Archer\Project X`

- 启动游戏：双击 `启动游戏.bat`
- PowerShell 启动：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_godot.ps1`
- 全量测试：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1`
- 公开版末日回归（无需私有美术）：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1 -PublicReview`
- 项目内 Godot：`tools\godot\Godot.exe`
- 默认主场景：`res://scenes/startup/apocalypse_start.tscn`（继续游戏 / 开始新游戏）

2026-08-20 的最新验证为 `TESTS_PASSED assertions=1133`。独立可视化 E2E 已在隔离存档中完成新游戏、市场/仓库链路、首袭、第 5—7 日事件、安全区设施、自动保存和 Continue 恢复，并保存 34 张逐步画面供人工检查。下一步是完整切片验收与边界清单，不同时展开居民或旧牧场线。

## 操作

- 鼠标左键：选择家园热点、地点和 UI 操作
- 鼠标拖动：整理背包/仓储或跨栏存取
- 鼠标右键：物品操作菜单
- `B`：背包（Backpack）
- `Esc` 或 `P`：系统菜单 / 关闭当前弹窗
- `S`：系统菜单打开时保存（Save）

末日流程没有角色移动按键。

## 接手阅读顺序

1. `handoff/PROJECT_X_APOCALYPSE_2026-08-08/README.md`
2. `HANDOFF.md`
3. `AGENTS.md`
4. `docs/APOCALYPSE_VERTICAL_SLICE.md`
5. `task_plan.md`
6. `progress.md` 的最新章节

关键实现：

- `src/domain/apocalypse/apocalypse_session.gd`
- `src/domain/apocalypse/shelter_facilities.gd`
- `src/world/apocalypse_shelter.gd`
- `src/world/apocalypse_house_interior.gd`
- `src/world/apocalypse_region_map.gd`
- `src/review/apocalypse_explore_review.gd`
- `src/review/apocalypse_warehouse_review.gd`
- `src/world/apocalypse_global_overlay.gd`
- `tests/test_apocalypse_session.gd`
- `tests/test_apocalypse_storage_visual_review.gd`

## 路线边界

近期只扩展末日静态热点式流程。入口、首袭结算、三个正式搜刮地点、第 5—7 日事件与安全区设施基础已经完成；下一阶段进行完整切片验收。NPC、动物生产经济与旧牧场计划继续保持冻结，除非用户明确改变方向。
