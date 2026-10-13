class_name ApocalypseSession
extends RefCounted

const SNAPSHOT_VERSION := 1
const TIMELINE_KIND := &"apocalypse"
const STARTING_REGION_ID := &"county_edge"
const STARTING_REGION_THREAT := 0
const MAX_REGION_THREAT := 3
const MAX_HOME_POWER := 100
const GENERATOR_REFUEL_MINUTES := 5
const MEDICAL_STATION_POWER_COST := 10
const MEDICAL_STATION_MINUTES := 15
const MEDICAL_STATION_INFECTION_REDUCTION := 15
const LOCATION_NOISE_WARNING_THRESHOLD := 5
const LOCATION_NOISE_DANGER_THRESHOLD := 10
const WORKBENCH_LOCKPICK_RECIPE_ID := &"simple_lockpick"
const FIRST_RAID_DAY := 4
const FIRST_RAID_REQUIRED_SCORE := 2
const FIRST_RAID_POWER_REQUIREMENT := 10
const FIRST_RAID_MEDKIT_REQUIREMENT := 1
const FIRST_RAID_POWER_COST := 5
const FIRST_RAID_FAILURE_DAMAGE := 20
const DAY_FIVE_EVENT_DAY := 5
const DAY_FIVE_EVENT_ID := &"day_five_radio_signal"
const DAY_FIVE_POWER_CHOICE_ID := &"power_radio"
const DAY_FIVE_ROOFTOP_CHOICE_ID := &"rooftop_watch"
const DAY_FIVE_POWER_COST := 5
const DAY_FIVE_ROOFTOP_FATIGUE := 1
const DAY_FIVE_ROOFTOP_STRESS := 1
const DAY_SIX_EVENT_DAY := 6
const DAY_SIX_EVENT_ID := &"day_six_hanging_pack"
const DAY_SIX_RECOVER_CHOICE_ID := &"recover_hanging_pack"
const DAY_SIX_ABANDON_CHOICE_ID := &"abandon_hanging_pack"
const DAY_SIX_RECOVERY_WATER := 2
const DAY_SIX_RECOVERY_FATIGUE := 1
const DAY_SIX_RECOVERY_STRESS := 1
const DAY_SEVEN_EVENT_DAY := 7
const DAY_SEVEN_EVENT_ID := &"day_seven_shelter_tarp"
const DAY_SEVEN_WIRE_CHOICE_ID := &"repair_shelter_tarp"
const DAY_SEVEN_MANUAL_CHOICE_ID := &"move_shelter_supplies"
const DAY_SEVEN_MANUAL_FATIGUE := 1
const DAY_SEVEN_MANUAL_STRESS := 1

const EVENT_STATE_NOT_STARTED := &"not_started"
const EVENT_STATE_PENDING := &"pending"
const EVENT_STATE_RESOLVED := &"resolved"
const VALID_EVENT_STATES := [EVENT_STATE_NOT_STARTED, EVENT_STATE_PENDING, EVENT_STATE_RESOLVED]

const POCKETS_ID := &"pockets"
const CHEST_RIG_ID := &"chest_rig"
const BACKPACK_ID := &"backpack"
const SECURE_POUCH_ID := &"secure_pouch"
const HOME_STORAGE_ID := &"home_storage"
const CONTAINER_IDS := [POCKETS_ID, CHEST_RIG_ID, BACKPACK_ID, SECURE_POUCH_ID, HOME_STORAGE_ID]

const VALID_LOCATION_STATES := [&"known", &"depleted", &"occupied", &"infected", &"burned"]

const GAME_SESSION_SCRIPT = preload("res://src/domain/session/game_session.gd")
const SURVIVOR_STATE_SCRIPT = preload("res://src/domain/apocalypse/survivor_state.gd")
const GRID_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/grid_container.gd")
const SEARCH_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/search_container.gd")
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const SHELTER_FACILITIES_SCRIPT = preload("res://src/domain/apocalypse/shelter_facilities.gd")

var _clock: Variant
var _survivor: Variant
var _containers: Dictionary = {}
var _current_region_id: StringName = STARTING_REGION_ID
var _region_threat: Dictionary = {}
var _known_locations: Dictionary = {}
var _home_power := 0
var _equipped_weapon_instance_id: StringName = &""
var _first_raid_resolved := false
var _first_raid_result: Dictionary = {}
var _day_five_event_state: StringName = EVENT_STATE_NOT_STARTED
var _day_five_event_result: Dictionary = {}
var _day_six_event_state: StringName = EVENT_STATE_NOT_STARTED
var _day_six_event_result: Dictionary = {}
var _day_seven_event_state: StringName = EVENT_STATE_NOT_STARTED
var _day_seven_event_result: Dictionary = {}
var _shelter_facilities: Variant

func start_new_game(rules: GameRules, attribute_modifiers: Dictionary = {}) -> void:
	assert(rules != null, "An apocalypse session requires a rules profile.")
	_clock = GAME_SESSION_SCRIPT.new()
	_clock.start_new_game(rules)
	_survivor = SURVIVOR_STATE_SCRIPT.new()
	_survivor.start_new_game(attribute_modifiers)
	_containers = {
		POCKETS_ID: _new_container(3, 1, 3),
		CHEST_RIG_ID: _new_container(4, 2, 8),
		BACKPACK_ID: _new_container(6, 4, 20),
		SECURE_POUCH_ID: _new_container(2, 2, 5),
		HOME_STORAGE_ID: _new_container(8, 6, 80),
	}
	_current_region_id = STARTING_REGION_ID
	_region_threat = {STARTING_REGION_ID: STARTING_REGION_THREAT}
	_known_locations.clear()
	_home_power = 0
	_equipped_weapon_instance_id = &""
	_first_raid_resolved = false
	_first_raid_result.clear()
	_day_five_event_state = EVENT_STATE_NOT_STARTED
	_day_five_event_result.clear()
	_day_six_event_state = EVENT_STATE_NOT_STARTED
	_day_six_event_result.clear()
	_day_seven_event_state = EVENT_STATE_NOT_STARTED
	_day_seven_event_result.clear()
	_shelter_facilities = SHELTER_FACILITIES_SCRIPT.new()
	_shelter_facilities.start_new_game(get_day())

func get_timeline_kind() -> StringName:
	return TIMELINE_KIND

func get_day() -> int:
	return _clock.get_day()

func get_clock_text() -> String:
	return _clock.get_clock_text()

func get_stamina() -> int:
	return _clock.get_stamina()

func get_weather_id() -> StringName:
	return _clock.get_weather_id()

func get_survivor_snapshot() -> Dictionary:
	return _survivor.to_snapshot()

func get_home_power() -> int:
	return _home_power


func get_shelter_facility_snapshot(facility_id: StringName) -> Dictionary:
	if _shelter_facilities == null:
		return {}
	return _shelter_facilities.get_facility_snapshot(facility_id, get_day())


func perform_shelter_facility_action(facility_id: StringName, action_id: StringName) -> Dictionary:
	var facility: Dictionary = get_shelter_facility_snapshot(facility_id)
	if facility.is_empty():
		return {"ok": false, "message": "未知的安全区设施。"}
	var actions: Array = facility.get("actions", [])
	var action: Dictionary = {}
	for value in actions:
		if value is Dictionary and StringName(value.get("action_id", "")) == action_id:
			action = value
			break
	if action.is_empty():
		return {"ok": false, "message": "该设施没有此动作。"}
	if not bool(action.get("available", false)):
		return {"ok": false, "message": String(action.get("unavailable_reason", "该设施当前不可操作。"))}
	var minutes: int = int(action.get("minutes", 0))
	var stamina: int = int(action.get("stamina", 0))
	if minutes <= 0 or stamina < 0:
		return {"ok": false, "message": "设施动作数据无效。"}
	if not spend_action(minutes, stamina):
		return {"ok": false, "message": "当前体力不足，无法完成设施维护。"}
	return _shelter_facilities.perform_action(facility_id, action_id, get_day())

