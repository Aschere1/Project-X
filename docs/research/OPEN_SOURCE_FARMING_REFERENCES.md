# 开源农场与生活模拟参考库

更新日期：2026-08-01

## 结论

《星露谷物语》游戏本体不是开源项目。官方模组文档说明，游戏代码以编译后的 `StardewValley.dll` 交付，模组作者看到的是反编译得到的近似代码，而不是作者发布、附带开源许可证的源代码。因此，GitHub 上的反编译副本只能作为私下研究线索，不能当成可复制的开源代码库。

- 官方模组说明：[Stardew Valley Modder Guide](https://stardewvalleywiki.com/Modding%3AModder_Guide)
- 官方权利声明：[Stardew Valley Forums Terms of Use](https://forums.stardewvalley.net/help/terms/)

与《星露谷物语》有关、但真正开源的是外围工具和底层框架：

- [SMAPI](https://github.com/Pathoschild/SMAPI)：开源模组框架，LGPL-3.0。适合研究事件 API、内容包、错误隔离、存档备份和版本兼容；它不是游戏源码。
- [MonoGame](https://github.com/MonoGame/MonoGame)：开源游戏框架，主要采用 Microsoft Public License；《星露谷物语》使用过该技术栈，但框架源码不包含游戏的农业、NPC、剧情或经济代码。

## 推荐参考矩阵

| 项目 | 技术与许可 | 值得学习 | 使用边界 |
|---|---|---|---|
| [Seasons Gone](https://github.com/elliotfontaine/untitled-farming-sim) | Godot 4，MIT | `crops/animals/resources/world/ui` 的模块拆分；作物轮作、氮循环、数据资源 | 最接近当前技术栈，优先阅读；素材仍需逐项确认，不能因代码 MIT 就默认全部图片可用 |
| [2D Farming Game](https://github.com/gadget-hq/2d-farming-game) | Godot，MIT | 小型农田闭环、Godot 场景组织、教程式实现顺序 | 规模较小，适合核对基础实现，不应替换我们已经通过测试的领域层 |
| [Harvest Moon 2.0](https://github.com/Kenny-Haworth/Harvest-Moon-2.0) | 旧版 Godot，MIT | 种植、商店、时间、天气、体力、背包、睡眠与存档组成的完整垂直切片 | Godot API 和架构较旧；研究流程和系统边界，不直接移植脚本或美术 |
| [Farmhand](https://github.com/jeremyckahn/farmhand) | Web 技术，GPL-2.0；美术 CC BY-NC-SA 4.0 | 动态农产品价格、贷款、每日市场、长期经营反馈和自动化测试 | 动态经济很有价值；直接复制 GPL 代码会带来源码开放义务，美术含 NC，不能作为未来商业版素材 |
| [GLoot](https://github.com/peter-kish/gloot) | Godot 插件，MIT | 背包序列化、堆叠、约束和存档接口 | 只作为库存接口对照；当前背包已稳定，不为使用插件而重写 |
| [Godot Demo Projects](https://github.com/godotengine/godot-demo-projects) | Godot 官方示例，MIT | 当前 Godot 版本的场景、输入、导航、GUI 和存档基础写法 | 它不是农场游戏，但比旧教程更适合校验引擎 API |

## 对 Project X 的采用策略

我们不整体 Fork 某个“星露谷克隆”，而采用分层借鉴：

1. **Godot 结构层**：优先对照 Seasons Gone 与 Godot 官方示例，检查 Resource、场景组合、TileMapLayer 和 UI 组织。
2. **生活闭环层**：用 Harvest Moon 2.0 对照“时间—体力—工作—睡眠—存档”是否缺环，但保留当前原创领域模型。
3. **经营经济层**：后期开店与动态市场阶段，研究 Farmhand 的每日价格、债务、供需反馈和测试方法，只移植设计思想并重新实现。
4. **可扩展性层**：借鉴 SMAPI 的事件、内容包、错误隔离和存档备份思想，为未来作物、料理、NPC 与世界事件预留稳定接口。
5. **资产层**：代码许可证与美术许可证分开登记。没有独立 LICENSE 或来源页的图片、音乐、字体，一律不进入正式素材库。

每次采用开源实现前，记录：项目与固定提交、被研究的模块、许可证、是否复制代码、需要保留的版权声明、素材的独立许可证。默认优先 MIT/CC0；GPL 代码以阅读和重新实现为主；无许可证仓库只看思路，不复制文件。

## 当前行动建议

先不要把这些仓库直接合并进项目。下一次开发具体模块时，再做一次针对性比较：例如开始动态经济前只阅读 Farmhand 的价格模型，开始 NPC 日程前再寻找有明确许可证的日程实现。这样既站在前人的肩膀上，也不会把多个项目的技术债、旧版 API 和许可证义务一起带进来。
