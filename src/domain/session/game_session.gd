class_name GameSession
extends RefCounted

const MINUTES_PER_DAY := 24 * 60
const SNAPSHOT_VERSION := 2
const LEGACY_SNAPSHOT_VERSION := 1

var _rules: GameRules
var _day: int
var _minute_of_day: int
var _stamina: int
var _world_seed: int
var _weather_id: StringName
var _forecast_weather_id: StringName

func start_new_game(rules: GameRules) -> void:
	assert(rules != null, "A game session requires a rules profile.")

	_rules = rules
	_day = 1
	_minute_of_day = rules.starting_minute
	_stamina = rules.maximum_stamina
	_world_seed = rules.default_world_seed
	_refresh_weather()

func get_day() -> int:
	return _day

func get_clock_text() -> String:
	return "%02d:%02d" % [_minute_of_day / 60, _minute_of_day % 60]

func get_stamina() -> int:
	return _stamina

func get_season_name() -> String:
	return _rules.get_season_name(_day)

func get_day_of_season() -> int:
	return _rules.get_day_of_season(_day)

func get_weather_id() -> StringName:
	return _weather_id

func get_world_seed() -> int:
	return _world_seed

func get_weather_text() -> String:
	return _rules.get_weather_display_name(_weather_id)

func get_forecast_text() -> String:
	return _rules.get_weather_display_name(_forecast_weather_id)

func advance_minutes(minutes: int) -> int:
	assert(minutes >= 0, "Time cannot move backwards in a normal timeline.")

	var total_minutes := _minute_of_day + minutes
	var elapsed_days := total_minutes / MINUTES_PER_DAY
	_day += elapsed_days
	_minute_of_day = total_minutes % MINUTES_PER_DAY
	if elapsed_days > 0:
		_refresh_weather()
	return elapsed_days

func consume_stamina(amount: int) -> int:
	assert(amount >= 0, "Stamina consumption cannot be negative.")

	var spent: int = min(amount, _stamina)
	_stamina -= spent
	return spent

func sleep() -> void:
	_day += 1
	_minute_of_day = _rules.starting_minute
	_stamina = _rules.maximum_stamina
	_refresh_weather()

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"day": _day,
		"minute_of_day": _minute_of_day,
		"stamina": _stamina,
		"world_seed": _world_seed,
	}

func restore_snapshot(rules: GameRules, snapshot: Dictionary) -> bool:
	assert(rules != null, "A restored game session requires a rules profile.")

	var version: int = int(snapshot.get("version", 0))
	var day: int = int(snapshot.get("day", 0))
	var minute_of_day: int = int(snapshot.get("minute_of_day", -1))
	var stamina: int = int(snapshot.get("stamina", -1))
	if version != SNAPSHOT_VERSION and version != LEGACY_SNAPSHOT_VERSION:
		return false
	if day < 1 or minute_of_day < 0 or minute_of_day >= MINUTES_PER_DAY:
		return false
	if stamina < 0 or stamina > rules.maximum_stamina:
		return false

	_rules = rules
	_day = day
	_minute_of_day = minute_of_day
	_stamina = stamina
	_world_seed = int(snapshot.get("world_seed", rules.default_world_seed))
	_refresh_weather()
	return true

func _refresh_weather() -> void:
	_weather_id = _rules.get_weather_for_day(_day, _world_seed)
	_forecast_weather_id = _rules.get_weather_for_day(_day + 1, _world_seed)
