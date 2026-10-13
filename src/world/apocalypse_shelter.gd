extends Node2D

@export var shelter_illustration: Texture2D
@export var status_hunger: Texture2D
@export var status_thirst: Texture2D
@export var status_injury: Texture2D
@export var status_infection: Texture2D
@export var status_noise_warning: Texture2D
@export var status_time_warning: Texture2D

const HOTSPOT_ZONE_IDS: Array[StringName] = [&"main_house", &"chicken_coop", &"livestock_pens", &"storage", &"workbench", &"farm_beds", &"gate"]
const HOUSE_INTERIOR_SCENE_PATH := "res://scenes/world/apocalypse_house_interior.tscn"
const STRESS_WARN_THRESHOLD := 2
const INFECTION_WARN_THRESHOLD := 25
const NOISE_WARN_THRESHOLD := 50
const TIME_WARN_MINUTES := 1080
const STAMINA_LOW_RATIO := 0.2
const STAMINA_MAX := 100
const BACKPACK_ID := &"backpack"
const HOME_STORAGE_ID := &"home_storage"
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const STORAGE_ACTION_TRANSFER_ONE := 1
const STORAGE_ACTION_TRANSFER_STACK := 2
const STORAGE_ACTION_SPLIT_HALF := 3
const STORAGE_ACTION_SPLIT_CUSTOM := 4
const STORAGE_ACTION_INSPECT := 5
const STORAGE_ACTION_USE_ONE := 6
const STORAGE_ACTION_EQUIP_WEAPON := 7
const STORAGE_ACTION_UNEQUIP_WEAPON := 8
const STORAGE_COMPACT_FONT_SIZE := 8
const STORAGE_MENU_WIDTH := 132
const STORAGE_SPLIT_DIALOG_SIZE := Vector2i(172, 82)
const STORAGE_INSPECT_DIALOG_SIZE := Vector2i(184, 104)
const GENERATOR_POWER_MAX := 100

@onready var shelter_view: TextureRect = $Canvas/Background/ShelterIllustration
@onready var shelter_fallback: ColorRect = $Canvas/Background/Fallback
@onready var map_hotspots: Control = $Canvas/MapHotspots
@onready var hotspot_label: Label = $Canvas/HotspotLabel
@onready var feature_modal: Control = $Canvas/FeatureModal
@onready var feature_title: Label = $Canvas/FeatureModal/Panel/VBox/Title
@onready var feature_description: Label = $Canvas/FeatureModal/Panel/VBox/Description
@onready var feature_action_button: Button = $Canvas/FeatureModal/Panel/VBox/FeatureAction
@onready var feature_secondary_action_button: Button = $Canvas/FeatureModal/Panel/VBox/FeatureSecondaryAction
@onready var feature_tertiary_action_button: Button = $Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction
@onready var feature_quaternary_action_button: Button = $Canvas/FeatureModal/Panel/VBox/FeatureQuaternaryAction
@onready var feature_close_button: Button = $Canvas/FeatureModal/Panel/VBox/CloseButton
@onready var campaign_event_modal: Control = $Canvas/CampaignEventModal
@onready var campaign_event_kicker: Label = $Canvas/CampaignEventModal/Panel/VBox/Kicker
@onready var campaign_event_title: Label = $Canvas/CampaignEventModal/Panel/VBox/Title
@onready var campaign_event_description: Label = $Canvas/CampaignEventModal/Panel/VBox/Description
@onready var campaign_event_power_choice: Button = $Canvas/CampaignEventModal/Panel/VBox/PowerChoice
@onready var campaign_event_rooftop_choice: Button = $Canvas/CampaignEventModal/Panel/VBox/RooftopChoice
@onready var campaign_event_result: Label = $Canvas/CampaignEventModal/Panel/VBox/Result
@onready var campaign_event_close_button: Button = $Canvas/CampaignEventModal/Panel/VBox/CloseButton
@onready var storage_modal: Control = $Canvas/StorageModal
@onready var storage_title: Label = $Canvas/StorageModal/Panel/VBox/Title
@onready var storage_hint: Label = $Canvas/StorageModal/Panel/VBox/Hint
@onready var storage_equipment_status: Label = $Canvas/StorageModal/Panel/VBox/EquipmentStatus
@onready var storage_backpack_panel: PanelContainer = $Canvas/StorageModal/Panel/VBox/Columns/BackpackPanel
@onready var storage_backpack_title: Label = $Canvas/StorageModal/Panel/VBox/Columns/BackpackPanel/VBox/Title
@onready var storage_backpack_weight: Label = $Canvas/StorageModal/Panel/VBox/Columns/BackpackPanel/VBox/Weight
@onready var storage_backpack_grid: ApocalypseInventoryGridView = $Canvas/StorageModal/Panel/VBox/Columns/BackpackPanel/VBox/Items
@onready var storage_home_panel: PanelContainer = $Canvas/StorageModal/Panel/VBox/Columns/HomeStoragePanel
@onready var storage_home_weight: Label = $Canvas/StorageModal/Panel/VBox/Columns/HomeStoragePanel/VBox/Weight
@onready var storage_home_grid: ApocalypseInventoryGridView = $Canvas/StorageModal/Panel/VBox/Columns/HomeStoragePanel/VBox/Items
@onready var storage_transfer_status: Label = $Canvas/StorageModal/Panel/VBox/TransferStatus
@onready var storage_close_button: Button = $Canvas/StorageModal/Panel/VBox/CloseButton
@onready var hud_backpack_button: Button = $Canvas/HUD/BackpackButton
@onready var campaign_objective_label: Label = $Canvas/HUD/CampaignObjective/Objective
@onready var system_menu: Control = $Canvas/SystemMenu
@onready var system_menu_status: Label = $Canvas/SystemMenu/Panel/VBox/Status
@onready var system_continue_button: Button = $Canvas/SystemMenu/Panel/VBox/ContinueButton
@onready var system_backpack_button: Button = $Canvas/SystemMenu/Panel/VBox/BackpackButton
@onready var system_save_button: Button = $Canvas/SystemMenu/Panel/VBox/SaveButton
@onready var hp_value_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/HpGroup/HpValue
@onready var fatigue_value_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/FatigueGroup/FatigueValue
@onready var hunger_png_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/HungerPngSlot
@onready var hunger_value_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/HungerValue
@onready var thirst_png_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/ThirstPngSlot
@onready var thirst_value_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/ThirstValue
@onready var stamina_value_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/StaminaGroup/StaminaValue
@onready var warnings_group: HBoxContainer = $Canvas/HUD/BottomStatusBar/BarInner/Warnings
@onready var png_injury_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/PngInjurySlot
@onready var png_infection_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/PngInfectionSlot
@onready var png_noise_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/PngNoiseSlot
@onready var png_time_slot: TextureRect = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/PngTimeSlot
@onready var stress_warn_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/StressWarn
@onready var injury_warn_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/InjuryWarn
@onready var infection_warn_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/InfectionWarn
@onready var noise_warn_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/NoiseWarn
@onready var time_warn_label: Label = $Canvas/HUD/BottomStatusBar/BarInner/Warnings/TimeWarn