func get_campaign_snapshot() -> Dictionary:
	var campaign: Dictionary
	var day_five_result := _day_five_event_result.duplicate(true)
	if _day_five_event_state == EVENT_STATE_RESOLVED and not day_five_result.has("choice_label"):
		day_five_result["choice_label"] = "短时供电监听" if StringName(day_five_result.get("choice_id", "")) == DAY_FIVE_POWER_CHOICE_ID else "登上屋顶观察"
	var day_six_result := _day_six_event_result.duplicate(true)
	if _day_six_event_state == EVENT_STATE_RESOLVED and not day_six_result.has("choice_label"):
		day_six_result["choice_label"] = "系绳回收悬包" if StringName(day_six_result.get("choice_id", "")) == DAY_SIX_RECOVER_CHOICE_ID else "割断吊带放弃"
	var day_seven_result := _day_seven_event_result.duplicate(true)
	if _day_seven_event_state == EVENT_STATE_RESOLVED and not day_seven_result.has("choice_label"):
		day_seven_result["choice_label"] = "用电线加固雨棚" if StringName(day_seven_result.get("choice_id", "")) == DAY_SEVEN_WIRE_CHOICE_ID else "徒手转移物资"
	if _first_raid_resolved:
		campaign = _first_raid_result.duplicate(true)
	else:
		var readiness := _get_first_raid_readiness()
		campaign = {
			"first_raid_day": FIRST_RAID_DAY,
			"resolved": false,
			"outcome": &"",
			"score": int(readiness["score"]),
			"required_score": FIRST_RAID_REQUIRED_SCORE,
			"power_ready": bool(readiness["power_ready"]),
			"medkit_ready": bool(readiness["medkit_ready"]),
			"weapon_ready": bool(readiness["weapon_ready"]),
		}
	campaign["day_five_event"] = {
		"event_id": DAY_FIVE_EVENT_ID,
		"day": DAY_FIVE_EVENT_DAY,
		"state": _day_five_event_state,
		"result": day_five_result,
	}
	campaign["day_six_event"] = {
		"event_id": DAY_SIX_EVENT_ID,
		"day": DAY_SIX_EVENT_DAY,
		"state": _day_six_event_state,
		"result": day_six_result,
	}
	campaign["day_seven_event"] = {
		"event_id": DAY_SEVEN_EVENT_ID,
		"day": DAY_SEVEN_EVENT_DAY,
		"state": _day_seven_event_state,
		"result": day_seven_result,
	}
	campaign["pending_event"] = get_pending_campaign_event()
	return campaign


func get_pending_campaign_event() -> Dictionary:
	if _day_five_event_state == EVENT_STATE_PENDING:
		return _get_day_five_event_definition()
	if _day_six_event_state == EVENT_STATE_PENDING:
		return _get_day_six_event_definition()
	if _day_seven_event_state == EVENT_STATE_PENDING:
		return _get_day_seven_event_definition()
	return {}


func _get_day_five_event_definition() -> Dictionary:
	var power_available := _home_power >= DAY_FIVE_POWER_COST
	return {
		"event_id": DAY_FIVE_EVENT_ID,
		"day": DAY_FIVE_EVENT_DAY,
		"state": EVENT_STATE_PENDING,
		"title": "断续的无线电信号",
		"description": "第 5 日清晨，主屋旧收音机反复收到一段县城东侧的警戒广播。信号很弱，但屋顶能看见同一方向的烟柱。必须先确认风险来源，才能继续休息。",
		"choices": [
			{
				"choice_id": DAY_FIVE_POWER_CHOICE_ID,
				"label": "短时供电监听",
				"consequence": "电力 -%d；不增加疲劳或压力。" % DAY_FIVE_POWER_COST,
				"available": power_available,
				"unavailable_reason": "当前电力 %d/%d。" % [_home_power, DAY_FIVE_POWER_COST] if not power_available else "",
			},
			{
				"choice_id": DAY_FIVE_ROOFTOP_CHOICE_ID,
				"label": "登上屋顶观察",
				"consequence": "不耗电；疲劳 +%d，压力 +%d。" % [DAY_FIVE_ROOFTOP_FATIGUE, DAY_FIVE_ROOFTOP_STRESS],
				"available": true,
				"unavailable_reason": "",
			},
		],
	}


func _get_day_six_event_definition() -> Dictionary:
	var storage: Variant = _containers.get(HOME_STORAGE_ID)
	var reward_instance_id := _make_available_instance_id(&"day_six_hanging_pack_water")
	var reward_available: bool = storage != null and storage.can_add_item_stack(
		reward_instance_id,
		&"water",
		1,
		1,
		5,
		DAY_SIX_RECOVERY_WATER,
		ITEM_CATALOG_SCRIPT.get_maximum_stack(&"water"),
		true,
	)
	return {
		"event_id": DAY_SIX_EVENT_ID,
		"day": DAY_SIX_EVENT_DAY,
		"state": EVENT_STATE_PENDING,
		"title": "屋檐外的悬包",
		"description": "第 6 日清晨，昨夜的风把一只旧救援包吹到主屋屋檐外。吊带正被铁皮边缘慢慢割断，包里能看见两瓶尚未开封的水。必须决定是否冒险回收。",
		"choices": [
			{
				"choice_id": DAY_SIX_RECOVER_CHOICE_ID,
				"label": "系绳回收悬包",
				"consequence": "家园仓储获得饮用水 ×%d；疲劳 +%d，压力 +%d。" % [DAY_SIX_RECOVERY_WATER, DAY_SIX_RECOVERY_FATIGUE, DAY_SIX_RECOVERY_STRESS],
				"available": reward_available,
				"unavailable_reason": "家园仓储没有空间容纳饮用水。" if not reward_available else "",
			},
			{
				"choice_id": DAY_SIX_ABANDON_CHOICE_ID,
				"label": "割断吊带放弃",
				"consequence": "不增加疲劳或压力；不获得物资。",
				"available": true,
				"unavailable_reason": "",
			},
		],
	}


func _get_day_seven_event_definition() -> Dictionary:
	var wire_available := _container_has_item(HOME_STORAGE_ID, &"wire")
	return {
		"event_id": DAY_SEVEN_EVENT_ID,
		"day": DAY_SEVEN_EVENT_DAY,
		"state": EVENT_STATE_PENDING,
		"title": "松动的仓储雨棚",
		"description": "第 7 日清晨，昨夜的积水让仓储雨棚的一处支架开始松脱。今天的天气是%s；再拖一晚，里面的物资就可能受潮。必须先处理雨棚，才能继续休息。" % _clock.get_weather_text(),
		"choices": [
			{
				"choice_id": DAY_SEVEN_WIRE_CHOICE_ID,
				"label": "用电线加固雨棚",
				"consequence": "家园仓储消耗电线 ×1；不增加疲劳或压力。",
				"available": wire_available,
				"unavailable_reason": "家园仓储没有电线。" if not wire_available else "",
			},
			{
				"choice_id": DAY_SEVEN_MANUAL_CHOICE_ID,
				"label": "徒手转移物资",
				"consequence": "不消耗电线；疲劳 +%d，压力 +%d。" % [DAY_SEVEN_MANUAL_FATIGUE, DAY_SEVEN_MANUAL_STRESS],
				"available": true,
				"unavailable_reason": "",
			},
		],
	}


func resolve_pending_campaign_event(choice_id: StringName) -> Dictionary:
	if _day_five_event_state == EVENT_STATE_PENDING:
		return _resolve_day_five_event(choice_id)
	if _day_six_event_state == EVENT_STATE_PENDING:
		return _resolve_day_six_event(choice_id)
	if _day_seven_event_state == EVENT_STATE_PENDING:
		return _resolve_day_seven_event(choice_id)
	return {"ok": false, "message": "当前没有待处理事件。"}


