class_name ApocalypseMarketVisualReviewTests
extends RefCounted

const MARKET_SCENE = preload("res://scenes/reviews/apocalypse_market_review.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")

static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The market review uses the shared apocalypse run seam")
	if apocalypse_run == null:
		return
	apocalypse_run.start_new_session()
	var market: Control = MARKET_SCENE.instantiate() as Control
	test.expect_true(market != null, "The authored market scavenging scene instantiates")
	if market == null:
		return
	scene_tree.root.add_child(market)
	var markers: GridContainer = market.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid") as GridContainer
	var counter: Button = market.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MarketCounter") as Button
	var storeroom: Button = market.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MarketStoreroom") as Button
	var search_action: Button = market.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction") as Button
	var search_state: Label = market.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	var clock: Label = market.get_node("Margin/RootVBox/Header/HeaderRow/Clock") as Label
	var take_all: Button = market.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll") as Button
	var exit: Button = market.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	test.expect_equal(markers.get_child_count(), 2, "The market scene exposes two authored search hotspots")
	var global_overlay := market.get_node_or_null("GlobalOverlay")
	test.expect_true(global_overlay != null, "The market reuses the shared backpack and system overlay")
	if global_overlay != null:
		test.expect_equal(global_overlay.get_index(), market.get_child_count() - 1, "The market overlay stays above the authored backdrop and content")
	counter.pressed.emit()
	search_action.pressed.emit()
	test.expect_equal(search_state.text, "部分搜索 · 已显露 1/2", "The market counter reveals its first authored item")
	test.expect_equal(clock.text, "第 1 日 · 06:04", "Market searching advances the shared apocalypse clock")
	take_all.pressed.emit()
	test.expect_equal(apocalypse_run.get_active_session().get_container_total_weight(&"backpack"), 5, "Taking market counter loot moves it into the shared backpack")
	storeroom.pressed.emit()
	search_action.pressed.emit()
	test.expect_equal(search_state.text, "部分搜索 · 已显露 1/2", "The market storeroom keeps an independent search state")
	test.expect_equal(clock.text, "第 1 日 · 06:12", "The storeroom search uses its authored time cost")
	take_all.pressed.emit()
	exit.pressed.emit()
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
	var save_result: Dictionary = repository.load_slot("auto_1")
	test.expect_true(bool(save_result.get("ok", false)), "Leaving the market writes the shared apocalypse autosave")
	if bool(save_result.get("ok", false)):
		var saved_market: Dictionary = save_result["snapshot"]["known_locations"]["county_market"]
		test.expect_equal(saved_market["search_containers"]["market_counter"]["state"], "partial", "The autosave preserves the market counter search state")
		test.expect_equal(saved_market["search_containers"]["market_storeroom"]["state"], "partial", "The autosave preserves the market storeroom search state")
	if market.get_parent() != null:
		market.get_parent().remove_child(market)
	market.free()
