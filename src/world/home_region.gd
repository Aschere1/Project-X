class_name HomeRegion
extends Node2D

const MAP_SIZE := Vector2i(60, 34)
const TILE_SIZE := Vector2i(16, 16)
const WORLD_SIZE := Vector2i(MAP_SIZE.x * TILE_SIZE.x, MAP_SIZE.y * TILE_SIZE.y)
const INTERACTION_RANGE := 32.0
const TERRAIN_TEXTURE: Texture2D = preload("res://assets/art/tilesets/home_terrain.png")
const PUNY_WORLD_TEXTURE: Texture2D = preload("res://assets/third_party/puny_world/puny_world_overworld_tileset.png")
const SPRING_CROP_CATALOG = preload("res://content/catalogs/spring_crop_catalog.tres")
const DEVELOPMENT_ART_ROOT := "res://assets/private/super_retro_world_farming"
const DEVELOPMENT_TILESET_PATH := DEVELOPMENT_ART_ROOT + "/Tilesets/Super_Retro_Tilesets.tres"
const DEVELOPMENT_FARMHOUSE_PATH := DEVELOPMENT_ART_ROOT + "/Props/Houses/Sprites/house_02.png"
const DEVELOPMENT_TREE_PATH := DEVELOPMENT_ART_ROOT + "/Props/Trees/Sprites/tree_01.png"
const MESSAGE_DURATION_SECONDS := 3.2
const SETTINGS_PAUSE_SOURCE := &"settings_panel"

const TILE_GRASS := Vector2i(0, 0)
const TILE_GRASS_VARIANT := Vector2i(1, 0)
const TILE_PATH := Vector2i(2, 0)
const TILE_SOIL := Vector2i(3, 0)
const TILE_WATER := Vector2i(4, 0)
const TILE_SHORE := Vector2i(5, 0)
const TILE_FENCE_HORIZONTAL := Vector2i(6, 0)
const TILE_FENCE_VERTICAL := Vector2i(7, 0)
const TILE_FLOWERS := Vector2i(0, 1)
const TILE_STONE := Vector2i(1, 1)
const TILE_GATE := Vector2i(2, 1)
const TILE_DARK_SOIL := Vector2i(3, 1)
const TILE_PATH_EDGE := Vector2i(4, 1)
const TILE_GRASS_TUFT := Vector2i(5, 1)
const TILE_BUSH := Vector2i(6, 1)
const TILE_SHRUB := Vector2i(7, 1)
const TILE_WATER_DEEP := Vector2i(0, 2)
const TILE_WATER_WAVE := Vector2i(1, 2)
const TILE_WATER_RIPPLE := Vector2i(2, 2)
const TILE_WATER_GLINT := Vector2i(3, 2)
const OCCLUDER_FADED_ALPHA := 0.48
const OCCLUDER_VISIBLE_ALPHA := 1.0
const MANUAL_SLOT_NAMES: Array[String] = ["slot_1", "slot_2", "slot_3"]

enum SlotMenuMode {
	NONE,
	SAVE,
	LOAD_SELECT,
	LOAD_CONFIRM,
}

@onready var ground_layer: TileMapLayer = $Ground
@onready var terrain_layer: TileMapLayer = $Terrain
@onready var objects_layer: TileMapLayer = $Objects
@onready var foreground_layer: TileMapLayer = $Foreground
@onready var player: PlayerController = $Player
@onready var interaction_indicator: Node2D = $InteractionIndicator
@onready var status_label: Label = %StatusLabel
@onready var message_panel: Control = %MessagePanel
@onready var message_timer: Timer = %MessageTimer
@onready var day_label: Label = %DayLabel
@onready var weather_label: Label = %WeatherLabel
@onready var clock_label: Label = %ClockLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var game_clock: GameClockController = $GameClock
@onready var inventory_controller: InventoryController = $InventoryController
@onready var cooking_controller: CookingController = $CookingController
@onready var save_coordinator: SaveCoordinator = $SaveCoordinator
@onready var inventory_overlay: Control = %InventoryOverlay
@onready var inventory_contents_label: Label = %InventoryContentsLabel
@onready var inventory_close_button: Button = %InventoryCloseButton
@onready var cooking_overlay: Control = %CookingOverlay
@onready var cooking_state_label: Label = %CookingStateLabel
@onready var cooking_close_button: Button = %CookingCloseButton
@onready var cooking_notebook_overlay: Control = %CookingNotebookOverlay
@onready var cooking_notebook_state_label: Label = %CookingNotebookStateLabel
@onready var notebook_previous_button: Button = %NotebookPreviousButton
@onready var notebook_next_button: Button = %NotebookNextButton
@onready var notebook_load_button: Button = %NotebookLoadButton
@onready var notebook_close_button: Button = %NotebookCloseButton
@onready var slot_menu_overlay: Control = %SlotMenuOverlay
@onready var slot_menu_title: Label = %SlotMenuTitle
@onready var slot_menu_detail: Label = %SlotMenuDetail
@onready var slot_1_button: Button = %Slot1Button
@onready var slot_2_button: Button = %Slot2Button
@onready var slot_3_button: Button = %Slot3Button
@onready var slot_confirm_button: Button = %SlotConfirmButton
@onready var slot_cancel_button: Button = %SlotCancelButton
@onready var settings_overlay: Control = %SettingsOverlay
@onready var settings_close_button: Button = %SettingsCloseButton

