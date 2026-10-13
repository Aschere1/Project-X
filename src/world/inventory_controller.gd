class_name InventoryController
extends Node

signal inventory_changed()
signal panel_visibility_changed(is_visible: bool)
signal selected_seed_changed(seed_item_id: StringName, display_name: String)

const ACTION_OPEN_INVENTORY := &"open_inventory"
const ACTION_CYCLE_SEED := &"cycle_seed"

@export var item_catalog: ItemCatalog
@export var starting_item_amounts: Dictionary[StringName, int] = {}
@export_range(1, 48, 1) var maximum_slots := 12

var inventory: Inventory
var _is_panel_open := false
var _selected_seed_item_id: StringName

func _ready() -> void:
	assert(item_catalog != null, "InventoryController requires an ItemCatalog.")
	inventory = Inventory.new(maximum_slots)
	for item_id in starting_item_amounts:
		add_item(item_id, starting_item_amounts[item_id])
	_ensure_selected_seed()
	inventory_changed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_OPEN_INVENTORY):
		set_panel_open(not _is_panel_open)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_CYCLE_SEED):
		select_next_seed()
		get_viewport().set_input_as_handled()

func add_item(item_id: StringName, quantity: int, quality: int = -1) -> int:
	var definition := item_catalog.get_item(item_id)
	assert(definition != null, "Unknown item_id: %s" % item_id)
	var actual_quality := definition.default_quality if quality < 0 else quality
	var remaining := inventory.add_item(item_id, quantity, definition.maximum_stack_size, actual_quality)
	inventory_changed.emit()
	return remaining

func remove_item(item_id: StringName, quantity: int) -> int:
	var removed := inventory.remove_item(item_id, quantity)
	if removed > 0:
		_ensure_selected_seed()
		inventory_changed.emit()
	return removed

func can_add_item(item_id: StringName, quantity: int, quality: int = -1) -> bool:
	var definition := item_catalog.get_item(item_id)
	assert(definition != null, "Unknown item_id: %s" % item_id)
	var actual_quality := definition.default_quality if quality < 0 else quality
	return inventory.can_add_item(item_id, quantity, definition.maximum_stack_size, actual_quality)

func get_selected_seed_item_id() -> StringName:
	return _selected_seed_item_id

func get_selected_seed_display_name() -> String:
	var definition := item_catalog.get_item(_selected_seed_item_id)
	return definition.display_name if definition != null else "无"

func select_next_seed() -> bool:
	var seed_item_ids := item_catalog.get_seed_item_ids()
	if seed_item_ids.is_empty():
		return false
	var current_index := seed_item_ids.find(_selected_seed_item_id)
	for offset in range(1, seed_item_ids.size() + 1):
		var candidate: StringName = seed_item_ids[(current_index + offset) % seed_item_ids.size()]
		if inventory.count_item(candidate) > 0:
			_set_selected_seed(candidate)
			return true
	return false

func set_panel_open(is_open: bool) -> void:
	if _is_panel_open == is_open:
		return
	_is_panel_open = is_open
	panel_visibility_changed.emit(_is_panel_open)

func get_inventory_text() -> String:
	var lines := [
		"背包  %d/%d" % [inventory.get_used_slots(), inventory.get_maximum_slots()],
		"当前种子：%s  （R 切换）" % get_selected_seed_display_name(),
	]
	for stack in inventory.get_stacks():
		var definition := item_catalog.get_item(StringName(stack["item_id"]))
		var display_name := definition.display_name if definition != null else "未知物品"
		lines.append("%s%s  x%d" % [display_name, get_quality_suffix(int(stack.get("quality", Inventory.NORMAL_QUALITY))), int(stack["quantity"])])
	return "\n".join(lines)

func to_snapshot() -> Dictionary:
	return inventory.to_snapshot()

func restore_snapshot(snapshot: Dictionary) -> bool:
	var restored := inventory.restore_snapshot(snapshot)
	if restored:
		_ensure_selected_seed()
		inventory_changed.emit()
	return restored

func _ensure_selected_seed() -> void:
	if _selected_seed_item_id != &"" and inventory.count_item(_selected_seed_item_id) > 0:
		return
	select_next_seed()

func _set_selected_seed(seed_item_id: StringName) -> void:
	if _selected_seed_item_id == seed_item_id:
		return
	_selected_seed_item_id = seed_item_id
	selected_seed_changed.emit(seed_item_id, get_selected_seed_display_name())

func get_quality_name(quality: int) -> String:
	match quality:
		Inventory.SILVER_QUALITY: return "银星"
		Inventory.GOLD_QUALITY: return "金星"
		_: return "普通"

func get_quality_suffix(quality: int) -> String:
	return "" if quality == Inventory.NORMAL_QUALITY else "（%s）" % get_quality_name(quality)
