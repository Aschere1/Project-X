extends Control

const SEARCH_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/search_container.gd")
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const BACKPACK_ID := &"backpack"
const CLINIC_LOCATION_ID := &"village_clinic"
const CLINIC_LOCATION_TYPE := &"fixed"
const CLINIC_LOCKBOX_ID := &"clinic_locked_cabinet"
const CLINIC_LOCKBOX_LOCK_ID := &"clinic_locked_cabinet"
const CLINIC_LOCKBOX_UNLOCK_MINUTES := 5
const REGION_MAP_SCENE_PATH := "res://scenes/world/apocalypse_region_map.tscn"

signal search_revealed(result: Dictionary)
signal location_exit_requested(save_result: Dictionary)

@export var location_illustration: Texture2D
@export var water_icon: Texture2D
@export var medkit_icon: Texture2D
@export var bandage_icon: Texture2D

@onready var location_title: Label = %LocationTitle
@onready var search_panel: PanelContainer = %SearchPanel
@onready var hotspot_grid: GridContainer = %HotspotGrid
@onready var loadout_row: HBoxContainer = %LoadoutRow
@onready var location_illustration_view: TextureRect = $Margin/RootVBox/Body/ScenePanel/SceneVBox/SceneArt/ArtStack/LocationIllustration
@onready var art_stack: VBoxContainer = $Margin/RootVBox/Body/ScenePanel/SceneVBox/SceneArt/ArtStack
@onready var medicine_cabinet: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MedicineCabinet
@onready var front_desk: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/FrontDesk
@onready var clinic_lockbox: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/ClinicLockbox
@onready var ambulance: Button = $Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/Ambulance
@onready var search_title: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchTitle
@onready var search_state: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState
@onready var search_action: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction
@onready var exit_button: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit
@onready var noise_label: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/Noise
@onready var search_log: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchLog
@onready var found_loot_title: Label = $Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootTitle
@onready var found_loot_list: VBoxContainer = $Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootList
@onready var take_all_button: Button = $Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll
@onready var clock_label: Label = $Margin/RootVBox/Header/HeaderRow/Clock
@onready var threat_label: Label = $Margin/RootVBox/Header/HeaderRow/Threat
@onready var loadout_title: Label = $Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutTitle
@onready var backpack_label: Label = $Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Label
@onready var backpack_grid: GridContainer = $Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Grid
@onready var global_overlay: Variant = $GlobalOverlay

var _search_container: Variant
var _search_containers: Dictionary = {}
var _search_item_ids_by_container: Dictionary = {}
var _session: Variant
var _search_item_ids: Array[StringName] = [&"medkit_1", &"bandage_1"]
var _selected_hotspot := &"药柜"
var _selected_container_id := &"clinic_medicine_cabinet"
var _location_exited := false
var _danger_search_confirmation_pending := false

