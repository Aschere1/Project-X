class_name ApocalypseStorageVisualReviewTests
extends RefCounted

const SHELTER_SCENE = preload("res://scenes/world/apocalypse_shelter.tscn")

static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The storage review uses the shared apocalypse run")
	if apocalypse_run == null:
		return
	var session: Variant = apocalypse_run.start_new_session()
	test.expect_true(session.place_item_in_container(&"backpack", &"water_1", &"water", 1, 1, 5), "The storage review starts with one carried item")
	test.expect_true(session.place_item_in_container(&"backpack", &"water_1", &"water", 1, 1, 5), "The storage review accepts a second copy of the same item type")
	test.expect_true(session.place_item_in_container(&"backpack", &"water_1", &"water", 1, 1, 5), "The storage review accepts a third copy of the same item type")
	test.expect_true(session.place_item_in_container(&"backpack", &"clinic_key_1", &"clinic_key", 1, 1, 1), "The storage review includes a no-icon key fallback")
	var shelter: Node2D = SHELTER_SCENE.instantiate() as Node2D
	test.expect_true(shelter != null, "The shelter scene instantiates for the storage review")
	if shelter == null:
		return
	scene_tree.root.add_child(shelter)
	var storage_hotspot: Button = shelter.get_node("Canvas/MapHotspots/StorageShed") as Button
	var storage_modal: Control = shelter.get_node("Canvas/StorageModal") as Control
	var storage_title: Label = shelter.get_node("Canvas/StorageModal/Panel/VBox/Title") as Label
	var backpack_grid: ApocalypseInventoryGridView = shelter.get_node("Canvas/StorageModal/Panel/VBox/Columns/BackpackPanel/VBox/Items") as ApocalypseInventoryGridView
	var home_panel: PanelContainer = shelter.get_node("Canvas/StorageModal/Panel/VBox/Columns/HomeStoragePanel") as PanelContainer
	var home_grid: ApocalypseInventoryGridView = shelter.get_node("Canvas/StorageModal/Panel/VBox/Columns/HomeStoragePanel/VBox/Items") as ApocalypseInventoryGridView
	var equipment_status: Label = shelter.get_node("Canvas/StorageModal/Panel/VBox/EquipmentStatus") as Label
	var hud_backpack_button: Button = shelter.get_node("Canvas/HUD/BackpackButton") as Button
	var system_menu: Control = shelter.get_node("Canvas/SystemMenu") as Control
	var system_menu_status: Label = shelter.get_node("Canvas/SystemMenu/Panel/VBox/Status") as Label
	var system_continue_button: Button = shelter.get_node("Canvas/SystemMenu/Panel/VBox/ContinueButton") as Button
	var system_backpack_button: Button = shelter.get_node("Canvas/SystemMenu/Panel/VBox/BackpackButton") as Button
	var system_save_button: Button = shelter.get_node("Canvas/SystemMenu/Panel/VBox/SaveButton") as Button
	test.expect_true(storage_modal != null and not storage_modal.visible, "The storage modal starts hidden")
	var inventory_events: Array[InputEvent] = InputMap.action_get_events("open_inventory")
	test.expect_true(inventory_events.any(func(event: InputEvent) -> bool: return event is InputEventKey and (event as InputEventKey).keycode == KEY_B), "The backpack action uses the matching B key")
	var save_events: Array[InputEvent] = InputMap.action_get_events("save_game")
	test.expect_true(save_events.any(func(event: InputEvent) -> bool: return event is InputEventKey and (event as InputEventKey).keycode == KEY_S), "The system-menu save action uses the matching S key")
	hud_backpack_button.pressed.emit()
	test.expect_true(storage_modal.visible, "The compact HUD backpack button opens a real standalone inventory")
	test.expect_equal(storage_title.text, "随身背包与装备", "Standalone inventory has its own backpack title")
	test.expect_true(not home_panel.visible, "Standalone inventory does not expose remote home storage")
	test.expect_true(backpack_grid.has_signal("item_drop_requested"), "The backpack grid exposes a standard drag-and-drop request")
	var standalone_water: Button = backpack_grid.get_node_or_null("Item_water_1") as Button
	test.expect_true(standalone_water != null and standalone_water.has_method("set_drag_identity"), "Rendered items carry drag identity without changing their slot size")
	var backpack_close_button: Button = shelter.get_node("Canvas/StorageModal/Panel/VBox/CloseButton") as Button
	backpack_close_button.pressed.emit()
	storage_hotspot.pressed.emit()
	test.expect_true(storage_modal.visible, "Clicking the storage hotspot opens the real storage modal")
	test.expect_true(home_panel.visible, "The real storage hotspot restores the home-storage column")
	test.expect_equal(backpack_grid.get_grid_dimensions(), Vector2i(6, 4), "The backpack renders its real six-by-four inventory grid")
	test.expect_equal(home_grid.get_grid_dimensions(), Vector2i(8, 6), "Home storage renders its real eight-by-six inventory grid")
	test.expect_equal(backpack_grid.get_rendered_item_count(), 2, "Three water bottles stack into one block beside one key block")
	test.expect_equal(home_grid.get_rendered_item_count(), 0, "An empty home storage grid has no item blocks")
	var drag_payload := {"kind": &"apocalypse_inventory_item", "container_id": &"backpack", "instance_id": &"water_1"}
	test.expect_true(home_grid._can_drop_data(Vector2(55, 37), drag_payload), "The home grid accepts a valid inventory drag over one of its cells")
	home_grid._drop_data(Vector2(55, 37), drag_payload)
	test.expect_equal(session.get_container_total_weight(&"backpack"), 1, "Dragging transfers the full water stack out of the backpack")
	test.expect_equal(session.get_container_total_weight(&"home_storage"), 15, "Cross-container drag preserves the full stack weight")
	test.expect_equal(home_grid.get_rendered_item_count(), 1, "The home storage grid refreshes after a drag-and-drop transfer")
	var dragged_water: Dictionary = session.get_container_items(&"home_storage")[0]
	test.expect_equal(Vector2i(int(dragged_water["x"]), int(dragged_water["y"])), Vector2i(3, 2), "The dragged stack lands in the exact target cell")
	var water_block: Button = home_grid.get_node_or_null("Item_water_1") as Button
	test.expect_true(water_block != null, "A transferred item renders as a real home-storage slot block")
	if water_block != null:
		test.expect_equal(water_block.size, Vector2(16, 16), "A one-slot item fits inside one 18-pixel inventory cell")
		test.expect_equal(water_block.text, "", "An item with a logo renders without redundant text behind it")
		test.expect_equal(water_block.get_theme_font_size("font_size"), 6, "Inventory slot text uses a smaller compact font size")
		var quantity_badge: Panel = water_block.get_node_or_null("QuantityBadge") as Panel
		var quantity_label: Label = water_block.get_node_or_null("QuantityBadge/Quantity") as Label
		test.expect_true(quantity_badge != null and quantity_label != null, "A stacked supply owns a dedicated quantity badge inside its item block")
		if quantity_badge != null and quantity_label != null:
			test.expect_equal(quantity_label.text, "×3", "A stacked supply shows its quantity inside the single cell")
			test.expect_equal(quantity_badge.offset_right, -1.0, "The quantity badge is anchored to the item block's right edge")
			test.expect_equal(quantity_badge.offset_bottom, -1.0, "The quantity badge is anchored to the item block's bottom edge")
			var badge_style: StyleBoxFlat = quantity_badge.get_theme_stylebox("panel") as StyleBoxFlat
			test.expect_true(badge_style != null and badge_style.bg_color.a < 0.5, "The quantity badge uses a translucent background that does not hide the icon")
		test.expect_equal(water_block.tooltip_text, "饮用水\n补给 · 3/16 · 单格\n效果：口渴等级 -1\n家园仓储不计负重", "Hover details show the stack cap, active effect and no-weight storage rule")
	var key_block: Button = backpack_grid.get_node_or_null("Item_clinic_key_1") as Button
	test.expect_true(key_block != null, "The no-icon key renders as an inventory slot block")
	if key_block != null:
		test.expect_equal(key_block.text, "", "The key does not render a large fallback character behind its icon")
		test.expect_equal(key_block.get_theme_font_size("font_size"), 6, "The key keeps the same compact slot font sizing")
		test.expect_true(key_block.has_method("set_fallback_icon"), "The no-logo key uses the dedicated compact fallback icon renderer")
		test.expect_equal(key_block.tooltip_text, "诊所钥匙\n任务物品 · 1/16 · 单格\n用途：开启诊所锁柜\n单件负重 1", "The key hover details explain its quantity and active intended use")
	var storage_context_menu: PopupMenu = storage_modal.get_node_or_null("StorageItemContextMenu") as PopupMenu
	var storage_split_dialog: ConfirmationDialog = storage_modal.get_node_or_null("StorageSplitDialog") as ConfirmationDialog
	var storage_split_amount: SpinBox = storage_modal.get_node_or_null("StorageSplitDialog/Amount") as SpinBox
	test.expect_true(storage_context_menu != null, "The storage modal owns one reusable right-click item menu")
	test.expect_true(storage_split_dialog != null and storage_split_amount != null, "The storage modal owns a quantity picker for custom stack splits")
	home_grid.item_context_requested.emit(&"home_storage", &"water_1", Vector2i(96, 96))
	test.expect_true(storage_context_menu.visible, "Right-clicking a storage item opens its context menu")
	if storage_context_menu != null:
		test.expect_equal(storage_context_menu.get_theme_font_size("font_size"), 8, "The right-click menu uses the fixed compact font size")
		test.expect_equal(storage_context_menu.size.x, 132.0, "The right-click menu uses the fixed compact width")
		test.expect_equal(storage_context_menu.get_item_text(0), "饮用 1", "A usable home storage water stack offers its compact use action first")
		test.expect_equal(storage_context_menu.get_item_text(2), "取出 1", "A home storage stack offers a one-item transfer action after use")
		test.expect_equal(storage_context_menu.get_item_text(3), "取出整组", "A home storage stack offers a full-stack transfer action")
		test.expect_equal(storage_context_menu.get_item_text(5), "拆分一半", "A multi-item stack offers a half-split action")
		test.expect_equal(storage_context_menu.get_item_text(6), "拆分指定数量…", "A multi-item stack offers a custom split action")
		storage_context_menu.id_pressed.emit(storage_context_menu.get_item_id(2))
		var backpack_water: Array[Dictionary] = session.get_container_items(&"backpack").filter(func(item: Dictionary) -> bool: return StringName(item["item_id"]) == &"water")
		var home_water: Array[Dictionary] = session.get_container_items(&"home_storage").filter(func(item: Dictionary) -> bool: return StringName(item["item_id"]) == &"water")
		test.expect_equal(backpack_water[0]["quantity"], 1, "The menu's one-item action transfers only one bottle into the backpack")
		test.expect_equal(home_water[0]["quantity"], 2, "The source storage stack keeps its remaining quantity")
		home_grid.item_context_requested.emit(&"home_storage", &"water_1", Vector2i(96, 96))
		storage_context_menu.id_pressed.emit(storage_context_menu.get_item_id(6))
		test.expect_true(storage_split_dialog.visible, "The custom split action opens a quantity picker")
		storage_split_amount.value = 1
		storage_split_dialog.confirmed.emit()
		home_water = session.get_container_items(&"home_storage").filter(func(item: Dictionary) -> bool: return StringName(item["item_id"]) == &"water")
		test.expect_equal(home_water.size(), 2, "The context menu custom split creates a second home storage stack")
		test.expect_equal(home_water[0]["quantity"] + home_water[1]["quantity"], 2, "Custom splitting through the menu preserves total item quantity")
	test.expect_true(session.place_item_in_container(&"backpack", &"crowbar_storage", &"crowbar", 1, 1, 3), "The storage review can carry the clinic crowbar")
	storage_hotspot.pressed.emit()
	var crowbar_block: Button = backpack_grid.get_node_or_null("Item_crowbar_storage") as Button
	test.expect_true(crowbar_block != null and crowbar_block.size == Vector2(16, 16), "The crowbar fits one compact inventory cell")
	if crowbar_block != null:
		test.expect_equal(crowbar_block.text, "", "The crowbar uses a compact icon without background lettering")
		test.expect_equal(crowbar_block.tooltip_text, "撬棍\n武器 · 1/1 · 单格\n近战伤害 8 · 体力消耗 6 · 噪声 1\n单件负重 3", "The crowbar details expose combat values and weight")
	backpack_grid.item_context_requested.emit(&"backpack", &"crowbar_storage", Vector2i(96, 96))
	test.expect_equal(storage_context_menu.get_item_text(0), "装备为主武器", "A backpack weapon offers the compact equip action first")
	storage_context_menu.id_pressed.emit(storage_context_menu.get_item_id(0))
	test.expect_equal(session.get_equipped_weapon_snapshot()["item_id"], &"crowbar", "The storage context menu equips the selected crowbar")
	test.expect_equal(equipment_status.text, "主武器：撬棍 · 近战伤害 8 · 体力 6 · 噪声 1", "The compact equipment line shows the equipped weapon's exact values")
	backpack_grid.item_context_requested.emit(&"backpack", &"crowbar_storage", Vector2i(96, 96))
	test.expect_equal(storage_context_menu.get_item_text(0), "卸下主武器", "The equipped weapon menu switches to an unequip action")
	backpack_grid.item_activated.emit(&"backpack", &"crowbar_storage")
	test.expect_equal(session.get_equipped_weapon_snapshot()["display_name"], "空手", "Storing the equipped crowbar automatically unequips it")
	test.expect_equal(equipment_status.text, "主武器：空手 · 近战伤害 2", "The equipment line returns to the compact unarmed state")
	test.expect_true(session.place_item_in_container(&"home_storage", &"fuel_generator", &"fuel_can", 1, 1, 6), "The home storage can hold a fuel can for the generator")
	var main_house: Button = shelter.get_node("Canvas/MapHotspots/MainHouse") as Button
	var feature_modal: Control = shelter.get_node("Canvas/FeatureModal") as Control
	var feature_title: Label = shelter.get_node("Canvas/FeatureModal/Panel/VBox/Title") as Label
	var feature_action: Button = shelter.get_node("Canvas/FeatureModal/Panel/VBox/FeatureAction") as Button
	var feature_secondary_action: Button = shelter.get_node("Canvas/FeatureModal/Panel/VBox/FeatureSecondaryAction") as Button
	var feature_tertiary_action: Button = shelter.get_node("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	main_house.pressed.emit()
	test.expect_true(feature_modal.visible, "Clicking the main house opens the compact home-utilities panel")
	test.expect_equal(feature_title.text, "主屋 · 休息 / 家园设施", "The main house presents rest, generator, and medical-station features instead of placeholder text")
	test.expect_true(feature_tertiary_action.visible and not feature_tertiary_action.disabled, "The compact main-house panel always provides the next-day rest action")
	test.expect_equal(feature_tertiary_action.get_theme_font_size("font_size"), 8, "The new rest action keeps the established compact UI font size")
	test.expect_true(feature_action.visible and not feature_action.disabled, "A home-stored fuel can enables the compact generator action")
	feature_action.pressed.emit()
	test.expect_equal(session.get_home_power(), 10, "The main-house generator action adds ten persistent home-power units")
	test.expect_equal(session.get_container_item_quantity(&"home_storage", &"fuel_can"), 0, "The main-house generator action consumes the stored fuel can")
	test.expect_true(session.place_item_in_container(&"home_storage", &"medkit_station", &"medkit", 1, 1, 4), "The home storage can hold a medical kit for the medical station")
	test.expect_true(session.add_survivor_injury(&"laceration"), "The shelter review can add a treatable injury")
	main_house.pressed.emit()
	test.expect_true(feature_secondary_action.visible and not feature_secondary_action.disabled, "A powered medical station with a stored kit enables its compact treatment action")
	feature_secondary_action.pressed.emit()
	test.expect_equal(session.get_home_power(), 0, "The main-house medical action consumes the generator power reserve")
	test.expect_equal(session.get_survivor_snapshot()["injuries"].size(), 0, "The main-house medical action treats one survivor injury")
	test.expect_true(session.place_item_in_container(&"home_storage", &"fuel_workbench", &"fuel_can", 1, 1, 6), "The home storage can hold fuel for the workbench power cost")
	main_house.pressed.emit()
	feature_action.pressed.emit()
	test.expect_true(session.place_item_in_container(&"home_storage", &"scrap_workbench", &"scrap_metal", 1, 1, 1), "The home storage can hold scrap metal for the workbench recipe")
	test.expect_true(session.place_item_in_container(&"home_storage", &"wire_workbench", &"wire", 1, 1, 1), "The home storage can hold wire for the workbench recipe")
	var workbench: Button = shelter.get_node("Canvas/MapHotspots/Workbench") as Button
	workbench.pressed.emit()
	test.expect_equal(feature_title.text, "工作台 · 简易开锁工具", "The workbench presents its one concrete crafting recipe")
	test.expect_true(feature_action.visible and not feature_action.disabled, "Stored materials and power enable the compact workbench recipe")
	feature_action.pressed.emit()
	test.expect_equal(session.get_home_power(), 5, "The workbench UI consumes five home-power units")
	test.expect_equal(session.get_container_item_quantity(&"home_storage", &"simple_lockpick"), 1, "The workbench UI creates one lockpick in home storage")
	test.expect_true(session.place_item_in_container(&"home_storage", &"fuel_first_raid", &"fuel_can", 1, 1, 6), "The returned clinic fuel can can be stored for first-raid preparation")
	test.expect_true(session.place_item_in_container(&"home_storage", &"medkit_first_raid", &"medkit", 1, 1, 4), "The returned clinic medical kit can be stored for first-raid preparation")
	main_house.pressed.emit()
	feature_action.pressed.emit()
	var objective_label: Label = shelter.get_node("Canvas/HUD/CampaignObjective/Objective") as Label
	test.expect_true(objective_label.text.contains("准备 3/3"), "The shelter objective board immediately reflects power, medicine, and the stored crowbar")
	feature_tertiary_action.pressed.emit()
	test.expect_equal(session.get_day(), 2, "The player-facing rest button advances the run to day two")
	feature_tertiary_action.pressed.emit()
	test.expect_equal(session.get_day(), 3, "A second player-facing rest advances the run to day three")
	feature_tertiary_action.pressed.emit()
	test.expect_equal(session.get_day(), 4, "A third player-facing rest reaches the first-raid dawn")
	test.expect_equal(session.get_campaign_snapshot()["outcome"], &"held", "Clinic supplies and home preparation hold the first raid through the real shelter UI")
	test.expect_equal(feature_title.text, "首轮袭击 · 守住家园", "The shelter presents a concrete successful settlement screen")
	test.expect_true(objective_label.text.contains("首轮袭击已结算"), "The persistent objective board switches from preparation to the settled outcome")
	apocalypse_run.reset_active_session()
	var restored_campaign_session: Variant = apocalypse_run.ensure_active_session()
	test.expect_equal(restored_campaign_session.get_day(), 4, "The shelter rest autosave restores the settled day after the runtime session is cleared")
	test.expect_equal(restored_campaign_session.get_campaign_snapshot()["outcome"], &"held", "The same autosave restores the completed first-raid outcome")
	shelter.call("_close_feature_modal")
	backpack_close_button.pressed.emit()
	var esc_event := InputEventAction.new()
	esc_event.action = &"ui_cancel"
	esc_event.pressed = true
	shelter.call("_unhandled_input", esc_event)
	test.expect_true(system_menu.visible, "Esc opens the compact system menu when no other modal is active")
	test.expect_equal(system_continue_button.get_theme_font_size("font_size"), 8, "The system menu keeps the fixed compact button size")
	var save_event := InputEventAction.new()
	save_event.action = &"save_game"
	save_event.pressed = true
	shelter.call("_unhandled_input", save_event)
	test.expect_equal(system_menu_status.text, "保存完成", "The system menu exposes a real manual save action")
	system_backpack_button.pressed.emit()
	test.expect_true(not system_menu.visible and storage_modal.visible, "The system menu can transition directly into the standalone backpack")
	test.expect_true(not home_panel.visible, "A backpack opened from Esc still hides remote home storage")
	backpack_close_button.pressed.emit()
	shelter.call("_open_system_menu")
	system_continue_button.pressed.emit()
	test.expect_true(not system_menu.visible, "Continue game closes the Esc menu")
	if shelter.get_parent() != null:
		shelter.get_parent().remove_child(shelter)
	shelter.free()
