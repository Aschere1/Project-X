# 完全免费与开源农场像素素材路线

更新日期：2026-08-01

## 结论

Cozy 系列免费版内容不足，不适合作为 Project X 的长期主素材库。下一阶段改用以下组合：

1. 从完整、许可明确的免费环境包中选择一套作为统一的临时主美术。
2. 人物继续保留当前可玩的角色，另行制作原创 24×32 四方向角色；开源生成器只用于动作、服装分层和批量导出的参考。
3. CC0 小素材只补 UI、食物、图标与调试内容，不随意混入地图。
4. 所有第三方素材保存在 D 盘外部素材库，进入项目的文件必须带来源、许可和替换状态。

## 第一梯队：可作为临时主地图素材

### Serene Village Revamped

- 官方页：https://limezu.itch.io/serenevillagerevamped
- 许可：CC BY 4.0，可修改并用于商业或非商业游戏，发布时需要署名。
- 规格：16×16，俯视 2D/2.5D 像素风。
- 内容：地形、树木、岩石、蘑菇、24 栋房屋和动画物件。
- 优点：免费包本身完整，房屋正面、屋顶和地形层次比 Cozy 免费版更适合当前家园；视觉也比 Puny World 更接近温暖的小镇生活模拟。
- 限制：人物并不包含在包内；室内仍需单独补充；必须保留署名。
- 当前判断：**首选候选。** 先用它制作一张 HomeRegion 视觉样板，再决定是否作为原型期主环境。

### Puny World

- 官方页：https://merchant-shade.itch.io/16x16-puny-world
- 许可：CC0，可自由使用、修改与发布，不要求署名。
- 规格：全套 16×16。
- 内容：草地、树木、高低差、泥路、河流、海水、建筑、资源点和 Tiled 示例地图；水面带动画。
- 优点：法律边界最简单，地图覆盖面完整，尤其适合解决当前水面、河岸、道路和高低差问题。
- 限制：整体更小、更平、更偏复古 RPG，离《矿石镇》的体积感和温暖 2.5D 层次仍有距离。
- 当前判断：**第二候选。** 更适合作为地形技术样板或水面参考，不建议和 Serene Village 大量混用。

### Kenney Tiny Town

- 官方页：https://kenney.nl/assets/tiny-town
- 许可：CC0。
- 规格：16×16，130 个以上独立 PNG。
- 内容：城镇、城堡与大地图相关小型瓦片。
- 优点：文件拆分清楚、许可极宽松，适合快速摆放和调试。
- 限制：造型非常简洁，和《矿石镇》式角色与建筑比例差距较大。
- 当前判断：不作为主地图，只用于远景、小地图或系统占位。

## 第二梯队：系统素材与内容补充

### Kenney Pixel UI Pack

- 官方页：https://kenney.nl/assets/pixel-ui-pack
- 许可：CC0。
- 内容：750 个像素 UI 文件。
- 用途：背包、按钮、滑块、面板和系统调试界面。
- 判断：可直接作为临时 UI，但需要重新配色以接近矿石镇的暖色界面。

### OpenGameArt 的 Harvest Moon 风格 16×16 合集

- 合集页：https://opengameart.org/content/16x16-pixel-art-sprites-for-a-harvest-moon-style-game
- 内容：食物、物品、室内地砖、作物等多个独立包。
- 注意：合集不是统一许可，每个条目必须单独核对。优先挑 CC0 条目，例如：
  - 16×16 Food Items：https://opengameart.org/content/16x16px-food-items
  - 64 16×16 Food Sprites：https://opengameart.org/content/64-16x16-food-sprites
- 判断：很适合补料理、库存图标和小物件，不适合直接拼成统一地图。

### LPC Farm / Crops / Animals / Food