var _atlas_source_id := -1
var _water_atlas_source_id := -1
var _interactables: Array[GridInteractable] = []
var _selected_target: GridInteractable
var _last_processed_world_day := 1
var _slot_menu_mode := SlotMenuMode.NONE
var _selected_slot_name := ""
var _is_cooking_open := false
var _is_cooking_notebook_open := false
var _notebook_entry_index := 0
var _is_settings_open := false
var _visual_baseline_id := &"original_fallback"
var _uses_development_tileset := false

func _ready() -> void:
	_apply_development_visual_baseline()
	if not _use_scene_authored_tile_map():
		_build_fallback_tile_layers()
	_configure_interactables()
	player.interaction_requested.connect(_on_player_interaction_requested)
	player.tool_requested.connect(_on_player_tool_requested)
	game_clock.clock_updated.connect(_on_clock_updated)
	game_clock.calendar_updated.connect(_on_calendar_updated)
	game_clock.pause_changed.connect(_on_pause_changed)
	inventory_controller.inventory_changed.connect(_on_inventory_changed)
	inventory_controller.panel_visibility_changed.connect(_on_inventory_panel_visibility_changed)
	cooking_controller.cooking_state_changed.connect(_refresh_cooking_overlay)
	cooking_controller.cooked.connect(_on_cooked)
	save_coordinator.save_message.connect(_on_save_message)
	slot_1_button.pressed.connect(_on_slot_button_pressed.bind("slot_1"))
	slot_2_button.pressed.connect(_on_slot_button_pressed.bind("slot_2"))
	slot_3_button.pressed.connect(_on_slot_button_pressed.bind("slot_3"))
	slot_confirm_button.pressed.connect(_on_slot_confirm_pressed)
	slot_cancel_button.pressed.connect(_close_slot_menu)
	settings_close_button.pressed.connect(_close_settings)
	inventory_close_button.pressed.connect(_close_inventory_panel)
	cooking_close_button.pressed.connect(_close_cooking_panel)
	notebook_previous_button.pressed.connect(_move_notebook_entry.bind(-1))
	notebook_next_button.pressed.connect(_move_notebook_entry.bind(1))
	notebook_load_button.pressed.connect(_load_selected_notebook_entry)
	notebook_close_button.pressed.connect(_close_cooking_notebook)
	message_timer.timeout.connect(_on_message_timeout)
	_last_processed_world_day = game_clock.session.get_day()
	game_clock.emit_clock_state()
	_on_inventory_changed()
	_refresh_interaction_selection()
	message_panel.visible = false
	status_label.text = ""
	print("HOME_REGION_READY size=%sx%s interactables=%d" % [WORLD_SIZE.x, WORLD_SIZE.y, _interactables.size()])

func _process(_delta: float) -> void:
	_refresh_interaction_selection()
	_update_visual_occlusion()

func _unhandled_input(event: InputEvent) -> void:
	if _is_cooking_notebook_open:
		_handle_cooking_notebook_input(event)
		return
	if _is_cooking_open:
		_handle_cooking_input(event)
		return
	if _is_settings_open:
		if event.is_action_pressed(&"pause"):
			_close_settings()
			get_viewport().set_input_as_handled()
		return
	if _slot_menu_mode != SlotMenuMode.NONE:
		if event.is_action_pressed(&"pause"):
			_close_slot_menu()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pause"):
		if inventory_overlay.visible:
			inventory_controller.set_panel_open(false)
		else:
			_open_settings()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"save_game"):
		_open_slot_menu(SlotMenuMode.SAVE)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"load_game"):
		_open_slot_menu(SlotMenuMode.LOAD_SELECT)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"open_cooking_notebook"):
		_open_cooking_notebook()
		get_viewport().set_input_as_handled()

func get_map_size() -> Vector2i:
	return MAP_SIZE

func get_world_size() -> Vector2i:
	return WORLD_SIZE

func get_interactable_count() -> int:
	return _interactables.size()

func get_life_state() -> Dictionary:
	return {
		"day": game_clock.session.get_day(),
		"clock_text": game_clock.session.get_clock_text(),
		"stamina": game_clock.session.get_stamina(),
		"maximum_stamina": game_clock.rules.maximum_stamina,
		"weather_id": String(game_clock.session.get_weather_id()),
	}

func sleep_at_home() -> void:
	game_clock.session.sleep()
	game_clock.reset_time_accumulator()
	game_clock.emit_clock_state()
	_show_message("休息到次日清晨，体力已经恢复。")

func get_current_area_id() -> StringName:
	return &"home_region"

func get_visual_baseline_id() -> StringName:
	return _visual_baseline_id

func uses_super_retro_tile_set() -> bool:
	return _uses_development_tileset

