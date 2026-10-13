# 基础像素贴图公开素材调研

调研日期：2026-07-31  
适用范围：当前 Godot 4.7.1、PC 优先、16×16 网格的 2D 俯视生活模拟原型。  
结论性质：开发决策参考，不构成法律意见。

## 结论

当前最稳妥的落地组合是：

1. **主视觉试装：Sunnyside World**。免费（自由定价）、16×16、题材完整，允许商业与非商业项目使用和修改；它最适合立刻替换草地、道路、农田、房屋、作物与室内灰盒。
2. **低风险补充：Kenney Tiny Town / Roguelike RPG Pack**。两者均为 CC0，可放入公开仓库，也适合补齐城镇物件、室内家具与通用图标。
3. **Godot 导入参考：Ninja Adventure 的 Godot 4 工程**。也是 CC0，适合学习 16×16 TileSet、动画、UI 和音效组织；忍者主题不应成为本作主视觉。
4. **暂不直接采用《牧场物语：矿石镇》原始贴图**。可以研究其比例、配色、轮廓、地图密度和动画节奏，但不得提取、转载或随项目分发原始素材。

Godot 官方商店的 **Super Retro World - Farming** 在内容覆盖上最贴合，但许可证明确禁止把原素材上传到仓库或文件分享服务，且当前版本被发布者标记为 unstable。因此它只能作为私有试装候选，不能在未设计私有素材流程前直接并入当前工作区。

## 为什么不能直接使用《矿石镇》贴图

