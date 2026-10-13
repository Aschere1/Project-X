# Project X 进度日志

## Session: 2026-10-13

### GitHub 外部内测公开发布

- **Status:** in_progress
- 用户授权 Project X 与 LifeOS 推送到 `Aschere1` 并公开，两个仓库统一 `main`。
- 已确认账号与仓库权限；Project X 干净副本验证、LifeOS 回归、提交推送与可见性复核进行中。
- 首次本地文件编辑被旧权限阻止；用户更新权限后恢复发布工作。
- 干净公开副本回归通过：21 套件、783 断言；默认启动和 34 步隔离可视化 E2E 通过。新增公开回归入口与评审启动说明，并保留历史私有素材回归。
- LifeOS 干净副本 analyze 无问题、27/27 tests；准备将文字捕获和 schema v2/迁移源码与文档统一推送至 main。

## Session: 2026-08-20

### Phase 7A：安全区设施基础
- **Status:** complete
- 为灾变会话加入独立 `ApocalypseShelterFacilities` 纯领域模块：`main_house`、`chicken_coop`、`livestock_pens` 使用稳定 ID，维护状态保存到根快照 `shelter_facilities`；旧档缺失字段时按读档当天未维护安全恢复。
- 庇护所保存场景新增鸡棚与三联牲畜棚两个可编辑 `Button` 热点，现有主屋的休息/医疗/应急电源入口保留，并从面板新增“进入主屋室内”。未恢复角色行走、碰撞或旧牧场 `HomeRegion`。
- 新建保存的 `apocalypse_house_interior.tscn`：床铺、屋内工作台、医疗角、应急电源和出口均为可在 Inspector 调整的正式热点；背景使用已有本地原创末日室内图，不新建运行时布局。
- 鸡棚每日“整理鸡棚”消耗 10 分钟/1 点体力，三联牲畜棚每日“巡检牲畜棚”消耗 15 分钟/1 点体力；两者明确不伪造鸡蛋、奶、毛、肉、饲料或动物经济产出。
- 验证：Godot 导入成功；全量回归 `TESTS_PASSED assertions=1133`；隔离存档 E2E `APOCALYPSE_E2E_CAPTURE_PASSED captures=34`，新增第 30—34 步覆盖两处设施、主屋室内及清空运行时会话后的恢复。
- 编辑器人工复核：`apocalypse_shelter.tscn/MapHotspots` 中可选中 7 个保存热点；`apocalypse_house_interior.tscn/MapHotspots` 中可选中床、屋内工作台、医疗角、应急电源、出口 5 个保存热点。根证书库读取失败仍是既有、不阻塞的 Windows 环境警告。
- 下一步回到 Phase 7 完整切片验收与保留/调整/删除边界清单；居民、种植、完整动物生产、社交、经济、战斗和旧牧场线继续冻结。

## Session: 2026-08-18

### Phase 6：第 7 日单事件“松动的仓储雨棚”
- **Status:** complete
- 将 `day_seven_shelter_tarp` 接入既有 `get_pending_campaign_event()`、`resolve_pending_campaign_event()`、`rest_at_shelter()` 和 campaign 快照接口。
- 公开两个稳定选择：`repair_shelter_tarp` 消耗家园仓储电线 ×1；`move_shelter_supplies` 不耗电线但疲劳、压力各 +1。无电线时维修选项禁用，徒手搬运作为可用兜底。
- 事件描述读取第 7 日天气文本；pending 阻止再次休息，resolved 结果进入自动保存，旧档缺少第 7 日字段时安全推导 pending。
- 新增领域边界、快照迁移和 wire/manual 两条分支测试；新增可视化回归场景；全量回归从 1036 增至 `TESTS_PASSED assertions=1075`。
- 隔离可视化 E2E 扩展至 29 步：`26_day_seven_event_pending`、`27_day_seven_event_resolved`、`28_day_seven_shelter_updated`、`29_day_seven_state_restored` 均通过人工逐图检查。
- Godot 编辑器导入、无头启动、全量测试和 Windows Compatibility 渲染 E2E 均通过；未触碰项目目录外的用户文件。
- 下一步进入 Phase 7 完整切片验收，整理保留/调整/删除与县域扩展清单；居民、农业、社交、经济、战斗和旧牧场线继续冻结。

## Session: 2026-07-31

### Phase 1：项目基线与工具准备
- **Status:** complete
- **Started:** 2026-07-31
- Actions taken:
  - 完成 74 轮关键产品决策拷问并得到用户最终确认。
  - 确认采用一个主聊天统筹、按模块完整交付的工作模式。
  - 核对 OpenAI curated Skills 与社区 Godot 游戏开发 Skill 仓库。
  - 检查候选仓库的实际目录、许可证及关键 `SKILL.md` 内容。
  - 创建持久化计划、发现和进度文件。
  - 安装并逐项核验 8 个 Godot/游戏开发 Skills。
  - 创建游戏设计总纲、统一术语表、项目索引和三项架构决策记录。
  - 检查基础工具链：Git 可用，Godot/Aseprite 不在 PATH。
  - 初始化本地 Git 仓库；未因缺少提交者身份而伪造初始提交。
  - 使用深模块原则起草 Game Session、内容目录、存档与表现层架构。
  - 用户叫停 C 盘 Godot 下载后立即终止，检查并清理所有本次 C 盘残留。
  - 将 Godot 4.7.1 标准版安装到 D 盘并验证官方构建标识和 SHA-256。
  - 创建最小 Godot 工程、480×270 启动场景和启动自检脚本。
  - 发现自包含模式未覆盖项目运行时 AppData 后，删除 C 盘新建空目录并增加 D 盘启动包装脚本。
  - 通过 D 盘启动脚本重新完成编辑器导入和运行时启动验证。
- Files created/modified:
  - `task_plan.md`（created）
  - `findings.md`（created）
  - `progress.md`（created）
  - `README.md`（created）
  - `CONTEXT.md`（created）
  - `docs/GAME_DESIGN_OVERVIEW.md`（created）
  - `docs/adr/0001-use-godot-4-and-gdscript.md`（created）
  - `docs/adr/0002-single-player-offline-architecture.md`（created）
  - `docs/adr/0003-fork-disaster-timelines.md`（created）
  - `.gitignore`（created）
  - `docs/TECHNICAL_ARCHITECTURE.md`（created）
  - `project.godot`（created）
  - `scenes/bootstrap/bootstrap.tscn`（created）
  - `src/app/bootstrap.gd`（created）
  - `scripts/run_godot.ps1`（created）
  - `docs/TOOLCHAIN.md`（created）

### Phase 2：技术架构与 Godot 工程骨架
- **Status:** in_progress
- Actions taken:
  - 完成技术架构草案；等待 Godot 工具链安装后用运行验证收敛。
- Files created/modified:
  - `docs/TECHNICAL_ARCHITECTURE.md`（created）
  - `src/domain/session/game_rules.gd`（created）
  - `src/domain/session/game_session.gd`（created）
  - `tests/test_harness.gd`（created）
  - `tests/test_game_session.gd`（created）
  - `tests/test_runner.gd`（created）
  - `scripts/test_project.ps1`（created）
  - `docs/TESTING.md`（created）
  - `src/player/player_controller.gd`（created）
  - `src/world/movement_playground.gd`（created）
  - `scenes/player/player.tscn`（created）
  - `scenes/world/movement_playground.tscn`（created）
  - `docs/MOVEMENT_MODULE.md`（created）
  - `src/world/grid_interactable.gd`（created）
  - `scenes/world/grid_interactable.tscn`（created）
  - `docs/GRID_INTERACTION_MODULE.md`（created）
  - `src/world/interaction_indicator.gd`（created）
  - `scenes/world/interaction_indicator.tscn`（created）
  - `src/world/game_clock_controller.gd`（created）
  - `content/rules/default_game_rules.tres`（created）
  - `docs/TIME_MODULE.md`（created）
  - `src/adapters/persistence/timeline_save_repository.gd`（created）
  - `src/adapters/persistence/save_coordinator.gd`（created）
  - `tests/test_save_repository.gd`（created）
  - `docs/SAVE_SYSTEM.md`（created）
  - `src/domain/inventory/item_definition.gd`（created）
  - `src/domain/inventory/item_catalog.gd`（created）
  - `src/domain/inventory/inventory.gd`（created）
  - `src/world/inventory_controller.gd`（created）
  - `src/world/farm_plot.gd`（created）
  - `scenes/world/farm_plot.tscn`（created）
  - `content/items/turnip_seed.tres`（created）
  - `content/items/wild_herb.tres`（created）
  - `content/catalogs/starter_item_catalog.tres`（created）
  - `tests/test_inventory.gd`（created）
  - `tests/test_farm_plot.gd`（created）
  - `tests/test_world_collision.gd`（created）
  - `docs/ITEMS_AND_TOOLS_MODULE.md`（created）
- Actions taken:
  - 完成 Game Session 的第一个垂直模块：新游戏、普通时间推进、体力消耗、睡眠和版本化纯数据快照。
  - 以公开 Game Session 行为作为已确认的测试边界；当前 13 条断言通过。
  - 测试运行脚本显式等待 Godot 子进程，且运行数据仍限制在 D 盘 Godot profile。
  - 建立 5 个具名输入动作，完成 WASD 移动、E 互动、四方向朝向与速度归一化。
  - 创建可复用的 Player 场景和移动灰盒；启动验证输出 `MOVEMENT_PLAYGROUND_READY actions=5`。
  - 保留 Action 名称作为未来手柄、触屏、按键重绑和提示本地化的稳定契约。
  - 完成自由移动下的网格对象交互：世界按角色位置解析邻近目标，分组注册 3 个可复用互动对象。
  - 启动验证输出 `GRID_INTERACTION_READY actions=5 targets=3`；既有会话测试仍为 13 条断言通过。
  - 根据用户反馈将交互改为邻近选中：最近对象在约一格半范围内显示黄色 E 框；无选中目标时 E 不改变状态或显示失败文本。
  - 调整后启动验证输出 `GRID_INTERACTION_READY actions=5 targets=3 selection=true`；既有会话测试仍为 13 条断言通过。
  - 将 Game Session 接入场景运行时：默认规则资源驱动第 1 日 06:00、体力 HUD 和每秒一游戏分钟的室外时钟。
  - P 键暂停会同步暂停时钟和玩家输入；室内 50% 流速作为公开接口等待室内区域模块调用。
  - 启动验证输出 `GAME_CLOCK_READY day=1 time=06:00` 与 `WORLD_READY actions=5 targets=3 selection=true`；既有会话测试仍为 13 条断言通过。
  - 实现普通时间线存档：K 写入手动槽、L 恢复手动槽、120 秒轮换 3 个自动槽；自动槽不会覆盖手动槽。
  - 使用版本化 JSON、临时写入、主文件备份和备份回退；测试使用独立 `user://project_x_save_tests` 根目录。
  - 存档仓储与会话回归测试共 25 条断言通过；场景集成启动无节点路径或解析错误。
  - 建立物品 ID、资源目录、12 格背包、I 键暂停背包和首个锄头行动；F 成功翻土消耗 5 体力和 10 分钟。
  - 将背包与农田状态纳入普通时间线快照；背包、农田、存档与会话测试现共 36 条断言通过。
  - 根据用户的防误触需求，将 K/L 从单格即时存取改为三手动格菜单：保存必须明确选格，读取需选格后再次确认；每格仍保留自己的上一版本备份，三自动格继续独立轮换。
  - 将通用可交互设施根节点改为带 12×12 静态碰撞体的 `StaticBody2D`；料理柜台、信箱等设施阻挡移动，农田明确保持可行走。
  - 增加三手动格独立性与场景碰撞边界测试；存档、会话、背包、农田和碰撞测试现共 51 条断言通过，编辑器导入和启动场景均通过。
  - 完成季节日历与基础天气：每季 28 日，首个原型保留春季前 14 日内容边界；天气按世界种子与日期稳定推导为晴、阴、雨，并在 HUD 显示当天与次日预报。
  - 新增可互动床铺，玩家可进入次日 06:00 并恢复体力；会话快照升级为版本 2，同时兼容版本 1 存档并为其补充默认世界种子。
  - 增加季节日期、天气预报、睡眠跨日和旧快照恢复测试；当前共 59 条断言通过，编辑器导入与启动场景验证通过。
  - 完成住宅室内灰盒：室外入口与室内出口在同一世界场景内切换，室内启用 50% 时间流速，床铺移入室内；进屋不会重置背包、时钟、农田或存档服务。
  - 为互动对象增加 `area_id`，激活区域外的对象会隐藏并关闭碰撞；存档保存当前区域及位置，旧档默认室外。
  - 多区域可复用同一网格坐标，交互注册键升级为“区域 + 格子”；住宅场景、碰撞与既有模块现共 63 条断言通过，编辑器导入和启动场景通过。
  - 完成首个可玩农田循环：芜菁种子播种、每日浇水、三次有效跨日成长、收获入背包；所有农田行动均消耗体力和游戏时间。
  - 新增 `CropDefinition` 数据资源和芜菁内容资源；农田快照升级为版本 2，并兼容原有仅翻土版本 1 快照。
  - 为背包补充安全移除与容量预检，防止体力不足、无种子或背包满时吞掉农田/物品状态；当前共 79 条断言通过，编辑器导入和启动场景通过。
  - 完成六种春季作物资源：芜菁、土豆、卷心菜、胡萝卜、罗勒和草莓；罗勒一次产出两份，草莓首收后可经三次有效浇水跨日复收。
  - 新增 `CropCatalog`，R 输入动作按目录顺序切换当前拥有的种子；背包显示当前种子，耗尽当前种子时自动切到下一种可用种子。
  - 增加六作物目录、草莓复收、种子切换与自动切换测试；当前共 91 条断言通过，编辑器导入和启动场景通过。

