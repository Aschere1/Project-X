# 末日区域大地图与主屋室内图提示词

## 是否需要大地图

需要。家园地图负责“我现在在哪里”，区域大地图负责“下一步去哪里”。外出流程建议为：

`家园大院 → 区域地图选点 → 地点详情/风险 → 进入搜刮场景`

区域大地图不是可自由行走的大世界，而是一个可点击的地点选择界面。底图负责方向感和氛围，地点按钮、风险、距离、耗时和可搜物资由 Godot UI 叠加。这样比纯文本选项更直观，也不会引入完整开放世界的工作量。

## 主屋室内图提示词

主屋是家园中唯一需要独立室内图的建筑。它与农场总地图分开生成，进入主屋后使用固定功能区和头像移动。

```text
Create a 480x270 pixel-art orthographic top-down 2D interior map for the main house of a Chinese rural zombie-apocalypse survival game. This is the interior of the damaged main house shown in the reference farm compound, not an exterior and not the whole farm. Show a compact rectangular room with a clearly visible floor, outer walls only around the edges, one entrance, and continuous walkable paths for a small avatar marker. Separate four practical functional areas without readable text: a sleeping corner with a simple cot, a storage corner with shelves and crates, a repair and crafting bench with hand tools, and a small cooking and water-preparation corner. Use damp cracked plaster, dark wooden beams, salvaged boards, faded blue cloth, rusted metal, muddy footprints and survivor-made repairs. Keep furniture against the walls and leave the center open. The mood is tense but livable, grounded in a southern Chinese rural homestead near Shangyou County, Ganzhou, Jiangxi. Use strict overhead orthographic view, floor-first composition, muted gray-green and rust-brown palette, readable silhouettes, and a fixed 480x270 game-screen composition. No characters, no zombies, no gore, no combat, no UI, no readable text, no logo, no watermark.
```

负面提示词：

```text
front-facing room, side view, eye-level camera, first-person view, cinematic perspective, vanishing point, realistic architectural visualization, exterior farm, large courtyard, isometric diamond map, diagonal grid, platformer view, furniture filling the center, blocked walkways, characters, zombies, gore, UI panels, buttons, text, labels, watermark, logo
```

输出要求：PNG、480×270、无 UI 和文字、无水印、硬边像素风；不需要透明背景。保存为 `assets/art/apocalypse/shelter/main_house_interior.png`。

## 区域大地图提示词

```text
Create a 640x360 overhead regional travel map for a Chinese zombie-apocalypse survival game. Use real satellite-map and Google Maps imagery only as composition reference for the relationship between streets, town blocks, rivers, reservoirs, villages and farmland, then reinterpret it as an original game map rather than copying a screenshot. The map represents a county-level area inspired by Shangyou County in Ganzhou, Jiangxi, not an isolated countryside. Use a strict vertical top-down view similar to a stylized satellite map: the county town is a clearly visible dense urban area with a street grid, apartment blocks, older low-rise buildings, a county government district, hospital, market, school, bus station and industrial edge. Around the town, show expanding suburbs, several connected villages and smaller townships, farmland, wooded hills, reservoirs and streams. Include a main highway, county roads, bridges and winding rural roads connecting the settlements.

Place a clearly identifiable starting shelter marker in a remote farm compound on the outer edge of the county, visibly far from the county town and connected by a smaller road. The shelter marker should be a warm but restrained circular pin or house icon, with enough surrounding empty space for Godot to add the label “庇护所” and a selected-state ring. Also leave room for additional location markers at the county clinic, market street, hardware store, gas station, police station, school, riverside dock, industrial warehouse zone and mountain trail.

This is a strategic location-selection map, not a freely walkable game level. Keep terrain, roads, water, urban blocks and settlement clusters clearly separated. Use muted gray-green survival colors, concrete gray urban areas, rust-brown roads, dark green hills and subdued water blue. Do not bake readable labels or UI into the image. No characters, no zombies, no gore, no logo, no watermark. It should feel like an original game-ready overhead satellite map based on a real county layout.
```

负面提示词：

```text
first-person, eye-level, cinematic landscape, isometric diamond map, diagonal grid, 3D perspective, pure countryside with no county town, no urban blocks, no roads connecting settlements, missing remote shelter, shelter placed inside the city center, dense unreadable detail, giant text, baked labels, UI, buttons, character portraits, zombies, gore, watermark, logo
```

输出要求：PNG、640×360、无文字、无水印、保留清晰道路和地点留白。保存为 `assets/art/apocalypse/world/apocalypse_region_map.png`。Godot 中由地点按钮和标记覆盖文字、风险和可搜物资。
