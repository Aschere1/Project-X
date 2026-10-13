# Project X 详细交接文档

更新时间：2026-10-13（Asia/Shanghai）  
项目目录：`D:\Archer\Project X`  
引擎：Godot 4.7.1 stable（GDScript，非 .NET）  
当前默认入口：`res://scenes/startup/apocalypse_start.tscn`

> 2026-10-13 公开评审：Project X 已发布到 https://github.com/Aschere1/Project-X ，LifeOS 已统一发布到 https://github.com/Aschere1/LifeOS 。两个仓库均公开，默认分支均为 main。Project X 公开版启动与验收说明见 `docs/EXTERNAL_REVIEW.md`，不依赖私有素材的主线回归为 21 套件/783 断言，干净副本 34 步可视化 E2E 通过。

> 2026-08-20 增量：安全区设施基础已接入保存的主屋室内、鸡棚、三联牲畜棚热点、每日维护、自动保存与 Continue 恢复；全流程通过 34 步 Godot 可视化 E2E 和人工逐图检查。最新全量回归为 `TESTS_PASSED assertions=1133`；下一步是完整切片验收与边界清单。

> 最新交接入口：`handoff/PROJECT_X_APOCALYPSE_2026-08-08/README.md`。本文前半部分保留了方向调整时的历史状态，可能描述当时尚未接通的功能；判断当前事实时，以最新交接包、本文末尾最新章节和全量测试为准。

---

## 0. 这份文档解决什么问题

这不是最初“普通农场生活模拟”版本的交接，而是项目经过多轮方向调整后的**当前真实状态**。

项目已经从“先完成普通牧场”转为优先制作：

> 以中国南方县城周边为背景的丧尸末日生存游戏。家园保留简化的 2D 可移动地图；外出地点主要通过固定场景插图、文字、UI、容器搜索和 D20 判定表现，不制作实时战斗。

旧的农业、动物、时间、天气、体力、料理、存档等系统仍有复用价值，**不得删除**；但普通牧场目前不再作为默认入口，也不应继续消耗近期开发资源。

本文档重点回答：

1. 玩家现在从哪里进入游戏，能实际操作什么。
2. 哪些画面和系统已经接通，哪些只是视觉原型。
3. 灾变领域模块、家园、区域地图和搜刮界面的边界在哪里。
4. 下一位接手者应按什么顺序继续，避免回到旧路线。
5. 如何验证项目，如何处理 Godot 导入、日志和 Windows 启动问题。

---

## 1. 接手后先读什么

建议按以下顺序阅读：

1. `AGENTS.md`：仓库级工作规范、架构原则和资源安全要求。
2. 本文件 `HANDOFF.md`：当前事实状态和下一步。
3. `task_plan.md`：当前 Phase、阶段路线和 Stop Rules。
4. `CONTEXT.md`：已有领域术语和长期方向。
5. `progress.md`：最近完成的工作记录。
6. `findings.md`：实现过程中发现的技术问题和决策依据。
7. 与当前任务直接相关的场景、脚本和测试，不要一开始通读所有旧原型。

### 当前治理状态

`AGENTS.md`、`task_plan.md`、默认主场景与本文已经同步为末日静态热点主线。旧牧场/生活模拟代码仍作为历史与可复用领域模块保留，但不是当前默认产品，也不是近期开发队列。判断当前事实时优先查看本文末尾最新章节和最新全量测试。

本次只重写交接文档，没有擅自修改 `AGENTS.md`。

---

## 2. 一分钟项目状态

### 当前已经能做的事

- 双击 `启动游戏.bat` 进入灾变家园。
- 家园是静态可点击地图，不再显示常驻移动头像。
- 直接点击主屋、储物棚、工作台、菜地和大门 5 个地图热区互动；热区位置和尺寸可在 Godot 中编辑。
- 主屋、储物、工作台和菜地会进入统一功能入口面板；大门进入县域区域地图。
- 大门可以进入县域区域地图。
- 区域地图能选择庇护所、诊所、市场、工业区等地点并显示选择状态。
- 独立的诊所搜刮评审场景已经能调用真实搜刮领域：搜索容器、逐件揭示物品、消耗时间和体力、增加噪音、显示稀有度，并把物品放进灾变背包。
- 灾变存档与普通生活存档已经在领域和仓储层隔离。
- 上一轮全量测试记录仅可作历史参考；本次热区改造后的 Godot 导入、自动测试和启动结果需以新的验证日志为准。

### 当前还不能形成完整游戏循环的地方

- 家园内除大门外的功能区只会打开说明面板，尚未调用真实储物、工作台、休息或种植系统。
- 区域地图地点按钮目前只更新文本，没有真正进入诊所搜刮场景。
- 诊所搜刮仍位于 `scenes/reviews/`，尚未转成正式游戏流程。
- 搜刮完成后没有正式返回区域地图/家园并保存世界状态的闭环。
- 完整的胸挂、背包、保险箱、装备栏、固定免费空间和拖放式格子背包 UI 尚未完成。
- D20 领域已经存在，但还没接入搜索、剧情、交涉、受伤和风险选择。
- NPC 入住、居民岗位、恋爱、前 7 天剧情、感染、伤势、口粮、夜间结算均未完成。
- 没有实时战斗；这是当前设计决定，不是缺陷。

### 当前真实流程

```text
启动游戏.bat
    ↓
灾变家园（静态背景 + 5 个可编辑点击热区）
    ├─ 主屋 / 储物 / 工作台 / 菜地 → 统一功能入口面板，等待真实领域 UI 接入
    └─ 大门
         ↓
县域区域地图（静态卫星式地图）
    ├─ 庇护所 → 可返回家园
    ├─ 诊所 → 目前只更新选择提示，尚未跳转
    ├─ 市场 → 目前只更新选择提示
    └─ 工业区 → 目前只更新选择提示

独立评审入口：诊所搜刮场景
    ↓
真实搜索容器 / 时间 / 体力 / 噪音 / 物品揭示 / 背包放置
    ↓
评审专用自动存档
    ↓
尚未接回区域地图和正式灾变存档槽
```

---

## 3. 已确认的产品方向

以下方向已经经过用户多轮确认。除非用户明确改变，不要重新展开大范围路线讨论。

### 3.1 主模式

- 近期只做丧尸末日生存模式。
- 普通牧场模式暂时隐藏，不删除其系统和资源。
- 荒野求生、普通经营牧场可作为以后独立模式或时间线扩展，但不属于当前垂直切片。
- 游戏不是实时动作游戏，也不制作实时战斗。
- 主要体验是资源规划、外出搜刮、文字事件、D20 判定、家园经营、种植、居民关系和生存压力。

### 3.2 世界背景

- 起始区域参考江西赣州上犹县一类的中国南方县城和周边山地。
- 使用虚构地名和虚构地点，避免把内容锁死为真实行政区域。
- 区域既有县城、医院/诊所、市场、学校、工厂、居民区，也有村落、田地、河流、水库和山地。
- 后期可以扩展到中国境内其他区域，甚至世界范围；数据结构不要写死在一个县。

### 3.3 家园表现

- 家园/庇护所保留 2D 地图。
- 地图是俯视或高位俯视的固定插图，不需要 TileMap 重制整张背景。
- 家园不显示常驻玩家头像；玩家通过直接点击地图上清晰的功能建筑进入 UI。
- 不需要全身角色模型、方向动画、实时换装、复杂骨骼或地图行走碰撞。
- 建筑、功能区和大门使用 Godot 中可视化编辑的透明 `Button` 热区，不使用 `CollisionShape2D` 或 `Area2D`。
- 热区必须随地图上的实际建筑分布，不做脱离地图的一排大按钮。
- 主屋可以有独立室内图；鸡舍、畜棚、储物棚等次要建筑可以直接打开 UI，不必都制作可行走室内。

### 3.4 外出地点表现

- 家园外的大多数地点不需要可行走 2D 地图。
- 每个地点使用一张固定插图、文字说明、热点/容器、事件选项和 UI 表现。
- 地点插图不负责碰撞；可搜索区域和容器由可编辑的 Godot 控件或区域定义。
- 县域大地图使用俯视卫星地图式构图，带庇护所位置和地点标记。
- 可以参考 Google 地图/真实卫星地图的构图与信息密度，但发行版应优先使用原创生成图或具有明确授权的底图，不直接依赖 Google 截图。

### 3.5 搜刮和背包

- 搜刮参考《三角洲行动》的信息揭示节奏，但不是复制其 UI。
- 未搜索物品先以未知轮廓或占格形状存在，已经占用容器空间。
- 搜索后逐件揭示具体物品、名称、稀有度和价值。
- 搜索需要消耗时间，并可能产生噪音、触发风险或 D20 检定。
- 物品有矩形格子尺寸、重量、稀有度和类别。
- 角色携带结构包括：
  - 固定免费空间/口袋：即使没有装备也能携带少量物品。
  - 胸挂。
  - 背包。
  - 保险箱/安全容器。
  - 装备栏。
- 背包采用格子摆放，不是简单列表。
- 稀有度顺序固定为：灰 → 绿 → 蓝 → 紫 → 金。
- 红色不用作常规物品品质；红色保留给危险、受伤、感染、警报和失败反馈。

### 3.6 D20 与战斗

- D20 用于搜索、观察、撬锁、修理、治疗、交涉、逃离、剧情分支和代价判定。
- D20 不只是“成功/失败”，需要支持失败推进、付出代价的成功、重大成功和重大失败。
- 不做实时战斗。
- 遭遇敌人时可以用文字、装备准备、距离、环境、资源投入和 D20 处理。
- 用户尚未要求删除战斗概念，只是明确不做实时操作战斗。

### 3.7 居民和关系

- 种植、家园经营、NPC 关系和恋爱仍是核心内容，不因转向灾变而删除。
- 居民不能一开始就永久入住；必须通过剧情、信任和条件后才真正住进家园。
- 家园后续可有居民岗位、工作分配、关系推进和至少一条恋爱线。
- 当前阶段不要先做大规模 NPC 名单，应先跑通一个居民从相遇到入住的垂直切片。

### 3.8 美术方向

- 灾变内容不再要求完全贴近 Super Retro World - Farming。
- 灾变主美术应统一为阴暗、磨损、低饱和、写实像素/手绘像素混合的末日风格。
- 固定背景插图可以比角色和图标更细致，不需要为了碰撞严格限制像素点。
- 旧普通生活线仍可保留 Super Retro 作为开发基线，但不要强行把灾变 UI 和县城场景改回明亮农场风。
- 若需要新图，优先把明确提示词、尺寸、透明要求和参考图告诉用户，由用户手动在 GPT 生图，节省 Codex 额度。

---

## 4. 当前阶段与近期优先级

`task_plan.md` 当前定义：

> **Phase 3：灾变时间线前 7 天垂直切片（进行中）**

阶段路线大致为：

1. Phase 3：灾变领域与存档隔离。
2. Phase 4：外出搜刮与战术 UI。
3. Phase 5：灾变家园与居民。

目前 Phase 3 的底层核心已经基本存在，但前 7 天内容和正式游戏流程仍未完成。Phase 4 有真实搜索原型，Phase 5 有可运行家园外壳。因此当前不是纯粹线性地“只做 Phase 3”，而是为了垂直切片先搭出了三个阶段的最小骨架。

### 当前唯一合理的近期目标

把现有三个孤立部分接成一个最小闭环：

```text
家园 → 大门 → 区域地图 → 诊所 → 搜索一个容器 → 带回物资 → 返回家园 → 存档 → 重新启动后状态保留
```

