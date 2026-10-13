# 矿石镇主角本地行走动画模块

## 范围

用户提供了一张《牧场物语：矿石镇的伙伴们》主角动作表，用于个人本地游玩版本。本模块只处理顶部 `Walk` 区域，不提前接入跑步、睡眠、温泉、农具或生病动作。

## 处理结果

- 原始 GIF：817×1219、单帧索引色，SHA-256 为 `8395D840FE4E58D15835FF163E99827864254BD2186247CDDA422DA05F4709D4`。
- 原始文件备份：`D:\Archer\Project X Private Sources\mineral_town_player\player_sprite_sheet_original.gif`，位于项目和未来公开仓库之外。
- Walk 区域按真实像素边界整理为 96×96 PNG：每帧 24×32，向下、向上、侧向各 4 帧。
- 精确移除原表蓝色背景 `RGB(48,152,232)`，不缩放、不插值、不重绘角色像素。
- 向下、向上两组逐帧保留人物主体与脚下阴影，并移除由相邻源帧边缘带入的独立黑点和彩色碎点。
- 透明图集严格保持 96×96；清理后 SHA-256：`75780327ECC86AADFD3CB575C685133CCDFEBE3D91F1D2FF2EA5BE80270B8500`。
- 错误缩成 86×86 的修复前文件已备份到项目外：`D:\Archer\Project X Private Sources\mineral_town_player\player_walk_86x86_before_rebuild.png`。

## Godot 接入

- `PlayerController` 在 `_ready()` 中检查 `res://assets/private/mineral_town_player/player_walk.png`。
- 私有图存在时动态建立 `SpriteFrames`，播放 7 FPS 的 `walk_down`、`walk_up` 或 `walk_side`。
- 原表只提供一个向右侧向组；向右保留原帧，向左移动时用 `flip_h` 镜像。
- 停止移动时将动画停在当前方向第一帧，移动、碰撞、互动方向和存档位置完全沿用原逻辑。
- 私有图缺失或不是可加载纹理时隐藏 `AnimatedSprite2D`，继续显示场景自带的 CC0 `Sprite2D`，避免玩家不可见或场景解析失败。

## 私有素材边界

生成图集位于 `.gitignore` 已排除的 `assets/private/`，不进入未来公开仓库或公开素材包。项目代码只提供可选加载和回退逻辑，不包含原始动作表。

## 验收

1. 新游戏静止时显示矿石镇主角向下待机帧。
2. WASD 移动分别显示下、上、左、右行走；左右脚步方向正确，向下与向上帧旁没有黑点、彩色碎点或蓝色方块。
3. 松开移动键时停止在当前朝向，不继续原地踏步。
4. 玩家脚底与原 12×14 碰撞体对齐，靠近物品的黄色 E 框仍正确出现。
5. 临时移走私有图集后，主场景仍能启动并回退到原 CC0 小人。
