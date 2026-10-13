extends Control

const CLINIC_LOCATION_ID := &"village_clinic"
const CLINIC_LOCATION_TYPE := &"fixed"
const CLINIC_SCENE_PATH := "res://scenes/reviews/apocalypse_explore_review.tscn"
const MARKET_LOCATION_ID := &"county_market"
const MARKET_LOCATION_TYPE := &"fixed"
const MARKET_SCENE_PATH := "res://scenes/reviews/apocalypse_market_review.tscn"
const WAREHOUSE_LOCATION_ID := &"industrial_warehouse"
const WAREHOUSE_LOCATION_TYPE := &"fixed"
const WAREHOUSE_SCENE_PATH := "res://scenes/reviews/apocalypse_warehouse_review.tscn"
const LOCATION_SCENE_PATHS := {
	CLINIC_LOCATION_ID: CLINIC_SCENE_PATH,
	MARKET_LOCATION_ID: MARKET_SCENE_PATH,
	WAREHOUSE_LOCATION_ID: WAREHOUSE_SCENE_PATH,
}
const LOCATION_TYPES := {
	CLINIC_LOCATION_ID: CLINIC_LOCATION_TYPE,
	MARKET_LOCATION_ID: MARKET_LOCATION_TYPE,
	WAREHOUSE_LOCATION_ID: WAREHOUSE_LOCATION_TYPE,
}

signal destination_open_requested(location_id: StringName, scene_path: String)

@onready var selection_status: Label = $HUD/SelectionStatus
@onready var global_overlay: Variant = $GlobalOverlay

func _ready() -> void:
	for marker in $HUD/LocationMarkers.get_children():
		var marker_button := marker as Button
		if marker_button != null:
			var location_id := StringName(marker_button.get_meta("location_id", ""))
			marker_button.pressed.connect(_on_location_selected.bind(location_id, marker_button.text))

func _unhandled_input(event: InputEvent) -> void:
	if global_overlay.handle_input_event(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_return_to_shelter()

func _on_location_selected(location_id: StringName, location_name: String) -> void:
	if location_id == &"shelter":
		_return_to_shelter()
		return
	var destination_path: String = String(LOCATION_SCENE_PATHS.get(location_id, ""))
	if destination_path.is_empty():
		selection_status.text = "%s · 该地点将在后续开放" % location_name
		return
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var location_type := StringName(LOCATION_TYPES.get(location_id, &"fixed"))
	apocalypse_run.ensure_active_session().discover_location(location_id, location_type)
	selection_status.text = "%s · 进入搜刮" % location_name
	destination_open_requested.emit(location_id, destination_path)
	get_tree().change_scene_to_file(destination_path)

func _on_back_pressed() -> void:
	_return_to_shelter()

func _return_to_shelter() -> void:
	get_tree().change_scene_to_file("res://scenes/world/apocalypse_shelter.tscn")
