# Project X：Godot UI、像素美术与游戏制作工具筛选

**检索日期：** 2026-08-02  
**项目基线：** Godot 4.7.1、480×270、16×16 瓦片、32×32 人物画布、Nearest、Super Retro World - Farming 开发期统一画风。

## 筛选标准

1. 能服务农场生活模拟，而不是只适合 RPG、平台跳跃或 3D 项目。
2. 能保留 16×16 / 32×32 像素规格、有限调色板和稳定的重复生产流程。
3. 许可证和生成资产的使用边界清楚，适合个人开发和未来商业化评估。
4. 能与 Godot 4.7 的编辑器优先流程共存：正式地图、UI 布局、碰撞、交互点和策划参数仍保存为场景/资源。
5. GitHub Star 只作为可信度参考，不作为小众工具的绝对淘汰线；活跃度、输出质量和项目匹配度更重要。

## 建议采用

### 1. Pixelorama：正式像素美术制作工具

- [GitHub：Orama-Interactive/Pixelorama](https://github.com/Orama-Interactive/Pixelorama)
- GitHub 页面检索时显示约 10.0k stars，MIT License。
- 支持精灵、瓦片、动画、图层、调色板和导出，适合作为 Project X 的外部源图制作工具。
- 它不是运行时插件，也不会替代 Godot 场景编辑；导出的 PNG/图集经过人工整理后再导入 Godot。
- 适用范围：玩家/居民动作、作物阶段、动物、料理图标、UI 图标、建筑细节和 16×16 地形补充。

**决定：采用为主要像素美术工具，但不把 Pixelorama 的代码或界面嵌入游戏。**

### 2. GD-Agentic-Skills：只安装精确的 Godot Skills

- [GitHub：thedivergentai/GD-Agentic-Skills](https://github.com/thedivergentai/GD-Agentic-Skills)
- GitHub 页面检索时显示约 445 stars、LGPL-3.0；仓库面向 Godot 4.7+，包含 97 个 Skills 和 27 个类型蓝图。
- 直接适合当前项目的模块：
  - [`godot-ui-theming`](https://github.com/thedivergentai/GD-Agentic-Skills/tree/main/skills/godot-ui-theming)：Theme、StyleBoxFlat、像素 UI 缩放、焦点状态和共享主题资源。
  - [`godot-ui-containers`](https://github.com/thedivergentai/GD-Agentic-Skills/tree/main/skills/godot-ui-containers)：HBox/VBox/Grid/Margin/Split 等布局，解决设置页、背包和料理面板拥挤问题。
  - [`godot-input-handling`](https://github.com/thedivergentai/GD-Agentic-Skills/tree/main/skills/godot-input-handling)：InputMap、键鼠/手柄、设置重绑定和 UI 输入隔离。
  - 后续需要时再调用 `godot-resource-data-patterns`、`godot-signal-architecture` 和 `godot-tilemap`。

**决定：采用“按需加载”，不安装或使用 `godot-master` 全量模式。Skills 中的运行时脚本只作为参考；正式 UI、地图和布局仍以 Godot 场景/资源为源。**

## 建议试用

### 3. Texel Studio：AI 辅助像素资产草稿工具

- [GitHub：EYamanS/texel-studio](https://github.com/EYamanS/texel-studio)
- GitHub 页面检索时显示约 149 stars、22 forks、33 commits，当前仓库未归档。
- 不是扩散模型缩图，而是使用像素、形状、噪声和调色板工具逐步绘制；支持手工修整、16 变体 autotile 导出和本地 Ollama/OpenAI/Gemini 等提供方。
- LICENSE 允许自托管、修改、商业使用和使用生成资产；如果再分发软件或衍生版本，需要保留原仓库链接；不得作为竞品 SaaS 对外托管。
- 风险：项目较新，输出仍必须逐张检查轮廓、调色板、重复纹理和与 Super Retro 基线的相容性；不能直接把 AI 输出视为正式美术。

**决定：先做小规模试验，不安装进 Godot，不让它生成正式地图或正式 UI。第一批只试 16×16 草地/土壤/石头瓦片和 32×32 料理图标，并人工逐像素复核。**

### 4. Godot AI：只作为可选的检查/辅助工具

- [GitHub：hi-godot/godot-ai](https://github.com/hi-godot/godot-ai)
- GitHub 页面检索时显示约 1.4k stars、MIT License；面向 Godot 4.5+，当前 README 推荐 4.7+。
- 能检查和操作场景、脚本、UI、材质、动画，并运行测试；因此可能帮助做场景查询和视觉 QA。
- 风险是它具备较强的 MCP 写入能力，容易把“可视化优先”误变成代码批量生成场景。

**决定：暂不安装。若后续试用，只允许用于读取、检查、运行测试和截图；禁止用它生成正式地图、UI 布局、碰撞、交互点或把运行时生成结果当作源文件。**

## 明确不采用

### 5. Godot MCP Full Control

- [GitHub：tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp)
- GitHub 页面检索时显示约 382 stars、MIT License、157 个 Godot 控制工具。
- 功能很强，包含文件写入、节点/场景创建、UI 操作、运行时代码、截图和输入模拟。
- 与本项目“Godot 能编辑的内容必须由场景/资源保存”的正式制作边界冲突太大；当前也没有必要引入另一套全引擎控制层。

**决定：不采用。**

### 6. SpriteBrew / PixelMaker Godot Plugin

- [SpriteBrew](https://github.com/GAlbanese09/spritebrew)：约 36 stars，AGPL-3.0，偏网页 AI 精灵生成和 SpriteFrames 导出。
- [PixelMaker Godot Plugin](https://github.com/kbraiden/pixelmaker-godot-plugin)：约 2 stars，MIT，但依赖 Python/OpenAI API，维护和可复现性不足。

两者都不能超过 Texel Studio 或 Pixelorama，不能直接进入正式资源；但 PixelMaker 的 16/32px 图片转像素和动画功能可以在项目副本中做一次低成本验证。

**决定：不作为 Project X 主工具或正式插件。PixelMaker 只允许在项目副本中有限试验 `From Image` 和 `Animate`；SpriteBrew 只允许手工试用切片和预览，不接入正式生产链。**

## UI 素材结论

目前没有发现一套可以直接覆盖 Project X、同时保持 Super Retro Farming 画风的高质量开源 UI 包。已有的 [Kenney Pixel UI Pack](https://opengameart.org/content/pixel-ui-pack-750-assets) 是 CC0 且资源量大，但色彩和按钮风格偏通用彩色复古，与当前深色自然像素 UI 不完全匹配。

**正式方案：**继续使用 `home_region.tscn` 中可编辑的 Godot Theme/StyleBoxFlat；需要补充时只挑单个 CC0 图标、光标或九宫格素材，并在独立预览场景确认后再导入。不要把多个 UI 包拼成一套。

## Kenney 官网补充筛选

Kenney 官网的免费资源量很大，但不能因为都是 CC0 就直接混入当前画面。按 Project X 的 16×16 基线筛选如下：

| 官方资源 | 许可证/规格 | 决策 |
|---|---|---|
| [Pixel UI Pack](https://kenney.nl/assets/pixel-ui-pack) | CC0；750 个 2D UI 文件 | 作为 UI 单件补充和独立预览，不替换当前原生 Theme |
| [Pattern Pack Pixel](https://kenney.nl/assets/pattern-pack-pixel) | CC0；16×16；60 个纹理/VFX | 可试验少量纹理或效果，不进入基础地面 |
| [Pixel Pack](https://kenney.nl/assets/pixel-pack) | CC0；98 个 2D 文件 | 可作像素画参考和小道具补位，风格需逐项检查 |
| [Pixel Platformer Farm Expansion](https://kenney.nl/assets/pixel-platformer-farm-expansion) | CC0；18×18；110 个农场像素文件 | 不直接用于当前地图；可作农场构图参考或重绘参考 |
| [Animal Pack Remastered](https://kenney.nl/assets/animal-pack-remastered) | CC0；240 个 2D 动物文件 | 不直接替换现有动物，先做风格和比例预览 |
| [Food Kit](https://kenney.nl/assets/food-kit) | CC0；3D | 排除，和当前 2D 像素管线不匹配 |

这些候选均保持在项目外素材库；正式场景只接收经过风格、尺寸、切帧和碰撞检查的独立导出文件。

## 最终工具链

```text
Pixelorama                 原创像素源图、动画、瓦片、图标
        ↓ 人工整理/切帧/校验
Godot 4.7 编辑器           正式场景、TileMapLayer、UI 布局、碰撞、交互与资源
        ↑ 按需参考
GD-Agentic-Skills          UI 主题、容器布局、输入和资源架构规范
        ↓ 受控试验
Texel Studio               AI 像素草稿和 autotile 候选，不作为正式源文件
```

## 下一步

1. 不改变当前 Phase 2 代码和正式场景。
2. 先用 Pixelorama 或现有 Godot 工具完成一个 16×16 草地/土壤/石头小图集，确认与 Super Retro 基线的色彩密度一致。
3. 再单独试用 Texel Studio 生成同一组瓦片，比较人工修整成本；若不能减少整理工作，就不纳入流程。
4. 继续复核料理笔记和存档菜单的统一主题，不混入新的整套 UI 包。

## 工具安装状态

- `C:\Users\Aschere\.codex\skills\godot-ui-theming`：已安装。
- `C:\Users\Aschere\.codex\skills\godot-ui-containers`：已安装。
- `C:\Users\Aschere\.codex\skills\godot-input-handling`：已安装。
- `D:\Archer\Tools\Pixelorama\Pixelorama-Windows-64bit\Pixelorama.exe`：已安装并成功启动 v1.1.10-stable。
- Texel Studio：保留为后续独立试验，不向 Project X 安装服务端依赖。