func _apply_development_visual_baseline() -> void:
	if not ResourceLoader.exists(DEVELOPMENT_FARMHOUSE_PATH) or not ResourceLoader.exists(DEVELOPMENT_TREE_PATH):
		_visual_baseline_id = &"original_fallback"
		return
	var farmhouse_texture := load(DEVELOPMENT_FARMHOUSE_PATH) as Texture2D
	var tree_texture := load(DEVELOPMENT_TREE_PATH) as Texture2D
	if farmhouse_texture == null or tree_texture == null:
		_visual_baseline_id = &"original_fallback"
		return
	_visual_baseline_id = &"super_retro_world"
	$Farmhouse.texture = farmhouse_texture
	$Farmhouse.region_enabled = false
	$Farmhouse.scale = Vector2(2.0, 2.0)
	for tree_name in [&"TreeA", &"TreeB", &"TreeC"]:
		var tree_sprite := get_node(NodePath(tree_name)) as Sprite2D
		tree_sprite.texture = tree_texture
		tree_sprite.region_enabled = false
		tree_sprite.scale = Vector2(1.5, 1.5)

func restore_area_and_player_position(area_id: StringName, position: Vector2) -> bool:
	if area_id != get_current_area_id():
		return false
	player.global_position = position.clamp(
		player.movement_bounds.position,
		player.movement_bounds.position + player.movement_bounds.size,
	)
	_refresh_interaction_selection()
	return true

func capture_interaction_state() -> Dictionary:
	var farm_plot_states: Dictionary = {}
	var chicken_coop_states: Dictionary = {}
	var forage_spot_states: Dictionary = {}
	var fishing_spot_states: Dictionary = {}
	for interactable in _interactables:
		var farm_plot := interactable as FarmPlot
		if farm_plot != null:
			farm_plot_states[String(farm_plot.interaction_id)] = farm_plot.to_snapshot()
			continue
		var chicken_coop := interactable as ChickenCoop
		if chicken_coop != null:
			chicken_coop_states[String(chicken_coop.interaction_id)] = chicken_coop.to_snapshot()
			continue
		var forage_spot := interactable as ForageSpot
		if forage_spot != null:
			forage_spot_states[String(forage_spot.interaction_id)] = forage_spot.to_snapshot()
			continue
		var fishing_spot := interactable as FishingSpot
		if fishing_spot != null:
			fishing_spot_states[String(fishing_spot.interaction_id)] = fishing_spot.to_snapshot()
	return {"farm_plots": farm_plot_states, "chicken_coops": chicken_coop_states, "forage_spots": forage_spot_states, "fishing_spots": fishing_spot_states}

func restore_interaction_state(snapshot: Dictionary) -> bool:
	var farm_plot_values: Variant = snapshot.get("farm_plots", {})
	var chicken_coop_values: Variant = snapshot.get("chicken_coops", {})
	var forage_spot_values: Variant = snapshot.get("forage_spots", {})
	var fishing_spot_values: Variant = snapshot.get("fishing_spots", {})
	if not farm_plot_values is Dictionary or not chicken_coop_values is Dictionary or not forage_spot_values is Dictionary or not fishing_spot_values is Dictionary:
		return false
	for interactable in _interactables:
		var farm_plot := interactable as FarmPlot
		if farm_plot != null:
			var farm_snapshot: Variant = farm_plot_values.get(String(farm_plot.interaction_id), {"version": 1, "is_tilled": false})
			if not farm_snapshot is Dictionary or not farm_plot.restore_snapshot(farm_snapshot):
				return false
			continue
		var chicken_coop := interactable as ChickenCoop
		if chicken_coop != null:
			var coop_snapshot: Variant = chicken_coop_values.get(String(chicken_coop.interaction_id), {"version": 1, "tracked_day": game_clock.session.get_day(), "fed_today": false, "petted_today": false, "care_streak": 0, "pending_egg_qualities": []})
			if not coop_snapshot is Dictionary or not chicken_coop.restore_snapshot(coop_snapshot):
				return false
			continue
		var forage_spot := interactable as ForageSpot
		if forage_spot != null:
			var forage_snapshot: Variant = forage_spot_values.get(String(forage_spot.interaction_id), {"version": 1, "last_collected_day": 0})
			if not forage_snapshot is Dictionary or not forage_spot.restore_snapshot(forage_snapshot):
				return false
			continue
		var fishing_spot := interactable as FishingSpot
		if fishing_spot != null:
			var fishing_snapshot: Variant = fishing_spot_values.get(String(fishing_spot.interaction_id), {"version": 1, "tracked_day": game_clock.session.get_day(), "catches_today": 0})
			if not fishing_snapshot is Dictionary or not fishing_spot.restore_snapshot(fishing_snapshot):
				return false
	return true

func _use_scene_authored_tile_map() -> bool:
	if ground_layer.tile_set == null or ground_layer.get_used_cells().is_empty():
		return false
	_uses_development_tileset = ground_layer.tile_set.resource_path == DEVELOPMENT_TILESET_PATH
	return true

