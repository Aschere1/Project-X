class_name CropVisualCatalog
extends Resource

@export var definitions: Array[Resource] = []
var _definitions_by_crop_id: Dictionary[StringName, Resource] = {}

func get_definition(crop_id: StringName) -> Resource:
	if _definitions_by_crop_id.is_empty():
		for definition in definitions:
			var definition_id := StringName(str(definition.get("crop_id"))) if definition != null else &""
			if definition != null and definition_id != &"":
				_definitions_by_crop_id[definition_id] = definition
	return _definitions_by_crop_id.get(crop_id)
