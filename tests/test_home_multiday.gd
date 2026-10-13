class_name HomeMultidayTests
extends RefCounted

const HOME_REGION_SCENE = preload("res://scenes/world/home_region.tscn")
const CROP_CATALOG: CropCatalog = preload("res://content/catalogs/spring_crop_catalog.tres")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")

static func run(test: Variant) -> void:
	var save_root := "user://project_x_home_multiday"
	var first_world := HOME_REGION_SCENE.instantiate() as HomeRegion
	test.expect_true(first_world != null, "The multi-day test can instantiate the formal HomeRegion")
	if first_world == null:
		return
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(first_world)
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new(save_root)
	first_world.save_coordinator._repository = repository

	var field := first_world.get_node("StarterField") as FarmPlot
	var forage := first_world.get_node("ForageMeadow") as ForageSpot
	var fishing := first_world.get_node("FishingPond") as FishingSpot
	var coop := first_world.get_node("StarterChickenCoop") as ChickenCoop
	var turnip_crop: Variant = CROP_CATALOG.get_crop_by_seed_item_id(&"turnip_seed")
	test.expect_true(field != null and turnip_crop != null, "The multi-day loop has a farm plot and a catalogued crop")
	if field == null or turnip_crop == null:
		first_world.free()
		return

	test.expect_equal(field.get_visual_state_id(), &"untouched", "A fresh authored farm cell starts with the untouched visual state")
	field.use_tool(FarmPlot.HOE_TOOL_ID)
	test.expect_equal(field.get_visual_state_id(), &"tilled", "Hoeing switches the farm cell to the Super Retro tilled-soil visual state")
	field.plant(turnip_crop)
	test.expect_equal(field.get_visual_state_id(), &"planted", "Planting switches the farm cell to the crop visual state")
	first_world.inventory_controller.remove_item(&"turnip_seed", 1)
	field.water()
	test.expect_equal(field.get_visual_state_id(), &"watered", "Watering switches the farm cell to the watered-soil visual state")
	first_world.cooking_controller.notebook.record(&"pot", [&"wild_herb", &"turnip"], &"", &"vegetable_soup")
	var day_one_foraging := first_world._collect_forage(forage)
	var day_one_fishing := first_world._fish_at_spot(fishing)
	var first_care: Dictionary = first_world.care_for_chicken_coop(coop)
	var second_care: Dictionary = first_world.care_for_chicken_coop(coop)
	test.expect_true(day_one_foraging.begins_with("采集到"), "Day one forage enters the saved life loop")
	test.expect_true(day_one_fishing.begins_with("钓到"), "Day one fishing enters the saved life loop")
	test.expect_true(first_care.get("success", false) and second_care.get("success", false), "Day one chicken care feeds and pets the chicken")
	test.expect_equal(field.to_snapshot().get("growth_days"), 0, "A newly planted crop starts at zero growth days")
	test.expect_equal(fishing.get_remaining_catches(1), 2, "Day one fishing usage is tracked before saving")
	test.expect_true(first_world.cooking_controller.notebook.get_entry_count() == 1, "The day one cooking notebook has one discovery")

	first_world.get_node("Player").global_position = Vector2(700, 400)
	first_world.save_coordinator.save_manual_slot("slot_1")
	var saved_result: Dictionary = repository.load_slot("slot_1")
	test.expect_true(saved_result.get("ok", false), "The full HomeRegion snapshot is readable immediately after saving")
	var saved_snapshot: Dictionary = saved_result.get("snapshot", {})
	test.expect_true(saved_snapshot.get("world", {}).get("interaction_state", {}).get("farm_plots", {}).has("starter_field"), "The saved snapshot contains the authored farm plot state")

	first_world.sleep_at_home()
	test.expect_equal(first_world.game_clock.session.get_day(), 2, "Sleeping advances the saved life loop to day two")
	test.expect_equal(field.to_snapshot().get("growth_days"), 1, "A watered crop grows across the first overnight boundary")
	test.expect_equal(field.get_visual_state_id(), &"planted", "The watered overlay clears after the overnight growth step")
	test.expect_equal(coop.get_pending_egg_count(), 1, "A fed and petted chicken produces one pending egg on day two")
	test.expect_true(forage.is_available(2), "Forage refreshes when the calendar enters a new day")
	test.expect_equal(fishing.get_remaining_catches(2), 3, "Fishing refreshes to three catches on a new day")
	var collected_egg: Dictionary = first_world.care_for_chicken_coop(coop)
	test.expect_true(collected_egg.get("success", false), "The day two loop can collect the produced egg")
	first_world.sleep_at_home()
	test.expect_equal(first_world.game_clock.session.get_day(), 3, "The loop remains playable across a second overnight boundary")

	first_world.free()

	var relaunched_world := HOME_REGION_SCENE.instantiate() as HomeRegion
	test.expect_true(relaunched_world != null, "A fresh HomeRegion can stand in for a relaunch")
	if relaunched_world == null:
		return
	tree.root.add_child(relaunched_world)
	relaunched_world.save_coordinator._repository = SAVE_REPOSITORY_SCRIPT.new(save_root)
	relaunched_world.save_coordinator.load_manual_slot("slot_1")

	var restored_field := relaunched_world.get_node("StarterField") as FarmPlot
	var restored_forage := relaunched_world.get_node("ForageMeadow") as ForageSpot
	var restored_fishing := relaunched_world.get_node("FishingPond") as FishingSpot
	var restored_coop := relaunched_world.get_node("StarterChickenCoop") as ChickenCoop
	test.expect_equal(relaunched_world.game_clock.session.get_day(), 1, "Loading the saved slot restores the original day instead of the later day")
	test.expect_equal(relaunched_world.game_clock.session.get_stamina(), 95, "Loading restores the day one stamina after care and exploration")
	test.expect_equal(restored_field.to_snapshot().get("growth_days"), 0, "Loading restores the crop before overnight growth")
	test.expect_true(restored_field.to_snapshot().get("is_watered_today", false), "Loading restores the crop's same-day watering state")
	test.expect_equal(restored_forage.to_snapshot().get("last_collected_day"), 1, "Loading restores the used forage point")
	test.expect_equal(restored_fishing.get_remaining_catches(1), 2, "Loading restores the day one fishing count")
	test.expect_equal(restored_coop.get_pending_egg_count(), 0, "Loading restores the chicken before its day two egg")
	test.expect_true(restored_coop.is_fed_today(1) and restored_coop.is_petted_today(1), "Loading restores both chicken care flags")
	test.expect_equal(relaunched_world.cooking_controller.notebook.get_entry_count(), 1, "Loading restores the cooking notebook")
	test.expect_equal(relaunched_world.get_node("Player").global_position, Vector2(700, 400), "Loading restores the authored player position")
	test.expect_equal(relaunched_world.inventory_controller.inventory.count_item(&"turnip_seed"), 3, "Loading restores inventory quantities from the saved day")
	relaunched_world.free()