func _resolve_day_five_event(choice_id: StringName) -> Dictionary:
	var outcome: StringName
	var message: String
	var power_spent := 0
	var fatigue_added := 0
	var stress_added := 0
	match choice_id:
		DAY_FIVE_POWER_CHOICE_ID:
			if _home_power < DAY_FIVE_POWER_COST:
				return {"ok": false, "message": "电力不足：监听需要 %d 点电力。" % DAY_FIVE_POWER_COST}
			_home_power -= DAY_FIVE_POWER_COST
			power_spent = DAY_FIVE_POWER_COST
			outcome = &"signal_monitored"
			message = "供电监听完成。广播确认东侧尸群正在远离县道；你保留了体力，但消耗了 %d 点电力。" % DAY_FIVE_POWER_COST
		DAY_FIVE_ROOFTOP_CHOICE_ID:
			fatigue_added = DAY_FIVE_ROOFTOP_FATIGUE
			stress_added = DAY_FIVE_ROOFTOP_STRESS
			_survivor.change_condition(&"fatigue", fatigue_added)
			_survivor.change_condition(&"stress", stress_added)
			outcome = &"rooftop_observation"
			message = "屋顶观察完成。烟柱正在向东移动，县道暂时安全；你没有耗电，但疲劳和压力各上升 1 级。"
		_:
			return {"ok": false, "message": "事件选项无效。"}
	_day_five_event_state = EVENT_STATE_RESOLVED
	_day_five_event_result = {
		"event_id": DAY_FIVE_EVENT_ID,
		"day": DAY_FIVE_EVENT_DAY,
		"state": EVENT_STATE_RESOLVED,
		"choice_id": choice_id,
		"choice_label": "短时供电监听" if choice_id == DAY_FIVE_POWER_CHOICE_ID else "登上屋顶观察",
		"outcome": outcome,
		"power_spent": power_spent,
		"fatigue_added": fatigue_added,
		"stress_added": stress_added,
		"message": message,
	}
	var response := _day_five_event_result.duplicate(true)
	response["ok"] = true
	return response


func _resolve_day_six_event(choice_id: StringName) -> Dictionary:
	var outcome: StringName
	var message: String
	var water_recovered := 0
	var fatigue_added := 0
	var stress_added := 0
	match choice_id:
		DAY_SIX_RECOVER_CHOICE_ID:
			var storage: Variant = _containers.get(HOME_STORAGE_ID)
			var reward_instance_id := _make_available_instance_id(&"day_six_hanging_pack_water")
			if storage == null or not storage.can_add_item_stack(
				reward_instance_id,
				&"water",
				1,
				1,
				5,
				DAY_SIX_RECOVERY_WATER,
				ITEM_CATALOG_SCRIPT.get_maximum_stack(&"water"),
				true,
			):
				return {"ok": false, "message": "家园仓储没有空间容纳悬包里的饮用水。"}
			if not storage.add_item_stack(
				reward_instance_id,
				&"water",
				1,
				1,
				5,
				DAY_SIX_RECOVERY_WATER,
				ITEM_CATALOG_SCRIPT.get_maximum_stack(&"water"),
				true,
			):
				return {"ok": false, "message": "悬包物资未能写入家园仓储。"}
			water_recovered = DAY_SIX_RECOVERY_WATER
			fatigue_added = DAY_SIX_RECOVERY_FATIGUE
			stress_added = DAY_SIX_RECOVERY_STRESS
			_survivor.change_condition(&"fatigue", fatigue_added)
			_survivor.change_condition(&"stress", stress_added)
			outcome = &"pack_recovered"
			message = "悬包已被绳索拖回。家园仓储获得饮用水 ×%d；疲劳和压力各上升 1 级。" % DAY_SIX_RECOVERY_WATER
		DAY_SIX_ABANDON_CHOICE_ID:
			outcome = &"pack_abandoned"
			message = "你割断吊带，让悬包落到屋外。没有人受伤，也没有获得其中的物资。"
		_:
			return {"ok": false, "message": "事件选项无效。"}
	_day_six_event_state = EVENT_STATE_RESOLVED
	_day_six_event_result = {
		"event_id": DAY_SIX_EVENT_ID,
		"day": DAY_SIX_EVENT_DAY,
		"state": EVENT_STATE_RESOLVED,
		"choice_id": choice_id,
		"choice_label": "系绳回收悬包" if choice_id == DAY_SIX_RECOVER_CHOICE_ID else "割断吊带放弃",
		"outcome": outcome,
		"water_recovered": water_recovered,
		"fatigue_added": fatigue_added,
		"stress_added": stress_added,
		"message": message,
	}
	var response := _day_six_event_result.duplicate(true)
	response["ok"] = true
	return response


func _resolve_day_seven_event(choice_id: StringName) -> Dictionary:
	var outcome: StringName
	var message: String
	var wire_spent := 0
	var fatigue_added := 0
	var stress_added := 0
	match choice_id:
		DAY_SEVEN_WIRE_CHOICE_ID:
			var storage: Variant = _containers.get(HOME_STORAGE_ID)
			var wire_instance_id := _find_container_item_instance(HOME_STORAGE_ID, &"wire")
			if storage == null or wire_instance_id == &"":
				return {"ok": false, "message": "家园仓储没有电线，无法加固雨棚。"}
			if not storage.remove_quantity(wire_instance_id, 1):
				return {"ok": false, "message": "电线未能从家园仓储取出，雨棚仍待处理。"}
			wire_spent = 1
			outcome = &"tarp_repaired"
			message = "你用电线重新固定了雨棚支架。物资暂时安全，没有额外消耗疲劳或压力。"
		DAY_SEVEN_MANUAL_CHOICE_ID:
			fatigue_added = DAY_SEVEN_MANUAL_FATIGUE
			stress_added = DAY_SEVEN_MANUAL_STRESS
			_survivor.change_condition(&"fatigue", fatigue_added)
			_survivor.change_condition(&"stress", stress_added)
			outcome = &"supplies_moved"
			message = "你把靠近漏水处的物资一件件搬到干燥位置。雨棚还需要后续维修，但今晚不会继续进水；疲劳和压力各上升 1 级。"
		_:
			return {"ok": false, "message": "事件选项无效。"}
	_day_seven_event_state = EVENT_STATE_RESOLVED
	_day_seven_event_result = {
		"event_id": DAY_SEVEN_EVENT_ID,
		"day": DAY_SEVEN_EVENT_DAY,
		"state": EVENT_STATE_RESOLVED,
		"choice_id": choice_id,
		"choice_label": "用电线加固雨棚" if choice_id == DAY_SEVEN_WIRE_CHOICE_ID else "徒手转移物资",
		"outcome": outcome,
		"wire_spent": wire_spent,
		"fatigue_added": fatigue_added,
		"stress_added": stress_added,
		"message": message,
	}
	var response := _day_seven_event_result.duplicate(true)
	response["ok"] = true
	return response

func get_equipped_weapon_snapshot() -> Dictionary:
	if _equipped_weapon_instance_id == &"":
		return {"instance_id": &"", "item_id": &"", "display_name": "空手", "damage": 2, "stamina_cost": 0, "noise": 0}
	var backpack: Variant = _containers.get(BACKPACK_ID)
	var item: Dictionary = backpack.get_item(_equipped_weapon_instance_id) if backpack != null else {}
	if item.is_empty():
		_equipped_weapon_instance_id = &""
		return {"instance_id": &"", "item_id": &"", "display_name": "空手", "damage": 2, "stamina_cost": 0, "noise": 0}
	var item_id := StringName(item.get("item_id", ""))
	var stats: Dictionary = ITEM_CATALOG_SCRIPT.get_weapon_stats(item_id)
	return {
		"instance_id": _equipped_weapon_instance_id,
		"item_id": item_id,
		"display_name": ITEM_CATALOG_SCRIPT.get_display_name(item_id),
		"damage": int(stats.get("damage", 2)),
		"stamina_cost": int(stats.get("stamina_cost", 0)),
		"noise": int(stats.get("noise", 0)),
	}

func equip_weapon(instance_id: StringName) -> Dictionary:
	var backpack: Variant = _containers.get(BACKPACK_ID)
	var item: Dictionary = backpack.get_item(instance_id) if backpack != null else {}
	if item.is_empty():
		return {"ok": false, "message": "武器必须放在背包中才能装备。"}
	var item_id := StringName(item.get("item_id", ""))
	if not ITEM_CATALOG_SCRIPT.is_weapon(item_id):
		return {"ok": false, "message": "该物品不是可装备武器。"}
	_equipped_weapon_instance_id = instance_id
	return {"ok": true, "message": "已装备主武器：%s。" % ITEM_CATALOG_SCRIPT.get_display_name(item_id), "item_id": item_id}

