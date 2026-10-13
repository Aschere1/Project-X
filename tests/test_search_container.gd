class_name SearchContainerTests
extends RefCounted

const SEARCH_CONTAINER_SCRIPT = preload("res://src/domain/apocalypse/search_container.gd")

static func run(test: Variant) -> void:
	var container: Variant = SEARCH_CONTAINER_SCRIPT.new(&"clinic_cabinet", 4, 3)
	test.expect_true(
		container.add_hidden_item(&"medkit_1", &"medkit", 2, 1, 4, 8, 2, 3, &"medical"),
		"A hidden item can be registered with search cost and rarity",
	)
	test.expect_true(
		container.add_hidden_item(&"bandage_1", &"bandage", 1, 1, 1, 3, 1, 1, &"medical"),
		"A second hidden item can occupy the same container",
	)
	test.expect_equal(container.get_state(), &"unsearched", "A container starts unsearched")
	test.expect_true(not container.get_item_snapshot(&"medkit_1")["revealed"], "Items start hidden")

	var first_search: Dictionary = container.search_item(&"bandage_1")
	test.expect_true(first_search.get("ok", false), "Searching an item succeeds")
	test.expect_equal(first_search.get("minutes_spent"), 3, "Search consumes the item's search time")
	test.expect_equal(first_search.get("noise_generated"), 1, "Search generates the item's noise")
	test.expect_equal(first_search.get("rarity_tier"), 1, "Search reveals item rarity")
	test.expect_equal(container.get_state(), &"partial", "A partially searched container keeps a partial state")

	var repeated_search: Dictionary = container.search_item(&"bandage_1")
	test.expect_true(not repeated_search.get("ok", false), "A revealed item cannot be searched twice")
	test.expect_equal(container.get_total_noise(), 1, "Repeated searches do not add noise")

	var second_search: Dictionary = container.search_item(&"medkit_1")
	test.expect_true(second_search.get("ok", false), "The remaining hidden item can be searched")
	test.expect_equal(second_search.get("minutes_spent"), 8, "The second item's search cost is preserved")
	test.expect_equal(container.get_total_noise(), 3, "Container noise accumulates across searches")
	test.expect_equal(container.get_state(), &"searched", "A fully revealed container is searched")

	var restored: Variant = SEARCH_CONTAINER_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(container.to_snapshot()), "Search state restores from a pure snapshot")
	test.expect_equal(restored.get_total_search_minutes(), 11, "Restored search state keeps elapsed search time")
	test.expect_equal(restored.get_item_snapshot(&"medkit_1")["rarity_tier"], 3, "Restored search state keeps rarity")
