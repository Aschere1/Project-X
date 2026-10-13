# 农田土壤视觉状态参考

研究日期：2026-08-02  
范围：只研究《星露谷物语》和《牧场物语／Story of Seasons》官方或开发者发布画面中的通用视觉规则；不复制其贴图、像素、配色或地图。

## 结论

农田至少需要三种清晰状态，而且它们必须共享同一个格子坐标和轮廓：

1. **未耕地**：显示地图原本的草地或裸地，不叠加耕地贴图。
2. **干燥耕地**：锄地后切换为干燥、较亮的翻土贴图。
3. **湿润耕地**：浇水后把同一格的干燥耕地替换为更暗、饱和度略低或带少量湿润高光的土壤贴图；不是在土上叠一格蓝色水面。
4. **作物**：种子、幼苗和成熟作物是独立透明层，始终叠在干燥或湿润耕地之上，不能替代土壤层。

可直接表达为：

```text
未耕地       = 基础地图地表
干燥空耕地   = 干燥耕地
湿润空耕地   = 湿润耕地
干燥已种植   = 干燥耕地 + 作物
湿润已种植   = 湿润耕地 + 作物
```

## 一手来源与观察

### 《星露谷物语》

- [ConcernedApe 发布的 Steam 商店页](https://store.steampowered.com/app/413150/Stardew_Valley/)及其[官方商店农场截图](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/413150/ss_b887651a93b0525739049eb4194f633de2df75be.1920x1080.jpg)显示：农田与草地／裸地是不同表面；作物和洒水器严格落在同一规则网格中；连续耕地可以形成大块田，但作物中心仍逐格对齐。
- [Stardew Valley Wiki：Crops](https://wiki.stardewvalley.net/Crops)明确区分未耕地与已耕地：未耕地必须先用锄头处理，之后才可种植和浇水；浇水可以发生在播种前或播种后。这说明“土壤状态”和“作物状态”是两个可组合的层，而不是一张合并贴图。
- [Stardew Valley Wiki：Fertilizer 的 Appearance 表](https://wiki.stardewvalley.net/Fertilizer#Appearance)为每一种施肥土壤分别列出 **Unwatered** 和 **Watered** 外观。代表性资源 [Basic Fertilizer 干燥版](https://wiki.stardewvalley.net/mediawiki/images/a/ab/Stardew-texture_Basic-Fertilizer.png)与[湿润版](https://wiki.stardewvalley.net/mediawiki/images/9/92/Stardew-texture_Basic-Fertilizer-w.png)保持同一尺寸、轮廓和细节位置，只让湿润版整体更暗。本次对这对官方 Wiki 图进行像素均值检查，平均亮度约由 123.9 降到 104.8，约降低 15%；该数值只证明“湿土明显变暗”的方向，**不应照抄为 Project X 的固定色值**。

这里的 Wiki 位于游戏官方 Wiki 域名，但内容可由社区编辑。因此它适合用来确认状态结构，并由 ConcernedApe 发布的商店画面交叉确认网格和叠层，不把 Wiki 单独当作美术授权来源。

### 《牧场物语／Story of Seasons》

- Marvelous/XSEED 的[官方 Growing Crops 教程](https://www.storyofseasons.com/sos/farm5.html)把流程明确拆成清地、耕地、播种、浇水和收获。
- 官方[耕地步骤截图](https://www.storyofseasons.com/sos/img/ss-farm5B.jpg)显示：耕完的田块拥有固定的 3×3 格位和固定外边缘；周围未耕地仍保持原本地表。
- 官方[播种步骤截图](https://www.storyofseasons.com/sos/img/ss-farm5C.jpg)显示：种子落在九个格位各自的中心，下面的耕地轮廓仍然可见。
- 官方[浇水步骤截图](https://www.storyofseasons.com/sos/img/ss-farm5D.jpg)显示：浇水后的格子颜色明显更深，但格子中心、圆形翻土细节、3×3 外边缘和相邻间距都没有移动；种子继续叠在湿土上。
- 较新的 [STORY OF SEASONS: Grand Bazaar 官方 Web Manual](https://www.storyofseasons.com/grandbazaar/manuals/xbox/01/)同样把 **Tilling Soil、Sowing Seeds、Watering Crops** 作为连续但独立的状态和动作，说明这不是某一代偶然的画法。

《Story of Seasons》示例采用 3×3 田块是该作的具体设计，Project X 不需要照搬。应继承的是“固定格位、固定边缘、湿度只改变土壤外观、作物单独叠层”的规则。

## 对 Project X 的可执行规则

### 1. 资源职责

每个可耕格至少需要以下可在 Godot Inspector 中查看和替换的资源：

- `base_ground`：地图原本地表；未耕时只显示它。
- `tilled_dry`：干燥翻土贴图。
- `tilled_wet`：与 `tilled_dry` 尺寸、原点、边界完全相同的湿土贴图，整体更暗但仍然读作“土”。
- `crop_stage`：带透明背景的种子／幼苗／成长／成熟作物图，独立于土壤湿度。

禁止把池塘、水波或蓝色水面 Prop 用作 `tilled_wet`。若 Super Retro World - Farming 包已有成套干土／湿土，直接使用正确成套资源；若没有，只有在许可证允许修改时才可制作同轮廓的湿润变体，否则应绘制原创湿土。

### 2. 状态与叠层

从下到上的显示顺序固定为：

1. 地图基础地表；
2. 仅在已耕状态显示的干土或湿土；
3. 肥料／种子等贴地细节（若有）；
4. 作物生长阶段；
5. 临时工具特效、选中框和水花动画。

浇水瞬间可以播放短暂水花，但动画结束后只保留湿土，不能留下蓝色水面层。

### 3. 网格与边缘

- Project X 的土壤格继续使用 16×16 网格；干土和湿土必须使用完全相同的尺寸、中心和绘制原点。
- 作物使用透明画布时，根部锚点必须固定在对应 16×16 格的底部中心；成长阶段变化不能让根部跳格。
- 如果耕地使用连通边缘／自动拼接，**邻居是否已耕**决定边缘形状，**是否浇水**只选择同一边缘形状的干／湿版本。湿度变化不能重新计算田块占地。
- 相邻耕地的间距不能因干湿状态不同而产生缝隙、重叠或半格偏移。
- 土壤湿度只影响显示与种植规则，不改变格子坐标、碰撞和交互中心。

### 4. 最小视觉验收

在 Godot 编辑器中并排放置并检查以下五格：

```text
未耕地 | 干燥空耕地 | 湿润空耕地 | 干燥幼苗 | 湿润幼苗
```

验收条件：

- 未耕地与干燥耕地一眼可分；
- 干土与湿土轮廓完全一致，湿土明显更暗但没有蓝色水面感；
- 两个幼苗的根部位于相同格心，只是下面土壤不同；
- 打开 Godot 网格后，所有土壤边缘和作物根部仍对齐 16×16 格；
- 连续田块的外边缘完整，内部没有重复边框、错位或残留旧贴图；
- 关闭作物层后，干土和湿土仍能独立正确显示。

## 版权边界

- 上述游戏画面只用于分析状态语言、相对明暗、叠层关系和网格规则。
- 不把官方截图、游戏贴图、图块集、角色／作物轮廓、边缘造型、动画帧或精确调色板复制、裁切、描摹或导入 Project X。
- 不用本报告中的亮度测量反推或复刻《星露谷物语》的具体 RGB 值。
- Project X 的实现只使用项目已经批准且许可证允许的 Super Retro World - Farming 资源，或团队原创资源；任何衍生改色都必须先确认原资源许可证允许修改与项目用途。
- 可以借鉴的是抽象规则：**三态土壤、湿土变暗、作物独立叠层、格心不动、边缘不因湿度改变**。