在这个闭环完成前，不应继续扩建大量地点、NPC、商店、料理或复杂 UI 动画。

---

## 5. 运行入口、分辨率和操作

### 5.1 默认入口

`project.godot`：

```ini
run/main_scene="res://scenes/world/apocalypse_shelter.tscn"
```

用户明确指的是根目录的：

```text
D:\Archer\Project X\启动游戏.bat
```

不要只验证 Godot 编辑器里的当前场景；必须同时验证这个批处理入口。

### 5.2 显示基线

- 内部视口：480×270。
- 默认窗口：1440×810。
- PC 优先。
- 纹理使用 nearest 过滤，保持像素边缘。
- 场景背景图可按视口缩放，UI 要在 16:9 下稳定。

### 5.3 当前操作

家园：

- 移动：InputMap 中的 `move_left`、`move_right`、`move_up`、`move_down`，通常对应 WASD/方向键。
- 互动：`interact`，当前提示显示为 `E`。
- 走到互动区附近后出现提示。

区域地图：

- 鼠标点击地点标记。
- `Esc` / `ui_cancel` 返回家园。
- 返回按钮也可返回家园。

---

## 6. 灾变家园：当前正式主场景

### 6.1 关键文件

- 场景：`scenes/world/apocalypse_shelter.tscn`
- 行为：`src/world/apocalypse_shelter.gd`
- 背景：`assets/art/apocalypse/shelter/apocalypse_shelter.png`
- 玩家头像：`assets/art/apocalypse/characters/survivor_avatar.png`
- 视觉测试：`tests/test_apocalypse_shelter_visual_review.gd`

### 6.2 场景职责

这个场景是当前默认游戏入口和正式灾变家园展示层，职责是：

- 显示家园大院背景。
- 显示左上角状态头像。
- 显示可移动的小型圆形头像标记。
- 读取场景中可视化编辑的边界、障碍物和互动区。
- 处理玩家在家园中的简化移动和碰撞。
- 在接近互动区时显示提示。
- 打开功能面板或切换到区域地图。

它目前**不负责**灾变 Session 的完整加载、储物、种植、工作台、睡眠和居民状态。

### 6.3 可视化碰撞结构

场景中已保存：

- `Collision/Walls`：4 个边界碰撞。
- `Collision/Obstacles`：5 个障碍物。
  - `MainHouse`
  - `AnimalPens`
  - `StorageShed`
  - `Workbench`
  - `FarmBeds`
- `Collision/InteractionZones`：5 个互动区域。
  - `main_house`：主屋 · 休息与生活
  - `storage`：储物柜 · 管理物资
  - `workbench`：工作台 · 制作准备
  - `farm_beds`：菜地 · 种植维护
  - `gate`：大门 · 外出搜刮

这些节点是正式制作来源。需要修改位置、尺寸或范围时，应在 Godot 编辑器里移动/缩放对应节点，不要把新坐标写死在脚本生成器中。

### 6.4 当前交互行为

- `gate`：立即切换到 `apocalypse_region_map.tscn`。
- 其他四个区域：打开 `ZoneActionPanel`，显示描述和行动按钮。
- 当前行动按钮仅显示“行动准备完成”并关闭面板，没有真正修改领域状态。

因此，主屋、储物、工作台和菜地现在是**视觉和交互入口已完成、领域功能尚未接入**。

### 6.5 当前 UI 资源

家园已正式使用：

- `ui/frames/avatar_frame.png`
- `ui/frames/interaction_prompt.png`
- `ui/frames/zone_panel.png`

面板采用 Godot `StyleBoxTexture` 和九宫格边距，不应把整张图当作不可拉伸按钮直接缩放。

### 6.6 头像修复历史

用户不接受早期方形或椭圆头像，当前要求是接近《活下去》的小型圆形状态头像表现。

已经处理：

- 左上角状态头像使用圆形框。
- 移动头像保持 24×24 正方形显示区域，避免圆形图被压成椭圆。
- 头像本体和边框分离，不再让头像黑底与旧 UI 混在一起。

如果再次修改头像，先检查原图是否真的带 Alpha；不要只凭图片查看器的棋盘/灰底判断透明。

### 6.7 仍需改进

- 左上角状态 HUD 只有头像，缺少健康、体力、饥饿、口渴、时间和异常状态的正式布局。
- 互动面板仍是最小可用版，尚未应用全部新 UI 素材。
- 移动碰撞采用矩形障碍检查，足够当前简化玩法，但未来若背景改变需要在编辑器重新校准。
- 主屋室内图尚未接入。
- 当前启动后的手动视觉截图需要重新确认一次，自动测试和无头启动不能替代最终视觉验收。

---

## 7. 县域区域地图

### 7.1 关键文件

- 场景：`scenes/world/apocalypse_region_map.tscn`
- 脚本：`src/world/apocalypse_region_map.gd`
- 背景：`assets/art/apocalypse/world/apocalypse_region_map.png`

### 7.2 当前表现

- 使用县域级卫星地图式固定背景。
- 地图中有山地、河流、水库、道路、县城、村落和庇护所位置。
- 有庇护所、诊所、市场、工业区等地点标记。
- 点击地点后只更新状态文字：`选择出发后进入搜刮`。
- `Esc` 或返回按钮回到家园。

### 7.3 当前缺口

- 地点按钮没有稳定地点 ID，只把按钮文字绑定给回调；正式实现应使用稳定 ID。
- 诊所没有跳转到真实搜刮场景。
- 没有路程、耗时、天气、危险度、交通工具、负重或返程判定。
- 没有从 `ApocalypseSession.discovered_locations` 控制显示和解锁。
- 没有保存玩家当前区域位置。

### 7.4 推荐接法

不要让区域地图直接拥有灾变领域真相。建议：

1. 地点标记保存稳定 `location_id`。
2. 点击后只发出“请求前往地点”的意图。
3. 上层流程控制器根据 Session、时间、负重、天气和剧情决定是否允许出发。
4. 允许后进入正式地点场景或地点适配器。
5. 地图只负责展示地点状态、威胁和选择反馈。

---

## 8. 诊所搜刮评审场景

### 8.1 关键文件

- 场景：`scenes/reviews/apocalypse_explore_review.tscn`
- 脚本：`src/review/apocalypse_explore_review.gd`
- 地点图：`assets/art/apocalypse/locations/county_clinic.png`
- 视觉测试：`tests/test_apocalypse_explore_visual_review.gd`

### 8.2 当前已经接入的真实能力

这个场景不是纯假 UI，已经接入以下领域模块：

- `ApocalypseSearchContainer`
- `ApocalypseSession`
- `TimelineSaveRepository`

当前热点：

- 前台：钥匙。
- 药柜：医疗包、绷带。
- 救护车：燃油桶。
- 后室：剧情锁定。

当前搜索行为：

1. 选择热点/容器。
2. 搜索消耗真实 Session 时间和体力。
3. 每次揭示一件物品。
4. 增加噪音。
5. 显示稀有度、类别、耗时和噪音。
6. 将揭示物品放入灾变背包格子。
7. 容器搜索状态能生成快照。

初始背包中有水。

场景启动日志：

```text
APOCALYPSE_EXPLORE_REVIEW_READY hotspots=4 loadout_containers=4
```

### 8.3 当前存档位置

离开评审地点后会锁定进一步操作，并自动保存到评审专用路径：

```text
user://saves/apocalypse_review/auto_1
```

这不是最终灾变正式存档槽，只是为了验证领域和持久化。

### 8.4 当前缺口

- 场景还在 `reviews` 目录，未作为正式地点接入。
- 区域地图不能进入它。
- 离开后不能回到区域地图或家园。
- 搜刮结果没有进入正式的灾变存档槽和家园储物。
- 当前 UI 布局仍偏原型，尚未全面使用新生成的容器框、稀有度框和状态图标。
- 没有完整的拖放、旋转、交换、溢出处理和丢弃确认。
- 没有 D20、敌情、感染、受伤或剧情后果。
- “搜索中先看轮廓、搜索完才显示具体物品”的领域基础已具备，但视觉揭示过程仍可加强。

### 8.5 正式化建议

不要直接把评审脚本继续堆大。建议分三步：

1. 抽出地点定义/容器配置资源，使用稳定地点和容器 ID。
2. 建立正式地点展示场景，复用评审里已经验证的搜索流程。
3. 让区域地图通过流程控制器进入地点，并在退出时把 Session 带回家园。

评审场景可保留为视觉和领域回归入口，不必删除。

---

## 9. 灾变领域模块

目录：`src/domain/apocalypse/`

领域层不应引用 Godot 场景节点、贴图尺寸、坐标或具体 UI。跨边界使用稳定 ID、值对象和纯字典快照。

### 9.1 `D20Check`

文件：`src/domain/apocalypse/d20_check.gd`

接口：

```gdscript
resolve(natural_roll, difficulty, modifier = 0)
```

结果类型：

- `major_failure`
- `failure_forward`
- `costly_success`
- `success`
- `major_success`

自然 1 和自然 20 有特殊覆盖规则。

模块内部不随机掷骰；掷骰来源应由上层提供，便于测试、回放和将来做种子。

### 9.2 `SurvivorState`

文件：`src/domain/apocalypse/survivor_state.gd`

属性：

- 体能 `fitness`
- 反应 `reaction`
- 观察 `observation`
- 知识 `knowledge`
- 意志 `will`
- 交涉 `negotiation`

状态：

- 生命值，初始上限 100。
- 饥饿。
- 口渴。
- 疲劳。
- 压力。
- 伤势列表。
- 隐藏感染风险 0–100。

感染风险不应直接把精确数值展示给玩家，UI 应显示症状、怀疑程度或风险提示。

### 9.3 `ApocalypseGridContainer`

文件：`src/domain/apocalypse/grid_container.gd`

能力：

- 矩形格子容器。
- 按物品宽高放置。
- 边界和重叠校验。
- first-fit 自动寻找位置。
- 移除物品。
- 揭示隐藏物品。
- 计算重量和负重状态。
- 版本化快照。

负重状态包括：

- `light`
- `normal`
- `overweight`
- `severely_overweight`

UI 只能提交放置/移动意图，不能自己维护另一份背包真相。

### 9.4 `ApocalypseSearchContainer`

文件：`src/domain/apocalypse/search_container.gd`

能力：

- 未知物品预先占格。
- 单件逐步揭示。
- 物品稀有度和类别。
- 单次搜索耗时。
- 搜索噪音。
- 容器状态：
  - `unsearched`
  - `partial`
  - `searched`
- 版本化快照。

### 9.5 `ApocalypseSession`

文件：`src/domain/apocalypse/apocalypse_session.gd`

它是当前灾变单局状态的主要聚合入口，组合：

- 既有 `GameSession` 时间/规则。
- `SurvivorState`。
- 固定免费空间 `pockets`。
- `chest_rig`。
- `backpack`。
- `secure_pouch`。
- 当前区域 ID 和威胁。
- 已发现地点。
- 行动耗时、睡眠、物品放置和获取。
- 版本化快照与恢复。

时间线类型固定为：

```text
apocalypse
```

装备栏的完整领域模型和 UI 还没有最终完成，接手时不要假设现有四容器已经覆盖全部装备需求。

---

## 10. 存档隔离

关键文件：

- `src/adapters/persistence/timeline_save_repository.gd`
- `src/domain/apocalypse/apocalypse_session.gd`

核心规则：

