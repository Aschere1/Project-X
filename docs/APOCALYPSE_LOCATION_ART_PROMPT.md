# 县郊卫生室地点插图生成提示词

当前审查场景已经提供 `LocationIllustration` TextureRect 槽位。若现成素材的画面拼接不够统一，可以手动生成一张背景插图，再通过 Godot Inspector 拖入该槽位。

## 推荐提示词

```text
Create a single 480x270 pixel-art location illustration for a Chinese rural county clinic in a zombie-apocalypse survival game. The art does not need to imitate a farming-game tileset. Prioritize a believable, weathered survival-horror location-card: crisp hard pixel edges, readable silhouettes, restrained low-saturation colors, damp gray-green hills, faded clinic white, oxidized metal, rust brown, dirty concrete, and small emergency red accents. The scene is a small abandoned village clinic on a mountain road inspired by Shangyou County in Ganzhou, Jiangxi: one modest tiled clinic building, a covered entrance, a faded medical sign with no readable text, a rusty parked ambulance, a roadside grass verge, distant wooded hills, scattered crates and a locked metal cabinet. Show three clearly separated foreground interaction areas: reception counter, medicine cabinet, and ambulance. Leave enough quiet space around each area for UI hotspot labels. Atmosphere: tense, quiet, recently abandoned, rain-worn, practical and grounded, not fantasy. Camera: fixed 2D side/front location-card composition, no perspective distortion, designed to sit behind a text-and-search UI. No characters, no zombies, no combat action, no gore, no readable lettering, no logos, no watermark.
```

## 负面提示词

```text
photorealistic, 3D render, smooth gradients, vector art, anime, glossy modern game UI, high saturation, neon cyberpunk, western city skyline, skyscrapers, fantasy magic, medieval castle, excessive fog, gore, blood splatter, corpses, close-up character, weapon showcase, readable text, watermark, logo, blurry pixels, anti-aliased edges, mismatched tile scales, isometric camera
```

## 参考图与输出要求

- 参考图可以使用项目现有家园截图来理解 UI 尺寸和像素清晰度，也可以使用真实乡村卫生室、废弃诊所、赣南山地道路的照片或其他末日像素环境作为氛围参考；不要复制具体建筑布局、角色或受版权保护的构图。
- 输出尺寸优先 480×270；如果生成工具更适合 320×180，也可以先输出后在 Godot 中以最近邻整数缩放检查。
- PNG，保留清晰硬边；不要在图中烘焙热点圆圈、按钮、时间、物资文字或搜索框。
- 必须输出 PNG；如果是贴图或图标，使用真正透明背景，不要使用 JPG、纯黑底或棋盘格假透明。
- 建议保存为：`assets/art/apocalypse/locations/county_clinic.png`
- 导入 Godot 后，在 `scenes/reviews/apocalypse_explore_review.tscn` 根节点的 `Location Illustration` 属性中拖入图片；不要改脚本路径。

## 如果手动拼接现成素材

可以用 `Pixel Hospital Tileset` 或 `Soppycraft Hospital Top-Down Pixel Pack` 做卫生室主体，用 `Kenney RPG Urban Pack` 或更贴近末日的素材补道路、箱子和路牌。拼接后统一到 480×270 的构图、硬像素边缘和 UI 对比度；不必强行统一成 Super Retro 色板，也不要把不同包的原始图块直接混进家园 TileMap。
