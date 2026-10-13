# 灾变地点运行贴图

这里保存外出地点的静态 `TextureRect` 插图。它们只负责地点氛围和热点可读性，不参与碰撞、TileMap、寻路或领域规则。

## backgrounds/ 生成背景

- `backgrounds/apocalypse_shelter_entry_generated.png`：启动入口的庇护所远景，仅作为标题背景，不替代可点击庇护所地图。
- `backgrounds/county_market_generated.png`：县城市场搜刮场景的主背景，已接入 `scenes/reviews/apocalypse_market_review.tscn`。
- `backgrounds/industrial_warehouse_generated.png`：未来工业仓库地点的预备背景，当前仅归档，不开放地图入口或搜刮逻辑。
- 三张图均为用户本轮提供的原创生成图；正式分发前仍需确认生成平台条款与最终可分发许可。

## county_clinic.png

- 用途：`scenes/reviews/apocalypse_explore_review.tscn` 的“县郊·村卫生室”地点背景。
- 来源：用户提供的生成图，本项目接入时按 16:9 地点卡使用。
- 接入方式：通过 Godot Inspector / 场景资源的 `location_illustration` 属性引用。
- 许可：正式发布前需要用户确认该生成图的来源、生成平台条款和最终可分发许可；在确认前不把它标记为已完成的商业发行素材。
- 替换规则：可直接替换同路径 PNG，或在 Godot Inspector 中拖入新的 Texture2D，不修改搜刮领域和 UI 逻辑。

## 背包物品图标

- `items/water.png`、`items/medkit.png`、`items/bandage.png`：用户提供的三张图已从 JPG 转为 PNG 后接入审查场景的可替换图标属性。
- 原图带纯黑背景；审查场景使用 Godot ShaderMaterial 将近黑背景转为透明显示，保留图标轮廓。
- 如果黑底键控误伤暗色边缘，可由用户提供透明背景 PNG 直接替换，删除材质键控也不会影响背包领域逻辑。

## 庇护所家园与主角头像

- `shelter/apocalypse_shelter.png`：用户提供的俯视末日农场家园总地图，包含主屋、鸡舍、牛羊猪棚、储物棚、工作区、水点和菜地。
- `characters/survivor_avatar.png`：用户提供的主角头像。庇护所已改为静态点击地图，因此它不再作为地图移动标记；文件保留给后续背包、装备、角色资料和剧情对话立绘使用。
- `apocalypse_shelter.png` 已通过 `scenes/world/apocalypse_shelter.tscn` 的资源属性接入。主角头像不绑定在家园地图场景中，后续可由对应 UI 独立替换。
- 正式发布前仍需确认生成平台条款和最终可分发许可。

## 区域地图与主屋室内

- `world/apocalypse_region_map.png`：用户提供的县域俯视地图，包含县城、道路、河流、乡村和左下方的庇护所图标；后续由 Godot 在其上叠加可点击地点标记。
- `shelter/main_house_interior.png`：用户提供的主屋俯视室内图，包含睡眠、储物、工作台、烹饪/净水等功能区；后续接入主屋室内场景。
- 两张图作为静态背景使用，位置、地点按钮、碰撞和交互仍由 Godot 场景负责，不把图片中的图标当作领域数据。
- UI 素材：
  - `ui/frames/interaction_prompt.png`：互动提示横向框。
  - `ui/frames/zone_panel.png`：功能区弹窗九宫格边框。
  - `ui/frames/avatar_frame.png`：头像状态框。
  - `ui/rarity/`：普通、优秀、稀有、史诗、金色品质框；金色框使用真透明版本。
  - `ui/containers/`：储物柜、木箱、抽屉、医疗柜、箱子、救护车、背包和保险箱图标。
  - `ui/slots/`：背包格子及金色/蓝色选中状态。
  - `ui/status/`：受伤、口渴、噪音、感染、饥饿和时间警告图标。
  - `ui/markers/`：地图玩家标记和选中环。
