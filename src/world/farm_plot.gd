class_name FarmPlot
extends GridInteractable

const SNAPSHOT_VERSION := 2
const LEGACY_SNAPSHOT_VERSION := 1
const HOE_TOOL_ID := &"hoe"
const CROP_DEFINITION_SCRIPT = preload("res://src/domain/farming/crop_definition.gd")
const ORIGINAL_CROP_STAGES: Texture2D = preload("res://assets/art/crops/spring_crop_stages.png")
const TILE_SIZE := Vector2(16.0, 16.0)
const ORIGINAL_TILLED_REGION := Rect2(0.0, 0.0, 16.0, 16.0)
const ORIGINAL_SPROUT_REGION := Rect2(16.0, 0.0, 16.0, 16.0)
const ORIGINAL_GROWING_REGION := Rect2(32.0, 0.0, 16.0, 16.0)
const ORIGINAL_MATURE_REGION := Rect2(48.0, 0.0, 16.0, 16.0)

@export var visual_catalog: Resource
@export var soil_visual_set: Resource
@export_enum("none", "untouched", "dry_tilled", "wet_tilled", "dry_crop", "wet_crop") var editor_preview_state := "none"
@export var editor_preview_crop: Resource

var _is_tilled := false
var _crop_id: StringName
var _harvest_item_id: StringName
var _days_to_mature := 0
var _harvest_amount := 0
var _regrow_days := 0
var _growth_days := 0
var _is_watered_today := false
var _hide_untouched_visual := false

func _ready() -> void:
	super._ready()
	_apply_editor_preview()

func _apply_editor_preview() -> void:
	if editor_preview_state == "none" or editor_preview_state == "untouched":
		return
	if editor_preview_state in ["dry_tilled", "wet_tilled", "dry_crop", "wet_crop"]:
		use_tool(HOE_TOOL_ID)
	if editor_preview_state in ["dry_crop", "wet_crop"] and editor_preview_crop != null:
		plant(editor_preview_crop)
	if editor_preview_state == "wet_tilled" or editor_preview_state == "wet_crop":
		_is_watered_today = true
		_refresh_visual()

func set_hide_untouched_visual(should_hide: bool) -> void:
	_hide_untouched_visual = should_hide
	queue_redraw()

func set_uses_private_crop_visual(_should_use: bool) -> void:
	# Kept for the old prototype scene; formal visuals now come from the
	# Inspector-assigned Super Retro CropVisualCatalog resource.
	queue_redraw()

func get_visual_state_id() -> StringName:
	if not _is_tilled:
		return &"untouched"
	if not has_crop():
		return &"tilled"
	if is_ready_to_harvest():
		return &"mature"
	if _is_watered_today:
		return &"watered"
	return &"planted"

func get_visual_cell_rect() -> Rect2:
	# FarmPlot.position is the center of the logical 16x16 TileMap cell.
	# Keeping this rect centered prevents its visual, interaction position and
	# future editor-painted FarmCells layer from drifting apart.
	return Rect2(-TILE_SIZE * 0.5, TILE_SIZE)

func _draw() -> void:
	if _hide_untouched_visual and not _is_tilled:
		return
	_draw_soil_visual()
	if not has_crop():
		return
	if visual_catalog != null and _draw_super_retro_crop_visual():
		return
	if not _hide_untouched_visual:
		_draw_original_crop_visual()

func _draw_soil_visual() -> void:
	if soil_visual_set == null:
		return
	var soil_state := &"untouched"
	if _is_tilled:
		soil_state = &"wet_tilled" if _is_watered_today else &"dry_tilled"
	var texture := soil_visual_set.call("get_texture", soil_state) as Texture2D
	if texture == null:
		return
	var modulate := soil_visual_set.call("get_modulate", soil_state) as Color
	draw_texture_rect(texture, get_visual_cell_rect(), false, modulate)

func _draw_super_retro_crop_visual() -> bool:
	var definition: Resource = visual_catalog.get_definition(_crop_id)
	var texture := definition.get("texture") as Texture2D if definition != null else null
	if definition == null or texture == null:
		return false
	var stage_index := 0
	if is_ready_to_harvest():
		stage_index = 3
	elif _growth_days >= maxi(1, ceili(float(_days_to_mature) / 2.0)):
		stage_index = 2
	elif _growth_days > 0:
		stage_index = 1
	var source_region: Rect2 = definition.call("get_stage_region", stage_index)
	if source_region.size == Vector2.ZERO:
		return false
	# The source plants are taller than one tile. Their bottom edge stays on
	# the FarmPlot cell center so adjacent editor-painted rows remain aligned.
	draw_texture_rect_region(texture, Rect2(-8.0, -16.0, 16.0, 24.0), source_region)
	return true

func _draw_original_crop_visual() -> void:
	var target_rect := get_visual_cell_rect()
	var crop_region := ORIGINAL_TILLED_REGION
	if has_crop():
		if is_ready_to_harvest():
			crop_region = ORIGINAL_MATURE_REGION
		elif _growth_days > 0:
			crop_region = ORIGINAL_GROWING_REGION
		else:
			crop_region = ORIGINAL_SPROUT_REGION
	draw_texture_rect_region(ORIGINAL_CROP_STAGES, target_rect, crop_region)

func use_tool(tool_id: StringName) -> Dictionary:
	if tool_id != HOE_TOOL_ID:
		return {"success": false, "message": "这个工具不能用于农田。"}
	if _is_tilled:
		return {"success": false, "message": "这块农田已经翻好了。"}

	_is_tilled = true
	fill_color = Color("6a4428")
	queue_redraw()
	return {"success": true, "message": "翻土完成，可以播种了。"}