func _ready() -> void:
	assert(location_title.text == "县郊 · 村卫生室", "The exploration review keeps the authored location title.")
	assert(search_panel != null, "The exploration review keeps the search panel seam.")
	assert(hotspot_grid.columns == 2, "Location hotspots use an authored two-column grid.")
	assert(loadout_row.get_child_count() == 4, "The loadout review exposes four equipment containers.")
	_apply_location_illustration()
	_setup_review_session()
	_setup_review_search()
	medicine_cabinet.pressed.connect(_on_medicine_cabinet_pressed)
	front_desk.pressed.connect(_on_front_desk_pressed)
	clinic_lockbox.pressed.connect(_on_clinic_lockbox_pressed)
	ambulance.pressed.connect(_on_ambulance_pressed)
	search_action.pressed.connect(_on_search_action_pressed)
	take_all_button.pressed.connect(_on_take_all_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	global_overlay.inventory_changed.connect(_on_overlay_inventory_changed)
	_refresh_search_ui()
	_refresh_loadout_ui()
	_refresh_session_ui()
	print("APOCALYPSE_EXPLORE_REVIEW_READY hotspots=%d loadout_containers=%d" % [hotspot_grid.get_child_count(), loadout_row.get_child_count()])

func _apply_location_illustration() -> void:
	if location_illustration == null:
		location_illustration_view.visible = false
		return
	location_illustration_view.texture = location_illustration
	location_illustration_view.visible = true
	for child in art_stack.get_children():
		if child != location_illustration_view:
			child.visible = false

func _setup_review_search() -> void:
	_register_search_container(&"clinic_medicine_cabinet", _create_medicine_container(), [&"medkit_1", &"bandage_1", &"scrap_metal_1"])
	_register_search_container(&"clinic_front_desk", _create_front_desk_container(), [&"wire_1", &"clinic_key_1"])
	_register_search_container(CLINIC_LOCKBOX_ID, _create_locked_cabinet_container(), [&"medkit_lockbox_1", &"bandage_lockbox_1", &"crowbar_lockbox_1"])
	_register_search_container(&"clinic_ambulance", _create_ambulance_container(), [&"fuel_can_1"])
	_select_search_container(&"clinic_medicine_cabinet", "药柜 · 容器", "物品：标准单格\n类别：未知\n取舍：搜索后才显露物品")
	if not _has_backpack_item(&"water_1"):
		_session.place_item_in_container(BACKPACK_ID, &"water_1", &"water", 1, 1, 5, true, 3)

func _create_medicine_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(&"clinic_medicine_cabinet", 4, 3)
	container.add_hidden_item(&"medkit_1", &"medkit", 1, 1, 4, 8, 2, 3, &"医疗")
	container.add_hidden_item(&"bandage_1", &"bandage", 1, 1, 1, 3, 1, 1, &"医疗")
	container.add_hidden_item(&"scrap_metal_1", &"scrap_metal", 1, 1, 1, 2, 0, 1, &"材料")
	return container

func _create_front_desk_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(&"clinic_front_desk", 3, 2)
	container.add_hidden_item(&"wire_1", &"wire", 1, 1, 1, 3, 0, 1, &"材料")
	container.add_hidden_item(&"clinic_key_1", &"clinic_key", 1, 1, 1, 4, 1, 2, &"工具")
	return container

func _create_locked_cabinet_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(CLINIC_LOCKBOX_ID, 3, 2)
	container.add_hidden_item(&"medkit_lockbox_1", &"medkit", 1, 1, 4, 6, 1, 2, &"医疗")
	container.add_hidden_item(&"bandage_lockbox_1", &"bandage", 1, 1, 1, 3, 0, 1, &"医疗")
	container.add_hidden_item(&"crowbar_lockbox_1", &"crowbar", 1, 1, 3, 5, 1, 2, &"武器")
	return container

func _create_ambulance_container() -> ApocalypseSearchContainer:
	var container := SEARCH_CONTAINER_SCRIPT.new(&"clinic_ambulance", 4, 2)
	container.add_hidden_item(&"fuel_can_1", &"fuel_can", 1, 1, 6, 10, 3, 2, &"燃料")
	return container

func _register_search_container(container_id: StringName, container: Variant, item_ids: Array[StringName]) -> void:
	var saved_snapshot: Dictionary = _session.get_location_search_container_snapshot(CLINIC_LOCATION_ID, container_id)
	if not saved_snapshot.is_empty():
		assert(container.restore_snapshot(saved_snapshot), "A saved clinic search container must restore cleanly.")
	_search_containers[container_id] = container
	_search_item_ids_by_container[container_id] = item_ids

func _select_search_container(container_id: StringName, title: String, log_text: String) -> void:
	_danger_search_confirmation_pending = false
	_selected_container_id = container_id
	_search_container = _search_containers[container_id]
	_search_item_ids = _search_item_ids_by_container[container_id]
	search_title.text = title
	search_log.text = log_text
	_refresh_search_ui()

func _setup_review_session() -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	_session = apocalypse_run.ensure_active_session()
	_session.discover_location(CLINIC_LOCATION_ID, CLINIC_LOCATION_TYPE)

func _on_medicine_cabinet_pressed() -> void:
	_selected_hotspot = &"药柜"
	_select_search_container(&"clinic_medicine_cabinet", "药柜 · 容器", "轮廓：2×1 + 1×1\n类别：未知\n取舍：搜索后才显露物品")

func _on_front_desk_pressed() -> void:
	_selected_hotspot = &"前台"
	_select_search_container(&"clinic_front_desk", "前台 · 容器", "轮廓：1×1\n类别：未知\n抽屉里可能还留着钥匙")

func _on_ambulance_pressed() -> void:
	_selected_hotspot = &"救护车"
	_select_search_container(&"clinic_ambulance", "救护车 · 容器", "轮廓：2×1\n类别：未知\n车厢后部有沉重的金属声")

func _on_clinic_lockbox_pressed() -> void:
	_selected_hotspot = &"锁柜"
	_select_search_container(CLINIC_LOCKBOX_ID, "锁柜 · 需要钥匙或开锁工具", "金属锁柜藏在诊室角落。诊所钥匙可重复使用；简易开锁工具也能打开它，但会消耗。")

func _on_other_hotspot_pressed(hotspot_name: String) -> void:
	_danger_search_confirmation_pending = false
	_selected_hotspot = StringName(hotspot_name)
	search_title.text = "%s · 暂不可搜索" % hotspot_name
	search_state.text = "已记录 · 等待进一步调查"
	search_action.disabled = true
	noise_label.text = "噪声 +0 · 当前热点未产生噪声"
	search_log.text = "这里先作为固定地点的叙事入口。\n后续可由剧情或工具解锁。"

func _on_search_action_pressed() -> void:
	if _location_exited:
		return
	if _selected_hotspot == &"锁柜" and not _session.is_location_lock_unlocked(CLINIC_LOCATION_ID, CLINIC_LOCKBOX_LOCK_ID):
		_unlock_selected_lockbox()
		return
	var next_item_id := _get_next_hidden_item_id()
	if next_item_id == &"":
		_refresh_search_ui()
		return
	if _session.is_location_search_dangerous(CLINIC_LOCATION_ID) and not _danger_search_confirmation_pending:
		_danger_search_confirmation_pending = true
		search_log.text = "危险搜索：地点累计噪声已达到 +%d。再次点击“危险搜索”才会继续，并承担后续风险。" % _session.get_location_search_noise(CLINIC_LOCATION_ID)
		_refresh_search_ui()
		return
	_danger_search_confirmation_pending = false
	var next_item: Dictionary = _search_container.get_item_snapshot(next_item_id)
	var action_minutes := int(next_item.get("search_minutes", 0))
	var stamina_cost := 2 if action_minutes >= 8 else 1
	if not _session.spend_action(action_minutes, stamina_cost):
		search_log.text = "体力不足：无法继续搜索"
		return
	var result: Dictionary = _search_container.search_item(next_item_id)
	if not bool(result.get("ok", false)):
		search_log.text = "搜索失败：%s" % String(result.get("message", "未知原因"))
		return
	search_revealed.emit(result)
	var risk_result: Dictionary = _session.record_location_search_noise(CLINIC_LOCATION_ID, int(result["noise_generated"]))
	assert(bool(risk_result.get("ok", false)), "A revealed clinic item must record its location noise.")
	var rarity_name := _rarity_name(int(result["rarity_tier"]))
	search_log.text = "发现：%s\n稀有度：%s · 类别：%s\n耗时 %d 分钟 · 噪声 +%d\n%s\n已留在容器，可选择带走。" % [
		ITEM_CATALOG_SCRIPT.get_display_name(StringName(result["item_id"])),
		rarity_name,
		String(result["category"]),
		int(result["minutes_spent"]),
		int(result["noise_generated"]),
		String(risk_result.get("message", "")),
	]
	_persist_selected_search_container()
	_refresh_search_ui()
	_refresh_loadout_ui()
	_refresh_session_ui()

func _on_exit_pressed() -> void:
	if _location_exited:
		return
	_location_exited = true
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	location_exit_requested.emit(save_result)
	get_tree().change_scene_to_file(REGION_MAP_SCENE_PATH)

func _unlock_selected_lockbox() -> void:
	var unlock_option := _get_lockbox_unlock_option()
	if unlock_option.is_empty():
		search_log.text = "背包中没有诊所钥匙或简易开锁工具。"
		_refresh_search_ui()
		return
	var result: Dictionary = _session.unlock_location_lock_with_item(
		CLINIC_LOCATION_ID,
		CLINIC_LOCKBOX_LOCK_ID,
		StringName(unlock_option["item_id"]),
		int(unlock_option["minutes"]),
		bool(unlock_option["consume_item"]),
	)
	if not bool(result.get("ok", false)):
		search_log.text = String(result.get("message", "锁柜未解锁。"))
		_refresh_search_ui()
		return
	search_log.text = "%s\n锁柜内还有物资可搜索。" % String(result.get("message", "锁柜已解锁。"))
	_refresh_search_ui()
	_refresh_session_ui()

func _get_lockbox_unlock_option() -> Dictionary:
	if _has_backpack_item_type(&"clinic_key"):
		return {"item_id": &"clinic_key", "minutes": CLINIC_LOCKBOX_UNLOCK_MINUTES, "consume_item": false}
	if _has_backpack_item_type(&"simple_lockpick"):
		return {"item_id": &"simple_lockpick", "minutes": 10, "consume_item": true}
	return {}

func _on_take_all_pressed() -> void:
	var item_ids: Array[StringName] = _search_container.get_revealed_uncollected_item_ids()
	if item_ids.is_empty():
		return
	var taken_count := 0
	for instance_id in item_ids:
		if _take_revealed_item(instance_id):
			taken_count += 1
	var remaining_count: int = _search_container.get_revealed_uncollected_item_ids().size()
	search_log.text = "已放入背包 %d 件%s。" % [taken_count, "；剩余 %d 件等待选择" % remaining_count if remaining_count > 0 else ""]
	_refresh_search_ui()
	_refresh_loadout_ui()

func _take_revealed_item(instance_id: StringName) -> bool:
	var item: Dictionary = _search_container.get_item_snapshot(instance_id)
	if item.is_empty() or bool(item.get("collected", false)):
		return false
	var carried: bool = bool(_session.place_item_in_container(
		BACKPACK_ID,
		instance_id,
		StringName(item["item_id"]),
		int(item["width"]),
		int(item["height"]),
		int(item["weight"]),
		true,
	))
	if not carried:
		return false
	var collection_result: Dictionary = _search_container.collect_revealed_item(instance_id)
	assert(bool(collection_result.get("ok", false)), "A successfully carried revealed item must mark as collected.")
	_persist_selected_search_container()
	return true

func _create_take_loot_button(instance_id: StringName, item: Dictionary) -> Button:
	var item_id := StringName(item["item_id"])
	var button := Button.new()
	button.name = "Take_%s" % instance_id
	button.custom_minimum_size = Vector2(0, 16)
	button.text = "放入背包 · %s · 负重 %d" % [ITEM_CATALOG_SCRIPT.get_display_name(item_id), int(item["weight"])]
	button.pressed.connect(_on_take_one_pressed.bind(instance_id))
	return button

func _on_take_one_pressed(instance_id: StringName) -> void:
	if _take_revealed_item(instance_id):
		search_log.text = "已放入背包：%s" % ITEM_CATALOG_SCRIPT.get_display_name(StringName(_search_container.get_item_snapshot(instance_id).get("item_id", "")))
	else:
		search_log.text = "背包空间不足：物资仍留在容器。"
	_refresh_search_ui()
	_refresh_loadout_ui()

func _unhandled_input(event: InputEvent) -> void:
	if global_overlay.handle_input_event(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_on_exit_pressed()
		get_viewport().set_input_as_handled()

func _on_overlay_inventory_changed() -> void:
	_refresh_loadout_ui()
	_refresh_session_ui()

func _refresh_session_ui() -> void:
	clock_label.text = "第 %d 日 · %s" % [_session.get_day(), _session.get_clock_text()]
	threat_label.text = "威胁 %d · 体力 %d" % [_session.get_region_threat(&"county_edge"), _session.get_stamina()]

func _persist_selected_search_container() -> void:
	if _search_container == null:
		return
	var persisted: bool = _session.store_location_search_container_snapshot(
		CLINIC_LOCATION_ID,
		_selected_container_id,
		_search_container.to_snapshot(),
	)
	assert(persisted, "A clinic search container must persist into the apocalypse session.")

func _has_backpack_item(instance_id: StringName) -> bool:
	for item in _session.get_container_items(BACKPACK_ID):
		if StringName(item.get("instance_id", "")) == instance_id:
			return true
	return false

func _has_backpack_item_type(item_id: StringName) -> bool:
	for item in _session.get_container_items(BACKPACK_ID):
		if StringName(item.get("item_id", "")) == item_id and int(item.get("quantity", 0)) > 0:
			return true
	return false

func _refresh_loadout_ui() -> void:
	var weight: int = _session.get_container_total_weight(BACKPACK_ID)
	var maximum_weight: int = _session.get_container_maximum_weight(BACKPACK_ID)
	backpack_label.text = "背包 · %d/%d" % [weight, maximum_weight]
	loadout_title.text = "装备与携带物 · 口袋始终可用 · 总负重 %d/%d" % [weight, maximum_weight]
	for slot in backpack_grid.get_children():
		slot.self_modulate = Color.WHITE
		slot.tooltip_text = "空格"
		var icon_view: TextureRect = slot.get_node_or_null("Icon") as TextureRect
		var fallback_label: Label = slot.get_node_or_null("Fallback") as Label
		if icon_view != null:
			icon_view.visible = false
		if fallback_label != null:
			fallback_label.text = ""
	for item in _session.get_container_items(BACKPACK_ID):
		var item_name := String(item["item_id"])
		var item_weight := int(item["weight"])
		var quantity := int(item.get("quantity", 1))
		for y in range(int(item["height"])):
			for x in range(int(item["width"])):
				var slot_index: int = (int(item["y"]) + y) * 6 + int(item["x"]) + x
				if slot_index < 0 or slot_index >= backpack_grid.get_child_count():
					continue
				var slot: Control = backpack_grid.get_child(slot_index) as Control
				slot.self_modulate = _item_slot_color(item_name)
				slot.tooltip_text = "%s · %d/%d · 单件负重 %d" % [item_name, quantity, int(item.get("maximum_stack", 16)), item_weight]
				if x == 0 and y == 0:
					_set_slot_icon(slot, item_name, quantity)

func _set_slot_icon(slot: Control, item_name: String, quantity: int) -> void:
	var icon_view: TextureRect = slot.get_node_or_null("Icon") as TextureRect
	var fallback_label: Label = slot.get_node_or_null("Fallback") as Label
	var icon := _icon_for_item(item_name)
	if icon_view != null and icon != null:
		icon_view.texture = icon
		icon_view.visible = true
		if fallback_label != null:
			fallback_label.visible = quantity > 1
			fallback_label.text = "×%d" % quantity if quantity > 1 else ""
			fallback_label.add_theme_font_size_override("font_size", 6)
		return
	if fallback_label != null:
		fallback_label.visible = true
		fallback_label.text = "×%d" % quantity if quantity > 1 else "◆"
		fallback_label.add_theme_font_size_override("font_size", 6)

func _icon_for_item(item_name: String) -> Texture2D:
	match item_name:
		"water":
			return water_icon
		"medkit":
			return medkit_icon
		"bandage":
			return bandage_icon
		_:
			return null

func _item_slot_color(item_name: String) -> Color:
	match item_name:
		"water":
			return Color(0.34, 0.63, 0.78, 1.0)
		"medkit":
			return Color(0.78, 0.42, 0.36, 1.0)
		"bandage":
			return Color(0.78, 0.68, 0.40, 1.0)
		_:
			return Color(0.55, 0.66, 0.59, 1.0)

func _get_next_hidden_item_id() -> StringName:
	for item_id in _search_item_ids:
		var item: Dictionary = _search_container.get_item_snapshot(item_id)
		if not item.is_empty() and not bool(item.get("revealed", false)):
			return item_id
	return &""

func _refresh_search_ui() -> void:
	_refresh_found_loot_ui()
	if _selected_hotspot == &"锁柜" and not _session.is_location_lock_unlocked(CLINIC_LOCATION_ID, CLINIC_LOCKBOX_LOCK_ID):
		var unlock_option := _get_lockbox_unlock_option()
		search_state.text = "锁定 · 需要钥匙或开锁工具"
		if unlock_option.is_empty():
			noise_label.text = "诊所钥匙可重复使用；开锁工具会消耗"
			search_action.text = "需要钥匙或开锁工具"
			search_action.disabled = true
			return
		var unlock_item_id := StringName(unlock_option["item_id"])
		var consumption_text := "会消耗" if bool(unlock_option["consume_item"]) else "不消耗"
		noise_label.text = "解锁耗时 %d 分钟 · %s" % [int(unlock_option["minutes"]), consumption_text]
		search_action.text = "使用%s解锁 · %d 分钟" % [ITEM_CATALOG_SCRIPT.get_display_name(unlock_item_id), int(unlock_option["minutes"])]
		search_action.disabled = false
		return
	var next_item_id := _get_next_hidden_item_id()
	var total_items := _search_item_ids.size()
	var revealed_items := total_items
	if next_item_id != &"":
		revealed_items = 0
		for item_id in _search_item_ids:
			var item: Dictionary = _search_container.get_item_snapshot(item_id)
			if bool(item.get("revealed", false)):
				revealed_items += 1
	search_state.text = "%s · 已显露 %d/%d" % [_state_name(_search_container.get_state()), revealed_items, total_items]
	noise_label.text = "地点噪声 +%d · 容器 +%d · 搜索 %d 分钟" % [
		_session.get_location_search_noise(CLINIC_LOCATION_ID),
		_search_container.get_total_noise(),
		_search_container.get_total_search_minutes(),
	]
	search_action.disabled = next_item_id == &""
	if next_item_id == &"":
		search_action.text = "搜索完成 · 检查物资"
		return
	var next_item: Dictionary = _search_container.get_item_snapshot(next_item_id)
	if _danger_search_confirmation_pending:
		search_action.text = "危险搜索 · 再点击确认 · %d 分钟" % int(next_item.get("search_minutes", 0))
	else:
		search_action.text = "搜索下一件 · %d 分钟" % int(next_item.get("search_minutes", 0))

func _refresh_found_loot_ui() -> void:
	for child in found_loot_list.get_children():
		found_loot_list.remove_child(child)
		child.queue_free()
	if _search_container == null:
		found_loot_title.text = "已发现物资 · 0"
		take_all_button.disabled = true
		return
	var item_ids: Array[StringName] = _search_container.get_revealed_uncollected_item_ids()
	found_loot_title.text = "已发现物资 · %d" % item_ids.size()
	take_all_button.disabled = item_ids.is_empty()
	for instance_id in item_ids:
		var item: Dictionary = _search_container.get_item_snapshot(instance_id)
		found_loot_list.add_child(_create_take_loot_button(instance_id, item))

func _state_name(state: StringName) -> String:
	match state:
		SEARCH_CONTAINER_SCRIPT.STATE_UNSEARCHED:
			return "未搜索"
		SEARCH_CONTAINER_SCRIPT.STATE_SEARCHED:
			return "搜索完成"
		_:
			return "部分搜索"

func _rarity_name(rarity_tier: int) -> String:
	match rarity_tier:
		3:
			return "稀有"
		2:
			return "少见"
		1:
			return "常见"
		_:
			return "普通"
