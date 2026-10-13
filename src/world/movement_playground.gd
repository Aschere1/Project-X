extends Node2D

const OUTDOOR_GRASS_DETAIL_TEXTURE: Texture2D = preload("res://assets/third_party/kenney_tiny_town/tile_0001.png")
const OUTDOOR_FLOWERS_TEXTURE: Texture2D = preload("res://assets/third_party/kenney_tiny_town/tile_0002.png")
const PRIVATE_SPRING_FARM_PATH := "res://assets/private/mineral_town_spring_farm/spring_farm.png"
const REQUIRED_ACTIONS := [&"move_left", &"move_right", &"move_up", &"move_down", &"sprint", &"interact", &"save_game", &"load_game", &"cycle_seed", &"cycle_cookware", &"cycle_ingredient", &"add_ingredient", &"set_seasoning", &"cook", &"clear_cooking", &"open_cooking_notebook"]
const GREYBOX_GRID_ORIGIN := Vector2(16.0, 44.0)
const SPRING_FARM_GRID_ORIGIN := Vector2(0.0, 44.0)
const GRID_CELL_SIZE := 16.0
const INTERACTION_RANGE := 32.0
const MANUAL_SLOT_NAMES: Array[String] = ["slot_1", "slot_2", "slot_3"]
const OUTDOOR_AREA_ID := &"outdoor"
const HOME_INTERIOR_AREA_ID := &"home_interior"
const GREYBOX_OUTDOOR_MOVEMENT_BOUNDS := Rect2(24.0, 52.0, 432.0, 192.0)
const SPRING_FARM_OUTDOOR_MOVEMENT_BOUNDS := Rect2(16.0, 52.0, 992.0, 680.0)
const GREYBOX_OUTDOOR_HOME_EXIT_POSITION := Vector2(168.0, 180.0)
const SPRING_FARM_OUTDOOR_HOME_EXIT_POSITION := Vector2(232.0, 196.0)
const SPRING_FARM_WORLD_SIZE := Vector2i(1024, 748)
const SPRING_FARM_INTERACTION_CELLS := {
	&"cooking_counter": Vector2i(16, 11),
	&"letter_box": Vector2i(17, 7),
	&"home_entrance": Vector2i(14, 7),
	&"field_plot": Vector2i(18, 12),
	&"forage_meadow": Vector2i(7, 24),
	&"forage_hedge": Vector2i(37, 8),
	&"fishing_pond": Vector2i(17, 20),
	&"starter_chicken_coop": Vector2i(46, 8),
}
const SPRING_FARM_VISIBLE_INTERACTION_IDS := [
	&"home_entrance",
	&"field_plot",
	&"starter_chicken_coop",
]
const SPRING_CROP_CATALOG = preload("res://content/catalogs/spring_crop_catalog.tres")
const ACTION_COOKWARE := &"cycle_cookware"
const ACTION_INGREDIENT := &"cycle_ingredient"
const ACTION_ADD_INGREDIENT := &"add_ingredient"
const ACTION_SEASONING := &"set_seasoning"
const ACTION_COOK := &"cook"
const ACTION_CLEAR_COOKING := &"clear_cooking"
const ACTION_OPEN_COOKING_NOTEBOOK := &"open_cooking_notebook"

enum SlotMenuMode {
	NONE,
	SAVE,
	LOAD_SELECT,
	LOAD_CONFIRM,
}

