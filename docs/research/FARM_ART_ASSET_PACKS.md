# 农场生活模拟成熟像素素材包调研

更新日期：2026-08-01

## 调研目标

为 Project X 寻找可以直接在 Godot 4 中试用的成熟像素素材，重点覆盖室外地形、带屋顶和正立面的建筑、室内、动态水面、耕地、作物和动物。目标画面不是严格的等距 3D，而是《牧场物语：矿石镇的伙伴们》常见的“俯视地图 + 可见建筑正面/屋顶 + 物体底部落在地格上”的伪 2.5D 表现。

本次只引用作者自己的商店页、作者发布页和 Creative Commons 官方许可证页。价格与促销会变化；购买前应再次查看作者页面和下载包内的 `LICENSE` 文件。本文是资产筛选记录，不是法律意见。

## 结论先行

### 排名 1：shubibubi Cozy Farm 系列

[Cozy Farm Asset Pack](https://shubibubi.itch.io/cozy-farm) 是当前最稳妥的首轮试用候选。完整版为 16×16，包含四季地形、草地/泥土/干湿耕地、动态水面装饰、桥、围栏、果树、作物、大量成年/幼年动物、动物产品、加工机器、鸡舍、住宅升级、多种镇上建筑，以及与建筑匹配的墙纸和地板；动画以 PNG 和 GIF 提供。完整版最低 US$3.99，允许商业和非商业项目使用及修改，禁止转售或再分发，署名为“建议”而非强制；免费版只能用于非商业项目。[来源与许可证：Cozy Farm 作者页](https://shubibubi.itch.io/cozy-farm)

它的优势不是单个像素画得最精，而是室外、房屋、动物、耕地和室内已经属于同一视觉族；作者还提供同风格的 [Cozy Town](https://shubibubi.itch.io/)、Cozy Interior、Cozy People、Cozy Fishing 与自然扩展。其“可见屋顶 + 正面墙体 + 脚底落格”的表现比当前程序生成素材更接近矿石镇式生活模拟画面。

适配判断：**最适合先购买/下载一小套做 HomeRegion 替换样板**。首轮只试草地、耕地、水、树、住宅、鸡舍和鸡，不导入整包。它仍是第三方资产；若作为正式室外世界基础，必须先修改项目当前“主要室外素材原创”的政策。

### 排名 2：LimeZu 同系列组合

建议先用下列三套的官方预览做一次 480×270、16×16 网格的静态样板图：

1. [Modern Farm](https://limezu.itch.io/modernfarm)：农场、作物、动物和农具动作。
2. [Serene Village Revamped](https://limezu.itch.io/serenevillagerevamped)：自然地形、树、岩石和 24 种房屋。
3. [Modern Interiors](https://limezu.itch.io/moderninteriors)：室内墙地板、家具、厨房和商铺。

三套出自同一作者、都以 16×16 网格为核心，最容易避免“草地、房屋、家具和动物来自不同游戏”的拼贴感。Modern Interiors 明确包含 2D/3D 墙体和模块化墙地板；这正是当前画面欠缺的墙厚、立面和空间层次。Modern Farm 则已经包含谷仓、马厩、围栏、制作设施、19 种作物成长状态、动物与工具动作。[来源：Modern Farm](https://limezu.itch.io/modernfarm)、[Modern Interiors](https://limezu.itch.io/moderninteriors)

适配判断：**最适合作为近期视觉验证基线**。它并非直接复制矿石镇，但“俯视地格 + 高于地面的正面墙体/屋顶 + 角色脚底锚点”比当前程序绘制的平面色块明显更接近目标。

注意：根据当前 `AGENTS.md`，室外地形、主要建筑外观、作物和正式世界地图仍被定义为核心原创资产。把上述素材直接升级成正式室外基础，会改变现有美术政策；在确认前，最稳妥的用途是样板图、结构参考和可替换的临时表现层。室内素材与项目既有白名单方向更一致。

### 排名 3：Pixelwood Valley Premium

[Pixelwood Valley](https://gowldev.itch.io/pixelwood-valley) 是一套 16×16 的完整村庄/农场视觉族，包含动态岸边、水瀑和水面装饰、11 种带成长动画的作物、30+ 村庄房屋、80+ 城镇房屋、3 套室内 TileSet、家具、谷仓、鸡舍，以及牛、羊、鸡的待机/行走/进食/休息/睡眠动画；还有冬季版本。Premium 允许商业和非商业项目使用及修改，不要求署名，但禁止再分发、转售、AI 训练和 NFT 使用。[来源与许可证：Pixelwood Valley 作者页](https://gowldev.itch.io/pixelwood-valley)

适配判断：**单包完整度最高，水面与建筑层次尤其适合解决当前问题**。它比 LimeZu 更偏统一的童话村庄调色，若整套使用，较容易快速获得一致画面。

限制：角色帧页面标注按 59×49 切割，与项目 24×32 角色基线不一致；更适合先使用环境、建筑、水、室内和动物，不宜直接替换正式主角。素材仍在开发中，个别图片的切片尺寸会随资产变化，导入前要建立明确清单。

## 候选对照表

| 素材包 | 费用/许可组 | 网格与视角 | 主要内容 | 与矿石镇式伪 2.5D 的接近度 | 主要风险 |
|---|---|---|---|---|---|
| [shubibubi Cozy Farm](https://shubibubi.itch.io/cozy-farm) | 完整版最低 US$3.99；商业/非商业、可修改；不可转售/分发；署名建议但非强制。免费版仅限非商业 | 16×16，Top-Down | 四季地形、水、干湿耕地、动物与幼崽、作物、加工机器、鸡舍、房屋升级、镇上建筑和匹配室内 | 高；同一包内的建筑、农场和动物最一致 | 正式采用室外部分会改变当前原创政策；角色另售且页面示例角色不包含在本包 |
| [LimeZu Modern Farm](https://limezu.itch.io/modernfarm) | 付费授权；作者页标价基准 US$7.50，促销价会变化；商业/非商业、可修改，不可转售/分发；署名“非常感谢”而非明确强制 | 16×16，Top-Down，Godot 标签 | 谷仓、马厩、围栏、设施、动态道具、果树、19 种作物、图标、工具动作、动物动画、Farmer Generator | 高；物件有正面高度，适合农场主体 | 若整包直接作为正式室外美术，会改变当前原创政策 |
| [LimeZu Serene Village Revamped](https://limezu.itch.io/serenevillagerevamped) | 免费，CC BY 4.0，必须署名 | 16×16，Top-Down | 地形、树、岩石、蘑菇、24 种房屋、动态物件 | 高；建筑和地形可与 Modern 系列衔接 | 农业/动物内容不足，需要与 Modern Farm 或自制素材组合 |
| [LimeZu Modern Interiors](https://limezu.itch.io/moderninteriors) | 完整版最低 US$1.50；商业/非商业、可修改，不可转售/分发；必须署名 | 16×16/32×32/48×48；Top-Down | 数千家具、模块墙地板、2D/3D 墙、100+ 动画物件、厨房和多种商铺 | 高；最能补充墙厚和室内空间感 | 免费版仅限非商业；完整包很大，必须只导入项目实际使用部分 |
| [Pixelwood Valley Premium](https://gowldev.itch.io/pixelwood-valley) | 原价页面为 US$7，促销会变化；商业/非商业、可修改；不要求署名；不可转售/分发/AI 训练/NFT | 16×16 为通用地格；Top-Down | 动态水、作物、四季、30+ 村屋、80+ 城镇房屋、室内、动物、谷仓/鸡舍 | 高；完整村庄场景和水面最突出 | 仍在开发；角色帧为 59×49 切片，不适合直接替换 24×32 主角 |
| [Farm RPG Asset Pack（viinlu games）](https://viinlu-games.itch.io/farm-asset-pack) | US$9.99；商业使用、可修改、不必署名；不可再分发/转售 | 16×16，Tilemap | 页面列出四季地形、土壤/湿土、动态水景、桥、树、围栏；多种房屋及匹配室内 | 页面描述高，但暂不列入采购 shortlist | 页面内容清单与 Cozy Farm 大量重合，且显示下载文件仅 14 kB；在作者确认权利来源与实际内容前不要购买或导入 |
| [Tiny Farm RPG（Maeve）](https://maevedevs.itch.io/farm-rpg) | 完整版当前门槛 US$6.49；商业/非商业、可修改；不可转售/分发/AI 训练；作者给出可选署名方式 | 16×16 环境，32×32 角色，Top-Down | 大量农场动物、宠物、作物、家具、200+ 图标、丰富工具/生活动作 | 中高；内容覆盖极广，适合补动物、室内和图标 | 仍在开发；32×32 角色与 24×32 基线不同，范围太大，整包导入会造成资产管理负担 |
| [Sunnyside World](https://danieldiggle.itch.io/sunnyside) | 自由定价，可免费获取；商业/非商业、可修改、不要求署名；不可改包转售，不可 AI 训练 | 16×16，Top-Down | 建筑、室内、土地、自然、水、围栏、墙、自动地形、11 种五阶段作物、UI | 中；成熟且完整，但整体更接近 Forager 式扁平俯视 | 原角色主要是左右移动，不适合项目四方向角色；作为正式基调仍偏平 |
| [Sprout Lands Premium](https://cupnooble.itch.io/sprout-lands-asset-pack) | Premium 最低 US$3.99；商业/非商业、可修改；不可转售/分发；Premium 不要求署名（作者在评论中澄清） | 作者称 16-bit、Top-Down，资源按 16×16 网格制作 | 草地、水、动物、作物、角色四方向待机/走/跑/耕作/砍伐/浇水 | 中；柔和可爱，但比矿石镇更粉彩、更现代 | 仍标注早期版本；免费 Basic 仅限非商业并要求署名，不能把免费版当商业许可素材 |
| [Pixel Farm Asset Pack（HelloRumin）](https://hellorumin.itch.io/pixel-farm-asset-pack) | 自由定价/可免费；作者自定义许可允许商业使用和修改；不可再分发/转售、不可声称原创 | 16×16 地砖，32×32 角色，Top-Down | 树、草、耕地、池塘、围栏门、牛羊鸡、4 种作物、农具动作 | 中；可快速替换耕地、池塘和动物占位 | 内容小、角色比例不同，更适合补件和对照，不适合作为完整世界基础 |
| [Kettoman Free Pixel Farming Base Pack](https://kettoman.itch.io/pixel-farming-base-pack-animals-crops-tileset) | 自由定价/可免费；商业/非商业、无需署名；禁止原样转售/分发 | 16×16，Top-Down | 3 种动画动物、3 种成长作物、草/土/翻耕/湿土和自然装饰 | 中低；农业状态清楚 | 只是基础包，没有建筑与室内，无法单独解决伪 2.5D 感 |
| [Kenney Roguelike/RPG Pack](https://kenney.nl/assets/roguelike-rpg-pack) | CC0 | 16×16，1700+ 文件 | 城镇、家具、地形、RPG 通用元素 | 低；轮廓清楚但很扁平 | 可做碰撞/TileMap 测试和通用占位，不宜作为目标风格 |

## 免费、CC0 与署名/相同方式共享素材

### 真正清晰的 CC0

- [Kenney Roguelike/RPG Pack](https://kenney.nl/assets/roguelike-rpg-pack)：官方页明确标注 16×16、1700+ 文件、CC0。法律边界干净，但视觉过度简化，建议只用于编辑器测试、UI 辅件或临时碰撞验证。CC0 条款见 [Creative Commons 官方页面](https://creativecommons.org/publicdomain/zero/1.0/)。
- [Kenney Tiny Town](https://kenney.nl/assets/tiny-town)：官方页明确标注 16×16、130+ 文件、CC0；适合世界地图缩略图或原型，不适合作为当前近景农场的主美术。

### 标称 CC0 但不建议直接采用

- [Mini Farm Asset Pack](https://jofra.itch.io/mini-farm) 的作者页一方面写“CC0/Public Domain”，另一方面又禁止以独立文件形式再分发。后者与标准 CC0 的不可撤销放弃权利表述不一致；作者账号还标记为停用、包仍是 WIP。除非作者书面澄清，否则不应把它当作法律边界干净的 CC0 正式资产。

### 需要署名

- [Serene Village Revamped](https://limezu.itch.io/serenevillagerevamped)：CC BY 4.0；可以商用和修改，但必须按许可证署名并标注改动。正式条款见 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)。
- [Modern Interiors 完整版](https://limezu.itch.io/moderninteriors)：作者自定义商业许可，明确要求署名；不是 CC0。
- [Farming Adventure](https://padrosives.itch.io/farming-adventure)：16×16；Premium 有完整自然、食物/成长阶段、道具和建筑，商业使用需要署名 Padrosives，禁止再分发与衍生素材包。风格和内容规模中等，优先级低于同系列更完整的候选。

### CC BY-SA / GPL：可用但不适合当前 16×16 基线

- [LPC Farming Tilesets](https://lpc.opengameart.org/content/lpc-farming-tilesets-magic-animations-and-ui-elements) 与 [LPC Crops](https://opengameart.org/content/lpc-crops) 的视角和体积感较接近传统 2.5D RPG/生活模拟，但 LPC 通常以 32×32 地格为基础，并涉及 CC BY-SA 3.0/4.0 或 GPL 3.0、多作者署名与派生链。
- 若使用 CC BY-SA 路径，修改后的相关美术需要遵守相同方式共享和完整署名要求；不能把“免费”理解为“无条件”。标准条款见 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)。
- 由于 Project X 已锁定 16×16，直接缩小 LPC 会破坏像素密度，混入又会产生明显风格割裂。本项目应把 LPC 作为结构和层次参考，而不是近期运行时素材。

## 对当前问题的针对性建议

### 1. 房屋、树与角色遮挡

成熟素材不会自动解决透明判断。正确结构仍应是：

- 物体底部/树干/门槛所在格：碰撞与脚底排序基准。
- 屋顶、树冠：独立前景 Sprite 或 TileMapLayer，不带整块碰撞。
- 角色只在进入“物体后方遮挡区域”时让前景半透明；角色走到房屋上方但没有被屋顶覆盖时，不应触发透明。

因此筛选素材时，应优先选择能把屋顶、墙体、门、树冠、树干拆分的包。LimeZu 的模块化结构和 Pixelwood 的独立建筑/动态物件都比单张完整背景图更适合。

### 2. 水面

优先试用 Pixelwood Valley 的动态 shoreline/waterfall/water decorations，或 viinlu 的 Water Cliff、气泡和睡莲。Sunnyside 也包含 water + autotiles，但视觉更扁。无论选哪套，池塘碰撞应沿不可通行水域边缘建立多边形或逐格碰撞，不应靠一个比水面小的居中矩形。

### 3. 农田与可选格

农田必须是同一套 TileSet 中的干土/翻耕土/湿土状态，不能再用不同纯色表达逻辑状态。Modern Farm、viinlu、Pixelwood、HelloRumin、Kettoman 都提供可参考的耕地状态。

Godot 中应保留三层：

- `Ground`：原始草地/地图背景。
- `FarmVisual`：干耕地、湿耕地、作物 Sprite。
- `FarmCells`：编辑器可见的 16×16 可耕种区域或自定义数据层；运行时可以隐藏辅助色。

这样编辑时能看着背景刷格子，运行时选择框严格落在同一个 16×16 单元上。

## 建议的零风险试用顺序

1. 不购买、不导入正式项目：先用作者页面预览，比较 LimeZu 组合与 Pixelwood Valley 两张 480×270 样板构图。
2. 选择一个主视觉族，不混用两套地形、房屋和树木。动物/小道具可以后续经过调色和轮廓统一再补入。
3. 仅把候选包放入独立的 `assets/third_party/<author>/<pack>/`；保存原始 `LICENSE`，并在 `asset_manifest.csv` 记录作者、URL、版本、购买凭证、许可、修改内容和使用范围。
4. 首轮只导入：一套草地/道路/水、干湿耕地、一棵树、一栋房屋、一个室内和一只鸡。完成遮挡、碰撞、TileMap 编辑和视觉截图后，再决定是否扩展整包。
5. 如果要把第三方室外素材从“临时表现”升级为正式世界基础，先更新 `AGENTS.md` 的 Art Policy；这是方向改变，不是普通素材替换。

## 采购建议

- **若只选一个完整包试画面：shubibubi Cozy Farm 完整版。** 16×16、四季、水、耕地、动物、建筑和配套室内都在同一包里，授权与内容边界清楚，最适合做 HomeRegion 的小范围替换样板。
- **若希望以后扩展商店、餐厅与大量室内：LimeZu Modern Farm + Modern Interiors + Serene Village Revamped。** 内容生态更大，Godot/16×16 适配明确，空间层次也最强。
- **若最重视动态水面和大量村镇房屋：Pixelwood Valley Premium。** 水、村庄、室内、作物、动物属于同一视觉族，但它仍在开发，角色切片也不符合当前基线。
- **若暂时不花钱：Sunnyside World + Serene Village Revamped。** 能做可读原型，但必须接受前者偏平、两者调色与轮廓不完全一致；不要把它们混成正式风格。
- **不建议**为了“完全免费”而大规模混用多个 CC0 小包。它们能消除色块，却不会自动形成矿石镇式统一画风，后期统一轮廓、光源和色板的成本可能高于购买一个成熟系列。

## 项目最终决定：不采购付费素材

Project X 当前为个人游玩项目，不考虑购买素材包。执行路线调整为：

1. 室外基础优先测试免费的 [Serene Village Revamped](https://limezu.itch.io/serenevillagerevamped)；保留其 CC BY 4.0 署名与修改记录。
2. 农业和动物缺口可使用 [Cozy Farm](https://shubibubi.itch.io/cozy-farm) 免费非商业版中的鸡、番茄、土豆和少量建筑素材。
3. Kenney CC0 只补充调试或暂时缺失的通用物件，不作为目标画风。
4. 不同时引入更多素材族；新素材必须先在一张 480×270 家园样板图中验证比例、调色板和遮挡。
5. 功能与地图稳定后，按“地形与水面 → 建筑 → 作物与动物 → 室内与 UI”的顺序逐批替换为自制素材。

这些素材均为开发期可替换表现层，不能进入领域数据、存档格式或地图稳定 ID。
