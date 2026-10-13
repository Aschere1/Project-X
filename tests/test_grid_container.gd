class_name GridContainerTests
extends RefCounted

const GRID_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/grid_container.gd")

static func run(test: Variant) -> void:
	var container: Variant = GRID_CONTAINER_SCRIPT.new(4, 3, 10)

	test.expect_true(container.place_item(&"medkit_1", &"medkit", 2, 1, 4, 0, 0, false), "A rectangular item fits into an empty grid")
	test.expect_true(container.place_item_first_fit(&"bandage_0", &"bandage", 1, 1, 1, false), "First-fit placement finds an available grid cell")
	test.expect_true(not container.place_item(&"bandage_1", &"bandage", 1, 1, 1, 1, 0, true), "An item cannot overlap an occupied cell")
	test.expect_true(not container.place_item(&"tool_1", &"tool", 2, 2, 6, 3, 2, true), "An item cannot extend beyond the grid")
	test.expect_true(container.place_item(&"bandage_1", &"bandage", 1, 1, 1, 3, 0, true), "A non-overlapping item can be placed")

	var unknown_item: Dictionary = container.get_item(&"medkit_1")
	test.expect_true(not unknown_item["revealed"], "A searched item can remain hidden before reveal")
	test.expect_true(container.reveal_item(&"medkit_1"), "A hidden item can be revealed")
	test.expect_true(container.get_item(&"medkit_1")["revealed"], "Reveal state is visible through the public query")
	test.expect_equal(container.get_total_weight(), 6, "Container weight includes all placed items")
	test.expect_equal(container.get_load_state(), &"normal", "Weight below the comfortable threshold is normal")

	test.expect_true(container.place_item(&"fuel_1", &"fuel", 1, 1, 7, 3, 1, true), "Grid fit is independent from the weight threshold")
	test.expect_equal(container.get_load_state(), &"overweight", "Weight above the comfortable threshold is overweight")
	test.expect_true(container.remove_item(&"fuel_1"), "A placed item can be removed")
	test.expect_true(not container.remove_item(&"fuel_1"), "Removing an absent item reports no change")

	var restored: Variant = GRID_CONTAINER_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(container.to_snapshot()), "Grid contents restore from a pure snapshot")
	test.expect_equal(restored.get_columns(), 4, "Grid dimensions survive restore")
	test.expect_equal(restored.get_total_weight(), 6, "Restored grid keeps item weight")
	test.expect_true(restored.get_item(&"medkit_1")["revealed"], "Restored grid keeps reveal state")

	var stacks: Variant = GRID_CONTAINER_SCRIPT.new(3, 1, 20)
	test.expect_true(stacks.add_item_stack(&"water_1", &"water", 1, 1, 2, 14, 16), "A partial supply stack can occupy one standard cell")
	test.expect_true(stacks.add_item_stack(&"water_2", &"water", 1, 1, 2, 2, 16), "Incoming supplies fill an existing matching stack first")
	test.expect_equal(stacks.get_items().size(), 1, "A filled matching supply stack still occupies one cell")
	test.expect_equal(stacks.get_item(&"water_1")["quantity"], 16, "A matching supply stack stops at its configured cap")
	test.expect_true(stacks.add_item_stack(&"water_3", &"water", 1, 1, 2, 1, 16), "Overflow from a full stack starts a new standard cell")
	test.expect_equal(stacks.get_occupied_slot_count(), 2, "Only the overflow consumes an additional inventory cell")
	test.expect_equal(stacks.get_total_weight(), 34, "Stacked quantities contribute every item's weight")

	var split_stacks: Variant = GRID_CONTAINER_SCRIPT.new(2, 1, 10)
	test.expect_true(split_stacks.add_item_stack(&"bandage_1", &"bandage", 1, 1, 1, 4, 16), "A stack can be prepared for a quantity split")
	test.expect_true(split_stacks.can_add_item_stack(&"bandage_2", &"bandage", 1, 1, 1, 12, 16), "Capacity checks account for filling matching stacks before opening a cell")
	test.expect_true(split_stacks.split_stack(&"bandage_1", &"bandage_split", 2), "A stack can split into a second standard cell")
	test.expect_equal(split_stacks.get_item(&"bandage_1")["quantity"], 2, "Splitting removes only the requested amount from the source stack")
	test.expect_equal(split_stacks.get_item(&"bandage_split")["quantity"], 2, "Splitting creates a stack with the requested amount")
	test.expect_true(not split_stacks.split_stack(&"bandage_1", &"bandage_split_2", 2), "A stack cannot split away its entire remaining quantity")