@onready var player: PlayerController = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var spring_farm_backdrop: Sprite2D = $SpringFarmBackdrop
@onready var spring_farm_collision: StaticBody2D = $SpringFarmCollision
@onready var status_label: Label = %StatusLabel
@onready var interaction_indicator: Node2D = $InteractionIndicator
@onready var game_clock: GameClockController = $GameClock
@onready var day_label: Label = %DayLabel
@onready var weather_label: Label = %WeatherLabel
@onready var clock_label: Label = %ClockLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var pause_overlay: Control = %PauseOverlay
@onready var save_coordinator: SaveCoordinator = $SaveCoordinator
@onready var inventory_controller: InventoryController = $InventoryController
@onready var cooking_controller: CookingController = $CookingController
@onready var cooking_overlay: Control = %CookingOverlay
@onready var cooking_state_label: Label = %CookingStateLabel
@onready var cooking_notebook_overlay: Control = %CookingNotebookOverlay
@onready var cooking_notebook_state_label: Label = %CookingNotebookStateLabel
@onready var notebook_previous_button: Button = %NotebookPreviousButton
@onready var notebook_next_button: Button = %NotebookNextButton
@onready var notebook_load_button: Button = %NotebookLoadButton
@onready var notebook_close_button: Button = %NotebookCloseButton
@onready var inventory_overlay: Control = %InventoryOverlay
@onready var inventory_contents_label: Label = %InventoryContentsLabel
@onready var home_interior: HomeInterior = $HomeInterior
@onready var slot_menu_overlay: Control = %SlotMenuOverlay
@onready var slot_menu_title: Label = %SlotMenuTitle
@onready var slot_menu_detail: Label = %SlotMenuDetail
@onready var slot_1_button: Button = %Slot1Button
@onready var slot_2_button: Button = %Slot2Button
@onready var slot_3_button: Button = %Slot3Button
@onready var slot_confirm_button: Button = %SlotConfirmButton
@onready var slot_cancel_button: Button = %SlotCancelButton

var _last_interaction_text := ""
var _interactables_by_cell: Dictionary[String, GridInteractable] = {}
var _selected_target: GridInteractable
var _slot_menu_mode := SlotMenuMode.NONE
var _selected_slot_name := ""
var _current_area_id: StringName = OUTDOOR_AREA_ID
var _last_processed_world_day := 1
var _is_cooking_open := false
var _is_cooking_notebook_open := false
var _notebook_entry_index := 0
var _spring_farm_active := false

func _ready() -> void:
	_configure_spring_farm_backdrop()
	for action in REQUIRED_ACTIONS:
		assert(InputMap.has_action(action), "Missing required input action: %s" % action)
	player.interaction_requested.connect(_on_player_interaction_requested)
	player.tool_requested.connect(_on_player_tool_requested)
	game_clock.clock_updated.connect(_on_clock_updated)
	game_clock.calendar_updated.connect(_on_calendar_updated)
	game_clock.pause_changed.connect(_on_pause_changed)
	save_coordinator.save_message.connect(_on_save_message)
	inventory_controller.inventory_changed.connect(_on_inventory_changed)
	inventory_controller.panel_visibility_changed.connect(_on_inventory_panel_visibility_changed)
	cooking_controller.cooking_state_changed.connect(_refresh_cooking_overlay)
	cooking_controller.cooked.connect(_on_cooked)
	notebook_previous_button.pressed.connect(_move_notebook_entry.bind(-1))
	notebook_next_button.pressed.connect(_move_notebook_entry.bind(1))
	notebook_load_button.pressed.connect(_load_selected_notebook_entry)
	notebook_close_button.pressed.connect(_close_cooking_notebook)
	slot_1_button.pressed.connect(_on_slot_button_pressed.bind("slot_1"))
	slot_2_button.pressed.connect(_on_slot_button_pressed.bind("slot_2"))
	slot_3_button.pressed.connect(_on_slot_button_pressed.bind("slot_3"))
	slot_confirm_button.pressed.connect(_on_slot_confirm_pressed)
	slot_cancel_button.pressed.connect(_close_slot_menu)
	game_clock.emit_clock_state()
	_on_inventory_changed()
	_register_grid_interactables()
	_last_processed_world_day = game_clock.session.get_day()
	_set_active_area(OUTDOOR_AREA_ID, player.global_position)
	_refresh_interaction_selection()
	assert(interaction_indicator.visible, "The initial nearby map doorway should be selectable.")
	queue_redraw()
	print(
		"WORLD_READY actions=%d targets=%d selection=%s" % [
			REQUIRED_ACTIONS.size(),
			_interactables_by_cell.size(),
			interaction_indicator.visible,
		],
	)

func _process(_delta: float) -> void:
	_refresh_interaction_selection()
	var location := player.global_position.round()
	var interaction_suffix := "  %s" % _last_interaction_text if not _last_interaction_text.is_empty() else ""
	var area_name := "住宅室内" if _current_area_id == HOME_INTERIOR_AREA_ID else "家园室外"
	status_label.text = "%s  位置 %03d, %03d  朝向%s%s" % [area_name, location.x, location.y, player.get_facing_name(), interaction_suffix]

