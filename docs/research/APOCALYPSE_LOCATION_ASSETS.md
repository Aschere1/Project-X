# 灾变地点可复用素材候选

更新时间：2026-08-02

本清单只记录适合“地点插图 / 搜索界面局部环境”的候选。当前采用两层美术策略：家园 2D 地图继续以 Super Retro World - Farming 为基线；外出地点不要求完全同风格，优先适配丧尸末日/荒野求生背景、地点叙事和搜刮可读性。所有候选仍通过 Godot 场景的 `LocationIllustration` 槽位接入。

## 当前优先候选

### 1. Pixel Hospital Tileset – Modern Medical Pixel Art

- 来源：[itch.io 页面](https://jackburton84.itch.io/pixel-hospital-tileset-modern-medical-pixel-art-32x32)
- 适用：村卫生室的药柜、诊室、病床、医疗器械、接待台等局部环境。
- 规格：32×32 PNG，页面明确写明可用于商业和非商业项目，可修改和组合，但不得把素材包原样再分发。
- 优点：与当前第一个固定地点“县郊·村卫生室”直接匹配，且是免费 / 自愿付费下载。
- 限制：不是家园 Super Retro 的 16×16 基线；这不是缺点，正好适合作为外部地点的医疗环境插图来源，但不直接混入家园 TileMap。

### 2. Kenney RPG Urban Pack

- 来源：[Kenney 官方页面](https://www.kenney.nl/assets/rpg-urban-pack)
- 适用：县道、街角、路灯、路牌、箱子、城市边缘和可搜索容器的补充。
- 规格：16×16，页面列出 480 个文件，许可为 CC0。
- 优点：许可最清晰，能直接放入项目；16×16 更容易与当前像素网格对齐。
- 限制：它是通用 RPG 城市素材，不是末日专用；可以通过破损、锈蚀、遮挡和地点文字叙事转为外出搜刮环境，不直接混入家园 TileMap。

### 3. Soppycraft Hospital Top-Down Pixel Pack

- 来源：[itch.io 页面](https://soppycraft.itch.io/top-down-hospital)
- 适用：医院/卫生室的整间室内、接待区、病房、手术室、实验室、产房。
- 规格：页面提供 5 类房间，PNG；免费 / 自愿付费，页面明确允许商业项目、修改和组合。
- 优点：比单张医院立面更接近“搜索地点”的完整背景。
- 限制：目前页面评分样本较少；需要在 Godot 中做一次地点插图审查，重点看末日氛围、热点辨识度和 UI 对比度，不再以是否接近 Super Retro 作为淘汰标准。

## 备选与不作为首选

- [Godot Asset Store · Free 2D Topdown Shooter Pack](https://store.godotengine.org/asset/twodpixx/free-2d-topdown-shooter-pack/)：Godot 资源库内可直接添加的 2D 像素素材，页面说明为末日/俯视射击主题，包含 PNG 图块；许可为 CC BY 4.0，需要署名。它不是完整卫生室背景，但可以直接拼成废弃道路、建筑和容器的地点贴图。
- [Godot Asset Store · Admurins Freebies](https://store.godotengine.org/asset/admurin/admurins-freebies/)：Apache 2.0，含许多通用图标、背景和图块，评价较多；题材混杂，不作为卫生室主背景，但可作为临时 UI/物资图标候选。
- [OpenGameArt Pastoral Overworld](https://opengameart.org/content/pastoral-overworld)：CC0、乡村环境方向合适，但为 32×32、DawnBringer db32 调色，适合作为荒野远景参考或临时背景，不作为当前卫生室插图首选。
- [GameBoy-styled Commercial Buildings](https://chuckiecatt.itch.io/gameboy-styled-commercial-buildings)：包含医院、警察局、车库等建筑，免费且可修改，但需署名，且更偏 Game Boy 低色数风格。
- [DithArt's Post-Apocalyptic Tileset](https://dithart.itch.io/ditharts-post-apocalyptic-tileset)：内容最贴近末日道路和建筑，32×32、允许商业游戏使用，但需要付费；只有在免费候选无法满足地点表现时再考虑。
- [Wasteland Essentials RPG](https://cat-cap.itch.io/wasteland)：16×16，免费版只允许非商业使用；付费版才允许商业项目。适合风格参考和个人原型，不直接进入正式可分发版本。
- [Top Down Exterior Post-Apocalyptic Tileset](https://vinchy007.itch.io/top-down-apocaliptic-tileset)：明确允许个人和商业使用但要求署名；可以作为荒废道路/建筑候选，接入前仍需在下载包内复核完整许可文本。

## 当前接入结论

本地项目目前已有 Kenney Tiny Town、Puny World、LimeZu Serene Village 和 Super Retro 私有资源，但没有发现一张可以直接表达“赣南县郊卫生室 + 末日荒废感”的完整背景图。由于本功能只需要 TextureRect 贴图，不需要碰撞和像素级拼接，接入门槛已经很低；仍建议先以一张地点插图验证：

1. 优先试 `Pixel Hospital Tileset` 或 `Soppycraft Hospital`，只做一张县郊卫生室静态插图；不要求它看起来像 Super Retro，只要求医疗地点和末日氛围成立。
2. 在 Godot Asset Library 试 `Free 2D Topdown Shooter Pack`，补充末日道路、建筑和容器形状；单独保留署名信息。
3. 以 `Kenney RPG Urban Pack` 补充道路、箱子、路牌和救护车周边的可读形状；它不进入家园正式 TileMap。
4. 若免费候选显得过于干净，优先评估 `DithArt's Post-Apocalyptic Tileset`；购买前先只用预览图做构图验证。
5. 生成或下载的图像放到 `assets/art/apocalypse/locations/`，在 Godot 场景 Inspector 中拖入 `LocationIllustration`，不在脚本里硬编码路径。
6. 记录最终实际采用的文件、原始页面、许可和是否改色；未经审查的候选仍留在本清单，不进入正式场景。

## 许可边界

- “可用于商业游戏”不等于可以把原始 PNG 单独重新打包发布；项目只发布嵌入游戏后的成品内容。
- CC0 候选仍保留来源记录，便于后续制作 credits 和替换资源。
- CC BY 候选必须在项目 credits 中署名并保留来源链接。
- 含 AI 辅助声明、许可描述模糊或只看到预览图而没有明确使用条款的包，不作为当前正式运行素材。
