# Project X 换电脑迁移说明

> 本文是 2026-08-03 的历史迁移说明，包含已经废弃的头像行走、碰撞区、E 键互动和旧测试数量。2026-08-09 起，请直接阅读项目根目录 `新电脑完整交接文档_2026-08-09.md`；不要按本文旧步骤恢复末日家园移动。

更新时间：2026-08-03  
适用版本：Godot 4.7.1 stable  
当前默认模式：灾变末日家园 / 外出搜刮垂直切片

这份文档用于把 Project X 复制到另一台 Windows 电脑后继续开发。压缩包本身包含项目文件、场景、脚本、测试、文档和项目素材；不包含 Godot 编辑器本体、`.godot` 导入缓存、运行日志和远程附件缓存。

## 一、压缩包内容

迁移包保留：

- `project.godot`
- `scenes/`
- `src/`
- `tests/`
- `scripts/`
- `assets/`
- `content/`
- `docs/`
- `AGENTS.md`
- `CONTEXT.md`
- `HANDOFF.md`
- `task_plan.md`
- `progress.md`
- `findings.md`
- `README.md`
- `启动游戏.bat`
- `编辑末日庇护所.bat`
- `编辑家园地图.bat`

压缩包排除：

- `.godot/`：Godot 本机导入和编辑器缓存。
- `tmp/`：运行日志、临时配置、测试输出。
- `.codex-remote-attachments/`：聊天附件缓存，不属于游戏项目。
- `.git/`：当前项目没有可靠的提交基线，避免把本机版本控制缓存误带到新电脑。

## 二、新电脑需要安装什么

必须安装：

1. Windows 10/11。
2. Godot 4.7.1 stable，Windows 64-bit 版本。

不需要安装：

- Visual Studio。
- Godot .NET 版本。
- 额外的 Python、Node 或数据库。

推荐把项目解压到不含中文和过深层级的路径，例如：

```text
D:\Projects\Project X
```

路径中包含空格是可以的，启动器已经使用了带引号的路径；但不建议放在 OneDrive、桌面同步目录或权限受限的系统目录中。

## 三、Godot 路径配置

启动器现在按下面顺序查找 Godot：

1. 启动脚本显式传入的 `-GodotPath`。
2. 系统环境变量 `GODOT_EXE`。
3. 项目内的：

   ```text
   tools\godot\Godot_v4.7.1-stable_win64.exe
   ```

4. 项目根目录下的同名 Godot 程序。
5. 原电脑路径：

   ```text
   D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe
   ```

6. Windows PATH 中名为 `godot` 的程序。

最推荐的两种配置方式：

### 方式 A：设置环境变量

把 `GODOT_EXE` 设置为新电脑的 Godot 可执行文件完整路径，例如：

```text
C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe
```

重新打开命令提示符后，双击 `启动游戏.bat` 即可。

### 方式 B：放进项目内

在项目根目录创建：

```text
tools\godot\
```

把 Godot 可执行文件放进去并命名为：

```text
Godot_v4.7.1-stable_win64.exe
```

这种方式最适合个人跨电脑继续开发，但压缩包不会自动包含 Godot 本体；如果需要，可以在本地自行复制进去。

## 四、第一次启动顺序

解压后不要直接打开旧的 `.godot` 缓存。项目包已经排除了它，第一次启动会自动重新导入资源。

按以下顺序操作：

### 1. 先验证 Godot 导入

在项目根目录打开 PowerShell：

```powershell
.\scripts\run_godot.ps1 --headless --editor --path (Get-Location) --quit-after 300
```

如果新电脑 Godot 不在自动查找位置，可以这样运行：

```powershell
.\scripts\run_godot.ps1 -GodotPath 'C:\Tools\Godot\Godot_v4.7.1-stable_win64.exe' --headless --editor --path (Get-Location) --quit-after 300
```

第一次完整导入可能需要一些时间。新 PNG 若没有 `.import` 文件属于正常情况，Godot 会重新生成。

### 2. 运行自动测试

```powershell
.\scripts\test_project.ps1
```

当前基线应至少看到：

```text
TESTS_PASSED assertions=599
```

如果包装脚本在 Windows 上返回退出码 1，先检查最新日志，而不是立即判定测试失败：

```powershell
Get-ChildItem '.\tmp\godot_logs\tests_*.log' |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1 |
  Get-Content -Encoding utf8
```

重点确认日志里有 `TESTS_PASSED`，且没有 `SCRIPT ERROR` 或 `TESTS_FAILED`。

### 3. 从用户真正使用的入口启动

双击：

```text
启动游戏.bat
```

当前首屏应该是灾变家园，不是普通牧场，也不是县域大地图。

无头验证命令：

```powershell
cmd.exe /c "启动游戏.bat --headless --quit-after 60"
```

预期日志：

```text
APOCALYPSE_SHELTER_READY zones=5 obstacles=6 collision_walls=4
```

### 4. 打开可编辑灾变家园

双击：

```text
编辑末日庇护所.bat
```

它会打开：

```text
scenes\world\apocalypse_shelter.tscn
```

可以在 Godot 2D 视图中直接选择并调整：

- `Canvas/Collision/Walls`
- `Canvas/Collision/Obstacles`
- `Canvas/Collision/InteractionZones`
- `Canvas/HUD/ZoneIndicators`
- 底部状态栏