func _build_fallback_tile_layers() -> void:
	_uses_development_tileset = false
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	var atlas := TileSetAtlasSource.new()
	atlas.texture = TERRAIN_TEXTURE
	atlas.texture_region_size = TILE_SIZE
	for row in 3:
		for column in 8:
			atlas.create_tile(Vector2i(column, row))
	_atlas_source_id = tile_set.add_source(atlas)
	var water_atlas := TileSetAtlasSource.new()
	water_atlas.texture = PUNY_WORLD_TEXTURE
	water_atlas.texture_region_size = TILE_SIZE
	water_atlas.create_tile(Vector2i(8, 11))
	_water_atlas_source_id = tile_set.add_source(water_atlas)
	for layer in [ground_layer, terrain_layer, objects_layer, foreground_layer]:
		layer.tile_set = tile_set

	for y in MAP_SIZE.y:
		for x in MAP_SIZE.x:
			var grass_tile := TILE_GRASS_VARIANT if (x * 3 + y * 5) % 17 == 0 else TILE_GRASS
			_set_tile(ground_layer, Vector2i(x, y), grass_tile)

	# Main paths connect the home, field, coop and southern exit.
	for y in range(9, MAP_SIZE.y):
		_set_tile(terrain_layer, Vector2i(15, y), TILE_PATH)
		_set_tile(terrain_layer, Vector2i(16, y), TILE_PATH)
	for x in range(15, 46):
		_set_tile(terrain_layer, Vector2i(x, 17), TILE_PATH)
		_set_tile(terrain_layer, Vector2i(x, 18), TILE_PATH)
	for x in range(15, 31):
		_set_tile(terrain_layer, Vector2i(x, 10), TILE_PATH)
		_set_tile(terrain_layer, Vector2i(x, 11), TILE_PATH)
	for y in range(7, 18):
		_set_tile(terrain_layer, Vector2i(44, y), TILE_PATH)
		_set_tile(terrain_layer, Vector2i(45, y), TILE_PATH)

	# A finite 20x12 field. The player must trade land for future buildings.
	for y in range(20, 31):
		for x in range(23, 43):
			_set_tile(terrain_layer, Vector2i(x, y), TILE_DARK_SOIL if (x + y) % 2 == 0 else TILE_SOIL)
	for x in range(22, 44):
		_set_tile(objects_layer, Vector2i(x, 19), TILE_FENCE_HORIZONTAL)
		_set_tile(objects_layer, Vector2i(x, 31), TILE_FENCE_HORIZONTAL)
	for y in range(20, 31):
		_set_tile(objects_layer, Vector2i(22, y), TILE_FENCE_VERTICAL)
		_set_tile(objects_layer, Vector2i(43, y), TILE_FENCE_VERTICAL)
	_set_tile(objects_layer, Vector2i(31, 19), TILE_GATE)
	_set_tile(objects_layer, Vector2i(32, 19), TILE_GATE)

	# Pond and soft shore transition.
	for y in range(21, 30):
		for x in range(3, 11):
			_set_modular_water_tile(Vector2i(x, y))
	for x in range(2, 12):
		_set_tile(terrain_layer, Vector2i(x, 20), TILE_SHORE)
		_set_tile(terrain_layer, Vector2i(x, 30), TILE_SHORE)

	for cell in [Vector2i(4, 7), Vector2i(8, 9), Vector2i(19, 7), Vector2i(35, 8), Vector2i(51, 11), Vector2i(55, 24), Vector2i(14, 27)]:
		_set_tile(objects_layer, cell, TILE_FLOWERS)
	for cell in [Vector2i(2, 12), Vector2i(12, 14), Vector2i(48, 19), Vector2i(55, 8)]:
		_set_tile(objects_layer, cell, TILE_STONE)
	for cell in [Vector2i(5, 16), Vector2i(12, 8), Vector2i(49, 27), Vector2i(55, 16)]:
		_set_tile(objects_layer, cell, TILE_GRASS_TUFT)
	for cell in [Vector2i(1, 7), Vector2i(57, 7), Vector2i(1, 31), Vector2i(57, 31)]:
		_set_tile(foreground_layer, cell, TILE_SHRUB)

func _set_tile(layer: TileMapLayer, cell: Vector2i, atlas_coordinate: Vector2i) -> void:
	layer.set_cell(cell, _atlas_source_id, atlas_coordinate)

func _set_modular_water_tile(cell: Vector2i) -> void:
	# (8, 11) is the pond screenshot's upper-left edge-free, decoration-free cell.
	# Shoreline
	# and future ripples are separate, so no partial lily or bank can repeat.
	terrain_layer.set_cell(cell, _water_atlas_source_id, Vector2i(8, 11))

func _get_water_tile(x: int, y: int) -> Vector2i:
	var water_tiles := [TILE_WATER_DEEP, TILE_WATER_WAVE, TILE_WATER_RIPPLE, TILE_WATER_GLINT]
	return water_tiles[(x * 7 + y * 3) % water_tiles.size()]