func unequip_weapon() -> Dictionary:
	if _equipped_weapon_instance_id == &"":
		return {"ok": false, "message": "当前没有装备主武器。"}
	var previous: Dictionary = get_equipped_weapon_snapshot()
	_equipped_weapon_instance_id = &""
	return {"ok": true, "message": "已卸下主武器：%s。" % String(previous.get("display_name", "武器"))}

func get_container_item_quantity(container_id: StringName, item_id: StringName) -> int:
	var container: Variant = _containers.get(container_id)
	if container == null or item_id == &"":
		return 0
	var quantity := 0
	for item in container.get_items():
		if StringName(item.get("item_id", "")) == item_id:
			quantity += int(item.get("quantity", 0))
	return quantity

func refuel_home_generator() -> Dictionary:
	var power_gain := ITEM_CATALOG_SCRIPT.get_generator_power_value(&"fuel_can")
	if power_gain <= 0:
		return {"ok": false, "message": "燃料罐没有可用的发电数值。"}
	if _home_power > MAX_HOME_POWER - power_gain:
		return {"ok": false, "message": "电力储备接近上限，燃料罐未消耗。"}
	var fuel_instance_id := _find_container_item_instance(HOME_STORAGE_ID, &"fuel_can")
	if fuel_instance_id == &"":
		return {"ok": false, "message": "家园仓储中没有燃料罐。"}
	if not spend_action(GENERATOR_REFUEL_MINUTES, 0):
		return {"ok": false, "message": "当前无法腾出加注燃料所需的时间。"}
	var home_storage: Variant = _containers[HOME_STORAGE_ID]
	if not home_storage.remove_quantity(fuel_instance_id, 1):
		return {"ok": false, "message": "燃料加注未完成，仓储未变化。"}
	_home_power += power_gain
	return {"ok": true, "message": "应急发电机已加注：电力 +%d。" % power_gain, "power_gain": power_gain}

func treat_at_home_medical_station() -> Dictionary:
	if _home_power < MEDICAL_STATION_POWER_COST:
		return {"ok": false, "message": "电力不足：医疗台需要 %d 点电力。" % MEDICAL_STATION_POWER_COST}
	var medkit_instance_id := _find_container_item_instance(HOME_STORAGE_ID, &"medkit")
	if medkit_instance_id == &"":
		return {"ok": false, "message": "家园仓储中没有急救包。"}
	var injuries: Array[StringName] = _survivor.get_injury_ids()
	var infection_risk: int = int(_survivor.to_snapshot().get("infection_risk", 0))
	if injuries.is_empty() and infection_risk <= 0:
		return {"ok": false, "message": "当前没有需要医疗台处理的创伤或感染风险。"}
	if not spend_action(MEDICAL_STATION_MINUTES, 0):
		return {"ok": false, "message": "当前无法腾出医疗处理所需的时间。"}
	var home_storage: Variant = _containers[HOME_STORAGE_ID]
	if not home_storage.remove_quantity(medkit_instance_id, 1):
		return {"ok": false, "message": "医疗处理未完成，仓储未变化。"}
	_home_power -= MEDICAL_STATION_POWER_COST
	var treated_injury: StringName = &""
	if not injuries.is_empty():
		treated_injury = injuries[0]
		_survivor.remove_injury(treated_injury)
	var reduced_infection: int = _survivor.reduce_infection_risk(MEDICAL_STATION_INFECTION_REDUCTION)
	var injury_text := "处理创伤：%s" % treated_injury if treated_injury != &"" else "未发现可处理的创伤"
	return {
		"ok": true,
		"message": "医疗台完成处理：%s；感染风险 -%d。" % [injury_text, reduced_infection],
		"treated_injury": treated_injury,
		"infection_reduced": reduced_infection,
	}

func craft_simple_lockpick() -> Dictionary:
	var recipe: Dictionary = ITEM_CATALOG_SCRIPT.get_workbench_recipe(WORKBENCH_LOCKPICK_RECIPE_ID)
	if recipe.is_empty():
		return {"ok": false, "message": "开锁工具配方不存在。"}
	var power_cost: int = int(recipe["power_cost"])
	if _home_power < power_cost:
		return {"ok": false, "message": "电力不足：制作需要 %d 点电力。" % power_cost}
	var scrap_instance_id := _find_container_item_instance(HOME_STORAGE_ID, &"scrap_metal")
	var wire_instance_id := _find_container_item_instance(HOME_STORAGE_ID, &"wire")
	if scrap_instance_id == &"" or wire_instance_id == &"":
		return {"ok": false, "message": "材料不足：需要废金属 ×1 和电线 ×1。"}
	if not spend_action(int(recipe["minutes"]), 0):
		return {"ok": false, "message": "当前无法腾出制作所需的时间。"}
	var home_storage: Variant = _containers[HOME_STORAGE_ID]
	if not home_storage.remove_quantity(scrap_instance_id, 1) or not home_storage.remove_quantity(wire_instance_id, 1):
		return {"ok": false, "message": "制作未完成，材料未正确扣除。"}
	var output_item_id: StringName = StringName(recipe["output_item_id"])
	var output_instance_id := _make_available_instance_id(&"simple_lockpick_1")
	if not home_storage.add_item_stack(output_instance_id, output_item_id, 1, 1, 1, 1, ITEM_CATALOG_SCRIPT.get_maximum_stack(output_item_id), true):
		return {"ok": false, "message": "制作未完成：仓储没有成品空间。"}
	_home_power -= power_cost
	return {"ok": true, "message": "工作台制作完成：简易开锁工具 ×1。", "item_id": output_item_id}

func apply_survivor_damage(amount: int) -> int:
	return int(_survivor.apply_damage(amount))

func add_survivor_injury(injury_id: StringName) -> bool:
	return bool(_survivor.add_injury(injury_id))

func add_survivor_infection_risk(amount: int) -> int:
	return int(_survivor.add_infection_risk(amount))

func get_current_region_id() -> StringName:
	return _current_region_id

func spend_action(minutes: int, stamina_cost: int) -> bool:
	assert(minutes > 0, "An apocalypse action must consume positive time.")
	assert(stamina_cost >= 0, "An apocalypse action cannot refund stamina.")
	if _clock.get_stamina() < stamina_cost:
		return false
	_clock.consume_stamina(stamina_cost)
	_clock.advance_minutes(minutes)
	return true

func sleep() -> void:
	_clock.sleep()
	_survivor.change_condition(&"hunger", 1)
	_survivor.change_condition(&"thirst", 1)
	_survivor.change_condition(&"fatigue", -2)
	_survivor.change_condition(&"stress", -1)
	if _shelter_facilities != null:
		_shelter_facilities.advance_to_day(get_day())

