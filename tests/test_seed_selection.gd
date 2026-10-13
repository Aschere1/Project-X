class_name SeedSelectionTests
extends RefCounted

const INVENTORY_CONTROLLER_SCRIPT = preload("res://src/world/inventory_controller.gd")
const STARTER_ITEM_CATALOG = preload("res://content/catalogs/starter_item_catalog.tres")

static func run(test: Variant) -> void:
	var controller: Variant = INVENTORY_CONTROLLER_SCRIPT.new()
	controller.item_catalog = STARTER_ITEM_CATALOG
	var starting_item_amounts: Dictionary[StringName, int] = {
		&"turnip_seed": 1,
		&"potato_seed": 1,
		&"cabbage_seed": 1,
	}
	controller.starting_item_amounts = starting_item_amounts
	controller._ready()
	test.expect_equal(controller.get_selected_seed_item_id(), &"turnip_seed", "The first available seed becomes the initial planting selection")
	test.expect_true(controller.select_next_seed(), "Seed selection can advance through owned seed types")
	test.expect_equal(controller.get_selected_seed_item_id(), &"potato_seed", "Cycling seeds selects the next catalog seed")
	controller.remove_item(&"potato_seed", 1)
	test.expect_equal(controller.get_selected_seed_item_id(), &"cabbage_seed", "A depleted selected seed automatically advances to an owned seed")
	controller.free()
