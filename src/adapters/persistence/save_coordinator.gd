class_name SaveCoordinator
extends Node

signal save_message(message: String)

const MANUAL_SLOT_NAMES: Array[String] = ["slot_1", "slot_2", "slot_3"]
const AUTOSAVE_SLOT_NAMES: Array[String] = ["auto_1", "auto_2", "auto_3"]

@export_range(30.0, 900.0, 1.0, "suffix:s") var autosave_interval_seconds := 120.0
@export var player_path: NodePath
@export var game_clock_path: NodePath
@export var inventory_controller_path: NodePath
@export var cooking_controller_path: NodePath
@export var world_state_path: NodePath

@onready var player: PlayerController = get_node_or_null(player_path) as PlayerController
@onready var game_clock: GameClockController = get_node_or_null(game_clock_path) as GameClockController
@onready var inventory_controller: InventoryController = get_node_or_null(inventory_controller_path) as InventoryController
@onready var cooking_controller: CookingController = get_node_or_null(cooking_controller_path) as CookingController
@onready var world_state: Node = get_node_or_null(world_state_path)

var _repository := TimelineSaveRepository.new()
var _autosave_elapsed_seconds := 0.0
var _next_autosave_index := 0

func _ready() -> void:
	assert(player != null, "SaveCoordinator requires a PlayerController path.")
	assert(game_clock != null, "SaveCoordinator requires a GameClockController path.")
	assert(inventory_controller != null, "SaveCoordinator requires an InventoryController path.")
	assert(cooking_controller != null, "SaveCoordinator requires a CookingController path.")
	assert(world_state != null, "SaveCoordinator requires a world state path.")

func _process(delta: float) -> void:
	if game_clock.is_paused():
		return

	_autosave_elapsed_seconds += delta
	if _autosave_elapsed_seconds < autosave_interval_seconds:
		return

	_autosave_elapsed_seconds = 0.0
	var autosave_slot: String = AUTOSAVE_SLOT_NAMES[_next_autosave_index]
	_next_autosave_index = (_next_autosave_index + 1) % AUTOSAVE_SLOT_NAMES.size()
	_save_to_slot(autosave_slot, "自动存档")

func save_manual_slot(slot_name: String) -> void:
	if not _is_manual_slot(slot_name):
		save_message.emit("手动存档失败：无效存档格")
		return
	_save_to_slot(slot_name, "手动存档")

func load_manual_slot(slot_name: String) -> void:
	if not _is_manual_slot(slot_name):
		save_message.emit("读取存档失败：无效存档格")
		return
	_load_from_slot(slot_name)

func get_manual_slot_summary(slot_name: String) -> Dictionary:
	if not _is_manual_slot(slot_name):
		return {"exists": false, "slot_name": slot_name}

	var result := _repository.load_slot(slot_name)
	if not result.get("ok", false):
		return {"exists": false, "slot_name": slot_name}
	var snapshot_value: Variant = result.get("snapshot", {})
	if not snapshot_value is Dictionary:
		return {"exists": false, "slot_name": slot_name}
	var session_value: Variant = snapshot_value.get("game_session", {})
	if not session_value is Dictionary:
		return {"exists": false, "slot_name": slot_name}
	return {
		"exists": true,
		"slot_name": slot_name,
		"day": int(session_value.get("day", 1)),
		"minute_of_day": int(session_value.get("minute_of_day", 360)),
		"stamina": int(session_value.get("stamina", 0)),
		"used_backup": bool(result.get("used_backup", false)),
	}

func _save_to_slot(slot_name: String, label: String) -> void:
	var result := _repository.save_slot(slot_name, _capture_snapshot())
	if result.get("ok", false):
		save_message.emit("%s完成" % label)
		return
	save_message.emit("%s失败：%s" % [label, result.get("message", "未知错误")])

func _load_from_slot(slot_name: String) -> void:
	var result := _repository.load_slot(slot_name)
	if not result.get("ok", false):
		save_message.emit("读取存档失败：%s" % result.get("message", "未知错误"))
		return

	var snapshot_value: Variant = result.get("snapshot")
	if not snapshot_value is Dictionary:
		save_message.emit("读取存档失败：快照结构无效")
		return
	if not _restore_snapshot(snapshot_value):
		save_message.emit("读取存档失败：状态校验未通过")
		return

	var recovery_suffix := "（已从备份恢复）" if result.get("used_backup", false) else ""
	save_message.emit("已读取手动存档%s" % recovery_suffix)

func _is_manual_slot(slot_name: String) -> bool:
	return slot_name in MANUAL_SLOT_NAMES

func _capture_snapshot() -> Dictionary:
	return {
		"game_session": game_clock.session.to_snapshot(),
		"inventory": inventory_controller.to_snapshot(),
		"cooking": cooking_controller.to_snapshot(),
		"world": {
			"area_id": String(world_state.get_current_area_id()),
			"player_position": {
				"x": player.global_position.x,
				"y": player.global_position.y,
			},
			"interaction_state": world_state.capture_interaction_state(),
		},
	}

func _restore_snapshot(snapshot: Dictionary) -> bool:
	var session_value: Variant = snapshot.get("game_session")
	var inventory_value: Variant = snapshot.get("inventory")
	var cooking_value: Variant = snapshot.get("cooking", {"version": 1, "entries": []})
	var world_value: Variant = snapshot.get("world")
	if not session_value is Dictionary or not inventory_value is Dictionary or not cooking_value is Dictionary or not world_value is Dictionary:
		return false
	if not game_clock.session.restore_snapshot(game_clock.rules, session_value):
		return false
	if not inventory_controller.restore_snapshot(inventory_value):
		return false
	if not cooking_controller.restore_snapshot(cooking_value):
		return false

	var position_value: Variant = world_value.get("player_position")
	if not position_value is Dictionary:
		return false
	if not position_value.has("x") or not position_value.has("y"):
		return false
	var interaction_value: Variant = world_value.get("interaction_state", {})
	if not interaction_value is Dictionary or not world_state.restore_interaction_state(interaction_value):
		return false

	var area_id := StringName(str(world_value.get("area_id", "outdoor")))
	if not world_state.restore_area_and_player_position(
		area_id,
		Vector2(float(position_value["x"]), float(position_value["y"])),
	):
		return false
	game_clock.reset_time_accumulator()
	game_clock.emit_clock_state()
	return true
