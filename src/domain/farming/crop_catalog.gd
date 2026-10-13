class_name CropCatalog
extends Resource

const CROP_DEFINITION_SCRIPT = preload("res://src/domain/farming/crop_definition.gd")

@export var crops: Array[Resource] = []

var _crops_by_seed_item_id: Dictionary[StringName, Resource] = {}

func get_crop_by_seed_item_id(seed_item_id: StringName) -> Resource:
	if _crops_by_seed_item_id.is_empty():
		_build_index()
	return _crops_by_seed_item_id.get(seed_item_id)

func get_crop_count() -> int:
	return crops.size()

func _build_index() -> void:
	for crop in crops:
		assert(is_instance_of(crop, CROP_DEFINITION_SCRIPT), "CropCatalog can only contain CropDefinition resources.")
		assert(crop.crop_id != &"", "Crop definitions require a stable crop_id.")
		assert(crop.seed_item_id != &"", "Crop definitions require a seed item id.")
		assert(not _crops_by_seed_item_id.has(crop.seed_item_id), "Duplicate crop seed item id: %s" % crop.seed_item_id)
		_crops_by_seed_item_id[crop.seed_item_id] = crop
