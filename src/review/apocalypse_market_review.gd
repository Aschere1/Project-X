extends Control

const SEARCH_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/search_container.gd")
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const LOCATION_ID := &"county_market"
const LOCATION_TYPE := &"fixed"
const BACKPACK_ID := &"backpack"
const REGION_MAP_SCENE_PATH := "res://scenes/world/apocalypse_region_map.tscn"

@onready var location_title: Label = $Margin/RootVBox/Header/HeaderRow/LocationTitle
@onready var clock_label: Label = $Margin/RootVBox/Header/HeaderRow/Clock
@onready var threat_label: Label = $Margin/RootVBox/Header/HeaderRow/Threat
@onready var search_title: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchTitle
@onready var search_state: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState
@onready var search_action: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction
@onready var search_log: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchLog
@onready var noise_label: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/Noise
@onready var found_loot_title: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootTitle
@onready var found_loot_list: VBoxContainer = $Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootList
@onready var take_all_button: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll
@onready var exit_button: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit
@onready var loadout_title: Label = $Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutTitle
@onready var counter_button: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MarketCounter
@onready var storeroom_button: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MarketStoreroom
@onready var global_overlay: Variant = $GlobalOverlay

var _session: Variant
var _containers: Dictionary = {}
var _item_ids_by_container: Dictionary = {}
var _selected_container_id: StringName = &"market_counter"
var _search_container: Variant
var _search_item_ids: Array[StringName] = []
var _location_exited := false