## Test Results
| Test | Input | Expected | Actual | Status |
|------|-------|----------|--------|--------|
| 工作区初检 | 列出项目根目录 | 识别既有项目文件 | 目录为空 | ✓ |
| Skill 路径核对 | 打开候选仓库实际 `SKILL.md` | 存在且许可证明确 | Apache-2.0、Godot 4.3+ | ✓ |
| Skill 安装核验 | 检查 8 个安装目录的 `SKILL.md` | 8/8 存在且非空 | 8/8 通过 | ✓ |
| 工具链初检 | 查询 Godot、Aseprite、Git 命令 | 记录可用状态 | Git 可用；Godot/Aseprite 未进 PATH | ✓ |
| Godot 官方版本 | 运行 D 盘 Godot `--version` | 4.7.1 stable | `4.7.1.stable.official.a13da4feb` | ✓ |
| Godot 编辑器导入 | D 盘脚本、headless editor、quit | 退出 0 且无错误 | 退出 0，无错误 | ✓ |
| Godot 启动场景 | D 盘脚本、headless、2 帧 | 输出启动标记 | `PROJECT_X_BOOT_OK viewport=(480, 270)` | ✓ |
| 日历与天气模块 | 自动测试、编辑器导入、场景启动 | 跨日稳定、旧档可恢复、无解析错误 | 59 条断言通过；`WORLD_READY actions=7 targets=4 selection=true` | ✓ |
| 住宅室内区域 | 自动测试、编辑器导入、场景启动 | 室内复用世界服务、区域对象无冲突 | 63 条断言通过；`WORLD_READY actions=7 targets=6 selection=true` | ✓ |
| 芜菁农田循环 | 自动测试、编辑器导入、场景启动 | 播种浇水跨日成熟收获、状态安全 | 79 条断言通过；`WORLD_READY actions=7 targets=6 selection=true` | ✓ |
| 六种春季作物 | 自动测试、编辑器导入、场景启动 | 资源选择、复收作物与安全切换 | 91 条断言通过；`WORLD_READY actions=8 targets=6 selection=true` | ✓ |
| D 盘数据约束 | 检查 D profile 与 C AppData | 数据仅在 D 盘 | D profile 存在；C Godot 目录不存在 | ✓ |
| 文档完整性 | 检查 11 个 Markdown 文件 | 非空且内部链接有效 | 0 空文件、0 断链 | ✓ |
| 安装包清理 | 检查 C/D 临时 ZIP | 下载包均已删除 | C/D 均无 Godot 下载 ZIP | ✓ |

## Latest Module Update

- 2026-08-01：根据实机反馈修复矿石镇主角左右方向：原始侧向帧本身朝右，现改为向右不翻转、向左 `flip_h`；新增左右翻转断言防止再次回归。
- 2026-08-01：接入用户提供的1024×704《矿石镇》春季牧场整图。地图保持原尺寸并由Camera2D滚动显示；新游戏从住宅门外开始，住宅、鸡舍、田地、树和池塘交互点已对齐。
- 2026-08-01：春季地图增加主要建筑、池塘、树干、左侧水域和底部水域粗碰撞；进入住宅时相机恢复480×270固定范围。地图存在时隐藏重复的Kenney设施图标，未翻土农田融入原田地，实际翻土后再显示状态。
- 2026-08-01：接收用户提供的《牧场物语：矿石镇》主角动作表，仅用于个人本地版本。原始 GIF 已备份到 `D:\Archer\Project X Private Sources\mineral_town_player`；项目内生成 96×96 透明行走图集，包含向下、向上、侧向各 4 帧。
- 2026-08-01：玩家场景接入可选 `AnimatedSprite2D`，移动时播放 7 FPS 行走动画，停止时保持对应朝向待机，向右通过无损水平翻转侧向帧；私有图缺失或加载失败时自动显示原 CC0 占位角色。
- 2026-08-01：矿石镇主角本地行走动画完成验收。176 条自动化断言通过，编辑器导入和主场景启动无错误；普通 OpenGL 实机帧确认私有主角生效、蓝底透明、脚底与碰撞体对齐、E 交互框清晰。人物尺度同时证明后续建筑与设施需改为多格矿石镇式贴图。
- 2026-07-31：完成第一批基础像素贴图接入。采用 Kenney Tiny Town 与 Tiny Dungeon 的 16×16 CC0 原图，替换室外草地、玩家、信箱、房门、料理柜台、两个采集点、钓点和鸡舍表现；互动、碰撞和存档数据未改变。
- 2026-07-31：新增可替换 `visual_texture` 表现接口、私有素材忽略目录、两份原始许可证、素材来源/哈希清单和公开素材调研；《矿石镇》原图仅在用户自行提供合法本地文件后进入 `assets/private/`，不会从第三方提取站下载或进入可公开资源目录。
- 2026-07-31：实机帧检查发现 Kenney 草地图块边缘形成明显棋盘线，已改为连续草色底叠加局部草叶/花草，保留 16×16 逻辑网格但不把网格画进地图。
- 2026-07-31：第二次实机帧确认残余棋盘线来自旧灰盒调试网格绘制，现已移除；同时缩短顶部快捷键提示，避免与体力 HUD 重叠。
- 2026-07-31：基础像素贴图模块最终验收完成。172 条自动化断言通过，Godot 编辑器导入无错误，主场景输出 `WORLD_READY actions=15 targets=10 selection=true`；普通 OpenGL 录制帧确认草地连续、贴图对齐、HUD 可读和交互框清晰。
- 2026-07-31：完成鸡舍与动物性食材来源模块。室外固定鸡舍与母鸡“小麦”已接入收蛋→喂食→抚摸→状态的上下文 E 交互；新游戏提供 14 份鸡饲料，喂食决定次日产蛋，连续 3/7 天完整照料分别产银星/金星蛋。
- 2026-07-31：鸡舍保存当日喂食/抚摸、连续照料和逐枚待收鸡蛋品质；旧档缺少字段时从读档当天的未照料空鸡舍开始。雨天无惩罚，断粮只暂停产蛋并重置连续照料。新增 18 条鸡舍断言；当前共 164 条断言通过，Godot 导入及 `WORLD_READY actions=15 targets=10 selection=true` 启动验证通过。
- 2026-07-31：启动鸡舍与动物性食材来源模块；确认采用固定灰盒鸡舍、单只鸡、收蛋→喂食→抚摸的上下文 E 互动，以及断粮不死亡的普通模式规则。
- 2026-07-31：完成 `ChickenDefinition` 与 `ChickenCoop` 运行时状态，实现每日喂食、抚摸、断粮暂停产蛋、连续照料品质阈值和逐枚鸡蛋品质快照；主场景已接入初始 14 份饲料和固定鸡舍。
- 2026-07-31：完成食材来源与天气作用模块。室外增加两个每日采集点和一个每日三次的简易钓点；晴/阴/雨分别驱动不同的野菜、蘑菇和鱼类产出，所有奖励与世界种子、日期、点位和天气确定性绑定。
- 2026-07-31：雨天会在跨日成长结算前自动浇水；采集日期和钓鱼次数已进入普通时间线互动快照，旧档缺失字段时安全恢复为未使用状态。新增 6 种食材、天气奖励资源、点位场景和 33 条相关断言；当前共 146 条断言通过，Godot 导入及 `WORLD_READY actions=15 targets=9 selection=true` 启动验证通过。
- 2026-07-31：启动“食材来源与天气作用”完整模块；已审计天气、跨日、农田、背包、互动和存档边界，确定结算顺序为旧日雨水浇水 → 农田成长 → 新日采集/钓鱼刷新。
- 2026-07-31：完成料理品质、稀有度与首批招牌料理。背包升级为同物不同品质分栈并在普通时间线中保存；料理根据实际消耗食材品质生成普通、银星或金星成品，罗勒与野生香草分别提供少见/珍稀输入。
- 2026-07-31：新增春野浓汤与野香烤根茎两种独立招牌物品；料理笔记升级为版本 2，保存品质、稀有度和招牌标记，同时兼容版本 1 笔记和背包快照。新增品质分栈、旧快照迁移、实际消耗顺序、招牌规则测试，当前共 113 条断言通过。
- 2026-07-31：完成个人料理笔记与一键装填模块。N 可从探索或料理面板打开笔记；按钮和 W/S/E 键均可浏览、装填和关闭。装填只恢复组合，实际烹饪才消耗食材、体力和时间。
- 2026-07-31：笔记快照现在规范化为纯字符串并在恢复时验证所有字段，避免损坏条目污染当前会话；新增条目读取、越界读取和损坏快照测试，当前共 102 条断言通过。
- 2026-07-31：完成自由料理首个可玩闭环。料理柜台可暂停世界并用四类厨具、主食材与香草调味组合出蔬菜汤、香草沙拉、烤根茎、失败料理或黑暗料理；成功料理扣 3 点体力并推进 15 分钟。
- 2026-07-31：料理笔记作为独立版本化快照写入普通时间线；旧档缺少该字段时恢复为空笔记。补齐料理控制器的时钟路径与存档路径，并把所有料理输入动作纳入场景启动自检。
- 2026-07-31：修复香草类食材被当前食材轮换排除、导致无法设为调味的问题；新增烤根茎与失败料理规则测试。

## Error Log
| Timestamp | Error | Attempt | Resolution |
| 2026-08-01 | PowerShell `New-Object Bitmap` 将 PixelFormat 枚举当成字符串，透明图集画布创建失败并产生空引用 | 1 | 确认没有输出坏 PNG，改用 `[System.Drawing.Bitmap]::new(...)` 和 `$ErrorActionPreference='Stop'`，成功生成图集 |
| 2026-08-01 | 春季地图视觉隐藏补丁使用了不存在的农田工具常量上下文，未能应用 | 1 | 读取真实农田、鸡舍和通用互动脚本后拆分精确补丁，未产生部分修改 |
| 2026-07-31 | 基础贴图接入大补丁假设世界脚本含 `class_name MovementPlayground`，上下文不匹配而未应用 | 1 | 读取真实文件头后拆成脚本、玩家与场景小补丁，全部成功应用 |
| 2026-07-31 | `--headless --write-movie` 在 dummy renderer 请求纹理时触发 Godot 4.7.1 原生崩溃 | 1 | 改用普通 OpenGL Compatibility 渲染器录制 3 帧；成功生成 PNG 并完成视觉检查 |
| 2026-07-31 | 新增草地 PNG 首次导入与测试并行，测试包装器先打印通过但世界脚本因资源尚未导入而解析失败 | 1 | 改为编辑器导入 → 测试 → 启动的严格顺序；后续新增资源不再与首次导入并行 |
| 2026-07-31 | 鸡舍 `pop_front()` 返回值在严格模式下被推断为 Variant，旧测试未加载新脚本但场景导入失败 | 1 | 显式声明 `int`，并把鸡舍测试加入测试运行器以覆盖新脚本 |
| 2026-07-31 | 食材来源计划首次补丁使用不精确上下文，`apply_patch` 未应用 | 1 | 读取实际文件尾部并拆分为精确小补丁，后续修改成功 |
| 2026-07-31 | 料理笔记恢复校验只接受 String，但内存快照还保留 StringName，导致同一进程内的快照恢复失败 | 1 | 记录时将食材 ID 规范化为纯 String；内存快照与 JSON 存档保持同形 |
| 2026-07-31 | 笔记校验为缺失字段提供默认值，错误地接受了不完整条目；测试工具也没有 `expect_false` | 1 | 要求四个字段完整存在后再校验类型，测试改用现有 `expect_true(not ...)` 接口 |
|-----------|-------|---------|------------|
| 2026-07-31 | `git status`：当前目录不是 Git 仓库 | 1 | 记录现状，暂不重复；工程骨架阶段再处理 |
| 2026-07-31 | OpenAI Skills `skills/.experimental` 路径不存在 | 1 | 使用 curated 清单与检查过的社区仓库 |
| 2026-07-31 | PowerShell `foreach` 后直接接管道产生 `EmptyPipeElement` | 1 | 改为先收集结果变量，再格式化输出 |
| 2026-07-31 | `git config --get user.name/user.email` 未配置，组合命令返回 1 | 1 | 保留已成功初始化的仓库，不伪造身份或创建提交 |
| 2026-07-31 | Godot 目标错误选择在 C 盘 | 1 | 立即终止；安装目录未创建；删除 C:\tmp 临时 ZIP；改用 D 盘 |
| 2026-07-31 | 沙箱内首次删除 C:\tmp 临时 ZIP 访问被拒绝 | 1 | 通过批准的提升权限删除并验证无残留 |
| 2026-07-31 | Godot 直接运行项目时仍在 C 盘创建空 `app_userdata` | 1 | 删除空目录并添加仅作用于子进程的 D 盘目录重定向脚本 |
| 2026-07-31 | D 盘日志检查脚本重复使用 `foreach {...} |` 错误模式 | 2 | 改为 `$matches = foreach (...) {...}` 后再输出，禁止第三次重复 |
| 2026-07-31 | 无编辑器测试时，跨脚本 `class_name` 注册顺序导致 Game Session 测试解析失败 | 1 | 测试和会话边界改为显式预加载、公开实例方法和资源接口，避免依赖全局类注册时序 |
| 2026-07-31 | `quit(1)` 未可靠传递 Windows Godot 脚本模式退出码，旧日志还会造成误判 | 1 | 测试脚本先清理本项目 D 盘日志，再以当次 `TESTS_PASSED/FAILED` 标记判定结果 |
| 2026-07-31 | Godot 图形可执行文件从 PowerShell 异步脱离，留下测试进程并锁住日志 | 1 | 已核对并结束本项目残留进程；启动/测试脚本改用 `Start-Process -Wait` |
| 2026-07-31 | GDScript 将从 Variant 推断的局部变量当作错误 | 1 | 为体力消耗结果补充显式 `int` 类型，后续避免未标注的 Variant 推断 |
| 2026-07-31 | 网格交互表从字典读取目标时被推断为 Variant，触发严格类型解析失败 | 1 | 将读取结果显式标为 `GridInteractable`，编辑器导入和场景启动均已通过 |
| 2026-07-31 | 缺失的存档仓储预加载及不匹配构造参数使 Godot 测试脚本未正常载入，并留下等待超时进程 | 2 | 补齐最小仓储构造入口；已核对并结束两次本项目测试进程，之后红灯和绿灯均正常退出 |
| 2026-07-31 | 自动存档槽数组没有静态元素类型，触发严格类型解析失败 | 1 | 显式声明 `Array[String]` 与当前槽 `String` 类型，编辑器导入通过 |
| 2026-07-31 | 农田工具结果缺少收窄类型、资源目录使用强类型数组导致 `.tres` 反序列化失败 | 1 | 显式转换为 `FarmPlot`；资源容器改为 `Array[Resource]` 并在运行时校验 ItemDefinition |
| 2026-07-31 | 未进入场景树的农田单元测试节点在退出时产生 CanvasItem 泄漏警告 | 1 | 测试结束显式释放临时节点，后续 36 条断言运行无泄漏警告 |
| 2026-07-31 | 存档菜单首次接入时 `slot_menu_overlay` 拼写为未声明的 `_slot_menu_overlay` | 1 | 编辑器导入立即定位并修正；随后测试、导入和启动均无解析错误 |
| 2026-07-31 | 室内床铺与室外柜台复用了同一网格坐标，触发重复交互格断言 | 1 | 注册键改为区域加网格；修复后 63 条断言、编辑器导入和场景启动均通过 |
| 2026-07-31 | 直跑测试在编辑器扫描前解析 `FarmPlot`，找不到新作物全局类 | 1 | 农田显式预加载作物脚本并运行时校验资源，不再依赖全局类注册顺序；79 条断言通过 |
| 2026-07-31 | 农田测试尝试手动释放 `RefCounted` 作物资源 | 1 | 移除无效 `free()`；后续测试与启动无资源释放错误 |
| 2026-07-31 | 扩展种子切换测试时，普通字典不能赋给强类型导出字典 | 1 | 测试夹具改为 `Dictionary[StringName, int]`；91 条断言通过 |
| 2026-07-31 | 场景脚本遗留固定芜菁作物引用，阻断六作物启动验证 | 1 | 改为使用当前选择种子解析的作物资源；编辑器导入和启动均通过 |
| 2026-08-01 | 主角 Walk 图集意外变为 86×86，运行时仍按 24×32 帧采样，并且旧切片混入相邻帧碎点 | 1 | 从项目外原始 GIF 无损重建 96×96 图集；上下行走帧只保留主体与脚下阴影，清除其他独立像素块 |
| 2026-08-01 | 春季牧场集成测试在 `SceneTree._init()` 内访问尚未建立的根节点，包装器先打印通过并伴随脚本错误 | 1 | 测试入口改为 deferred 执行；重新运行得到无脚本错误的 184 条断言通过 |
| 2026-08-01 | 私有春季牧场只隐藏旧灰盒交互物体的画面，仍保留旧物体的互动注册和碰撞，形成隐形互动和隐形墙 | 1 | 地图模式改为仅启用有可见地图对应物的门、田地、鸡舍；旧网格物体关闭自身碰撞，由地图建筑/水域碰撞统一负责；188 条断言通过 |
| 2026-08-01 | 一键启动入口首次通过旧启动脚本传递带空格的项目路径时，Godot 将后续参数误并入路径 | 1 | 启动脚本改为 PowerShell 原生参数数组调用；通过 `启动游戏.bat --headless --quit-after 2` 和全量测试验证 |

