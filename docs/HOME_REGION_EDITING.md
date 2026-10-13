# 家园地图：自己调整碰撞、遮挡与水面

正式家园场景是 [home_region.tscn](../scenes/world/home_region.tscn)。它把可重复地面放进 TileMapLayer，把农舍、树和鸡舍放成独立 Sprite，并把“看得见的物体”和“实际能走到的位置”分开维护。

## 水面图集

池塘水面现在使用 `assets/third_party/puny_world/puny_world_overworld_tileset.png`
作为第二个 TileSet Atlas Source；草地、道路、耕地和岸边仍使用原有的家园图集。

- 水面艺术坐标在 `HomeRegion._set_modular_water_tile()` 中集中选择；当前只允许使用池塘截图左上角对应的纯水格 `(8,11)`。
- 池塘碰撞仍由 `PondCollision` 的 124×136 矩形控制，不能根据图片边缘自动推断。
- 若之后替换水岸，也应保留水面/岸边与碰撞三者分离的结构，并更新第三方来源记录。

## 池塘视觉验收

使用 `scenes/review/home_pond_review.tscn` 的“运行当前场景”可直接把镜头放在
池塘区域。该场景只在运行时移动玩家，不会修改正式出生点或保存任何位置。

同理，运行 `scenes/review/home_tree_review.tscn` 可确认玩家走到 TreeA 后方时，
树冠会淡化且树干碰撞仍保持在脚底位置。

## 调整碰撞箱

1. 在 Godot 中双击打开 `scenes/world/home_region.tscn`。
2. 在左侧节点树展开 `StructuralCollision`。
3. 选择要调整的节点，例如 `FarmhouseCollision`、`TreeACollision` 或 `PondCollision`。
4. 右侧 Inspector 中：
   - 改 `Position`，移动碰撞箱；
   - 点击 `Shape` 资源，再改 `Size`，改变宽高。
5. 运行游戏，在编辑器顶部菜单开启 `Debug → Visible Collision Shapes`，确认绿色形状只包住墙体底部、树干或真正水面。

约定：

- 农舍、鸡舍：只挡住前方墙体/门槛附近，不挡屋顶。
- 树：只挡树干，树叶只是视觉遮挡。
- 池塘：只挡真正水面，岸边留出少量可走区域。
- 不要通过缩放 `StructuralCollision` 父节点调整；直接改各自 `CollisionShape2D` 的 Position 和 Shape Size，数值最稳定。

农田周边的装饰也必须保持“画面节点 + 底边碰撞”成对存在。当前正式节点为：

- `Rock01`–`Rock04` 对应 `Rock01Collision`–`Rock04Collision`；
- `FieldEdgeCrate`、`FieldEdgeBarrel`、`FieldEdgePlantA`、`FieldEdgePlantB`、`FieldEdgeRockA` 对应同名的 `...Collision` 节点。
- `CoopFeedCrate`、`CoopWaterBarrel` 是鸡舍外侧的饲料/饮水储物装饰，也对应同名的 `...Collision` 节点。

这些碰撞故意只覆盖装饰接触地面的 4 像素左右，不覆盖树冠、箱体上半部或盆栽叶片。移动装饰时，应在 2D 视图同时移动 Sprite 和对应碰撞节点，并打开 `Debug → Visible Collision Shapes` 检查是否产生空气墙。

## 调整树叶与房顶遮挡

遮挡规则位于 [home_region.gd](../src/world/home_region.gd) 的 `_update_visual_occlusion()`。

每个 `Rect2(x, y, width, height)` 是“玩家走进这里后，物体应升到前景并半透明”的范围。想扩大树叶遮挡，就扩大树的矩形；想让透明程度更低，就调高 `OCCLUDER_FADED_ALPHA`，例如从 `0.48` 改为 `0.62`。

目前规则是：玩家脚底真正进入树冠或建筑背后的矩形时，遮挡物提升到玩家前方，并变为 48% 不透明；走到门前、墙前或树干前方时必须保持不透明。遮挡矩形的下边缘应停在实体碰撞的后侧/上侧，不能覆盖门前道路。

