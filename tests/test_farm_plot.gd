class_name FarmPlotTests
extends RefCounted

const FARM_PLOT_SCRIPT = preload("res://src/world/farm_plot.gd")
const CROP_DEFINITION_SCRIPT = preload("res://src/domain/farming/crop_definition.gd")

static func run(test: Variant) -> void:
	var plot: Variant = FARM_PLOT_SCRIPT.new()
	test.expect_equal(plot.get_visual_cell_rect(), Rect2(-8, -8, 16, 16), "A farm-plot visual occupies exactly the same 16px map cell as its interaction point")
	var first_use: Dictionary = plot.use_tool(&"hoe")
	test.expect_true(first_use.get("success", false), "A hoe tills an untouched farm plot")
	var repeated_use: Dictionary = plot.use_tool(&"hoe")
	test.expect_true(not repeated_use.get("success", true), "A farm plot cannot be tilled twice")
	var restored_plot: Variant = FARM_PLOT_SCRIPT.new()
	test.expect_true(restored_plot.restore_snapshot(plot.to_snapshot()), "Farm plot restores its saved soil state")
	var restored_repeated_use: Dictionary = restored_plot.use_tool(&"hoe")
	test.expect_true(not restored_repeated_use.get("success", true), "Restored farm plot remains tilled")
	plot.free()
	restored_plot.free()

	crop_lifecycle_requires_watering_and_survives_a_snapshot(test)

static func crop_lifecycle_requires_watering_and_survives_a_snapshot(test: Variant) -> void:
	var crop: Variant = CROP_DEFINITION_SCRIPT.new()
	crop.crop_id = &"turnip"
	crop.display_name = "芜菁"
	crop.seed_item_id = &"turnip_seed"
	crop.harvest_item_id = &"turnip"
	crop.days_to_mature = 3
	crop.harvest_amount = 1
	var plot: Variant = FARM_PLOT_SCRIPT.new()
	plot.use_tool(&"hoe")
	test.expect_true(plot.plant(crop).get("success", false), "A tilled plot accepts a crop definition")
	plot.advance_day()
	test.expect_true(not plot.is_ready_to_harvest(), "A crop does not grow through an unwatered day")
	for day_index in range(3):
		test.expect_true(plot.water().get("success", false), "A growing crop can be watered once on day %d" % (day_index + 1))
		plot.advance_day()
	test.expect_true(plot.is_ready_to_harvest(), "Three watered days mature the turnip crop")
	var snapshot: Dictionary = plot.to_snapshot()
	var restored_plot: Variant = FARM_PLOT_SCRIPT.new()
	test.expect_true(restored_plot.restore_snapshot(snapshot), "A planted crop restores from a version-two plot snapshot")
	test.expect_true(restored_plot.is_ready_to_harvest(), "A restored crop keeps its mature state")
	var harvest: Dictionary = restored_plot.harvest()
	test.expect_true(harvest.get("success", false), "A mature crop can be harvested")
	test.expect_equal(harvest.get("item_id"), &"turnip", "Harvesting returns the configured item id")
	test.expect_equal(harvest.get("quantity"), 1, "Harvesting returns the configured amount")
	plot.free()
	restored_plot.free()

	repeat_harvest_crops_regrow_after_their_configured_days(test)
	rain_waters_crops_before_daily_growth(test)

static func repeat_harvest_crops_regrow_after_their_configured_days(test: Variant) -> void:
	var crop: Variant = CROP_DEFINITION_SCRIPT.new()
	crop.crop_id = &"strawberry"
	crop.display_name = "草莓"
	crop.seed_item_id = &"strawberry_seed"
	crop.harvest_item_id = &"strawberry"
	crop.days_to_mature = 3
	crop.harvest_amount = 1
	crop.regrow_days = 2
	var plot: Variant = FARM_PLOT_SCRIPT.new()
	plot.use_tool(&"hoe")
	plot.plant(crop)
	for day_index in range(3):
		plot.water()
		plot.advance_day()
	test.expect_true(plot.is_ready_to_harvest(), "A repeat-harvest crop reaches its first harvest")
	plot.harvest()
	test.expect_true(plot.has_crop(), "Harvesting a repeat crop leaves it planted")
	test.expect_true(not plot.is_ready_to_harvest(), "A repeat crop must regrow before another harvest")
	for day_index in range(2):
		plot.water()
		plot.advance_day()
	test.expect_true(plot.is_ready_to_harvest(), "A repeat crop regrows after its configured watered days")
	plot.free()

static func rain_waters_crops_before_daily_growth(test: Variant) -> void:
	var crop: Variant = CROP_DEFINITION_SCRIPT.new()
	crop.crop_id = &"rain_turnip"
	crop.display_name = "雨水芜菁"
	crop.seed_item_id = &"turnip_seed"
	crop.harvest_item_id = &"turnip"
	crop.days_to_mature = 2
	crop.harvest_amount = 1
	var plot: Variant = FARM_PLOT_SCRIPT.new()
	plot.use_tool(&"hoe")
	plot.plant(crop)
	test.expect_true(not plot.apply_weather(&"sunny"), "Sunny weather does not water a farm plot")
	plot.advance_day()
	test.expect_true(not plot.is_ready_to_harvest(), "A sunny unwatered day does not grow the crop")
	for _day in range(2):
		test.expect_true(plot.apply_weather(&"rain"), "Rain waters a growing crop before the day settles")
		plot.advance_day()
	test.expect_true(plot.is_ready_to_harvest(), "Two rainy days mature a two-day crop without manual watering")
	plot.free()
