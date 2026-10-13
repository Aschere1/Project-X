class_name ForageSpot
extends GridInteractable

const SNAPSHOT_VERSION := 1
const SOURCE_KIND := &"forage"

@export var source_catalog: FoodSourceCatalog
var _last_collected_day := 0

func _ready() -> void:
	super._ready()
	assert(source_catalog != null, "ForageSpot requires a food source catalog.")

func is_available(total_day: int) -> bool:
	return _last_collected_day != total_day

func preview_reward(total_day: int, weather_id: StringName, world_seed: int) -> Dictionary:
	if not is_available(total_day):
		return {}
	return source_catalog.resolve_reward(SOURCE_KIND, weather_id, total_day, world_seed, interaction_id)

func mark_collected(total_day: int) -> void:
	assert(total_day >= 1, "Forage collection requires a valid day.")
	_last_collected_day = total_day
	refresh_for_day(total_day)

func refresh_for_day(total_day: int) -> void:
	fill_color = Color("6f9f4c") if is_available(total_day) else Color("58614c")
	queue_redraw()

func to_snapshot() -> Dictionary:
	return {"version": SNAPSHOT_VERSION, "last_collected_day": _last_collected_day}

func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	var last_collected_day := int(snapshot.get("last_collected_day", -1))
	if last_collected_day < 0:
		return false
	_last_collected_day = last_collected_day
	return true
