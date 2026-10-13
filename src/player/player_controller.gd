class_name PlayerController
extends CharacterBody2D

signal interaction_requested(facing_direction: Vector2)
signal tool_requested(facing_direction: Vector2)

const ACTION_MOVE_LEFT := &"move_left"
const ACTION_MOVE_RIGHT := &"move_right"
const ACTION_MOVE_UP := &"move_up"
const ACTION_MOVE_DOWN := &"move_down"
const ACTION_SPRINT := &"sprint"
const ACTION_INTERACT := &"interact"
const ACTION_USE_TOOL := &"use_tool"
const DEVELOPMENT_WALK_ATLAS_PATH := "res://assets/private/super_retro_world_farming/Characters/Farm/farm_walk_atlas_32x32.png"
const ORIGINAL_WALK_ATLAS_PATH := "res://assets/art/characters/player_walk.png"
const WALK_DOWN_ANIMATION := &"walk_down"
const WALK_UP_ANIMATION := &"walk_up"
const WALK_SIDE_ANIMATION := &"walk_side"
const DEVELOPMENT_WALK_FRAME_SIZE := Vector2(32.0, 32.0)
const DEVELOPMENT_WALK_FRAMES_PER_DIRECTION := 3
const DEVELOPMENT_WALK_COLUMN_OFFSET := 6
const DEVELOPMENT_IDLE_FRAME := 1
const ORIGINAL_WALK_FRAME_SIZE := Vector2(24.0, 32.0)
const ORIGINAL_WALK_FRAMES_PER_DIRECTION := 4

@export_range(1.0, 500.0, 1.0, "suffix:px/s") var move_speed := 80.0
@export_range(1.0, 3.0, 0.05) var sprint_speed_multiplier := 1.5
@export_range(1.0, 3.0, 0.05) var sprint_animation_speed_multiplier := 1.35
@export var movement_bounds := Rect2(24.0, 52.0, 432.0, 192.0)

var facing_direction := Vector2.DOWN
var input_enabled := true
var _visual_baseline_id := &"original_fallback"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fallback_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_configure_original_walk_visual()
	_update_walk_visual(false)

func _physics_process(_delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		_update_walk_visual(false)
		return

	var input_direction := Input.get_vector(
		ACTION_MOVE_LEFT,
		ACTION_MOVE_RIGHT,
		ACTION_MOVE_UP,
		ACTION_MOVE_DOWN,
	)
	var is_sprinting := input_direction != Vector2.ZERO and Input.is_action_pressed(ACTION_SPRINT)
	velocity = input_direction * get_move_speed(is_sprinting)
	if input_direction != Vector2.ZERO:
		facing_direction = _to_cardinal_direction(input_direction)
	_update_walk_visual(input_direction != Vector2.ZERO, is_sprinting)

	move_and_slide()
	global_position = global_position.clamp(
		movement_bounds.position,
		movement_bounds.position + movement_bounds.size,
	)

func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event.is_action_pressed(ACTION_INTERACT):
		interaction_requested.emit(facing_direction)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_USE_TOOL):
		tool_requested.emit(facing_direction)
		get_viewport().set_input_as_handled()

func set_input_enabled(is_enabled: bool) -> void:
	input_enabled = is_enabled
	if not input_enabled:
		velocity = Vector2.ZERO
		_update_walk_visual(false)

func get_move_speed(is_sprinting: bool) -> float:
	return move_speed * sprint_speed_multiplier if is_sprinting else move_speed

func get_walk_animation_speed_scale(is_sprinting: bool) -> float:
	return sprint_animation_speed_multiplier if is_sprinting else 1.0

func get_facing_name() -> String:
	match facing_direction:
		Vector2.LEFT:
			return "左"
		Vector2.RIGHT:
			return "右"
		Vector2.UP:
			return "上"
		_:
			return "下"

func _to_cardinal_direction(direction: Vector2) -> Vector2:
	if absf(direction.x) > absf(direction.y):
		return Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if direction.y > 0.0 else Vector2.UP