## 2026-08-01：原创方向重新对齐

- 使用 `grilling` 逐项确认核心原创、最低美术完成线、技术规格、私有白名单、首张地图范围、瓦片/精灵分工、角色参考方式、美术生产流程与现有代码保留策略。
- 使用 `codebase-design` 将现有农业、料理、时间、存档、背包和动物识别为继续保留的领域模块，将地图、贴图、碰撞和坐标识别为需要替换的表现 adapter。
- 将下一模块从“基础商店”改为“原创家园垂直切片”。
- 新增根级 `AGENTS.md`，把当前 Phase、原创素材政策、私有白名单、模块完成定义和 Skills 路由固定为后续代理规则。
- 重写 `task_plan.md`，形成 Phase 0–8 的正式路线和防偏差 Stop Rules。
- 本轮未修改游戏运行代码，也未删除或移动任何私有素材。

## 2026-08-01：Phase 1 原创家园垂直切片

- **Status:** complete
- 启动 Phase 1，并重读根级代理规则、总计划及 ImageGen、TileMapLayer、节点/场景和 GDScript Skills。
- 内置 imagegen 原创概念板请求因网络错误失败，未产出文件；依据 Skill 规则未自动切换到需要 API Key 的 CLI。
- 决定继续使用已确认的原创角色设定、调色板和像素规格，直接制作可运行的低分辨率像素图集；概念板留作后续非阻塞重试。
- 新增可复现的原创像素素材生成流程，产出家园地形图集、24×32 主角三方向四帧行走、农舍、鸡舍、树木和家园道具；建立 `ART_BIBLE.md` 与素材清单。
- 新建 60×34 格 `HomeRegion`，用 Ground、Terrain、Objects、Foreground 四个 `TileMapLayer` 组织草地、道路、有限农田、池塘、围栏与装饰；特色建筑和树木保持独立 Sprite。
- 家门、首块农田与鸡舍是仅有的三个 Phase 1 交互目标；建筑、池塘、树木和地图边界均有与画面对应的结构碰撞，正式场景不加载矿石镇整图、原主角或旧地图交互坐标。
- 一键启动入口已切换至 `HomeRegion`，旧 `movement_playground` 保留为原型与回归测试场景。
- 新增 18 条家园断言，累计 206 条断言通过；Godot 编辑器导入、无头启动与普通 OpenGL 画面录制均通过。
- 实机审查发现初始镜头遮挡屋顶和农田旧占位绘制未完全关闭，已修正镜头上移与地图型农田隐藏策略后重新通过全部验证。
- 最终验收帧：`D:\Archer\Project X Captures\phase1_home_final\frame00000002.png`。
- `code-review` 固定点流程因仓库尚无首个提交而无法生成 Git 差异，改为对照 `AGENTS.md` 和 Phase 1 规格直接审查本次文件；修复上述两项问题后未发现阻断项。
- 后续试玩反馈修复：树叶和房顶原先始终绘制在角色下方，导致角色像踩在图层上；现根据玩家所在遮挡矩形动态提升树、农舍与鸡舍的前景层级，并降至 48% 不透明以保持可读。
- 后续试玩反馈修复：农舍、鸡舍、树与池塘碰撞从大致视觉矩形收紧为墙体底部、树干和实际水面；新增精确尺寸断言。池塘改用四种深浅与波纹水瓦片混合，新增水面变体断言。当前 213 条断言通过，普通 OpenGL 实机启动通过。
- 新增 `docs/HOME_REGION_EDITING.md`，说明如何在 Godot Inspector 打开可视碰撞、直接调整 Position/Shape Size，以及如何调整遮挡矩形和水面图集。
- 新增 `sprint` 输入动作，默认绑定 Shift；玩家按住时移动速度从 80 提升至 120，行走动画同步提升 35%。新增输入绑定、速度和动画倍率断言；全量测试现为 220 条通过，Godot 导入和启动验证通过。
- 2026-08-01：启动 Phase 2 家园生活闭环。正式 `HomeRegion` 已接入日历、天气、时钟、体力、在家休息跨日、背包、三格手动存档与轮换自动存档；K 选择存档格、L 选择并确认读取，I 打开背包。
- 2026-08-01：将六种春季作物的既有领域规则接入正式农田，新增可复现的原创四阶段作物精灵图（翻土、嫩芽、生长、成熟），不再由正式场景绘制交互色块。
- 2026-08-01：鸡舍的 E 互动已接入喂食、抚摸、隔日产蛋、品质累积与背包收取；新角色“小麦”不会因断粮死亡，断粮只使次日跳过产蛋。当前 229 条自动化断言通过，Godot 编辑器导入、无头启动与 OpenGL 实机截图均通过。
- 2026-08-01：根据新实机截图收紧建筑和树木的遮挡区域：只在玩家脚底真正位于屋后或树冠后方时淡化，门前、墙前不再误触半透明。池塘碰撞由 112×112 扩大为 124×136，更贴近实际水面并保留窄岸边。回归测试增至 234 条，实机帧确认门前农舍保持不透明。
- 2026-08-01：确认不购买付费美术包。开发期只使用许可清晰的免费素材作为可替换表现层，后期按区域逐步自制替换；优先评估 Serene Village Revamped 免费外景与 Cozy Farm 免费非商业农业/动物素材，不扩大到多套混搭。
- 2026-08-01：下载并校验 Serene Village Revamped（CC BY 4.0）、Puny World（CC0）与 Kenney Pixel UI Pack（CC0）；原始包和解压副本均放在 D 盘外部素材库，项目不保存整包。
- 2026-08-01：仅导入 Serene Village 的一张 16×16 图集至 `assets/third_party/limezu_serene_village/`，新增独立 `serene_art_review.tscn` 和来源/哈希记录，用于在 480×270 下评估建筑、树木与水岸。Godot 导入、预览场景无头启动和全部 234 条回归断言均通过；`HomeRegion` 未被改动。
- 2026-08-01：池塘首轮错误混用了 Serene Village 的预拼水岸与 Puny World 的装饰水格，导致重复出现半截岸边和睡莲。现已固定为用户截图左上角对应的 Puny World CC0 纯水格 `(8,11)`，并新增断言禁止其他水底坐标；岸边、池塘碰撞、交互和存档均维持原有实现。
- 2026-08-01：树木区按 16 像素网格复核后，确认主体树精灵为 32 像素宽；在用户视觉验收后，将 64 像素高度缩为 48，去除底部脱离树干的叶片。三棵树现使用已登记 Serene Village CC BY 4.0 图集区域 `Rect2(176,192,32,48)`；树干碰撞、树冠淡化和交互保持原值，并新增来源与区域回归断言。
- 2026-08-01：根据试玩反馈，32×48 的树精灵在家园中偏小；视觉层已等比放大为 1.5 倍并上移 12 像素，树根仍对齐原 12×12 树干碰撞，交互和遮挡规则保持不变。
- 2026-08-01：用户决定暂停树根碰撞与其余美术微调，后续统一处理；开发队列切回功能模块“食材来源与天气作用”。
- 2026-08-01：在开始下一功能模块前，根据新反馈将三棵树的树干碰撞从 12×12 收紧至 8×8；仅影响树根脚底可走范围，不改美术、遮挡或其他物体。
- 2026-08-01：完成“食材来源与天气作用”正式接入。HomeRegion 新增草地采集点（每日一次）和池塘钓点（每日三次）；二者按既有天气表给出可复现的食材/鱼类，并将当天状态纳入存档快照。雨天继续在作物成长前自动浇灌，HUD 同步说明该效果。为避免隐形交互，采集点显示蘑菇、钓点显示岸边木牌；实机近景确认交互提示可见。回归测试增至 249 条。
- 2026-08-01：完成“正式料理台与料理面板”接入。家园新增可见的露天料理台，按 E 打开暂停式料理面板；玩家可沿用 C/T/G/H/J/U 的既有厨具、食材、调味、烹饪和清空操作，E 关闭并恢复行动。新增正式场景交互/关闭回归断言与 `home_cooking_review` 视觉验收场景；全量测试现为 253 条通过。
- 2026-08-01：完成“料理食材来源与分类”。可料理物品现以资源字段标注农田、采集、钓鱼或动物来源；料理面板新增 V 分类筛选，并显示当前食材的取得提示与每日限制。钓鱼分类的实机画面已验收；全量测试现为 261 条通过。
- 2026-08-01：用户确认整套采用 Godot Asset Store 的 `Super Retro World - Farming v1.0.3` 作为开发期统一画风。原包下载至 D 盘外部素材库并通过 SHA-256 校验；292 张 PNG 和许可证的运行副本进入 Git 忽略的私有目录。新增覆盖/缺口矩阵，明确畜牧、料理、钓鱼、头像、UI、经营和末日内容需要按同画风扩展。首轮表现 Adapter 已让玩家、农舍和树木在私有包存在时使用新基线，缺包时继续安全回退。
- 2026-08-01：按新 PNG 的真实底边同步校准表现与玩法判定：农舍改为 120×16 底墙碰撞并把家门交互点上移到门外；树木改为 8×6 根部碰撞并上移到根部像素内；树冠与屋顶遮挡区域在碰撞顶边结束。玩家继续使用 12×10 脚底碰撞。266 条自动化断言、Godot 4.7.1 编辑器导入、普通 OpenGL 实机帧和碰撞调试帧全部通过；验收帧位于 `D:\Archer\Project X Captures\super_retro_baseline\frame00000002.png` 与 `D:\Archer\Project X Captures\super_retro_collision_review\frame00000002.png`。
- 2026-08-02：修复 Super Retro 玩家动画取帧：每个方向实际为每套肤色 3 帧，不是连续 6 帧；待机固定使用中间站立帧，行走不再跨入相邻肤色。HUD 移除常驻操作说明和底部常驻对话，Esc/P 设置页集中显示操作，动作反馈仅临时出现。
- 2026-08-02：停止用运行时代码生成正式家园地图。Ground、Terrain、Objects、Foreground、岩石、建筑、角色、交互物和碰撞已统一保存在完整的 `scenes/world/home_region.tscn`，可在一个 Godot 2D 界面中整体构图；不再使用只能看到地形的独立地图入口。新增并修复 `编辑家园地图.bat`，双击直接打开完整家园场景。纯草改用完整不透明格 `(18,30)`，不再把带固定小花的四格纹理铺满地图。Godot 导入和 283 条自动化断言通过；实机验收帧为 `D:\Archer\Project X Captures\authored_home_map\frame00000002.png`。
- 2026-08-02：修复编辑入口因 `%~dp0` 尾部反斜杠导致 Godot 项目路径解析失败的问题，并把入口目标从纯地图改为完整 `home_region.tscn`。农舍、树和玩家当前外观也直接保存进场景，编辑器中不再等到运行后才替换贴图。新增完全新手版 `docs/VISUAL_GAME_EDITING.md`，涵盖界面、地图四层、Terrain、建筑/交互/碰撞联动、保存试玩和错误恢复。实际入口进程保持运行，编辑器导入和 283 条断言再次通过。
- 2026-08-02：为新窗口建立根级 `HANDOFF.md`，汇总产品决策、Phase 2边界、工程入口、领域/表现分层、素材许可、操作说明、下一模块与验证流程。交接前复跑发现最新可视化场景保存后测试与场景发生漂移：主场景仍可无头启动，但自动测试为8项失败，缺少 `StarterField` 与 `ForageMeadow`，并且地面格数、建筑/池塘/树碰撞及家门位置不同于旧断言；场景还新增5个围栏碰撞。该状态被明确视为需保留核对的用户编辑，新窗口第一任务是先视觉校准并恢复Phase 2测试，而不是回退旧场景或提前扩展其他模块。
- 2026-08-02：用户进一步确认“可视化优先”为硬性制作规则：凡Godot能够直接编辑的地图、瓦片、节点摆放、出生点、碰撞、交互范围、遮挡、动画、UI布局和策划参数，正式内容必须保存在可视场景或资源中，不再由运行时代码生成或脚本硬编码；代码只承担行为、领域规则、状态、存档、校验和真正动态效果。该规则已同步写入 `AGENTS.md`、`task_plan.md` 和交接文档。

