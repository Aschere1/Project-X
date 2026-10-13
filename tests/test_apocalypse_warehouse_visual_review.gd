class_name ApocalypseWarehouseVisualReviewTests
extends RefCounted

const WAREHOUSE_SCENE = preload("res://scenes/reviews/apocalypse_warehouse_review.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")


static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The warehouse review uses the shared apocalypse run seam")
	if apocalypse_run == null:
		return
	apocalypse_run.start_new_session()
	var warehouse: Control = WAREHOUSE_SCENE.instantiate() as Control
	test.expect_true(warehouse != null, "The authored industrial warehouse scene instantiates")
	if warehouse == null:
		return
	scene_tree.root.add_child(warehouse)
	var hotspot_grid := warehouse.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid") as GridContainer
	var loading_bay := warehouse.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/LoadingBay") as Button
	var maintenance_cage := warehouse.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MaintenanceCage") as Button
	var scene_art := warehouse.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/SceneArt/Art") as TextureRect
	var search_action := warehouse.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction") as Button
	var search_state := warehouse.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	var clock := warehouse.get_node("Margin/RootVBox/Header/HeaderRow/Clock") as Label
	var take_all := warehouse.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll") as Button
	var exit := warehouse.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	test.expect_equal(hotspot_grid.get_child_count(), 2, "The warehouse scene exposes two authored search hotspots")
	test.expect_true(scene_art.texture != null, "The warehouse scene saves its authored industrial background as a texture resource")
	if scene_art.texture != null:
		test.expect_equal(scene_art.texture.resource_path, "res://assets/art/apocalypse/backgrounds/industrial_warehouse_generated.png", "The warehouse scene uses the archived industrial background")
	var global_overlay := warehouse.get_node_or_null("GlobalOverlay")
	test.expect_true(global_overlay != null, "The warehouse reuses the shared backpack and system overlay")
	if global_overlay != null:
		test.expect_equal(global_overlay.get_index(), warehouse.get_child_count() - 1, "The warehouse overlay stays above the authored backdrop and content")
	loading_bay.pressed.emit()
	search_action.pressed.emit()
	test.expect_equal(search_state.text, "部分搜索 · 已显露 1/2", "The loading bay reveals its first authored item")
	test.expect_equal(clock.text, "第 1 日 · 06:07", "Loading-bay searching advances the shared apocalypse clock")
	take_all.pressed.emit()
	test.expect_equal(apocalypse_run.get_active_session().get_container_total_weight(&"backpack"), 6, "Taking loading-bay fuel moves it into the shared backpack")
	maintenance_cage.pressed.emit()
	search_action.pressed.emit()
	test.expect_equal(search_state.text, "部分搜索 · 已显露 1/2", "The maintenance cage keeps an independent search state")
	test.expect_equal(clock.text, "第 1 日 · 06:13", "Maintenance-cage searching uses its authored time cost")
	test.expect_equal(apocalypse_run.get_active_session().get_location_search_noise(&"industrial_warehouse"), 4, "Warehouse searches accumulate authored metal-noise pressure")
	exit.pressed.emit()
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
	var save_result: Dictionary = repository.load_slot("auto_1")
	test.expect_true(bool(save_result.get("ok", false)), "Leaving the warehouse writes the shared apocalypse autosave")
	if bool(save_result.get("ok", false)):
		var saved_warehouse: Dictionary = save_result["snapshot"]["known_locations"]["industrial_warehouse"]
		test.expect_equal(saved_warehouse["search_containers"]["warehouse_loading_bay"]["state"], "partial", "The autosave preserves the loading-bay search state")
		test.expect_equal(saved_warehouse["search_containers"]["warehouse_maintenance_cage"]["state"], "partial", "The autosave preserves the maintenance-cage search state")
	if warehouse.get_parent() != null:
		warehouse.get_parent().remove_child(warehouse)
	warehouse.free()