func _ready() -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	_session = apocalypse_run.ensure_active_session()
	_session.discover_location(LOCATION_ID, LOCATION_TYPE)
	_register_container(&"market_counter", _create_counter_container(), [&"water_market_1", &"wire_market_1"])
	_register_container(&"market_storeroom", _create_storeroom_container(), [&"fuel_market_1", &"crowbar_market_1"])
	counter_button.pressed.connect(_on_counter_pressed)
	storeroom_button.pressed.connect(_on_storeroom_pressed)
	search_action.pressed.connect(_on_search_pressed)
	take_all_button.pressed.connect(_on_take_all_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	_select_container(&"market_counter", "柜台 · 容器", "轮廓：收银台下的生活物资\n类别：食品与材料\n取舍：先搜索，再决定是否带走")
	_refresh_all()
	print("APOCALYPSE_MARKET_REVIEW_READY hotspots=%d" % $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid.get_child_count())

func _register_container(container_id: StringName, container: Variant, item_ids: Array[StringName]) -> void:
	var saved_snapshot: Dictionary = _session.get_location_search_container_snapshot(LOCATION_ID, container_id)
	if not saved_snapshot.is_empty():
		assert(container.restore_snapshot(saved_snapshot), "A saved market search container must restore cleanly.")
	_containers[container_id] = container
	_item_ids_by_container[container_id] = item_ids

func _create_counter_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(&"market_counter", 3, 2)
	container.add_hidden_item(&"water_market_1", &"water", 1, 1, 5, 4, 1, 1, &"食物")
	container.add_hidden_item(&"wire_market_1", &"wire", 1, 1, 1, 5, 1, 1, &"材料")
	return container

func _create_storeroom_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(&"market_storeroom", 3, 2)
	container.add_hidden_item(&"fuel_market_1", &"fuel_can", 1, 1, 6, 8, 2, 2, &"燃料")
	container.add_hidden_item(&"crowbar_market_1", &"crowbar", 1, 1, 3, 10, 4, 2, &"武器")
	return container

func _select_container(container_id: StringName, title: String, log_text: String) -> void:
	_selected_container_id = container_id
	_search_container = _containers[container_id]
	_search_item_ids = _item_ids_by_container[container_id]
	search_title.text = title
	search_log.text = log_text
	_refresh_search_ui()

func _on_counter_pressed() -> void:
	_select_container(&"market_counter", "柜台 · 容器", "收银台下的纸箱仍然封着。\n先搜索可见物资，再决定是否带走。")

func _on_storeroom_pressed() -> void:
	_select_container(&"market_storeroom", "后仓 · 容器", "后仓门没有完全关上。\n燃料和工具可能还在货架深处。")

func _on_search_pressed() -> void:
	var next_item_id := _get_next_hidden_item_id()
	if next_item_id == &"":
		return
	var next_item: Dictionary = _search_container.get_item_snapshot(next_item_id)
	var minutes := int(next_item.get("search_minutes", 0))
	if not _session.spend_action(minutes, 1 if minutes < 8 else 2):
		search_log.text = "体力不足，无法继续搜索。"
		return
	var result: Dictionary = _search_container.search_item(next_item_id)
	if not bool(result.get("ok", false)):
		search_log.text = String(result.get("message", "搜索失败。"))
		return
	_session.record_location_search_noise(LOCATION_ID, int(result.get("noise_generated", 0)))
	search_log.text = "发现：%s\n耗时 %d 分钟 · 噪声 +%d\n物资仍留在容器中，可选择带走。" % [
		ITEM_CATALOG_SCRIPT.get_display_name(StringName(result["item_id"])),
		int(result["minutes_spent"]),
		int(result["noise_generated"]),
	]
	_persist_container()
	_refresh_all()

func _on_take_all_pressed() -> void:
	for instance_id in _search_container.get_revealed_uncollected_item_ids():
		_take_item(instance_id)
	_refresh_all()

func _take_item(instance_id: StringName) -> bool:
	var item: Dictionary = _search_container.get_item_snapshot(instance_id)
	if item.is_empty() or bool(item.get("collected", false)):
		return false
	if not _session.place_item_in_container(BACKPACK_ID, instance_id, StringName(item["item_id"]), int(item["width"]), int(item["height"]), int(item["weight"]), true):
		return false
	var result: Dictionary = _search_container.collect_revealed_item(instance_id)
	if bool(result.get("ok", false)):
		_persist_container()
		return true
	return false

func _persist_container() -> void:
	assert(_session.store_location_search_container_snapshot(LOCATION_ID, _selected_container_id, _search_container.to_snapshot()), "A market search container must persist.")

func _get_next_hidden_item_id() -> StringName:
	for instance_id in _search_item_ids:
		var item: Dictionary = _search_container.get_item_snapshot(instance_id)
		if not item.is_empty() and not bool(item.get("revealed", false)):
			return instance_id
	return &""

func _refresh_all() -> void:
	_refresh_search_ui()
	_refresh_loadout_ui()
	_refresh_session_ui()

func _refresh_search_ui() -> void:
	var next_item_id := _get_next_hidden_item_id()
	var revealed_count := 0
	for instance_id in _search_item_ids:
		if bool(_search_container.get_item_snapshot(instance_id).get("revealed", false)):
			revealed_count += 1
	search_state.text = "%s · 已显露 %d/%d" % ["搜索完成" if next_item_id == &"" else ("未搜索" if revealed_count == 0 else "部分搜索"), revealed_count, _search_item_ids.size()]
	noise_label.text = "地点噪声 +%d · 容器 +%d · 搜索 %d 分钟" % [_session.get_location_search_noise(LOCATION_ID), _search_container.get_total_noise(), _search_container.get_total_search_minutes()]
	search_action.disabled = next_item_id == &""
	search_action.text = "搜索完成" if next_item_id == &"" else "搜索下一件 · %d 分钟" % int(_search_container.get_item_snapshot(next_item_id).get("search_minutes", 0))
	for child in found_loot_list.get_children():
		found_loot_list.remove_child(child)
		child.queue_free()
	var loot_ids: Array[StringName] = _search_container.get_revealed_uncollected_item_ids()
	found_loot_title.text = "已发现物资 · %d" % loot_ids.size()
	take_all_button.disabled = loot_ids.is_empty()
	for instance_id in loot_ids:
		var item: Dictionary = _search_container.get_item_snapshot(instance_id)
		var take_button := Button.new()
		take_button.name = "Take_%s" % instance_id
		take_button.text = "放入背包 · %s · 负重 %d" % [ITEM_CATALOG_SCRIPT.get_display_name(StringName(item["item_id"])), int(item["weight"])]
		take_button.custom_minimum_size = Vector2(0, 16)
		take_button.pressed.connect(_on_take_one_pressed.bind(instance_id))
		found_loot_list.add_child(take_button)

func _on_take_one_pressed(instance_id: StringName) -> void:
	if not _take_item(instance_id):
		search_log.text = "背包空间不足，物资仍留在容器中。"
	else:
		search_log.text = "已将物资放入背包。"
	_refresh_all()

func _refresh_loadout_ui() -> void:
	loadout_title.text = "携带物资 · 背包负重 %d/%d · B 查看背包" % [_session.get_container_total_weight(BACKPACK_ID), _session.get_container_maximum_weight(BACKPACK_ID)]

func _refresh_session_ui() -> void:
	clock_label.text = "第 %d 日 · %s" % [_session.get_day(), _session.get_clock_text()]
	threat_label.text = "威胁 %d · 体力 %d" % [_session.get_region_threat(&"county_edge"), _session.get_stamina()]

func _on_exit_pressed() -> void:
	if _location_exited:
		return
	_location_exited = true
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	apocalypse_run.save_active_session()
	get_tree().change_scene_to_file(REGION_MAP_SCENE_PATH)

func _unhandled_input(event: InputEvent) -> void:
	if global_overlay.handle_input_event(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_on_exit_pressed()
		get_viewport().set_input_as_handled()
