class_name ChickenDefinition
extends Resource

@export var animal_id: StringName
@export var display_name := "未命名鸡"
@export var product_item_id: StringName = &"egg"
@export_range(1, 28, 1) var silver_quality_streak := 3
@export_range(1, 56, 1) var gold_quality_streak := 7

func is_valid() -> bool:
	return animal_id != &"" and not display_name.is_empty() and product_item_id != &"" and silver_quality_streak >= 1 and gold_quality_streak > silver_quality_streak

func get_product_quality(care_streak: int) -> int:
	if care_streak >= gold_quality_streak:
		return 3
	if care_streak >= silver_quality_streak:
		return 2
	return 1
