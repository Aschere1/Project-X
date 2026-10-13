class_name ChickenCoop
extends GridInteractable

const SNAPSHOT_VERSION := 1

@export var chicken: ChickenDefinition
var _tracked_day := 0
var _fed_today := false
var _petted_today := false
var _care_streak := 0
var _pending_egg_qualities: Array[int] = []

func _ready() -> void:
	super._ready()
	assert(chicken != null and chicken.is_valid(), "ChickenCoop requires a valid ChickenDefinition.")

func advance_to_day(target_day: int) -> int:
	assert(target_day >= 1, "Chicken care requires a valid calendar day.")
	if _tracked_day == 0:
		_tracked_day = target_day
		_refresh_visual()
		return 0
	if target_day <= _tracked_day:
		return 0
	var produced_eggs := 0
	while _tracked_day < target_day:
		if _fed_today:
			_care_streak = _care_streak + 1 if _petted_today else 0
			_pending_egg_qualities.append(chicken.get_product_quality(_care_streak))
			produced_eggs += 1
		else:
			_care_streak = 0
		_tracked_day += 1
		_fed_today = false
		_petted_today = false
	_refresh_visual()
	return produced_eggs

func feed(total_day: int) -> bool:
	advance_to_day(total_day)
	if _fed_today:
		return false
	_fed_today = true
	_refresh_visual()
	return true

func pet(total_day: int) -> bool:
	advance_to_day(total_day)
	if _petted_today:
		return false
	_petted_today = true
	_refresh_visual()
	return true

func has_pending_egg() -> bool:
	return not _pending_egg_qualities.is_empty()

func peek_next_egg_quality() -> int:
	return _pending_egg_qualities[0] if has_pending_egg() else 0

func take_next_egg_quality() -> int:
	if not has_pending_egg():
		return 0
	var quality: int = int(_pending_egg_qualities.pop_front())
	_refresh_visual()
	return quality

func is_fed_today(total_day: int) -> bool:
	advance_to_day(total_day)
	return _fed_today

func is_petted_today(total_day: int) -> bool:
	advance_to_day(total_day)
	return _petted_today

func get_care_streak() -> int:
	return _care_streak

func get_pending_egg_count() -> int:
	return _pending_egg_qualities.size()

func get_status_text(total_day: int, weather_id: StringName) -> String:
	advance_to_day(total_day)
	var weather_text := "雨天安稳待在鸡舍里。" if weather_id == GameRules.WEATHER_RAIN else "正在鸡舍附近悠闲活动。"
	return "%s：%s 今日喂食%s，抚摸%s；连续照料 %d 天，待收鸡蛋 %d 枚。" % [chicken.display_name, weather_text, "完成" if _fed_today else "未完成", "完成" if _petted_today else "未完成", _care_streak, _pending_egg_qualities.size()]

func refresh_for_day(total_day: int) -> void:
	advance_to_day(total_day)
	_refresh_visual()

func to_snapshot() -> Dictionary:
	return {"version": SNAPSHOT_VERSION, "tracked_day": _tracked_day, "fed_today": _fed_today, "petted_today": _petted_today, "care_streak": _care_streak, "pending_egg_qualities": _pending_egg_qualities.duplicate()}

func restore_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != SNAPSHOT_VERSION:
		return false
	var tracked_day := int(snapshot.get("tracked_day", -1))
	var care_streak := int(snapshot.get("care_streak", -1))
	var egg_values: Variant = snapshot.get("pending_egg_qualities", [])
	if tracked_day < 0 or care_streak < 0 or not egg_values is Array:
		return false
	var restored_qualities: Array[int] = []
	for value in egg_values:
		var quality := int(value)
		if quality < 1 or quality > 3:
			return false
		restored_qualities.append(quality)
	_tracked_day = tracked_day
	_fed_today = bool(snapshot.get("fed_today", false))
	_petted_today = bool(snapshot.get("petted_today", false))
	_care_streak = care_streak
	_pending_egg_qualities = restored_qualities
	_refresh_visual()
	return true

func _refresh_visual() -> void:
	if has_pending_egg():
		fill_color = Color("f2d16b")
	elif not _fed_today:
		fill_color = Color("b56d3f")
	elif not _petted_today:
		fill_color = Color("8aaa57")
	else:
		fill_color = Color("6fa0a3")
	queue_redraw()

func set_visual_suppressed(is_suppressed: bool) -> void:
	super.set_visual_suppressed(is_suppressed)
	for visual_name in [&"Wall", &"Door", &"Roof"]:
		var visual := get_node_or_null(NodePath(visual_name)) as CanvasItem
		if visual != null:
			visual.visible = not is_suppressed