## 2026-08-02 本次会话

- 已完整阅读 `HANDOFF.md`，并复读 `AGENTS.md`、`task_plan.md`、`CONTEXT.md`、家园编辑和测试文档。
- 已读取 `planning-with-files`、`codebase-design`、`godot-nodes-scenes`、`godot-tilemap` 与 Windows 应用操作规范；本次修改将保持场景作为正式表现来源，避免新增浅层管理器或把坐标写入代码。
- 已建立本次校准计划。当前基线测试结果为 `TESTS_FAILED count=8`；无头主场景可启动并输出 `HOME_REGION_READY size=960x544 interactables=4`。
- 已确认失败由最新场景与旧断言漂移共同造成：缺少 `StarterField`/`ForageMeadow`、互动目标为 4、Ground 为 3772 格，以及 6 组碰撞/家门位置差异。下一步为场景证据检查，不直接恢复旧数值。
- 已完成场景校准：补回 `StarterField` 与 `ForageMeadow`，保留用户场景绘制和新增围栏；将测试改为验证可玩 60×34 范围而非绑定 Ground 总格数，并按可见底边收紧 4 类碰撞与家门交互点。
- 场景校准验证通过：Godot 导入、`TESTS_PASSED assertions=285`、无头启动和编辑器视觉检查均通过。下一阶段转入正式 `HomeRegion` 料理笔记 Overlay。
- 已将旧原型料理笔记的表现迁入正式 `home_region.tscn`：Overlay、按钮和文字布局作为场景节点保存；`home_region.gd` 仅接入打开/关闭、浏览、装填和暂停状态。
- 已添加正式场景回归：空笔记禁用装填、探索打开、料理面板内打开并返回、装填不消耗背包；测试结果为 `TESTS_PASSED assertions=296`。
- 已完成 Godot 导入和无头主场景启动验证；下一步是正常窗口视觉检查与连续多日存档/跨日试玩。

## 2026-08-02：UI 与设置界面优化

- 已检查项目内与项目外的候选 UI 素材；Kenney Pixel UI Pack 暂不混入正式场景，避免破坏当前统一画风。
- 已在 `home_region.tscn` 中保存统一 Theme/StyleBoxFlat，并应用到顶部 HUD、消息、背包、料理、料理笔记、存档和设置面板。
- 已把设置页重做为正常暂停菜单：`设置` 标题、暂停说明、左右双列操作、中央分隔线和独立继续游戏区域；布局仍是 Godot 场景节点，可直接拖动和调整。
- 已给背包和料理面板补充标题、副标题、分隔线和可点击关闭按钮；快捷键行为保留。
- `home_settings_review.tscn` 实机视觉检查确认设置页无文字叠压；测试断言增至 307 条，导入、自动测试和无头启动通过。

## 2026-08-02：料理笔记与存档菜单主题复核

- 在正式 `home_region.tscn` 中补齐料理笔记标题区、说明、分隔线、状态文本留白和底部按钮间距。
- 在存档菜单中补齐分隔线与返回提示，并把面板高度调整为能容纳标题、存档格、确认区和底部提示的单一菜单结构。
- 新增 6 条 UI 回归断言，结果为 `TESTS_PASSED assertions=313`；`home_cooking_review.tscn` 无头启动通过。
- 已尝试使用 Godot 普通窗口做视觉捕获；当前 Computer Use 对 Godot 窗口边框句柄返回 `SetIsBorderRequired` 系统兼容错误，因此本轮未宣称新增截图验收通过。已有 `home_settings_review` 视觉基线保持不变。

## 2026-08-02：Phase 2 跨日与保存恢复

- 新增正式 HomeRegion 多日回归：第 1 日完成浇水、采集、钓鱼、鸡舍照料和料理笔记记录后保存；连续睡眠至第 3 日，确认作物成长、鸡蛋生成、采集/钓鱼每日刷新；释放旧场景后用新 HomeRegion 实例读回第 1 日快照。
- 测试首次发现料理笔记经过 JSON 存档后，整数型品质/稀有度可能表现为浮点数，导致 SaveCoordinator 拒绝完整快照；已在 `src/domain/cooking/cooking_notebook.gd` 做数值合法性检查与整数规范化。
- 验证通过：`scripts/test_project.ps1` 输出 `TESTS_PASSED assertions=342`；正式家园无头启动输出 `HOME_REGION_READY size=960x544 interactables=6`；料理审查场景输出 `HOME_COOKING_REVIEW_READY`。
- Phase 2 的自动化跨日/重启恢复项已完成；仍保留“普通窗口视觉检查与人工连续多日试玩”待用户可视化验收，未将系统兼容错误包装为截图通过。

## 2026-08-02：农田 Super Retro 视觉与多格布局

- 已核对正式资源覆盖：Super Retro 当前覆盖正式 TileSet、农舍、树、岩石、玩家和本轮新增作物视觉；鸡、鸡舍构件、采集/钓鱼/料理台标记仍属于待替换缺口，未宣称全量统一。
- 已将正式 FarmPlot 从旧 `mineral_town_crops` 图集切换为可替换的 `CropVisualCatalog` Resource，六种春季作物映射到 Super Retro `crop_*.png`，代码只根据成长阶段读取表现资源。
- 已在 `home_region.tscn` 的 `FarmPlots` 节点中保存 219 个独立 FarmPlot 实例，加上 `StarterField` 组成 20×11 农田网格；每格与 TileMap cell center 对齐，用户可在 Godot 2D 视图中直接选择和移动。
- `HomeRegion` 从场景树交互组收集嵌套农田，未增加任何运行时代码坐标生成；编辑入口已打开完整家园场景供继续可视化调整。
- 验证通过：`scripts/test_project.ps1` 输出 `TESTS_PASSED assertions=346`；正式场景无头启动输出 `HOME_REGION_READY size=960x544 interactables=225`。

## 2026-08-02：HomeRegion 交互标记统一

- 料理、采集、钓鱼三个交互点已经在正式 `home_region.tscn` 中换成 Super Retro 的锅、盆栽和水面纹理，避免基础地图统一后仍混用 Kenney 小图标。
- 资源包没有合适的鸡素材，因此保留 `StarterHen` 的原始鸡图；鸡和鸡舍内部构件列为明确缺口，不用鸟类或无关道具冒充。
- `scripts/test_project.ps1`：`TESTS_PASSED assertions=349`；正式 HomeRegion 无头启动：`HOME_REGION_READY size=960x544 interactables=225`。
- 鸡舍外部建筑已从偏商铺的 Super Retro 变体改为更接近木质农舍的 `house_05.png`；交互实例内部的 Kenney 原型构件在正式家园中由现有 suppression 逻辑隐藏，不再与外部建筑重叠。

## 2026-08-02：水池边缘与农田状态视觉回归

- 修正钓鱼点水面标记向上多出一格的问题：交互点仍在池塘顶部岸边，图标改为向池内偏移 16px。
- FarmPlot 现在有可编辑的 Super Retro 土壤图集区域、作物阶段和浇水水面；翻土不再是只有逻辑状态，播种与浇水也会显示对应表现。
- 自动回归锁定五种视觉状态转换；测试结果为 `TESTS_PASSED assertions=358`，正式场景无头启动保持 `HOME_REGION_READY size=960x544 interactables=225`。

## 2026-08-02：农田湿土素材复核与同系列扩展核对

- 查阅作者 Gif 的 Godot Store、itch.io Farming Pack 页面和作者评论：同系列确实有更大的 `Super Retro Ranch / Farming Pack` 扩展，但当前可验证说明没有承诺独立湿土 PNG；作者对旧湿地问题的说明是“重着色土壤/地形”。
- 对比项目内运行包与外部 Godot Store 检查副本的主图集 SHA-256，确认两者一致；因此没有无证据地再下载或混入另一套风格资源。
- 将之前错误的“水面叠层”改为可在 Inspector 替换的 `FarmSoilVisualSet`：未耕使用场景底地，干耕使用 `Farming sim` 图集 `(176,960)`，湿耕使用同一轮廓的更暗重着色，作物独立叠加。
- 删除了诊断截图脚本；真实可见窗口验证确认干/湿土均保持 16×16 对齐，湿土不是池水。headless 自动测试为 `TESTS_PASSED assertions=361`，正式场景启动仍为 `HOME_REGION_READY size=960x544 interactables=225`。
- 参考规则和来源记录在 `docs/research/FARM_SOIL_VISUAL_REFERENCE.md`；后续若购买 Premium 扩展，只在取得实际包并核对其 TileSet/许可证后替换当前 Resource，不改领域存档接口。

## 2026-08-02：外部工具与 Kenney 素材接入准备

- 已安装三个定向 Godot Skills：`godot-ui-theming`、`godot-ui-containers`、`godot-input-handling`。
- 已将 Pixelorama v1.1.10-stable 安装到 `D:\Archer\Tools\Pixelorama` 并成功启动确认；未写入 Project X 工程目录。
- 已复核 Kenney 官网免费资源，保留 Pixel UI、16×16 Pattern、Pixel Pack、18×18 Farm Expansion 和 Animal Pack 作为项目外候选；没有直接混入正式场景。
- Pixelorama 下载中途曾超时，已通过断点续传完成；当前压缩包和解压目录均完整存在。

## 2026-08-02：开源工具与 Skills 研究

- 已通过 GitHub 与项目官网核对 Pixelorama、GD-Agentic-Skills、Texel Studio、Godot AI、Godot MCP 及候选 UI 资源的用途、许可证、活跃度和项目冲突。
- 已确认当前最稳妥的组合为：Godot 原生 Theme/场景作为正式 UI，Pixelorama 作为像素制作工具，GD-Agentic-Skills 只按需加载 UI/容器/输入模块，Texel Studio 只做受控 AI 像素草稿试验。
- 未安装外部插件或修改游戏运行代码；研究报告已保存至 `docs/research/GODOT_UI_ART_SKILL_AUDIT.md`。

## 5-Question Reboot Check
| Question | Answer |
|----------|--------|
| Where am I? | Phase 2：技术架构与 Godot 工程骨架 |
| Where am I going? | 安装并确认 Godot 稳定版，创建可运行工程骨架 |
| What's the goal? | 完成以自由料理为核心的 14 日 PC 生活模拟原型 |
| What have I learned? | 见 `findings.md` |
| What have I done? | 完成产品基线、工作模式、Skill 安装、文档基线和架构草案 |
## 2026-08-02：鸡舍缺失视觉补齐

- 复核确认 Super Retro Farming 包没有可直接使用的鸡；同包 `bird` 素材不作为鸡使用。
- 使用受限提示生成原创母鸡候选图，保留正面、背面、左右朝向和行走姿态六帧，并统一裁成 16×20 像素网格。
- 正式家园先接入正面待机帧 `assets/art/animals/super_retro_hen_idle.png`；完整图集 `super_retro_hen_sheet.png` 作为后续动画的可替换资源。
- 未改变 `ChickenCoop` 领域逻辑、动物 ID、鸡蛋产出和存档结构。

## 2026-08-02：母鸡眼睛与农田空旷感修正