- 普通生活时间线与灾变时间线必须使用不同 `timeline_kind`。
- 灾变存档不能覆盖普通生活存档。
- 加载时必须校验时间线类型，不能跨类型恢复。
- UI 不应自己拼存档路径或直接写领域字段。
- 当前诊所评审使用的是独立评审路径，不等于正式灾变存档槽。

下一步做正式闭环时，应先确定：

1. 正式灾变手动槽/自动槽路径。
2. 从家园进入区域地图、进入地点和返回时的保存时机。
3. 搜刮容器状态是否属于地点持久状态。
4. 死亡、丢包、保险箱保留物和重新出发的恢复规则。
5. 版本迁移策略。

不要为每个场景各做一套临时存档。

---

## 11. 可复用的普通生活系统

普通生活线不是当前入口，但已经完成了大量可复用领域工作，不得删除或重写为灾变专用脚本。

关键入口：

- `scenes/world/home_region.tscn`
- `src/world/home_region.gd`

已存在并通过测试的能力包括：

- 日历、时间、季节和天气。
- 体力和行动耗时。
- 睡眠、跨日结算和多日恢复。
- 背包/库存。
- 农田状态、播种、浇水、成长和收获。
- 鸡和鸡舍领域。
- 食材来源。
- 自由组合料理。
- 普通时间线存档。

旧 Phase 2 的正式 `HomeRegion` 曾达到：

```text
HOME_REGION_READY size=960x544 interactables=225
```

这些系统未来可以作为灾变家园中的适配来源：

- 时间和天气 → 灾变行动、夜晚和外出风险。
- 农业 → 家园菜地、食物安全。
- 鸡/动物 → 灾变畜牧和饲料压力。
- 料理 → 口粮、恢复、疾病和居民偏好。
- 关系 → 居民信任、入住和恋爱。

复用时应通过适配器或小接口连接，不要把普通 `HomeRegion` 整个嵌进灾变家园，也不要让灾变 UI 直接操作旧场景节点。

---

## 12. 当前美术资源清单

根目录：`assets/art/apocalypse/`

### 12.1 家园和地图

- `shelter/apocalypse_shelter.png`：当前家园大院正式背景。
- `shelter/main_house_interior.png`：主屋俯视室内图，尚未接入。
- `world/apocalypse_region_map.png`：当前县域卫星式区域地图。
- `locations/county_clinic.png`：诊所/卫生院固定地点插图。

### 12.2 角色

- `characters/survivor_avatar.png`：当前圆形兜帽幸存者头像。

头像只需要承担状态头像和家园移动标记，不要再要求生成全身四方向行走图。

### 12.3 物品图标

- `items/water.png`
- `items/medkit.png`
- `items/bandage.png`

这些早期图片曾包含黑色背景，诊所评审使用过着色器/抠色式处理。替换前要检查实际 Alpha 和当前材质引用，不能只替文件后假设透明正确。

### 12.4 UI 框体

`ui/frames/`：

- `avatar_frame.png`
- `interaction_prompt.png`
- `zone_panel.png`

这些已经用于家园正式 UI。

### 12.5 稀有度框

`ui/rarity/`：

- `common.png`
- `uncommon.png`
- `rare.png`
- `epic.png`
- `gold.png`

品质顺序：灰、绿、蓝、紫、金。金框是最高品质。红框方案已经放弃作为品质框。

### 12.6 容器图标

`ui/containers/`：

- `ambulance.png`
- `backpack.png`
- `crate.png`
- `drawer.png`
- `locker.png`
- `medical_cabinet.png`
- `secure_case.png`
- `trunk.png`

这些已经整理进项目，但大部分尚未接入正式搜刮 UI。

### 12.7 背包格子

`ui/slots/`：

- `inventory_slot.png`
- `slot_hover_blue.png`
- `slot_hover_gold.png`

需要通过 Godot Theme/StyleBox 或可复用 Slot 场景使用，不要为每个格子复制一张大图片。

### 12.8 状态图标

`ui/status/`：

- `hunger.png`
- `thirst.png`
- `injury.png`
- `infection.png`
- `noise.png`
- `noise_warning.png`
- `time_warning.png`

感染应显示模糊风险/症状提示，不显示隐藏感染精确值。

### 12.9 地图标记

`ui/markers/`：

- `player_marker.png`
- `selection_ring.png`

另外，`D:\下载` 中的 `ChatGPT Image 2026年8月2日 22_43_55.png` 是一张地点图标合集，目前尚未拆分和接入。使用前需要：

1. 确认 Alpha。
2. 按一致尺寸拆分。
3. 给每个图标建立稳定语义名称。
4. 导入 Godot 后再接区域地图。

### 12.10 资源来源与发布风险

- 多张图由用户手动通过 GPT 生成。
- 原始生成文件多数仍在 `D:\下载`。
- 项目内图片已经做过裁剪、透明处理和重命名。
- 正式发行前必须确认生成平台商业授权、第三方素材许可证和地图底图权利。
- `assets/private/` 中的旧参考资源不得公开、删除或移动到公开资产目录。

---

## 13. 已有生图提示词文档

后续需要用户生成新图时，优先复用和修订以下文档：

- `docs/APOCALYPSE_SHELTER_ART_PROMPT.md`
- `docs/APOCALYPSE_WORLD_MAP_AND_INTERIOR_PROMPTS.md`
- `docs/APOCALYPSE_LOCATION_ART_PROMPT.md`
- `docs/APOCALYPSE_ITEM_ICON_PROMPTS.md`
- `docs/APOCALYPSE_UI_ART_PROMPTS.md`

向用户索要新图时必须说明：

- 用途。
- 目标尺寸和宽高比。
- 视角：正俯视、卫星式、正面地点插图或 UI 正交图。
- 是否必须真透明 Alpha。
- 是否允许阴影、辉光和外发光。
- 是否需要留出文字区。
- 是否要求可九宫格拉伸。
- 参考图路径。
- 禁止项，例如透视错误、人物、文字、水印、假棋盘透明底、巨大空白边缘。

用户明确希望自己手动生图以节省 Codex 额度。除非用户再次授权，不要直接调用生图工具批量生成。

---

## 14. 架构与制作规则

### 14.1 场景/资源是表现层正式来源

凡是 Godot 能编辑的内容，正式版本必须保存在场景或资源里：

- 地图和背景图引用。
- Sprite/TextureRect 摆放。
- 障碍碰撞。
- 互动区域。
- 出生点。
- UI 布局。
- Theme、StyleBox 和字体。
- 动画帧。
- 地点热点。
- 策划可调参数。

代码只负责：

- 行为。
- 领域规则。
- 状态变化。
- 存档。
- 校验。
- 动态运行效果。

不要再次用代码生成正式地图、碰撞箱、农田格子或整套 UI 布局。运行时缺图 fallback 可以存在，但不是制作源。

### 14.2 领域和展示分离

- 领域只认识稳定 ID、数字、枚举和值快照。
- 场景节点和贴图尺寸不能进入领域快照。
- UI 不拥有库存、搜索、时间、伤势或关系真相。
- 地点场景只发出意图并显示领域结果。
- 存档仓储负责路径、版本和时间线隔离。

### 14.3 不要新增万能 Manager

新增流程前先判断它属于：

- 灾变 Session。
- 旅行/地点流程控制。
- 展示适配器。
- 存档仓储。
- 具体领域模块。

不要创建一个同时控制地图、背包、NPC、时间、存档和 UI 的全局 Manager。

### 14.4 文本编码

场景和脚本中的中文实际为 UTF-8。PowerShell 或旧终端偶尔会显示乱码，先使用：

```powershell
Get-Content -Encoding utf8 <文件>
```

或使用 `rg` 检查，不要看到终端乱码就批量重写文件。

---

## 15. 自动测试

测试入口：`tests/test_runner.gd`

灾变专项测试：

- `tests/test_d20_check.gd`
- `tests/test_survivor_state.gd`
- `tests/test_grid_container.gd`
- `tests/test_search_container.gd`
- `tests/test_apocalypse_session.gd`
- `tests/test_apocalypse_explore_visual_review.gd`
- `tests/test_apocalypse_shelter_visual_review.gd`

家园视觉测试当前会检查：

- 5 个互动区。
- 5 个障碍物。
- 4 个墙体边界。
- 左上角状态头像。
- 可移动头像。
- 行动面板。
- 区域地图资源。
- 家园背景、头像和核心 UI 框资源。
- 金色最高稀有度资源。

最近一次直接运行结果：

```text
GAME_CLOCK_READY day=1 time=06:00
WORLD_READY actions=16 targets=10 selection=true
HOME_REGION_READY size=960x544 interactables=225
APOCALYPSE_EXPLORE_REVIEW_READY hotspots=4 loadout_containers=4
TESTS_PASSED assertions=555
```

对应日志：

```text
D:\Archer\Project X\tmp\godot_logs\tests_final.log
```

测试通过只说明结构和规则没有回归，不代表 UI 已经完成视觉验收。

---

## 16. 标准验证流程

每次加入新 PNG、`.tres` 或场景资源后，按以下顺序验证。

### 16.1 第一步：让 Godot 完整导入资源

```powershell
.\scripts\run_godot.ps1 --headless --editor --path 'D:\Archer\Project X' --quit-after 300
```

原因：新 PNG 如果还没有 `.import`，直接无头加载可能报：

```text
No loader found for resource
```

过去使用很短的 `--quit-after` 会在资源扫描完成前退出。对一批新图片，使用 300 帧更稳妥。

### 16.2 第二步：运行全量测试

优先：

```powershell
.\scripts\test_project.ps1
```

Windows 上该包装脚本偶尔会在日志已经出现 `TESTS_PASSED` 时仍返回退出码 1。遇到这种情况不要立即判定失败，检查最新日志：

```powershell
Get-ChildItem '.\tmp\godot_logs\tests_*.log' |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1
```

然后查看是否包含：

```text
TESTS_PASSED
TESTS_FAILED
SCRIPT ERROR
```

也可以直接运行：

```powershell
$godotExe = 'D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe'
& $godotExe `
  --headless `
  --path 'D:\Archer\Project X' `
  --script 'D:\Archer\Project X\tests\test_runner.gd' `
  --log-file 'D:\Archer\Project X\tmp\godot_logs\tests_handoff.log'
```

### 16.3 第三步：验证用户真正使用的入口

```powershell
cmd.exe /c "启动游戏.bat --headless --quit-after 60"
```

当前预期关键日志：

```text
APOCALYPSE_SHELTER_READY zones=5 obstacles=5 collision_walls=4
```

### 16.4 第四步：手动视觉验收

双击：

```text
D:\Archer\Project X\启动游戏.bat
```

至少检查：

1. 首屏是家园，不是区域地图。
2. 左上角头像是圆形，没有黑底、噪点、椭圆或裁切错误。
3. 移动头像是小型圆形标记，不是大人物立绘。
4. 玩家不能穿过主屋、畜棚、储物棚、工作台和菜地。
5. 接近功能区会出现提示。
6. 按 `E` 能打开面板。
7. 大门能进入区域地图。
8. `Esc` 能返回家园。
9. UI 不遮住大面积家园画面。
10. 16:9 窗口缩放下没有明显错位。

最后一次改完核心 UI 后尚未留下一张新的正式视觉截图，因此下一位接手者应把这一步当作必做，而不是依赖 555 个断言。

---

## 17. Windows/Godot 已知问题

### 17.1 Godot 4.7.1 日志崩溃

曾出现 Godot 在共享 `user://logs` 轮换日志时崩溃或访问无效内存。

已修复方式：

