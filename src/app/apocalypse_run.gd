extends Node

const GAME_RULES_SCRIPT = preload("res://src/domain/session/game_rules.gd")
const APOCALYPSE_SESSION_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_session.gd")
const TIMELINE_SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")

const DEFAULT_SAVE_ROOT := "user://saves/apocalypse_review"
const AUTOSAVE_SLOT := "auto_1"

var _active_session: Variant
var _save_repository: Variant
var _restore_status: Dictionary = {}

func _init(save_root: String = DEFAULT_SAVE_ROOT) -> void:
	_save_repository = TIMELINE_SAVE_REPOSITORY_SCRIPT.new(save_root, "apocalypse")

func ensure_active_session() -> ApocalypseSession:
	if _active_session == null:
		_active_session = _restore_or_start_new_session()
		print("APOCALYPSE_RUN_READY source=%s backup=%s" % [
			String(_restore_status.get("source", "unknown")),
			str(bool(_restore_status.get("used_backup", false))),
		])
	return _active_session

func get_active_session() -> ApocalypseSession:
	return ensure_active_session()

func replace_active_session(session: ApocalypseSession) -> void:
	assert(session != null, "An active apocalypse run requires a session.")
	_active_session = session
	_restore_status = {"source": &"replaced", "message": "当前会话已替换。"}

func reset_active_session() -> void:
	_active_session = null
	_restore_status = {}

func start_new_session() -> ApocalypseSession:
	var new_session: Variant = APOCALYPSE_SESSION_SCRIPT.new()
	new_session.start_new_game(GAME_RULES_SCRIPT.new(), {"observation": 1})
	_active_session = new_session
	_restore_status = {"source": &"new_game", "message": "已开始新的一局。"}
	return _active_session

func continue_session() -> ApocalypseSession:
	return ensure_active_session()

func start_new_session_and_save() -> Dictionary:
	var session := start_new_session()
	var save_result: Dictionary = _save_repository.save_slot(AUTOSAVE_SLOT, session.to_snapshot())
	save_result["session"] = session
	if bool(save_result.get("ok", false)):
		save_result["message"] = "已开始新的一局，自动存档已更新。"
	return save_result

func get_continue_summary() -> Dictionary:
	var load_result: Dictionary = _save_repository.load_slot(AUTOSAVE_SLOT)
	if not bool(load_result.get("ok", false)):
		return {
			"available": false,
			"source": &"new_game",
			"used_backup": false,
			"message": "没有可继续的自动存档，请开始新游戏。",
		}
	var candidate: Variant = APOCALYPSE_SESSION_SCRIPT.new()
	var snapshot: Dictionary = load_result.get("snapshot", {})
	if not candidate.restore_snapshot(GAME_RULES_SCRIPT.new(), snapshot):
		return {
			"available": false,
			"source": &"new_game",
			"used_backup": false,
			"message": "自动存档无法恢复，请开始新游戏。",
		}
	return {
		"available": true,
		"source": &"auto_save",
		"used_backup": bool(load_result.get("used_backup", false)),
		"day": candidate.get_day(),
		"clock_text": candidate.get_clock_text(),
		"weather_id": candidate.get_weather_id(),
		"campaign": candidate.get_campaign_snapshot(),
		"message": "已发现自动存档：第 %d 日 %s" % [candidate.get_day(), candidate.get_clock_text()],
	}

func save_active_session() -> Dictionary:
	return _save_repository.save_slot(AUTOSAVE_SLOT, ensure_active_session().to_snapshot())

func get_restore_status() -> Dictionary:
	return _restore_status.duplicate(true)

func _restore_or_start_new_session() -> ApocalypseSession:
	var load_result: Dictionary = _save_repository.load_slot(AUTOSAVE_SLOT)
	if bool(load_result.get("ok", false)):
		var restored_session: Variant = APOCALYPSE_SESSION_SCRIPT.new()
		var snapshot: Dictionary = load_result.get("snapshot", {})
		if restored_session.restore_snapshot(GAME_RULES_SCRIPT.new(), snapshot):
			_restore_status = {
				"source": &"auto_save",
				"used_backup": bool(load_result.get("used_backup", false)),
				"message": "已恢复最近一次外出自动存档。",
			}
			return restored_session
	_restore_status = {
		"source": &"new_game",
		"message": "没有可恢复的自动存档，已开始新的一局。",
	}
	return start_new_session()