三棵家园树目前使用 Serene Village Revamped 图集的裁切树精灵 `Rect2(176, 192, 32, 48)`；它保留树冠和树干，并去掉底部脱离树干的叶片。为匹配家园比例，视觉等比放大为 1.5 倍并上移 12 像素；树干碰撞收紧为 8×8，树冠遮挡矩形均不随视觉替换而扩大。树后近景中看到玩家透过淡化树冠是预期效果，不是图集混入角色。

## 调整水面

水面当前来自 Puny World 的 CC0 图集，并只平铺其中一个经过实际画面确认的纯水格 `(8,11)`。不要把带睡莲、岸边、半块石头或预拼水岸的格子混入水底层；它们会在重复后形成明显的拼接痕迹。

正式家园当前的池塘水岸由 `Terrain` 层保存的 Super Retro 自动连接瓦片组成。`FishingPond` 是池塘上岸交互点，位置仍可在 Inspector 中调整；其水面标记的 `Visual Offset` 当前为 `Vector2(0, 32)`，目的是让标记完全落在水面内，不在上沿额外绘制一格水。以后要增加波纹或睡莲时，应把它们放到独立的 `Objects`/`Foreground` 装饰层，只放在少量指定坐标，不能作为每格都会重复的水底。

土壤状态可在 `scenes/reviews/farm_soil_visual_review.tscn` 中集中检查。五个实例的 `Editor Preview State` 分别是未耕、干耕、湿耕、干土作物和湿土作物；正式农田仍只在运行时根据领域状态切换表现，不把预览场景当成游戏逻辑。

## 控制奔跑

默认按住 `Shift` 奔跑；游戏代码读取的是 `sprint` 动作，而不是直接读取 Shift。若要改键，请进入 `Project → Project Settings → Input Map`，找到 `sprint` 后替换或追加按键。移动速度和动画速度倍率位于 `Player` 的 Inspector，或 `player_controller.gd` 的 `sprint_speed_multiplier`、`sprint_animation_speed_multiplier`。

## 存档格

- `K`：打开三个手动存档格，选择一个格位保存。
- `L`：打开三个手动读档格；选择已有格位后，必须再次确认才会读取。

三格均独立保存，覆盖时由存档系统保留旧档备份。自动存档仍独立运行，不会占用手动格。

## 食材来源与天气

- 草地采集点：靠近左侧蘑菇标记按 `E`，每天一次；晴天、阴天、雨天会从不同的野外食材表中稳定抽取。

## 正式料理台

- 家园正中央偏右的 `CookingCounter` 是可见的“露天料理台”；靠近时显示 `E 露天料理台`，按 `E` 打开料理面板。
- 面板打开时世界时间和玩家输入会暂停。`C` 切换厨具、`T` 切换当前食材、`G` 加入、`H` 选择调味、`J` 烹饪、`U` 清空，`E` 关闭并恢复行动。
- `V` 在“全部、农田、采集、钓鱼、动物”食材分类间循环。面板会显示当前食材来自哪里，以及该来源目前的取得方式或每日限制。
- 料理台本身不参与阻挡；替换图片时只替换 `CookingCounter` 的 `visual_texture`，不要删除节点或改动 `cooking_counter` ID。
- 视觉验收可运行 `scenes/review/home_cooking_review.tscn`。它只会打开正式料理面板以便截图，不会改动存档或正式出生点。
- 池塘钓点：靠近池塘上岸的木牌按 `E`，每天最多三次；雨天有机会钓到雨鳗，晴天则以鲫鱼和鳟鱼为主。
- 雨天会在每日结算前自动浇灌已种作物，并在顶部天气栏显示“农田自动浇水”。
- 采集状态和当天钓鱼次数会写入三格手动存档与自动存档，读档不会重复刷取。

## 鸡舍内部视觉审查

打开 `scenes/reviews/chicken_coop_visual_review.tscn` 可以检查鸡舍内部的最低可用布局：母鸡、饲料箱、饮水桶、盆栽、活动空间和碰撞边界都作为独立节点保存在场景中。它是表现审查场景，不复制 `ChickenCoop` 的喂食、抚摸、产蛋和存档逻辑；正式家园仍从 `StarterChickenCoop` 交互入口进入照料流程。
