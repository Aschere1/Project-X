# Project X：Godot 完全新手可视化操作手册

这份手册只针对当前 Project X 项目。你不需要先学会编程，也不要打开或修改 `.gd` 脚本。

当前目标是让你能够独立完成：

1. 打开完整家园。
2. 查看地图、建筑、角色、交互物和碰撞。
3. 修改草地、道路、水面、农田和围栏。
4. 移动建筑、树、玩家出生点和交互物。
5. 调整碰撞框。
6. 保存、撤销并启动游戏检查结果。

---

## 一、第一次打开

### 推荐方法：使用一键入口

打开文件夹：

`D:\Archer\Project X`

双击：

`编辑家园地图.bat`

它会启动 Godot，并直接打开完整家园场景：

`res://scenes/world/home_region.tscn`

这个场景现在同时包含：

- 地面、道路、水、农田和围栏。
- 农舍、树、鸡舍和岩石。
- 玩家出生点。
- 家门、农田、鸡舍、料理台、采集点和钓鱼点。
- 建筑、树、池塘和地图边界的碰撞框。
- 游戏时间、背包、料理、存档和 UI 节点。

### 如果一键入口仍然没有打开

1. 运行 `D:\Archer\Tools\Godot\4.7.1\Godot_v4.7.1-stable_win64.exe`。
2. 在 Project Manager 中点击 `Import`。
3. 选择：`D:\Archer\Project X\project.godot`。
4. 点击 `Import & Edit`。
5. 进入编辑器后，在左下角 `FileSystem` 中依次展开：
   `scenes` → `world`。
6. 双击 `home_region.tscn`。

不要打开已经废弃的独立 `home_region_map.tscn`。完整编辑入口只有 `home_region.tscn`。

---

## 二、认识 Godot 界面

打开 `home_region.tscn` 后，主要看五个区域。

### 1. 左上角：Scene 场景树

这里列出当前家园的所有内容。可以把它理解成“图层和物品清单”。

重要节点：

| 节点 | 含义 | 是否适合直接修改 |
|---|---|---|
| `Ground` | 基础草地 | 可以绘制 |
| `Terrain` | 道路、水面、农田 | 可以绘制 |
| `Objects` | 围栏等地图物件 | 可以绘制 |
| `Foreground` | 人物前方的遮挡图层 | 谨慎绘制 |
| `DecorationSprites` | 岩石等独立装饰 | 可以移动 |
| `Farmhouse` | 农舍图片 | 可以移动 |
| `TreeA/B/C` | 三棵树 | 可以移动 |
| `ChickenCoopExterior` | 鸡舍图片 | 可以移动 |
| `StructuralCollision` | 所有结构碰撞 | 可以展开后调整 |
| `HomeEntrance` | 家门交互点 | 移动农舍时一起移动 |
| `StarterField` | 农田交互点 | 移动农田时一起移动 |
| `StarterChickenCoop` | 鸡舍交互点 | 移动鸡舍时一起移动 |
| `CookingCounter` | 料理台交互点 | 可以移动 |
| `ForageMeadow` | 采集点 | 可以移动 |
| `FishingPond` | 钓鱼点 | 移动池塘时一起移动 |
| `Player` | 玩家出生点 | 可以移动根节点 |
| `Interface` | HUD 和菜单 | 暂时不要修改 |

节点左侧的小眼睛可以临时隐藏显示。不要通过删除节点来“暂时不看它”。

### 2. 中间：2D 视图

这里就是地图画布。

常用操作：

| 操作 | 方法 |
|---|---|
| 缩放 | 鼠标滚轮 |
| 平移画布 | 按住鼠标中键拖动 |
| 选择物体 | 左键点击物体，或在 Scene 树点击节点 |
| 移动物体 | 选择后拖动红/绿箭头 |
| 聚焦选中物体 | 选中节点后按 `F` |
| 撤销 | `Ctrl+Z` |
| 重做 | `Ctrl+Shift+Z` |
| 保存 | `Ctrl+S` |

如果打开后看不到地图：

1. 在 Scene 树选中 `Farmhouse`。
2. 把鼠标移到中间 2D 视图。
3. 按 `F`。
4. 用滚轮向下缩小，直到能看到周围地图。

### 3. 右侧：Inspector 属性栏

选中节点后，这里显示它的参数。

最常用的属性：

