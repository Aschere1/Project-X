class_name ItemCatalog
extends Resource

@export var items: Array[Resource] = []

var _items_by_id: Dictionary[StringName, ItemDefinition] = {}

func get_item(item_id: StringName) -> ItemDefinition:
	if _items_by_id.is_empty():
		_build_index()
	return _items_by_id.get(item_id)

func get_seed_item_ids() -> Array[StringName]:
	var seed_item_ids: Array[StringName] = []
	for resource in items:
		var item := resource as ItemDefinition
		assert(item != null, "ItemCatalog can only contain ItemDefinition resources.")
		if item.is_seed:
			seed_item_ids.append(item.item_id)
	return seed_item_ids

func _build_index() -> void:
	for resource in items:
		var item := resource as ItemDefinition
		assert(item != null, "ItemCatalog can only contain ItemDefinition resources.")
		assert(item.item_id != &"", "Item definitions require a stable item_id.")
		assert(not _items_by_id.has(item.item_id), "Duplicate item_id: %s" % item.item_id)
		_items_by_id[item.item_id] = item