func get_walk_animation_name_for_facing(direction: Vector2) -> StringName:
	if direction == Vector2.UP:
		return WALK_UP_ANIMATION
	if direction == Vector2.LEFT or direction == Vector2.RIGHT:
		return WALK_SIDE_ANIMATION
	return WALK_DOWN_ANIMATION

func is_original_walk_visual_active() -> bool:
	return animated_sprite != null and animated_sprite.visible and animated_sprite.sprite_frames != null

func is_super_retro_walk_visual_active() -> bool:
	return is_original_walk_visual_active() and _visual_baseline_id == &"super_retro_world"

func get_visual_baseline_id() -> StringName:
	return _visual_baseline_id

func is_private_walk_visual_active() -> bool:
	# Compatibility seam for prototype-only tests. Formal scenes use the original atlas.
	return is_original_walk_visual_active()

func should_flip_walk_sprite(direction: Vector2) -> bool:
	return direction == Vector2.LEFT

func _configure_original_walk_visual() -> void:
	var atlas_path := ORIGINAL_WALK_ATLAS_PATH
	var frame_size := ORIGINAL_WALK_FRAME_SIZE
	var frames_per_direction := ORIGINAL_WALK_FRAMES_PER_DIRECTION
	var column_offset := 0
	if ResourceLoader.exists(DEVELOPMENT_WALK_ATLAS_PATH):
		atlas_path = DEVELOPMENT_WALK_ATLAS_PATH
		frame_size = DEVELOPMENT_WALK_FRAME_SIZE
		frames_per_direction = DEVELOPMENT_WALK_FRAMES_PER_DIRECTION
		column_offset = DEVELOPMENT_WALK_COLUMN_OFFSET
		_visual_baseline_id = &"super_retro_world"
	else:
		_visual_baseline_id = &"original_fallback"
	if not ResourceLoader.exists(atlas_path):
		animated_sprite.visible = false
		fallback_sprite.visible = true
		return
	var loaded_resource: Resource = load(atlas_path)
	var walk_texture := loaded_resource as Texture2D
	if walk_texture == null:
		animated_sprite.visible = false
		fallback_sprite.visible = true
		return
	animated_sprite.sprite_frames = _build_walk_frames(walk_texture, frame_size, frames_per_direction, column_offset)
	animated_sprite.visible = true
	fallback_sprite.visible = false

func _build_walk_frames(walk_texture: Texture2D, frame_size: Vector2, frames_per_direction: int, column_offset: int) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var animation_rows: Dictionary[StringName, int] = {
		WALK_DOWN_ANIMATION: 0,
		WALK_UP_ANIMATION: 3,
		WALK_SIDE_ANIMATION: 2,
	}
	if _visual_baseline_id != &"super_retro_world":
		animation_rows[WALK_UP_ANIMATION] = 1
	for animation_name: StringName in animation_rows:
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.set_animation_speed(animation_name, 7.0)
		var row: int = animation_rows[animation_name]
		for frame_index in frames_per_direction:
			var frame_texture := AtlasTexture.new()
			frame_texture.atlas = walk_texture
			frame_texture.region = Rect2(
				Vector2((column_offset + frame_index) * int(frame_size.x), row * int(frame_size.y)),
				frame_size,
			)
			frames.add_frame(animation_name, frame_texture)
	return frames

func _update_walk_visual(is_moving: bool, is_sprinting := false) -> void:
	if animated_sprite == null or not animated_sprite.visible or animated_sprite.sprite_frames == null:
		return
	animated_sprite.speed_scale = get_walk_animation_speed_scale(is_sprinting) if is_moving else 1.0
	var animation_name := get_walk_animation_name_for_facing(facing_direction)
	animated_sprite.flip_h = should_flip_walk_sprite(facing_direction)
	if is_moving:
		if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
			animated_sprite.play(animation_name)
		return
	animated_sprite.animation = animation_name
	animated_sprite.frame = DEVELOPMENT_IDLE_FRAME if _visual_baseline_id == &"super_retro_world" else 0
	animated_sprite.pause()
