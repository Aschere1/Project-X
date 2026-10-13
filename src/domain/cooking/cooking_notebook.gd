class_name CookingNotebook
extends RefCounted

const SNAPSHOT_VERSION := 2
var _entries: Array[Dictionary] = []

func record(cookware_id: StringName, ingredient_ids: Array[StringName], seasoning_id: StringName, result_item_id: StringName, quality_tier: int = 1, rarity_tier: int = 0, is_signature: bool = false) -> void:
	var ingredients := ingredient_ids.duplicate()
	ingredients.sort()
	var serialized_ingredients: Array[String] = []
	for ingredient_id in ingredients:
		serialized_ingredients.append(String(ingredient_id))
	var entry := {"cookware_id": String(cookware_id), "ingredient_ids": serialized_ingredients, "seasoning_id": String(seasoning_id), "result_item_id": String(result_item_id), "quality_tier": quality_tier, "rarity_tier": rarity_tier, "is_signature": is_signature}
	for index in _entries.size():
		var existing: Dictionary = _entries[index]
		if _is_same_combination(existing, entry):
			if int(entry["quality_tier"]) >= int(existing.get("quality_tier", 1)):
				_entries[index] = entry
			return
	_entries.append(entry)

func get_entry_count() -> int:
	return _entries.size()

func get_entry(index: int) -> Dictionary:
	if index < 0 or index >= _entries.size():
		return {}
	return _entries[index].duplicate(true)

func to_snapshot() -> Dictionary:
	return {"version": SNAPSHOT_VERSION, "entries": _entries.duplicate(true)}

func restore_snapshot(snapshot: Dictionary) -> bool:
	var version := int(snapshot.get("version", 0))
	if version != 1 and version != SNAPSHOT_VERSION:
		return false
	var entries: Variant = snapshot.get("entries", [])
	if not entries is Array:
		return false
	var restored_entries: Array[Dictionary] = []
	for value in entries:
		if not value is Dictionary or not _is_valid_entry(value, version):
			return false
		var restored_entry: Dictionary = value.duplicate(true)
		if version == 1:
			restored_entry["quality_tier"] = 1
			restored_entry["rarity_tier"] = 0
			restored_entry["is_signature"] = false
		else:
			# JSON decoders may materialize integral numbers as floats. Normalize
			# them back to the typed values used by the runtime snapshot.
			restored_entry["quality_tier"] = int(restored_entry["quality_tier"])
			restored_entry["rarity_tier"] = int(restored_entry["rarity_tier"])
		restored_entries.append(restored_entry)
	_entries = restored_entries
	return true

func _is_valid_entry(entry: Dictionary, version: int) -> bool:
	if not entry.has("cookware_id") or not entry.has("ingredient_ids") or not entry.has("seasoning_id") or not entry.has("result_item_id"):
		return false
	if version == SNAPSHOT_VERSION and (not entry.has("quality_tier") or not entry.has("rarity_tier") or not entry.has("is_signature")):
		return false
	var cookware_value: Variant = entry["cookware_id"]
	var seasoning_value: Variant = entry["seasoning_id"]
	var result_value: Variant = entry["result_item_id"]
	if not cookware_value is String or not seasoning_value is String or not result_value is String:
		return false
	if version == SNAPSHOT_VERSION:
		var quality_value: Variant = entry["quality_tier"]
		var rarity_value: Variant = entry["rarity_tier"]
		var signature_value: Variant = entry["is_signature"]
		if not _is_integer_number(quality_value) or not _is_integer_number(rarity_value) or not signature_value is bool:
			return false
		if int(quality_value) < 1 or int(quality_value) > 3 or int(rarity_value) < 0 or int(rarity_value) > 2:
			return false
	var ingredients: Variant = entry["ingredient_ids"]
	if not ingredients is Array or ingredients.size() > 4:
		return false
	for ingredient_id in ingredients:
		if not ingredient_id is String:
			return false
	return true

func _is_integer_number(value: Variant) -> bool:
	if not value is int and not value is float:
		return false
	return is_equal_approx(float(value), round(float(value)))

func _is_same_combination(first: Dictionary, second: Dictionary) -> bool:
	return first.get("cookware_id") == second.get("cookware_id") and first.get("ingredient_ids") == second.get("ingredient_ids") and first.get("seasoning_id") == second.get("seasoning_id") and first.get("result_item_id") == second.get("result_item_id")
