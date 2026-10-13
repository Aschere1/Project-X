class_name ApocalypseInventoryItem
extends Button

var _fallback_icon_id: StringName = &""
var _drag_container_id: StringName = &""
var _drag_instance_id: StringName = &""

func set_fallback_icon(item_id: StringName) -> void:
	_fallback_icon_id = item_id
	queue_redraw()

func set_drag_identity(container_id: StringName, instance_id: StringName) -> void:
	_drag_container_id = container_id
	_drag_instance_id = instance_id

func _get_drag_data(_at_position: Vector2) -> Variant:
	if _drag_container_id == &"" or _drag_instance_id == &"":
		return null
	var preview := Panel.new()
	preview.custom_minimum_size = Vector2(16, 16)
	preview.size = Vector2(16, 16)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color(0.12, 0.19, 0.16, 0.82)
	preview_style.border_width_left = 1
	preview_style.border_width_top = 1
	preview_style.border_width_right = 1
	preview_style.border_width_bottom = 1
	preview_style.border_color = Color(0.64, 0.72, 0.62, 0.9)
	preview.add_theme_stylebox_override("panel", preview_style)
	set_drag_preview(preview)
	return {
		"kind": &"apocalypse_inventory_item",
		"container_id": _drag_container_id,
		"instance_id": _drag_instance_id,
	}

func _draw() -> void:
	if _fallback_icon_id == &"":
		return
	var color := Color(0.94, 0.86, 0.53, 1.0)
	var center := size * 0.5
	match _fallback_icon_id:
		&"clinic_key":
			draw_circle(Vector2(5.0, 6.0), 2.5, color)
			draw_arc(Vector2(5.0, 6.0), 1.2, 0.0, TAU, 10, Color(0.18, 0.21, 0.18, 1.0), 1.0)
			draw_line(Vector2(7.0, 7.5), Vector2(13.0, 13.0), color, 1.5)
			draw_line(Vector2(10.5, 10.5), Vector2(9.0, 12.0), color, 1.5)
			draw_line(Vector2(12.0, 12.0), Vector2(10.5, 13.5), color, 1.5)
		&"fuel_can":
			draw_rect(Rect2(4.0, 3.0, 8.0, 11.0), color, false, 1.5)
			draw_line(Vector2(6.0, 3.0), Vector2(6.0, 1.5), color, 1.5)
			draw_line(Vector2(6.0, 1.5), Vector2(10.0, 1.5), color, 1.5)
			draw_line(Vector2(6.0, 8.5), Vector2(10.0, 8.5), color, 1.0)
		&"scrap_metal":
			draw_rect(Rect2(4.0, 4.0, 8.0, 7.0), Color(0.69, 0.73, 0.72, 1.0), true)
			draw_line(Vector2(3.0, 11.0), Vector2(12.5, 4.0), color, 1.0)
		&"wire":
			draw_arc(Vector2(8.0, 8.0), 4.0, 0.4, TAU - 0.4, 14, Color(0.78, 0.55, 0.28, 1.0), 1.2)
			draw_line(Vector2(4.5, 11.0), Vector2(2.5, 13.0), color, 1.0)
		&"simple_lockpick":
			draw_line(Vector2(4.0, 13.0), Vector2(11.5, 4.0), color, 1.3)
			draw_line(Vector2(9.5, 6.5), Vector2(13.0, 6.5), color, 1.0)
			draw_line(Vector2(5.5, 12.5), Vector2(9.0, 12.5), color, 1.0)
		&"crowbar":
			var steel := Color(0.67, 0.70, 0.66, 1.0)
			draw_line(Vector2(5.0, 13.0), Vector2(10.5, 3.0), steel, 2.0)
			draw_line(Vector2(10.0, 3.5), Vector2(13.0, 2.5), steel, 1.5)
			draw_line(Vector2(5.5, 12.5), Vector2(3.0, 10.5), steel, 1.5)
		_:
			draw_circle(center, 4.0, color)
			draw_line(Vector2(center.x - 2.0, center.y), Vector2(center.x + 2.0, center.y), Color(0.18, 0.21, 0.18, 1.0), 1.0)

func _make_custom_tooltip(for_text: String) -> Object:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.07, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.63, 0.57, 0.39, 1.0)
	style.content_margin_left = 4
	style.content_margin_top = 2
	style.content_margin_right = 4
	style.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = for_text
	label.add_theme_font_size_override("font_size", 7)
	label.add_theme_color_override("font_color", Color(0.91, 0.87, 0.70, 1.0))
	panel.add_child(label)
	return panel