func _unhandled_input(event: InputEvent) -> void:
	if _is_cooking_notebook_open:
		_handle_cooking_notebook_input(event)
		return
	if _is_cooking_open:
		_handle_cooking_input(event)
		return
	if event.is_action_pressed(ACTION_OPEN_COOKING_NOTEBOOK):
		_open_cooking_notebook()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"save_game"):
		_open_slot_menu(SlotMenuMode.SAVE)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"load_game"):
		_open_slot_menu(SlotMenuMode.LOAD_SELECT)
		get_viewport().set_input_as_handled()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(480.0, 270.0)), Color("4d7f58"))
	draw_rect(Rect2(16.0, 44.0, 448.0, 210.0), Color("81c66b"), true)
	for grass_position in [Vector2(80.0, 76.0), Vector2(176.0, 108.0), Vector2(352.0, 92.0), Vector2(64.0, 172.0), Vector2(304.0, 188.0), Vector2(400.0, 148.0)]:
		draw_texture(OUTDOOR_GRASS_DETAIL_TEXTURE, grass_position)
	for flower_position in [Vector2(40.0, 58.0), Vector2(432.0, 62.0), Vector2(48.0, 218.0), Vector2(416.0, 218.0), Vector2(280.0, 84.0)]:
		draw_texture(OUTDOOR_FLOWERS_TEXTURE, flower_position)
	draw_rect(Rect2(16.0, 44.0, 448.0, 210.0), Color("d6bd78"), false, 2.0)

func _on_player_interaction_requested(_facing_direction: Vector2) -> void:
	var target := _get_nearby_target()
	if target == null:
		return
	target.interact()

func _refresh_interaction_selection() -> void:
	var target := _get_nearby_target()
	if target == _selected_target:
		return

	_selected_target = target
	interaction_indicator.visible = target != null
	if target != null:
		interaction_indicator.global_position = target.global_position

func _get_nearby_target() -> GridInteractable:
	var nearest_target: GridInteractable
	var nearest_distance := INF
	for interactable in _interactables_by_cell.values():
		if not interactable.is_gameplay_enabled() or interactable.area_id != _current_area_id:
			continue
		var distance := player.global_position.distance_to(interactable.global_position)
		if distance <= INTERACTION_RANGE and distance < nearest_distance:
			nearest_target = interactable
			nearest_distance = distance
	return nearest_target

func _register_grid_interactables() -> void:
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		var interactable := node as GridInteractable
		if interactable == null:
			continue
		var is_map_backed_outdoor := _spring_farm_active and interactable.area_id == OUTDOOR_AREA_ID
		var has_visible_map_counterpart := not is_map_backed_outdoor or interactable.interaction_id in SPRING_FARM_VISIBLE_INTERACTION_IDS
		interactable.set_gameplay_enabled(has_visible_map_counterpart)
		interactable.set_uses_map_collision_proxy(is_map_backed_outdoor)
		if _spring_farm_active and interactable.area_id == OUTDOOR_AREA_ID and SPRING_FARM_INTERACTION_CELLS.has(interactable.interaction_id):
			interactable.grid_cell = Vector2i(SPRING_FARM_INTERACTION_CELLS[interactable.interaction_id])
		var interaction_key := _interaction_key(interactable.area_id, interactable.grid_cell)
		assert(
			not _interactables_by_cell.has(interaction_key),
			"Duplicate interactable cell in area %s: %s" % [interactable.area_id, interactable.grid_cell],
		)
		_interactables_by_cell[interaction_key] = interactable
		interactable.global_position = _cell_to_world(interactable.grid_cell, interactable.area_id)
		if is_map_backed_outdoor:
			var farm_plot := interactable as FarmPlot
			if farm_plot != null:
				farm_plot.set_hide_untouched_visual(true)
				farm_plot.set_uses_private_crop_visual(true)
			else:
				interactable.set_visual_suppressed(true)
		interactable.interacted.connect(_on_grid_interactable_interacted)