- `scripts/run_godot.ps1` 将 `APPDATA`、`LOCALAPPDATA`、`TEMP`、`TMP` 指向项目使用的 D 盘便携环境。
- 每次运行使用项目 `tmp/godot_logs` 下的唯一日志文件。

不要绕过这个脚本直接恢复共享日志路径，除非已经确认问题不再出现。

### 17.2 启动路径带空格

项目目录包含空格：`Project X`。

`启动游戏.bat` 已修复为正确引用 `%~dp0.`。后续修改批处理时必须保留路径引号。

### 17.3 根证书警告

无头运行可能出现根证书相关警告，通常不影响本项目脚本和测试。判断失败应优先看：

- `SCRIPT ERROR`
- `TESTS_FAILED`
- 场景加载错误
- 资源导入错误

不要只因证书警告就重装 Godot。

### 17.4 旧 EditorScript 错误

以前出现过检查脚本被错误地当作场景运行，报“不继承 SceneTree 或 MainLoop”。如果未来确实需要编辑器脚本，它必须继承 `EditorScript`，并通过正确方式从编辑器运行。

当前制作尽量直接使用 Godot 编辑器和正常测试，不要再添加一次性运行时地图生成脚本。

---

## 18. 当前已知缺口和风险

### P0：阻止垂直切片闭环

1. 区域地图不能进入诊所正式搜刮。
2. 搜刮场景不能返回区域地图/家园。
3. 搜刮获得物没有进入正式灾变存档槽。
4. 家园储物区没有连接灾变库存。
5. 启动、外出、搜刮、返回、重启后的状态保持尚未验证。

### P1：核心玩法不完整

1. 完整格子背包 UI 未完成。
2. 胸挂、背包、保险箱、口袋和装备栏没有完整可视化。
3. 搜索的未知轮廓揭示还不够清楚。
4. D20 未接地点行为。
5. 负重、时间、噪音和危险没有形成真实取舍。
6. 主屋休息、工作台制作和菜地种植仍是占位功能。

### P2：内容和长期循环

1. 前 7 天剧情没有完整事件表。
2. 没有首位可招募居民和入住剧情。
3. 没有家园岗位和居民日程。
4. 没有恋爱垂直切片。
5. 没有夜间结算、天气威胁、感染症状和伤势恢复。
6. 没有死亡/撤离失败/丢包/保险箱保留规则。

### 视觉风险

1. 新 UI 素材来源风格并非完全一致，需要在 Godot 实际缩小到使用尺寸后再筛选。
2. 多数源图为 1024×1024，直接缩成几十像素可能糊、噪点多或边框过厚。
3. “看起来透明”的图片可能只是灰色背景；必须检查 Alpha 通道。
4. 物品图标和背景图细节密度差异较大，需要统一展示尺度。
5. 家园静态图内已经画有动物和设施，未来状态变化可能与背景中的固定内容冲突。短期可以接受，长期需决定是否分层或用状态覆盖。

### 架构风险

1. 不要把评审场景直接扩成万能玩法场景。
2. 不要让区域地图以按钮文本作为正式地点 ID。
3. 不要在 UI 中复制一套库存状态。
4. 不要让灾变存档覆盖普通时间线。
5. 不要因为静态背景图方便，就把全部交互坐标硬编码到脚本。

---

## 19. 推荐的下一轮实现计划

### 第一步：把诊所接入正式流程

目标：从区域地图点击诊所后进入真实搜刮场景。

工作：

1. 给区域地图标记加入稳定 `location_id`。
2. 把诊所评审逻辑拆出可复用的地点/容器配置。
3. 新建正式地点场景或把评审场景包装为正式适配器。
4. 进入地点时传入同一个 `ApocalypseSession`。
5. 离开地点时返回区域地图。

验收：

- 从 `启动游戏.bat` 开始，不借助编辑器单场景运行即可走通家园 → 区域地图 → 诊所。
- 搜索至少一个药柜物品后能离开。
- 返回地图时 Session 时间、体力、噪音和背包内容仍在。

### 第二步：接正式灾变存档

目标：完成最小持久化闭环。

工作：

1. 定义正式灾变自动存档槽。
2. 家园启动时加载或创建灾变 Session。
3. 外出/返回时保存。
4. 容器搜索状态、已获取物品和地点发现状态进入快照。
5. 保持普通时间线完全隔离。

验收：

- 搜到绷带后回家、退出游戏、重新启动，绷带仍在。
- 已搜空的药柜不会重新生成同一批物资。
- 普通生活存档不受影响。

### 第三步：接家园储物区

目标：让家园第一个非大门功能区成为真实功能。

推荐先做储物，不先做工作台或完整农业，因为储物能验证外出物资回流。

工作：

1. 走到 `storage` 区域按 `E`。
2. 打开正式背包/储物 UI。
3. 显示口袋、胸挂、背包、保险箱和家园储物。
4. 移动物品时调用领域容器命令。
5. 关闭 UI 后状态保留并自动保存。

验收：

- 能把诊所获得的物品从背包放进家园储物。
- 重启后物品位置一致。
- UI 节点可在 Godot 中移动和调整，不由脚本生成正式布局。

### 第四步：完成最小战术背包 UI

目标：实现可玩的格子管理，不追求一次完成所有美术。

最低能力：

- 固定免费口袋。
- 胸挂。
- 背包。
- 保险箱。
- 装备栏占位。
- 物品尺寸占格。
- 拖动、交换失败反馈、越界反馈。
- 重量和负重状态。
- 稀有度框。
- 未知物品轮廓与搜索后揭示。

先保证领域真相、交互和可读性，再做复杂动画。

### 第五步：接主屋休息与时间推进

目标：开始形成“外出—回家—恢复—下一天”的循环。

- 主屋进入室内图或打开生活 UI。
- 休息消耗时间并恢复部分状态。
- 睡眠推进到下一天。
- 饥饿、口渴、疲劳和伤势按规则结算。
- 预留居民床位和主屋升级接口。

### 第六步：再接工作台与菜地

顺序建议：

1. 工作台：修理/制作一个最小配方。
2. 菜地：复用旧农业领域，先实现少量灾变作物。
3. 居民：一名幸存者从相遇、信任到入住。
4. 前 7 天事件：围绕上述系统编排，而不是先写大量孤立文本。

---

## 20. 下一阶段的完成定义

“前 7 天垂直切片”至少应满足：

- 玩家从家园开始。
- 有清晰的时间、健康、体力、饥饿、口渴和异常状态 HUD。
- 可以从大门进入区域地图。
- 至少一个地点可正式进入和搜索。
- 搜刮使用逐件揭示、噪音、耗时、稀有度和格子背包。
- 至少一次 D20 判定会改变结果和代价。
- 能带物资回家并放入储物。
- 能休息、睡眠和进入下一天。
- 菜地至少有一个可种植、浇水、成长、收获的作物。
- 至少一名 NPC 有相遇、信任和未来入住条件。
- 保存退出后能继续。
- 普通时间线不被覆盖。
- 所有正式碰撞、互动区和 UI 布局都能在 Godot 编辑器中查看和调整。
- 自动测试、无头启动和手动视觉验收全部通过。

---

## 21. 明确不要做的事

- 不要把普通牧场重新设为默认入口。
- 不要删除旧农业、鸡、料理、关系或普通存档模块。
- 不要现在扩建商店经营、完整职业系统或大量普通居民。
- 不要制作实时战斗系统。
- 不要为家园制作复杂全身角色动画；当前圆形头像移动是确认方向。
- 不要为每个外出地点制作完整可行走地图。
- 不要在代码中生成正式地图、功能区坐标、碰撞箱和 UI 布局。
- 不要用红色作为普通物品稀有度最高级；最高品质用金色。
- 不要直接公开或移动 `assets/private/`。
- 不要未经确认删除用户在 `D:\下载` 或项目内保存的生成图。
- 不要用 `git reset --hard`、`git clean` 或类似命令清理当前工作区。
- 不要因为测试通过就宣称视觉已经完成。
- 不要继续堆评审脚本而不先接通正式流程。

---

## 22. Git 和文件安全

当前仓库没有可靠的提交基线。此前检查时大量文件仍显示为未跟踪，且用户身份配置可能不完整。

因此：

- 不要假设可以通过 Git 找回全部用户文件。
- 不要执行清理未跟踪文件的命令。
- 不要擅自提交大量私有素材。
- 修改前先检查 `git status --short`。
- 只编辑当前任务需要的文件。
- 如果要建立基线提交，必须先和用户确认私有资源、忽略规则和提交范围。

---

## 23. 关键文件索引

### 规划与交接

- `AGENTS.md`
- `HANDOFF.md`
- `task_plan.md`
- `CONTEXT.md`
- `progress.md`
- `findings.md`

### 启动与工程

- `project.godot`
- `启动游戏.bat`
- `编辑家园地图.bat`
- `scripts/run_godot.ps1`
- `scripts/test_project.ps1`

注意：`编辑家园地图.bat` 仍主要针对旧普通 `HomeRegion`，不是当前灾变家园的专用编辑入口。

### 灾变家园

- `scenes/world/apocalypse_shelter.tscn`
- `src/world/apocalypse_shelter.gd`
- `tests/test_apocalypse_shelter_visual_review.gd`

### 区域地图

- `scenes/world/apocalypse_region_map.tscn`
- `src/world/apocalypse_region_map.gd`

### 搜刮评审

- `scenes/reviews/apocalypse_explore_review.tscn`
- `src/review/apocalypse_explore_review.gd`
- `tests/test_apocalypse_explore_visual_review.gd`

### 灾变领域

- `src/domain/apocalypse/d20_check.gd`
- `src/domain/apocalypse/survivor_state.gd`
- `src/domain/apocalypse/grid_container.gd`
- `src/domain/apocalypse/search_container.gd`
- `src/domain/apocalypse/apocalypse_session.gd`
- `src/adapters/persistence/timeline_save_repository.gd`

### 普通生活可复用系统

- `scenes/world/home_region.tscn`
- `src/world/home_region.gd`
- `src/domain/`
- `src/adapters/persistence/`

### 测试

- `tests/test_runner.gd`
- `tmp/godot_logs/tests_final.log`

### 灾变美术

- `assets/art/apocalypse/README.md`
- `assets/art/apocalypse/shelter/`
- `assets/art/apocalypse/world/`
- `assets/art/apocalypse/locations/`
- `assets/art/apocalypse/characters/`
- `assets/art/apocalypse/items/`
- `assets/art/apocalypse/ui/`

---

## 24. 接手者执行清单

开始修改前：

- [ ] 阅读 `AGENTS.md`、本文件、`task_plan.md` 和 `CONTEXT.md`。
- [ ] 明确 `AGENTS.md` 当前优先级与实际灾变方向的文档冲突。
- [ ] 检查 `git status --short`，不要覆盖用户改动。
- [ ] 双击 `启动游戏.bat`，亲自看当前首屏。
- [ ] 确认首屏是灾变家园，头像为圆形，移动和大门正常。
- [ ] 运行全量测试，确认基线仍为 555 个断言通过。

本轮开发中：

- [ ] 只选择一个完整闭环目标。
- [ ] 先设计领域和展示之间的接口。
- [ ] 所有碰撞、热点和 UI 布局保存在场景/资源。
- [ ] 新 PNG 先完整导入 Godot。
- [ ] 新行为增加领域或场景测试。
- [ ] 保持普通/灾变存档隔离。

完成后：

