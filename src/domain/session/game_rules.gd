class_name GameRules
extends Resource

const DEFAULT_STARTING_MINUTE := 6 * 60
const DEFAULT_MAXIMUM_STAMINA := 100
const WEATHER_SUNNY := &"sunny"
const WEATHER_OVERCAST := &"overcast"
const WEATHER_RAIN := &"rain"

@export_range(0, 1_439, 1) var starting_minute: int = DEFAULT_STARTING_MINUTE
@export_range(1, 9_999, 1) var maximum_stamina: int = DEFAULT_MAXIMUM_STAMINA
@export_range(1, 56, 1) var days_per_season: int = 28
@export var season_names: PackedStringArray = PackedStringArray(["春", "夏", "秋", "冬"])
@export var default_world_seed: int = 20_260_725
@export_range(0, 100, 1) var sunny_weather_weight: int = 55
@export_range(0, 100, 1) var overcast_weather_weight: int = 30
@export_range(0, 100, 1) var rain_weather_weight: int = 15

func get_season_name(total_day: int) -> String:
	assert(total_day >= 1, "A calendar day must be at least one.")
	if season_names.is_empty():
		return "春"
	var season_index := ((total_day - 1) / days_per_season) % season_names.size()
	return season_names[season_index]

func get_day_of_season(total_day: int) -> int:
	assert(total_day >= 1, "A calendar day must be at least one.")
	return (total_day - 1) % days_per_season + 1

func get_weather_for_day(total_day: int, world_seed: int) -> StringName:
	assert(total_day >= 1, "Weather requires a valid calendar day.")
	var total_weight := sunny_weather_weight + overcast_weather_weight + rain_weather_weight
	assert(total_weight > 0, "At least one weather weight must be positive.")
	var roll := posmod(world_seed + total_day * 104_729, total_weight)
	if roll < sunny_weather_weight:
		return WEATHER_SUNNY
	if roll < sunny_weather_weight + overcast_weather_weight:
		return WEATHER_OVERCAST
	return WEATHER_RAIN

func get_weather_display_name(weather_id: StringName) -> String:
	match weather_id:
		WEATHER_SUNNY:
			return "晴"
		WEATHER_OVERCAST:
			return "阴"
		WEATHER_RAIN:
			return "雨"
		_:
			return "未知"