- `Position`：位置。
- `Scale`：缩放。像素素材通常保持整数或已经设定的比例，不要随意改成 1.37 之类的小数。
- `Texture`：图片。
- `Visible`：是否显示。
- `Z Index`：绘制前后顺序。
- `Shape`：碰撞形状。
- `Interaction Id`：交互物的稳定身份，不要随便改。
- `Display Name`：游戏内名称，可以改中文。
- `Interaction Description`：交互说明。
- `Grid Cell`：交互物所在的 16×16 网格坐标。

### 4. 左下角：FileSystem 文件区

这里是项目文件。

你最常用的目录：

- `scenes/world/`：地图和交互物场景。
- `scenes/player/`：玩家场景。
- `assets/private/super_retro_world_farming/`：当前 Super Retro 素材。
- `content/`：作物、物品、天气等数据。

不要移动或重命名已经在使用的图片和场景，否则引用会失效。

### 5. 底部：TileMap 地图绘制面板

只有选中 `Ground`、`Terrain`、`Objects` 或 `Foreground` 时才会出现。

主要标签：

- `Tiles`：手工选择并绘制单个瓦片。
- `Patterns`：绘制预先组合好的区域。
- `Terrains`：自动连接道路、水岸和围栏。

---

## 三、最安全的第一次练习

第一次不要移动农舍，也不要改池塘。先练习增加和撤销一小块草地。

1. 在 Scene 树点击 `Ground`。
2. 底部会出现 TileMap 面板。
3. 点击 `Tiles`。
4. 在图集里选择纯草瓦片。当前使用的是图集坐标 `(18,30)`。
5. 在地图角落左键点一下。
6. 按 `Ctrl+Z`，确认刚才的修改被撤销。
7. 不保存这次练习也可以。

纯草格是完整不透明底图。带花、草叶、阴影或边缘的瓦片不能铺满 `Ground`，否则会形成重复点阵或出现切边。

---

## 四、修改地面

### 铺纯草地

1. 选中 `Ground`。
2. 打开底部 `Tiles`。
3. 选择纯草瓦片 `(18,30)`。
4. 使用铅笔工具绘制单格，或使用矩形工具铺大片区域。
5. 使用橡皮工具删除错误瓦片。

`Ground` 应覆盖整张可见地图，不能大面积留空，否则会显示编辑器背景或透明区域。

### 添加少量花草装饰

不要把花草画到整张 `Ground`。

推荐做法：

1. 选中 `Objects`。
2. 在 `Tiles` 中选择花、草叶或小石头。
3. 每隔较远距离放一两个。
4. 不要形成整齐棋盘阵列。

---

## 五、修改道路

道路应使用 `Terrain` 自动连接，不要逐块猜转角。

1. 选中 Scene 树的 `Terrain`。
2. 在底部选择 `Terrains`。
3. 在左侧 Terrain 列表中选择草地到道路对应的 Terrain。
4. 选择 `Connect` 或画笔模式。
5. 在地图上按住左键拖动道路。
6. Godot 会自动选择直线、转角、T 形路口和边缘。
7. 用右键或橡皮工具删除错误区域，再重新连接一次。

如果道路出现奇怪断角，先撤销，不要用其他不相关瓦片补洞。通常是选错 Terrain，或者在错误图层绘制。

---

## 六、修改池塘和水面

池塘画面在 `Terrain`，碰撞和钓鱼点是独立节点。

### 改水面形状

1. 选中 `Terrain`。
2. 底部选择 `Terrains`。
3. 选择草地到水面的 Terrain。
4. 用画笔扩大或缩小池塘。
5. 检查水岸转角是否自动连接正确。

### 同步修改池塘碰撞

只改画面不改碰撞，会出现“走进水里”或“空气墙”。

1. 在 Scene 树展开 `StructuralCollision`。
2. 选择 `PondCollision`。
3. 在 2D 视图中拖动碰撞框控制点。
4. 让碰撞覆盖实际水面，岸边保留窄小可走区域。

### 同步修改钓鱼点

1. 选择 `FishingPond`。
2. 把它拖到玩家能够站在岸边互动的位置。
3. 不要把钓鱼点放到水中央。

---

## 七、修改农田与围栏

农田底图在 `Terrain`，围栏在 `Objects`，可操作农田由 `StarterField` 和 `FarmPlots` 下的 219 个独立 FarmPlot 场景实例组成。正式家园当前是 20×11 格农田。

### 修改农田形状

1. 选中 `Terrain`。
2. 在 `Tiles` 中选择耕地瓦片。
3. 使用矩形工具铺设农田。
4. 保持 16×16 网格对齐。

### 修改围栏

1. 选中 `Objects`。
2. 底部打开 `Terrains`。
3. 选择围栏 Terrain。
4. 沿农田边缘绘制。
5. 给入口留出至少两格宽度，不要用围栏完全封死。

