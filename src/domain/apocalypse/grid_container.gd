class_name ApocalypseGridContainer
extends RefCounted

const SNAPSHOT_VERSION := 2
const LOAD_LIGHT := &"light"
const LOAD_NORMAL := &"normal"
const LOAD_OVERWEIGHT := &"overweight"
const LOAD_SEVERELY_OVERWEIGHT := &"severely_overweight"

var _columns: int
var _rows: int
var _maximum_weight: int
var _items: Array[Dictionary] = []

func _init(columns: int = 4, rows: int = 4, maximum_weight: int = 10) -> void:
	assert(columns > 0 and rows > 0, "A grid container requires positive dimensions.")
	assert(maximum_weight > 0, "A grid container requires a positive weight threshold.")
	_columns = columns
	_rows = rows
	_maximum_weight = maximum_weight

func get_columns() -> int:
	return _columns

func get_rows() -> int:
	return _rows

func get_maximum_weight() -> int:
	return _maximum_weight

func place_item(
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	x: int,
	y: int,
	revealed: bool = true,
	quantity: int = 1,
	maximum_stack: int = 1,
) -> bool:
	if not _is_valid_item(instance_id, item_id, width, height, weight, quantity, maximum_stack):
		return false
	if _find_item_index(instance_id) >= 0 or not _fits_grid(width, height, x, y):
		return false
	for item in _items:
		if _rectangles_overlap(item, width, height, x, y):
			return false

	_items.append({
		"instance_id": instance_id,
		"item_id": item_id,
		"width": width,
		"height": height,
		"weight": weight,
		"quantity": quantity,
		"maximum_stack": maximum_stack,
		"x": x,
		"y": y,
		"revealed": revealed,
	})
	return true

func place_item_first_fit(
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	revealed: bool = true,
	quantity: int = 1,
	maximum_stack: int = 1,
) -> bool:
	for y in range(_rows):
		for x in range(_columns):
			if place_item(instance_id, item_id, width, height, weight, x, y, revealed, quantity, maximum_stack):
				return true
	return false

func add_item_stack(
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	quantity: int,
	maximum_stack: int,
	revealed: bool = true,
) -> bool:
	if not _is_valid_item(instance_id, item_id, width, height, weight, quantity, maximum_stack):
		return false
	var remaining := quantity
	for item in _items:
		if _can_merge(item, item_id, weight, maximum_stack, revealed):
			remaining -= min(remaining, maximum_stack - int(item["quantity"]))
			if remaining <= 0:
				break
	if not _has_space_for_new_stacks(width, height, remaining, maximum_stack):
		return false

	remaining = quantity
	for index in range(_items.size()):
		var existing: Dictionary = _items[index]
		if not _can_merge(existing, item_id, weight, maximum_stack, revealed):
			continue
		var added: int = min(remaining, maximum_stack - int(existing["quantity"]))
		if added <= 0:
			continue
		existing["quantity"] = int(existing["quantity"]) + added
		_items[index] = existing
		remaining -= added
		if remaining <= 0:
			return true

	var next_instance_id: StringName = instance_id
	while remaining > 0:
		var stack_quantity: int = min(remaining, maximum_stack)
		var accepted_instance_id: StringName = _make_available_instance_id(next_instance_id)
		if not place_item_first_fit(accepted_instance_id, item_id, width, height, weight, revealed, stack_quantity, maximum_stack):
			return false
		remaining -= stack_quantity
		next_instance_id = StringName("%s_2" % accepted_instance_id)
	return true

func can_add_item_stack(
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	quantity: int,
	maximum_stack: int,
	revealed: bool = true,
) -> bool:
	if not _is_valid_item(instance_id, item_id, width, height, weight, quantity, maximum_stack):
		return false
	var remaining := quantity
	for item in _items:
		if _can_merge(item, item_id, weight, maximum_stack, revealed):
			remaining -= min(remaining, maximum_stack - int(item["quantity"]))
			if remaining <= 0:
				return true
	return _has_space_for_new_stacks(width, height, remaining, maximum_stack)

func remove_quantity(instance_id: StringName, quantity: int) -> bool:
	var index := _find_item_index(instance_id)
	if index < 0 or quantity <= 0:
		return false
	var item: Dictionary = _items[index]
	var current_quantity := int(item.get("quantity", 1))
	if quantity > current_quantity:
		return false
	if quantity == current_quantity:
		_items.remove_at(index)
		return true
	item["quantity"] = current_quantity - quantity
	_items[index] = item
	return true

func split_stack(instance_id: StringName, new_instance_id: StringName, quantity: int) -> bool:
	var item: Dictionary = get_item(instance_id)
	if item.is_empty() or new_instance_id == &"" or _find_item_index(new_instance_id) >= 0:
		return false
	var current_quantity := int(item.get("quantity", 1))
	if quantity <= 0 or quantity >= current_quantity:
		return false
	if not place_item_first_fit(
		new_instance_id,
		StringName(item["item_id"]),
		int(item["width"]),
		int(item["height"]),
		int(item["weight"]),
		bool(item["revealed"]),
		quantity,
		int(item.get("maximum_stack", 1)),
	):
		return false
	return remove_quantity(instance_id, quantity)