var _status_hp := 72
var _status_hunger := 45
var _status_thirst := 38
var _status_fatigue := 0
var _status_stress := 0
var _status_stamina := STAMINA_MAX
var _status_injury_count := 0
var _status_infection_risk := 0
var _status_noise_total := 0
var _status_time_minutes := 360
var _storage_context_menu: PopupMenu
var _storage_split_dialog: ConfirmationDialog
var _storage_split_amount: SpinBox
var _storage_inspect_dialog: AcceptDialog
var _storage_context_container_id: StringName = &""
var _storage_context_instance_id: StringName = &""
var _feature_modal_mode: StringName = &""
var _feature_facility_id: StringName = &""
var _storage_mode: StringName = &"storage"
func _ready() -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	apocalypse_run.ensure_active_session()
	_apply_optional_texture(shelter_view, shelter_fallback, shelter_illustration)
	_wire_hotspots()
	feature_close_button.pressed.connect(_close_feature_modal)
	feature_action_button.pressed.connect(_on_feature_action_pressed)
	feature_secondary_action_button.pressed.connect(_on_feature_secondary_action_pressed)
	feature_tertiary_action_button.pressed.connect(_on_feature_tertiary_action_pressed)
	feature_quaternary_action_button.pressed.connect(_on_feature_quaternary_action_pressed)
	campaign_event_power_choice.pressed.connect(_on_campaign_event_button_pressed.bind(campaign_event_power_choice))
	campaign_event_rooftop_choice.pressed.connect(_on_campaign_event_button_pressed.bind(campaign_event_rooftop_choice))
	campaign_event_close_button.pressed.connect(_close_campaign_event_modal)
	storage_backpack_grid.item_activated.connect(_on_storage_item_activated)
	storage_home_grid.item_activated.connect(_on_storage_item_activated)
	storage_backpack_grid.item_context_requested.connect(_on_storage_item_context_requested)
	storage_home_grid.item_context_requested.connect(_on_storage_item_context_requested)
	storage_backpack_grid.item_drop_requested.connect(_on_storage_item_drop_requested)
	storage_home_grid.item_drop_requested.connect(_on_storage_item_drop_requested)
	storage_close_button.pressed.connect(_close_storage_modal)
	hud_backpack_button.pressed.connect(_open_backpack_modal)
	system_continue_button.pressed.connect(_close_system_menu)
	system_backpack_button.pressed.connect(_open_backpack_from_system_menu)
	system_save_button.pressed.connect(_save_from_system_menu)
	_setup_storage_context_controls()
	_apply_status_icon_slots()
	_refresh_status_ui()
	hotspot_label.visible = false
	feature_modal.visible = false
	storage_modal.visible = false
	system_menu.visible = false
	campaign_event_modal.visible = false
	_show_pending_campaign_event_if_needed()
	print("APOCALYPSE_SHELTER_READY hotspots=%d avatar=false collisions=false" % map_hotspots.get_child_count())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if campaign_event_modal.visible:
			_close_campaign_event_modal()
		elif storage_modal.visible:
			_close_storage_modal()
		elif feature_modal.visible:
			_close_feature_modal()
		elif system_menu.visible:
			_close_system_menu()
		else:
			_open_system_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("open_inventory"):
		if campaign_event_modal.visible or feature_modal.visible or system_menu.visible:
			return
		if storage_modal.visible:
			_close_storage_modal()
		else:
			_open_backpack_modal()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("save_game") and system_menu.visible:
		_save_from_system_menu()
		get_viewport().set_input_as_handled()

func _wire_hotspots() -> void:
	for child in map_hotspots.get_children():
		var hotspot := child as Button
		if hotspot == null:
			continue
		var zone_id := StringName(hotspot.get_meta("zone_id", ""))
		if HOTSPOT_ZONE_IDS.find(zone_id) == -1:
			push_error("Unknown shelter hotspot zone_id: %s" % zone_id)
			hotspot.disabled = true
			continue
		hotspot.pressed.connect(_route_hotspot.bind(zone_id))
		hotspot.mouse_entered.connect(_show_hotspot_label.bind(String(hotspot.get_meta("zone_label", hotspot.tooltip_text))))
		hotspot.mouse_exited.connect(_hide_hotspot_label)

func _route_hotspot(zone_id: StringName) -> void:
	if zone_id == &"gate":
		get_tree().change_scene_to_file("res://scenes/world/apocalypse_region_map.tscn")
		return
	match zone_id:
		&"main_house":
			_open_generator_modal()
		&"chicken_coop", &"livestock_pens":
			_open_shelter_facility_modal(zone_id)
		&"storage":
			_open_storage_modal()
		&"workbench":
			_open_workbench_modal()
		&"farm_beds":
			_open_feature_modal("菜地", "灾变作物的种植、浇水和收获会从这里进入。当前保留入口，后续适配既有农业领域模块。")

