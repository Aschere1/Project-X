class_name GridInteractable
extends StaticBody2D

signal interacted(interaction_id: StringName, result_text: String)

const INTERACTABLE_GROUP := &"project_x.grid_interactable"

@export var interaction_id: StringName
@export var display_name := "未命名对象"
@export_multiline var interaction_description := "暂时没有可执行的行动。"
@export var grid_cell := Vector2i.ZERO
@export var area_id: StringName = &"outdoor"
@export var fill_color := Color("e0a957")
@export var blocks_movement := true
@export var visual_texture: Texture2D
@export var visual_offset := Vector2.ZERO

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var _visual_suppressed := false
var _area_active := true
var _gameplay_enabled := true
var _uses_map_collision_proxy := false

func _ready() -> void:
	add_to_group(INTERACTABLE_GROUP)
	_sync_active_state()
	queue_redraw()

func interact() -> void:
	interacted.emit(interaction_id, "%s：%s" % [display_name, interaction_description])

func set_area_active(is_active: bool) -> void:
	_area_active = is_active
	_sync_active_state()

func set_gameplay_enabled(is_enabled: bool) -> void:
	_gameplay_enabled = is_enabled
	_sync_active_state()

func is_gameplay_enabled() -> bool:
	return _gameplay_enabled

func set_uses_map_collision_proxy(is_enabled: bool) -> void:
	_uses_map_collision_proxy = is_enabled
	_sync_active_state()

func set_visual_suppressed(is_suppressed: bool) -> void:
	_visual_suppressed = is_suppressed
	queue_redraw()

func is_visual_suppressed() -> bool:
	return _visual_suppressed

func _sync_active_state() -> void:
	visible = _area_active and _gameplay_enabled
	if collision_shape != null:
		collision_shape.set_deferred(
			"disabled",
			not _area_active or not _gameplay_enabled or not blocks_movement or _uses_map_collision_proxy,
		)

func _draw() -> void:
	if _visual_suppressed:
		return
	if visual_texture != null:
		var texture_size := visual_texture.get_size()
		draw_texture(visual_texture, -texture_size * 0.5 + visual_offset)
		return
	draw_rect(Rect2(-7.0, -7.0, 14.0, 14.0), Color("372c26"), true)
	draw_rect(Rect2(-5.0, -5.0, 10.0, 10.0), fill_color, true)
	draw_rect(Rect2(-7.0, -7.0, 14.0, 14.0), Color("f6e6b3"), false, 1.0)
