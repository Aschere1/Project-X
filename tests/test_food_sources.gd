class_name FoodSourceTests
extends RefCounted

const FORAGE_SPOT_SCRIPT = preload("res://src/world/forage_spot.gd")
const FISHING_SPOT_SCRIPT = preload("res://src/world/fishing_spot.gd")
const SOURCE_CATALOG: Resource = preload("res://content/catalogs/spring_food_source_catalog.tres")
const ITEM_CATALOG: Resource = preload("res://content/catalogs/starter_item_catalog.tres")

static func run(test: Variant) -> void:
	weather_tables_are_deterministic_and_bounded(test)
	forage_spots_refresh_daily_and_restore(test)
	fishing_spots_enforce_a_daily_limit_and_restore(test)

static func weather_tables_are_deterministic_and_bounded(test: Variant) -> void:
	var first: Dictionary = SOURCE_CATALOG.resolve_reward(&"forage", &"rain", 4, 20_260_725, &"meadow")
	var second: Dictionary = SOURCE_CATALOG.resolve_reward(&"forage", &"rain", 4, 20_260_725, &"meadow")
	test.expect_equal(first, second, "A food source gives the same reward after reloading the same day")
	test.expect_true(StringName(first.get("item_id")) in [&"rain_mushroom", &"wild_herb"], "Rainy forage only chooses from the rainy reward table")
	test.expect_equal(int(first.get("quality")), 3, "Rainy forage produces the configured premium quality")
	var sunny_fish: Dictionary = SOURCE_CATALOG.resolve_reward(&"fishing", &"sunny", 1, 20_260_725, &"pond", 0)
	test.expect_true(StringName(sunny_fish.get("item_id")) in [&"pond_smelt", &"river_trout"], "Sunny fishing only chooses from the sunny reward table")
	for reward in SOURCE_CATALOG.rewards:
		test.expect_true(ITEM_CATALOG.get_item(reward.item_id) != null, "Every food source reward exists in the item catalog: %s" % reward.item_id)

static func forage_spots_refresh_daily_and_restore(test: Variant) -> void:
	var spot: Variant = FORAGE_SPOT_SCRIPT.new()
	spot.interaction_id = &"test_forage"
	spot.source_catalog = SOURCE_CATALOG
	test.expect_true(spot.is_available(1), "A forage spot starts available")
	test.expect_true(not spot.preview_reward(1, &"sunny", 7).is_empty(), "An available forage spot previews a reward")
	spot.mark_collected(1)
	test.expect_true(not spot.is_available(1), "A forage spot can only be collected once per day")
	test.expect_true(spot.is_available(2), "A forage spot refreshes on the next day")
	var restored: Variant = FORAGE_SPOT_SCRIPT.new()
	restored.source_catalog = SOURCE_CATALOG
	test.expect_true(restored.restore_snapshot(spot.to_snapshot()), "A forage spot restores its collected day")
	test.expect_true(not restored.is_available(1), "Restored forage state prevents same-day duplicate collection")
	spot.free()
	restored.free()

static func fishing_spots_enforce_a_daily_limit_and_restore(test: Variant) -> void:
	var spot: Variant = FISHING_SPOT_SCRIPT.new()
	spot.interaction_id = &"test_fishing"
	spot.source_catalog = SOURCE_CATALOG
	spot.daily_catch_limit = 2
	test.expect_equal(spot.get_remaining_catches(1), 2, "A fishing spot starts with its configured daily limit")
	spot.record_catch(1)
	spot.record_catch(1)
	test.expect_equal(spot.get_remaining_catches(1), 0, "Fishing stops after the daily catch limit")
	test.expect_true(spot.preview_reward(1, &"sunny", 7).is_empty(), "An exhausted fishing spot cannot preview another catch")
	var restored: Variant = FISHING_SPOT_SCRIPT.new()
	restored.source_catalog = SOURCE_CATALOG
	restored.daily_catch_limit = 2
	test.expect_true(restored.restore_snapshot(spot.to_snapshot()), "A fishing spot restores its daily catch count")
	test.expect_equal(restored.get_remaining_catches(1), 0, "Restored fishing state prevents same-day duplicate catches")
	test.expect_equal(restored.get_remaining_catches(2), 2, "Fishing attempts refresh on the next day")
	spot.free()
	restored.free()