- 农场：https://opengameart.org/content/lpc-farm
- 作物：https://opengameart.org/content/lpc-crops
- 农场合集：https://opengameart.org/content/farm-assets
- 内容：谷仓、鸡舍、筒仓、机器、50 种五阶段作物、动物、食物、室内和大量城镇素材。
- 许可：以 CC BY 4.0、CC BY-SA、GPL 等为主，必须逐文件保留署名与相同方式共享要求。
- 规格：LPC 通常按 32×32 地砖与 64×64 人物画布组织。
- 判断：内容极完整，但尺寸、人物比例和审美不适合直接混入当前 16×16 矿石镇式场景。适合研究内容覆盖和动作表，不作为 Project X 主美术。

## 人物与动画生成器

### Universal LPC Spritesheet Character Generator

- GitHub：https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator
- 在线生成器：https://liberatedpixelcup.github.io/Universal-LPC-Spritesheet-Character-Generator/
- 特点：肤色、头发、服装、装备和大量动作可以分层组合，能随导出生成相应署名清单。
- 许可：素材逐件采用 CC0、CC BY、CC BY-SA、OGA-BY 或 GPL，不能把生成器的 GPL 代码许可误当成全部美术许可。
- 判断：非常适合研究可换装人物的数据结构和动作帧组织；其 64×64/LPC 比例不适合直接当正式主角。正式人物仍应按 Project X 的 24×32 基准原创绘制。

### pixel duuuuudes maker

- 官方页：https://masterpose.itch.io/pixelduuuuudesmaker
- 许可：页面称生成的 Sprite Sheet 为 CC0。
- 特点：能快速组合很小的 8-bit 人物。
- 判断：可生成大量测试 NPC，但风格过小、过简，不作为正式人物。

## 免费开源制作工具

### Pixelorama

- GitHub：https://github.com/Orama-Interactive/Pixelorama
- 许可：MIT。
- 能力：像素绘制、动画时间轴、洋葱皮、调色板、Tilemap 图层、无缝预览、Sprite Sheet/GIF 导出和命令行批量导出。
- 判断：**首选免费像素美术工具。** 可安装或解压到 D 盘，不需要放在 C 盘。

### Tiled

- 官网：https://www.mapeditor.org/
- GitHub：https://github.com/mapeditor/tiled
- 许可：GPLv2。
- 能力：多图层地图、地形笔刷、对象层和规则化铺图。
- 判断：适合编辑外部 TMJ/TMX 示例地图，但 Project X 已使用 Godot TileMapLayer；没有明确效率优势前不引入第二套正式地图编辑流程。

### Flites

- 官网：https://www.flites.app/
- 特点：免费开源的 Sprite Sheet 组装、帧对齐、动画预览、碰撞框编辑和导出工具。
- 判断：适合整理人物动作和碰撞参考，不负责生成统一风格的原创美术。

## 不采用或谨慎采用

- SpriteBrew：代码为 AGPL，但 AI 生成依赖额度，不能算完全免费的生产路线。
- Texel Studio：引擎可自托管，但官方云端采用每日额度和计费；在生成资产许可、模型依赖与稳定性完全核清前不进入项目流程。
- Aseprite：源码可见但当前许可并非普通开源软件；免费路线优先 Pixelorama 或 LibreSprite。
- 从开源游戏仓库直接复制 `assets/`：仓库代码的 MIT/GPL 许可通常不自动覆盖第三方美术，必须查看每个资产目录的许可文件。

## 当前推荐的美术验证顺序

1. 下载并解压 `Serene Village Revamped` 到 D 盘外部素材目录。
2. 下载 `Puny World`，只用于水面、道路、高低差和地图编辑对照。
3. 下载 Kenney Pixel UI Pack，做临时背包和菜单样板。
4. 不把 LPC 人物直接导入游戏；只建立一份动作与换装层清单。
5. 从 Serene Village 中挑一栋房屋、一棵树、一组地形与一段水岸，制作 HomeRegion A/B 样板。
6. 样板通过后，才批量整理 TileSet、碰撞、遮挡与 Y 排序。

最终原则：**先选一套主环境风格，再补功能素材；不能因为全部免费就把多套互不相容的贴图混成一张地图。**
