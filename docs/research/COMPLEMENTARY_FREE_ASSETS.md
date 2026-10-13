# Project X 免费互补素材筛选报告

## 结论

`Super Retro World - Farming` 继续作为开发期唯一环境画风基线。新增素材只用于补齐当前缺口，不引入第二套草地、道路、水岸、树木、房屋外景或完整地图系统。

当前最稳妥的组合是：

- 动物：优先 `growmaster Pixel Farm Animals Pack`，小尺寸备选 `Kettoman Free Pixel Farming Base Pack`。
- 食材和料理图标：`Hayaya Farm Products` 加两套 OpenGameArt CC0 食物图标。
- 普通住宅和家用厨房：`Bitglow Pixel Interior Living Room & Kitchen`。
- 餐厅后厨：`0_mem0ry Professional Kitchen Set`，先做缩放与调色样板再决定正式接入。
- UI：`Kenney Pixel UI Pack`，只作为可替换的功能界面基础。
- 钓鱼动作和恋爱角色头像：仍以原创为主，免费素材只用于临时占位或构图参考。

## 使用分级

### A级：可以直接进入原型

这些素材的许可和技术规格适合直接用于当前功能开发，但导入前仍要登记来源、许可证和是否修改。

| 素材 | 已核实内容 | 许可与限制 | 建议用途 | 来源 |
|---|---|---|---|---|
| growmaster Pixel Farm Animals Pack | 32×32；鸡三种颜色、雏鸡、猪、牛；包含待机以及向上、向下、向右行走动画，向左可通过水平翻转得到 | 可免费商用 | 当前动物系统的首选补充；尺寸与项目的32×32角色画布更接近 | [作者页面](https://growmasterart.itch.io/pixel-farm-animals-pack-passive-npcs-32x32-animated-chicken-pig-cow-chick) |
| Hayaya Farm Products | 32个16×16图标；含蔬菜、水果、蘑菇、鸡蛋、牛奶、奶酪等农产品 | 可免费商用、允许修改 | 背包、商店、食材与动物产品图标 | [作者页面](https://hayaya.itch.io/farm-products-asset-16x16) |
| OGA 16x16 Food | 188个食物图标 | CC0 | 料理结果、餐厅菜单和料理笔记的临时图标库 | [OpenGameArt页面](https://opengameart.org/content/16x16-food) |
| OGA 16x16px Food Items | 16×16食物图标 | CC0 | 补充原料、零食和料理小图标 | [OpenGameArt页面](https://opengameart.org/content/16x16px-food-items) |
| Bitglow Pixel Interior Living Room & Kitchen | 16×16室内素材，覆盖客厅与家用厨房 | 可免费商用；不可将素材本体重新分发 | 玩家住宅、普通居民住宅、家用厨房的开发期表现 | [作者页面](https://bitglow.itch.io/pixelinterior-livingroomkitchen) |
| Kenney Pixel UI Pack | 约750个UI文件 | CC0 | 设置、背包、存档选择、按钮和窗口的可替换原型UI | [Kenney官方页面](https://www.kenney.nl/assets/pixel-ui-pack) |

### B级：需要调色、缩放或先做样板

这些素材可以补功能，但不能直接整包混入正式场景。必须先在480×270、Nearest过滤和整数缩放下制作独立对比样板。

| 素材 | 已核实内容 | 主要问题 | 建议处理 | 来源 |
|---|---|---|---|---|
| Kettoman Free Pixel Farming Base Pack | 16×16；3种动画动物、3种成长作物以及基础草地、土地与耕地 | 动物尺寸偏小；自带地形会形成第二套环境视觉 | 只提取缺失动物或动作作为备选；不用它的地形替换当前环境 | [作者页面](https://kettoman.itch.io/pixel-farming-base-pack-animals-crops-tileset) |
| 0_mem0ry Professional Kitchen Set | 标称32×32，但物件按16×16网格对齐；覆盖商业厨房设备 | 像素密度和色彩可能比当前室内更重；许可禁止再分发和AI用途 | 先做一个餐厅后厨样板，统一阴影、木色、金属色与缩放后再接入 | [作者页面](https://0-mem0ry.itch.io/professional-kitchen-set-free) |
| OGA Pixel Animals 16x16 | 16×16静态牛、羊等动物 | 没有完整四方向动画，视觉体量偏小 | 用于幼崽、远景或系统占位；正式成体需要补帧和统一比例 | [OpenGameArt页面](https://opengameart.org/content/pixel-animals-16x16) |
| Pixel Gnome Fishing Sample | 免费样本含12个16×16钓鱼图标 | 只是小型样本，无法覆盖玩家甩竿、收线、鱼影和水面反馈；具体使用仍应复核下载包条款 | 仅补临时鱼类/钓具图标；导入前保存许可证原文 | [作者页面](https://pixelgnome.itch.io/fish) |

### C级：只作参考或临时占位

| 素材 | 已核实内容 | 不作为正式基础的原因 | 来源 |
|---|---|---|---|
| Tiny Realm Free | 16×16；免费版含动画鸡、羊与部分牧场物件 | 免费版本仅限非商业使用；项目未来仍保留可发布可能，不能让它成为难以替换的正式依赖 | [作者页面](https://wrabitart.itch.io/tiny-realm-asset-pack) |
| EverFace | 18张头像 | 虽为CC0，但数量有限，也不能承担原创居民身份、恋爱表情和婚后事件的长期需求 | [OpenGameArt页面](https://opengameart.org/content/everface) |

## 与当前素材基线的互补关系

| 当前缺口 | 建议来源 | 接入结论 |
|---|---|---|
| 鸡、雏鸡、猪、牛 | growmaster首选；Kettoman备选 | 先替换或补充动物精灵，不改动物领域逻辑和存档ID |
| 羊及临时幼崽 | OGA Pixel Animals或Tiny Realm参考 | 静态占位可以，正式版需要原创动画 |
| 农产品和基础食材图标 | Hayaya | 可直接做物品图标适配层 |
| 大量料理结果图标 | OGA两套CC0食物图标 | 先建立临时料理图标映射，招牌料理和黑暗料理以后原创 |
| 住宅、客厅、家庭厨房 | Bitglow | 只补室内；不拿来替换当前户外环境 |
| 餐厅商业后厨 | 0_mem0ry | 先调色和像素密度验证，再用于Phase 4/Phase 6 |
| 背包、设置、存档和交易UI | Kenney | 适合功能阶段，后续按Project X美术圣经原创替换 |
| 钓鱼图标 | Pixel Gnome样本 | 仅补小图标，玩家钓鱼动作和水面反馈继续原创 |
| 恋爱头像 | EverFace临时参考 | 正式居民、候选对象及表情组必须原创 |

## 明确不做的事情

- 不导入Kettoman或Tiny Realm整套环境地形，不让家园出现第二套草地、水岸、道路和房屋风格。
- 不因为免费就一次性把所有素材复制进项目，只导入当前模块实际使用的文件。
- 不把仅限非商业的Tiny Realm素材放进未来可能发布的正式资产链。
- 不将禁止再分发的素材包、原始压缩包或完整图集提交到公开仓库。
- 不使用0_mem0ry素材进行AI训练、AI再生成或上传到生成式工具。
- 不把临时头像当成最终居民身份，也不让临时图标进入存档格式；存档始终引用稳定物品ID和角色ID。

## 推荐接入顺序

1. **动物样板**：从growmaster选择鸡和牛各一套，在独立预览场景验证尺寸、朝向、帧速和地面接触点。
2. **图标样板**：从Hayaya选择鸡蛋、牛奶和一种蔬菜；从OGA选择三种料理，检查背包中16×16与UI放大效果。
3. **家庭厨房样板**：使用Bitglow拼一个最小厨房，验证玩家能否在桌台后方正确遮挡，以及碰撞是否只覆盖家具底部。
4. **餐厅后厨样板**：单独测试0_mem0ry，不与正式家园地图直接混合；通过调色评审后再进入料理或开店阶段。
5. **UI样板**：使用Kenney建立设置和背包界面，保留统一主题资源，避免每个界面单独改色。
6. **登记与隔离**：每项素材保留来源页、许可证文本、下载日期、原始哈希和修改记录；第三方素材与原创素材分目录保存。

## 最终判断

这批免费素材足以补齐近期的动物、食材、料理、室内厨房和基础UI，因此没有必要再寻找另一套完整农场环境包。它们应该作为`Super Retro World - Farming`表现层的局部补件：先逐项做样板、统一调色和比例，再按模块少量导入。

仍未真正解决的两类核心美术是：

1. 玩家完整钓鱼动作、鱼影、水面反馈和钓鱼小游戏表现。
2. 原创居民头像、恋爱候选表情、事件服装与婚后状态。

这两类内容直接承载Project X的角色身份和体验特色，应继续以原创为主，而不是继续堆叠免费素材包。
