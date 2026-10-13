class_name CookingEngineTests
extends RefCounted

const ENGINE_SCRIPT = preload("res://src/domain/cooking/cooking_engine.gd")
const NOTEBOOK_SCRIPT = preload("res://src/domain/cooking/cooking_notebook.gd")

static func run(test: Variant) -> void:
	var soup: Dictionary = ENGINE_SCRIPT.resolve(&"pot", [&"turnip", &"carrot"], &"")
	test.expect_equal(soup.get("item_id"), &"vegetable_soup", "A pot with two vegetables makes soup")
	var salad: Dictionary = ENGINE_SCRIPT.resolve(&"board", [&"cabbage"], &"basil")
	test.expect_equal(salad.get("item_id"), &"herb_salad", "A board with seasoning makes a herb salad")
	var roasted: Dictionary = ENGINE_SCRIPT.resolve(&"oven", [&"potato"], &"")
	test.expect_equal(roasted.get("item_id"), &"roasted_roots", "An oven with a root vegetable makes roasted roots")
	var dark: Dictionary = ENGINE_SCRIPT.resolve(&"pan", [&"turnip", &"carrot", &"strawberry"], &"")
	test.expect_equal(dark.get("item_id"), &"dark_dish", "A structurally invalid crowded combination makes dark food")
	var failed: Dictionary = ENGINE_SCRIPT.resolve(&"pan", [&"turnip"], &"")
	test.expect_equal(failed.get("item_id"), &"failed_dish", "An incomplete combination makes a failed dish")
	var signature: Dictionary = ENGINE_SCRIPT.resolve(&"pot", [&"turnip", &"carrot"], &"basil", [2, 3, 2], [0, 0, 1])
	test.expect_equal(signature.get("item_id"), &"spring_garden_soup", "A specific cookware and ingredient combination makes a signature dish")
	test.expect_true(signature.get("is_signature", false), "Signature dishes are explicitly marked for future social and commerce systems")
	test.expect_equal(signature.get("quality_tier"), 2, "Cooking quality is derived from the consumed ingredient qualities")
	test.expect_equal(signature.get("rarity_tier"), 1, "Cooking rarity preserves the strongest consumed ingredient rarity")
	var notebook: Variant = NOTEBOOK_SCRIPT.new()
	var first_note_ingredients: Array[StringName] = [&"carrot", &"turnip"]
	var second_note_ingredients: Array[StringName] = [&"turnip", &"carrot"]
	notebook.record(&"pot", first_note_ingredients, &"", &"vegetable_soup")
	notebook.record(&"pot", second_note_ingredients, &"", &"vegetable_soup")
	test.expect_equal(notebook.get_entry_count(), 1, "A cooking notebook deduplicates equivalent ingredient orders")
	var note_entry: Dictionary = notebook.get_entry(0)
	test.expect_equal(note_entry.get("cookware_id"), "pot", "A notebook exposes a stored entry for quick loading")
	test.expect_equal(notebook.get_entry(1), {}, "A notebook rejects out-of-range entry reads")
	var restored: Variant = NOTEBOOK_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(notebook.to_snapshot()), "Cooking notes restore from a pure snapshot")
	test.expect_equal(restored.get_entry_count(), 1, "Restored cooking notes preserve discoveries")
	test.expect_true(not restored.restore_snapshot({"version": 1, "entries": [{"cookware_id": "pot"}]}), "Cooking notes reject malformed entries instead of poisoning a save")
	var legacy_notebook: Variant = NOTEBOOK_SCRIPT.new()
	var legacy_note := {"version": 1, "entries": [{"cookware_id": "pot", "ingredient_ids": ["turnip", "carrot"], "seasoning_id": "", "result_item_id": "vegetable_soup"}]}
	test.expect_true(legacy_notebook.restore_snapshot(legacy_note), "Version-one cooking notes migrate into the quality-aware notebook")
	test.expect_equal(legacy_notebook.get_entry(0).get("quality_tier"), 1, "Migrated cooking notes receive normal quality metadata")
