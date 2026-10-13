class_name ApocalypseInventoryGridView
extends Control

signal item_activated(container_id: StringName, instance_id: StringName)
signal item_context_requested(container_id: StringName, instance_id: StringName, screen_position: Vector2i)
signal item_drop_requested(source_container_id: StringName, instance_id: StringName, target_container_id: StringName, target_cell: Vector2i)

const INVENTORY_ITEM_SCRIPT = preload("res://src/world/apocalypse_inventory_item.gd")
const SLOT_TEXTURE = preload("res://assets/art/apocalypse/ui/slots/inventory_slot.png")
const WATER_ICON = preload("res://assets/art/apocalypse/items/water.png")
const MEDKIT_ICON = preload("res://assets/art/apocalypse/items/medkit.png")
const BANDAGE_ICON = preload("res://assets/art/apocalypse/items/bandage.png")
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const CELL_PIXELS := 18

var _container_id: StringName = &""
var _columns := 1
var _rows := 1
var _item_count := 0
var _icon_key_material: ShaderMaterial

func set_inventory(container_id: StringName, snapshot: Dictionary) -> void:
	_container_id = container_id
	_columns = max(1, int(snapshot.get("columns", 1)))
	_rows = max(1, int(snapshot.get("rows", 1)))
	var items_value: Variant = snapshot.get("items", [])
	var items: Array[Dictionary] = []
	if items_value is Array:
		for item_value in items_value:
			if item_value is Dictionary:
				items.append(item_value)
	_item_count = items.size()
	custom_minimum_size = Vector2(_columns * CELL_PIXELS, _rows * CELL_PIXELS)
	size = custom_minimum_size
	_rebuild_cells(items)

func get_rendered_item_count() -> int:
	return _item_count

func get_grid_dimensions() -> Vector2i:
	return Vector2i(_columns, _rows)

func _rebuild_cells(items: Array[Dictionary]) -> void:
	for child in get_children():
		child.queue_free()
	for y in range(_rows):
		for x in range(_columns):
			var slot := TextureRect.new()
			slot.texture = SLOT_TEXTURE
			slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			slot.stretch_mode = TextureRect.STRETCH_SCALE
			slot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			slot.position = Vector2(x * CELL_PIXELS, y * CELL_PIXELS)
			slot.size = Vector2(CELL_PIXELS, CELL_PIXELS)
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(slot)
	for item in items:
		_add_item_block(item)

