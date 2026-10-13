class_name Inventory
extends RefCounted

const SNAPSHOT_VERSION := 2
const NORMAL_QUALITY := 1
const SILVER_QUALITY := 2
const GOLD_QUALITY := 3

var _maximum_slots: int
var _stacks: Array[Dictionary] = []

func _init(maximum_slots: int = 12) -> void:
	assert(maximum_slots > 0, "Inventory must have at least one slot.")
	_maximum_slots = maximum_slots

func add_item(item_id: StringName, quantity: int, maximum_stack_size: int, quality: int = NORMAL_QUALITY) -> int:
	assert(item_id != &"", "Inventory items require a stable item_id.")
	assert(quantity >= 0, "Cannot add a negative item quantity.")
	assert(maximum_stack_size > 0, "Item stack size must be positive.")
	assert(_is_valid_quality(quality), "Item quality must be between normal and gold.")

	var remaining := quantity
	for stack in _stacks:
		if StringName(stack["item_id"]) != item_id or int(stack.get("quality", NORMAL_QUALITY)) != quality:
			continue
		var available_space: int = maximum_stack_size - int(stack["quantity"])
		var added_to_stack: int = min(available_space, remaining)
		stack["quantity"] = int(stack["quantity"]) + added_to_stack
		remaining -= added_to_stack
		if remaining == 0:
			return 0

	while remaining > 0 and _stacks.size() < _maximum_slots:
		var added_to_new_stack: int = min(maximum_stack_size, remaining)
		_stacks.append({"item_id": item_id, "quantity": added_to_new_stack, "quality": quality})
		remaining -= added_to_new_stack
	return remaining

func count_item(item_id: StringName) -> int:
	var total := 0
	for stack in _stacks:
		if StringName(stack["item_id"]) == item_id:
			total += int(stack["quantity"])
	return total

func remove_item(item_id: StringName, quantity: int) -> int:
	assert(item_id != &"", "Inventory items require a stable item_id.")
	assert(quantity >= 0, "Cannot remove a negative item quantity.")
	var remaining := quantity
	for quality in range(NORMAL_QUALITY, GOLD_QUALITY + 1):
		for index in range(_stacks.size() - 1, -1, -1):
			var stack: Dictionary = _stacks[index]
			if StringName(stack["item_id"]) != item_id or int(stack.get("quality", NORMAL_QUALITY)) != quality:
				continue
			var removed: int = min(int(stack["quantity"]), remaining)
			stack["quantity"] = int(stack["quantity"]) - removed
			remaining -= removed
			if int(stack["quantity"]) == 0:
				_stacks.remove_at(index)
			if remaining == 0:
				return quantity
	return quantity - remaining

func can_add_item(item_id: StringName, quantity: int, maximum_stack_size: int, quality: int = NORMAL_QUALITY) -> bool:
	assert(item_id != &"", "Inventory items require a stable item_id.")
	assert(quantity >= 0, "Cannot check a negative item quantity.")
	assert(maximum_stack_size > 0, "Item stack size must be positive.")
	assert(_is_valid_quality(quality), "Item quality must be between normal and gold.")
	var available_capacity := 0
	for stack in _stacks:
		if StringName(stack["item_id"]) == item_id and int(stack.get("quality", NORMAL_QUALITY)) == quality:
			available_capacity += maximum_stack_size - int(stack["quantity"])
	available_capacity += (_maximum_slots - _stacks.size()) * maximum_stack_size
	return available_capacity >= quantity

func get_used_slots() -> int:
	return _stacks.size()

func get_maximum_slots() -> int:
	return _maximum_slots

func get_stacks() -> Array[Dictionary]:
	var copied_stacks: Array[Dictionary] = []
	for stack in _stacks:
		copied_stacks.append(stack.duplicate())
	return copied_stacks

func get_item_quality_values(item_id: StringName, quantity: int) -> Array[int]:
	assert(quantity >= 0, "Cannot request a negative item quantity.")
	var values: Array[int] = []
	for quality in range(NORMAL_QUALITY, GOLD_QUALITY + 1):
		for stack in _stacks:
			if StringName(stack["item_id"]) != item_id or int(stack.get("quality", NORMAL_QUALITY)) != quality:
				continue
			for _index in int(stack["quantity"]):
				values.append(quality)
				if values.size() == quantity:
					return values
	return values

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"maximum_slots": _maximum_slots,
		"stacks": get_stacks(),
	}

func restore_snapshot(snapshot: Dictionary) -> bool:
	var version: int = int(snapshot.get("version", 0))
	var maximum_slots: int = int(snapshot.get("maximum_slots", 0))
	var stack_values: Variant = snapshot.get("stacks")
	if (version != 1 and version != SNAPSHOT_VERSION) or maximum_slots <= 0 or not stack_values is Array:
		return false

	var restored_stacks: Array[Dictionary] = []
	for stack_value in stack_values:
		if not stack_value is Dictionary:
			return false
		if not stack_value.has("item_id") or not stack_value.has("quantity"):
			return false
		var item_id := StringName(stack_value["item_id"])
		var quantity: int = int(stack_value["quantity"])
		var quality: int = NORMAL_QUALITY if version == 1 else int(stack_value.get("quality", 0))
		if item_id == &"" or quantity <= 0 or not _is_valid_quality(quality):
			return false
		restored_stacks.append({"item_id": item_id, "quantity": quantity, "quality": quality})

	if restored_stacks.size() > maximum_slots:
		return false
	_maximum_slots = maximum_slots
	_stacks = restored_stacks
	return true

func _is_valid_quality(quality: int) -> bool:
	return quality >= NORMAL_QUALITY and quality <= GOLD_QUALITY