func remove_item(instance_id: StringName) -> bool:
	var index := _find_item_index(instance_id)
	if index < 0:
		return false
	_items.remove_at(index)
	return true

func reveal_item(instance_id: StringName) -> bool:
	var index := _find_item_index(instance_id)
	if index < 0:
		return false
	_items[index]["revealed"] = true
	return true

func get_item(instance_id: StringName) -> Dictionary:
	var index := _find_item_index(instance_id)
	if index < 0:
		return {}
	return _items[index].duplicate()

func get_items() -> Array[Dictionary]:
	var copied_items: Array[Dictionary] = []
	for item in _items:
		copied_items.append(item.duplicate())
	return copied_items

func get_total_weight() -> int:
	var total := 0
	for item in _items:
		total += int(item["weight"]) * int(item.get("quantity", 1))
	return total

func get_occupied_slot_count() -> int:
	var occupied := 0
	for item in _items:
		occupied += int(item["width"]) * int(item["height"])
	return occupied

func get_capacity() -> int:
	return _columns * _rows

func get_load_state() -> StringName:
	var ratio := float(get_total_weight()) / float(_maximum_weight)
	if ratio <= 0.3:
		return LOAD_LIGHT
	if ratio <= 1.0:
		return LOAD_NORMAL
	if ratio <= 1.5:
		return LOAD_OVERWEIGHT
	return LOAD_SEVERELY_OVERWEIGHT

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"columns": _columns,
		"rows": _rows,
		"maximum_weight": _maximum_weight,
		"items": get_items(),
	}

func restore_snapshot(snapshot: Dictionary) -> bool:
	var version := int(snapshot.get("version", 0))
	if version < 1 or version > SNAPSHOT_VERSION:
		return false
	var columns: int = int(snapshot.get("columns", 0))
	var rows: int = int(snapshot.get("rows", 0))
	var maximum_weight: int = int(snapshot.get("maximum_weight", 0))
	var items_value: Variant = snapshot.get("items")
	if columns <= 0 or rows <= 0 or maximum_weight <= 0 or not items_value is Array:
		return false

	var restored: Variant = get_script().new(columns, rows, maximum_weight)
	for item_value in items_value:
		if not item_value is Dictionary:
			return false
		var item: Dictionary = item_value
		if not restored.place_item(
			StringName(item.get("instance_id", "")),
			StringName(item.get("item_id", "")),
			int(item.get("width", 0)),
			int(item.get("height", 0)),
			int(item.get("weight", -1)),
			int(item.get("x", -1)),
			int(item.get("y", -1)),
			bool(item.get("revealed", false)),
			int(item.get("quantity", 1)),
			int(item.get("maximum_stack", 1)),
		):
			return false

	_columns = restored._columns
	_rows = restored._rows
	_maximum_weight = restored._maximum_weight
	_items = restored._items
	return true

func _fits_grid(width: int, height: int, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x + width <= _columns and y + height <= _rows

func _rectangles_overlap(item: Dictionary, width: int, height: int, x: int, y: int) -> bool:
	return (
		x < int(item["x"]) + int(item["width"])
		and x + width > int(item["x"])
		and y < int(item["y"]) + int(item["height"])
		and y + height > int(item["y"])
	)

func _find_item_index(instance_id: StringName) -> int:
	for index in range(_items.size()):
		if StringName(_items[index]["instance_id"]) == instance_id:
			return index
	return -1

func _is_valid_item(instance_id: StringName, item_id: StringName, width: int, height: int, weight: int, quantity: int, maximum_stack: int) -> bool:
	return instance_id != &"" and item_id != &"" and width > 0 and height > 0 and weight >= 0 and quantity > 0 and maximum_stack > 0 and quantity <= maximum_stack

func _can_merge(item: Dictionary, item_id: StringName, weight: int, maximum_stack: int, revealed: bool) -> bool:
	return StringName(item["item_id"]) == item_id and int(item["weight"]) == weight and int(item.get("maximum_stack", 1)) == maximum_stack and bool(item["revealed"]) == revealed and int(item.get("quantity", 1)) < maximum_stack

func _has_space_for_new_stacks(width: int, height: int, remaining: int, maximum_stack: int) -> bool:
	if remaining <= 0:
		return true
	var simulated_items := get_items()
	var stacks_required := ceili(float(remaining) / float(maximum_stack))
	for ignored in range(stacks_required):
		var position := _find_first_fit_position(simulated_items, width, height)
		if position.x < 0:
			return false
		simulated_items.append({"x": position.x, "y": position.y, "width": width, "height": height})
	return true

func _find_first_fit_position(items: Array[Dictionary], width: int, height: int) -> Vector2i:
	for y in range(_rows):
		for x in range(_columns):
			if not _fits_grid(width, height, x, y):
				continue
			var overlaps := false
			for item in items:
				if _rectangles_overlap(item, width, height, x, y):
					overlaps = true
					break
			if not overlaps:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _make_available_instance_id(requested_instance_id: StringName) -> StringName:
	if _find_item_index(requested_instance_id) < 0:
		return requested_instance_id
	var suffix := 2
	while true:
		var candidate := StringName("%s_%d" % [requested_instance_id, suffix])
		if _find_item_index(candidate) < 0:
			return candidate
		suffix += 1
	return requested_instance_id