func rest_at_shelter() -> Dictionary:
	var pending_event := get_pending_campaign_event()
	if not pending_event.is_empty():
		return {
			"ok": false,
			"raid_resolved": false,
			"event_pending": true,
			"event": pending_event,
			"message": "必须先处理当前事件，才能继续休息。",
		}
	sleep()
	if not _first_raid_resolved and get_day() >= FIRST_RAID_DAY:
		return _resolve_first_raid()
	if _first_raid_resolved and get_day() >= DAY_FIVE_EVENT_DAY and _day_five_event_state == EVENT_STATE_NOT_STARTED:
		_day_five_event_state = EVENT_STATE_PENDING
		return {
			"ok": true,
			"raid_resolved": false,
			"event_pending": true,
			"event": get_pending_campaign_event(),
			"message": "休息进入第 5 日；一段断续的无线电信号需要处理。",
		}
	if _first_raid_resolved and _day_five_event_state == EVENT_STATE_RESOLVED and get_day() >= DAY_SIX_EVENT_DAY and _day_six_event_state == EVENT_STATE_NOT_STARTED:
		_day_six_event_state = EVENT_STATE_PENDING
		return {
			"ok": true,
			"raid_resolved": false,
			"event_pending": true,
			"event": get_pending_campaign_event(),
			"message": "休息进入第 6 日；屋檐外的悬包需要处理。",
		}
	if _first_raid_resolved and _day_six_event_state == EVENT_STATE_RESOLVED and get_day() >= DAY_SEVEN_EVENT_DAY and _day_seven_event_state == EVENT_STATE_NOT_STARTED:
		_day_seven_event_state = EVENT_STATE_PENDING
		return {
			"ok": true,
			"raid_resolved": false,
			"event_pending": true,
			"event": get_pending_campaign_event(),
			"message": "休息进入第 7 日；松动的仓储雨棚需要处理。",
		}
	return {
		"ok": true,
		"raid_resolved": false,
		"event_pending": false,
		"message": "休息完成。现在是第 %d 日 %s；饥饿与口渴各上升 1 级。" % [get_day(), get_clock_text()],
	}

func set_region_threat(region_id: StringName, level: int) -> void:
	assert(region_id != &"", "A region requires a stable region_id.")
	assert(level >= 0 and level <= MAX_REGION_THREAT, "Region threat must be between zero and three.")
	_region_threat[region_id] = level

func get_region_threat(region_id: StringName) -> int:
	return int(_region_threat.get(region_id, 0))

func discover_location(location_id: StringName, location_type: StringName) -> bool:
	assert(location_id != &"", "A location requires a stable location_id.")
	assert(location_type != &"", "A location requires a stable location_type.")
	if _known_locations.has(location_id):
		return false
	_known_locations[location_id] = {
		"location_type": location_type,
		"state": &"known",
		"search_containers": {},
		"unlocked_locks": {},
		"search_noise": 0,
	}
	return true

func is_location_known(location_id: StringName) -> bool:
	return _known_locations.has(location_id)

func get_location_snapshot(location_id: StringName) -> Dictionary:
	var value: Variant = _known_locations.get(location_id, {})
	if not value is Dictionary:
		return {}
	return value.duplicate()

func get_location_search_noise(location_id: StringName) -> int:
	var location_value: Variant = _known_locations.get(location_id)
	if not location_value is Dictionary:
		return 0
	return int(location_value.get("search_noise", 0))

func is_location_search_dangerous(location_id: StringName) -> bool:
	return get_location_search_noise(location_id) >= LOCATION_NOISE_DANGER_THRESHOLD

func record_location_search_noise(location_id: StringName, noise_generated: int) -> Dictionary:
	if location_id == &"" or noise_generated < 0:
		return {"ok": false, "message": "地点噪声数据无效。"}
	var location_value: Variant = _known_locations.get(location_id)
	if not location_value is Dictionary:
		return {"ok": false, "message": "当前地点不存在。"}
	var location_data: Dictionary = location_value
	var previous_noise: int = int(location_data.get("search_noise", 0))
	var next_noise: int = previous_noise + noise_generated
	location_data["search_noise"] = next_noise
	_known_locations[location_id] = location_data
	var threat_increased := false
	if previous_noise < LOCATION_NOISE_WARNING_THRESHOLD and next_noise >= LOCATION_NOISE_WARNING_THRESHOLD:
		var previous_threat := get_region_threat(_current_region_id)
		if previous_threat < MAX_REGION_THREAT:
			set_region_threat(_current_region_id, previous_threat + 1)
			threat_increased = true
	var message := "地点累计噪声 +%d。" % next_noise
	if threat_increased:
		message += " 噪声引来注意：区域威胁 +1。"
	if next_noise >= LOCATION_NOISE_DANGER_THRESHOLD:
		message += " 已进入危险搜索：下次搜索需要再次确认。"
	return {
		"ok": true,
		"noise_total": next_noise,
		"threat_increased": threat_increased,
		"dangerous": next_noise >= LOCATION_NOISE_DANGER_THRESHOLD,
		"message": message,
	}

func is_location_lock_unlocked(location_id: StringName, lock_id: StringName) -> bool:
	if location_id == &"" or lock_id == &"":
		return false
	var location_value: Variant = _known_locations.get(location_id)
	if not location_value is Dictionary:
		return false
	var locks_value: Variant = location_value.get("unlocked_locks", {})
	return locks_value is Dictionary and bool(locks_value.get(lock_id, false))

func unlock_location_lock(location_id: StringName, lock_id: StringName, required_item_id: StringName, minutes: int) -> Dictionary:
	return unlock_location_lock_with_item(location_id, lock_id, required_item_id, minutes, false)

func unlock_location_lock_with_item(location_id: StringName, lock_id: StringName, required_item_id: StringName, minutes: int, consume_item: bool) -> Dictionary:
	if location_id == &"" or lock_id == &"" or required_item_id == &"" or minutes <= 0:
		return {"ok": false, "message": "锁柜配置无效。"}
	var location_value: Variant = _known_locations.get(location_id)
	if not location_value is Dictionary:
		return {"ok": false, "message": "当前地点不存在。"}
	if is_location_lock_unlocked(location_id, lock_id):
		return {"ok": false, "message": "锁柜已经解锁。"}
	var required_instance_id := _find_container_item_instance(BACKPACK_ID, required_item_id)
	if required_instance_id == &"":
		return {"ok": false, "message": "背包中没有所需工具。"}
	if not spend_action(minutes, 0):
		return {"ok": false, "message": "当前无法腾出解锁所需的时间。"}
	if consume_item:
		var backpack: Variant = _containers[BACKPACK_ID]
		if not backpack.remove_quantity(required_instance_id, 1):
			return {"ok": false, "message": "工具使用未完成，背包未变化。"}
	var location_data: Dictionary = location_value
	var unlocked_locks: Dictionary = location_data.get("unlocked_locks", {})
	unlocked_locks[lock_id] = true
	location_data["unlocked_locks"] = unlocked_locks
	_known_locations[location_id] = location_data
	var item_name := ITEM_CATALOG_SCRIPT.get_display_name(required_item_id)
	var consumption_text := "，工具已消耗" if consume_item else ""
	return {"ok": true, "message": "已使用%s解锁锁柜%s。" % [item_name, consumption_text], "minutes_spent": minutes}

func get_location_search_container_snapshot(location_id: StringName, container_id: StringName) -> Dictionary:
	var location_value: Variant = _known_locations.get(location_id)
	if not location_value is Dictionary:
		return {}
	var containers_value: Variant = location_value.get("search_containers", {})
	if not containers_value is Dictionary:
		return {}
	var snapshot_value: Variant = containers_value.get(container_id, {})
	if not snapshot_value is Dictionary:
		return {}
	return snapshot_value.duplicate(true)

func store_location_search_container_snapshot(location_id: StringName, container_id: StringName, snapshot: Dictionary) -> bool:
	if not _known_locations.has(location_id) or container_id == &"":
		return false
	var search_container: Variant = SEARCH_CONTAINER_SCRIPT.new()
	if not search_container.restore_snapshot(snapshot) or search_container.get_container_id() != container_id:
		return false
	var location_data: Dictionary = _known_locations[location_id]
	var search_containers: Dictionary = location_data.get("search_containers", {})
	search_containers[container_id] = snapshot.duplicate(true)
	location_data["search_containers"] = search_containers
	_known_locations[location_id] = location_data
	return true

func get_container_snapshot(container_id: StringName) -> Dictionary:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return {}
	return container.to_snapshot()

func place_item_in_container(
	container_id: StringName,
	instance_id: StringName,
	item_id: StringName,
	width: int,
	height: int,
	weight: int,
	revealed: bool = true,
	quantity: int = 1,
) -> bool:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return false
	return container.add_item_stack(_make_available_instance_id(instance_id), item_id, 1, 1, weight, quantity, ITEM_CATALOG_SCRIPT.get_maximum_stack(item_id), revealed)

