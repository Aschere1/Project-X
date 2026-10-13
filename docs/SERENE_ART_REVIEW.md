# Serene Village 美术预览

预览场景位于 [serene_art_review.tscn](../scenes/world/serene_art_review.tscn)。它不接入
`HomeRegion`，只用于确认 16×16 素材在 480×270、最近邻放大的实际观感。

## 打开方式

1. 在 Godot FileSystem 中打开 `scenes/world/serene_art_review.tscn`。
2. 使用“运行当前场景”。
3. 检查建筑、树木、水岸与现有 24×32 玩家比例是否匹配。

## 本轮验收点

- 图集本身没有被拉伸或模糊。
- 建筑的底边、树干和水岸有足够的细节密度，适合作为下一轮替换目标。
- 未直接改变 `HomeRegion`、碰撞、农田 ID 或存档规则。

## 下一轮选择

通过预览后，只选取一个小范围接入正式家园：草地/水岸/树木/一栋建筑四项中最多两项。
碰撞仍由现有独立的脚底/物体底部规则维护，不从图片边缘自动推断。