- 用户反馈指出母鸡缺少眼睛、农场绿地过于空旷；像素回归先失败，再补入 16×20 待机帧的两处深色眼睛像素。
- 田地边缘新增 5 个正式场景装饰节点：木箱、木桶、两盆植物和一块石头，均来自本地 Super Retro World - Farming 素材。
- 装饰保存在 `home_region.tscn/DecorationSprites`，不由运行时代码撒点；当前测试通过 `TESTS_PASSED assertions=366`。
- 根据二次视觉反馈，移除上一版 2×2 眼部块，改成左右同高的单像素眼点；重新导入后测试仍为 `TESTS_PASSED assertions=366`。

## 2026-08-02：装饰碰撞、池塘标记与土壤验收收尾

- 复核附图后确认池塘本体的 Super Retro 自动连接瓦片没有被运行时代码替换，实际问题是 `FishingPond` 的水面标记仍有半格越过池塘上沿；已将可编辑场景中的 `visual_offset` 从 `Vector2(0, 16)` 调整为 `Vector2(0, 32)`，交互 ID、池塘碰撞和钓鱼规则不变。
- 为 9 个农田周边装饰补齐正式 `StructuralCollision` 子节点：四块岩石、木箱、木桶、两盆植物和一块石头。每个形状均为编辑器保存的窄底边矩形，避免装饰变成覆盖整张图的空气墙。
- 新增 `scenes/reviews/farm_soil_visual_review.tscn`，可在 Godot 中直接比较未耕、干耕、湿耕、干土作物和湿土作物五种状态；回归测试锁定五个实例的 Inspector 预览状态。
- 母鸡正式像素资源将右眼校准到对称位置 `(10,7)`，与左眼 `(5,7)` 同高、同大小；重新导入后像素断言通过。
- 增加动态装饰审计：测试遍历 `DecorationSprites` 下的所有 `Sprite2D`，自动要求对应的 `...Collision` 节点存在；同时在鸡舍外侧补入同风格木箱/木桶作为饲料与饮水储物区，并配套底边碰撞。
- 新增 `scenes/reviews/chicken_coop_visual_review.tscn`，将母鸡、储物箱、饮水桶、盆栽和边界/物件碰撞保存为可在 Godot 中继续调整的场景资源；鸡舍照料仍复用正式 `ChickenCoop` 领域模块。
- 验证结果：`scripts/test_project.ps1` 输出 `TESTS_PASSED assertions=409`；正式场景无头启动输出 `HOME_REGION_READY size=960x544 interactables=225`。普通窗口截图仍不把系统边框兼容错误包装成视觉通过，编辑器场景是可继续人工检查的正式源文件。

## 2026-08-02：灾变时间线方案收口

- 用户通过连续 `grilling` 确认末日生存文字探索的完整方向，并明确授权进入实施。
- 已重读 `AGENTS.md`、`HANDOFF.md`、`task_plan.md` 与 `CONTEXT.md`；Phase 2 已完成审计，因此新模块必须复用而非重做时间、天气、体力、存档、背包、种植、料理和鸡舍领域能力。
- 已将 `task_plan.md` 当前阶段改为 Phase 3“灾变时间线前 7 天垂直切片”，并新增明确的产品边界、执行顺序和 Stop Rules。
- 使用 `codebase-design` 确定第一模块 seam：纯领域的灾变会话、D20、地点与容器搜刮通过版本化快照连接到 Godot 场景/UI adapter；不得让节点引用或贴图尺寸进入领域规则。
- 本轮工具定位错误：首次将 `planning-with-files` 误读为 `C:\\Users\\Aschere\\.codex\\skills` 下的技能；已改用实际的 `.agents\\skills` 目录，未重复同一失败路径。

## 2026-08-02：Phase 3.1 D20 领域切片

- 使用 `godot-gdscript` 和测试优先流程实现 `D20Check` 纯领域模块；它不创建节点、不生成随机数，调用者只传入已掷骰面、难度和修正。
- 新增 `tests/test_d20_check.gd` 并注册到 `tests/test_runner.gd`。先验证缺失实现导致 Red；实现后直接无头运行得到 `TESTS_PASSED assertions=420`。
- `scripts/test_project.ps1` 在脚本编译错误时错误地继续加载主场景，两个测试尝试均在 64 秒超时；已终止对应的测试 Godot 子进程（PID 3000、1912），没有触碰用户编辑器进程或项目内容。确定根因后改用直接 Godot 命令验证 Green，后续应修复该脚本的失败退出行为。

## 2026-08-02：Phase 3.1 角色状态与格子容器

- 新增 `src/domain/apocalypse/survivor_state.gd` 与 `tests/test_survivor_state.gd`，实现六属性、生命、四类压力、伤势、隐藏感染提示和纯数据恢复。
- 新增 `src/domain/apocalypse/grid_container.gd` 与 `tests/test_grid_container.gd`，实现矩形占格、重叠/边界判断、未知物揭示、重量分级和纯数据恢复；类名使用 `ApocalypseGridContainer` 避免覆盖 Godot 原生 `GridContainer`。
- 先后修复 GDScript 多行表达式、原生类名冲突和类内自实例化解析问题；最终 `scripts/test_project.ps1` 通过，结果为 `TESTS_PASSED assertions=461`。
- 测试包装脚本新增编译预检，当前不会再因测试脚本解析错误退回运行主场景。

## 2026-08-02：Phase 3 灾变会话与存档隔离

- 新增 `src/domain/apocalypse/apocalypse_session.gd` 与 `tests/test_apocalypse_session.gd`，组合普通时钟、角色状态、四类容器、地点发现和区域威胁；支持行动、睡眠与版本化恢复。
- 扩展 `TimelineSaveRepository` 的可选 `timeline_kind`，保留 `normal` 默认值，并新增普通/灾变互拒测试。
- 全量 Godot 测试通过：`TESTS_PASSED assertions=490`；测试包装脚本、编辑器导入和正式家园无头启动均正常。

## 2026-08-02：Phase 3 容器搜索切片

- 新增 `src/domain/apocalypse/search_container.gd` 与 `tests/test_search_container.gd`，实现未知物占格、逐件揭示、搜索分钟、噪声、稀有度和持久容器状态。
- 修复自动放置未知物初版固定到 `(0,0)` 导致第二件物品重叠的问题，改为通过格子容器公开尺寸寻找首个可用位置。
- 全量测试通过：`TESTS_PASSED assertions=508`；脚本检查、Godot 导入与现有主场景启动没有错误。

## 2026-08-02：Phase 4 外出 UI 审查场景

- 新增保存的 `scenes/reviews/apocalypse_explore_review.tscn`，使用 Godot 容器节点完成地点插图占位、四个热点、搜索面板和四类装备栏布局。
- 新增 `src/review/apocalypse_explore_review.gd` 与 `tests/test_apocalypse_explore_visual_review.gd`，锁定主标题、两列热点、四个热点按钮和四类装备容器。
- 修正一次审查测试路径：顶部主标题与面板内副标题是两个不同节点，测试改为明确检查顶部主标题。
- 全量测试通过：`TESTS_PASSED assertions=513`；独立场景无头启动输出 `APOCALYPSE_EXPLORE_REVIEW_READY hotspots=4 loadout_containers=4`。

## 2026-08-02：外出地点插图槽位与真实搜刮反馈

- 查找并记录了三个可直接评估的地点素材候选：Kenney RPG Urban Pack（CC0，16×16）、Pixel Hospital Tileset（免费/自愿付费，商业可用，32×32）和 Soppycraft Hospital Top-Down Pixel Pack（免费/自愿付费，商业可用）。候选和许可边界已写入 `docs/research/APOCALYPSE_LOCATION_ASSETS.md`，暂不未经视觉审查混入家园正式地图。
- 新增 `docs/APOCALYPSE_LOCATION_ART_PROMPT.md`，如果现成素材不够统一，用户可按提示生成一张 480×270 县郊卫生室插图；提示限制了 Super Retro 像素密度、低饱和末日色板、热点留白和无文字/无水印输出。
- 审查场景根节点新增可导出的 `location_illustration`，对应场景中的 `LocationIllustration` TextureRect。用户生成 PNG 后可直接通过 Godot Inspector 拖入，未提供图片时仍使用原有色块回退。
- 搜刮 UI 已接入真实 `ApocalypseSearchContainer`：药柜含急救包和绷带，点击搜索会逐件显露并更新稀有度、类别、耗时、噪声与完成按钮状态；其他热点先显示叙事锁定状态。
- 验证结果：Godot `--check-only` 通过，包装脚本通过，`TESTS_PASSED assertions=519`，独立审查场景无头启动通过。

## 2026-08-02：外出地点风格策略放宽

- 用户确认外出地点不再要求完全贴近 Super Retro；家园继续保留 Super Retro 基线，灾变外出地点允许采用更符合末日、荒野和地点叙事的独立像素风格。
- 已重新检索更贴近背景的候选：DithArt 末日城镇包（商业可用但付费）、Wasteland Essentials（免费版不可商用）和 Vinchy 末日外景包（可商用但需署名）。候选优先级与许可边界已同步到 `docs/research/APOCALYPSE_LOCATION_ASSETS.md`。
- 已更新 `docs/APOCALYPSE_LOCATION_ART_PROMPT.md`：不再要求模仿 Super Retro，改为强调潮湿、锈蚀、荒废诊所、赣南山地和搜索热点可读性。
- 检查 Godot Asset Store 后发现可直接添加的 `Free 2D Topdown Shooter Pack`（末日俯视图块，CC BY 4.0，需署名）和 `Admurins Freebies`（Apache 2.0 通用资源集合）；前者可作为卫生室周边/道路贴图候选，后者不适合主背景。
- 本地已有素材没有完整的县郊卫生室末日背景；由于地点只使用 TextureRect，不需要碰撞箱或像素级地图对齐，当前优先尝试免费医院包 + Godot 末日图块。若仍缺少一张完整背景，再交给用户按提示词生成。

## 2026-08-02：县郊卫生室插图接入

- 用户提供的县郊卫生室末日背景图已经接入正式审查场景，保存位置为 `assets/art/apocalypse/locations/county_clinic.png`。
- 插图通过 Godot 场景资源的 `location_illustration` 属性绑定，当前药柜、前台、铁柜和救护车热点都能在画面中找到；不制作碰撞或像素级对齐。
- 增加来源记录 `assets/art/apocalypse/README.md`，提醒正式发布前确认生成平台授权条款；如果授权不明确，可以直接替换 PNG，不影响 UI 和搜刮逻辑。
- Godot 导入、独立场景无头启动和全量测试通过：`TESTS_PASSED assertions=520`。

## 2026-08-02：搜刮物资接入背包

- 新增 `ApocalypseGridContainer.place_item_first_fit()`，让背包领域容器自行处理首个可用格位。
- 搜索药柜后，急救包和绷带会进入审查场景的 6×4 背包容器，负重从 5/20 更新到 9/20、10/20；空间不足时会显示暂不携带。
- 本轮没有制作物品图标或拖拽操作，先完成“发现 → 携带 → 负重变化”的可验证闭环。
- 验证结果：`TESTS_PASSED assertions=523`，独立审查场景启动正常。

## 2026-08-02：背包占格视觉反馈

- 搜到的物资现在会在背包格子中显示占用色，急救包的 2×1 形状会真实覆盖两个格位。
- 格子悬停提示包含物品 ID 和重量，水、急救包、绷带使用不同颜色区分。
- 验证结果：`TESTS_PASSED assertions=524`。

## 2026-08-02：背包图标槽位与生成提示词

- 背包格现在有正式的 `TextureRect` 图标槽位和文字回退；当前没有图标 PNG 也能正常显示“水 / 药 / 绷”。
- 新增三个可在审查场景根节点 Inspector 中替换的属性：`Water Icon`、`Medkit Icon`、`Bandage Icon`。
- 已整理图标生成提示词：[APOCALYPSE_ITEM_ICON_PROMPTS.md](docs/APOCALYPSE_ITEM_ICON_PROMPTS.md)。用户只需生成三张透明背景 PNG，再拖入对应属性，不需要修改代码。
- 验证结果：`TESTS_PASSED assertions=526`。

## 2026-08-02：搜索耗时与灾变时间线接通

- 搜索行为现在经过 `ApocalypseSession.spend_action()`，搜索急救包后时间从 06:00 变为 06:08，搜索绷带后变为 06:11，并同步消耗体力。
- 用户后续生成图片的格式要求已补充到地点和物品提示词：PNG、真透明背景、无黑底、无棋盘格、独立物体、可直接拖入 Godot TextureRect。
- 验证结果：`TESTS_PASSED assertions=529`。

## 2026-08-02：卫生室多热点容器

- 药柜、前台、救护车现在各自拥有独立容器状态；点击不同热点会切换右侧搜索面板，后仓继续作为剧情锁定热点。
- 前台钥匙和救护车燃料罐会复用真实搜索耗时、体力、时钟和背包逻辑。
- 验证结果：`TESTS_PASSED assertions=534`。

## 2026-08-02：地点退出闭环

- `离开地点` 按钮现在会锁定当前热点和搜索操作，并显示已带回物资与负重。
- 暂不跳转正式家园场景，避免审查 UI 提前绑定尚未完成的灾变 HomeRegion；后续接入时保留退出接口。
- 验证结果：`TESTS_PASSED assertions=536`。

## 2026-08-02：搜刮物资接入灾变存档状态

- 背包不再是审查 UI 的临时容器，搜到的水、急救包、绷带和钥匙会写入 `ApocalypseSession` 的背包快照。
- 新增会话级容器写入/读取接口，后续接入存档和返回家园时可以直接复用。
- 验证结果：`TESTS_PASSED assertions=539`。