func _on_grid_interactable_interacted(_interaction_id: StringName, result_text: String) -> void:
	var chicken_coop := _selected_target as ChickenCoop
	if chicken_coop != null and chicken_coop.interaction_id == _interaction_id:
		_interact_with_chicken_coop(chicken_coop)
		return
	var forage_spot := _selected_target as ForageSpot
	if forage_spot != null and forage_spot.interaction_id == _interaction_id:
		_collect_forage(forage_spot)
		return
	var fishing_spot := _selected_target as FishingSpot
	if fishing_spot != null and fishing_spot.interaction_id == _interaction_id:
		_fish_at_spot(fishing_spot)
		return
	if _interaction_id == &"cooking_counter":
		_is_cooking_open = true
		cooking_overlay.visible = true
		game_clock.set_pause_requested(&"cooking_panel", true)
		_refresh_cooking_overlay()
		return
	if _interaction_id == &"home_entrance":
		_set_active_area(HOME_INTERIOR_AREA_ID, home_interior.entry_position)
		_last_interaction_text = "进入住宅，室内时间流速减半。"
		return
	if _interaction_id == &"home_exit":
		_set_active_area(OUTDOOR_AREA_ID, _get_outdoor_home_exit_position())
		_last_interaction_text = "回到家园室外。"
		return
	if _interaction_id == &"bed":
		game_clock.session.sleep()
		game_clock.reset_time_accumulator()
		game_clock.emit_clock_state()
		_last_interaction_text = "休息到次日清晨，体力已经恢复。"
		return
	_last_interaction_text = result_text

func _interact_with_chicken_coop(chicken_coop: ChickenCoop) -> void:
	var day := game_clock.session.get_day()
	chicken_coop.advance_to_day(day)
	if chicken_coop.has_pending_egg():
		var egg_item_id := chicken_coop.chicken.product_item_id
		var egg_quality := chicken_coop.peek_next_egg_quality()
		if not inventory_controller.can_add_item(egg_item_id, 1, egg_quality):
			_last_interaction_text = "背包没有空间，鸡蛋仍安全留在鸡舍。"
			return
		chicken_coop.take_next_egg_quality()
		inventory_controller.add_item(egg_item_id, 1, egg_quality)
		_finish_source_action(0, 5)
		_last_interaction_text = "收取%s鸡蛋；鸡舍还有 %d 枚待收。" % [inventory_controller.get_quality_suffix(egg_quality), chicken_coop.get_pending_egg_count()]
		return
	if not chicken_coop.is_fed_today(day):
		if inventory_controller.inventory.count_item(&"chicken_feed") < 1:
			_last_interaction_text = "没有鸡饲料。%s不会生病，但明天不会产蛋。" % chicken_coop.chicken.display_name
			return
		if not _has_stamina_for_source_action(1):
			return
		inventory_controller.remove_item(&"chicken_feed", 1)
		chicken_coop.feed(day)
		_finish_source_action(1, 5)
		_last_interaction_text = "已经给%s喂食；再互动一次可以抚摸。" % chicken_coop.chicken.display_name
		return
	if not chicken_coop.is_petted_today(day):
		chicken_coop.pet(day)
		_finish_source_action(0, 5)
		_last_interaction_text = "轻轻抚摸了%s；连续细心照料会提高鸡蛋品质。" % chicken_coop.chicken.display_name
		return
	_last_interaction_text = chicken_coop.get_status_text(day, game_clock.session.get_weather_id())

func _collect_forage(forage_spot: ForageSpot) -> void:
	var day := game_clock.session.get_day()
	if not forage_spot.is_available(day):
		_last_interaction_text = "这里今天已经采集过了，明天再来看看。"
		return
	if not _has_stamina_for_source_action(1):
		return
	var reward := forage_spot.preview_reward(day, game_clock.session.get_weather_id(), game_clock.session.get_world_seed())
	if reward.is_empty():
		_last_interaction_text = "这里今天没有可采集的食材。"
		return
	var item_id := StringName(reward["item_id"])
	var quantity := int(reward["quantity"])
	var quality := int(reward["quality"])
	if not inventory_controller.can_add_item(item_id, quantity, quality):
		_last_interaction_text = "背包没有空间，采集物仍留在原处。"
		return
	forage_spot.mark_collected(day)
	inventory_controller.add_item(item_id, quantity, quality)
	_finish_source_action(1, 10)
	var definition := inventory_controller.item_catalog.get_item(item_id)
	_last_interaction_text = "采集到%s%s x%d。" % [inventory_controller.get_quality_suffix(quality), definition.display_name, quantity]

