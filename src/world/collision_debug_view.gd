@tool
extends Node2D
## 碰撞可视化：编辑器里始终可见，游戏里按 F1 开关（默认显示）。
## 直接读取真实 CollisionShape2D 实时绘制，所见即所得。
##
## 颜色约定（只有三种）：
##   蓝 = 墙 Walls（StaticBody2D，挡住玩家走出地图边界）
##   橙 = 障碍 Obstacles（StaticBody2D，挡住玩家穿过建筑/家具）
##   绿 = 功能区 InteractionZones（Area2D，玩家走进去触发互动，上方标名字）

const _COLOR_WALL_FILL := Color(0.36, 0.68, 0.99, 0.22)
const _COLOR_WALL_EDGE := Color(0.62, 0.84, 1.0, 0.95)
const _COLOR_OBSTACLE_FILL := Color(0.99, 0.50, 0.27, 0.22)
const _COLOR_OBSTACLE_EDGE := Color(1.0, 0.66, 0.45, 0.95)
const _COLOR_ZONE_FILL := Color(0.29, 0.96, 0.55, 0.22)
const _COLOR_ZONE_EDGE := Color(0.55, 1.0, 0.78, 0.95)
const _LABEL_COLOR := Color(1, 1, 1, 0.95)
const _LABEL_SIZE := 9

var _visible := true

func _ready() -> void:
	set_process(true)
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	var key_event := event as InputEventKey
	if key_event != null and key_event.keycode == KEY_F1 and key_event.pressed and not key_event.echo:
		_visible = not _visible
		queue_redraw()
	queue_redraw()

func _draw() -> void:
	if not _visible:
		return
	for shape in _collect_shapes():
		var rect_shape := shape.shape as RectangleShape2D
		if rect_shape == null:
			continue
		var center := to_local(shape.global_position)
		var rect := Rect2(center - rect_shape.size * 0.5, rect_shape.size)
		var cat := _category_of(shape)
		var fill: Color = _COLOR_WALL_FILL
		var edge: Color = _COLOR_WALL_EDGE
		match cat:
			1:
				fill = _COLOR_OBSTACLE_FILL
				edge = _COLOR_OBSTACLE_EDGE
			2:
				fill = _COLOR_ZONE_FILL
				edge = _COLOR_ZONE_EDGE
		draw_rect(rect, fill, true)
		draw_rect(rect, edge, false, 1.5)
		_draw_label(rect, shape, cat)

func _draw_label(rect: Rect2, shape: CollisionShape2D, cat: int) -> void:
	var font: Font = ThemeDB.fallback_font
	if font == null:
		return
	var text := _label_text(shape, cat)
	if text == "":
		return
	var pos := Vector2(rect.position.x + 1.0, rect.position.y - _LABEL_SIZE - 1.0)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, _LABEL_SIZE, _LABEL_COLOR)

func _label_text(shape: CollisionShape2D, cat: int) -> String:
	var owner_node := shape.get_parent()
	if owner_node == null:
		return ""
	var nm := String(owner_node.name)
	if cat == 2:
		if owner_node.has_meta("zone_label"):
			return nm + "·" + String(owner_node.get_meta("zone_label"))
		if owner_node.has_meta("zone_id"):
			return nm + "·" + String(owner_node.get_meta("zone_id"))
	return nm

func _collect_shapes() -> Array:
	var out: Array = []
	for child in get_children():
		_gather(child, out)
	return out

func _gather(node: Node, out: Array) -> void:
	if node is CollisionShape2D:
		out.append(node)
	for child in node.get_children():
		_gather(child, out)

func _category_of(shape: CollisionShape2D) -> int:
	var n: Node = shape.get_parent()
	while n != null and n != self:
		var nm := String(n.name)
		if nm == "Walls":
			return 0
		if nm == "Obstacles":
			return 1
		if nm == "InteractionZones":
			return 2
		n = n.get_parent()
	return 0