## 五、当前实际游戏方向

当前项目优先制作丧尸末日生存模式：

- 家园保留 2D 俯视地图。
- 玩家在家园中使用圆形头像移动。
- 大门进入县域区域地图。
- 外出地点主要使用固定插图、文字、热点和搜刮 UI。
- 搜刮采用容器先显示未知轮廓、搜索后逐件揭示。
- 物品使用口袋、胸挂、背包、保险箱和格子负重结构。
- D20 用于观察、搜索、撬锁、治疗、交涉和风险结果。
- 不做实时战斗。
- 普通牧场系统暂时隐藏，但保留用于未来农业、动物、料理和关系复用。

完整状态请先阅读：

[HANDOFF.md](../HANDOFF.md)

## 六、迁移后必须确认的视觉结果

启动后手动检查：

- 左上角没有旧的大头像资料框。
- 移动头像是圆形，不是黑色方块或椭圆。
- 底部状态栏没有超出 480×270 画面。
- 主屋、动物棚、鸡舍、储物棚、工作台和菜地的碰撞位置与背景一致。
- 左下鸡舍不再被误认为储物柜。
- 右侧小棚是储物棚互动区。
- 菜地互动区与大门互动区没有重叠。
- 大门位于底部中央开口附近。
- 靠近功能区时只出现对应的互动标记。
- 按 `E` 触发当前功能提示。
- 按 `F1` 可切换运行时碰撞可视化，并且按住不会连续闪烁。
- `Esc` 不会错误切换碰撞显示。

## 七、当前碰撞和功能区的组织方式

正式来源是 `scenes/world/apocalypse_shelter.tscn`，不是脚本中的坐标生成。

### 墙体

`Canvas/Collision/Walls`：4 个 `StaticBody2D`，用于边界参考。玩家移动范围目前仍由脚本边界限制配合使用。

### 障碍物

`Canvas/Collision/Obstacles`：

- `MainHouse`
- `AnimalPens`
- `ChickenCoop`
- `StorageShed`
- `Workbench`
- `FarmBeds`

每个障碍物下面有一个 `CollisionShape2D`。脚本会读取父节点位置加上 Shape 的局部偏移，调 Shape 时不要在脚本里另写一份坐标。

### 功能区

`Canvas/Collision/InteractionZones`：

- `MainHouse` / `main_house`
- `StorageShed` / `storage`
- `Workbench` / `workbench`
- `FarmBeds` / `farm_beds`
- `Gate` / `gate`

功能区是 `Area2D`，不会阻挡玩家；阻挡使用 `Obstacles` 下的 `StaticBody2D`。

## 八、继续开发前的规则

- 不要用代码生成正式地图、碰撞或 UI 布局。
- 不要只改父节点位置而忘记检查子级 `CollisionShape2D` 的局部位置。
- 不要让同一个稳定 `zone_id` 同时代表两个不同视觉设施。
- 新增设施时同时建立视觉节点、障碍碰撞和功能区，或明确它只属于其中一种。
- UI 不能自己维护库存、时间、搜索或角色状态。
- 普通时间线和灾变时间线不能共用存档路径。
- 新图片导入 Godot 后再接场景。
- 保留用户在 Godot 编辑器里保存的场景调整。

## 九、推荐的下一步

迁移后不要马上继续加新地点。建议顺序：

1. 手动确认家园六个障碍物和五个功能区。
2. 从家园大门进入区域地图。
3. 把诊所接入正式搜刮场景。
4. 搜刮物品带回家园。
5. 接通储物棚的真实格子储物 UI。
6. 保存、退出、重启，确认物品和容器状态保留。
7. 再接主屋休息、工作台、菜地和第一位居民。

## 十、出现问题时如何排查

### 找不到 Godot

检查：

- `GODOT_EXE` 是否指向真实 exe。
- 是否安装的是 Godot 4.7.1 stable，而不是 .NET 版。
- 是否从项目根目录启动脚本。

### 新图片显示不出来

先运行完整导入命令：

```powershell
.\scripts\run_godot.ps1 --headless --editor --path (Get-Location) --quit-after 300
```

不要手动伪造 `.import` 文件。

### 测试数量不同

以日志中是否有 `TESTS_PASSED` 为准，并检查是否有 `SCRIPT ERROR`、`TESTS_FAILED`。不同阶段断言数量可能增加，但不能无故减少专项测试。

### 家园碰撞不对

先打开 `编辑末日庇护所.bat`，在 Godot 中检查对应 Shape 的：

- 父节点 Position。
- `CollisionShape2D` 子节点 Position。
- `RectangleShape2D` Size。

运行时按 F1 查看调试框。不要只看脚本中的范围常量。

## 十一、迁移完成判定

当下面项目全部满足时，说明新电脑可以继续开发：

- [ ] Godot 4.7.1 能打开项目。
- [ ] 资源导入完成。
- [ ] 自动测试通过。
- [ ] `启动游戏.bat` 能启动灾变家园。
- [ ] `编辑末日庇护所.bat` 能打开正确场景。
- [ ] 家园碰撞和功能区位置正确。
- [ ] 区域地图能从大门进入。
- [ ] 所有文档可读取。
- [ ] 项目路径和 Godot 路径不再依赖原电脑的 D 盘结构。
