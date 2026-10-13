class_name CookingEngine
extends RefCounted

const NORMAL_QUALITY := 1
const SILVER_QUALITY := 2
const GOLD_QUALITY := 3

static func resolve(cookware_id: StringName, ingredient_ids: Array[StringName], seasoning_id: StringName, quality_values: Array[int] = [], rarity_values: Array[int] = []) -> Dictionary:
	if cookware_id == &"" or ingredient_ids.is_empty():
		return _decorate_outcome(_outcome(&"failed_dish", "失败料理", "缺少关键步骤，料理没有成形。"), quality_values, rarity_values)
	if cookware_id == &"pot" and &"turnip" in ingredient_ids and &"carrot" in ingredient_ids and seasoning_id == &"basil":
		return _decorate_outcome(_outcome(&"spring_garden_soup", "春野浓汤", "芜菁、胡萝卜与罗勒形成了这道招牌料理。", true), quality_values, rarity_values)
	if cookware_id == &"oven" and &"potato" in ingredient_ids and &"carrot" in ingredient_ids and seasoning_id == &"wild_herb":
		return _decorate_outcome(_outcome(&"herb_roasted_roots", "野香烤根茎", "野生香草让烤根茎成为独特的招牌料理。", true), quality_values, rarity_values)
	if cookware_id == &"pot" and ingredient_ids.size() >= 2:
		return _decorate_outcome(_outcome(&"vegetable_soup", "蔬菜汤", "食材在汤锅中慢慢融合。"), quality_values, rarity_values)
	if cookware_id == &"board" and seasoning_id != &"":
		return _decorate_outcome(_outcome(&"herb_salad", "香草沙拉", "清爽的食材与香草形成了平衡。"), quality_values, rarity_values)
	if cookware_id == &"oven" and (&"carrot" in ingredient_ids or &"potato" in ingredient_ids):
		return _decorate_outcome(_outcome(&"roasted_roots", "烤根茎", "根茎在烤箱中变得香甜。"), quality_values, rarity_values)
	if ingredient_ids.size() >= 3:
		return _decorate_outcome(_outcome(&"dark_dish", "黑暗料理", "组合失去了结构，散发出不可名状的气息。"), quality_values, rarity_values)
	return _decorate_outcome(_outcome(&"failed_dish", "失败料理", "这个组合暂时没有形成一道料理。"), quality_values, rarity_values)

static func _outcome(item_id: StringName, display_name: String, message: String, is_signature: bool = false) -> Dictionary:
	return {"item_id": item_id, "display_name": display_name, "message": message, "is_signature": is_signature}

static func _decorate_outcome(outcome: Dictionary, quality_values: Array[int], rarity_values: Array[int]) -> Dictionary:
	var total_quality := 0
	for quality in quality_values:
		total_quality += clampi(quality, NORMAL_QUALITY, GOLD_QUALITY)
	var quality_tier := NORMAL_QUALITY if quality_values.is_empty() else clampi(roundi(float(total_quality) / quality_values.size()), NORMAL_QUALITY, GOLD_QUALITY)
	var rarity_tier := 0
	for rarity in rarity_values:
		rarity_tier = max(rarity_tier, max(0, rarity))
	outcome["quality_tier"] = quality_tier
	outcome["rarity_tier"] = rarity_tier
	return outcome