## 2026-08-02：地点退出自动保存

- 点击“离开地点”时自动保存灾变会话到独立的 `user://saves/apocalypse_review/auto_1`。
- 自动存档保留时间、体力、搜刮状态、背包格位和带回物资，避免离开审查场景后丢失进度。
- 验证结果：`TESTS_PASSED assertions=541`。

## 2026-08-02：简化末日庇护所主入口

- 普通牧场模式目前不再作为默认入口，现有农场场景和资源保留但隐藏。
- 新建 `apocalypse_shelter.tscn`，仅保留固定功能区、少量碰撞边界、头像槽和背景贴图槽，符合文字生存游戏的低工作量方向。
- 四个功能区为休息区、储物柜、工作台和旧菜地；当前按钮只作为可编辑功能入口，真实领域功能后续接入。
- 已整理背景与主角头像提示词：[APOCALYPSE_SHELTER_ART_PROMPT.md](docs/APOCALYPSE_SHELTER_ART_PROMPT.md)。
- 验证结果：主场景无头启动输出 `APOCALYPSE_SHELTER_READY zones=4 collision_walls=4`，全量测试 `TESTS_PASSED assertions=545`。

## 2026-08-02：头像式主角移动

- 庇护所主角改为简单头像标记，支持 WASD 在固定范围内移动；不制作完整人物模型、行走动画或复杂角色碰撞。
- 资料头像和地图移动头像共用同一张可替换图片，没有图片时使用简单圆点回退。
- 验证结果：`TESTS_PASSED assertions=546`，主场景启动正常。

## 2026-08-02：末日庇护所 UI 素材接入

- 将下载目录中的 UI 素材裁切为透明边界并整理到 `assets/art/apocalypse/ui/`，包含互动框、功能面板、头像框、品质框、容器、背包格、状态图标和地图标记。
- 金色品质框改用用户提供的真透明版本；互动框和功能面板保留原比例，并在 Godot 场景中使用 `StyleBoxTexture` 九宫格拉伸，避免面板边角变形。
- `apocalypse_shelter.tscn` 已接入互动提示框、功能区弹窗框和头像框，布局仍可在 Godot Inspector 中移动、缩放和调整。
- 验证结果：Godot 编辑器导入完成；启动入口无头运行输出 `APOCALYPSE_SHELTER_READY zones=5 obstacles=5 collision_walls=4`；全量测试日志输出 `TESTS_PASSED assertions=554`。

## 2026-08-02：水、急救包、绷带图标接入

- 已接入用户提供的三张物品图，并转为 Godot 可稳定导入的 PNG。
- 场景根节点的 `Water Icon`、`Medkit Icon`、`Bandage Icon` 已绑定实际图片；背包格会显示对应图标，仍保留文字回退。
- 黑色背景通过 Godot ShaderMaterial 进行透明键控；如果后续提供透明底 PNG，可以直接替换而无需修改逻辑。
- 验证结果：`TESTS_PASSED assertions=526`。

## 2026-08-03：庇护所 UI 完整重构 + 碰撞箱精确贴合

- 用户指出左上头像框、右侧动作面板和底部互动提示全部"阶段不适配"，确认参考《活下去》方向：**砍掉常显文案面板，只用图标/高亮/轮廓引导**。
- 场景与脚本改造：
  - `scenes/world/apocalypse_shelter.tscn`：移除 `AvatarPanel` / `ZoneActionPanel` / `InteractionPrompt` 三组冗余节点；新增 `BottomStatusBar`（480×16，Y 254–270）、`ZoneIndicators`（5 个浮动 MarkerIndicator）、`Toast`（半透明右侧提示），并重新测量 5 个障碍 + 5 个交互区的 RectangleShape2D 尺寸，使其精确贴合 `ShelterElements` 视觉区域。
  - `src/world/apocalypse_shelter.gd`：新增 `_render_status_bar()`、`_animate_indicators()`、`_trigger_zone_action()`，并把单点碰撞判断改为 `_rect_has_avatar` 五点矩形检测（中心 + 四个方向 7px）；外边界收紧到 X∈[28,452]、Y∈[52,229]；按 E 改为按距离取最近交互区做路由，而不是旧的按钮弹出面板。
- 视觉资源：`assets/art/apocalypse/ui/frames/status_bar.png`、`ui/markers/interaction_indicator.png` 以及 6 张状态图标（hunger/thirst/injury/infection/noise_warning/time_warning）全部归档到对应目录，Godot 编辑器重新 Import 后生成 `.import`。
- 文档：新增 `docs/APOCALYPSE_UI_ART_PROMPTS.md` 汇总后续可能需要的图提示词，方便用户批量生成。
- 测试：`tests/test_apocalypse_shelter_visual_review.gd` 完全重写，从断言旧头像框切换为断言 BottomStatusBar / ZoneIndicators(5 个) / Toast / 4 类警告图标槽 / 新 UI 贴图存在，并反向断言 AvatarPanel / ZoneActionPanel 已移除；`expect_false` 不存在，最终改为 `expect_true(not x, ...)`。
- 验证结果：Godot 编辑器 import 通过；无头启动庇护所输出 `APOCALYPSE_SHELTER_READY zones=5 obstacles=5 collision_walls=4`；完整 headless 测试套件 `TESTS_PASSED assertions=567`（基线 555，超过基线 +12 条）。

## 2026-08-05：静态家园地图点击热区

- 用户确认庇护所不再使用地图头像行走、碰撞箱和靠近后按 E 的交互方式；其维护成本与静态背景图不匹配。
- `scenes/world/apocalypse_shelter.tscn` 改为 `Canvas/MapHotspots`：主屋、储物棚、工作台、菜地和大门各自保存为可在 Godot Inspector 移动/缩放的透明 `Button` 热区；悬停显示名称和低透明边框，点击才执行路由。
- `src/world/apocalypse_shelter.gd` 收敛为单一热点路由 seam：脚本验证 `zone_id`，大门进入区域地图，其他区进入同一个 `FeatureModal`。真实库存、制作、种植和休息完成后将在此处替换面板内容，不新建第二套入口。
- 删除庇护所内的 `Collision`、`AvatarMover`、`ZoneIndicators`、移动输入、碰撞检测和 E 键互动依赖。`survivor_avatar.png` 保留，后续只用于背包、装备、角色资料和剧情对话立绘。
- `tests/test_apocalypse_shelter_visual_review.gd` 已改为验证 5 个稳定热区、统一入口面板、底部状态条以及头像/碰撞节点不存在；验证结果待本轮 Godot 导入与自动测试补充。

## 2026-08-05：区域地图—诊所搜刮的跨场景闭环

- 新增 `ApocalypseRun` 自动加载模块，作为“正在进行的一局灾变”的唯一持有者。家园初始化、区域地图诊所入口和诊所搜刮 UI 都从同一会话读取数据，切场景不再把时间、体力与背包重置。
- 区域地图的地点按钮现在用场景 metadata 保存稳定 `location_id`；县诊所 `village_clinic` 已接入真实搜刮场景，未完成的县城市场和工业仓库不会伪装成可用系统。
- `ApocalypseSession` 扩展为可校验、存储和恢复地点内 `ApocalypseSearchContainer` 快照。搜索药柜/前台/救护车后立刻保留揭示状态，离开诊所自动保存完整会话并返回县域地图。
- 新增地图入口视觉审查测试，并扩展灾变会话测试覆盖地点容器快照的存档恢复；诊所审查测试改为验证自动保存事件和已完成药柜的持久进度。
- 静态检查：全部新增引用资源存在、自动加载和三段路由令牌齐全、诊所脚本不再私建会话。当前环境未找到 Godot 命令，尚无新的导入、headless 测试或人工试玩结果。

## 2026-08-05：Godot 4.7.1 本地工具链与真实回归验证

- 按用户授权下载 Godot 官方 Windows x86_64 标准版 `4.7.1.stable.official.a13da4feb`，放入 `tools/godot/Godot.exe`，不做系统安装；同时保留下载压缩包以便离线复用。
- 完成首次资源导入，`.godot/imported` 生成 759 个缓存文件。此前测试失败的贴图“缺失”实际是导入被过早终止，不是资源路径丢失。
- 修复 `ApocalypseRun` 在 `--check-only` 下不能作为全局标识符的解析问题：场景脚本改为从 `/root/ApocalypseRun` 获取自动加载节点。
- 测试脚本取消不可执行的 `--check-only` 预阶段；改为自动发现项目内 Godot、使用项目内临时用户目录，并以 PowerShell 5 兼容的 .NET 进程接口记录 stdout/stderr。直接执行需使用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1`，不会改动系统执行策略。
- 验证结果：全量 Godot headless 测试 `TESTS_PASSED assertions=595`；默认 `project.godot` 主场景无头启动输出 `APOCALYPSE_SHELTER_READY hotspots=5 avatar=false collisions=false`。
- 非阻塞环境警告：Godot 报告 Windows 根证书库读取失败；本轮资源导入、脚本编译、全量测试和主场景启动均未受其影响。

## 2026-08-05：灾变自动存档恢复

- `ApocalypseRun` 从单纯内存会话持有者升级为窄的自动继续模块：首次请求会话时尝试读取 `user://saves/apocalypse_review/auto_1`，有效快照恢复为活跃 `ApocalypseSession`，没有有效档案才新开局。
- 诊所退出统一调用 `ApocalypseRun.save_active_session()`，不再私建存档仓储；写入、备份回退和家园启动读取均使用同一条灾变存档路径。
- 增加 `start_new_session()`，实现层已能明确开始一局新会话；尚未创建对应玩家 UI，不能将“新开局菜单”标记完成。
- 新增 `test_apocalypse_run.gd` 覆盖新局、存入水和时间消耗、写 auto_1、清空内存、恢复时间与背包的流程。最初暴露旧诊所测试因自动恢复读到历史档案，已改为调用正式的新开局接口建立干净状态。
- 最终验证：全量测试 `TESTS_PASSED assertions=603`；默认主场景从同一用户目录启动输出 `APOCALYPSE_RUN_READY source=auto_save backup=false`，确认不是只在单次场景切换内保持状态。

## 2026-08-05：储物棚—背包真实转移闭环

- `ApocalypseSession` 新增家园仓储 `home_storage`，规格为 8×6 格、最大负重 80；它进入同一份灾变会话快照，因此自动档、备份恢复和重启继续都会保留仓储物资。
- 新增 `transfer_item()`，以“目标优先放置 → 成功后移除来源 → 来源移除异常则回滚目标”的顺序维护原子性。UI 不接触 GridContainer 的内部物品数组或坐标。
- `StorageShed` 热区已从 FeatureModal 占位文案改为场景内 `StorageModal`：左栏外出背包，右栏家园仓储，点击条目转移并即时自动保存。空列表、目标无空间、自动保存失败均有明确状态文本。
- 原有旧 `auto_1` 不含 `home_storage` 时会补空容器后继续恢复，避免本轮字段新增导致旧档失效。
- 新增仓储视觉审查测试，自动继续测试改为验证“水已存进家园 → 存档 → 恢复后仍在家园仓储”。验证结果：`TESTS_PASSED assertions=624`。

## 2026-08-05：一键启动器本地 Godot 路径修复