func transfer_item(source_container_id: StringName, destination_container_id: StringName, instance_id: StringName) -> bool:
	var source_container: Variant = _containers.get(source_container_id)
	if source_container == null:
		return false
	var item: Dictionary = source_container.get_item(instance_id)
	if item.is_empty():
		return false
	return transfer_quantity(source_container_id, destination_container_id, instance_id, int(item.get("quantity", 1)))

func transfer_quantity(source_container_id: StringName, destination_container_id: StringName, instance_id: StringName, quantity: int) -> bool:
	if source_container_id == destination_container_id or instance_id == &"":
		return false
	var source_container: Variant = _containers.get(source_container_id)
	var destination_container: Variant = _containers.get(destination_container_id)
	if source_container == null or destination_container == null:
		return false
	var item: Dictionary = source_container.get_item(instance_id)
	var source_quantity := int(item.get("quantity", 0))
	if item.is_empty() or quantity <= 0 or quantity > source_quantity:
		return false
	var destination_instance_id := instance_id if quantity == source_quantity else _make_available_instance_id(instance_id)
	if not destination_container.can_add_item_stack(
		destination_instance_id,
		StringName(item["item_id"]),
		int(item["width"]),
		int(item["height"]),
		int(item["weight"]),
		quantity,
		int(item.get("maximum_stack", ITEM_CATALOG_SCRIPT.get_maximum_stack(StringName(item["item_id"])))),
		bool(item["revealed"]),
	):
		return false
	if not destination_container.add_item_stack(
		destination_instance_id,
		StringName(item["item_id"]),
		int(item["width"]),
		int(item["height"]),
		int(item["weight"]),
		quantity,
		int(item.get("maximum_stack", ITEM_CATALOG_SCRIPT.get_maximum_stack(StringName(item["item_id"])))),
		bool(item["revealed"]),
	):
		return false
	if source_container.remove_quantity(instance_id, quantity):
		if source_container_id == BACKPACK_ID and instance_id == _equipped_weapon_instance_id and quantity == source_quantity:
			_equipped_weapon_instance_id = &""
		return true
	return false

func split_item_stack(container_id: StringName, instance_id: StringName, quantity: int) -> bool:
	var container: Variant = _containers.get(container_id)
	if container == null or instance_id == &"" or quantity <= 0:
		return false
	var item: Dictionary = container.get_item(instance_id)
	if item.is_empty() or quantity >= int(item.get("quantity", 0)):
		return false
	return container.split_stack(instance_id, _make_available_instance_id(StringName("%s_split" % instance_id)), quantity)

func use_item_in_container(container_id: StringName, instance_id: StringName) -> Dictionary:
	var container: Variant = _containers.get(container_id)
	if container == null or instance_id == &"":
		return {"ok": false, "message": "物品不存在，无法使用。"}
	var item: Dictionary = container.get_item(instance_id)
	if item.is_empty() or int(item.get("quantity", 0)) <= 0:
		return {"ok": false, "message": "物品不存在，无法使用。"}
	var item_id: StringName = StringName(item["item_id"])
	var action_id: StringName = ITEM_CATALOG_SCRIPT.get_use_action(item_id)
	if action_id == ITEM_CATALOG_SCRIPT.USE_ACTION_NONE:
		return {"ok": false, "message": "该物品当前不能直接使用。"}
	var message: String = ""
	match action_id:
		ITEM_CATALOG_SCRIPT.USE_ACTION_DRINK:
			if _survivor.get_condition_level(&"thirst") <= 0:
				return {"ok": false, "message": "当前不口渴：饮用水未消耗。"}
			message = "饮用水已使用，口渴等级 -1。"
		ITEM_CATALOG_SCRIPT.USE_ACTION_HEAL:
			if _survivor.get_health() >= SURVIVOR_STATE_SCRIPT.MAX_HEALTH:
				return {"ok": false, "message": "生命已满：急救包未消耗。"}
			message = "急救包已使用，生命 +%d。" % min(25, SURVIVOR_STATE_SCRIPT.MAX_HEALTH - _survivor.get_health())
		ITEM_CATALOG_SCRIPT.USE_ACTION_BANDAGE:
			var injuries: Array[StringName] = _survivor.get_injury_ids()
			if injuries.is_empty():
				return {"ok": false, "message": "没有可处理的创伤：绷带未消耗。"}
			message = "绷带已使用，处理创伤：%s。" % injuries[0]
	if not spend_action(5, 0):
		return {"ok": false, "message": "当前无法腾出使用物品所需的时间。"}
	match action_id:
		ITEM_CATALOG_SCRIPT.USE_ACTION_DRINK:
			_survivor.change_condition(&"thirst", -1)
		ITEM_CATALOG_SCRIPT.USE_ACTION_HEAL:
			_survivor.heal(25)
		ITEM_CATALOG_SCRIPT.USE_ACTION_BANDAGE:
			_survivor.remove_injury(_survivor.get_injury_ids()[0])
	if not container.remove_quantity(instance_id, 1):
		return {"ok": false, "message": "物品使用未完成，库存未变化。"}
	return {"ok": true, "message": message, "item_id": item_id}

func move_item_in_container(container_id: StringName, instance_id: StringName, x: int, y: int) -> bool:
	var container: Variant = _containers.get(container_id)
	if container == null or instance_id == &"":
		return false
	var item: Dictionary = container.get_item(instance_id)
	if item.is_empty() or (int(item["x"]) == x and int(item["y"]) == y):
		return false
	if not container.remove_item(instance_id):
		return false
	if container.place_item(instance_id, StringName(item["item_id"]), int(item["width"]), int(item["height"]), int(item["weight"]), x, y, bool(item["revealed"]), int(item.get("quantity", 1)), int(item.get("maximum_stack", 1))):
		return true
	container.place_item(instance_id, StringName(item["item_id"]), int(item["width"]), int(item["height"]), int(item["weight"]), int(item["x"]), int(item["y"]), bool(item["revealed"]), int(item.get("quantity", 1)), int(item.get("maximum_stack", 1)))
	return false

func transfer_item_to_position(source_container_id: StringName, destination_container_id: StringName, instance_id: StringName, x: int, y: int) -> bool:
	if source_container_id == destination_container_id:
		return move_item_in_container(source_container_id, instance_id, x, y)
	if instance_id == &"":
		return false
	var source_container: Variant = _containers.get(source_container_id)
	var destination_container: Variant = _containers.get(destination_container_id)
	if source_container == null or destination_container == null:
		return false
	var item: Dictionary = source_container.get_item(instance_id)
	if item.is_empty():
		return false
	if not destination_container.place_item(instance_id, StringName(item["item_id"]), int(item["width"]), int(item["height"]), int(item["weight"]), x, y, bool(item["revealed"]), int(item.get("quantity", 1)), int(item.get("maximum_stack", 1))):
		return false
	if source_container.remove_item(instance_id):
		if source_container_id == BACKPACK_ID and instance_id == _equipped_weapon_instance_id:
			_equipped_weapon_instance_id = &""
		return true
	destination_container.remove_item(instance_id)
	return false

func get_container_items(container_id: StringName) -> Array[Dictionary]:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return []
	return container.get_items()

func get_container_total_weight(container_id: StringName) -> int:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return 0
	return int(container.get_total_weight())

func get_container_maximum_weight(container_id: StringName) -> int:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return 0
	return int(container.get_maximum_weight())

func get_container_occupied_slot_count(container_id: StringName) -> int:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return 0
	return int(container.get_occupied_slot_count())

func get_container_capacity(container_id: StringName) -> int:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return 0
	return int(container.get_capacity())