func _open_feature_modal(title: String, description: String) -> void:
	_feature_modal_mode = &""
	_feature_facility_id = &""
	feature_title.text = title
	feature_description.text = description
	feature_action_button.visible = false
	feature_secondary_action_button.visible = false
	feature_tertiary_action_button.visible = false
	feature_quaternary_action_button.visible = false
	feature_modal.visible = true
	feature_close_button.grab_focus()

func _open_generator_modal() -> void:
	_feature_modal_mode = &"home_utilities"
	_feature_facility_id = &""
	feature_action_button.visible = true
	feature_secondary_action_button.visible = true
	feature_tertiary_action_button.visible = true
	feature_quaternary_action_button.visible = true
	feature_modal.visible = true
	_refresh_generator_modal()
	if not feature_action_button.disabled:
		feature_action_button.grab_focus()
	else:
		feature_close_button.grab_focus()

func _open_workbench_modal() -> void:
	_feature_modal_mode = &"workbench"
	_feature_facility_id = &""
	feature_action_button.visible = true
	feature_secondary_action_button.visible = false
	feature_tertiary_action_button.visible = false
	feature_quaternary_action_button.visible = false
	feature_modal.visible = true
	_refresh_workbench_modal()
	if not feature_action_button.disabled:
		feature_action_button.grab_focus()
	else:
		feature_close_button.grab_focus()

func _refresh_workbench_modal(status_text: String = "") -> void:
	var session := _get_apocalypse_session()
	var recipe: Dictionary = ITEM_CATALOG_SCRIPT.get_workbench_recipe(&"simple_lockpick")
	var scrap_count: int = session.get_container_item_quantity(HOME_STORAGE_ID, &"scrap_metal")
	var wire_count: int = session.get_container_item_quantity(HOME_STORAGE_ID, &"wire")
	var power: int = session.get_home_power()
	var power_cost: int = int(recipe.get("power_cost", 0))
	var minutes: int = int(recipe.get("minutes", 0))
	feature_title.text = "工作台 · 简易开锁工具"
	feature_description.text = "仓储：废金属 ×%d · 电线 ×%d · 电力 %d/%d\n制作：废金属 ×1 + 电线 ×1 + %d 电力，耗时 %d 分钟。\n成品可替代诊所钥匙撬开锁柜，但使用后会消耗。%s" % [
		scrap_count,
		wire_count,
		power,
		GENERATOR_POWER_MAX,
		power_cost,
		minutes,
		"\n" + status_text if not status_text.is_empty() else "",
	]
	feature_action_button.text = "制作 1 个简易开锁工具"
	feature_action_button.disabled = scrap_count <= 0 or wire_count <= 0 or power < power_cost


func _open_shelter_facility_modal(facility_id: StringName) -> void:
	_feature_modal_mode = &"shelter_facility"
	_feature_facility_id = facility_id
	feature_action_button.visible = true
	feature_secondary_action_button.visible = false
	feature_tertiary_action_button.visible = false
	feature_quaternary_action_button.visible = false
	feature_modal.visible = true
	_refresh_shelter_facility_modal()
	if not feature_action_button.disabled:
		feature_action_button.grab_focus()
	else:
		feature_close_button.grab_focus()


func _refresh_shelter_facility_modal(status_text: String = "") -> void:
	var session := _get_apocalypse_session()
	var facility: Dictionary = session.get_shelter_facility_snapshot(_feature_facility_id)
	if facility.is_empty():
		_open_feature_modal("安全区设施", "设施状态暂不可用。")
		return
	var animal_lines: Array[String] = []
	for animal_value in facility.get("animals", []):
		if animal_value is Dictionary:
			animal_lines.append("%s ×%d" % [String(animal_value.get("label", "动物")), int(animal_value.get("count", 0))])
	var actions: Array = facility.get("actions", [])
	var action: Dictionary = actions[0] if not actions.is_empty() and actions[0] is Dictionary else {}
	feature_title.text = "%s · 安全区设施" % String(facility.get("title", "设施"))
	feature_description.text = "%s\n%s%s%s" % [
		String(facility.get("summary", "")),
		"动物：%s\n" % " · ".join(animal_lines) if not animal_lines.is_empty() else "",
		"状态：%s" % String(facility.get("status_text", "可用")),
		"\n" + status_text if not status_text.is_empty() else "",
	]
	if action.is_empty():
		feature_action_button.visible = false
		return
	feature_action_button.visible = true
	feature_action_button.text = "%s · %d 分钟 · 体力 %d" % [
		String(action.get("label", "维护")),
		int(action.get("minutes", 0)),
		int(action.get("stamina", 0)),
	]
	feature_action_button.disabled = not bool(action.get("available", false))

