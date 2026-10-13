# Super Retro 农田与作物视觉模块

## 素材边界

- 正式 `HomeRegion` 使用 `Super_Retro_Tilesets.tres` 的 16×16 耕地底图。
- 六种春季作物通过 `content/catalogs/super_retro_crop_visual_catalog.tres` 映射到 Super Retro 的 `Props/Crops/Sprites/crop_*.png`。
- `FarmPlot` 的运行时状态仍只保存作物 ID、成长天数和浇水状态；作物图集、帧宽和阶段帧属于可替换的 Resource 表现适配。
- 旧 `assets/private/mineral_town_crops/` 保留为历史参考和兼容资料，但不再被正式 `FarmPlot` 运行路径引用。

## 当前接入

正式家园的土壤由编辑器中保存的 Super Retro TileMap 绘制；作物植株由 Inspector 指定的视觉目录按作物 ID 绘制发芽、成长、半成熟和成熟阶段。每个 FarmPlot 的底部锚点对齐其声明的 16×16 TileMap cell center。

## 验收

1. 未翻土的大田保持原地图外观。
2. 对编辑器中保存的任一农田格使用锄头后，状态仍写入该格对应的 FarmPlot。
3. 播种、浇水并跨日后，作物贴图由发芽变为成长、成熟。
4. 缺少 Super Retro 作物资源时，农田逻辑、存档和旧原型回退仍可正常工作；正式家园不会把旧图集当作视觉源。