- [ ] 全量测试通过。
- [ ] `启动游戏.bat` 无头启动通过。
- [ ] 手动视觉检查通过。
- [ ] 从正式入口实际走通新功能，而不是只运行评审场景。
- [ ] 更新 `task_plan.md`、`progress.md`、`findings.md` 和本交接文档。
- [ ] 若新增图片，记录来源、用途、替换状态和授权风险。

---

## 25. 给下一位接手者的最终结论

当前项目并不是“什么都没做”，也不是“灾变游戏已经完成”。它已经具备三块有价值的基础：

1. 可运行、可碰撞、可互动的灾变家园。
2. 可扩展的县域区域地图表现。
3. 带真实领域状态的容器搜索和格子背包原型。

最大问题是三者仍然彼此断开。下一步最有价值的工作不是继续画更多 UI、增加更多地点或写更多剧情，而是把它们接成一次完整且可存档的外出循环。

请优先完成：

> 家园大门 → 区域地图 → 诊所搜刮 → 返回家园 → 储物 → 保存和重载。

---

## 26. 2026-08-03：TRAE 修改后的碰撞修复与迁移状态

TRAE 最近重构了灾变家园 UI，并调整了碰撞和互动节点。经检查确认，原版本存在以下问题：

- 移动碰撞读取父节点位置，忽略 `CollisionShape2D` 的局部偏移。
- 互动范围读取父节点位置，忽略 `CollisionShape2D` 的局部偏移。
- 左下鸡舍被错误标记为 `storage`，右侧储物棚没有对应功能区。
- 菜地和大门互动范围有重叠。
- 碰撞可视化脚本没有 `@tool`，无法保证编辑器实时显示。
- F1 使用按住检测，可能连续闪烁。

本轮已修复：

- 家园脚本统一通过 `CollisionShape2D` 局部偏移计算实际矩形。
- 左下结构改为 `ChickenCoop` 碰撞。
- 右侧结构补充为 `StorageShed` 碰撞和 `storage` 功能区。
- 菜地和大门范围重新分离。
- 碰撞调试脚本加入 `@tool`。
- F1 改为一次按键切换一次。
- 新增针对 Shape 偏移、储物棚位置、鸡舍碰撞和功能区重叠的回归检查。

最新验证结果：

```text
TESTS_PASSED assertions=599
APOCALYPSE_SHELTER_READY zones=5 obstacles=6 collision_walls=4
```

换电脑迁移步骤已单独写在：

`docs/MIGRATION_TO_NEW_PC.md`

当前启动器已不再只依赖原电脑的 Godot 路径。它会依次查找 `GODOT_EXE`、项目内 `tools/godot`、项目根目录、原路径和系统 PATH。

这个闭环跑通后，再加入 D20、主屋休息、工作台、菜地、第一位居民和前 7 天剧情，项目才会从多个可靠原型变成真正可玩的灾变生活游戏。

---

## 27. 2026-08-05：庇护所改为静态地图热区（优先于旧碰撞章节）

本节覆盖本文中关于庇护所地图头像、`Collision`、`Area2D`、五点矩形检测、靠近后按 E 和 `ZoneIndicators` 的旧描述。

- 场景不再存在移动头像、障碍碰撞或功能区碰撞。`assets/art/apocalypse/characters/survivor_avatar.png` 不删除，改为留给背包、装备、人物资料和剧情对话立绘。
- 交互正式来源为 `scenes/world/apocalypse_shelter.tscn` 的 `Canvas/MapHotspots`。它包含主屋、储物棚、工作台、菜地和大门 5 个透明 `Button`；每个按钮保存稳定 `zone_id`、显示名称、位置和尺寸，可直接在 Godot Inspector 中改动。
- `src/world/apocalypse_shelter.gd` 只通过 `_route_hotspot()` 路由这 5 个稳定 ID。大门进入区域地图；其余 4 个功能先打开同一个 `FeatureModal`，后续应在该面板位置接入真实存储、制作、种植和休息 UI。
- 地图替换或建筑位置变化时，只调整对应热区的 Control 矩形，不修改脚本坐标，也不再重新测量碰撞箱。
- 当前尚未完成的是领域闭环，而不是家园点击：储物棚仍未连接灾变库存，主屋/工作台/菜地仍未连接休息、制作和种植规则。不要把入口面板当成这些功能已经完成。

验证要求：Godot 导入、全量测试、无头启动和人工检查应确认热区位置覆盖对应建筑、悬停标签可读、点击大门进入区域地图、其他 4 个热区均能打开并关闭统一入口面板、`Esc` 可以关闭面板。

---

## 28. 2026-08-05：区域地图到诊所的正式首段链路

本节覆盖本文中“区域地图只显示选择文字、诊所仍是孤立评审场景”的旧描述。

- 项目新增自动加载模块 `src/app/apocalypse_run.gd`，全局名为 `ApocalypseRun`。它只提供 `ensure_active_session()`、读取/替换当前会话和重置会话这一个窄接口；家园、区域地图和诊所不再各自新建灾变会话。
- `scenes/world/apocalypse_region_map.tscn` 的四个地图标记各自保存 `metadata/location_id`。点击 `village_clinic` 会登记固定地点并直接切换到 `scenes/reviews/apocalypse_explore_review.tscn`；市场、工业仓库仍显示“后续开放”，庇护所标记返回家园。
- 诊所 UI 现在从 `ApocalypseRun` 取得会话。水、背包物资、世界时间与体力会跨“区域地图 → 诊所 → 区域地图”保留，不再每次进入就从 06:00 和空背包重新开始。
- `ApocalypseSession` 将每个地点的 `ApocalypseSearchContainer` 快照保存到稳定地点 ID 下。药柜、前台和救护车搜索后立即写入会话；离开诊所先将完整会话写入 `user://saves/apocalypse_review/auto_1`，再返回区域地图。重新进入时已揭示物品不会重置。
- 这仍不是“启动游戏自动读取存档”：当前保存动作已真实写入快照，但“家园启动时选槽位/恢复 auto_1”的正式读档入口属于下一小步。家园储物棚 UI 也尚未接入。

本轮加入 `test_apocalypse_region_map_visual_review.gd` 和地点搜索快照的领域断言。由于当前工作环境找不到 Godot 可执行文件，完成的是资源路径、稳定 ID、私有会话移除和脚本引用的静态核对；尚未重新获得 Godot 导入、无头测试或人工窗口试玩证据。

---

## 29. 2026-08-05：项目内 Godot 与运行时验证（覆盖第 28 节最后一句）

- 已从 Godot 官方发布渠道下载 Windows x86_64 标准版 `4.7.1.stable.official.a13da4feb` 到 `tools/godot/Godot.exe`。它是项目内工具，不写入系统安装目录。
- 已用项目内 `tmp/godot_profile` 完成资源导入；`.godot/imported` 已生成 759 个导入缓存文件。
- `scripts/test_project.ps1` 已修复为优先读取 `GODOT_EXE`、项目内 `tools/godot/Godot.exe`，并将 AppData/LocalAppData/TEMP 指到项目内临时目录。它不再依赖原电脑 `D:\Archer` 路径；脚本以兼容 PowerShell 5 的 .NET 进程 API 收集 stdout/stderr 到 `tmp/godot_logs`。
- 运行 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_project.ps1` 的结果为 `TESTS_PASSED assertions=595`。其中包含本轮地点快照、地图诊所路由和诊所退出自动保存断言。
- 默认主场景无头启动输出：`APOCALYPSE_SHELTER_READY hotspots=5 avatar=false collisions=false`。
- 当前仍会出现 Windows 系统根证书读取失败警告；它没有阻止资源导入、测试或默认场景启动。人工窗口试玩仍值得在用户实际显示环境完成，但不再属于“没有任何运行时验证”的状态。

---

## 30. 2026-08-05：灾变自动继续已接入正式入口

- `src/app/apocalypse_run.gd` 现在是灾变会话与 `auto_1` 的唯一 adapter。其公开 Interface 保持很小：`ensure_active_session()`、`save_active_session()`、`start_new_session()`、会话替换/读取和恢复状态读取；JSON、备份回退和领域快照校验留在内部实现与既有仓储中。
- 启动默认庇护所时，`ensure_active_session()` 会尝试恢复 `user://saves/apocalypse_review/auto_1`。有效快照通过 `ApocalypseSession.restore_snapshot()` 后成为活跃会话；没有档案、时间线不符或快照无效则安全开始新局，不会崩溃。
- 诊所退出不再直接构造自己的 `TimelineSaveRepository`，改由 `ApocalypseRun.save_active_session()` 保存。这保证诊所写入与家园启动读取永远使用同一个槽位、根路径和时间线。
- `start_new_session()` 已具备，防止未来“新开局”只清空内存又被 `auto_1` 立刻覆盖；但尚未提供玩家可点击的新开局/选槽 UI，不能宣称该用户功能完成。
- 新增 `tests/test_apocalypse_run.gd`，覆盖无档新局 → 行动/携带物资 → 自动保存 → 清空内存 → 自动恢复的完整链路。全量测试为 `TESTS_PASSED assertions=603`。
- 运行时证据：测试后从同一项目内用户目录启动默认主场景，输出 `APOCALYPSE_RUN_READY source=auto_save backup=false`，随后输出 `APOCALYPSE_SHELTER_READY hotspots=5 avatar=false collisions=false`。

---

## 31. 2026-08-05：储物棚已成为真实家园仓储入口

- `ApocalypseSession` 新增稳定容器 `home_storage`：8×6 格、最大负重 80。它被包含在会话快照中，随 `auto_1` 保存和恢复；旧档案没有该字段时恢复时会自动补一个空仓储，保持向后兼容。
- `transfer_item(source_container_id, destination_container_id, instance_id)` 是容器之间唯一的领域转移 Interface。它先写目标再移除来源，目标无空间或容器无效时返回 `false`，不会吞掉或复制物品。
- `scenes/world/apocalypse_shelter.tscn` 增加 `Canvas/StorageModal`。储物棚热区不再打开占位说明，而是打开背包 / 家园仓储双栏 `ItemList`；点击左栏物品存入，点击右栏物品取回。每次成功转移立即调用 `ApocalypseRun.save_active_session()`。
- 此版本刻意是“点击转移”，不是拖拽格子。后续可在不动领域/存档的前提下，把同一 `transfer_item()` Interface 接到格子拖拽表现。
- 新增 `tests/test_apocalypse_storage_visual_review.gd`，并扩展会话/自动继续测试：覆盖仓储初始状态、背包与仓储双向转移、旧档恢复、热区打开 UI、点击后 UI 与领域状态同步、存档恢复后仓储物品仍存在。
- 运行验证：`TESTS_PASSED assertions=624`。仍需在有显示窗口的环境人工检查双栏列表的中文可读性和触控/鼠标手感。

---

## 32. 2026-08-05：一键启动器定位项目内 Godot

- `scripts/run_godot.ps1` 不能只依赖压缩包内的旧可执行文件名。项目内已验证的引擎实际路径是 `tools/godot/Godot.exe`，启动器现在将它作为首选候选路径。
- 其余兼容顺序仍保留：用户传入的 `-GodotPath`、`GODOT_EXE`、旧版版本化文件名、控制台版、项目根目录、历史 `D:\Archer` 路径和系统 PATH。这样项目移动到新电脑后不需要先修改系统环境变量。
- 启动器无界面定位验证：`powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_godot.ps1 --version` 输出 `4.7.1.stable.official.a13da4feb`。随后完整测试为 `TESTS_PASSED assertions=624`。

---

## 33. 2026-08-05：储物棚使用俄罗斯方块式库存格

