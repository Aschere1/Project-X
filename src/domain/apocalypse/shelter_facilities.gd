class_name ApocalypseShelterFacilities
extends RefCounted

## Pure persistent state for the facilities represented on the static apocalypse shelter map.
## It deliberately knows stable facility IDs and daily maintenance only; scenes own
## hotspot rectangles, artwork, labels, and navigation.

const SNAPSHOT_VERSION := 1

const MAIN_HOUSE_ID := &"main_house"
const CHICKEN_COOP_ID := &"chicken_coop"
const LIVESTOCK_PENS_ID := &"livestock_pens"
const FACILITY_IDS: Array[StringName] = [MAIN_HOUSE_ID, CHICKEN_COOP_ID, LIVESTOCK_PENS_ID]

const ACTION_SERVICE := &"service"
const ANIMAL_FACILITY_IDS: Array[StringName] = [CHICKEN_COOP_ID, LIVESTOCK_PENS_ID]

const _DEFINITIONS := {
	MAIN_HOUSE_ID: {
		"title": "主屋",
		"summary": "床铺、医疗台、炉火和屋内工作台都集中在这里。",
		"animals": [],
	},
	CHICKEN_COOP_ID: {
		"title": "鸡棚",
		"summary": "检查鸡群、饮水桶、饲槽和围栏。当前只记录日常维护，不结算蛋品。",
		"animals": [
			{"animal_id": &"chicken", "label": "鸡群", "count": 4},
		],
		"service_label": "整理鸡棚",
		"service_minutes": 10,
		"service_stamina": 1,
	},
	LIVESTOCK_PENS_ID: {
		"title": "三联牲畜棚",
		"summary": "牛、羊、猪分栏安置；检查饮水、围栏和地面排水。当前不结算奶、毛或肉类产物。",
		"animals": [
			{"animal_id": &"cattle", "label": "黄牛", "count": 1},
			{"animal_id": &"sheep", "label": "山羊", "count": 1},
			{"animal_id": &"pig", "label": "猪", "count": 1},
		],
		"service_label": "巡检牲畜棚",
		"service_minutes": 15,
		"service_stamina": 1,
	},
}

var _tracked_day := 1
var _last_service_day: Dictionary = {}


func start_new_game(day: int = 1) -> void:
	assert(day >= 1, "Shelter facilities require a valid calendar day.")
	_tracked_day = day
	_last_service_day = {
		CHICKEN_COOP_ID: 0,
		LIVESTOCK_PENS_ID: 0,
	}


func advance_to_day(day: int) -> void:
	assert(day >= 1, "Shelter facilities require a valid calendar day.")
	if day > _tracked_day:
		_tracked_day = day


func get_facility_snapshot(facility_id: StringName, current_day: int) -> Dictionary:
	advance_to_day(current_day)
	var definition_value: Variant = _DEFINITIONS.get(facility_id, {})
	if not definition_value is Dictionary:
		return {}
	var facility: Dictionary = definition_value.duplicate(true)
	facility["facility_id"] = facility_id
	facility["day"] = _tracked_day
	if not ANIMAL_FACILITY_IDS.has(facility_id):
		facility["status"] = &"ready"
		facility["status_text"] = "屋内设施可用；从场景中的固定功能点进入。"
		facility["actions"] = []
		return facility
	var last_service_day: int = int(_last_service_day.get(facility_id, 0))
	var serviced_today := last_service_day == _tracked_day
	facility["status"] = &"serviced_today" if serviced_today else &"needs_service"
	facility["status_text"] = "今天已完成巡检和整理。" if serviced_today else "今天尚未巡检；完成后会记录到安全区设施状态。"
	facility["last_service_day"] = last_service_day
	facility["actions"] = [{
		"action_id": ACTION_SERVICE,
		"label": String(facility.get("service_label", "维护设施")),
		"minutes": int(facility.get("service_minutes", 0)),
		"stamina": int(facility.get("service_stamina", 0)),
		"available": not serviced_today,
		"unavailable_reason": "今天已经完成维护。" if serviced_today else "",
	}]
	return facility


func perform_action(facility_id: StringName, action_id: StringName, current_day: int) -> Dictionary:
	advance_to_day(current_day)
	if not ANIMAL_FACILITY_IDS.has(facility_id):
		return {"ok": false, "message": "该设施没有可执行的日常维护动作。"}
	if action_id != ACTION_SERVICE:
		return {"ok": false, "message": "未知的设施动作。"}
	if int(_last_service_day.get(facility_id, 0)) == _tracked_day:
		return {"ok": false, "message": "今天已经完成维护。"}
	_last_service_day[facility_id] = _tracked_day
	var definition: Dictionary = _DEFINITIONS[facility_id]
	return {
		"ok": true,
		"facility_id": facility_id,
		"action_id": action_id,
		"message": "%s完成：饮水、围栏和地面已检查。" % String(definition.get("service_label", "设施维护")),
		"facility": get_facility_snapshot(facility_id, _tracked_day),
	}


func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"tracked_day": _tracked_day,
		"last_service_day": _last_service_day.duplicate(),
	}


func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	var tracked_day: int = int(snapshot.get("tracked_day", 0))
	var last_service_value: Variant = snapshot.get("last_service_day", {})
	if tracked_day < 1 or not last_service_value is Dictionary:
		return false
	var restored_services: Dictionary = {}
	for facility_id in ANIMAL_FACILITY_IDS:
		var service_day: int = int(last_service_value.get(facility_id, 0))
		if service_day < 0 or service_day > tracked_day:
			return false
		restored_services[facility_id] = service_day
	_tracked_day = tracked_day
	_last_service_day = restored_services
	return true