func _fish_at_spot(fishing_spot: FishingSpot) -> void:
	var day := game_clock.session.get_day()
	if fishing_spot.get_remaining_catches(day) <= 0:
		_last_interaction_text = "今天已经带走三条鱼，让池塘休息到明天吧。"
		return
	if not _has_stamina_for_source_action(3):
		return
	var reward := fishing_spot.preview_reward(day, game_clock.session.get_weather_id(), game_clock.session.get_world_seed())
	if reward.is_empty():
		_last_interaction_text = "这次没有鱼靠近钓点。"
		return
	var item_id := StringName(reward["item_id"])
	var quantity := int(reward["quantity"])
	var quality := int(reward["quality"])
	if not inventory_controller.can_add_item(item_id, quantity, quality):
		_last_interaction_text = "背包没有空间，暂时不抛竿。"
		return
	fishing_spot.record_catch(day)
	inventory_controller.add_item(item_id, quantity, quality)
	_finish_source_action(3, 20)
	fishing_spot.refresh_for_day(game_clock.session.get_day())
	var definition := inventory_controller.item_catalog.get_item(item_id)
	_last_interaction_text = "钓到%s%s；今天还可带走 %d 条。" % [inventory_controller.get_quality_suffix(quality), definition.display_name, fishing_spot.get_remaining_catches(game_clock.session.get_day())]

func _has_stamina_for_source_action(stamina_cost: int) -> bool:
	if game_clock.session.get_stamina() >= stamina_cost:
		return true
	_last_interaction_text = "体力不足，无法完成这次野外行动。"
	return false

func _finish_source_action(stamina_cost: int, elapsed_minutes: int) -> void:
	game_clock.session.consume_stamina(stamina_cost)
	game_clock.session.advance_minutes(elapsed_minutes)
	game_clock.emit_clock_state()

func _on_player_tool_requested(_facing_direction: Vector2) -> void:
	var target := _get_nearby_target()
	var farm_plot := target as FarmPlot
	if farm_plot == null:
		return
	if not farm_plot.is_tilled():
		if not _has_stamina_for_farm_action(5):
			return
		_perform_farm_action(farm_plot.use_tool(FarmPlot.HOE_TOOL_ID), 5, 10)
		return
	if not farm_plot.has_crop():
		var seed_item_id := inventory_controller.get_selected_seed_item_id()
		if seed_item_id == &"":
			_last_interaction_text = "背包里没有可播种的种子。"
			return
		var crop_catalog: Variant = SPRING_CROP_CATALOG
		var crop: Variant = crop_catalog.get_crop_by_seed_item_id(seed_item_id)
		if crop == null:
			_last_interaction_text = "当前种子没有对应的作物数据。"
			return
		if inventory_controller.inventory.count_item(seed_item_id) < 1:
			_last_interaction_text = "背包里没有当前选中的种子。"
			return
		if not _has_stamina_for_farm_action(2):
			return
		var plant_result: Dictionary = farm_plot.plant(crop)
		if not plant_result.get("success", false):
			_last_interaction_text = plant_result.get("message", "无法播种。")
			return
		inventory_controller.remove_item(seed_item_id, 1)
		_perform_farm_action(plant_result, 2, 5)
		return
	if farm_plot.needs_water():
		if not _has_stamina_for_farm_action(2):
			return
		_perform_farm_action(farm_plot.water(), 2, 5)
		return
	if farm_plot.is_ready_to_harvest():
		var harvest_item_id := farm_plot.get_harvest_item_id()
		var harvest_amount := farm_plot.get_harvest_amount()
		if not inventory_controller.can_add_item(harvest_item_id, harvest_amount):
			_last_interaction_text = "背包没有空间，无法收获。"
			return
		if not _has_stamina_for_farm_action(2):
			return
		var harvest_result: Dictionary = farm_plot.harvest()
		if harvest_result.get("success", false):
			inventory_controller.add_item(harvest_item_id, harvest_amount)
		_perform_farm_action(harvest_result, 2, 10)
		return
	_last_interaction_text = "作物正在等待明天生长。"

