class_name ApocalypseExploreVisualReviewTests
extends RefCounted

const REVIEW_SCENE = preload("res://scenes/reviews/apocalypse_explore_review.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")

static func run(test: Variant) -> void:
	var review: Control = REVIEW_SCENE.instantiate() as Control
	test.expect_true(review != null, "The apocalypse exploration review scene instantiates")
	if review == null:
		return
	var location_title: Label = review.get_node_or_null("Margin/RootVBox/Header/HeaderRow/LocationTitle") as Label
	var hotspot_grid: GridContainer = review.get_node_or_null("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid") as GridContainer
	var loadout_row: HBoxContainer = review.get_node_or_null("Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow") as HBoxContainer
	var illustration_slot: TextureRect = review.get_node_or_null("Margin/RootVBox/Body/ScenePanel/SceneVBox/SceneArt/ArtStack/LocationIllustration") as TextureRect
	test.expect_equal(location_title.text, "县郊 · 村卫生室", "The review scene keeps the authored location title")
	test.expect_equal(hotspot_grid.columns, 2, "The review scene keeps two columns of location hotspots")
	test.expect_equal(hotspot_grid.get_child_count(), 4, "The review scene exposes four location hotspots")
	test.expect_equal(loadout_row.get_child_count(), 4, "The review scene exposes pockets, chest rig, backpack and secure pouch")
	test.expect_true(illustration_slot != null, "The review scene exposes an Inspector-replaceable location illustration slot")
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree != null:
		var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
		test.expect_true(apocalypse_run != null, "The exploration review uses the shared apocalypse run seam")
		if apocalypse_run == null:
			review.free()
			return
		apocalypse_run.start_new_session()
		scene_tree.root.add_child(review)
		var global_overlay: Variant = review.get_node_or_null("GlobalOverlay")
		test.expect_true(global_overlay != null, "The clinic owns the reusable disaster UI overlay")
		if global_overlay != null:
			test.expect_equal(global_overlay.get_index(), review.get_child_count() - 1, "The clinic overlay stays above the authored backdrop and content")
		var inventory_event := InputEventAction.new()
		inventory_event.action = &"open_inventory"
		inventory_event.pressed = true
		review.call("_unhandled_input", inventory_event)
		test.expect_true(global_overlay.is_backpack_open(), "B opens the same backpack while searching the clinic")
		var overlay_grid: ApocalypseInventoryGridView = global_overlay.get_node("InventoryModal/Panel/VBox/Items") as ApocalypseInventoryGridView
		test.expect_equal(overlay_grid.get_grid_dimensions(), Vector2i(6, 4), "The clinic overlay reads the shared session backpack")
		var escape_event := InputEventAction.new()
		escape_event.action = &"ui_cancel"
		escape_event.pressed = true
		review.call("_unhandled_input", escape_event)
		test.expect_true(not global_overlay.is_backpack_open(), "Esc closes the clinic backpack before any location exit")
		review.call("_unhandled_input", escape_event)
		test.expect_true(global_overlay.is_system_menu_open(), "Esc opens the clinic system menu instead of leaving the location")
		review.call("_unhandled_input", escape_event)
		test.expect_true(not global_overlay.is_system_menu_open(), "A second Esc closes the clinic system menu")
		test.expect_true(illustration_slot.texture != null, "The review scene binds the supplied county clinic illustration")
		var medicine_cabinet: Button = review.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MedicineCabinet") as Button
		var front_desk: Button = review.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/FrontDesk") as Button
		var clinic_lockbox: Button = review.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/ClinicLockbox") as Button
		var exit_button: Button = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
		var search_action: Button = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction") as Button
		var search_title: Label = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchTitle") as Label
		var search_state: Label = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
		var noise_label: Label = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/Noise") as Label
		var found_loot_title: Label = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootTitle") as Label
		var found_loot_list: VBoxContainer = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/FoundLootList") as VBoxContainer
		var take_all_button: Button = review.get_node("Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll") as Button
		var backpack_label: Label = review.get_node("Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Label") as Label
		var backpack_slot_2: Panel = review.get_node("Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Grid/Slot2") as Panel
		var backpack_slot_1_icon: TextureRect = review.get_node("Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Grid/Slot1/Icon") as TextureRect
		var backpack_slot_2_icon: TextureRect = review.get_node("Margin/RootVBox/LoadoutPanel/LoadoutVBox/LoadoutRow/Backpack/VBox/Grid/Slot2/Icon") as TextureRect
		var clock_label: Label = review.get_node("Margin/RootVBox/Header/HeaderRow/Clock") as Label
		test.expect_equal(search_state.text, "未搜索 · 已显露 0/3", "The review binds the initial three-item medicine-container state")
		test.expect_equal(clock_label.text, "第 1 日 · 06:00", "The review binds the apocalypse session clock")
		test.expect_true(backpack_slot_1_icon.texture != null and backpack_slot_1_icon.visible, "The initial carried item uses the supplied water icon")
		medicine_cabinet.pressed.emit()
		search_action.pressed.emit()
		test.expect_equal(search_state.text, "部分搜索 · 已显露 1/3", "The review reveals one real search-container item")
		test.expect_equal(noise_label.text, "地点噪声 +2 · 容器 +2 · 搜索 8 分钟", "The review mirrors cumulative location noise and container search cost")
		test.expect_equal(backpack_label.text, "背包 · 15/20", "Revealed loot remains in the source container until the player chooses to take it")
		test.expect_equal(found_loot_title.text, "已发现物资 · 1", "The reveal UI reports one uncollected supply")
		test.expect_equal(found_loot_list.get_child_count(), 1, "The reveal UI renders one take-one action")
		var take_medkit: Button = found_loot_list.get_node("Take_medkit_1") as Button
		test.expect_true(take_medkit != null, "A revealed medical kit receives its own take-to-backpack action")
		take_medkit.pressed.emit()
		test.expect_equal(backpack_label.text, "背包 · 19/20", "Taking a chosen item moves it into the backpack")
		test.expect_true(backpack_slot_2.self_modulate != Color.WHITE, "The backpack highlights the second occupied cell after the player takes the medkit")
		test.expect_true(backpack_slot_2_icon.texture != null and backpack_slot_2_icon.visible, "The chosen medkit uses the supplied icon")
		test.expect_equal(clock_label.text, "第 1 日 · 06:08", "The first search advances the apocalypse clock")
		search_action.pressed.emit()
		test.expect_equal(search_state.text, "部分搜索 · 已显露 2/3", "The review keeps the final crafting material hidden until a third medicine search")
		test.expect_equal(found_loot_title.text, "已发现物资 · 1", "The second revealed item waits for an explicit backpack choice")
		take_all_button.pressed.emit()
		test.expect_equal(backpack_label.text, "背包 · 20/20", "Taking all moves every currently revealed item into the backpack")
		test.expect_equal(clock_label.text, "第 1 日 · 06:11", "The second search advances the apocalypse clock")
		search_action.pressed.emit()
		test.expect_equal(search_state.text, "搜索完成 · 已显露 3/3", "The third medicine search reveals the authored scrap-metal crafting material")
		take_all_button.pressed.emit()
		test.expect_equal(clock_label.text, "第 1 日 · 06:13", "The crafting-material search advances the shared clock by its authored time")
		test.expect_true(search_action.disabled, "The review disables search after all medicine-container items are revealed")
		front_desk.pressed.emit()
		test.expect_equal(search_title.text, "前台 · 容器", "The review switches to the front desk container")
		test.expect_equal(search_state.text, "未搜索 · 已显露 0/2", "The front desk keeps its own two-item search state")
		search_action.pressed.emit()
		test.expect_equal(search_state.text, "部分搜索 · 已显露 1/2", "The front desk first reveals the wire crafting material")
		test.expect_equal(clock_label.text, "第 1 日 · 06:16", "Searching wire continues the shared clock")
		test.expect_equal(backpack_label.text, "背包 · 21/20", "The revealed wire waits in the front desk until explicitly taken")
		take_all_button.pressed.emit()
		test.expect_equal(backpack_label.text, "背包 · 22/20", "Taking wire adds a crafting material to the backpack")
		search_action.pressed.emit()
		test.expect_equal(search_state.text, "搜索完成 · 已显露 2/2", "The front desk reveals its key after the wire")
		test.expect_equal(clock_label.text, "第 1 日 · 06:20", "Searching the front-desk key continues the shared clock")
		take_all_button.pressed.emit()
		test.expect_equal(backpack_label.text, "背包 · 23/20", "Taking the key makes it available for the lockbox")
		clinic_lockbox.pressed.emit()
		test.expect_equal(search_title.text, "锁柜 · 需要钥匙或开锁工具", "The clinic lockbox describes its key-or-tool entry options")
		test.expect_equal(search_state.text, "锁定 · 需要钥匙或开锁工具", "The clinic lockbox starts locked")
		test.expect_true(not search_action.disabled, "Finding the front-desk key enables the lockbox action")
		search_action.pressed.emit()
		test.expect_equal(clock_label.text, "第 1 日 · 06:25", "Unlocking the cabinet with its durable key consumes five shared-world minutes")
		test.expect_equal(search_state.text, "未搜索 · 已显露 0/3", "An unlocked cabinet exposes medical supplies and one weapon")
		search_action.pressed.emit()
		test.expect_equal(clock_label.text, "第 1 日 · 06:31", "Searching unlocked cabinet supplies uses their authored time")
		var active_session: Variant = apocalypse_run.ensure_active_session()
		active_session.record_location_search_noise(&"village_clinic", 5)
		var ambulance: Button = review.get_node("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/Ambulance") as Button
		ambulance.pressed.emit()
		search_action.pressed.emit()
		test.expect_equal(clock_label.text, "第 1 日 · 06:31", "The first dangerous-search click asks for confirmation without spending time")
		test.expect_true(search_action.text.begins_with("危险搜索 · 再点击确认"), "Dangerous searches require a visible second confirmation click")
		search_action.pressed.emit()
		test.expect_equal(clock_label.text, "第 1 日 · 06:41", "A confirmed dangerous search spends the authored item-search time")
		var exit_request: Dictionary = {}
		review.location_exit_requested.connect(func(save_result: Dictionary) -> void:
			exit_request["save_result"] = save_result
		)
		exit_button.pressed.emit()
		var exit_save_result: Dictionary = exit_request.get("save_result", {})
		test.expect_true(bool(exit_save_result.get("ok", false)), "Leaving the location requests an autosave before returning to the region map")
		var save_repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
		var save_result: Dictionary = save_repository.load_slot("auto_1")
		test.expect_true(bool(save_result.get("ok", false)), "Leaving the location writes an apocalypse autosave")
		test.expect_equal(save_result["snapshot"]["containers"]["backpack"]["items"].size(), 6, "The autosave keeps stacked water plus the selected clinic supplies and crafting materials")
		var saved_clinic: Dictionary = save_result["snapshot"]["known_locations"]["village_clinic"]
		test.expect_equal(saved_clinic["search_containers"]["clinic_medicine_cabinet"]["state"], "searched", "The autosave keeps completed clinic search progress")
		test.expect_true(bool(saved_clinic["unlocked_locks"].get("clinic_locked_cabinet", false)), "The autosave keeps the unlocked clinic cabinet state")
		test.expect_equal(saved_clinic["search_noise"], 13, "The autosave keeps cumulative location noise across every searched clinic container")
		scene_tree.root.remove_child(review)
		review.free()
	else:
		review.free()
