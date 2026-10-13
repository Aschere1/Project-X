class_name FoodSourceCatalog
extends Resource

@export var rewards: Array[Resource] = []

func resolve_reward(source_kind: StringName, weather_id: StringName, total_day: int, world_seed: int, source_id: StringName, attempt_index: int = 0) -> Dictionary:
	assert(total_day >= 1, "Food sources require a valid calendar day.")
	assert(attempt_index >= 0, "Food source attempts cannot be negative.")
	var candidates: Array[FoodSourceReward] = []
	var total_weight := 0
	for resource in rewards:
		var reward := resource as FoodSourceReward
		assert(reward != null and reward.is_valid(), "FoodSourceCatalog contains an invalid reward resource.")
		if reward.source_kind == source_kind and reward.weather_id == weather_id:
			candidates.append(reward)
			total_weight += reward.weight
	if candidates.is_empty() or total_weight <= 0:
		return {}
	var roll := posmod(_stable_source_hash(world_seed, total_day, source_id, attempt_index), total_weight)
	for reward in candidates:
		if roll < reward.weight:
			return {"item_id": reward.item_id, "quantity": reward.quantity, "quality": reward.quality}
		roll -= reward.weight
	return {}

func _stable_source_hash(world_seed: int, total_day: int, source_id: StringName, attempt_index: int) -> int:
	var value := world_seed * 31 + total_day * 104_729 + attempt_index * 8_191
	var source_text := String(source_id)
	for index in source_text.length():
		value = value * 33 + source_text.unicode_at(index)
	return value