func _has_stamina_for_farm_action(stamina_cost: int) -> bool:
	if game_clock.session.get_stamina() >= stamina_cost:
		return true
	_last_interaction_text = "体力不足，无法完成这项农田工作。"
	return false

func _perform_farm_action(result: Dictionary, stamina_cost: int, elapsed_minutes: int) -> void:
	if not result.get("success", false):
		_last_interaction_text = result.get("message", "农田行动没有产生效果。")
		return
	if game_clock.session.get_stamina() < stamina_cost:
		_last_interaction_text = "体力不足，无法完成这项农田工作。"
		return
	_last_interaction_text = result.get("message", "农田行动完成。")
	game_clock.session.consume_stamina(stamina_cost)
	game_clock.session.advance_minutes(elapsed_minutes)
	game_clock.emit_clock_state()

func _on_clock_updated(day: int, clock_text: String, stamina: int, maximum_stamina: int) -> void:
	_advance_world_to_day(day)
	clock_label.text = clock_text
	stamina_label.text = "体力 %d/%d" % [stamina, maximum_stamina]

func _on_calendar_updated(season_name: String, season_day: int, weather_text: String, forecast_text: String) -> void:
	day_label.text = "%s  第%d日" % [season_name, season_day]
	var weather_effect := " · 农田自动浇水" if game_clock.session.get_weather_id() == GameRules.WEATHER_RAIN else ""
	weather_label.text = "%s%s · 明日%s" % [weather_text, weather_effect, forecast_text]

func _advance_world_to_day(current_day: int) -> void:
	if current_day <= _last_processed_world_day:
		_last_processed_world_day = current_day
		_refresh_daily_world_state(current_day)
		return
	for elapsed_day in range(_last_processed_world_day, current_day):
		var elapsed_weather := game_clock.rules.get_weather_for_day(elapsed_day, game_clock.session.get_world_seed())
		for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
			var farm_plot := node as FarmPlot
			if farm_plot != null:
				farm_plot.apply_weather(elapsed_weather)
				farm_plot.advance_day()
				continue
			var chicken_coop := node as ChickenCoop
			if chicken_coop != null:
				chicken_coop.advance_to_day(elapsed_day + 1)
	_last_processed_world_day = current_day
	_refresh_daily_world_state(current_day)

func _refresh_daily_world_state(current_day: int) -> void:
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		var chicken_coop := node as ChickenCoop
		if chicken_coop != null:
			chicken_coop.refresh_for_day(current_day)
			continue
		var forage_spot := node as ForageSpot
		if forage_spot != null:
			forage_spot.refresh_for_day(current_day)
			continue
		var fishing_spot := node as FishingSpot
		if fishing_spot != null:
			fishing_spot.refresh_for_day(current_day)

func _on_pause_changed(is_paused: bool) -> void:
	pause_overlay.visible = is_paused
	player.set_input_enabled(not is_paused)

func _on_save_message(message: String) -> void:
	_last_interaction_text = message

func _on_inventory_changed() -> void:
	inventory_contents_label.text = inventory_controller.get_inventory_text()

func _on_inventory_panel_visibility_changed(is_visible: bool) -> void:
	inventory_overlay.visible = is_visible
	game_clock.set_pause_requested(&"inventory_panel", is_visible)

func _handle_cooking_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_OPEN_COOKING_NOTEBOOK):
		_open_cooking_notebook()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"interact"):
		_is_cooking_open = false
		cooking_overlay.visible = false
		game_clock.set_pause_requested(&"cooking_panel", false)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(ACTION_COOKWARE): cooking_controller.cycle_cookware()
	elif event.is_action_pressed(ACTION_INGREDIENT): cooking_controller.cycle_ingredient()
	elif event.is_action_pressed(ACTION_ADD_INGREDIENT): cooking_controller.add_current_ingredient()
	elif event.is_action_pressed(ACTION_SEASONING): cooking_controller.set_current_seasoning()
	elif event.is_action_pressed(ACTION_COOK): cooking_controller.cook()
	elif event.is_action_pressed(ACTION_CLEAR_COOKING): cooking_controller.clear_selection()
	else: return
	get_viewport().set_input_as_handled()

