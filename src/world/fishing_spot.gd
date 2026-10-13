class_name FishingSpot
extends GridInteractable

const SNAPSHOT_VERSION := 1
const SOURCE_KIND := &"fishing"

@export var source_catalog: FoodSourceCatalog
@export_range(1, 10, 1) var daily_catch_limit := 3
var _tracked_day := 0
var _catches_today := 0

func _ready() -> void:
	super._ready()
	assert(source_catalog != null, "FishingSpot requires a food source catalog.")

func get_remaining_catches(total_day: int) -> int:
	_ensure_day(total_day)
	return max(0, daily_catch_limit - _catches_today)

func preview_reward(total_day: int, weather_id: StringName, world_seed: int) -> Dictionary:
	_ensure_day(total_day)
	if _catches_today >= daily_catch_limit:
		return {}
	return source_catalog.resolve_reward(SOURCE_KIND, weather_id, total_day, world_seed, interaction_id, _catches_today)

func record_catch(total_day: int) -> void:
	_ensure_day(total_day)
	assert(_catches_today < daily_catch_limit, "Fishing cannot exceed its daily catch limit.")
	_catches_today += 1

func refresh_for_day(total_day: int) -> void:
	_ensure_day(total_day)
	fill_color = Color("3f88a8") if get_remaining_catches(total_day) > 0 else Color("536d78")
	queue_redraw()

func to_snapshot() -> Dictionary:
	return {"version": SNAPSHOT_VERSION, "tracked_day": _tracked_day, "catches_today": _catches_today}

func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	var tracked_day := int(snapshot.get("tracked_day", -1))
	var catches_today := int(snapshot.get("catches_today", -1))
	if tracked_day < 0 or catches_today < 0 or catches_today > daily_catch_limit:
		return false
	_tracked_day = tracked_day
	_catches_today = catches_today
	return true

func _ensure_day(total_day: int) -> void:
	assert(total_day >= 1, "Fishing requires a valid calendar day.")
	if _tracked_day == total_day:
		return
	_tracked_day = total_day
	_catches_today = 0
