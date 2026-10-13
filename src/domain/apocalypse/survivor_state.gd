class_name SurvivorState
extends RefCounted

const SNAPSHOT_VERSION := 1
const MAX_HEALTH := 100
const MAX_INFECTION_RISK := 100

const CONDITION_IDS := [&"hunger", &"thirst", &"fatigue", &"stress"]
const ATTRIBUTE_IDS := [&"fitness", &"reaction", &"observation", &"knowledge", &"will", &"negotiation"]

var _attributes: Dictionary = {}
var _health := MAX_HEALTH
var _condition_levels: Dictionary = {}
var _injuries: Array[StringName] = []
var _infection_risk := 0

func start_new_game(attribute_modifiers: Dictionary = {}) -> void:
	_attributes.clear()
	for attribute_id in ATTRIBUTE_IDS:
		_attributes[attribute_id] = 0
	for attribute_id in attribute_modifiers:
		var normalized_id := StringName(attribute_id)
		assert(normalized_id in ATTRIBUTE_IDS, "Unknown survivor attribute: %s" % normalized_id)
		var modifier: int = int(attribute_modifiers[attribute_id])
		assert(modifier >= -3 and modifier <= 3, "Survivor attribute modifiers must stay between -3 and 3.")
		_attributes[normalized_id] = modifier

	_health = MAX_HEALTH
	_condition_levels.clear()
	for condition_id in CONDITION_IDS:
		_condition_levels[condition_id] = 0
	_injuries.clear()
	_infection_risk = 0

func get_attribute(attribute_id: StringName) -> int:
	assert(attribute_id in ATTRIBUTE_IDS, "Unknown survivor attribute: %s" % attribute_id)
	return int(_attributes.get(attribute_id, 0))

func get_health() -> int:
	return _health

func change_condition(condition_id: StringName, amount: int) -> int:
	assert(condition_id in CONDITION_IDS, "Unknown survivor condition: %s" % condition_id)
	var next_level: int = clampi(int(_condition_levels.get(condition_id, 0)) + amount, 0, 3)
	_condition_levels[condition_id] = next_level
	return next_level

func get_condition_level(condition_id: StringName) -> int:
	assert(condition_id in CONDITION_IDS, "Unknown survivor condition: %s" % condition_id)
	return int(_condition_levels.get(condition_id, 0))

func apply_damage(amount: int) -> int:
	assert(amount >= 0, "Damage cannot be negative.")
	var applied: int = min(amount, _health)
	_health -= applied
	return applied

func heal(amount: int) -> int:
	assert(amount >= 0, "Healing cannot be negative.")
	var restored: int = min(amount, MAX_HEALTH - _health)
	_health += restored
	return restored

func add_injury(injury_id: StringName) -> bool:
	assert(injury_id != &"", "Injuries require a stable injury_id.")
	if injury_id in _injuries:
		return false
	_injuries.append(injury_id)
	return true

func has_injury(injury_id: StringName) -> bool:
	return injury_id in _injuries

func get_injury_ids() -> Array[StringName]:
	return _injuries.duplicate()

func remove_injury(injury_id: StringName) -> bool:
	var index := _injuries.find(injury_id)
	if index < 0:
		return false
	_injuries.remove_at(index)
	return true

func add_infection_risk(amount: int) -> int:
	assert(amount >= 0, "Infection risk cannot decrease through this method.")
	_infection_risk = mini(_infection_risk + amount, MAX_INFECTION_RISK)
	return _infection_risk

func reduce_infection_risk(amount: int) -> int:
	assert(amount >= 0, "Infection-risk reduction cannot be negative.")
	var reduced: int = min(amount, _infection_risk)
	_infection_risk -= reduced
	return reduced

func get_infection_hint() -> String:
	if _infection_risk >= MAX_INFECTION_RISK:
		return "不可逆感染"
	if _infection_risk >= 80:
		return "病情恶化"
	if _infection_risk >= 50:
		return "出现异常症状"
	if _infection_risk >= 25:
		return "可能暴露"
	return "暂无明显症状"

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"attributes": _attributes.duplicate(),
		"health": _health,
		"condition_levels": _condition_levels.duplicate(),
		"injuries": get_injury_ids(),
		"infection_risk": _infection_risk,
	}

func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false

	var attributes_value: Variant = snapshot.get("attributes")
	var health_value: int = int(snapshot.get("health", -1))
	var conditions_value: Variant = snapshot.get("condition_levels")
	var injuries_value: Variant = snapshot.get("injuries")
	var infection_risk_value: int = int(snapshot.get("infection_risk", -1))
	if not attributes_value is Dictionary or not conditions_value is Dictionary or not injuries_value is Array:
		return false
	if health_value < 0 or health_value > MAX_HEALTH or infection_risk_value < 0 or infection_risk_value > MAX_INFECTION_RISK:
		return false

	var restored_attributes: Dictionary = {}
	for attribute_id in ATTRIBUTE_IDS:
		var modifier: int = int(attributes_value.get(attribute_id, 0))
		if modifier < -3 or modifier > 3:
			return false
		restored_attributes[attribute_id] = modifier

	var restored_conditions: Dictionary = {}
	for condition_id in CONDITION_IDS:
		var level: int = int(conditions_value.get(condition_id, -1))
		if level < 0 or level > 3:
			return false
		restored_conditions[condition_id] = level

	var restored_injuries: Array[StringName] = []
	for injury_value in injuries_value:
		var injury_id := StringName(injury_value)
		if injury_id == &"" or injury_id in restored_injuries:
			return false
		restored_injuries.append(injury_id)

	_attributes = restored_attributes
	_health = health_value
	_condition_levels = restored_conditions
	_injuries = restored_injuries
	_infection_risk = infection_risk_value
	return true