func _configure_interactables() -> void:
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		var interactable := node as GridInteractable
		if interactable == null or not is_ancestor_of(interactable):
			continue
		var farm_plot := interactable as FarmPlot
		if farm_plot != null:
			farm_plot.set_hide_untouched_visual(true)
		var keeps_source_visual := interactable is ForageSpot or interactable is FishingSpot or interactable.visual_texture != null
		interactable.set_visual_suppressed(not keeps_source_visual)
		interactable.set_uses_map_collision_proxy(true)
		interactable.interacted.connect(_on_interactable_interacted)
		_interactables.append(interactable)

func _on_player_interaction_requested(_facing_direction: Vector2) -> void:
	var target := _get_nearby_target()
	if target != null:
		target.interact()

func _on_player_tool_requested(_facing_direction: Vector2) -> void:
	var farm_plot := _get_nearby_target() as FarmPlot
	if farm_plot == null:
		return
	if not farm_plot.is_tilled():
		_perform_farm_action(farm_plot.use_tool(FarmPlot.HOE_TOOL_ID), 5, 10)
		return
	if not farm_plot.has_crop():
		var seed_item_id := inventory_controller.get_selected_seed_item_id()
		var crop: Variant = SPRING_CROP_CATALOG.get_crop_by_seed_item_id(seed_item_id)
		if seed_item_id == &"" or crop == null or inventory_controller.inventory.count_item(seed_item_id) < 1:
			_show_message("背包里没有当前可播种的种子。按 R 切换种子。")
			return
		var plant_result := farm_plot.plant(crop)
		if plant_result.get("success", false):
			inventory_controller.remove_item(seed_item_id, 1)
		_perform_farm_action(plant_result, 2, 5)
		return
	if farm_plot.needs_water():
		_perform_farm_action(farm_plot.water(), 2, 5)
		return
	if farm_plot.is_ready_to_harvest():
		var harvest_item_id := farm_plot.get_harvest_item_id()
		var harvest_amount := farm_plot.get_harvest_amount()
		if not inventory_controller.can_add_item(harvest_item_id, harvest_amount):
			_show_message("背包没有空间，无法收获。")
			return
		var harvest_result := farm_plot.harvest()
		if harvest_result.get("success", false):
			inventory_controller.add_item(harvest_item_id, harvest_amount)
		_perform_farm_action(harvest_result, 2, 10)
		return
	_show_message("作物正在等待明天生长。")

func _on_interactable_interacted(interaction_id: StringName, result_text: String) -> void:
	var forage_spot := _selected_target as ForageSpot
	if forage_spot != null:
		_show_message(_collect_forage(forage_spot))
		return
	var fishing_spot := _selected_target as FishingSpot
	if fishing_spot != null:
		_show_message(_fish_at_spot(fishing_spot))
		return
	match interaction_id:
		&"home_entrance":
			sleep_at_home()
		&"cooking_counter":
			_open_cooking_panel()
		&"starter_field":
			_show_message("农田：F 翻土、播种、浇水或收获；R 切换种子。")
		&"starter_chicken_coop":
			var chicken_coop := _selected_target as ChickenCoop
			if chicken_coop != null:
				var care_result := care_for_chicken_coop(chicken_coop)
				_show_message(str(care_result.get("message", result_text)))
			else:
				_show_message(result_text)
		_:
			_show_message(result_text)

func _collect_forage(forage_spot: ForageSpot) -> String:
	var day := game_clock.session.get_day()
	if not forage_spot.is_available(day):
		return "这里今天已经采集过了，明天再来看看。"
	if game_clock.session.get_stamina() < 1:
		return "体力不足，先回家休息。"
	var reward := forage_spot.preview_reward(day, game_clock.session.get_weather_id(), game_clock.session.get_world_seed())
	if reward.is_empty():
		return "这里今天没有可采集的食材。"
	var item_id := StringName(reward["item_id"])
	var quantity := int(reward["quantity"])
	var quality := int(reward["quality"])
	if not inventory_controller.can_add_item(item_id, quantity, quality):
		return "背包没有空间，采集物仍留在原处。"
	forage_spot.mark_collected(day)
	inventory_controller.add_item(item_id, quantity, quality)
	_consume_life_action(1, 10)
	return "采集到%s%s x%d。" % [inventory_controller.get_quality_suffix(quality), inventory_controller.item_catalog.get_item(item_id).display_name, quantity]

func _fish_at_spot(fishing_spot: FishingSpot) -> String:
	var day := game_clock.session.get_day()
	if fishing_spot.get_remaining_catches(day) <= 0:
		return "今天已经带走三条鱼，让池塘休息到明天吧。"
	if game_clock.session.get_stamina() < 3:
		return "体力不足，先回家休息。"
	var reward := fishing_spot.preview_reward(day, game_clock.session.get_weather_id(), game_clock.session.get_world_seed())
	if reward.is_empty():
		return "这次没有鱼靠近钓点。"
	var item_id := StringName(reward["item_id"])
	var quantity := int(reward["quantity"])
	var quality := int(reward["quality"])
	if not inventory_controller.can_add_item(item_id, quantity, quality):
		return "背包没有空间，暂时不抛竿。"
	fishing_spot.record_catch(day)
	inventory_controller.add_item(item_id, quantity, quality)
	_consume_life_action(3, 20)
	fishing_spot.refresh_for_day(game_clock.session.get_day())
	return "钓到%s%s；今天还可带走 %d 条。" % [inventory_controller.get_quality_suffix(quality), inventory_controller.item_catalog.get_item(item_id).display_name, fishing_spot.get_remaining_catches(game_clock.session.get_day())]