“网上能找到”不等于“允许用于游戏开发”。Nintendo 的官方内容分享规则只覆盖带创作性内容的游戏视频与截图分享，并没有授予把游戏视觉元素提取后用于另一款游戏的许可；规则还明确把未经授权使用游戏视觉元素以及数据挖掘取得的图像等列为不允许的情况。[Nintendo 游戏内容分享规则](https://www.nintendo.co.jp/networkservice_guideline/en/index.html)

因此本项目只继承《矿石镇》的**设计语言**，不继承其原始像素文件：

- 可研究：16×16 单元、暖色低对比调色、人物头身比、农田与道路占比、建筑可读性、交互物轮廓。
- 不可采用：从 ROM、截图、素材站或他人转载包中切出的地块、角色、动物、UI、图标与动画帧。
- 可行替代：用合法公开素材完成玩法验证，随后基于自己的轮廓、色板和细节规则逐步原创替换。

## 候选比较

| 候选 | 尺寸与内容 | 许可与费用 | Godot 适配 | 决策 |
|---|---|---|---|---|
| [Sunnyside World](https://danieldiggle.itch.io/sunnyside) | 16×16；地形、悬崖、道路、泥地、水、树木、围栏、建筑、室内、UI、11 种五阶段作物、角色动作 | 免费/自由定价；自定义许可；商业和非商业均可、可修改、无需署名；不得重新打包转售；不得用于 AI 训练 | 通用 PNG、GIF、部分 Aseprite 源文件；页面列出 Godot，但无预配 Godot TileSet | **首选主视觉占位**；题材和气质最吻合。角色主包主要按左右方向制作，应优先使用页面另附的 4/6/8 方向测试角色或暂留现有角色控制表现 |
| [Kenney Tiny Town](https://kenney.nl/assets/tiny-town) | 16×16；130 个城镇、世界地图类文件 | 免费；CC0；无强制署名 | 通用图片，需自行建立 TileSet | **推荐补充**；法律风险最低、适合公开仓库，但农作物和人物动画不够完整 |
| [Kenney Roguelike/RPG Pack](https://kenney.nl/assets/roguelike-rpg-pack) | 16×16；约 1700 个城镇、家具、面板、按钮等文件 | 免费；CC0；无强制署名 | 通用图片，需自行切图和配 TileSet | **推荐补充**；覆盖面大，适合室内与 UI 占位，但风格偏符号化，不能与高细节素材随意混搭 |
| [Ninja Adventure](https://pixel-boy.itch.io/ninja-adventure-asset-pack) | 16×16；角色、怪物、地形、室内、物品、UI、字体、音效、音乐、特效 | 免费/自由定价；CC0；商业可用、可修改、无需署名 | 作者提供 [Godot 4 工程](https://github.com/pixel-boy/NinjaAdventure) | **推荐作技术参考与局部占位**；导入路径最省事，但主题和本作温暖农场方向不一致 |
| [Super Retro World - Farming](https://store.godotengine.org/asset/gif/super-retro-world/) | 16×16；15+ 作物、地形 Terrain、水/瀑布动画、32 个四方向角色、耕作动作、动物、房屋、商店、室内外道具 | 免费；[自定义商业许可证](https://storage.rpgpowerforge.com/super-retro-world.license)；商业/非商业可用、可修改、无需署名；不得把原素材或素材包重新分发、上传仓库/市场/网盘，也不得公开为可提取的独立形式或用于 AI 训练 | 已提供 TileSet、Terrain 与 spritesheet | **有条件首选**；内容最完整，但只能私有保存和试装。官方条目 v1.0.3 标为 unstable 且没有明确 Godot 版本信息，需隔离验证 |
| [Top-Down Prototype Character](https://store.godotengine.org/asset/snoblin/top-down-prototype-character/) | 16×16；四方向、多配色；待机、行走、受伤、死亡 | 免费；CC0；无强制署名 | PNG；条目声明兼容范围最高到 Godot 4.5，但图片本身可手工导入 4.7.1 | **安全角色占位**；可公开提交，缺少锄地、浇水等生活模拟动作 |
| [Sprout Lands](https://cupnooble.itch.io/sprout-lands-asset-pack) | 16×16；粉彩农场、动物、作物、地形、四方向耕作动画（高级包） | 基础包免费但**仅限非商业**且要求署名；高级包至少 3.99 美元，可商业使用和修改，禁止重新分发/转售 | 通用 spritesheet，需自行配置 | **仅学习或非商业私有原型**；视觉很合适，但免费版会形成未来商业化替换成本，不应作为默认依赖 |
| [Tiny Farm RPG](https://maevedevs.itch.io/farm-rpg) | 16×16/32×32；角色、农具、钓鱼、动物、四季作物、室内、图标等，内容丰富 | 免费小包 + 至少 6.49 美元完整包；页面明确的是“完整版许可”：商业/非商业可用、可修改，不得再分发/转售，不得用于 NFT 或 AI 训练 | 通用 PNG/Aseprite；需手工配置 | **后续付费候选**；完整版价值高，但免费包适用条款没有单独写清，采用前应邮件确认或只购买完整包并保存购买凭证 |
| [Mini Farm Asset Pack](https://jofra.itch.io/mini-farm) | 16×16；农场、动物、作物、建筑；仍为 WIP，下载仅 16 KB | 页面同时写“CC0”和“禁止单独再分发”，两者表达存在冲突；作者账号标为停用 | 通用图片 | **淘汰**；许可表述矛盾、维护与内容完整性不足 |
| [2DPIXX Free Isometric Fantasy Pack](https://store.godotengine.org/asset/twodpixx/test/) | 128×128 等距地牢、森林、村庄与角色 | 免费；CC BY 4.0；必须署名 Jana Ochse / 2DPIXX | Godot 官方商店包 | **淘汰**；尺寸、视角与农场题材均不匹配 |

CC0 的含义以 [Creative Commons CC0 1.0 原文](https://creativecommons.org/publicdomain/zero/1.0/legalcode.en)为准：权利人尽可能放弃相关版权与权利主张，并提供公共许可兜底；但 CC0 不处理商标、专利、肖像等第三方权利，也不提供无侵权保证。因此即使是 CC0，仍需保留来源记录并避免混入不明转载素材。

## Godot 官方资源库的判断

Godot 官方已在 2026 年宣布旧 Asset Library 将继续运行但进入弃用与只读阶段，Godot 4.7/4.8 的重点转向新版 Asset Store。[Godot 官方公告](https://godotengine.org/article/introducing-the-godot-asset-store/)

这两处资源库更擅长提供插件、模板、Demo 与导入工作流，不保证能找到艺术方向一致的完整农场包。可参考但不直接并入的项目：

- [Topdown Pixelart Starter Project](https://godotengine.org/asset-library/asset/2397)：Godot 4.3、MIT，含两个 TileSet、NPC、图标、灯光和粒子，适合学习工程组织；不是农场主题。其上游 README 还要求保留 m3x6 字体作者 Daniel Linssen 的署名。
- [Connected Tileset Template 16px](https://godotengine.org/asset-library/asset/5103)：Godot 4.3、MIT、47-tile 自动连接模板，适合学习 terrain 拼接；它是技术模板而不是成品美术，并且上游说明偏横版用途。
- `Simple Tileset`：旧库条目仍在，但当前上游仓库链接返回 404，无法可靠复核文件与许可证，故淘汰。

MIT 素材或工程若被分发，必须随分发保留版权与许可声明；不能因为它显示在 Godot 官方资源库里，就当作 CC0 或“无条件免费”。

## 推荐实施方案

### 第一阶段：先做一张合法素材试装地图

用 **Sunnyside World** 替换一个小范围场景，不要一次替换整个游戏：

- 草地、水、泥地、道路与围栏。
- 玩家房屋、鸡舍和一组室内家具。
- 六种现有作物各映射一个生长序列。
- 鸡、钓鱼点、采集点各替换一个交互外观。
- 暂时不替换需要完整四方向工具动画的玩家角色。

验收重点不是“素材好不好看”，而是：16×16 拼接是否无缝、碰撞轮廓是否清晰、交互高亮是否可读、雨天颜色是否仍有对比、UI 与世界色板是否冲突。

### 第二阶段：建立原创化边界

公开素材只作为生产起点，正式视觉逐步收敛为自己的规则：

- 固定一套原创色板与阴影方向。
- 建筑轮廓、屋顶形状、角色头身比和作物剪影不直接复刻任一参考游戏或单一素材包。
- 交互物必须在无提示时也能通过轮廓识别，选中提示只是确认，不代替造型可读性。
- 混用素材前统一像素密度、描边颜色、光源方向和饱和度；不把多个包原样拼在同一画面。

### 第三阶段：再决定是否使用受限的 Godot 农场包

若需要快速获得完整人物耕作动作，可在**工作区之外的私有测试目录**试装 Super Retro World：

1. 保存下载时间、原始 ZIP、来源 URL、许可证原文和文件哈希。
2. 先检查其 TileSet/Terrain 是否能在 Godot 4.7.1 无警告打开。
3. 确认项目仓库不会公开原 PNG、spritesheet、`.tres` 图集资源或可直接还原的素材文件。
4. 只有在版本控制与成品导出都满足许可证时才合并；否则继续用 CC0 或 Sunnyside。

## 素材管理规则

每个采用的素材包至少记录：作者、页面 URL、下载日期、版本、许可 URL/快照、是否要求署名、是否允许商业使用、是否允许修改、是否允许仓库再分发、是否禁止 AI/NFT、原包 SHA-256。

实际文件建议分为两类：

- `CC0 / 可再分发`：可进入项目仓库，但仍附来源清单，便于日后统一替换。
- `禁止再分发 / 自定义许可`：不直接提交公开仓库；用本地私有目录和 `.gitignore` 管理，并为缺少素材的开发环境提供灰盒 fallback。

即便许可证不强制，建议成品 Credits 仍列出作者和来源。这既尊重作者，也能在后续许可证审计时快速定位素材链路。

## 最终选择

当前阶段优先顺序：

1. **Sunnyside World**：作为第一张基础贴图试装地图。
2. **Kenney Tiny Town + Roguelike/RPG Pack**：补齐通用城镇、室内与 UI 占位。
3. **Ninja Adventure Godot 4 工程**：只学习 TileSet、动画和资源组织，不整体搬入忍者视觉。
4. **Super Retro World - Farming**：先不合并；如需要完整耕作角色与农场全集，再建立私有素材流程后隔离测试。
5. **《牧场物语：矿石镇》原始贴图**：不使用、不提取、不转载，仅作视觉设计参考。