func to_snapshot() -> Dictionary:
	var containers_snapshot: Dictionary = {}
	for container_id in CONTAINER_IDS:
		containers_snapshot[container_id] = _containers[container_id].to_snapshot()
	return {
		"version": SNAPSHOT_VERSION,
		"timeline_kind": TIMELINE_KIND,
		"game_session": _clock.to_snapshot(),
		"survivor": _survivor.to_snapshot(),
		"containers": containers_snapshot,
		"current_region_id": _current_region_id,
		"region_threat": _region_threat.duplicate(),
		"known_locations": _known_locations.duplicate(true),
		"home_power": _home_power,
		"shelter_facilities": _shelter_facilities.to_snapshot() if _shelter_facilities != null else {},
		"equipment": {"weapon_instance_id": _equipped_weapon_instance_id},
		"campaign": {
			"first_raid_resolved": _first_raid_resolved,
			"first_raid_result": _first_raid_result.duplicate(true),
			"day_five_event_state": _day_five_event_state,
			"day_five_event_result": _day_five_event_result.duplicate(true),
			"day_six_event_state": _day_six_event_state,
			"day_six_event_result": _day_six_event_result.duplicate(true),
			"day_seven_event_state": _day_seven_event_state,
			"day_seven_event_result": _day_seven_event_result.duplicate(true),
		},
	}