func plant(crop: Variant) -> Dictionary:
	if not _is_tilled:
		return {"success": false, "message": "先翻土，才能播种。"}
	if has_crop():
		return {"success": false, "message": "这块农田已经种了作物。"}
	if crop == null or not is_instance_of(crop, CROP_DEFINITION_SCRIPT):
		return {"success": false, "message": "作物数据无效。"}
	var crop_id: StringName = crop.crop_id
	var harvest_item_id: StringName = crop.harvest_item_id
	var days_to_mature: int = crop.days_to_mature
	var harvest_amount: int = crop.harvest_amount
	var regrow_days: int = crop.regrow_days
	if crop_id == &"" or harvest_item_id == &"" or days_to_mature < 1 or harvest_amount < 1 or regrow_days < 0:
		return {"success": false, "message": "作物数据不完整。"}
	_crop_id = crop_id
	_harvest_item_id = harvest_item_id
	_days_to_mature = days_to_mature
	_harvest_amount = harvest_amount
	_regrow_days = regrow_days
	_growth_days = 0
	_is_watered_today = false
	_refresh_visual()
	return {"success": true, "message": "%s已经播种，需要每天浇水。" % crop.display_name}

func water() -> Dictionary:
	if not has_crop():
		return {"success": false, "message": "这里还没有作物可以浇水。"}
	if is_ready_to_harvest():
		return {"success": false, "message": "作物已经成熟，可以收获了。"}
	if _is_watered_today:
		return {"success": false, "message": "今天已经浇过水了。"}
	_is_watered_today = true
	_refresh_visual()
	return {"success": true, "message": "浇水完成，作物会在明天生长。"}

func advance_day() -> Dictionary:
	if not has_crop():
		return {"grew": false, "became_ready": false}
	var grew := _is_watered_today and not is_ready_to_harvest()
	if grew:
		_growth_days += 1
	var became_ready := grew and is_ready_to_harvest()
	_is_watered_today = false
	_refresh_visual()
	return {"grew": grew, "became_ready": became_ready}

func apply_weather(weather_id: StringName) -> bool:
	if weather_id != GameRules.WEATHER_RAIN or not needs_water():
		return false
	_is_watered_today = true
	_refresh_visual()
	return true

func harvest() -> Dictionary:
	if not is_ready_to_harvest():
		return {"success": false, "message": "作物还没有成熟。"}
	var harvested_item_id := _harvest_item_id
	var harvested_amount := _harvest_amount
	if _regrow_days > 0:
		_growth_days = max(0, _days_to_mature - _regrow_days)
		_is_watered_today = false
	else:
		_clear_crop()
	_refresh_visual()
	return {
		"success": true,
		"message": "收获完成。",
		"item_id": harvested_item_id,
		"quantity": harvested_amount,
	}

func has_crop() -> bool:
	return _crop_id != &""

func is_tilled() -> bool:
	return _is_tilled

func needs_water() -> bool:
	return has_crop() and not is_ready_to_harvest() and not _is_watered_today

func is_ready_to_harvest() -> bool:
	return has_crop() and _growth_days >= _days_to_mature

func get_harvest_item_id() -> StringName:
	return _harvest_item_id

func get_harvest_amount() -> int:
	return _harvest_amount

func to_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"is_tilled": _is_tilled,
		"crop_id": String(_crop_id),
		"harvest_item_id": String(_harvest_item_id),
		"days_to_mature": _days_to_mature,
		"harvest_amount": _harvest_amount,
		"regrow_days": _regrow_days,
		"growth_days": _growth_days,
		"is_watered_today": _is_watered_today,
	}

func restore_snapshot(snapshot: Dictionary) -> bool:
	var version := int(snapshot.get("version", 0))
	if version == LEGACY_SNAPSHOT_VERSION:
		_is_tilled = bool(snapshot.get("is_tilled", false))
		_clear_crop()
		_refresh_visual()
		return true
	if version != SNAPSHOT_VERSION:
		return false

	var crop_id := StringName(str(snapshot.get("crop_id", "")))
	var harvest_item_id := StringName(str(snapshot.get("harvest_item_id", "")))
	var days_to_mature := int(snapshot.get("days_to_mature", 0))
	var harvest_amount := int(snapshot.get("harvest_amount", 0))
	var regrow_days := int(snapshot.get("regrow_days", 0))
	var growth_days := int(snapshot.get("growth_days", 0))
	if crop_id == &"":
		if harvest_item_id != &"" or days_to_mature != 0 or harvest_amount != 0 or regrow_days != 0 or growth_days != 0:
			return false
	else:
		if not bool(snapshot.get("is_tilled", false)):
			return false
		if harvest_item_id == &"" or days_to_mature < 1 or harvest_amount < 1 or regrow_days < 0 or growth_days < 0:
			return false

	_is_tilled = bool(snapshot.get("is_tilled", false))
	_crop_id = crop_id
	_harvest_item_id = harvest_item_id
	_days_to_mature = days_to_mature
	_harvest_amount = harvest_amount
	_regrow_days = regrow_days
	_growth_days = growth_days
	_is_watered_today = bool(snapshot.get("is_watered_today", false))
	_refresh_visual()
	return true

func _clear_crop() -> void:
	_crop_id = &""
	_harvest_item_id = &""
	_days_to_mature = 0
	_harvest_amount = 0
	_regrow_days = 0
	_growth_days = 0
	_is_watered_today = false

func _refresh_visual() -> void:
	if not _is_tilled:
		fill_color = Color("81522d")
	elif not has_crop():
		fill_color = Color("6a4428")
	elif is_ready_to_harvest():
		fill_color = Color("d8d06a")
	elif _is_watered_today:
		fill_color = Color("4d392b")
	else:
		fill_color = Color("5f9d57")
	queue_redraw()