- 用户从 `启动游戏.bat` 启动时，`scripts/run_godot.ps1` 仍只查找旧文件名 `Godot_v4.7.1-stable_win64.exe`，没有识别项目内已经安装的 `tools/godot/Godot.exe`，因而在启动前报“executable not found”。
- 启动器现优先查找 `tools/godot/Godot.exe`，并保留旧的版本文件名、控制台版本、项目根目录、旧机器路径和 `GODOT_EXE` / 系统 PATH 作为兼容回退。
- 同一条复现命令 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_godot.ps1 --version` 现输出 `4.7.1.stable.official.a13da4feb`；完整回归结果仍为 `TESTS_PASSED assertions=624`。Windows 根证书库警告仍为不阻塞环境警告。

## 2026-08-05：灾变仓储改为真实格子库存

- 修复“同类物品只能放一个”：`ApocalypseSession.place_item_in_container()` 现在在请求的实例 ID 已被使用时生成新的全局唯一实例 ID。因此两瓶同类饮用水会各自占格；物品类型 `water` 可以重复，库存实例不能重复。
- 会话模块新增“容器内移动到指定格”和“跨容器放到指定格”的接口。它们由领域层负责矩形占格、边界、碰撞和失败回滚；储物棚 UI 不直接改物品数组或坐标。
- `StorageModal` 已从两个文字 `ItemList` 替换为可见的 6×4 背包和 8×6 家园仓储网格。复用现有 `inventory_slot.png` 与水/急救包/绷带图标；物品按真实宽高覆盖格子，单击快速转移，按住拖到同一或另一侧的目标格。
- 回归覆盖第二件同类物品、两个独立物品块、网格尺寸、单击转移和拖到指定格。验证：`TESTS_PASSED assertions=631`，默认庇护所无头启动输出 `APOCALYPSE_SHELTER_READY hotspots=5 avatar=false collisions=false`。

## 2026-08-05：仓储表现收敛为常规单槽库存

- 按用户反馈撤回储物棚的俄罗斯方块式拖拽整理。保留真实背包 6×4、家园仓储 8×6、自动保存和“同类物品可多件”的领域规则，但玩家操作恢复为单击物品在两侧快速转移。
- 当前可携带的水、急救包、绷带、钥匙和燃料罐统一为一件一格；格子从 14 像素调整为 18 像素，物品块在槽位内留 1 像素边距，图标与格框对齐。
- 有图标的物品不再同时显示“水 / 药 / 绷”等文字。悬停信息改为 7 像素的自定义单行 Tooltip，例如“饮用水 · 1 格 · 负重 5”。
- 验证结果：`TESTS_PASSED assertions=634`。自动测试覆盖图标块 16×16 正好置于 18×18 槽位、图标物品无多余文字和简短详情文本。

## 2026-08-05：库存详情补全与多瓶水演示

- 没有 PNG 的诊所钥匙此前回退为默认 16 号“钥”字，显得异常大。所有库存槽现在统一覆盖为 7 号字体；有图标的物品继续不显示槽位文字，无图标钥匙仅显示小号“钥”作为临时回退。
- Tooltip 从过于简单的一行恢复为紧凑三行：名称；分类、占格、负重；具体设计效果或用途。使用效果均明确标记“待接入”，不把尚未实现的消耗系统伪装为已可用。
- 水显示“口渴等级 -1（待接入）”，急救包“生命 +25（待接入）”，绷带“移除 1 项创伤（待接入）”，钥匙“开启诊所锁柜（待接入）”，燃料罐“提供燃料 +10（待接入）”。
- 诊所审查入口会确保背包中至少有 `water_1`、`water_2`、`water_3` 三瓶水，以便实际检查同类物品多个独立槽位的效果；搜到急救包后它进入第 4 槽。
- 验证：`TESTS_PASSED assertions=641`。回归覆盖三瓶水、钥匙回退字号、图标与文字互斥，以及水/钥匙的详细 Tooltip 文案。

## 2026-08-05：常规生存库存的数量叠加

- 新增 `ApocalypseItemCatalog`，将物品名称、类别、数值效果与 `maximum_stack` 收敛到同一份静态定义。普通用品默认最多 16 个一组；已预留手枪、步枪、霰弹枪和近战武器为 `1` 的不叠加规则。
- `ApocalypseGridContainer` 的库存记录新增 `quantity` 与 `maximum_stack`。`add_item_stack()` 会先补满同种、同单位负重、同可见状态的未满堆，再按空格新建溢出堆；总负重随数量计算，新增已用格/总容量查询。
- `ApocalypseSession` 所有新入库物资强制为标准 1×1 格，并在恢复旧版容器快照时归一化、合并为新的 16 上限物品堆。存档不会因为从旧的一件一格格式升级而直接失效。
- 家园仓储 UI 不再显示 `存储重量/80`，改为 `已用格/48 · 不计负重`；背包仍保留探索负重。点击一个格子会转移整组物品。
- 水、医疗包、绷带保留现有图标。钥匙和燃料罐不再显示中文回退字；格子内由 `ApocalypseInventoryItem` 绘制同尺寸的简化图标。物品堆右下角显示 `×N`，Tooltip 改为名称、类别、数量/16、效果/用途和负重规则。
- 诊所审查入口的三瓶测试水改为 `water ×3` 的单格堆；搜到医疗包后占紧邻的下一格。完整无头测试为 `TESTS_PASSED assertions=655`。Windows 根证书库读取警告仍为不阻塞环境警告；未声称已人工目测实际窗口效果。

## 2026-08-05：库存数量角标与右键物品操作菜单

- `ApocalypseInventoryGridView` 的数量改为 `QuantityBadge` 面板：锚定在每个 16×16 物品块内部右下，距离边缘 1 像素，父物品按钮启用裁切；`×N` 不再依赖会漂移的绝对 Label 坐标。
- `ApocalypseGridContainer` 新增无副作用容量预检、按数量扣减和原地拆堆；`ApocalypseSession` 新增 `transfer_quantity()` 与 `split_item_stack()`。按数量转移先确认目标可容纳，再更新目标并扣减来源；所有数量仍进入现有快照。
- 储物棚物品右键现在打开操作菜单。背包显示“存入 1 / 存入整组”，仓储显示“取出 1 / 取出整组”；数量至少为 2 时提供“拆分一半 / 拆分指定数量”，另有只读详情弹窗。左键仍是原有的整组快速转移。
- 右键“拆分指定数量”使用数量选择弹窗；无空格或数量无效时不会改变原堆。使用、装备、丢弃和快捷栏尚未实现，菜单也没有伪造这些不可用操作。
- 验证：`TESTS_PASSED assertions=684`。覆盖了角标节点及右下锚定、按数量跨容器转移、自动回填已有堆、原地拆堆、右键菜单选项、菜单取出 1 和指定数量拆分后的数量守恒。Windows 根证书库警告仍不阻塞测试。

## 2026-08-05：固定紧凑库存 UI 与基础物品使用

- 储物棚右键菜单统一为固定紧凑规格：8 像素字体、132 像素宽；拆分数量窗固定 172×82，详情窗固定 184×104。动态弹窗不再随系统默认主题放大。
- `QuantityBadge` 继续锁在物品块右下角，背景使用深色 `alpha=0.42`（约 58% 透明）；数量仍显示在 16×16 图标格内部，不覆盖大部分图案。
- 右键菜单会优先显示物品当前可用的动作：水为“饮用 1”、急救包为“使用急救包”、绷带为“使用绷带”。水只在口渴大于 0 时降低 1 级；急救包只在生命未满时恢复最多 25 点；绷带只在存在创伤时移除 1 项。成功时扣 1 件并推进 5 分钟；状态不满足时不消耗物品。
- 钥匙与燃料仍保留明确的待接入用途，避免没有对应地点/设施时出现无效按钮。
- 验证：`TESTS_PASSED assertions=704`。新增覆盖水、急救包、绷带的真实效果、失败不消耗、单件扣减和 5 分钟行动时间；Windows 根证书库警告仍为不阻塞环境警告。未声称已人工目测窗口效果。

## 2026-08-05：诊所钥匙、锁柜与“发现后领取”搜刮

- 村卫生室把原“后仓 · 有声响”占位热点替换为“锁柜 · 需要钥匙”。玩家先在前台搜索并领取诊所钥匙，再用钥匙解锁；钥匙是耐久门禁物，不会被消耗，解锁只推进 5 分钟。锁柜已解锁状态进入地点快照和自动档，离开再回来不会重新上锁。
- 锁柜内含独立的医疗搜刮容器，解锁后仍按普通搜索结算时间、噪声和物资揭示，不把奖励直接塞进背包。
- 所有诊所容器现在遵循统一两阶段流程：搜索只揭示物资；“已发现物资”面板显示逐件“放入背包”按钮和“全部放入背包”。物资仅在玩家领取成功后标记为已带走；背包空间不足时，它继续留在原容器、可下次再取，并随地点快照保存。
- 修复了诊所容器注册只在读档时写入字典的隐患：新局与读档都会注册相同的容器定义，锁柜和原有药柜/前台/救护车使用一条持久化链路。
- 验证：`TESTS_PASSED assertions=727`。覆盖搜索不自动入包、逐件领取、全部领取、钥匙解锁、钥匙不消耗、解锁耗时、锁柜内容搜索，以及锁状态/未领取物资随自动档保留。Windows 根证书库警告仍为不阻塞环境警告；尚未人工目测窗口布局。

## 2026-08-05：燃料罐—主屋应急发电机—家园电力储备

- `fuel_can` 不再显示“待接入”。燃料罐只能从 `home_storage` 消耗：玩家需要先在诊所领取燃料、带回家、存入家园仓储，再点击主屋进入应急发电机面板。
- 每个燃料罐增加 10 点电力储备，最高 100；加注消耗 5 分钟，不消耗体力。储备接近上限时按钮禁用且燃料不会被浪费；仓储没有燃料时同样不能加注。
- 电力储备是 `ApocalypseSession` 的正式快照字段。旧档没有该字段时安全默认为 0；自动档和重启恢复后会保留加注结果。
- 主屋不再只是占位说明：新增固定紧凑的“主屋 · 应急发电机”面板，标题 10 像素、正文与按钮 8 像素；面板显示当前电力、仓储燃料数量、单次收益和耗时。通用功能弹窗也沿用这套更小的规格。
- 当前真实完成的是“燃料转为可保存的电力资源”。医疗、制作、夜间操作尚未读取电力，不能宣传为已完成这些加成；下一步应选择其中一个系统消费电力。
- 验证：`TESTS_PASSED assertions=743`。覆盖无燃料失败、从背包存回仓储、加注后 +10 电力、扣 1 燃料、消耗 5 分钟、快照恢复，以及主屋 UI 实际触发加注。Windows 根证书库警告仍为不阻塞环境警告；尚未人工目测窗口布局。

## 2026-08-05：主屋医疗台消费电力处理创伤

- 主屋面板从单一发电机扩展为“主屋 · 发电机 / 医疗台”，仍使用同一个紧凑弹窗和两个 8 像素操作按钮，不增加新的家园热区或地图行走。
- 医疗处理的明确成本为：家园电力 10、家园仓储急救包 1、游戏时间 15 分钟；只有存在创伤或感染风险时按钮可用。电力不足、没有急救包、没有可处理状态时不会消耗任何资源。
- 成功后移除当前第一项创伤，并降低最多 15 点感染风险。若只有感染风险，则仍可处理风险；若只有创伤，也可单独处理创伤。感染风险不会低于 0。
- `SurvivorState` 新增受控的 `reduce_infection_risk()`，避免 UI 或医疗台直接编辑角色快照；`ApocalypseSession.treat_at_home_medical_station()` 统一负责前置校验、时间、电力、库存、角色状态和结果文本。
- 验证：`TESTS_PASSED assertions=757`。覆盖医疗台需要电力和仓储急救包、扣 10 电力/1 急救包/15 分钟、处理创伤、感染风险 -15、无电失败，以及主屋 UI 操作。Windows 根证书库警告仍为不阻塞环境警告；尚未人工目测窗口布局。

## 2026-08-05：地点累计噪声、区域威胁与危险搜索确认

- 每次诊所搜索成功后，物品本身的噪声会写入地点 `search_noise`，而不是只停留在单个药柜/前台/锁柜的显示中。离开地点、自动存档、重启恢复后，累计地点噪声保持不变；旧档缺失该字段时默认为 0。
- 噪声规则第一版采用确定性阈值：地点噪声首次达到 5 时，当前区域威胁提高 1 级（最高 3）；达到 10 时，后续每次有可搜物资的搜索按钮先变为“危险搜索 · 再点击确认”，第一次点击不消耗时间，第二次点击才执行搜索。
- 诊所右侧状态改为同时显示“地点噪声、当前容器噪声、当前容器累计搜索时间”，搜索日志也说明本次噪声结果和是否提升了区域威胁。切换容器会取消尚未执行的二次确认，避免误操作。
- 本版没有随机伤病或无提示失败：危险搜索的明确成本仍是时间、体力、噪声与更高区域威胁；随机遭遇应等威胁后果的数据表和可解释 UI 一起设计，不能先暗中塞入概率。
- 验证：`TESTS_PASSED assertions=771`。覆盖地点噪声累计、5 点跨阈值仅提升一次区域威胁、10 点危险状态、存档恢复、危险搜索第一次点击不消耗时间、第二次确认后正常耗时，以及自动档保留 13 点诊所噪声。Windows 根证书库警告仍为不阻塞环境警告；尚未人工目测窗口布局。

## 2026-08-05：工作台单配方与替代开锁路线

- 新增三种目录物品：废金属、电线、简易开锁工具。它们没有 PNG 时由库存格内部的紧凑矢量回退图标绘制，不显示大号中文回退字；Tooltip 说明材料用途或工具的一次性开锁效果。
- 诊所药柜增加废金属，前台调整为先出电线、再出诊所钥匙。玩家可以带走材料提前返回家园，在不继续搜前台钥匙的情况下走制作路线；钥匙路线仍保留，形成两条实际选择而不是把钥匙替换掉。
- 工作台从占位面板改为单个可执行配方：`废金属 ×1 + 电线 ×1 + 电力 5 + 时间 10 分钟 → 简易开锁工具 ×1`。输入、输出都在家园仓储中，成功后立即自动保存；材料或电力不足时不扣任何资源。
- 诊所锁柜支持两种解锁方式：诊所钥匙耗时 5 分钟、不会消耗；简易开锁工具耗时 10 分钟、会消耗 1 个工具。锁柜 UI 会根据背包实际持有的物品显示正确文本，不会同时显示无效动作。
- 验证：`TESTS_PASSED assertions=797`。覆盖材料搜刮顺序、配方扣除材料/电力/时间、成品入家园仓储、开锁工具替代钥匙且被消耗、钥匙继续耐久、工作台 UI 实际制作和自动保存。Windows 根证书库警告仍为不阻塞环境警告；尚未人工目测窗口布局。

## 2026-08-07：家园热区弱化与第一件可装备武器

- 家园五个地图热区默认继续完全透明。悬停状态从亮黄色覆盖与高不透明边框改为低饱和灰绿色：背景 alpha 0.07、边框 alpha 0.30；按下状态背景 alpha 0.14、边框 alpha 0.55。功能区名称从亮黄 10 像素改为灰绿 9 像素和更薄描边。
- 地图热区与弹窗按钮不再共用同一悬停样式。制作、医疗、返回等实体按钮使用独立的深灰绿 hover/pressed 样式，避免弱化地图热点时让普通按钮变透明。
- 新增不可叠加武器“撬棍”，单件负重 3，近战伤害 8、体力消耗 6、噪声 1。它作为诊所锁柜第三件隐藏物资进入现有“搜索后选择领取”流程，并使用 16×16 内部矢量图标，不显示背景大字。
- `ApocalypseSession` 新增单一主武器装备槽。背包中的武器可装备/卸下，状态进入会话快照；旧档没有 `equipment` 时默认为空手。把已装备武器转移到家园仓储时会自动卸下，避免悬空装备引用。
- 储物棚增加 8 像素紧凑装备状态行。背包右键撬棍显示“装备为主武器”，装备后切换为“卸下主武器”；状态行显示武器名称、伤害、体力消耗和噪声。当前只完成装备与数值展示，尚未接入攻击结算、耐久或快捷使用栏。
- 完整无头回归：`TESTS_PASSED assertions=833`。覆盖热区透明度上限、武器单件不叠加、装备/卸下、存档恢复、转存自动卸下、右键菜单、紧凑装备状态行和诊所锁柜三件内容。Windows 根证书库警告仍不阻塞。Windows 控制插件缺少其规范要求的文档入口，因此本轮没有冒充人工窗口视觉验收。

## 2026-08-07：库存拖放、B 键独立背包与 Esc 系统菜单

- 标准单槽库存恢复拖放交互，但没有恢复俄罗斯方块尺寸：每个物品堆仍占 1 格，拖动的是整组。物品按钮提供来源容器和实例 ID，目标网格只计算落点，`ApocalypseSession.transfer_item_to_position()` 继续负责同容器移动、跨容器转移、占格校验、失败回滚和装备自动卸下。
- 家园仓储界面支持背包内整理、仓储内整理，以及在两栏之间拖动。有效拖放会自动保存并显示目标格；被占用、越界或无效落点不会改变物品。原有左键整组快速转移和右键按数量操作继续保留。
- HUD 新增紧凑的“背包 [B]”按钮，`open_inventory` 从 I 改为 B，对应 Backpack。独立背包复用同一套库存格、Tooltip、右键菜单和 8 像素规格，但隐藏家园仓储栏，并移除“存入/取出”操作，防止远程访问仓库；单击物品查看详情，右键可使用、装备、拆分或查看。
- 新增 Esc/P 系统菜单，包含继续游戏、打开背包和保存游戏。`S = Save` 只在系统菜单打开时触发保存；末日家园仍是完全静态的点击地图，不读取 WASD，也没有角色移动、碰撞箱或功能区接近交互。Esc 仍遵循模态优先级：先关闭当前仓储/背包或功能弹窗，没有其他弹窗时才打开系统菜单。
- 完整无头回归：`TESTS_PASSED assertions=851`。新增覆盖 B 键与 S 键映射、HUD 背包入口、独立背包隐藏仓储、拖放请求、跨栏拖到指定格、Esc 菜单、菜单保存、菜单打开背包和继续游戏。Windows 根证书库警告仍为不阻塞环境警告。

## 2026-08-07：县域地图与诊所复用背包/系统菜单覆盖层

- 新增可复用 `ApocalypseGlobalOverlay` 场景，集中提供“背包 [B]”、6×4 随身背包、装备状态、负重、物品详情、使用/装备/拆分右键菜单、背包内拖动，以及 Esc/P 系统菜单和 S 保存。县域地图与诊所都实例化这一份场景，不复制 UI 代码。
- 覆盖层只读取 `ApocalypseRun` 的共享会话，因此换场景后看到的是同一个背包和同一件已装备武器。外出覆盖层没有家园仓库入口，只允许整理 backpack；家园仓储仍必须回家点击储物棚。
- 县域地图和诊所的 `_unhandled_input()` 先调用覆盖层。B 打开背包；Esc 优先关闭背包，其次打开/关闭系统菜单。原先“县域地图 Esc 直接回家”和“诊所 Esc 直接离开并保存”不再抢先触发，返回仍由场景中的正式按钮执行。
- 诊所连接覆盖层 `inventory_changed` 信号；使用物品、装备、拆分或移动后，诊所原有携带栏和时间/状态显示同步刷新。覆盖层的有效操作自动保存，失败操作不改变库存。
- 完整无头回归：`TESTS_PASSED assertions=863`。新增覆盖县域地图与诊所都持有同一覆盖层、B 打开真实 6×4 背包、Esc 关闭背包、Esc 打开菜单而不离场、再次 Esc 关闭菜单。Windows 根证书库警告仍为不阻塞环境警告；尚未人工窗口验收覆盖按钮在两张界面上的位置。

## 2026-08-08：首轮袭击最小完整流程与交接包

- 新增 3 日准备、第 4 日清晨结算的公开阶段目标。准备项是电力 10、家园急救包 1、武器 1，任意完成两项即可守住首袭；准备不足固定生命 -20、新增袭击创伤并提高区域威胁，但仍会完成演示结算。
- 主屋新增 8 像素“休息到次日”按钮，家园 HUD 新增 8 像素首袭目标板。主屋保持现有 480×256 紧凑规格，没有恢复人物行走、碰撞箱或功能区靠近交互。
- 底部状态栏改为读取灾变会话中的真实生命、生存压力、体力、创伤、感染风险与时间，删除固定演示状态造成的错觉。
- 首袭状态进入版本兼容快照；旧档缺少 `campaign` 时安全恢复。家园 UI 自动化真实点击三次休息并在结算后清空运行时会话，从自动档恢复到同一第 4 日结局。
- 顶层 README、代理规则、计划和灾变规格已经同步到末日主线；旧牧场源码/测试保留，不再是近期路线。
- 新增 `handoff/PROJECT_X_APOCALYPSE_2026-08-08/`，包含状态、验证、交接提示词和清单，准备压缩为可供另一个账号读取的上下文包。
- 完整无头回归：`TESTS_PASSED assertions=895`。Windows 根证书库警告仍不阻塞。由于当前桌面会话无法获得 Godot 可见窗口句柄，本轮没有人工视觉验收，交接包已把它列为新账号第一项任务。

## 2026-08-09：完整迁移包切换完成

- 将桌面当前旧版本打包为 `archives/Project_X_Live_PreMigration_2026-08-09.zip`，用于回滚；未删除旧源码资料。
- 隔离解压 `Project_X_Complete_Migration_2026-08-09.zip`，使用包内 Godot 4.7.1 完成 380 项资源导入。
- 隔离工程默认启动输出 `APOCALYPSE_RUN_READY source=new_game backup=false` 与 `APOCALYPSE_SHELTER_READY hotspots=5 avatar=false collisions=false`。
- 提升完整迁移包后，当前主工程全量回归为 `TESTS_PASSED assertions=895`。
- 本地 `project_materials/` 与 `archives/` 增加 `.gdignore`，旧生成缓存移入 `project_materials/pre_migration_generated_2026-08-09/`；临时隔离解压目录已送入 Windows 回收站，原始 ZIP 仍在归档目录。
- 当前路线正式以末日静态热点流程为准；待办顺序保持：真实窗口视觉验收 → 新游戏/继续入口 → 第二个正式搜刮地点 → 口粮日结算。

## 2026-08-09：新游戏/继续入口与县城市场完成

- 新增 `scenes/startup/apocalypse_start.tscn` 与 `src/world/apocalypse_start.gd`。入口布局、覆盖背景、按钮、状态文案和新开局确认面板都保存在可编辑场景中；脚本仅负责路由和 `ApocalypseRun` seam 调用。
- `ApocalypseRun` 新增 `get_continue_summary()`、`continue_session()` 与 `start_new_session_and_save()`。继续前先校验 `auto_1` 快照，新游戏确认后才覆盖自动档。
- 县域地图的 `Market` 标记现在进入 `scenes/reviews/apocalypse_market_review.tscn`；新增柜台和后仓两个独立搜刮容器，搜索耗时、噪声、揭示/取物和退出自动保存均进入 `county_market` 快照。
- 新增入口 API、入口场景、地图路由和市场搜刮的回归覆盖。资源导入成功；全量无头回归为 `TESTS_PASSED assertions=925`。
- 默认主场景无头启动成功，输出 `APOCALYPSE_START_READY continue=true`（本机已有可恢复自动档）。真实窗口人工视觉验收仍未完成，不把自动检查替代为目测结论。

## 2026-08-09：三张原创背景图接入

- 用户提供三张 1717×916 背景图，已复制到 `assets/art/apocalypse/backgrounds/`，保留原有庇护所/诊所素材，不覆盖旧文件。
- `apocalypse_shelter_entry_generated.png` 已用于新游戏/继续入口；`county_market_generated.png` 已用于县城市场搜刮场景的主插图。
- `industrial_warehouse_generated.png` 仅作为未来地点资源归档，当前工业标记仍不开放。
- 重新导入、默认启动和全量回归通过：`TESTS_PASSED assertions=925`；入口与市场窗口截图已人工查看，完整点击路径仍待验收。

## 2026-08-12：继续入口窗口验收

- 实际启动 Godot 4.7.1 项目窗口，确认启动页从 `auto_1` 提供“继续游戏”，点击后进入庇护所；日志记录 `APOCALYPSE_RUN_READY source=auto_save` 与 `APOCALYPSE_SHELTER_READY hotspots=5`。
- 门口热点之后的窗口点击未完成：Computer Use 对 Godot 游戏画布报告截图边界接口异常，无法可靠定位游戏内坐标。保持未完成状态，不将地图/市场 E2E 路径误报为通过。
- 自动化验证复跑通过：`scripts/test_project.ps1` → `TESTS_PASSED assertions=925`。下一步是修复或更换 Godot 窗口捕获方式，再继续地图→市场→返回的人工验收。

## 2026-08-13：Phase 3B 可视化 E2E 关闭

- 新增 `tests/capture_apocalypse_e2e.gd`，在独立 Godot 用户目录中驱动正式场景和正式按钮，生成 `tmp/apocalypse_e2e_capture/01`—`12` 共 12 张 1440×810 逐步画面，不修改玩家存档。
- 完成新游戏确认→庇护所→县域地图→市场→搜索/取物→退出自动保存→启动页继续→市场状态恢复→返回庇护所的人工逐图检查。
- 修复市场与诊所 `GlobalOverlay` 被主界面遮挡的问题：共享覆盖层现为场景根节点最后一个子节点，并增加绘制顺序回归断言。
- 验证通过：编辑器资源解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；可视化 E2E `APOCALYPSE_E2E_CAPTURE_PASSED captures=12`；全量测试 `TESTS_PASSED assertions=927`。
- Phase 3B 关闭。下一步进入第三个正式搜刮地点“工业仓库”，不同时扩展 7 日事件、居民或旧牧场线。

## 2026-08-13：第三个正式搜刮地点“工业仓库”完成

- 新增 `scenes/reviews/apocalypse_warehouse_review.tscn` 与 `src/review/apocalypse_warehouse_review.gd`，使用已归档工业仓库背景、两个保存热点和共享灾变覆盖层。
- 县域地图开放 `industrial_warehouse` 路由；装卸台与维修笼分别保存独立的搜索、领取、时间和噪声状态，离场沿用 `ApocalypseRun.save_active_session()`。
- 新增仓库场景回归，并扩展地图路由与隔离存档 E2E。领取日志的首次视觉矛盾已在逐图检查后修正。
- 验证通过：Godot 编辑器场景解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；可视化 E2E `APOCALYPSE_E2E_CAPTURE_PASSED captures=16`；全量测试 `TESTS_PASSED assertions=947`。
- 第三个地点模块关闭。下一步只做一个第 5 日事件切片，不同时展开居民、农业、社交、经济或旧牧场线。

## 2026-08-13：第 5 日单事件切片完成

- 在 `ApocalypseSession` 的休息/campaign seam 中加入 `day_five_radio_signal`，提供供电监听与屋顶观察两个公开、确定的选择；pending 会阻止再次跳日。
- pending/resolved、稳定选择 ID 和结果进入向后兼容的 campaign 快照；旧档不提高版本即可恢复。
- 在 `apocalypse_shelter.tscn` 保存独立 `CampaignEventModal`，接入自动弹出、禁用态、不可 Esc 跳过、结算反馈、自动保存与目标板结果。
- 可视化 E2E 从 16 步扩展到 21 步，覆盖首袭、第 5 日 pending、屋顶结算、目标板更新和 Continue 后 resolved 恢复；逐图检查后收紧事件面板高度。
- 验证通过：Godot 编辑器场景解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；`APOCALYPSE_E2E_CAPTURE_PASSED captures=21`；`TESTS_PASSED assertions=993`。
- 第 5 日模块关闭。下一步只做第 6 日单事件切片，不同时展开居民、农业、社交、经济或旧牧场线。

## 2026-08-13：第 6 日单事件切片完成

- 参考用户提供的末日叙事，提炼“屋檐悬包、绳索回收、物资与安全取舍”为 `day_six_hanging_pack`；没有照搬人物、队伍、D20 或实时战斗。
- 回收悬包会把饮用水 ×2 写入真实家园仓储，并公开增加疲劳、压力各 1；放弃悬包不会增加状态，也不发放隐藏奖励。pending 继续阻止跳日。
- 保留 `get_pending_campaign_event()` / `resolve_pending_campaign_event()` 两个领域接口；第 5—6 日定义与结算只在会话内部派发。庇护所双按钮改为读取 `choices` 元数据，不再认识逐日选择常量。
- 第 6 日状态与结果进入版本 1 campaign 快照；旧档缺少字段时可推导待处理状态。自动保存与 Continue 同时恢复事件选择、目标板和两份饮用水。
- 新增领域和视觉回归，可视化 E2E 从 21 步扩展到 25 步。逐图检查确认 pending、结算、目标板和 Continue 恢复均完整可读，并修正结算页仍显示“待处理”的文案。
- 验证通过：Godot 编辑器场景解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；`APOCALYPSE_E2E_CAPTURE_PASSED captures=25`；`TESTS_PASSED assertions=1036`。
- 第 6 日模块关闭。下一步只做第 7 日单事件切片，不同时展开居民、农业、社交、经济或旧牧场线。
