class_name CropVisualDefinition
extends Resource

@export var crop_id: StringName = &""
@export var texture: Texture2D
@export_range(1, 64, 1) var frame_width := 18
@export var stage_frames: Array[int] = [0, 1, 2, 3]

func get_stage_region(stage_index: int) -> Rect2:
	if texture == null or frame_width < 1 or stage_frames.is_empty():
		return Rect2()
	var safe_index := clampi(stage_index, 0, stage_frames.size() - 1)
	var frame := maxi(0, stage_frames[safe_index])
	return Rect2(frame * frame_width, 0, frame_width, texture.get_height())