func _refresh_generator_modal(status_text: String = "") -> void:
	var session := _get_apocalypse_session()
	var fuel_count: int = session.get_container_item_quantity(HOME_STORAGE_ID, &"fuel_can")
	var fuel_power: int = ITEM_CATALOG_SCRIPT.get_generator_power_value(&"fuel_can")
	var medkit_count: int = session.get_container_item_quantity(HOME_STORAGE_ID, &"medkit")
	var power: int = session.get_home_power()
	var survivor: Dictionary = session.get_survivor_snapshot()
	var injuries: Array = survivor.get("injuries", [])
	var infection_risk: int = int(survivor.get("infection_risk", 0))
	var campaign: Dictionary = session.get_campaign_snapshot()
	feature_title.text = "主屋 · 休息 / 家园设施"
	feature_description.text = "第 %d 日 %s · 电力 %d/%d · 燃料 ×%d · 急救包 ×%d\n加注：燃料 +%d 电力，耗时 %d 分钟。\n医疗：急救包 ×1 + 10 电力，处理 1 项创伤、感染风险 -15。\n首袭准备 %d/3；第 4 日清晨结算，完成任意 2 项可守住。%s" % [
		session.get_day(),
		session.get_clock_text(),
		power,
		GENERATOR_POWER_MAX,
		fuel_count,
		medkit_count,
		fuel_power,
		ApocalypseSession.GENERATOR_REFUEL_MINUTES,
		int(campaign.get("score", 0)),
		"\n" + status_text if not status_text.is_empty() else "",
	]
	feature_action_button.text = "加注 1 个燃料罐"
	feature_action_button.disabled = fuel_count <= 0 or power > GENERATOR_POWER_MAX - fuel_power
	feature_secondary_action_button.text = "医疗处理 · 急救包 ×1 + 10 电力"
	feature_secondary_action_button.disabled = power < ApocalypseSession.MEDICAL_STATION_POWER_COST or medkit_count <= 0 or (injuries.is_empty() and infection_risk <= 0)
	feature_tertiary_action_button.text = "休息到次日 06:00"
	feature_tertiary_action_button.disabled = false
	feature_quaternary_action_button.text = "进入主屋室内"
	feature_quaternary_action_button.disabled = false

func _on_feature_action_pressed() -> void:
	var session := _get_apocalypse_session()
	var result: Dictionary = {}
	match _feature_modal_mode:
		&"home_utilities":
			result = session.refuel_home_generator()
		&"workbench":
			result = session.craft_simple_lockpick()
		&"shelter_facility":
			result = session.perform_shelter_facility_action(_feature_facility_id, &"service")
		_:
			return
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session() if bool(result.get("ok", false)) else {}
	var suffix := "已自动保存。" if bool(save_result.get("ok", false)) else ""
	var message := "%s%s" % [String(result.get("message", "操作没有变化。")), suffix]
	if _feature_modal_mode == &"home_utilities":
		_refresh_generator_modal(message)
	elif _feature_modal_mode == &"shelter_facility":
		_refresh_shelter_facility_modal(message)
	else:
		_refresh_workbench_modal(message)
	_refresh_status_ui()

func _on_feature_secondary_action_pressed() -> void:
	if _feature_modal_mode != &"home_utilities":
		return
	var session := _get_apocalypse_session()
	var result: Dictionary = session.treat_at_home_medical_station()
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session() if bool(result.get("ok", false)) else {}
	var suffix := "已自动保存。" if bool(save_result.get("ok", false)) else ""
	_refresh_generator_modal("%s%s" % [String(result.get("message", "医疗台没有变化。")), suffix])
	_refresh_status_ui()

func _on_feature_tertiary_action_pressed() -> void:
	if _feature_modal_mode != &"home_utilities":
		return
	var session := _get_apocalypse_session()
	var result: Dictionary = session.rest_at_shelter()
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	var suffix := " 已自动保存。" if bool(save_result.get("ok", false)) else " 自动保存失败。"
	if bool(result.get("event_pending", false)):
		_close_feature_modal()
		_open_campaign_event(result.get("event", {}))
	elif bool(result.get("raid_resolved", false)):
		var campaign: Dictionary = result.get("campaign", {})
		feature_title.text = "首轮袭击 · %s" % ("守住家园" if StringName(campaign.get("outcome", "")) == &"held" else "受创幸存")
		feature_description.text = "%s%s\n准备明细：电力 %s · 急救包 %s · 武器 %s。" % [
			String(result.get("message", "首轮袭击已结算。")),
			suffix,
			"完成" if bool(campaign.get("power_ready", false)) else "未完成",
			"完成" if bool(campaign.get("medkit_ready", false)) else "未完成",
			"完成" if bool(campaign.get("weapon_ready", false)) else "未完成",
		]
		feature_action_button.visible = false
		feature_secondary_action_button.visible = false
		feature_tertiary_action_button.visible = false
		feature_quaternary_action_button.visible = false
	else:
		_refresh_generator_modal("%s%s" % [String(result.get("message", "休息完成。")), suffix])
	_refresh_status_ui()


func _on_feature_quaternary_action_pressed() -> void:
	if _feature_modal_mode != &"home_utilities":
		return
	get_tree().change_scene_to_file(HOUSE_INTERIOR_SCENE_PATH)


func _show_pending_campaign_event_if_needed() -> void:
	var pending_event: Dictionary = _get_apocalypse_session().get_pending_campaign_event()
	if not pending_event.is_empty():
		_open_campaign_event(pending_event)


func _open_campaign_event(event: Dictionary) -> void:
	if event.is_empty():
		return
	campaign_event_kicker.text = "第 %d 日 · 待处理事件 · 选择前公开全部代价" % int(event.get("day", 5))
	campaign_event_title.text = String(event.get("title", "待处理事件"))
	campaign_event_description.text = String(event.get("description", "必须处理当前事件，才能继续休息。"))
	campaign_event_result.text = ""
	campaign_event_result.visible = false
	campaign_event_close_button.visible = false
	campaign_event_power_choice.visible = true
	campaign_event_rooftop_choice.visible = true
	var choices: Array = event.get("choices", [])
	_configure_campaign_event_choice(campaign_event_power_choice, choices[0] if choices.size() >= 1 else {})
	_configure_campaign_event_choice(campaign_event_rooftop_choice, choices[1] if choices.size() >= 2 else {})
	campaign_event_modal.visible = true
	if not campaign_event_power_choice.disabled:
		campaign_event_power_choice.grab_focus()
	else:
		campaign_event_rooftop_choice.grab_focus()


