class_name FarmSoilVisualSet
extends Resource

const UNTOUCHED := &"untouched"
const DRY_TILLED := &"dry_tilled"
const WET_TILLED := &"wet_tilled"

@export var untouched_texture: Texture2D
@export var dry_tilled_texture: Texture2D
@export var wet_tilled_texture: Texture2D
@export var untouched_modulate := Color.WHITE
@export var dry_tilled_modulate := Color.WHITE
@export var wet_tilled_modulate := Color(0.64, 0.72, 0.78, 1.0)

func get_texture(state_id: StringName) -> Texture2D:
	match state_id:
		DRY_TILLED:
			return dry_tilled_texture
		WET_TILLED:
			return wet_tilled_texture
		_:
			return untouched_texture

func get_modulate(state_id: StringName) -> Color:
	match state_id:
		DRY_TILLED:
			return dry_tilled_modulate
		WET_TILLED:
			return wet_tilled_modulate
		_:
			return untouched_modulate