func care_for_chicken_coop(chicken_coop: ChickenCoop) -> Dictionary:
	var day := game_clock.session.get_day()
	chicken_coop.advance_to_day(day)
	if chicken_coop.has_pending_egg():
		var egg_item_id := chicken_coop.chicken.product_item_id
		var egg_quality := chicken_coop.peek_next_egg_quality()
		if not inventory_controller.can_add_item(egg_item_id, 1, egg_quality):
			return {"success": false, "message": "背包没有空间，鸡蛋仍安全留在鸡舍。"}
		chicken_coop.take_next_egg_quality()
		inventory_controller.add_item(egg_item_id, 1, egg_quality)
		_consume_life_action(0, 5)
		return {
			"success": true,
			"message": "收取%s鸡蛋；鸡舍还有 %d 枚待收。" % [inventory_controller.get_quality_suffix(egg_quality), chicken_coop.get_pending_egg_count()],
		}
	if not chicken_coop.is_fed_today(day):
		if inventory_controller.inventory.count_item(&"chicken_feed") < 1:
			return {"success": false, "message": "没有鸡饲料。%s不会生病，但明天不会产蛋。" % chicken_coop.chicken.display_name}
		if game_clock.session.get_stamina() < 1:
			return {"success": false, "message": "体力不足，先回家休息。"}
		inventory_controller.remove_item(&"chicken_feed", 1)
		chicken_coop.feed(day)
		_consume_life_action(1, 5)
		return {"success": true, "message": "已经给%s喂食；再互动一次可以抚摸。" % chicken_coop.chicken.display_name}
	if not chicken_coop.is_petted_today(day):
		chicken_coop.pet(day)
		_consume_life_action(0, 5)
		return {"success": true, "message": "轻轻抚摸了%s；连续细心照料会提高鸡蛋品质。" % chicken_coop.chicken.display_name}
	return {"success": false, "message": chicken_coop.get_status_text(day, game_clock.session.get_weather_id())}

func _perform_farm_action(result: Dictionary, stamina_cost: int, elapsed_minutes: int) -> void:
	if not result.get("success", false):
		_show_message(str(result.get("message", "农田行动没有产生效果。")))
		return
	if game_clock.session.get_stamina() < stamina_cost:
		_show_message("体力不足，先回家休息。")
		return
	game_clock.session.consume_stamina(stamina_cost)
	game_clock.session.advance_minutes(elapsed_minutes)
	game_clock.emit_clock_state()
	_show_message(str(result.get("message", "农田行动完成。")))

func _consume_life_action(stamina_cost: int, elapsed_minutes: int) -> void:
	if stamina_cost > 0:
		game_clock.session.consume_stamina(stamina_cost)
	game_clock.session.advance_minutes(elapsed_minutes)
	game_clock.emit_clock_state()

func _on_clock_updated(day: int, clock_text: String, stamina: int, maximum_stamina: int) -> void:
	_advance_world_to_day(day)
	clock_label.text = clock_text
	stamina_label.text = "体力 %d/%d" % [stamina, maximum_stamina]

func _on_calendar_updated(season_name: String, season_day: int, weather_text: String, forecast_text: String) -> void:
	day_label.text = "%s %d日" % [season_name, season_day]
	var weather_effect := " · 农田自动浇水" if game_clock.session.get_weather_id() == GameRules.WEATHER_RAIN else ""
	weather_label.text = "%s%s · 明日%s" % [weather_text, weather_effect, forecast_text]

func _advance_world_to_day(current_day: int) -> void:
	if current_day <= _last_processed_world_day:
		_last_processed_world_day = current_day
		_refresh_daily_world_state(current_day)
		return
	for elapsed_day in range(_last_processed_world_day, current_day):
		var elapsed_weather := game_clock.rules.get_weather_for_day(elapsed_day, game_clock.session.get_world_seed())
		for interactable in _interactables:
			var farm_plot := interactable as FarmPlot
			if farm_plot != null:
				farm_plot.apply_weather(elapsed_weather)
				farm_plot.advance_day()
				continue
			var chicken_coop := interactable as ChickenCoop
			if chicken_coop != null:
				chicken_coop.advance_to_day(elapsed_day + 1)
	_last_processed_world_day = current_day
	_refresh_daily_world_state(current_day)

func _refresh_daily_world_state(current_day: int) -> void:
	for interactable in _interactables:
		var chicken_coop := interactable as ChickenCoop
		if chicken_coop != null:
			chicken_coop.refresh_for_day(current_day)
			continue
		var forage_spot := interactable as ForageSpot
		if forage_spot != null:
			forage_spot.refresh_for_day(current_day)
			continue
		var fishing_spot := interactable as FishingSpot
		if fishing_spot != null:
			fishing_spot.refresh_for_day(current_day)