### 同步移动农田交互点

1. 选择 `StarterField` 或展开 `FarmPlots` 后选择具体的 `FarmPlot_x_y`。
2. 直接拖动根节点，让它落在对应耕地瓦片中心；不要移动 `FarmPlot` 内部的碰撞子节点。
3. 在 Inspector 检查 `Position` 与 `Grid Cell` 是否对应：`Position = (x*16+8, y*16+8)`。
4. 如果整体移动农田，优先移动 `Terrain`、围栏和 `FarmPlots` 父节点，再检查入口和碰撞。

每个 FarmPlot 的 `Interaction Id` 必须保持唯一；复制新格子后要同步修改名称、`Interaction Id` 和 `Grid Cell`。不要把这些坐标写回玩法脚本。

---

## 八、移动建筑

移动建筑时必须同时移动视觉、碰撞和交互点。

### 移动农舍

需要一起调整三个节点：

| 内容 | 节点 |
|---|---|
| 农舍图片 | `Farmhouse` |
| 农舍底墙碰撞 | `StructuralCollision/FarmhouseCollision` |
| 家门交互点 | `HomeEntrance` |

操作顺序：

1. 选择 `Farmhouse` 并记录 Inspector 中原来的 `Position`。
2. 拖到新位置。
3. 用同样位移移动 `FarmhouseCollision`。
4. 把 `HomeEntrance` 移到门外脚下。
5. 保存并试玩。

碰撞框只应该覆盖建筑底部墙脚，不能覆盖整个屋顶。

### 移动鸡舍

一起调整：

- `ChickenCoopExterior`
- `StructuralCollision/ChickenCoopCollision`
- `StarterChickenCoop`
- 必要时移动 `StarterHen`

### 移动树

对应关系：

| 树图片 | 碰撞 |
|---|---|
| `TreeA` | `TreeACollision` |
| `TreeB` | `TreeBCollision` |
| `TreeC` | `TreeCCollision` |

树的碰撞只覆盖树根底部，不能覆盖树冠。

---

## 九、移动玩家出生点

1. 在 Scene 树选择最外层的 `Player`。
2. 不要展开后移动里面的 `Sprite2D`、`AnimatedSprite2D` 或 `CollisionShape2D`。
3. 直接拖动整个 `Player` 到新的出生位置。
4. 出生点不能放在房屋、树根、水、围栏或地图边界里。
5. 保存后运行游戏检查。

如果只移动了玩家图片子节点，碰撞仍会留在原地，必须立即撤销。

---

## 十、移动和添加交互物

### 移动已有交互物

可以移动：

- `CookingCounter`
- `ForageMeadow`
- `FishingPond`
- `HomeEntrance`
- `StarterField`
- `StarterChickenCoop`

选择节点后直接拖动根节点，不要只拖它里面的图片或碰撞子节点。

### 新增普通可交互物

熟悉编辑器后再做：

1. 在 FileSystem 找到 `scenes/world/grid_interactable.tscn`。
2. 把它拖到中间 2D 视图。
3. 在 Scene 树给新节点起唯一英文名。
4. 在 Inspector 填写：
   - `Interaction Id`：唯一、稳定的英文小写 ID。
   - `Display Name`：游戏中显示的中文名称。
   - `Interaction Description`：互动提示。
   - `Grid Cell`：对应网格。
5. 指定可见图片或使用独立 Sprite。

不要复制已有交互物后保留相同 `Interaction Id`，否则存档和互动可能冲突。

---

## 十一、修改碰撞

### 在编辑器中调整

1. 展开 `StructuralCollision`。
2. 选择一个 `CollisionShape2D`。
3. 中间画面会显示彩色轮廓和控制点。
4. 拖动中心移动碰撞。
5. 拖动边缘控制点调整大小。

### 牧场类游戏的碰撞规则

- 玩家碰撞在脚底，不包住整个头和身体。
- 树只碰撞树根。
- 建筑只碰撞底部墙脚。
- 桌子、箱子等物品只碰撞接触地面的底部。
- 屋顶和树冠属于遮挡画面，不应成为大块空气墙。
- 水面碰撞覆盖水域，不覆盖岸边草地。

### 运行时显示碰撞

1. 在 Godot 顶部菜单点击 `Debug`。
2. 勾选 `Visible Collision Shapes`。
3. 按 `F6` 或 `F5` 运行。
4. 游戏中会显示碰撞轮廓。

检查完可以取消勾选。

---

## 十二、保存和试玩

### 保存

按 `Ctrl+S`。