- `item_id` 只表示物品种类（例如 `water`）；`instance_id` 表示某一件具体物品。会话接收重复的请求 ID 时会自动生成未占用实例 ID，避免第二件同类物品被误判为第一件的重复放置。
- `ApocalypseSession` 对库存的公开 Interface 现在包括：首个可用位置放入、`transfer_item()` 快速转移、`move_item_in_container()` 指定位置移动、`transfer_item_to_position()` 跨容器指定位置转移。所有 UI 应只使用这些方法，不可直接编辑容器快照。
- `src/world/apocalypse_inventory_grid.gd` 是格子表现 Module；它把任意容器快照画为网格与宽高物品块，并发出激活/落点请求。`src/world/apocalypse_inventory_item.gd` 提供 Godot 拖拽数据。它们没有存档和物品规则，未来诊所、装备栏可复用。
- 储物棚两栏为背包 6×4、家园仓储 8×6。鼠标操作：单击物品快速放入另一侧的第一个可用位置；按住物品拖到同侧或另一侧的目标格。无法放下时保持原位置并显示原因。
- 运行验证：`TESTS_PASSED assertions=631`。自动化验证了数据和信号路由；仍建议在实际窗口中手动确认图标在用户显示缩放下的可读性与拖拽手感。

---

## 34. 2026-08-05：当前采用常规单槽生存库存（覆盖第 33 节的拖拽交互）

- 最终玩家表现不是俄罗斯方块式拖放整理，而是常规单槽格子库存：每件当前可携带物品一格，单击物品即可在背包和家园仓储之间快速转移；领域层仍会阻止真实容量不足和错误转移。
- 6×4 背包与 8×6 家园仓储保留为真实数据网格。水、急救包、绷带、钥匙、燃料罐的现有内容定义均为 1×1，图标块实际大小为 16×16，置于 18×18 槽位中，形成清楚的边距和对齐。
- `ApocalypseInventoryGridView` 不再发出拖放落点请求；`transfer_item_to_position()` 仍留在会话模块，作为未来装备布局或其他确实需要指定位置的功能接口，当前储物棚不调用它。
- 物品有图标时 Button 文本为空，不出现图案与“水 / 药 / 绷”等字叠在一起。`ApocalypseInventoryItem._make_custom_tooltip()` 使用紧凑单行 7 像素 Tooltip，不再使用此前多行大文本提示。
- 最终运行验证：`TESTS_PASSED assertions=634`。仍需用户在实际窗口中确认字体和图标在自己的系统缩放下的主观观感。

---

## 35. 2026-08-05：库存槽位的图标、回退字与详细 Tooltip