func _on_pause_changed(is_paused: bool) -> void:
	player.set_input_enabled(not is_paused)

func _open_settings() -> void:
	_is_settings_open = true
	settings_overlay.visible = true
	message_panel.visible = false
	message_timer.stop()
	game_clock.set_pause_requested(SETTINGS_PAUSE_SOURCE, true)

func _close_settings() -> void:
	_is_settings_open = false
	settings_overlay.visible = false
	game_clock.set_pause_requested(SETTINGS_PAUSE_SOURCE, false)

func _show_message(message: String) -> void:
	status_label.text = message
	message_panel.visible = not message.is_empty()
	if message.is_empty():
		message_timer.stop()
		return
	message_timer.start(MESSAGE_DURATION_SECONDS)

func _on_message_timeout() -> void:
	message_panel.visible = false
	status_label.text = ""
	_refresh_interaction_selection()

func _on_inventory_changed() -> void:
	inventory_contents_label.text = inventory_controller.get_inventory_text()

func _on_inventory_panel_visibility_changed(is_visible: bool) -> void:
	inventory_overlay.visible = is_visible
	game_clock.set_pause_requested(&"inventory_panel", is_visible)

func _close_inventory_panel() -> void:
	inventory_controller.set_panel_open(false)

func _on_save_message(message: String) -> void:
	_show_message(message)

func _open_cooking_panel() -> void:
	_is_cooking_open = true
	cooking_overlay.visible = true
	game_clock.set_pause_requested(&"cooking_panel", true)
	_refresh_cooking_overlay()

func _close_cooking_panel() -> void:
	_is_cooking_open = false
	cooking_overlay.visible = false
	game_clock.set_pause_requested(&"cooking_panel", false)

func _handle_cooking_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_cooking_notebook"):
		_open_cooking_notebook()
	elif event.is_action_pressed(&"interact") or event.is_action_pressed(&"pause"):
		_close_cooking_panel()
	elif event.is_action_pressed(&"cycle_cookware"):
		cooking_controller.cycle_cookware()
	elif event.is_action_pressed(&"cycle_ingredient"):
		cooking_controller.cycle_ingredient()
	elif event.is_action_pressed(&"cycle_ingredient_filter"):
		cooking_controller.cycle_ingredient_filter()
	elif event.is_action_pressed(&"add_ingredient"):
		cooking_controller.add_current_ingredient()
	elif event.is_action_pressed(&"set_seasoning"):
		cooking_controller.set_current_seasoning()
	elif event.is_action_pressed(&"cook"):
		cooking_controller.cook()
	elif event.is_action_pressed(&"clear_cooking"):
		cooking_controller.clear_selection()
	else:
		return
	get_viewport().set_input_as_handled()

func _handle_cooking_notebook_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_cooking_notebook") or event.is_action_pressed(&"pause"):
		_close_cooking_notebook()
	elif event.is_action_pressed(&"move_up"):
		_move_notebook_entry(-1)
	elif event.is_action_pressed(&"move_down"):
		_move_notebook_entry(1)
	elif event.is_action_pressed(&"interact"):
		_load_selected_notebook_entry()
	else:
		return
	get_viewport().set_input_as_handled()

func _open_cooking_notebook() -> void:
	_is_cooking_notebook_open = true
	cooking_notebook_overlay.visible = true
	game_clock.set_pause_requested(&"cooking_notebook", true)
	_refresh_cooking_notebook_overlay()

func _close_cooking_notebook() -> void:
	_is_cooking_notebook_open = false
	cooking_notebook_overlay.visible = false
	game_clock.set_pause_requested(&"cooking_notebook", false)
	_refresh_cooking_overlay()

func _move_notebook_entry(direction: int) -> void:
	var entry_count := cooking_controller.notebook.get_entry_count()
	if entry_count > 0:
		_notebook_entry_index = posmod(_notebook_entry_index + direction, entry_count)
	_refresh_cooking_notebook_overlay()

func _load_selected_notebook_entry() -> void:
	if not cooking_controller.load_notebook_entry(_notebook_entry_index):
		_show_message("这条料理笔记无法装填。")
		_refresh_cooking_notebook_overlay()
		return
	_show_message("已按料理笔记装填组合，不会消耗食材。")
	_close_cooking_notebook()

func _refresh_cooking_notebook_overlay() -> void:
	if not _is_cooking_notebook_open:
		return
	var entry_count := cooking_controller.notebook.get_entry_count()
	if entry_count > 0:
		_notebook_entry_index %= entry_count
	else:
		_notebook_entry_index = 0
	cooking_notebook_state_label.text = cooking_controller.get_notebook_entry_text(_notebook_entry_index)
	notebook_load_button.disabled = entry_count == 0

func _refresh_cooking_overlay() -> void:
	if _is_cooking_open:
		cooking_state_label.text = cooking_controller.get_state_text()

