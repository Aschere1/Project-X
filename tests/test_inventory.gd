class_name InventoryTests
extends RefCounted

const INVENTORY_SCRIPT = preload("res://src/domain/inventory/inventory.gd")

static func run(test: Variant) -> void:
	var inventory: Variant = INVENTORY_SCRIPT.new(2)
	test.expect_equal(inventory.add_item(&"turnip_seed", 105, 99), 0, "Inventory stacks an item across available slots")
	test.expect_equal(inventory.count_item(&"turnip_seed"), 105, "Inventory counts all stacks of the same item")
	test.expect_equal(inventory.get_used_slots(), 2, "Inventory uses a second slot after the first stack is full")
	test.expect_equal(inventory.add_item(&"wild_herb", 1, 99), 1, "Inventory returns the quantity that does not fit")

	var snapshot: Dictionary = inventory.to_snapshot()
	var restored: Variant = INVENTORY_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(snapshot), "Inventory restores a valid snapshot")
	test.expect_equal(restored.count_item(&"turnip_seed"), 105, "Restored inventory preserves item quantities")
	test.expect_equal(restored.get_maximum_slots(), 2, "Restored inventory preserves slot capacity")

	var working_inventory: Variant = INVENTORY_SCRIPT.new(2)
	working_inventory.add_item(&"turnip_seed", 4, 99)
	test.expect_true(working_inventory.can_add_item(&"turnip", 99, 99), "Inventory recognizes capacity for a new harvest stack")
	test.expect_equal(working_inventory.remove_item(&"turnip_seed", 1), 1, "Inventory removes one planted seed")
	test.expect_equal(working_inventory.count_item(&"turnip_seed"), 3, "Removing a seed updates its quantity")
	test.expect_equal(working_inventory.remove_item(&"turnip_seed", 9), 3, "Removing more than owned only removes available items")
	test.expect_equal(working_inventory.get_used_slots(), 0, "An empty stack is removed after its last item is used")

	var graded_inventory: Variant = INVENTORY_SCRIPT.new(3)
	graded_inventory.add_item(&"turnip", 1, 99, 1)
	graded_inventory.add_item(&"turnip", 1, 99, 3)
	test.expect_equal(graded_inventory.get_used_slots(), 2, "Different-quality items remain in separate stacks")
	test.expect_equal(graded_inventory.get_item_quality_values(&"turnip", 2), [1, 3], "Cooking reads actual ingredient qualities in consumption order")
	graded_inventory.remove_item(&"turnip", 1)
	test.expect_equal(graded_inventory.get_item_quality_values(&"turnip", 1), [3], "Cooking consumes lower-quality items before premium ingredients")
	var legacy_snapshot := {"version": 1, "maximum_slots": 2, "stacks": [{"item_id": "turnip", "quantity": 2}]}
	var migrated_inventory: Variant = INVENTORY_SCRIPT.new()
	test.expect_true(migrated_inventory.restore_snapshot(legacy_snapshot), "Version-one inventory snapshots migrate to quality-aware inventory")
	test.expect_equal(migrated_inventory.get_item_quality_values(&"turnip", 2), [1, 1], "Migrated legacy items receive normal quality")