- `assets/art/apocalypse/items/` 当前只有水、急救包与绷带 PNG；诊所钥匙和燃料罐没有对应图标。图标存在时槽位 Button 文本必须为空；没有图标时只显示 7 号的小号回退字（钥匙为“钥”），不能继承 Godot 默认 16 号大字。
- 每个物品的 [文字提示（Tooltip）](https://vibe-hub.org/tooltip) 由 `ApocalypseInventoryGridView._item_tooltip()` 生成，使用 `ApocalypseInventoryItem` 的 7 号自定义面板。内容为三行：物品名；分类/格数/负重；具体效果或用途。
- 当前数值是显式的设计数据，不是已可点击执行的功能：水的口渴等级 -1、急救包生命 +25、绷带移除 1 项创伤、燃料罐提供燃料 +10，均标注“待接入”。钥匙显示将开启诊所锁柜，锁柜门禁尚未实现。
- `apocalypse_explore_review.gd` 会在进入诊所时补齐 3 瓶测试水，方便立即验证同类物品的多槽表现。这个演示库存会进入当前灾变会话和自动档；未来正式开局物资平衡确定后，应将它迁移到正式新局配置，而不是长期放在诊所入口。
- 验证结果：`TESTS_PASSED assertions=641`。

---

## 36. 2026-08-05：库存已升级为数量堆叠，仓库不计负重

- `src/domain/apocalypse/apocalypse_item_catalog.gd` 是物品规则的唯一来源：普通用品 `maximum_stack=16`，目前定义的武器类别 `maximum_stack=1`。显示名称、分类及待接入的效果/用途也在此处读取，避免库存 UI 再次自行维护一套文案。
- `ApocalypseGridContainer` 快照版本为 2，单条物品记录包含 `quantity` 与 `maximum_stack`；它仍能读取版本 1。`ApocalypseSession.restore_snapshot()` 会将旧档的独立同类物品归一化为 1×1 堆叠记录，因此旧档中三瓶水升级后成为 `water ×3/16`，而不是丢失或占用三格。
- `place_item_in_container()` 现在将游戏物品统一为 1×1 标准格并传入目录规定的上限；`transfer_item()` 转移整个堆，目标会优先补已有堆。背包总负重继续按 `单件重量 × quantity` 计算；家园仓储只显示 `已用格/48`，不显示/不限制负重。
- `ApocalypseInventoryGridView` 的物品按钮固定为槽内 16×16。图片存在时仅显示图片；图片不存在时 Button 文本始终为空，`ApocalypseInventoryItem._draw()` 绘制钥匙/燃料的紧凑符号。数量角标仅在数量大于 1 时显示。
- 测试新增并验证：14/16 水接收 2 瓶后仍是一格 16/16、溢出的第 17 瓶才占第二格、堆叠重量累计正确、两把武器不能叠加、点击仓储水堆会整体转移、Tooltip 显示 `3/16` 与“不计负重”。完整验证：`TESTS_PASSED assertions=655`。仍需要用户在实际游戏窗口检查 16×16 钥匙符号在其显示缩放下是否符合审美。

---

## 37. 2026-08-05：按数量存取、拆分与右键菜单

- `ApocalypseGridContainer` 新增三个窄接口：`can_add_item_stack()` 只模拟目标容量，`remove_quantity()` 只扣当前物品堆的一部分，`split_stack()` 在有空格时从原堆创建同类新堆。它们保留单格规则、最大叠加数、单件重量和存档字段。
- `ApocalypseSession.transfer_quantity()` 在 UI 和容器之间成为唯一的“存/取 N 个”入口；完整转移仍通过它工作。部分转移会为目标创建安全的实例 ID，若目标已有相同未满堆则自动合并。`split_item_stack()` 负责会话级的新实例 ID，UI 不接触物品数组。
- `ApocalypseInventoryGridView` 新信号 `item_context_requested` 把右键请求送到庇护所；数量展示改为父按钮内的 `QuantityBadge`，使用右下锚定、1 像素内边距和父级裁切，不会漂到物品外。
- `ApocalypseShelter` 在储物棚动态创建 `StorageItemContextMenu`、指定数量 `ConfirmationDialog` 与详情 `AcceptDialog`。左键依然整组转移；右键根据来源显示存入/取出 1、整组、拆分一半、拆分指定数量和查看详情。没有空格、数量非法或物品已消失时只显示失败状态，不改变库存。
- 完整验证：`TESTS_PASSED assertions=684`。测试覆盖领域数量守恒、菜单文本、取出 1、指定数量拆分、数量角标右下锚定、存档快照和既有库存流程。尚需在真实窗口中确认右键菜单位置与数量角标在用户的 Windows 缩放下的视觉效果。

---

## 38. 2026-08-05：固定紧凑规格与可使用的基础消耗品

- `ApocalypseShelter` 将仓储动态 UI 固定为 8 像素字体：右键菜单宽 132 像素、拆分窗 172×82、详情窗 184×104；这是一份集中常量规格，后续新增仓储操作不应自行放大字号或窗口。
- `ApocalypseInventoryGridView` 的 `QuantityBadge` 位于物品块内右下，深色背景 `alpha=0.42`（约 58% 透明），父按钮开启裁切；数量可读但不会用不透明黑块遮住图标。
- `ApocalypseItemCatalog.get_use_action()` 是基础使用动作的唯一物品定义入口。水、急救包、绷带分别映射为 drink/heal/bandage；钥匙与燃料返回空动作，菜单不显示假的“使用”。
- `ApocalypseSession.use_item_in_container()` 负责先校验角色状态、再消耗 5 分钟、应用效果并扣 1 件。水在口渴为 0、医疗包在满血、绷带在无创伤时都会失败且不扣物品。测试还覆盖生命恢复最多 25、移除 1 项创伤与成功后库存减少。
- 最新无头回归：`TESTS_PASSED assertions=704`。Godot 仍打印 Windows 根证书库读取失败，这是现有不阻塞环境警告；下一步应由用户在实际窗口确认小字号菜单与约 58% 透明数量角标的观感，再继续制作一个真实地点用途（如诊所钥匙的锁柜）。

---

## 39. 2026-08-05：诊所锁柜与搜刮领取层

- `ApocalypseSession` 的地点快照新增可选 `unlocked_locks` 字段，旧档缺失该字段时默认空字典、可继续恢复。`unlock_location_lock()` 只检查背包中是否有指定物品、消耗行动时间并持久化开锁状态；它不扣除钥匙，因此诊所钥匙是耐久门禁物，而非消耗品。
- 村卫生室的 `ClinicLockbox` 替代旧后仓占位。前台搜索并领取钥匙后，锁柜显示“使用诊所钥匙解锁 · 5 分钟”；成功后开放包含急救包、绷带的独立搜索容器。锁柜奖励仍需要搜索，不是解锁即入包。
- `ApocalypseSearchContainer` 的每个物资元数据新增 `collected`。搜索仅将物资改为 `revealed`；`collect_revealed_item()` 在 UI 已成功把物品放进背包后才标记带走。快照保留已揭示、未领取、已领取三种状态；旧快照缺少 `collected` 时默认未领取。
- `ApocalypseExploreReview` 新增“已发现物资”列表、逐件“放入背包”和“全部放入背包”。领取失败不会标记 collected，因此背包没有空格时物资保留在地点容器，下一次打开对应热点仍可选择领取。当前背包负重仍是状态提示而非硬性阻止条件。
- `ApocalypseExploreReview._register_search_container()` 现无论新局或读档都会注册容器；读取到快照时才覆盖为恢复状态，解决了此前新局容器可能没有进入字典的脆弱实现。
- 最新无头回归：`TESTS_PASSED assertions=727`。仍有 Windows 根证书库读取警告，但不阻断脚本编译和测试。下一步可为救护车燃料接入可见的车辆/发电设施用途，或在真实窗口进行搜刮领取面板的视觉验收。

---

## 40. 2026-08-05：燃料罐接入主屋应急发电机

- `ApocalypseItemCatalog.get_generator_power_value()` 集中定义燃料罐为 `+10` 电力。`ApocalypseSession.refuel_home_generator()` 只从 `home_storage` 查找并扣除 1 个燃料罐，先校验 100 点上限与库存、再消耗 5 分钟、最后增加电力；失败不会扣燃料。
- `home_power` 是会话快照的正式字段，范围 0–100。`restore_snapshot()` 对旧档使用 `0` 默认值，对非法负值或超上限值拒绝恢复；这保证本次字段新增不让旧灾变存档失效。
- 主屋热点现在进入“主屋 · 应急发电机”而非旧的生活系统占位文字。`FeatureAction` 是复用 FeatureModal 的单一操作按钮，只有发电机模式显示；面板统一收敛为标题 10、正文/按钮 8 的紧凑规格，并将按钮改为可获得键盘焦点，避免测试时产生焦点警告。
- 当前电力只是可见、可保存的资源储备，尚未影响其他行动；这不是缺陷隐藏，而是明确的依赖边界。下一步应选一个真实消费者（优先：医疗台使用 10 电力处理伤病；或工作台使用 10 电力制作/修理），不要同时启动两套系统。
- 最新无头回归：`TESTS_PASSED assertions=743`。仍有 Windows 根证书库读取失败这一不阻塞环境警告；无新增脚本错误、无新增 UI 焦点警告。 

---

## 41. 2026-08-05：主屋医疗台成为电力的第一个真实消费者

- `SurvivorState.reduce_infection_risk(amount)` 是感染风险的唯一受控降低入口；它只接受非负量、从当前风险中扣除并返回实际减少值，不允许 UI 修改快照字典。
- `ApocalypseSession.treat_at_home_medical_station()` 需要：`home_power >= 10`、`home_storage` 至少 1 个急救包、存在创伤或感染风险。成功后依次消耗 15 分钟、1 个急救包、10 电力，移除第一项创伤并降低最多 15 感染风险。任何前置条件失败都不扣时间、电力或急救包。
- 主屋 FeatureModal 增加 `FeatureSecondaryAction`；主屋模式现在显示发电与医疗两项小操作。通用 FeatureModal 仍复用同一节点，非主屋热点会隐藏两个操作按钮，不产生无效 UI。
- “电力资源”从纯储备升级为真实可消费资源，但仅接入医疗台；工作台、夜间行动仍不读取它，不能标为已完成。
- 最新无头回归：`TESTS_PASSED assertions=757`。Windows 根证书库读取警告仍存在但不阻断。下一步建议在工作台做一个单配方、消耗材料和少量电力的制作闭环，避免同时新增多种装备/武器系统。

---

## 42. 2026-08-05：探索噪声成为可保存的风险状态

- `ApocalypseSession` 在每个地点快照中保存 `search_noise`，并提供 `record_location_search_noise()`、`get_location_search_noise()`、`is_location_search_dangerous()`。旧快照不含 `search_noise` 时默认为 0；负数噪声或非法快照会被拒绝。
- 阈值是明确常量：累计 5 噪声时当前区域威胁 +1（最多 3，阈值只跨越时触发一次）；累计 10 噪声时标记为危险搜索。第一版不使用随机数，因此玩家可从 UI 预测每个后果。
- `ApocalypseExploreReview` 在危险地点搜索前使用二次点击确认：第一次显示“危险搜索 · 再点击确认”并不花时间，第二次才调用原搜索逻辑。确认待定状态只属于当前 UI 操作；切换容器/离开界面后自然重新确认，真正需要保存的是地点噪声与区域威胁。
- 右侧噪声文本现在区分地点累计、当前容器累计和当前容器耗时。每次成功搜索日志都会附加领域层返回的风险结算信息。
- 最新无头回归：`TESTS_PASSED assertions=771`。仍有 Windows 根证书库读取失败这一不阻塞环境警告。下一步可做工作台单配方，或在已有威胁状态之上设计一个完全可解释的危险遭遇表；不要直接加入不可见随机伤害。

---

## 43. 2026-08-05：工作台单配方——简易开锁工具

- `ApocalypseItemCatalog.get_workbench_recipe(simple_lockpick)` 是目前唯一的工作台配方定义：输出简易开锁工具，输入废金属 ×1、电线 ×1、电力 5、时间 10 分钟。材料名称、类别、用途与工具说明也集中在同一目录，UI 不复制配方数值。
- `ApocalypseSession.craft_simple_lockpick()` 只从 `home_storage` 读取输入，校验电力和双材料后才消耗时间、材料与电力，并将成品放回家园仓储。由于消耗两个单格输入后必然释放空间，成品没有额外占格风险；失败前置条件不会改动资源。
- 新物品废金属、电线、简易开锁工具均由 `ApocalypseInventoryItem._draw()` 提供 16×16 内部矢量回退图标，保持图案与文字互斥、数量角标位置不变。
- `unlock_location_lock_with_item()` 支持指定开锁物及是否消耗。既有 `unlock_location_lock()` 仍委托它并保持“钥匙不消耗”的兼容行为；诊所 UI 优先使用钥匙，背包无钥匙但有简易开锁工具时自动显示更慢且消耗工具的替代方案。
- 诊所药柜第三件是废金属，前台第一件是电线、第二件才是钥匙。这使玩家能在发现钥匙前回家制作替代工具，也可继续搜索选择更快的钥匙路线。
- 最新无头回归：`TESTS_PASSED assertions=797`。Windows 根证书库警告仍不阻塞。下一步可基于现有区域威胁制作一张可解释的危险遭遇表，或先由用户在真实窗口验收诊所三件物资列表、工作台与锁柜文本的可读性。

---

## 44. 2026-08-07：地图热区悬停状态与主武器装备槽

- 家园热区的 normal 状态必须保持透明。地图专用 `Style_hotspot_hover` 使用灰绿色背景 alpha 0.07、边框 alpha 0.30；pressed 使用背景 alpha 0.14、边框 alpha 0.55。不要再把地图热点改回高饱和黄色整块高亮。
- `Style_action_hover` / `Style_action_pressed` 专供实体按钮。地图热点与弹窗按钮已拆分样式；后续调整地图可点击反馈时不要批量替换实体按钮样式。
- `ApocalypseItemCatalog` 当前第一件真实装备是 `crowbar`：最大堆叠 1、负重 3、伤害 8、体力消耗 6、噪声 1。诊所锁柜搜索顺序为急救包、绷带、撬棍；搜到后仍需玩家明确选择放入背包。
- `ApocalypseSession` 仅保存 `equipment.weapon_instance_id`，装备本体仍位于 backpack。恢复时会验证实例确实存在且类别为武器；旧快照没有 equipment 时恢复为空手。完整转移已装备实例离开 backpack 会自动清空装备槽。
- 储物棚右键菜单只对背包中的武器显示装备操作；仓储中的武器必须先取回背包。`EquipmentStatus` 保持 8 像素单行，空手显示伤害 2，撬棍显示具体伤害/体力/噪声。当前没有攻击行为、武器耐久、多部位装备或快捷使用栏，不能将它们宣传为已完成。
- 最新回归为 `TESTS_PASSED assertions=833`。由于 Windows 控制插件版本与规范不匹配，本轮未完成真实窗口悬停截图；需要用户运行 `启动游戏.bat`，把鼠标移过主屋/仓储/工作台确认主观观感。下一步建议补“快捷使用槽”：只允许从背包绑定水、急救包或绷带，复用既有真实物品使用规则，不先引入战斗系统。

---

## 45. 2026-08-07：库存拖放、独立背包和系统菜单

- `ApocalypseInventoryItem._get_drag_data()` 只产生 `kind/container_id/instance_id` 数据；`ApocalypseInventoryGridView._drop_data()` 把鼠标位置换算为 18 像素格坐标并发出 `item_drop_requested`。不要在 UI 直接修改容器快照。
- `ApocalypseShelter._on_storage_item_drop_requested()` 调用现有会话接口 `transfer_item_to_position()`。当前规则只允许拖动整组到可放置格；落在占用格时失败并保持原位。按数量存取仍走右键菜单，不在拖动时弹数量窗。
- `StorageModal` 通过 `_storage_mode` 复用为两种模式：`storage` 显示 6×4 背包和 8×6 家园仓储，可跨栏拖动；`backpack` 只显示背包，禁止远程仓储并隐藏存入/取出菜单。不要复制第二套库存 UI。
- `open_inventory` 输入映射为 B，HUD 文案为“背包 [B]”。Esc 或 P 打开 `SystemMenu`；`S = Save` 只在菜单打开时保存。末日家园不读取 `move_left/right/up/down`，旧农场模式遗留的 WASD 输入映射不能被误解为末日主线仍有移动。Esc 会优先关闭当前模态窗口。
- 最新测试为 `TESTS_PASSED assertions=851`。下一步建议把相同的独立背包和 Esc 菜单入口抽成可复用覆盖层，接入县域地图和诊所探索场景；随后再做一个消耗品快捷槽。当前不要宣称这两个入口已经覆盖所有灾变场景。

---

## 46. 2026-08-07：共享灾变 UI 覆盖层接入县域地图和诊所

- `scenes/world/apocalypse_global_overlay.tscn` 与 `src/world/apocalypse_global_overlay.gd` 是外出场景背包和系统菜单的唯一复用入口。它读取 `/root/ApocalypseRun`，不持有第二份库存状态；新增地点应实例化该场景，不复制动态菜单代码。
- 覆盖层提供 B 背包、Esc/P 菜单和菜单内 S 保存。背包使用现有 `ApocalypseInventoryGridView`，支持单击详情、右键使用/装备/拆分和同背包拖动。外出覆盖层不得显示 `home_storage`，家园仓储仍是储物棚专属。
- 县域地图与诊所的 `_unhandled_input()` 必须先调用 `global_overlay.handle_input_event(event)`，处理后立即标记 viewport 并返回。否则旧的 Esc 退出逻辑会绕过菜单。正式返回分别继续使用县域地图“返回家园”和诊所“离开地点”按钮。
- 诊所通过 `inventory_changed` 刷新旧的 loadout 预览。覆盖层仍是紧凑库存的正式操作 UI；诊所下方四容器栏暂时只是地点页面的携带状态概览，后续可逐步收敛，不能再做第二套可操作背包。
- 最新测试：`TESTS_PASSED assertions=863`。当前覆盖家园、县域地图和诊所；未来新开放的市场、工业仓库等地点应直接挂同一覆盖层。下一步建议做一个可保存的消耗品快捷槽，并由覆盖层和家园 HUD 共用；不要先扩大战斗系统。

---

## 47. 2026-08-08：第 1 日至首轮袭击的最小完整流程

- `ApocalypseSession` 增加公开的首袭准备状态：第 4 日清晨结算，电力至少 10、家园急救包至少 1、背包或仓储至少 1 件武器，共 3 项；完成任意 2 项为守住，否则为受创幸存。规则确定且可见，不使用隐藏随机数。
- 主屋新增紧凑的“休息到次日 06:00”按钮。休息恢复时钟体力并推进饥饿/口渴压力；第 4 日触发一次首袭结算。准备不足固定生命 -20、新增 `raid_wound`、区域威胁 +1，但不会形成无提示死档。
- 家园左上增加 8 像素首袭目标板，实时读取电力、急救包和武器，不复制第二份 UI 状态。底部状态栏也改为读取真实 Survivor/Clock，而非旧的固定演示数值。
- 首袭结果及准备明细进入 `campaign` 快照；旧档没有该字段时按未结算默认恢复。每次休息自动保存。
- 家园 UI 测试真实点击休息三次，再调用 `reset_active_session()` 清空运行时会话，从自动档恢复后仍为第 4 日和同一 `held` 结局。领域测试同时覆盖准备不足的 `overrun` 路径。
- 顶层 `README.md`、`AGENTS.md`、`task_plan.md` 和灾变垂直切片文档已同步：末日静态热点流程是当前主线，旧牧场内容保留但降级为历史/可复用模块。
- 最新全量无头回归：`TESTS_PASSED assertions=895`。Windows 根证书库读取失败仍为不阻塞警告。当前桌面自动化无法为 Godot 提供可见窗口句柄，因此目标板、休息面板和结算页仍需真实窗口人工视觉验收，不能宣称已经目测通过。

---

## 48. 2026-08-12：继续入口窗口验收

- 实际启动 Godot 4.7.1 项目窗口，确认启动页从 `auto_1` 提供“继续游戏”，点击后进入庇护所；日志为 `APOCALYPSE_RUN_READY source=auto_save`、`APOCALYPSE_SHELTER_READY hotspots=5`。
- Computer Use 对 Godot 游戏窗口返回截图边界接口异常，未能可靠点击门口热点；地图→市场/诊所→返回的人工全路径仍保持未完成，不能用 `TESTS_PASSED` 替代。
- 当前自动化基线：`scripts/test_project.ps1` 输出 `TESTS_PASSED assertions=925`。下一步优先修复窗口捕获/交互验收条件，再继续场景路由验收；不要扩展旧牧场线。

---

## 49. 2026-08-13：Phase 3B 可视化 E2E 关闭

- 新增独立 `tests/capture_apocalypse_e2e.gd`。它使用隔离的 Godot 用户目录，不读取或覆盖玩家 `auto_1`；依次触发正式启动页、确认新游戏、庇护所大门、县域市场、搜索/领取、退出自动保存、重新继续、市场状态恢复和返回庇护所。
- 12 张 1440×810 逐步画面保存在 `tmp/apocalypse_e2e_capture/`。人工检查确认新游戏确认、县域地图、市场背景、搜索反馈、自动档摘要、恢复后的背包/搜索状态和返回庇护所均完整可读。
- 可视化检查发现市场与诊所的 `GlobalOverlay` 场景树顺序错误；现已把共享覆盖层保存为根节点最后一个子节点，避免“背包 [B]”被主内容遮挡，并增加回归断言。
- 编辑器资源解析、默认无头启动、可视化 E2E 和全量回归均通过；最新基线 `TESTS_PASSED assertions=927`。外部 Computer Use 的 Godot 截图接口仍报 Windows 接口不支持，但已不再阻塞引擎内场景验收。
- 下一模块只做工业仓库一个正式地点：复用共享背包覆盖层、稳定 ID、搜刮容器和自动保存；不要同时启动 7 日事件、居民或旧牧场线。

---

## 50. 2026-08-13：第三个正式搜刮地点“工业仓库”

- 县域地图的既有 `industrial_warehouse` 标记现在路由到 `scenes/reviews/apocalypse_warehouse_review.tscn`；进入地点时登记 `fixed` 类型，不新增 manager、存档版本或领域公开方法。
- 仓库表现保存为可编辑场景：使用已归档的 `industrial_warehouse_generated.png` 背景、装卸台与维修笼两个热点、紧凑搜索面板，以及根节点最后一位的共享 `GlobalOverlay`。
- `warehouse_loading_bay` 与 `warehouse_maintenance_cage` 是两个独立稳定容器。当前物资分别为燃料/废金属和电线/撬棍；搜索时间与金属噪声进入共享会话，取物进入真实 6×4 背包，离场写入 `auto_1`。
- 可视化 E2E 扩展为 16 步：市场恢复后继续进入仓库、搜索并领取燃料、离场自动保存、重置运行时会话、再次 Continue 后验证仓库仍为“部分搜索 · 已显露 1/2”且背包为 11/20。画面位于 `tmp/apocalypse_e2e_capture/13`—`16`。
- 首轮逐图检查发现领取后日志仍残留“物资留在容器”，现已改为明确报告领取件数；修正后的截图显示“已放入背包 1 件”，状态、已发现列表和负重一致。
- 验证结果：工业仓库场景在 Godot 编辑器解析并实例化成功；默认无头启动输出 `APOCALYPSE_START_READY continue=false`；可视化 E2E 输出 `APOCALYPSE_E2E_CAPTURE_PASSED captures=16`；全量回归为 `TESTS_PASSED assertions=947`。
- 下一模块只做一个第 5 日事件切片，复用现有休息、campaign 快照和自动保存 seam；不要同时开始居民、农业、社交、经济或旧牧场线。

---

## 51. 2026-08-13：第 5 日单事件“断续的无线电信号”

- `ApocalypseSession.rest_at_shelter()` 继续作为跨日结算的唯一深 interface：首袭已结算后，休息进入第 5 日会产生 `day_five_radio_signal` pending 事件；未处理时再次休息返回失败且日期保持第 5 日。
- 新增两个稳定选择：`power_radio` 需要并消耗 5 电力，不增加疲劳/压力；`rooftop_watch` 不耗电，但疲劳与压力各 +1。所有代价在事件面板点击前公开，无 D20 或隐藏随机伤害；无电时供电选项明确禁用。
- 事件状态扩展现有 `campaign` 快照，不提高快照版本：`not_started/pending/resolved`、选择 ID 和结算结果均可保存；旧档缺少字段时按首袭状态和当前日安全迁移。
- 庇护所新增保存的 `Canvas/CampaignEventModal`，位于场景树最上层。它与设施 `FeatureModal` 分离；pending 时 Esc 不能关闭，resolved 后显示唯一“确认并返回家园”操作。Continue 读到 pending 会自动重开，resolved 则只在目标板恢复结果。
- 首轮视觉检查发现事件面板底部留白过多；直接把 `.tscn` 的 `offset_bottom` 从 232 收紧至 196，未使用运行时代码改布局。最终 pending、resolved、返回家园与 Continue 后目标板画面均完整可读。
- 验证结果：Godot 编辑器场景解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；可视化 E2E 输出 `APOCALYPSE_E2E_CAPTURE_PASSED captures=21`；全量回归为 `TESTS_PASSED assertions=993`。
- 下一模块只制作一个第 6 日事件，复用同一 pending-event interface；不同时启动居民、农业、社交、经济或旧牧场线。

---

## 52. 2026-08-13：第 6 日单事件“屋檐外的悬包”

- 用户提供的《末日丧尸游戏设定》只作为叙事参考：本模块提炼屋檐、悬包、绳索回收和物资/安全取舍；未引入对话中的具名人物、队伍关系、D20 随机检定、感染者或实时战斗。
- `ApocalypseSession` 保持 `get_pending_campaign_event()` 与 `resolve_pending_campaign_event(choice_id)` 两个公开接口。内部按当前 pending 状态派发第 5/6 日定义与结算，不新增 EventManager 或逐日 UI 方法。
- 稳定事件 ID 为 `day_six_hanging_pack`。`recover_hanging_pack` 将饮用水 ×2 放入真实 `home_storage`，并增加疲劳/压力各 1；`abandon_hanging_pack` 无状态代价，也不获得物资。仓储无法容纳奖励时回收按钮明确禁用，失败不先修改状态。
- 第 6 日 `not_started/pending/resolved`、稳定选择 ID 与结算结果扩展现有 campaign 快照，版本仍为 1。旧档缺少第 6 日字段时，只有在首袭已结算、第 5 日已解决且当前至少第 6 日时才推导 pending。
- 庇护所 `CampaignEventModal` 的两个保存按钮现按领域 `choices` 顺序配置，通过按钮元数据提交稳定 ID；表现层不再认识第 5 日选择常量。目标板按最新已解决事件显示领域返回的 `choice_label`。
- 可视化 E2E 扩展到 25 步：在原 21 步后继续休息到第 6 日，检查 pending、选择回收、结算、目标板、自动保存、Continue 恢复及饮用水持久化。四张新增画面均完整可读；结算页 kicker 已从“待处理事件”修正为“事件已处理 · 后果已结算”。
- 验证结果：Godot 编辑器场景解析 exit 0；默认无头启动 `APOCALYPSE_START_READY continue=false`；可视化 E2E 输出 `APOCALYPSE_E2E_CAPTURE_PASSED captures=25`；全量回归为 `TESTS_PASSED assertions=1036`。
- 下一模块只制作一个第 7 日事件，继续复用同一 pending-event interface；居民、农业、社交、经济、战斗与旧牧场线继续冻结。

---

## 53. 2026-08-18：第 7 日单事件“松动的仓储雨棚”

- 稳定事件 ID 为 `day_seven_shelter_tarp`；触发条件是首袭、第 5 日和第 6 日事件均已结算，休息进入第 7 日清晨。
- 事件描述读取 `GameSession.get_weather_text()`，把昨夜积水、支架松脱和今天天气写入公开叙述；不引入隐藏骰或战斗。
- `repair_shelter_tarp` 需要并消耗家园仓储 `wire` ×1，不增加疲劳/压力；`move_shelter_supplies` 不消耗电线，疲劳与压力各 +1，始终可用。
- 事件状态、稳定选择 ID、结果和电线消耗进入既有 `campaign` 快照，版本仍为 1；旧档缺少第 7 日字段时安全推导 pending。
- `apocalypse_shelter.gd` 只把 day7 结果加入现有目标板循环，通用 `CampaignEventModal` 仍通过按钮元数据提交 `choice_id`。
- 新增领域测试、可视化事件测试和 E2E 第 26—29 步；`TESTS_PASSED assertions=1075`，`APOCALYPSE_E2E_CAPTURE_PASSED captures=29`。
- 人工逐图检查文件：`tmp/apocalypse_e2e_capture/26_day_seven_event_pending.png`、`27_day_seven_event_resolved.png`、`28_day_seven_shelter_updated.png`、`29_day_seven_state_restored.png`。
- 下一步：进入 Phase 7 完整切片验收，整理搜刮/休息/事件/存档的保留、调整、删除与县域扩展清单；不要启动居民、农业、社交、经济、战斗或旧牧场线。

---

## 54. 2026-08-20：安全区设施基础

- 新增 `src/domain/apocalypse/shelter_facilities.gd`。它只处理稳定设施 ID、当天维护状态、纯值动作和快照恢复；`ApocalypseSession` 作为唯一公开会话入口，根快照新增兼容字段 `shelter_facilities`。旧档缺少该字段时不会失效，而是将当前日初始化为尚未维护。
- `scenes/world/apocalypse_shelter.tscn` 的 `MapHotspots` 现保存主屋、鸡棚、三联牲畜棚、储物棚、工作台、菜地、大门 7 个可编辑 `Button`。鸡棚/牲畜棚位置与大小来自场景，不被脚本坐标取代。
- 鸡棚显示鸡群 ×4，每日可“整理鸡棚”（10 分钟、1 点体力）；三联棚显示黄牛、山羊、猪各 ×1，每日可“巡检牲畜棚”（15 分钟、1 点体力）。维护成功会自动保存；同日重复操作明确不可用。
- 这不是动物生产系统：没有新增饲料、鸡蛋、奶、毛、肉、繁殖、死亡、交易或经济平衡。后续若要加入这些内容，必须通过同一设施领域接口与真实物品定义交付，不可先在 UI 发放假奖励。
- 新增 `scenes/world/apocalypse_house_interior.tscn` 与 `src/world/apocalypse_house_interior.gd`。主屋原有休息/医疗/供电面板保持兼容；新增“进入主屋室内”后，床、屋内工作台、医疗角、应急电源、出口均是保存的可编辑热点，并只转发给既有会话规则。
- 新增设施领域/视觉回归；隔离 E2E 从 29 步增加到 34 步，新增画面检查鸡棚、两次维护、主屋室内与清空运行时会话后的设施恢复。验证为 `TESTS_PASSED assertions=1133` 与 `APOCALYPSE_E2E_CAPTURE_PASSED captures=34`。
- 在 Godot 编辑器实际打开两张正式场景，确认上述 `MapHotspots` 节点均出现在场景树中且可选中。Godot 资源导入与无头启动均成功；“Failed to read the root certificate store”沿用既有结论，属于不阻塞 Windows 环境警告。
- 下一步：回到 Phase 7 完整切片验收，形成保留/调整/删除边界清单；居民、种植、完整动物生产、社交、经济、战斗和旧牧场线继续冻结。