func _add_item_block(item: Dictionary) -> void:
	var instance_id := StringName(item.get("instance_id", ""))
	var item_id := StringName(item.get("item_id", ""))
	var width := int(item.get("width", 1))
	var height := int(item.get("height", 1))
	var quantity := int(item.get("quantity", 1))
	var maximum_stack := int(item.get("maximum_stack", ITEM_CATALOG_SCRIPT.get_maximum_stack(item_id)))
	var item_button: ApocalypseInventoryItem = INVENTORY_ITEM_SCRIPT.new()
	item_button.name = "Item_%s" % instance_id
	item_button.clip_contents = true
	var icon := _icon_for_item(item_id)
	item_button.text = ""
	item_button.add_theme_font_size_override("font_size", 6)
	item_button.position = Vector2(int(item.get("x", 0)) * CELL_PIXELS + 1, int(item.get("y", 0)) * CELL_PIXELS + 1)
	item_button.size = Vector2(width * CELL_PIXELS - 2, height * CELL_PIXELS - 2)
	item_button.tooltip_text = _item_tooltip(item_id, quantity, maximum_stack, int(item.get("weight", 0)))
	item_button.set_drag_identity(_container_id, instance_id)
	item_button.add_theme_stylebox_override("normal", _item_style(_item_color(item_id), Color(0.72, 0.82, 0.91, 1.0)))
	item_button.add_theme_stylebox_override("hover", _item_style(_item_color(item_id).lightened(0.12), Color(0.96, 0.78, 0.32, 1.0)))
	item_button.add_theme_stylebox_override("pressed", _item_style(_item_color(item_id).darkened(0.12), Color(1.0, 0.91, 0.55, 1.0)))
	item_button.pressed.connect(_on_item_pressed.bind(instance_id))
	item_button.gui_input.connect(_on_item_gui_input.bind(instance_id))
	if icon != null:
		var icon_view := TextureRect.new()
		icon_view.texture = icon
		icon_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_view.material = _get_icon_key_material()
		icon_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_button.add_child(icon_view)
	else:
		item_button.set_fallback_icon(item_id)
	if quantity > 1:
		var quantity_badge := Panel.new()
		quantity_badge.name = "QuantityBadge"
		quantity_badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		quantity_badge.offset_left = -12
		quantity_badge.offset_top = -8
		quantity_badge.offset_right = -1
		quantity_badge.offset_bottom = -1
		quantity_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var badge_style := StyleBoxFlat.new()
		badge_style.bg_color = Color(0.04, 0.06, 0.07, 0.42)
		badge_style.corner_radius_top_left = 2
		badge_style.corner_radius_top_right = 2
		badge_style.corner_radius_bottom_left = 2
		badge_style.corner_radius_bottom_right = 2
		quantity_badge.add_theme_stylebox_override("panel", badge_style)
		var quantity_label := Label.new()
		quantity_label.name = "Quantity"
		quantity_label.text = "×%d" % quantity
		quantity_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		quantity_label.add_theme_font_size_override("font_size", 5)
		quantity_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.76, 1.0))
		quantity_label.add_theme_color_override("font_outline_color", Color(0.05, 0.06, 0.07, 1.0))
		quantity_label.add_theme_constant_override("outline_size", 1)
		quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		quantity_badge.add_child(quantity_label)
		item_button.add_child(quantity_badge)
	add_child(item_button)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	if StringName(data.get("kind", "")) != &"apocalypse_inventory_item":
		return false
	if StringName(data.get("container_id", "")) == &"" or StringName(data.get("instance_id", "")) == &"":
		return false
	var target_cell := Vector2i(floori(at_position.x / CELL_PIXELS), floori(at_position.y / CELL_PIXELS))
	return target_cell.x >= 0 and target_cell.y >= 0 and target_cell.x < _columns and target_cell.y < _rows

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(at_position, data):
		return
	var target_cell := Vector2i(floori(at_position.x / CELL_PIXELS), floori(at_position.y / CELL_PIXELS))
	item_drop_requested.emit(
		StringName(data.get("container_id", "")),
		StringName(data.get("instance_id", "")),
		_container_id,
		target_cell,
	)

func _on_item_pressed(instance_id: StringName) -> void:
	item_activated.emit(_container_id, instance_id)

func _on_item_gui_input(event: InputEvent, instance_id: StringName) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_RIGHT or not mouse_event.pressed:
		return
	item_context_requested.emit(_container_id, instance_id, Vector2i(get_global_mouse_position()))
	accept_event()

func _item_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border
	return style

func _get_icon_key_material() -> ShaderMaterial:
	if _icon_key_material != null:
		return _icon_key_material
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\n\nvoid fragment() {\n\tvec4 color = texture(TEXTURE, UV);\n\tif (max(color.r, max(color.g, color.b)) < 0.025) {\n\t\tcolor.a = 0.0;\n\t}\n\tCOLOR = color;\n}\n"
	_icon_key_material = ShaderMaterial.new()
	_icon_key_material.shader = shader
	return _icon_key_material

func _item_color(item_id: StringName) -> Color:
	match item_id:
		&"water":
			return Color(0.16, 0.42, 0.60, 0.94)
		&"medkit":
			return Color(0.62, 0.23, 0.20, 0.94)
		&"bandage":
			return Color(0.54, 0.46, 0.18, 0.94)
		_:
			return Color(0.22, 0.38, 0.30, 0.94)

func _icon_for_item(item_id: StringName) -> Texture2D:
	match item_id:
		&"water":
			return WATER_ICON
		&"medkit":
			return MEDKIT_ICON
		&"bandage":
			return BANDAGE_ICON
		_:
			return null

func _item_tooltip(item_id: StringName, quantity: int, maximum_stack: int, weight: int) -> String:
	var weight_text := "单件负重 %d" % weight
	if _container_id == &"home_storage":
		weight_text = "家园仓储不计负重"
	return "%s\n%s · %d/%d · 单格\n%s\n%s" % [
		ITEM_CATALOG_SCRIPT.get_display_name(item_id),
		ITEM_CATALOG_SCRIPT.get_category(item_id),
		quantity,
		maximum_stack,
		ITEM_CATALOG_SCRIPT.get_effect_text(item_id),
		weight_text,
	]