func _configure_campaign_event_choice(button: Button, choice_value: Variant) -> void:
	button.disabled = true
	button.text = "选项不可用"
	button.set_meta("choice_id", &"")
	if not choice_value is Dictionary:
		button.visible = false
		return
	var choice: Dictionary = choice_value
	var choice_id := StringName(choice.get("choice_id", ""))
	if choice_id == &"":
		button.visible = false
		return
	var available := bool(choice.get("available", false))
	var unavailable_reason := String(choice.get("unavailable_reason", ""))
	button.visible = true
	button.disabled = not available
	button.set_meta("choice_id", choice_id)
	button.text = "%s · %s%s" % [
		String(choice.get("label", "选择")),
		String(choice.get("consequence", "后果未知")),
		" 不可用：%s" % unavailable_reason if not available and not unavailable_reason.is_empty() else "",
	]
	button.tooltip_text = unavailable_reason


func _on_campaign_event_button_pressed(button: Button) -> void:
	_on_campaign_event_choice_pressed(StringName(button.get_meta("choice_id", "")))


func _on_campaign_event_choice_pressed(choice_id: StringName) -> void:
	var result: Dictionary = _get_apocalypse_session().resolve_pending_campaign_event(choice_id)
	if not bool(result.get("ok", false)):
		campaign_event_result.text = String(result.get("message", "事件没有变化。"))
		campaign_event_result.visible = true
		_show_pending_campaign_event_if_needed()
		return
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	var suffix := " 已自动保存。" if bool(save_result.get("ok", false)) else " 自动保存失败。"
	campaign_event_kicker.text = "第 %d 日 · 事件已处理 · 后果已结算" % int(result.get("day", 0))
	campaign_event_power_choice.visible = false
	campaign_event_rooftop_choice.visible = false
	campaign_event_result.text = "%s%s" % [String(result.get("message", "事件已处理。")), suffix]
	campaign_event_result.visible = true
	campaign_event_close_button.visible = true
	campaign_event_close_button.grab_focus()
	_refresh_status_ui()


func _close_campaign_event_modal() -> void:
	if not _get_apocalypse_session().get_pending_campaign_event().is_empty():
		return
	campaign_event_modal.visible = false

func _close_feature_modal() -> void:
	_feature_modal_mode = &""
	_feature_facility_id = &""
	feature_action_button.visible = false
	feature_secondary_action_button.visible = false
	feature_tertiary_action_button.visible = false
	feature_quaternary_action_button.visible = false
	feature_modal.visible = false

func _open_storage_modal() -> void:
	_storage_mode = &"storage"
	_configure_inventory_modal()
	storage_transfer_status.text = "拖动物品可整理或跨栏存取；右键可按数量操作。"
	_refresh_storage_ui()
	storage_modal.visible = true

func _open_backpack_modal() -> void:
	_storage_mode = &"backpack"
	_configure_inventory_modal()
	storage_transfer_status.text = "拖动可整理格子；单击或右键查看，右键还可使用和装备。"
	_refresh_storage_ui()
	storage_modal.visible = true

func _configure_inventory_modal() -> void:
	var is_storage := _storage_mode == &"storage"
	storage_title.text = "储物棚 · 背包与家园仓储" if is_storage else "随身背包与装备"
	storage_hint.text = "普通用品最多叠加 16；拖动整组，右键按数量操作。" if is_storage else "随身物品 · 普通用品最多叠加 16 · 按 B 或 Esc 关闭"
	storage_home_panel.visible = is_storage
	storage_backpack_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	storage_backpack_title.text = "外出背包" if is_storage else "背包 · 拖动整理 / 右键操作"
	storage_close_button.text = "返回家园" if is_storage else "关闭背包"

func _close_storage_modal() -> void:
	if _storage_context_menu != null:
		_storage_context_menu.hide()
	storage_modal.visible = false

func _refresh_storage_ui() -> void:
	var session := _get_apocalypse_session()
	storage_backpack_grid.set_inventory(BACKPACK_ID, session.get_container_snapshot(BACKPACK_ID))
	storage_home_grid.set_inventory(HOME_STORAGE_ID, session.get_container_snapshot(HOME_STORAGE_ID))
	storage_backpack_weight.text = "负重 %d/%d" % [
		session.get_container_total_weight(BACKPACK_ID),
		session.get_container_maximum_weight(BACKPACK_ID),
	]
	storage_home_weight.text = "已用格 %d/%d · 不计负重" % [
		session.get_container_occupied_slot_count(HOME_STORAGE_ID),
		session.get_container_capacity(HOME_STORAGE_ID),
	]
	var equipped: Dictionary = session.get_equipped_weapon_snapshot()
	storage_equipment_status.text = "主武器：%s · 近战伤害 %d%s" % [
		String(equipped.get("display_name", "空手")),
		int(equipped.get("damage", 2)),
		" · 体力 %d · 噪声 %d" % [int(equipped.get("stamina_cost", 0)), int(equipped.get("noise", 0))] if StringName(equipped.get("item_id", "")) != &"" else "",
	]

func _on_storage_item_activated(source_container_id: StringName, instance_id: StringName) -> void:
	if _storage_mode == &"backpack":
		_storage_context_container_id = source_container_id
		_storage_context_instance_id = instance_id
		var item := _get_storage_item(source_container_id, instance_id)
		if not item.is_empty():
			_show_storage_item_details(item)
		return
	var destination_container_id := HOME_STORAGE_ID if source_container_id == BACKPACK_ID else BACKPACK_ID
	_transfer_storage_item(source_container_id, destination_container_id, instance_id)

func _on_storage_item_drop_requested(source_container_id: StringName, instance_id: StringName, target_container_id: StringName, target_cell: Vector2i) -> void:
	if _storage_mode == &"backpack" and (source_container_id != BACKPACK_ID or target_container_id != BACKPACK_ID):
		storage_transfer_status.text = "独立背包界面不能远程访问家园仓储。"
		return
	var session := _get_apocalypse_session()
	var item := _get_storage_item(source_container_id, instance_id)
	if item.is_empty():
		storage_transfer_status.text = "物品已不存在，无法拖动。"
		return
	if not session.transfer_item_to_position(source_container_id, target_container_id, instance_id, target_cell.x, target_cell.y):
		storage_transfer_status.text = "该格无法放置：物品仍留在原位。"
		return
	var target_name := "背包" if target_container_id == BACKPACK_ID else "家园仓储"
	_finish_storage_change("%s 已拖到%s格 (%d,%d)" % [
		_item_display_name(StringName(item["item_id"])),
		target_name,
		target_cell.x + 1,
		target_cell.y + 1,
	])

