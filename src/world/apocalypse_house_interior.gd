extends Control

const SHELTER_SCENE_PATH := "res://scenes/world/apocalypse_shelter.tscn"

const HOTSPOT_ZONE_IDS: Array[StringName] = [
	&"bed",
	&"medical_corner",
	&"indoor_workbench",
	&"emergency_power",
	&"exit",
]

@onready var map_hotspots: Control = $MapHotspots
@onready var status_label: Label = $HUD/StatusPanel/VBox/Status
@onready var message_label: Label = $HUD/StatusPanel/VBox/Message
@onready var hotspot_label: Label = $HUD/HotspotLabel
@onready var global_overlay: ApocalypseGlobalOverlay = $GlobalOverlay


func _ready() -> void:
	for child in map_hotspots.get_children():
		var hotspot := child as Button
		if hotspot == null:
			continue
		var zone_id := StringName(hotspot.get_meta("zone_id", ""))
		if not HOTSPOT_ZONE_IDS.has(zone_id):
			push_error("Unknown house-interior hotspot zone_id: %s" % zone_id)
			hotspot.disabled = true
			continue
		hotspot.pressed.connect(_on_hotspot_pressed.bind(zone_id))
		hotspot.mouse_entered.connect(_show_hotspot_label.bind(String(hotspot.get_meta("zone_label", hotspot.tooltip_text))))
		hotspot.mouse_exited.connect(_hide_hotspot_label)
	hotspot_label.visible = false
	_refresh_status("主屋内的设施已就绪。")
	print("APOCALYPSE_HOUSE_INTERIOR_READY hotspots=%d avatar=false" % map_hotspots.get_child_count())


func _unhandled_input(event: InputEvent) -> void:
	if global_overlay.handle_input_event(event):
		get_viewport().set_input_as_handled()
		return


func _on_hotspot_pressed(zone_id: StringName) -> void:
	if zone_id == &"exit":
		_return_to_shelter()
		return
	var session: Variant = _get_session()
	var result: Dictionary = {}
	match zone_id:
		&"bed":
			result = session.rest_at_shelter()
		&"medical_corner":
			result = session.treat_at_home_medical_station()
		&"indoor_workbench":
			result = session.craft_simple_lockpick()
		&"emergency_power":
			result = session.refuel_home_generator()
		_:
			return
	var saved_suffix := ""
	if bool(result.get("ok", false)) or zone_id == &"bed":
		var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
		var save_result: Dictionary = apocalypse_run.save_active_session()
		saved_suffix = " 已自动保存。" if bool(save_result.get("ok", false)) else " 自动保存失败。"
	if bool(result.get("event_pending", false)):
		get_tree().change_scene_to_file(SHELTER_SCENE_PATH)
		return
	_refresh_status("%s%s" % [String(result.get("message", "设施没有变化。")), saved_suffix])


func _refresh_status(message: String) -> void:
	var session: Variant = _get_session()
	status_label.text = "主屋 · 第 %d 日 %s\n电力 %d/100 · 床铺、医疗、炉火、工作台" % [
		session.get_day(),
		session.get_clock_text(),
		session.get_home_power(),
	]
	message_label.text = message


func _get_session() -> Variant:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	return apocalypse_run.ensure_active_session()


func _return_to_shelter() -> void:
	get_tree().change_scene_to_file(SHELTER_SCENE_PATH)


func _show_hotspot_label(label_text: String) -> void:
	hotspot_label.text = label_text
	hotspot_label.visible = true


func _hide_hotspot_label() -> void:
	hotspot_label.visible = false
