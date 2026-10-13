# 末日庇护所与主角头像提示词

当前主线使用简化的末日农场家园：一张静态俯视 2D 大院地图，院内有主屋、鸡舍、牛棚、羊棚、猪棚、菜地、储物和工作区。主屋、储物棚、工作台、菜地和大门由 Godot 场景中可编辑的点击热区覆盖；不再要求头像在地图上行走，也不再为庇护所维护碰撞箱。只有主屋需要单独制作室内图；其他棚舍和功能区先使用院内建筑标记与 UI 入口表现，不要求生成全部室内场景。主角头像保留给以后背包、装备、角色资料和剧情对话使用。

## 庇护所背景

上一版生成结果只是室内局部图，不能作为家园总地图。不要继续把床、工作台和菜地塞进一间室内。应重新生成一张“俯视的正方形末日农场大院总地图”；室内图另行制作，其他区域用院内建筑屋顶、围栏和功能标记即可。

### 编辑现有图片的提示词

```text
Use the attached image only as a mood and material reference. Create a new 2D home-farm map, not an interior illustration. Show one large nearly square walled rural compound viewed from a strict orthographic top-down camera, approximately 70 to 80 degrees from above. The whole compound must fit in frame with a visible outer fence or broken brick wall, a gate, dirt ground, and clear readable zones. Place a damaged main house near the upper or left edge, with a readable front door and porch; the main house is the only structure that needs an interior later. Inside the yard, clearly separate small, simple functional structures: a chicken coop, a combined cattle/sheep/pig shelter with three adjacent pens, a storage shed, a workbench or repair corner, a water point, and a rectangular vegetable field. Use roofs, fences, troughs, crates, tool racks and animal-pen silhouettes to communicate these zones without readable text. Keep each functional structure visually separated so Godot can place a transparent clickable hotspot over it. The farm should feel like an abandoned but recoverable southern Chinese rural homestead near Shangyou County, Ganzhou, Jiangxi: damaged plaster, dark tile roofs, repaired wood, rusted metal, damp soil, weeds, muted gray-green daylight and a few warm practical lights. Preserve a tense zombie-apocalypse survival mood, but make the layout readable like a simple game map. Compose for a 480x270 fixed 2D screen, with the large square yard occupying most of the image.
```

### 必须追加的负面提示词

```text
front-facing interior, indoor room only, side view, eye-level camera, first-person view, cinematic perspective, vanishing point, strong depth perspective, close-up furniture, realistic architectural visualization, isometric diamond map, diagonal isometric grid, platformer side view, tiny yard, narrow corridor, no outer compound, no fence, no gate, no farm structures, no animal pens, no main house, all buildings merged together, huge foreground furniture, blocked floor, cluttered walkways, characters, zombies, UI, buttons, readable text, labels, watermark, logo
```

如果仍然生成成正面室内图，可以改用这句更强的开头：

```text
Do not make an interior illustration. Generate a large square playable orthographic top-down 2D farm compound map, like a simple survival game home map viewed from above. The main house is only one building inside the yard; the yard, gate, paths, animal pens, sheds and vegetable field must all be visible.
```

### 推荐输出要求

- PNG，480×270。
- 俯视平面优先，正方形大院和地面至少占画面 70%。
- 必须同时看见主屋、鸡舍、三联牲畜棚/围栏、储物棚、工作区、水点、菜地、院墙和大门。
- 主屋、储物棚、工作区、菜地与大门的外观必须彼此清晰分开，方便在 Godot 中覆盖透明点击热区。
- 鸡舍、牲畜棚和储物棚只需要外观轮廓；它们的室内内容由 UI 面板表现。
- 不要把单个建筑做成大特写，不要让任何建筑遮住大部分院子。
- 不需要角色，不需要碰撞框，不需要 UI 文字；点击热区和功能入口 UI 由 Godot 场景单独处理。

```text
Create a 480x270 pixel-art orthographic top-down 2D farm compound map for a Chinese rural zombie-apocalypse survival game. Show one large nearly square fenced yard at an abandoned southern Chinese farmhouse near wooded hills, inspired by rural Shangyou County in Ganzhou, Jiangxi. The whole yard is the main subject: broken brick-and-wood perimeter wall, gate, dirt paths, open central yard, damaged main house, chicken coop, three small animal pens for cattle, sheep and pigs, storage shed, repair/workbench corner, water point and rectangular vegetable field. Use roof silhouettes, fences, troughs, crates and simple props to make each zone readable without text. Keep the main house as the only important building; all other interiors will be shown through UI panels. Include damp earth, weeds, rain stains, dark tile roofs, repaired wood, rust-brown metal, faded blue cloth, muted gray-green daylight and a few warm practical light accents. The mood is tense but livable: a recoverable homestead after several days of collapse. Use strict overhead orthographic view, a floor-first composition, clear walkable paths, no vanishing point, no side-view wall composition, and no isometric diamond grid. No characters, no zombies, no combat, no gore, no readable signs, no logos, no watermark.
```

## 主角头像

```text
Create one simple 64x64 pixel-art survivor portrait for a Chinese rural zombie-apocalypse survival game. Neutral tired expression, practical weathered jacket, short dark hair, small scratch or dirt mark, grounded ordinary civilian appearance, clear face silhouette, muted gray-green and rust-brown palette, subtle warm skin tones, front-facing bust portrait, transparent background, no frame, no text, no logo, no watermark, no exaggerated anime features, no glamour pose, no gore.
```

## 统一格式要求

- 背景：PNG，480×270，真正透明背景不适用于整张背景时使用完整画布，但不要出现黑边；无 UI、按钮、文字和水印。
- 头像：PNG，64×64，真正透明 alpha，单个头像，无黑底、无棋盘格、无头像框。
- 两者都要保留硬边和清晰轮廓，但不要求贴近 Super Retro；优先服务末日氛围和功能区辨识度。
- 背景生成后保存为 `assets/art/apocalypse/shelter/apocalypse_shelter.png`。
- 头像生成后保存为 `assets/art/apocalypse/characters/survivor_avatar.png`。

## Godot 接入

打开 `scenes/world/apocalypse_shelter.tscn`，选择根节点：

- 将背景拖到 `Shelter Illustration`。
- 在 `Canvas/MapHotspots` 中移动或缩放主屋、储物棚、工作台、菜地和大门的 `Button`，使其覆盖对应建筑；这些热区才是功能入口的正式来源。
- 头像保存到 `assets/art/apocalypse/characters/survivor_avatar.png`，暂不绑定在庇护所场景；以后由背包、装备或对话 UI 引用。

没有背景图时，场景会保留低饱和色块回退；没有头像图时不影响家园地图、热区或功能入口面板。