func _handle_cooking_notebook_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_OPEN_COOKING_NOTEBOOK):
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
		_last_interaction_text = "这条料理笔记无法装填。"
		_refresh_cooking_notebook_overlay()
		return
	_last_interaction_text = "已按笔记装填料理组合。"
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
	notebook_previous_button.disabled = entry_count <= 1
	notebook_next_button.disabled = entry_count <= 1
	notebook_load_button.disabled = entry_count == 0

func _refresh_cooking_overlay() -> void:
	if _is_cooking_open:
		cooking_state_label.text = cooking_controller.get_state_text()

func _on_cooked(message: String) -> void:
	_last_interaction_text = message
	_refresh_cooking_overlay()

func _open_slot_menu(mode: SlotMenuMode) -> void:
	_selected_slot_name = ""
	_slot_menu_mode = mode
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
		return "格位 %d  ·  空" % slot_number
	var recovery_suffix := " 备份恢复" if summary.get("used_backup", false) else ""
	return "格位 %d  ·  第 %d 日 %s  ·  体力 %d%s" % [
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
	slot_menu_detail.text = "%s\n读取后会恢复此时刻的世界状态。" % _format_slot_label(MANUAL_SLOT_NAMES.find(slot_name) + 1, summary)
	for button in [slot_1_button, slot_2_button, slot_3_button]:
		button.visible = false
	slot_confirm_button.visible = true

func _on_slot_confirm_pressed() -> void:
	if _slot_menu_mode != SlotMenuMode.LOAD_CONFIRM or _selected_slot_name.is_empty():
		return
	save_coordinator.load_manual_slot(_selected_slot_name)
	_close_slot_menu()

func capture_interaction_state() -> Dictionary:
	var farm_plot_states: Dictionary = {}
	var forage_spot_states: Dictionary = {}
	var fishing_spot_states: Dictionary = {}
	var chicken_coop_states: Dictionary = {}
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		if node is FarmPlot:
			farm_plot_states[String(node.interaction_id)] = node.to_snapshot()
		elif node is ForageSpot:
			forage_spot_states[String(node.interaction_id)] = node.to_snapshot()
		elif node is FishingSpot:
			fishing_spot_states[String(node.interaction_id)] = node.to_snapshot()
		elif node is ChickenCoop:
			chicken_coop_states[String(node.interaction_id)] = node.to_snapshot()
	return {"farm_plots": farm_plot_states, "forage_spots": forage_spot_states, "fishing_spots": fishing_spot_states, "chicken_coops": chicken_coop_states}

func restore_interaction_state(snapshot: Dictionary) -> bool:
	var farm_plot_values: Variant = snapshot.get("farm_plots", {})
	var forage_spot_values: Variant = snapshot.get("forage_spots", {})
	var fishing_spot_values: Variant = snapshot.get("fishing_spots", {})
	var chicken_coop_values: Variant = snapshot.get("chicken_coops", {})
	if not farm_plot_values is Dictionary or not forage_spot_values is Dictionary or not fishing_spot_values is Dictionary or not chicken_coop_values is Dictionary:
		return false
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		if node is FarmPlot:
			var plot_snapshot: Variant = farm_plot_values.get(String(node.interaction_id), {"version": 1, "is_tilled": false})
			if not plot_snapshot is Dictionary or not node.restore_snapshot(plot_snapshot):
				return false
		elif node is ForageSpot:
			var forage_snapshot: Variant = forage_spot_values.get(String(node.interaction_id), {"version": 1, "last_collected_day": 0})
			if not forage_snapshot is Dictionary or not node.restore_snapshot(forage_snapshot):
				return false
		elif node is FishingSpot:
			var fishing_snapshot: Variant = fishing_spot_values.get(String(node.interaction_id), {"version": 1, "tracked_day": 0, "catches_today": 0})
			if not fishing_snapshot is Dictionary or not node.restore_snapshot(fishing_snapshot):
				return false
		elif node is ChickenCoop:
			var coop_snapshot: Variant = chicken_coop_values.get(String(node.interaction_id), {"version": 1, "tracked_day": game_clock.session.get_day(), "fed_today": false, "petted_today": false, "care_streak": 0, "pending_egg_qualities": []})
			if not coop_snapshot is Dictionary or not node.restore_snapshot(coop_snapshot):
				return false
	return true

func _world_to_cell(world_position: Vector2) -> Vector2i:
	var grid_origin := SPRING_FARM_GRID_ORIGIN if _spring_farm_active and _current_area_id == OUTDOOR_AREA_ID else GREYBOX_GRID_ORIGIN
	return Vector2i(
		floori((world_position.x - grid_origin.x) / GRID_CELL_SIZE),
		floori((world_position.y - grid_origin.y) / GRID_CELL_SIZE),
	)

func _cell_to_world(cell: Vector2i, area_id: StringName) -> Vector2:
	var grid_origin := SPRING_FARM_GRID_ORIGIN if _spring_farm_active and area_id == OUTDOOR_AREA_ID else GREYBOX_GRID_ORIGIN
	return grid_origin + (Vector2(cell) + Vector2(0.5, 0.5)) * GRID_CELL_SIZE

func _interaction_key(area_id: StringName, cell: Vector2i) -> String:
	return "%s:%d:%d" % [area_id, cell.x, cell.y]

func _set_active_area(area_id: StringName, arrival_position: Vector2) -> bool:
	if area_id != OUTDOOR_AREA_ID and area_id != HOME_INTERIOR_AREA_ID:
		return false
	_current_area_id = area_id
	var is_indoor := area_id == HOME_INTERIOR_AREA_ID
	home_interior.visible = is_indoor
	spring_farm_backdrop.visible = _spring_farm_active and not is_indoor
	spring_farm_collision.set_deferred("collision_layer", 0 if is_indoor or not _spring_farm_active else 1)
	game_clock.set_indoor(is_indoor)
	player.movement_bounds = home_interior.movement_bounds if is_indoor else _get_outdoor_movement_bounds()
	_configure_camera_for_area(is_indoor)
	for node in get_tree().get_nodes_in_group(GridInteractable.INTERACTABLE_GROUP):
		var interactable := node as GridInteractable
		if interactable != null:
			interactable.set_area_active(interactable.area_id == area_id)
	player.global_position = arrival_position.clamp(
		player.movement_bounds.position,
		player.movement_bounds.position + player.movement_bounds.size,
	)
	_selected_target = null
	interaction_indicator.visible = false
	queue_redraw()
	return true

func get_current_area_id() -> StringName:
	return _current_area_id

func restore_area_and_player_position(area_id: StringName, position: Vector2) -> bool:
	return _set_active_area(area_id, position)

func is_spring_farm_backdrop_active() -> bool:
	return _spring_farm_active

func _configure_spring_farm_backdrop() -> void:
	if not ResourceLoader.exists(PRIVATE_SPRING_FARM_PATH):
		_spring_farm_active = false
		spring_farm_backdrop.visible = false
		return
	var loaded_resource: Resource = load(PRIVATE_SPRING_FARM_PATH)
	var spring_farm_texture := loaded_resource as Texture2D
	if spring_farm_texture == null or spring_farm_texture.get_size() != Vector2(1024.0, 704.0):
		_spring_farm_active = false
		spring_farm_backdrop.visible = false
		return
	_spring_farm_active = true
	spring_farm_backdrop.texture = spring_farm_texture
	spring_farm_backdrop.visible = true
	player.global_position = SPRING_FARM_OUTDOOR_HOME_EXIT_POSITION

func _get_outdoor_movement_bounds() -> Rect2:
	return SPRING_FARM_OUTDOOR_MOVEMENT_BOUNDS if _spring_farm_active else GREYBOX_OUTDOOR_MOVEMENT_BOUNDS

func _get_outdoor_home_exit_position() -> Vector2:
	return SPRING_FARM_OUTDOOR_HOME_EXIT_POSITION if _spring_farm_active else GREYBOX_OUTDOOR_HOME_EXIT_POSITION

func _configure_camera_for_area(is_indoor: bool) -> void:
	player_camera.limit_left = 0
	player_camera.limit_top = 0
	if is_indoor or not _spring_farm_active:
		player_camera.limit_right = 480
		player_camera.limit_bottom = 270
	else:
		player_camera.limit_right = SPRING_FARM_WORLD_SIZE.x
		player_camera.limit_bottom = SPRING_FARM_WORLD_SIZE.y
	player_camera.reset_smoothing()
