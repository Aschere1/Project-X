class_name HomeRegionTests
extends RefCounted

const HOME_REGION_SCENE = preload("res://scenes/world/home_region.tscn")

static func run(test: Variant) -> void:
	var world := HOME_REGION_SCENE.instantiate() as HomeRegion
	test.expect_true(world != null, "The formal HomeRegion scene instantiates")
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(world)

	test.expect_equal(world.get_map_size(), Vector2i(60, 34), "The first home region has the agreed finite 60x34 tile footprint")
	test.expect_equal(world.get_world_size(), Vector2i(960, 544), "The home region derives world size from the 16px grid")
	for layer_name in [&"Ground", &"Terrain", &"Objects", &"Foreground"]:
		var layer := world.get_node_or_null(NodePath(layer_name)) as TileMapLayer
		test.expect_true(layer != null and layer.tile_set != null, "%s is an independent populated TileMapLayer" % layer_name)

	var ground := world.get_node("Ground") as TileMapLayer
	var playable_ground_cells := 0
	for y in range(world.get_map_size().y):
		for x in range(world.get_map_size().x):
			if ground.get_cell_source_id(Vector2i(x, y)) >= 0:
				playable_ground_cells += 1
	test.expect_equal(playable_ground_cells, 60 * 34, "Every playable home-region grid cell has visible ground art")
	test.expect_true(world.uses_super_retro_tile_set(), "The formal home uses the selected Super Retro World TileSet instead of the original placeholder atlas")
	var ground_source := ground.tile_set.get_source(ground.get_cell_source_id(Vector2i(0, 0))) as TileSetAtlasSource
	test.expect_true(ground_source != null and ground_source.texture.resource_path.contains("super_retro_world_farming"), "The grass ground resolves to the unified private art baseline")
	var grass_tiles: Dictionary[Vector2i, bool] = {}
	for cell in ground.get_used_cells():
		grass_tiles[ground.get_cell_atlas_coords(cell)] = true
	test.expect_equal(grass_tiles.size(), 1, "The authored map uses one clean grass base instead of stamping a decoration motif on every cell")
	test.expect_true(grass_tiles.has(Vector2i(18, 30)), "The authored map uses the fully opaque clean grass tile")
	test.expect_true(
		ground.has_method("set_cell") and world.get_node_or_null("Farmhouse") != null,
		"The editor-paintable map and buildings live together in the complete HomeRegion scene"
	)
	test.expect_equal(world.get_interactable_count(), 225, "The home region exposes the full 20x11 editor-authored farm grid plus its life-loop targets")
	var farm_plots := world.get_node("FarmPlots") as Node2D
	test.expect_equal(farm_plots.get_child_count(), 219, "The remaining farm cells are saved as selectable scene instances under FarmPlots")
	var farm_grid_is_aligned := true
	for child in farm_plots.get_children():
		var plot := child as FarmPlot
		if plot == null or plot.position != Vector2(plot.grid_cell.x * 16 + 8, plot.grid_cell.y * 16 + 8):
			farm_grid_is_aligned = false
	test.expect_true(farm_grid_is_aligned, "Every editor-authored farm instance sits on the center of its declared 16px TileMap cell")
	test.expect_true(world.get_node_or_null("SpringFarmBackdrop") == null, "The formal map has no private full-map backdrop")

	var structural_collision := world.get_node("StructuralCollision") as StaticBody2D
	test.expect_true(structural_collision.get_child_count() >= 10, "Visible buildings, pond, trees and bounds have matching structural collisions")
	var house_shape := structural_collision.get_node("FarmhouseCollision").shape as RectangleShape2D
	var coop_shape := structural_collision.get_node("ChickenCoopCollision").shape as RectangleShape2D
	var pond_shape := structural_collision.get_node("PondCollision").shape as RectangleShape2D
	var tree_shape := structural_collision.get_node("TreeACollision").shape as RectangleShape2D
	test.expect_equal(house_shape.size, Vector2(120, 16), "The Super Retro farmhouse blocks only its visible bottom wall footprint, not its roof or the grass in front")
	test.expect_equal(coop_shape.size, Vector2(56, 18), "The coop only blocks its grounded wall footprint")
	test.expect_equal(pond_shape.size, Vector2(124, 136), "The pond collision covers the visible water while leaving only a narrow walkable shore")
	test.expect_equal(tree_shape.size, Vector2(8, 6), "Super Retro trees block only the visible root base rather than their leaf canopy")
	test.expect_equal(structural_collision.get_node("TreeACollision").position, Vector2(104, 150), "The tree collision overlaps the new sprite's root pixels instead of floating below them")
	for collision_name in ["Rock01Collision", "Rock02Collision", "Rock03Collision", "Rock04Collision", "FieldEdgeCrateCollision", "FieldEdgeBarrelCollision", "FieldEdgePlantACollision", "FieldEdgePlantBCollision", "FieldEdgeRockACollision"]:
		var decoration_collision := structural_collision.get_node_or_null(collision_name) as CollisionShape2D
		test.expect_true(decoration_collision != null and decoration_collision.shape is RectangleShape2D, "%s has an editor-authored bottom-footprint collision" % collision_name)
		if decoration_collision != null and decoration_collision.shape is RectangleShape2D:
			test.expect_true((decoration_collision.shape as RectangleShape2D).size.y <= 4.0, "%s blocks only the decoration's grounded base" % collision_name)
	var decoration_sprites := world.get_node("DecorationSprites") as Node2D
	for decoration_node in decoration_sprites.get_children():
		if decoration_node is Sprite2D:
			var paired_collision := structural_collision.get_node_or_null("%sCollision" % decoration_node.name) as CollisionShape2D
			test.expect_true(paired_collision != null, "%s has a matching editor collision" % decoration_node.name)
	var player := world.get_node("Player") as PlayerController
	test.expect_true(player.is_super_retro_walk_visual_active(), "The formal player uses the selected Super Retro World 32x32 development atlas")
	test.expect_equal(world.get_visual_baseline_id(), &"super_retro_world", "The home region activates the selected development art adapter when the private pack is present")
	test.expect_equal(player.movement_bounds, Rect2(16, 16, 928, 512), "Player clamping matches the finite home-region boundary")
	var camera := world.get_node("Player/Camera2D") as Camera2D
	test.expect_equal(camera.limit_right, 960, "Camera horizontal limit matches the formal map")
	test.expect_equal(camera.limit_bottom, 544, "Camera vertical limit matches the formal map")
	player.global_position = Vector2(104, 140)
	world._process(0.0)
	var tree_a := world.get_node("TreeA") as Sprite2D
	test.expect_true(tree_a.texture.resource_path == "res://assets/private/super_retro_world_farming/Props/Trees/Sprites/tree_01.png", "The home trees use the selected private development art baseline")
	test.expect_true(not tree_a.region_enabled, "The pre-cut Super Retro tree is used as a complete sprite instead of being guessed from a mixed sheet")
	test.expect_equal(tree_a.scale, Vector2(1.5, 1.5), "The smaller source tree is enlarged uniformly to fit the home's visual scale")
	test.expect_equal(tree_a.position, Vector2(104, 124), "The enlarged tree is raised so its root remains aligned with the existing trunk collision")
	test.expect_true(tree_a.z_index > player.z_index and tree_a.modulate.a < 1.0, "A tree becomes a translucent foreground when the player walks behind it")
	player.global_position = Vector2(240, 82)
	world._process(0.0)
	var farmhouse := world.get_node("Farmhouse") as Sprite2D
	test.expect_true(farmhouse.texture.resource_path == "res://assets/private/super_retro_world_farming/Props/Houses/Sprites/house_02.png", "The farmhouse uses the selected private development art baseline")
	test.expect_equal(farmhouse.scale, Vector2(2.0, 2.0), "The 75x48 source farmhouse is enlarged by an integer factor for the current home footprint")
	test.expect_true(farmhouse.z_index > player.z_index and farmhouse.modulate.a < 1.0, "The farmhouse becomes translucent when the player walks behind it")
	player.global_position = Vector2(240, 136)
	world._process(0.0)
	test.expect_true(farmhouse.z_index <= player.z_index and farmhouse.modulate.a == 1.0, "The farmhouse stays opaque when the player stands at its front wall or doorway")
	var terrain := world.get_node("Terrain") as TileMapLayer
	var water_base_tiles: Dictionary[Vector2i, bool] = {}
	for y in range(21, 30):
		for x in range(3, 11):
			water_base_tiles[terrain.get_cell_atlas_coords(Vector2i(x, y))] = true
	test.expect_true(water_base_tiles.size() > 1, "The pond uses connected shoreline, corner and water tiles instead of repeating one flat water square")
	var pond_source_ids: Dictionary[int, bool] = {}
	for y in range(21, 30):
		for x in range(3, 11):
			var pond_cell := Vector2i(x, y)
			pond_source_ids[terrain.get_cell_source_id(pond_cell)] = true
	for source_id in pond_source_ids:
		var pond_source := terrain.tile_set.get_source(source_id) as TileSetAtlasSource
		test.expect_true(pond_source != null and pond_source.texture.resource_path.contains("super_retro_world_farming"), "Every connected pond tile comes from the unified Super Retro water atlas")

	test.expect_true(world.get_node_or_null("Interface/TopBand/HelpLabel") == null, "Control instructions are removed from the always-visible HUD")
	var pause_events := InputMap.action_get_events(&"pause")
	var has_escape := false
	for pause_event in pause_events:
		var pause_key := pause_event as InputEventKey
		if pause_key != null and pause_key.keycode == KEY_ESCAPE:
			has_escape = true
	test.expect_true(has_escape, "Escape opens the settings and controls screen")
	test.expect_true(not world.message_panel.visible, "The dialogue/message panel is hidden until an action produces feedback")
	test.expect_true(world.interaction_indicator.visible, "The nearby interactable is marked in world space without a second bottom-screen prompt")
	world._show_message("测试消息")
	test.expect_true(world.message_panel.visible, "An action produces a temporary message panel")
	world._on_message_timeout()
	test.expect_true(not world.message_panel.visible, "The action message disappears after its timer instead of becoming a permanent bottom bar")
	world._open_settings()
	test.expect_true(world.settings_overlay.visible and world.game_clock.is_paused(), "The settings screen contains controls and pauses home life")
	var controls_label := world.get_node("Interface/SettingsOverlay/Panel/Controls") as Label
	var controls_right_label := world.get_node("Interface/SettingsOverlay/Panel/ControlsRight") as Label
	test.expect_true(controls_label.text.contains("WASD") and controls_label.text.contains("Shift") and controls_right_label.text.contains("Esc"), "Movement, sprint and settings controls live inside the settings screen")
	test.expect_true(world.get_node("Interface/TopBand").visible, "The normal gameplay HUD is visible during exploration")
	test.expect_true(world.get_node("Interface/SettingsOverlay/Panel") is Panel, "The settings screen uses an editor-authored themed panel")
	test.expect_true((world.get_node("Interface/SettingsOverlay/Panel/Title") as Label).text == "设置", "The settings screen has a clear menu title")
	test.expect_true(world.settings_close_button.text == "继续游戏", "The settings screen has a clear resume action")
	world._close_settings()
	test.expect_true(not world.settings_overlay.visible and not world.game_clock.is_paused(), "Closing settings resumes the game")
	world.inventory_controller.set_panel_open(true)
	test.expect_true(world.inventory_overlay.visible and world.game_clock.is_paused(), "Opening the inventory pauses home life")
	test.expect_true((world.get_node("Interface/InventoryOverlay/Panel") as Panel) != null, "The inventory uses the shared editor-authored panel")
	test.expect_true((world.get_node("Interface/InventoryOverlay/Panel/Subtitle") as Label).text == "物品与种子", "The inventory has a clear menu subtitle")
	test.expect_true(world.inventory_close_button.text == "关闭", "The inventory has a visible close action")
	world._close_inventory_panel()
	test.expect_true(not world.inventory_overlay.visible and not world.game_clock.is_paused(), "Closing the inventory resumes home life")

	var home_entrance := world.get_node("HomeEntrance") as GridInteractable
	test.expect_equal(home_entrance.position, Vector2(258, 144), "The home interaction anchor sits immediately below the current farmhouse doorway")
	var starter_field := world.get_node("StarterField") as FarmPlot
	var chicken_coop := world.get_node("StarterChickenCoop") as ChickenCoop
	var cooking_counter := world.get_node("CookingCounter") as GridInteractable
	var forage_meadow := world.get_node("ForageMeadow") as ForageSpot
	var fishing_pond := world.get_node("FishingPond") as FishingSpot
	var starter_hen := world.get_node_or_null("StarterHen") as Sprite2D
	test.expect_equal(starter_field.position, Vector2(376, 328), "The farm interaction anchor sits on the authored field tiles")
	test.expect_equal(starter_field.grid_cell, Vector2i(23, 20), "The starter farm interaction reports the same TileMap cell as its saved position")
	var turnip_visual: Resource = starter_field.visual_catalog.call("get_definition", &"turnip") if starter_field.visual_catalog != null else null
	var turnip_texture := turnip_visual.get("texture") as Texture2D if turnip_visual != null else null
	test.expect_true(turnip_texture != null and turnip_texture.resource_path.contains("super_retro_world_farming"), "Farm crops use an Inspector-assigned Super Retro visual catalog")
	var soil_visuals := starter_field.soil_visual_set
	var dry_soil := soil_visuals.call("get_texture", &"dry_tilled") as AtlasTexture if soil_visuals != null else null
	var wet_soil := soil_visuals.call("get_texture", &"wet_tilled") as AtlasTexture if soil_visuals != null else null
	var dry_modulate := soil_visuals.call("get_modulate", &"dry_tilled") as Color if soil_visuals != null else Color.WHITE
	var wet_modulate := soil_visuals.call("get_modulate", &"wet_tilled") as Color if soil_visuals != null else Color.WHITE
	test.expect_true(soil_visuals != null, "Farm plots use an Inspector-assigned soil visual resource")
	test.expect_true(dry_soil != null and dry_soil.atlas != null and dry_soil.atlas.resource_path.contains("super_retro_world_farming"), "Dry tilled plots use the Super Retro farming-sim soil atlas")
	test.expect_equal(dry_soil.region if dry_soil != null else Rect2(), Rect2(176, 960, 16, 16), "Dry tilled plots use the verified Farming sim soil tile instead of a generic road tile")
	test.expect_true(wet_soil != null and wet_soil.atlas != null and not wet_soil.atlas.resource_path.contains("/Props/Water/"), "Watered farm plots use dark wet soil rather than a pond-water prop")
	test.expect_true(wet_modulate.get_luminance() < dry_modulate.get_luminance(), "Wet soil is visibly darker than dry tilled soil")
	test.expect_true(starter_field.has_method("get_visual_state_id"), "Farm plots expose a visual state seam for untouched, tilled, planted and watered states")
	test.expect_equal(fishing_pond.visual_offset, Vector2(0, 32), "The fishing marker stays inside the authored pond instead of adding a water tile above it")
	test.expect_equal(forage_meadow.position, Vector2(160, 240), "The forage interaction anchor sits in the authored grass meadow")
	test.expect_true(home_entrance.is_visual_suppressed(), "The visible farmhouse door replaces the old interaction marker art")
	test.expect_true(starter_field.is_visual_suppressed(), "The visible field tiles replace the untouched farm-plot marker")
	test.expect_true(chicken_coop.is_visual_suppressed(), "The original coop exterior replaces the old composed placeholder")
	test.expect_true(starter_hen != null and starter_hen.texture != null and starter_hen.texture.resource_path.ends_with("starter_hen.png"), "The starter coop has a visible corrected hen sprite rather than an invisible animal state")
	var hen_texture := load("res://assets/art/animals/starter_hen.png") as Texture2D
	var hen_image := hen_texture.get_image() if hen_texture != null else null
	test.expect_true(hen_image != null and hen_image.get_pixel(5, 7).a > 0.9 and hen_image.get_pixel(5, 7).get_luminance() < 0.2 and hen_image.get_pixel(10, 7).a > 0.9 and hen_image.get_pixel(10, 7).get_luminance() < 0.2, "The hen idle frame keeps two aligned and symmetric readable dark eye pixels")
	test.expect_true(world.get_node("DecorationSprites/FieldEdgeCrate") is Sprite2D, "The farm edge has an editor-authored crate decoration")
	test.expect_true(world.get_node("DecorationSprites/FieldEdgeBarrel") is Sprite2D, "The farm edge has an editor-authored barrel decoration")
	test.expect_true(world.get_node("DecorationSprites/FieldEdgePlantA") is Sprite2D and world.get_node("DecorationSprites/FieldEdgePlantB") is Sprite2D, "The farm edge has editor-authored plant decorations")
	test.expect_true(world.get_node("DecorationSprites/FieldEdgeRockA") is Sprite2D, "The farm edge has an editor-authored rock decoration")
	test.expect_true(world.get_node("DecorationSprites/CoopFeedCrate") is Sprite2D and world.get_node("DecorationSprites/CoopWaterBarrel") is Sprite2D, "The coop yard has editor-authored feed and water storage decorations")
	test.expect_true(cooking_counter != null and not cooking_counter.is_visual_suppressed(), "The formal home exposes a visible cooking station rather than an invisible cooking action")
	world._open_cooking_panel()
	test.expect_true(world.cooking_overlay.visible, "Interacting with the visible cooking station opens the formal cooking panel")
	test.expect_true((world.get_node("Interface/CookingOverlay/Panel/Title") as Label).text == "料理台", "The cooking panel has a clear menu title")
	test.expect_true(world.cooking_close_button.text == "关闭", "The cooking panel has a visible close action")
	test.expect_true(world.cooking_state_label.text.contains("当前食材"), "The formal cooking panel describes the currently selectable ingredient")
	var close_cooking_event := InputEventAction.new()
	close_cooking_event.action = &"interact"
	close_cooking_event.pressed = true
	world._handle_cooking_input(close_cooking_event)
	test.expect_true(not world.cooking_overlay.visible, "The cooking panel closes with the same interact action shown in its instructions")
	world._open_cooking_notebook()
	test.expect_true(world.cooking_notebook_overlay.visible, "The formal home can open an empty cooking notebook from exploration")
	test.expect_true((world.get_node("Interface/CookingNotebookOverlay/Panel/Title") as Label).text == "料理笔记", "The cooking notebook has a clear menu title")
	test.expect_true(world.get_node("Interface/CookingNotebookOverlay/Panel/Divider") is ColorRect, "The cooking notebook uses the shared menu divider")
	test.expect_true(world.cooking_notebook_state_label.text.contains("还没有发现过的料理"), "An empty cooking notebook explains how discoveries are created")
	test.expect_true(world.notebook_load_button.disabled, "An empty cooking notebook disables recipe loading")
	test.expect_true(world.game_clock.is_paused(), "The cooking notebook pauses home life")
	world._close_cooking_notebook()
	test.expect_true(not world.cooking_notebook_overlay.visible and not world.game_clock.is_paused(), "Closing an exploration notebook resumes home life")
	world.inventory_controller.add_item(&"turnip", 1)
	world.inventory_controller.add_item(&"pond_smelt", 1)
	world.inventory_controller.add_item(&"egg", 1)
	world.cooking_controller.notebook.record(&"pot", [&"carrot", &"turnip"], &"", &"vegetable_soup")
	world._open_cooking_panel()
	var open_notebook_event := InputEventAction.new()
	open_notebook_event.action = &"open_cooking_notebook"
	open_notebook_event.pressed = true
	world._handle_cooking_input(open_notebook_event)
	test.expect_true(world.cooking_overlay.visible and world.cooking_notebook_overlay.visible, "N opens the notebook over the formal cooking panel")
	test.expect_true(world.cooking_notebook_state_label.text.contains("个人料理笔记"), "The formal notebook displays a discovered cooking entry")
	var turnip_before_notebook_load := world.inventory_controller.inventory.count_item(&"turnip")
	var load_notebook_event := InputEventAction.new()
	load_notebook_event.action = &"interact"
	load_notebook_event.pressed = true
	world._handle_cooking_notebook_input(load_notebook_event)
	test.expect_true(not world.cooking_notebook_overlay.visible and world.cooking_overlay.visible, "Loading a notebook entry returns to the cooking panel")
	test.expect_equal(world.inventory_controller.inventory.count_item(&"turnip"), turnip_before_notebook_load, "Loading a notebook entry does not consume ingredients")
	test.expect_equal(world.cooking_controller.get_current_cookware_id(), &"pot", "Loading a notebook entry restores its cookware")
	test.expect_true(world.cooking_controller.get_state_text().contains("主食材：胡萝卜、芜菁"), "Loading a notebook entry restores its ingredient combination")
	world._handle_cooking_input(close_cooking_event)
	world._open_slot_menu(1)
	test.expect_true(world.slot_menu_overlay.visible and world.game_clock.is_paused(), "The save menu pauses home life")
	test.expect_true(world.get_node("Interface/SlotMenuOverlay/Panel/Divider") is ColorRect, "The save menu uses the shared menu divider")
	test.expect_true((world.get_node("Interface/SlotMenuOverlay/Panel/SlotMenuFooter") as Label).text.contains("Esc"), "The save menu explains its return action")
	world._close_slot_menu()
	test.expect_true(not world.slot_menu_overlay.visible and not world.game_clock.is_paused(), "Closing the save menu resumes home life")
	test.expect_equal(world.inventory_controller.item_catalog.get_item(&"wild_herb").ingredient_source, "forage", "Foraged ingredients keep their source in static item data")
	test.expect_equal(world.inventory_controller.item_catalog.get_item(&"pond_smelt").ingredient_source, "fishing", "Fish ingredients keep their source in static item data")
	world.cooking_controller.cycle_ingredient_filter()
	test.expect_equal(world.cooking_controller.get_current_ingredient_filter_id(), &"farm", "The first cooking filter is farm ingredients")
	test.expect_equal(world.cooking_controller.get_current_ingredient_id(), &"turnip", "Farm filtering hides non-farm cookable ingredients")
	test.expect_true(world.cooking_controller.get_state_text().contains("收获农田作物"), "Farm ingredients show a useful acquisition hint in the cooking panel")
	world.cooking_controller.cycle_ingredient_filter()
	world.cooking_controller.cycle_ingredient_filter()
	test.expect_equal(world.cooking_controller.get_current_ingredient_filter_id(), &"fishing", "The cooking filters can reach fishing ingredients")
	test.expect_equal(world.cooking_controller.get_current_ingredient_id(), &"pond_smelt", "Fishing filtering hides unrelated cookable ingredients")
	test.expect_true(world.cooking_controller.get_state_text().contains("每天最多钓三次"), "Fishing ingredients show their daily pond limit in the cooking panel")
	test.expect_true(forage_meadow != null and fishing_pond != null, "The formal home includes one forage point and one pond fishing point")
	test.expect_true(not forage_meadow.is_visual_suppressed() and forage_meadow.visual_texture != null, "The forage point has a visible Super Retro marker instead of becoming an invisible interaction")
	test.expect_true(not fishing_pond.is_visual_suppressed() and fishing_pond.visual_texture != null, "The fishing point has a visible shore marker instead of becoming an invisible interaction")
	test.expect_true(str(cooking_counter.visual_texture.resource_path).contains("super_retro_world_farming"), "The cooking point uses the Super Retro prop catalog")
	test.expect_true(str(forage_meadow.visual_texture.resource_path).contains("super_retro_world_farming"), "The forage point uses the Super Retro prop catalog")
	test.expect_true(str(fishing_pond.visual_texture.resource_path).contains("super_retro_world_farming"), "The fishing point uses the Super Retro prop catalog")
	var forage_message := world._collect_forage(forage_meadow)
	test.expect_true(forage_message.begins_with("采集到"), "Forage adds a weather-table food ingredient to the inventory")
	test.expect_true(not forage_meadow.is_available(world.game_clock.session.get_day()), "Forage is exhausted for the rest of its collection day")
	var fishing_message := world._fish_at_spot(fishing_pond)
	test.expect_true(fishing_message.begins_with("钓到"), "Fishing adds a weather-table food ingredient to the inventory")
	test.expect_equal(fishing_pond.get_remaining_catches(world.game_clock.session.get_day()), 2, "The pond reduces its three-catch daily limit after a successful catch")
	var food_snapshot := world.capture_interaction_state()
	test.expect_true(food_snapshot.has("forage_spots") and food_snapshot.has("fishing_spots"), "Food-source collection state is included in home-region saves")

	var exposes_life_seam := world.has_method("get_life_state") and world.has_method("sleep_at_home")
	test.expect_true(exposes_life_seam, "HomeRegion exposes a small life-loop seam for resting and HUD state")
	if exposes_life_seam:
		var before_sleep: Dictionary = world.call("get_life_state")
		world.call("sleep_at_home")
		var after_sleep: Dictionary = world.call("get_life_state")
		test.expect_equal(int(after_sleep.get("day", 0)), int(before_sleep.get("day", 0)) + 1, "Resting at home advances exactly one normal-world day")
		test.expect_equal(int(after_sleep.get("stamina", 0)), int(after_sleep.get("maximum_stamina", 0)), "Resting at home restores full stamina")

	var exposes_save_adapter := world.has_method("get_current_area_id") and world.has_method("capture_interaction_state") and world.has_method("restore_area_and_player_position")
	test.expect_true(exposes_save_adapter, "HomeRegion exposes the save adapter seam without leaking map implementation details")

	var exposes_chicken_care := world.has_method("care_for_chicken_coop")
	test.expect_true(exposes_chicken_care, "HomeRegion exposes a focused chicken-care action instead of leaving the coop as display-only")
	if exposes_chicken_care:
		var feed_before := world.inventory_controller.inventory.count_item(&"chicken_feed")
		var first_care: Dictionary = world.call("care_for_chicken_coop", chicken_coop)
		test.expect_true(bool(first_care.get("success", false)), "The first coop interaction feeds the chicken when feed is available")
		test.expect_equal(world.inventory_controller.inventory.count_item(&"chicken_feed"), feed_before - 1, "Feeding consumes exactly one chicken feed")
		var second_care: Dictionary = world.call("care_for_chicken_coop", chicken_coop)
		test.expect_true(bool(second_care.get("success", false)), "The second coop interaction pets the already-fed chicken")
		test.expect_true(chicken_coop.is_petted_today(world.game_clock.session.get_day()), "The coop records daily petting after the second interaction")

	world.free()
