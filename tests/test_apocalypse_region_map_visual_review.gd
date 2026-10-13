class_name ApocalypseRegionMapVisualReviewTests
extends RefCounted

const REGION_MAP_SCENE = preload("res://scenes/world/apocalypse_region_map.tscn")

static func run(test: Variant) -> void:
	var region_map: Control = REGION_MAP_SCENE.instantiate() as Control
	test.expect_true(region_map != null, "The apocalypse region map scene instantiates")
	if region_map == null:
		return
	var markers: Control = region_map.get_node_or_null("HUD/LocationMarkers") as Control
	var clinic: Button = region_map.get_node_or_null("HUD/LocationMarkers/Clinic") as Button
	var market: Button = region_map.get_node_or_null("HUD/LocationMarkers/Market") as Button
	var industrial: Button = region_map.get_node_or_null("HUD/LocationMarkers/Industrial") as Button
	test.expect_true(markers != null and markers.get_child_count() == 4, "The region map exposes four authored map markers")
	if clinic == null:
		region_map.free()
		return
	test.expect_equal(StringName(clinic.get_meta("location_id", "")), &"village_clinic", "The clinic marker uses a stable location ID instead of its display text")
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		region_map.free()
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The project registers the apocalypse run as an autoload seam")
	if apocalypse_run == null:
		region_map.free()
		return
	apocalypse_run.start_new_session()
	var travel_request: Dictionary = {}
	region_map.destination_open_requested.connect(func(_location_id: StringName, scene_path: String) -> void:
		travel_request["scene_path"] = scene_path
	)
	scene_tree.root.add_child(region_map)
	var global_overlay: Variant = region_map.get_node_or_null("GlobalOverlay")
	test.expect_true(global_overlay != null, "The region map owns the reusable disaster UI overlay")
	var inventory_event := InputEventAction.new()
	inventory_event.action = &"open_inventory"
	inventory_event.pressed = true
	region_map.call("_unhandled_input", inventory_event)
	test.expect_true(global_overlay.is_backpack_open(), "B opens the shared backpack from the county map")
	test.expect_equal((global_overlay.get_node("InventoryModal/Panel/VBox/Items") as ApocalypseInventoryGridView).get_grid_dimensions(), Vector2i(6, 4), "The county-map backpack uses the real six-by-four carried container")
	var escape_event := InputEventAction.new()
	escape_event.action = &"ui_cancel"
	escape_event.pressed = true
	region_map.call("_unhandled_input", escape_event)
	test.expect_true(not global_overlay.is_backpack_open(), "Esc first closes the county-map backpack")
	region_map.call("_unhandled_input", escape_event)
	test.expect_true(global_overlay.is_system_menu_open(), "Esc opens the shared system menu instead of immediately leaving the county map")
	region_map.call("_unhandled_input", escape_event)
	test.expect_true(not global_overlay.is_system_menu_open(), "A second Esc closes the county-map system menu")
	test.expect_true(market != null, "The county map keeps the authored market marker as the second scavenging location")
	if market != null:
		test.expect_equal(StringName(market.get_meta("location_id", "")), &"county_market", "The market marker uses a stable location ID")
		market.pressed.emit()
		test.expect_equal(String(travel_request.get("scene_path", "")), "res://scenes/reviews/apocalypse_market_review.tscn", "Clicking the market marker requests the authored market search scene")
		test.expect_true(apocalypse_run.get_active_session().is_location_known(&"county_market"), "Entering the market registers its stable location in the active run")
	test.expect_true(industrial != null, "The county map keeps the authored industrial-warehouse marker as the third scavenging location")
	if industrial != null:
		test.expect_equal(StringName(industrial.get_meta("location_id", "")), &"industrial_warehouse", "The industrial marker uses a stable location ID")
		industrial.pressed.emit()
		test.expect_equal(String(travel_request.get("scene_path", "")), "res://scenes/reviews/apocalypse_warehouse_review.tscn", "Clicking the industrial marker requests the authored warehouse search scene")
		test.expect_true(apocalypse_run.get_active_session().is_location_known(&"industrial_warehouse"), "Entering the warehouse registers its stable location in the active run")
	clinic.pressed.emit()
	test.expect_equal(String(travel_request.get("scene_path", "")), "res://scenes/reviews/apocalypse_explore_review.tscn", "Clicking the clinic marker requests the actual clinic search scene")
	test.expect_true(apocalypse_run.get_active_session().is_location_known(&"village_clinic"), "Entering the clinic registers the stable location in the active run")
	if is_instance_valid(region_map) and region_map.get_parent() != null:
		region_map.get_parent().remove_child(region_map)
	if is_instance_valid(region_map):
		region_map.free()