func _transfer_storage_item(source_container_id: StringName, destination_container_id: StringName, instance_id: StringName) -> void:
	var session := _get_apocalypse_session()
	var item := _get_storage_item(source_container_id, instance_id)
	if item.is_empty():
		storage_transfer_status.text = "物品已不存在，无法转移。"
		return
	_transfer_storage_quantity(source_container_id, destination_container_id, instance_id, int(item.get("quantity", 1)))

func _transfer_storage_quantity(source_container_id: StringName, destination_container_id: StringName, instance_id: StringName, quantity: int) -> void:
	var session := _get_apocalypse_session()
	var item := _get_storage_item(source_container_id, instance_id)
	if item.is_empty() or not session.transfer_quantity(source_container_id, destination_container_id, instance_id, quantity):
		storage_transfer_status.text = "目标空间不足：物品仍留在原容器。"
		return
	var destination_name := "家园仓储" if destination_container_id == HOME_STORAGE_ID else "背包"
	var quantity_text := "" if quantity == 1 else " ×%d" % quantity
	_finish_storage_change("%s%s 已转入%s" % [_item_display_name(StringName(item["item_id"])), quantity_text, destination_name])

func _setup_storage_context_controls() -> void:
	_storage_context_menu = PopupMenu.new()
	_storage_context_menu.name = "StorageItemContextMenu"
	_apply_compact_storage_popup_theme(_storage_context_menu)
	_storage_context_menu.id_pressed.connect(_on_storage_context_action)
	storage_modal.add_child(_storage_context_menu)

	_storage_split_dialog = ConfirmationDialog.new()
	_storage_split_dialog.name = "StorageSplitDialog"
	_storage_split_dialog.title = "拆分物品堆"
	_apply_compact_storage_popup_theme(_storage_split_dialog)
	_storage_split_dialog.confirmed.connect(_on_storage_split_confirmed)
	_storage_split_amount = SpinBox.new()
	_storage_split_amount.name = "Amount"
	_storage_split_amount.custom_minimum_size = Vector2(112, 18)
	_storage_split_amount.step = 1
	_storage_split_amount.allow_greater = false
	_storage_split_amount.allow_lesser = false
	_storage_split_dialog.add_child(_storage_split_amount)
	storage_modal.add_child(_storage_split_dialog)

	_storage_inspect_dialog = AcceptDialog.new()
	_storage_inspect_dialog.name = "StorageInspectDialog"
	_storage_inspect_dialog.title = "物品详情"
	_apply_compact_storage_popup_theme(_storage_inspect_dialog)
	var inspect_text := Label.new()
	inspect_text.name = "Details"
	inspect_text.custom_minimum_size = Vector2(160, 58)
	inspect_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspect_text.add_theme_font_size_override("font_size", STORAGE_COMPACT_FONT_SIZE)
	_storage_inspect_dialog.add_child(inspect_text)
	storage_modal.add_child(_storage_inspect_dialog)

func _on_storage_item_context_requested(container_id: StringName, instance_id: StringName, screen_position: Vector2i) -> void:
	var item := _get_storage_item(container_id, instance_id)
	if item.is_empty():
		return
	_storage_context_container_id = container_id
	_storage_context_instance_id = instance_id
	var is_backpack := container_id == BACKPACK_ID
	var item_id := StringName(item["item_id"])
	var quantity := int(item.get("quantity", 1))
	_storage_context_menu.clear()
	var use_text := ITEM_CATALOG_SCRIPT.get_use_menu_text(item_id)
	if not use_text.is_empty():
		_storage_context_menu.add_item(use_text, STORAGE_ACTION_USE_ONE)
		_storage_context_menu.add_separator()
	if is_backpack and ITEM_CATALOG_SCRIPT.is_weapon(item_id):
		var equipped: Dictionary = _get_apocalypse_session().get_equipped_weapon_snapshot()
		var is_equipped := StringName(equipped.get("instance_id", "")) == instance_id
		_storage_context_menu.add_item("卸下主武器" if is_equipped else "装备为主武器", STORAGE_ACTION_UNEQUIP_WEAPON if is_equipped else STORAGE_ACTION_EQUIP_WEAPON)
		_storage_context_menu.add_separator()
	if _storage_mode == &"storage":
		_storage_context_menu.add_item("存入 1" if is_backpack else "取出 1", STORAGE_ACTION_TRANSFER_ONE)
		_storage_context_menu.add_item("存入整组" if is_backpack else "取出整组", STORAGE_ACTION_TRANSFER_STACK)
	if quantity >= 2:
		_storage_context_menu.add_separator()
		_storage_context_menu.add_item("拆分一半", STORAGE_ACTION_SPLIT_HALF)
		_storage_context_menu.add_item("拆分指定数量…", STORAGE_ACTION_SPLIT_CUSTOM)
	_storage_context_menu.add_separator()
	_storage_context_menu.add_item("查看详情", STORAGE_ACTION_INSPECT)
	_storage_context_menu.popup(Rect2i(screen_position, Vector2i(STORAGE_MENU_WIDTH, 1)))
	_storage_context_menu.size = Vector2i(STORAGE_MENU_WIDTH, _storage_context_menu.size.y)

