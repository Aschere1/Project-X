class_name GameClockController
extends Node

signal clock_updated(day: int, clock_text: String, stamina: int, maximum_stamina: int)
signal calendar_updated(season_name: String, season_day: int, weather_text: String, forecast_text: String)
signal pause_changed(is_paused: bool)

const ACTION_PAUSE := &"pause"
const MANUAL_PAUSE_SOURCE := &"manual_pause"

@export var rules: GameRules
@export_range(0.1, 10.0, 0.1, "suffix:s") var seconds_per_game_minute := 1.0
@export_range(0.1, 1.0, 0.05) var indoor_time_multiplier := 0.5

var session: GameSession
var _accumulated_minutes := 0.0
var _is_indoor := false
var _pause_sources: Dictionary[StringName, bool] = {}

func _ready() -> void:
	assert(rules != null, "GameClockController requires a rules resource.")
	session = GameSession.new()
	session.start_new_game(rules)
	emit_clock_state()
	print("GAME_CLOCK_READY day=%d time=%s" % [session.get_day(), session.get_clock_text()])

func _process(delta: float) -> void:
	if is_paused():
		return

	var time_multiplier := indoor_time_multiplier if _is_indoor else 1.0
	_accumulated_minutes += delta * time_multiplier / seconds_per_game_minute
	var elapsed_minutes := floori(_accumulated_minutes)
	if elapsed_minutes <= 0:
		return

	_accumulated_minutes -= elapsed_minutes
	session.advance_minutes(elapsed_minutes)
	emit_clock_state()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_PAUSE):
		set_pause_requested(MANUAL_PAUSE_SOURCE, not _pause_sources.has(MANUAL_PAUSE_SOURCE))
		get_viewport().set_input_as_handled()

func set_paused(is_paused: bool) -> void:
	set_pause_requested(MANUAL_PAUSE_SOURCE, is_paused)

func set_pause_requested(source: StringName, should_pause: bool) -> void:
	var was_paused := is_paused()
	if should_pause:
		_pause_sources[source] = true
	else:
		_pause_sources.erase(source)
	if was_paused != is_paused():
		pause_changed.emit(is_paused())

func set_indoor(is_indoor: bool) -> void:
	_is_indoor = is_indoor

func is_paused() -> bool:
	return not _pause_sources.is_empty()

func reset_time_accumulator() -> void:
	_accumulated_minutes = 0.0

func emit_clock_state() -> void:
	clock_updated.emit(
		session.get_day(),
		session.get_clock_text(),
		session.get_stamina(),
		rules.maximum_stamina,
	)
	calendar_updated.emit(
		session.get_season_name(),
		session.get_day_of_season(),
		session.get_weather_text(),
		session.get_forecast_text(),
	)