func restore_snapshot(rules: GameRules, snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	if StringName(snapshot.get("timeline_kind", "")) != TIMELINE_KIND:
		return false

	var clock_value: Variant = snapshot.get("game_session")
	var survivor_value: Variant = snapshot.get("survivor")
	var containers_value: Variant = snapshot.get("containers")
	var region_threat_value: Variant = snapshot.get("region_threat")
	var known_locations_value: Variant = snapshot.get("known_locations")
	var home_power: int = int(snapshot.get("home_power", 0))
	var shelter_facilities_value: Variant = snapshot.get("shelter_facilities", {})
	var equipment_value: Variant = snapshot.get("equipment", {})
	var campaign_value: Variant = snapshot.get("campaign", {})
	if not clock_value is Dictionary or not survivor_value is Dictionary or not containers_value is Dictionary:
		return false
	if not region_threat_value is Dictionary or not known_locations_value is Dictionary:
		return false
	if not equipment_value is Dictionary or not campaign_value is Dictionary:
		return false
	if not shelter_facilities_value is Dictionary:
		return false
	if home_power < 0 or home_power > MAX_HOME_POWER:
		return false

	var restored_clock: Variant = GAME_SESSION_SCRIPT.new()
	if not restored_clock.restore_snapshot(rules, clock_value):
		return false
	var restored_survivor: Variant = SURVIVOR_STATE_SCRIPT.new()
	if not restored_survivor.restore_snapshot(survivor_value):
		return false
	var restored_shelter_facilities: Variant = SHELTER_FACILITIES_SCRIPT.new()
	if shelter_facilities_value.is_empty():
		restored_shelter_facilities.start_new_game(restored_clock.get_day())
	elif not restored_shelter_facilities.restore_snapshot(shelter_facilities_value):
		return false
	else:
		restored_shelter_facilities.advance_to_day(restored_clock.get_day())

	var restored_containers: Dictionary = {}
	for container_id in CONTAINER_IDS:
		var container_value: Variant = containers_value.get(container_id)
		if not container_value is Dictionary:
			if container_id == HOME_STORAGE_ID:
				restored_containers[HOME_STORAGE_ID] = _new_container(8, 6, 80)
				continue
			return false
		var container: Variant = GRID_CONTAINER_SCRIPT.new()
		if not container.restore_snapshot(container_value):
			return false
		restored_containers[container_id] = _normalize_container_stacks(container)

	var restored_threat: Dictionary = {}
	for region_value in region_threat_value:
		var region_id := StringName(region_value)
		var level: int = int(region_threat_value[region_value])
		if region_id == &"" or level < 0 or level > MAX_REGION_THREAT:
			return false
		restored_threat[region_id] = level
	if restored_threat.is_empty():
		return false

	var restored_locations: Dictionary = {}
	for location_value in known_locations_value:
		var location_id := StringName(location_value)
		var location_data: Variant = known_locations_value[location_value]
		if location_id == &"" or not location_data is Dictionary:
			return false
		var location_type := StringName(location_data.get("location_type", ""))
		var state := StringName(location_data.get("state", ""))
		if location_type == &"" or state not in VALID_LOCATION_STATES:
			return false
		var restored_search_containers: Dictionary = {}
		var search_containers_value: Variant = location_data.get("search_containers", {})
		if not search_containers_value is Dictionary:
			return false
		for container_value in search_containers_value:
			var container_id := StringName(container_value)
			var container_snapshot: Variant = search_containers_value[container_value]
			if container_id == &"" or not container_snapshot is Dictionary:
				return false
			var search_container: Variant = SEARCH_CONTAINER_SCRIPT.new()
			if not search_container.restore_snapshot(container_snapshot) or search_container.get_container_id() != container_id:
				return false
			restored_search_containers[container_id] = container_snapshot.duplicate(true)
		var restored_unlocked_locks: Dictionary = {}
		var unlocked_locks_value: Variant = location_data.get("unlocked_locks", {})
		if not unlocked_locks_value is Dictionary:
			return false
		for lock_value in unlocked_locks_value:
			var lock_id := StringName(lock_value)
			if lock_id == &"" or not bool(unlocked_locks_value[lock_value]):
				return false
			restored_unlocked_locks[lock_id] = true
		var search_noise: int = int(location_data.get("search_noise", 0))
		if search_noise < 0:
			return false
		restored_locations[location_id] = {
			"location_type": location_type,
			"state": state,
			"search_containers": restored_search_containers,
			"unlocked_locks": restored_unlocked_locks,
			"search_noise": search_noise,
		}

	var restored_region_id := StringName(snapshot.get("current_region_id", ""))
	if restored_region_id == &"":
		return false
	var restored_weapon_instance_id := StringName(equipment_value.get("weapon_instance_id", ""))
	if restored_weapon_instance_id != &"":
		var restored_weapon: Dictionary = restored_containers[BACKPACK_ID].get_item(restored_weapon_instance_id)
		if restored_weapon.is_empty() or not ITEM_CATALOG_SCRIPT.is_weapon(StringName(restored_weapon.get("item_id", ""))):
			return false
	var restored_first_raid_resolved := bool(campaign_value.get("first_raid_resolved", false))
	var restored_first_raid_result: Variant = campaign_value.get("first_raid_result", {})
	if not restored_first_raid_result is Dictionary:
		return false
	if restored_first_raid_resolved:
		var restored_outcome := StringName(restored_first_raid_result.get("outcome", ""))
		var restored_score := int(restored_first_raid_result.get("score", -1))
		if restored_outcome not in [&"held", &"overrun"] or restored_score < 0 or restored_score > 3:
			return false
	var default_event_state: StringName = EVENT_STATE_PENDING if restored_first_raid_resolved and restored_clock.get_day() >= DAY_FIVE_EVENT_DAY else EVENT_STATE_NOT_STARTED
	var restored_day_five_event_state := StringName(campaign_value.get("day_five_event_state", default_event_state))
	var restored_day_five_event_result: Variant = campaign_value.get("day_five_event_result", {})
	if restored_day_five_event_state not in VALID_EVENT_STATES or not restored_day_five_event_result is Dictionary:
		return false
	if restored_day_five_event_state != EVENT_STATE_NOT_STARTED and (not restored_first_raid_resolved or restored_clock.get_day() < DAY_FIVE_EVENT_DAY):
		return false
	if restored_day_five_event_state == EVENT_STATE_RESOLVED:
		if StringName(restored_day_five_event_result.get("event_id", "")) != DAY_FIVE_EVENT_ID:
			return false
		var restored_choice_id := StringName(restored_day_five_event_result.get("choice_id", ""))
		if restored_choice_id not in [DAY_FIVE_POWER_CHOICE_ID, DAY_FIVE_ROOFTOP_CHOICE_ID]:
			return false
	var default_day_six_event_state: StringName = EVENT_STATE_PENDING if (
		restored_first_raid_resolved
		and restored_day_five_event_state == EVENT_STATE_RESOLVED
		and restored_clock.get_day() >= DAY_SIX_EVENT_DAY
	) else EVENT_STATE_NOT_STARTED
	var restored_day_six_event_state := StringName(campaign_value.get("day_six_event_state", default_day_six_event_state))
	var restored_day_six_event_result: Variant = campaign_value.get("day_six_event_result", {})
	if restored_day_six_event_state not in VALID_EVENT_STATES or not restored_day_six_event_result is Dictionary:
		return false
	if restored_day_six_event_state != EVENT_STATE_NOT_STARTED and (
		not restored_first_raid_resolved
		or restored_day_five_event_state != EVENT_STATE_RESOLVED
		or restored_clock.get_day() < DAY_SIX_EVENT_DAY
	):
		return false
	if restored_day_six_event_state == EVENT_STATE_RESOLVED:
		if StringName(restored_day_six_event_result.get("event_id", "")) != DAY_SIX_EVENT_ID:
			return false
		var restored_day_six_choice_id := StringName(restored_day_six_event_result.get("choice_id", ""))
		if restored_day_six_choice_id not in [DAY_SIX_RECOVER_CHOICE_ID, DAY_SIX_ABANDON_CHOICE_ID]:
			return false
	var default_day_seven_event_state: StringName = EVENT_STATE_PENDING if (
		restored_first_raid_resolved
		and restored_day_five_event_state == EVENT_STATE_RESOLVED
		and restored_day_six_event_state == EVENT_STATE_RESOLVED
		and restored_clock.get_day() >= DAY_SEVEN_EVENT_DAY
	) else EVENT_STATE_NOT_STARTED
	var restored_day_seven_event_state := StringName(campaign_value.get("day_seven_event_state", default_day_seven_event_state))
	var restored_day_seven_event_result: Variant = campaign_value.get("day_seven_event_result", {})
	if restored_day_seven_event_state not in VALID_EVENT_STATES or not restored_day_seven_event_result is Dictionary:
		return false
	if restored_day_seven_event_state != EVENT_STATE_NOT_STARTED and (
		not restored_first_raid_resolved
		or restored_day_five_event_state != EVENT_STATE_RESOLVED
		or restored_day_six_event_state != EVENT_STATE_RESOLVED
		or restored_clock.get_day() < DAY_SEVEN_EVENT_DAY
	):
		return false
	if restored_day_seven_event_state == EVENT_STATE_RESOLVED:
		if StringName(restored_day_seven_event_result.get("event_id", "")) != DAY_SEVEN_EVENT_ID:
			return false
		var restored_day_seven_choice_id := StringName(restored_day_seven_event_result.get("choice_id", ""))
		if restored_day_seven_choice_id not in [DAY_SEVEN_WIRE_CHOICE_ID, DAY_SEVEN_MANUAL_CHOICE_ID]:
			return false

	_clock = restored_clock
	_survivor = restored_survivor
	_containers = restored_containers
	_current_region_id = restored_region_id
	_region_threat = restored_threat
	_known_locations = restored_locations
	_home_power = home_power
	_equipped_weapon_instance_id = restored_weapon_instance_id
	_first_raid_resolved = restored_first_raid_resolved
	_first_raid_result = restored_first_raid_result.duplicate(true)
	_day_five_event_state = restored_day_five_event_state
	_day_five_event_result = restored_day_five_event_result.duplicate(true)
	_day_six_event_state = restored_day_six_event_state
	_day_six_event_result = restored_day_six_event_result.duplicate(true)
	_day_seven_event_state = restored_day_seven_event_state
	_day_seven_event_result = restored_day_seven_event_result.duplicate(true)
	_shelter_facilities = restored_shelter_facilities
	return true

func _get_first_raid_readiness() -> Dictionary:
	var power_ready := _home_power >= FIRST_RAID_POWER_REQUIREMENT
	var medkit_ready := get_container_item_quantity(HOME_STORAGE_ID, &"medkit") >= FIRST_RAID_MEDKIT_REQUIREMENT
	var weapon_ready := _has_raid_weapon()
	return {
		"score": int(power_ready) + int(medkit_ready) + int(weapon_ready),
		"power_ready": power_ready,
		"medkit_ready": medkit_ready,
		"weapon_ready": weapon_ready,
	}

func _has_raid_weapon() -> bool:
	for container_id in [BACKPACK_ID, HOME_STORAGE_ID]:
		var container: Variant = _containers.get(container_id)
		if container == null:
			continue
		for item in container.get_items():
			if ITEM_CATALOG_SCRIPT.is_weapon(StringName(item.get("item_id", ""))):
				return true
	return false

func _resolve_first_raid() -> Dictionary:
	var readiness := _get_first_raid_readiness()
	var score := int(readiness["score"])
	var outcome: StringName = &"held" if score >= FIRST_RAID_REQUIRED_SCORE else &"overrun"
	var power_spent := mini(_home_power, FIRST_RAID_POWER_COST)
	_home_power -= power_spent
	var damage_taken := 0
	if outcome == &"overrun":
		damage_taken = int(_survivor.apply_damage(FIRST_RAID_FAILURE_DAMAGE))
		_survivor.add_injury(&"raid_wound")
		var threat := get_region_threat(_current_region_id)
		_region_threat[_current_region_id] = mini(threat + 1, MAX_REGION_THREAT)
	_first_raid_resolved = true
	_first_raid_result = {
		"first_raid_day": FIRST_RAID_DAY,
		"resolved": true,
		"outcome": outcome,
		"score": score,
		"required_score": FIRST_RAID_REQUIRED_SCORE,
		"power_ready": bool(readiness["power_ready"]),
		"medkit_ready": bool(readiness["medkit_ready"]),
		"weapon_ready": bool(readiness["weapon_ready"]),
		"power_spent": power_spent,
		"damage_taken": damage_taken,
	}
	var outcome_text := "守住了第一轮袭击" if outcome == &"held" else "家园失守一角，但你活了下来"
	_first_raid_result["message"] = "%s。准备评分 %d/3（守住需要 %d）；防守消耗电力 %d%s。演示主流程已完成，可继续整理与探索。" % [
		outcome_text,
		score,
		FIRST_RAID_REQUIRED_SCORE,
		power_spent,
		"，生命 -%d 并留下袭击创伤" % damage_taken if damage_taken > 0 else "",
	]
	return {
		"ok": true,
		"raid_resolved": true,
		"message": String(_first_raid_result["message"]),
		"campaign": _first_raid_result.duplicate(true),
	}

func _new_container(columns: int, rows: int, maximum_weight: int) -> Variant:
	return GRID_CONTAINER_SCRIPT.new(columns, rows, maximum_weight)

func _normalize_container_stacks(container: Variant) -> Variant:
	var normalized: Variant = _new_container(container.get_columns(), container.get_rows(), container.get_maximum_weight())
	for item in container.get_items():
		var item_id := StringName(item["item_id"])
		if not normalized.add_item_stack(
			StringName(item["instance_id"]),
			item_id,
			1,
			1,
			int(item["weight"]),
			int(item.get("quantity", 1)),
			ITEM_CATALOG_SCRIPT.get_maximum_stack(item_id),
			bool(item["revealed"]),
		):
			return container
	return normalized

func _make_available_instance_id(requested_instance_id: StringName) -> StringName:
	if requested_instance_id == &"":
		return &""
	if not _is_instance_id_in_use(requested_instance_id):
		return requested_instance_id
	var suffix := 2
	while true:
		var candidate := StringName("%s_%d" % [requested_instance_id, suffix])
		if not _is_instance_id_in_use(candidate):
			return candidate
		suffix += 1
	return requested_instance_id

func _is_instance_id_in_use(instance_id: StringName) -> bool:
	for container_id in CONTAINER_IDS:
		var container: Variant = _containers.get(container_id)
		if container != null and not container.get_item(instance_id).is_empty():
			return true
	return false

func _container_has_item(container_id: StringName, item_id: StringName) -> bool:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return false
	for item in container.get_items():
		if StringName(item.get("item_id", "")) == item_id and int(item.get("quantity", 0)) > 0:
			return true
	return false

func _find_container_item_instance(container_id: StringName, item_id: StringName) -> StringName:
	var container: Variant = _containers.get(container_id)
	if container == null:
		return &""
	for item in container.get_items():
		if StringName(item.get("item_id", "")) == item_id and int(item.get("quantity", 0)) > 0:
			return StringName(item.get("instance_id", ""))
	return &""
