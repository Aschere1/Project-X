class_name ApocalypseSearchContainer
extends RefCounted

const SNAPSHOT_VERSION := 1
const STATE_UNSEARCHED := &"unsearched"
const STATE_PARTIAL := &"partial"
const STATE_SEARCHED := &"searched"

const GRID_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/grid_container.gd")

var _container_id: StringName
var _grid: Variant
var _metadata: Dictionary = {}
var _total_noise := 0
var _total_search_minutes := 0
var _state: StringName = STATE_UNSEARCHED

func _init(container_id: StringName = &"", columns: int = 4, rows: int = 4) -> void:
	assert(columns > 0 and rows > 0, "A search container requires positive grid dimensions.")
	_container_id = container_id
	_grid = GRID_CONTAINER_SCRIPT.new(columns, rows, 1)

func get_container_id() -> StringName:
	return _container_id

func add_hidden_item(
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	search_minutes: int,
	noise: int,
	rarity_tier: int,
	category: StringName,
) -> bool:
	if _container_id == &"" or search_minutes <= 0 or noise < 0 or rarity_tier < 0 or rarity_tier > 3 or category == &"":
		return false
	var placed := false
	for y in range(_grid.get_rows()):
		for x in range(_grid.get_columns()):
			if _grid.place_item(instance_id, item_id, width, height, weight, x, y, false):
				placed = true
				break
		if placed:
			break
	if not placed:
		return false
	var item_snapshot: Array[Dictionary] = _grid.get_items()
	var position: Dictionary = {}
	for item in item_snapshot:
		if StringName(item["instance_id"]) == instance_id:
			position = item
			break
	if position.is_empty():
		return false
	_metadata[instance_id] = {
		"search_minutes": search_minutes,
		"noise": noise,
		"rarity_tier": rarity_tier,
		"category": category,
		"collected": false,
	}
	return true

func search_item(instance_id: StringName) -> Dictionary:
	var item: Dictionary = _grid.get_item(instance_id)
	var metadata: Variant = _metadata.get(instance_id)
	if item.is_empty() or bool(item.get("revealed", false)) or (metadata is Dictionary and bool(metadata.get("collected", false))):
		return {"ok": false, "message": "Item is already revealed or missing."}
	if not metadata is Dictionary:
		return {"ok": false, "message": "Search metadata is missing."}
	_grid.reveal_item(instance_id)
	_total_noise += int(metadata["noise"])
	_total_search_minutes += int(metadata["search_minutes"])
	_refresh_state()
	return {
		"ok": true,
		"container_id": _container_id,
		"instance_id": instance_id,
		"item_id": StringName(item["item_id"]),
		"rarity_tier": int(metadata["rarity_tier"]),
		"category": StringName(metadata["category"]),
		"minutes_spent": int(metadata["search_minutes"]),
		"noise_generated": int(metadata["noise"]),
	}

func get_revealed_uncollected_item_ids() -> Array[StringName]:
	var item_ids: Array[StringName] = []
	for item in _grid.get_items():
		var instance_id := StringName(item["instance_id"])
		var metadata: Variant = _metadata.get(instance_id, {})
		if bool(item.get("revealed", false)) and metadata is Dictionary and not bool(metadata.get("collected", false)):
			item_ids.append(instance_id)
	return item_ids

func collect_revealed_item(instance_id: StringName) -> Dictionary:
	var item: Dictionary = _grid.get_item(instance_id)
	var metadata: Variant = _metadata.get(instance_id)
	if item.is_empty() or not metadata is Dictionary:
		return {"ok": false, "message": "物资不存在。"}
	if not bool(item.get("revealed", false)):
		return {"ok": false, "message": "物资尚未被发现。"}
	if bool(metadata.get("collected", false)):
		return {"ok": false, "message": "物资已经带走。"}
	var collected_metadata: Dictionary = metadata
	collected_metadata["collected"] = true
	_metadata[instance_id] = collected_metadata
	return {"ok": true, "instance_id": instance_id, "item_id": StringName(item["item_id"])}

func get_item_snapshot(instance_id: StringName) -> Dictionary:
	var item: Dictionary = _grid.get_item(instance_id)
	if item.is_empty():
		return {}
	var metadata: Variant = _metadata.get(instance_id, {})
	if metadata is Dictionary:
		item.merge(metadata)
	return item

func get_state() -> StringName:
	return _state

func get_total_noise() -> int:
	return _total_noise

func get_total_search_minutes() -> int:
	return _total_search_minutes

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"container_id": _container_id,
		"grid": _grid.to_snapshot(),
		"metadata": _metadata.duplicate(true),
		"total_noise": _total_noise,
		"total_search_minutes": _total_search_minutes,
		"state": _state,
	}

func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	var container_id := StringName(snapshot.get("container_id", ""))
	var grid_value: Variant = snapshot.get("grid")
	var metadata_value: Variant = snapshot.get("metadata")
	var total_noise: int = int(snapshot.get("total_noise", -1))
	var total_search_minutes: int = int(snapshot.get("total_search_minutes", -1))
	var state := StringName(snapshot.get("state", ""))
	if container_id == &"" or not grid_value is Dictionary or not metadata_value is Dictionary:
		return false
	if total_noise < 0 or total_search_minutes < 0 or state not in [STATE_UNSEARCHED, STATE_PARTIAL, STATE_SEARCHED]:
		return false

	var restored_grid: Variant = GRID_CONTAINER_SCRIPT.new()
	if not restored_grid.restore_snapshot(grid_value):
		return false
	var restored_metadata: Dictionary = {}
	for item in restored_grid.get_items():
		var instance_id := StringName(item["instance_id"])
		var metadata: Variant = metadata_value.get(instance_id)
		if not metadata is Dictionary:
			return false
		if int(metadata.get("search_minutes", 0)) <= 0 or int(metadata.get("noise", -1)) < 0:
			return false
		if int(metadata.get("rarity_tier", -1)) < 0 or int(metadata.get("rarity_tier", -1)) > 3:
			return false
		if StringName(metadata.get("category", "")) == &"":
			return false
		var collected: bool = bool(metadata.get("collected", false))
		restored_metadata[instance_id] = {
			"search_minutes": int(metadata["search_minutes"]),
			"noise": int(metadata["noise"]),
			"rarity_tier": int(metadata["rarity_tier"]),
			"category": StringName(metadata["category"]),
			"collected": collected,
		}

	_container_id = container_id
	_grid = restored_grid
	_metadata = restored_metadata
	_total_noise = total_noise
	_total_search_minutes = total_search_minutes
	_state = state
	return true

func _refresh_state() -> void:
	var items: Array[Dictionary] = _grid.get_items()
	if items.is_empty():
		_state = STATE_UNSEARCHED
		return
	var revealed_count := 0
	for item in items:
		if bool(item.get("revealed", false)):
			revealed_count += 1
	if revealed_count == 0:
		_state = STATE_UNSEARCHED
	elif revealed_count == items.size():
		_state = STATE_SEARCHED
	else:
		_state = STATE_PARTIAL
