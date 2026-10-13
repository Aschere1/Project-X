class_name FoodSourceReward
extends Resource

@export var source_kind: StringName
@export var weather_id: StringName
@export var item_id: StringName
@export_range(1, 99, 1) var quantity := 1
@export_range(1, 3, 1) var quality := 1
@export_range(1, 100, 1) var weight := 1

func is_valid() -> bool:
	return source_kind != &"" and weather_id != &"" and item_id != &"" and quantity > 0 and quality >= 1 and quality <= 3 and weight > 0