func _on_storage_context_action(action_id: int) -> void:
	if _storage_context_container_id == &"" or _storage_context_instance_id == &"":
		return
	var item := _get_storage_item(_storage_context_container_id, _storage_context_instance_id)
	if item.is_empty():
		storage_transfer_status.text = "物品已不存在，无法操作。"
		return
	var destination_container_id := HOME_STORAGE_ID if _storage_context_container_id == BACKPACK_ID else BACKPACK_ID
	match action_id:
		STORAGE_ACTION_USE_ONE:
			_use_storage_item(_storage_context_container_id, _storage_context_instance_id)
		STORAGE_ACTION_TRANSFER_ONE:
			_transfer_storage_quantity(_storage_context_container_id, destination_container_id, _storage_context_instance_id, 1)
		STORAGE_ACTION_TRANSFER_STACK:
			_transfer_storage_quantity(_storage_context_container_id, destination_container_id, _storage_context_instance_id, int(item.get("quantity", 1)))
		STORAGE_ACTION_SPLIT_HALF:
			_split_storage_item(max(1, int(item.get("quantity", 1)) / 2))
		STORAGE_ACTION_SPLIT_CUSTOM:
			_show_storage_split_dialog(int(item.get("quantity", 1)))
		STORAGE_ACTION_INSPECT:
			_show_storage_item_details(item)
		STORAGE_ACTION_EQUIP_WEAPON:
			_change_equipped_weapon(false)
		STORAGE_ACTION_UNEQUIP_WEAPON:
			_change_equipped_weapon(true)

func _change_equipped_weapon(unequip: bool) -> void:
	var session := _get_apocalypse_session()
	var result: Dictionary = session.unequip_weapon() if unequip else session.equip_weapon(_storage_context_instance_id)
	if not bool(result.get("ok", false)):
		storage_transfer_status.text = String(result.get("message", "装备状态没有变化。"))
		return
	_finish_storage_change(String(result.get("message", "装备状态已更新。")))

func _use_storage_item(container_id: StringName, instance_id: StringName) -> void:
	var session := _get_apocalypse_session()
	var result: Dictionary = session.use_item_in_container(container_id, instance_id)
	if not bool(result.get("ok", false)):
		storage_transfer_status.text = String(result.get("message", "物品未使用。"))
		return
	_finish_storage_change(String(result.get("message", "物品已使用。")))

func _show_storage_split_dialog(quantity: int) -> void:
	if quantity < 2:
		return
	_storage_split_amount.min_value = 1
	_storage_split_amount.max_value = quantity - 1
	_storage_split_amount.value = max(1, int(quantity / 2))
	_storage_split_dialog.dialog_text = "从当前物品堆拆出多少个？"
	_storage_split_dialog.popup_centered(STORAGE_SPLIT_DIALOG_SIZE)

func _on_storage_split_confirmed() -> void:
	_split_storage_item(int(_storage_split_amount.value))

func _split_storage_item(quantity: int) -> void:
	var session := _get_apocalypse_session()
	var item := _get_storage_item(_storage_context_container_id, _storage_context_instance_id)
	if item.is_empty() or not session.split_item_stack(_storage_context_container_id, _storage_context_instance_id, quantity):
		storage_transfer_status.text = "没有空格或数量无效：物品堆未拆分。"
		return
	_finish_storage_change("%s 已拆分出 ×%d" % [_item_display_name(StringName(item["item_id"])), quantity])

func _show_storage_item_details(item: Dictionary) -> void:
	var item_id := StringName(item["item_id"])
	var details: Label = _storage_inspect_dialog.get_node("Details") as Label
	details.text = "%s\n%s · %d/%d · 单格\n%s\n%s" % [
		ITEM_CATALOG_SCRIPT.get_display_name(item_id),
		ITEM_CATALOG_SCRIPT.get_category(item_id),
		int(item.get("quantity", 1)),
		int(item.get("maximum_stack", 1)),
		ITEM_CATALOG_SCRIPT.get_effect_text(item_id),
		"家园仓储不计负重" if _storage_context_container_id == HOME_STORAGE_ID else "单件负重 %d" % int(item.get("weight", 0)),
	]
	_storage_inspect_dialog.popup_centered(STORAGE_INSPECT_DIALOG_SIZE)

func _apply_compact_storage_popup_theme(popup: Window) -> void:
	popup.add_theme_font_size_override("font_size", STORAGE_COMPACT_FONT_SIZE)
	popup.add_theme_constant_override("h_separation", 3)
	popup.add_theme_constant_override("v_separation", 1)
	popup.add_theme_constant_override("item_start_padding", 4)
	popup.add_theme_constant_override("item_end_padding", 4)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.08, 0.09, 0.94)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.50, 0.56, 0.47, 0.92)
	panel_style.content_margin_left = 3
	panel_style.content_margin_top = 2
	panel_style.content_margin_right = 3
	panel_style.content_margin_bottom = 2
	popup.add_theme_stylebox_override("panel", panel_style)
	var hover_style := panel_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.20, 0.29, 0.25, 0.96)
	popup.add_theme_stylebox_override("hover", hover_style)
	if popup is ConfirmationDialog:
		var confirmation_dialog := popup as ConfirmationDialog
		confirmation_dialog.get_ok_button().add_theme_font_size_override("font_size", STORAGE_COMPACT_FONT_SIZE)
		var cancel_button: Button = confirmation_dialog.get_cancel_button()
		if cancel_button != null:
			cancel_button.add_theme_font_size_override("font_size", STORAGE_COMPACT_FONT_SIZE)
	elif popup is AcceptDialog:
		var accept_dialog := popup as AcceptDialog
		accept_dialog.get_ok_button().add_theme_font_size_override("font_size", STORAGE_COMPACT_FONT_SIZE)

func _get_storage_item(container_id: StringName, instance_id: StringName) -> Dictionary:
	var session := _get_apocalypse_session()
	for candidate in session.get_container_items(container_id):
		if StringName(candidate["instance_id"]) == instance_id:
			return candidate
	return {}

