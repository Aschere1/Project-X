# 灾变背包物品图标提示词

当前背包已经有可替换的 `TextureRect` 图标槽位。没有 PNG 时会显示“水 / 药 / 绷”文字回退；生成后直接把对应图片拖到 `apocalypse_explore_review.tscn` 根节点的三个导出属性：`Water Icon`、`Medkit Icon`、`Bandage Icon`。

## 通用约束

```text
Create a clean standalone inventory icon for a Chinese rural zombie-apocalypse survival game. Pixel-art inspired but readable at small size, hard edges, compact silhouette, subdued survival-horror palette, transparent background, centered object, no cast shadow outside the object, no UI frame, no text, no logo, no watermark, no character, no gore. The icon must remain recognizable when displayed at 12x12 to 24x24 pixels in a grid inventory.
```

## 文件格式要求

- 输出 PNG，不要 JPG/JPEG。
- 必须是真透明背景（alpha），不要用纯黑、白色或棋盘格模拟透明。
- 保留单个物品，不要带 UI 框、背包格、阴影底板或文字。
- 推荐画布 32×32 或 64×64；物品主体四周保留少量透明边距。
- 导入 Godot 后使用 `TextureRect`，保持普通纹理，不生成碰撞、TileMap 或额外节点。

## 水

```text
One reusable clear plastic water bottle with a slightly dented body, cloudy blue-gray water, a dark cap, a small faded orange tape mark, practical scavenged survival item, front three-quarter view, isolated on transparent background, 32x32 pixel-art icon, hard pixel edges, muted blue and gray palette, no readable label, no text, no logo.
```

## 急救包

```text
One compact worn red-brown first-aid kit with a pale medical cross painted on the lid, scratched metal corners, a small clasp, practical rural clinic supply, front three-quarter view, isolated on transparent background, 32x32 pixel-art icon, hard pixel edges, muted red, cream and dark teal palette, no readable text, no logo, no blood.
```

## 绷带

```text
One rolled sterile bandage in a slightly dirty cream cloth wrap with a tiny muted red tie, compact scavenged medical supply, front three-quarter view, isolated on transparent background, 32x32 pixel-art icon, hard pixel edges, muted cream, gray and rust-red palette, no readable text, no logo, no blood.
```

## 负面提示词

```text
photorealistic, 3D render, glossy mobile game icon, neon colors, fantasy potion, oversized object, complex background, UI panel, inventory grid, readable lettering, brand logo, watermark, gore, blood, zombie face, blurry edges, anti-aliased vector art, excessive highlights
```

## 接入路径

建议保存为：

- `assets/art/apocalypse/items/water.png`
- `assets/art/apocalypse/items/medkit.png`
- `assets/art/apocalypse/items/bandage.png`

然后在 Godot 打开 `scenes/reviews/apocalypse_explore_review.tscn`，选择根节点，把三张图分别拖到 `Water Icon`、`Medkit Icon`、`Bandage Icon`。如果暂时不生成，文字缩写回退会继续工作。