func _on_cooked(message: String) -> void:
	_show_message(message)
	_refresh_cooking_overlay()

func _open_slot_menu(mode: SlotMenuMode) -> void:
	_slot_menu_mode = mode
	_selected_slot_name = ""
	slot_menu_overlay.visible = true
	slot_confirm_button.visible = false
	game_clock.set_pause_requested(&"slot_menu", true)
	if mode == SlotMenuMode.SAVE:
		slot_menu_title.text = "选择手动存档格"
		slot_menu_detail.text = "请选择 3 个独立格之一。覆盖前会保留旧档备份。"
	else:
		slot_menu_title.text = "选择要读取的存档"
		slot_menu_detail.text = "选择后仍需确认，不会立即回档。"
	_refresh_slot_buttons()

func _close_slot_menu() -> void:
	slot_menu_overlay.visible = false
	_slot_menu_mode = SlotMenuMode.NONE
	_selected_slot_name = ""
	game_clock.set_pause_requested(&"slot_menu", false)

func _refresh_slot_buttons() -> void:
	var buttons: Array[Button] = [slot_1_button, slot_2_button, slot_3_button]
	for index in MANUAL_SLOT_NAMES.size():
		var slot_name: String = MANUAL_SLOT_NAMES[index]
		var summary := save_coordinator.get_manual_slot_summary(slot_name)
		var exists := bool(summary.get("exists", false))
		var button: Button = buttons[index]
		button.text = _format_slot_label(index + 1, summary)
		button.visible = true
		button.disabled = _slot_menu_mode != SlotMenuMode.SAVE and not exists

func _format_slot_label(slot_number: int, summary: Dictionary) -> String:
	if not summary.get("exists", false):
		return "格位 %d · 空" % slot_number
	var recovery_suffix := " 备份恢复" if summary.get("used_backup", false) else ""
	return "格位 %d · 第 %d 日 %s · 体力 %d%s" % [
		slot_number,
		int(summary.get("day", 1)),
		_format_clock(int(summary.get("minute_of_day", 360))),
		int(summary.get("stamina", 0)),
		recovery_suffix,
	]

func _format_clock(minute_of_day: int) -> String:
	return "%02d:%02d" % [minute_of_day / 60, minute_of_day % 60]

func _on_slot_button_pressed(slot_name: String) -> void:
	if _slot_menu_mode == SlotMenuMode.SAVE:
		save_coordinator.save_manual_slot(slot_name)
		_close_slot_menu()
		return
	if _slot_menu_mode != SlotMenuMode.LOAD_SELECT:
		return
	var summary := save_coordinator.get_manual_slot_summary(slot_name)
	if not summary.get("exists", false):
		return
	_selected_slot_name = slot_name
	_slot_menu_mode = SlotMenuMode.LOAD_CONFIRM
	slot_menu_title.text = "确认读取存档"
	slot_menu_detail.text = "%s\n读取后会恢复此时刻的家园与背包状态。" % _format_slot_label(MANUAL_SLOT_NAMES.find(slot_name) + 1, summary)
	for button in [slot_1_button, slot_2_button, slot_3_button]:
		button.visible = false
	slot_confirm_button.visible = true

func _on_slot_confirm_pressed() -> void:
	if _slot_menu_mode != SlotMenuMode.LOAD_CONFIRM or _selected_slot_name.is_empty():
		return
	save_coordinator.load_manual_slot(_selected_slot_name)
	_close_slot_menu()

func _refresh_interaction_selection() -> void:
	var target := _get_nearby_target()
	_selected_target = target
	interaction_indicator.visible = target != null
	if target != null:
		interaction_indicator.global_position = target.global_position

func _update_visual_occlusion() -> void:
	# The bottom edge of each rectangle stops at the back/top edge of the
	# grounded collision. Walking in front of a wall or trunk must never fade it.
	_set_occluder_state($Farmhouse, Rect2(165, 40, 150, 80))
	_set_occluder_state($TreeA, Rect2(80, 95, 48, 52))
	_set_occluder_state($TreeB, Rect2(832, 135, 48, 52))
	_set_occluder_state($TreeC, Rect2(800, 383, 48, 52))
	_set_occluder_state($ChickenCoopExterior, Rect2(672, 56, 96, 61))

func _set_occluder_state(occluder: Sprite2D, occlusion_rect: Rect2) -> void:
	var player_is_behind := occlusion_rect.has_point(player.global_position)
	occluder.z_index = 3 if player_is_behind else 0
	occluder.modulate.a = OCCLUDER_FADED_ALPHA if player_is_behind else OCCLUDER_VISIBLE_ALPHA

func _get_nearby_target() -> GridInteractable:
	var nearest_target: GridInteractable
	var nearest_distance := INF
	for interactable in _interactables:
		if not interactable.is_gameplay_enabled():
			continue
		var distance := player.global_position.distance_to(interactable.global_position)
		if distance <= INTERACTION_RANGE and distance < nearest_distance:
			nearest_target = interactable
			nearest_distance = distance
	return nearest_target