func _finish_storage_change(message: String) -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	storage_transfer_status.text = "%s%s" % [message, "，已自动保存。" if bool(save_result.get("ok", false)) else "，但自动保存失败。"]
	_refresh_storage_ui()

func _open_system_menu() -> void:
	system_menu_status.text = "系统菜单已打开"
	system_menu.visible = true
	system_continue_button.grab_focus()

func _close_system_menu() -> void:
	system_menu.visible = false

func _open_backpack_from_system_menu() -> void:
	_close_system_menu()
	_open_backpack_modal()

func _save_from_system_menu() -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	system_menu_status.text = "保存完成" if bool(save_result.get("ok", false)) else "保存失败"

func _get_apocalypse_session() -> ApocalypseSession:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	return apocalypse_run.ensure_active_session()

func _item_display_name(item_id: StringName) -> String:
	match item_id:
		&"water":
			return "饮用水"
		&"medkit":
			return "急救包"
		&"bandage":
			return "绷带"
		&"clinic_key":
			return "诊所钥匙"
		&"fuel_can":
			return "燃料罐"
		&"scrap_metal":
			return "废金属"
		&"wire":
			return "电线"
		&"simple_lockpick":
			return "简易开锁工具"
		&"crowbar":
			return "撬棍"
		_:
			return String(item_id)

func _show_hotspot_label(label_text: String) -> void:
	hotspot_label.text = label_text
	hotspot_label.visible = true

func _hide_hotspot_label() -> void:
	hotspot_label.visible = false

func _apply_optional_texture(view: TextureRect, fallback: ColorRect, texture: Texture2D) -> void:
	if texture == null:
		view.visible = false
		fallback.visible = true
		return
	view.texture = texture
	view.visible = true
	fallback.visible = false

func _apply_status_icon_slots() -> void:
	if status_hunger != null:
		hunger_png_slot.texture = status_hunger
	if status_thirst != null:
		thirst_png_slot.texture = status_thirst
	if status_injury != null:
		png_injury_slot.texture = status_injury
	if status_infection != null:
		png_infection_slot.texture = status_infection
	if status_noise_warning != null:
		png_noise_slot.texture = status_noise_warning
	if status_time_warning != null:
		png_time_slot.texture = status_time_warning

func _refresh_status_ui() -> void:
	var session := _get_apocalypse_session()
	var survivor: Dictionary = session.get_survivor_snapshot()
	var conditions: Dictionary = survivor.get("condition_levels", {})
	_status_hp = int(survivor.get("health", 0))
	_status_hunger = int(conditions.get("hunger", 0))
	_status_thirst = int(conditions.get("thirst", 0))
	_status_fatigue = int(conditions.get("fatigue", 0))
	_status_stress = int(conditions.get("stress", 0))
	_status_stamina = session.get_stamina()
	_status_injury_count = Array(survivor.get("injuries", [])).size()
	_status_infection_risk = int(survivor.get("infection_risk", 0))
	var clock_parts := session.get_clock_text().split(":")
	_status_time_minutes = int(clock_parts[0]) * 60 + int(clock_parts[1]) if clock_parts.size() == 2 else 0
	hp_value_label.text = str(_status_hp)
	fatigue_value_label.text = "%d/3" % _status_fatigue
	hunger_value_label.text = "%d/3" % _status_hunger
	thirst_value_label.text = "%d/3" % _status_thirst
	stamina_value_label.text = str(_status_stamina)
	_refresh_campaign_objective()

	var show_stress := _status_stress >= STRESS_WARN_THRESHOLD
	var show_injury := _status_injury_count > 0
	var show_infection := _status_infection_risk >= INFECTION_WARN_THRESHOLD
	var show_noise := _status_noise_total >= NOISE_WARN_THRESHOLD
	var show_time := _status_time_minutes >= TIME_WARN_MINUTES or _status_stamina <= int(float(STAMINA_MAX) * STAMINA_LOW_RATIO)
	stress_warn_label.visible = show_stress
	injury_warn_label.visible = show_injury
	infection_warn_label.visible = show_infection
	noise_warn_label.visible = show_noise
	time_warn_label.visible = show_time
	warnings_group.visible = show_stress or show_injury or show_infection or show_noise or show_time

func _refresh_campaign_objective() -> void:
	var campaign: Dictionary = _get_apocalypse_session().get_campaign_snapshot()
	var pending_event: Dictionary = campaign.get("pending_event", {})
	if not pending_event.is_empty():
		campaign_objective_label.text = "第%d日事件待处理\n%s · 请选择应对" % [
			int(pending_event.get("day", 0)),
			String(pending_event.get("title", "待处理事件")),
		]
		return
	for event_key in [&"day_seven_event", &"day_six_event", &"day_five_event"]:
		var campaign_event: Dictionary = campaign.get(event_key, {})
		if StringName(campaign_event.get("state", "not_started")) != ApocalypseSession.EVENT_STATE_RESOLVED:
			continue
		var event_result: Dictionary = campaign_event.get("result", {})
		campaign_objective_label.text = "第%d日事件已处理\n%s" % [
			int(campaign_event.get("day", 0)),
			String(event_result.get("choice_label", "处理完成")),
		]
		return
	if bool(campaign.get("resolved", false)):
		var outcome := StringName(campaign.get("outcome", ""))
		campaign_objective_label.text = "首轮袭击已结算\n%s · 准备 %d/3" % [
			"守住家园" if outcome == &"held" else "受创幸存",
			int(campaign.get("score", 0)),
		]
		return
	campaign_objective_label.text = "首袭目标 · 第4日清晨\n%s 电力10  %s 急救包  %s 武器\n准备 %d/3 · 任意2项可守住" % [
		"✓" if bool(campaign.get("power_ready", false)) else "□",
		"✓" if bool(campaign.get("medkit_ready", false)) else "□",
		"✓" if bool(campaign.get("weapon_ready", false)) else "□",
		int(campaign.get("score", 0)),
	]