场景标签上如果有 `(*)` 或未保存标记，说明修改尚未保存。

### 运行当前家园场景

按 `F6`。如果 Godot 询问选择当前场景，确认运行 `home_region.tscn`。

### 运行完整游戏

按 `F5`，或者退出编辑器后双击：

`启动游戏.bat`

### 每次修改后的最低检查

1. 玩家能否正常出生。
2. 是否能沿道路移动。
3. 是否出现空气墙。
4. 是否能走进水里。
5. E 提示是否出现在正确物体旁。
6. 角色走到屋后和树后时透明效果是否合理。
7. 农田格和画面是否对齐。

---

## 十三、改错了怎么办

### 还没有保存

- 按 `Ctrl+Z` 多次撤销。
- 或关闭场景，选择不保存，再重新打开。

### 已经保存

先停止继续修改，把具体操作和截图发给 Codex。不要为了修一个错误继续删除大量节点。

### 绝对不要做

- 不要删除 `HomeRegion` 根节点。
- 不要重命名 `Ground`、`Terrain`、`Objects`、`Foreground`、`Player`、`Interface`。
- 不要修改 `.gd` 文件。
- 不要更换四个 TileMapLayer 的 `Tile Set`。
- 不要把所有内容都画在同一层。
- 不要删除碰撞只为了临时通过。
- 不要移动整个 `StructuralCollision` 根节点；移动里面的具体碰撞框。

---

## 十四、四个地图图层应该放什么

| 图层 | 应该放 | 不应该放 |
|---|---|---|
| `Ground` | 连续基础草地、基础地面 | 房屋、树、围栏、大量装饰 |
| `Terrain` | 道路、水岸、水、农田 | 角色、交互物、UI |
| `Objects` | 围栏、小型地图装饰 | 屋顶遮挡、玩家 |
| `Foreground` | 树冠、屋顶等始终需要盖住角色的部分 | 地面、道路、碰撞逻辑 |

大型建筑、树、动物、角色和交互物优先使用独立节点，而不是强行切成普通地砖。这样更容易移动、做动画、调整碰撞和透明遮挡。

---

## 十五、Godot 可以做到多少可视化

Godot 原生可以可视化编辑：

- 场景树和对象组合。
- TileMap 和 Terrain 地图。
- 图片、位置、缩放和绘制顺序。
- 碰撞、导航和遮挡。
- 逐帧动画和动画时间轴。
- UI 界面。
- 粒子和灯光。
- Inspector 中暴露的作物、物品、NPC 和交互参数。
- 信号连接。

Godot 4 不再内置旧版 VisualScript，所以复杂玩法规则仍然需要 GDScript。但 Project X 的工作方式是：

> 你在编辑器里负责地图、摆放、外观和数值；Codex 负责底层规则代码。

因此你不需要为了扩地图、移动建筑、摆 NPC、修改碰撞或调整交互位置而学习写代码。

---

## 十六、建议的学习顺序

不要一次学习整个 Godot。按下面顺序练习：

1. 打开场景、缩放和平移。
2. 选择节点、查看 Position、撤销和保存。
3. 在 `Ground` 画一格草再撤销。
4. 用 Terrain 延长一小段道路。
5. 移动一个岩石装饰。
6. 打开碰撞显示并试玩。
7. 移动一棵树及其树根碰撞。
8. 最后才尝试改变池塘、农田或建筑布局。

每完成一步就运行一次游戏。不要积累几十项修改后再统一检查。

---

## 十七、农田与交互标记的当前资源

- `FarmPlots` 是 `home_region.tscn` 中保存的 219 个 `FarmPlot` 实例；首块 `StarterField` 加入后形成 20×11 网格。可以在 2D 视图中选中单格拖动，移动后同步检查 Inspector 里的 `Grid Cell`。
- 作物外观由 `content/catalogs/super_retro_crop_visual_catalog.tres` 维护，换图应在 Resource Inspector 中替换，不要在 `FarmPlot` 代码里写纹理路径。
- 料理台、采集点、钓鱼点的当前标记分别是 Super Retro 的锅、盆栽和水面素材，直接挂在场景节点的 `Visual Texture` 上，可以在 Inspector 中替换。
- 鸡目前仍使用独立的 `StarterHen` 素材，因为 Super Retro Farming 资源包没有合适的鸡；不要用鸟类素材冒充。正式 HomeRegion 会隐藏鸡舍交互实例内部的原型构件，只由 `home_region.tscn` 中的 Super Retro 建筑节点承担外观。后续补齐专用鸡舍素材时只替换外观 Sprite，不改变交互 ID、碰撞或存档。
