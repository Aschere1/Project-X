class_name GameSessionTests
extends RefCounted

const GAME_RULES_SCRIPT = preload("res://src/domain/session/game_rules.gd")
const GAME_SESSION_SCRIPT = preload("res://src/domain/session/game_session.gd")

static func run(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	session.start_new_game(rules)

	test.expect_equal(session.get_day(), 1, "A new normal timeline starts on day 1")
	test.expect_equal(session.get_clock_text(), "06:00", "A new normal timeline starts at 06:00")
	test.expect_equal(session.get_stamina(), 100, "A new normal timeline starts with full stamina")

	advance_minutes_crosses_midnight(test)
	stamina_consumption_never_becomes_negative(test)
	sleep_starts_a_restored_new_day(test)
	snapshot_round_trip_preserves_session_state(test)
	calendar_and_forecast_follow_the_world_seed(test)
	legacy_snapshots_receive_a_safe_weather_state(test)

static func advance_minutes_crosses_midnight(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	session.start_new_game(rules)
	if not session.has_method("advance_minutes"):
		test.expect_true(false, "A game session can advance the normal timeline")
		return
	session.advance_minutes(1_110)

	test.expect_equal(session.get_day(), 2, "Time advances to the next day after midnight")
	test.expect_equal(session.get_clock_text(), "00:30", "Time keeps the correct remainder after midnight")

static func stamina_consumption_never_becomes_negative(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	session.start_new_game(rules)
	if not session.has_method("consume_stamina"):
		test.expect_true(false, "A game session can consume stamina")
		return

	test.expect_equal(session.consume_stamina(125), 100, "Stamina consumption reports the amount actually spent")
	test.expect_equal(session.get_stamina(), 0, "Stamina cannot fall below zero")

static func sleep_starts_a_restored_new_day(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	session.start_new_game(rules)
	session.advance_minutes(240)
	session.consume_stamina(70)
	if not session.has_method("sleep"):
		test.expect_true(false, "A player can sleep to begin the next normal day")
		return

	session.sleep()
	test.expect_equal(session.get_day(), 2, "Sleeping advances the normal timeline by one day")
	test.expect_equal(session.get_clock_text(), "06:00", "Sleeping restores the configured morning start time")
	test.expect_equal(session.get_stamina(), 100, "Sleeping restores full stamina")

static func snapshot_round_trip_preserves_session_state(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var original: Variant = GAME_SESSION_SCRIPT.new()
	original.start_new_game(rules)
	original.advance_minutes(225)
	original.consume_stamina(35)
	if not original.has_method("to_snapshot"):
		test.expect_true(false, "A game session can create a pure data snapshot")
		return

	var restored: Variant = GAME_SESSION_SCRIPT.new()
	if not restored.has_method("restore_snapshot"):
		test.expect_true(false, "A game session can restore from a pure data snapshot")
		return

	restored.restore_snapshot(rules, original.to_snapshot())
	test.expect_equal(restored.get_day(), 1, "A restored snapshot preserves the day")
	test.expect_equal(restored.get_clock_text(), "09:45", "A restored snapshot preserves the time")
	test.expect_equal(restored.get_stamina(), 65, "A restored snapshot preserves the stamina")

static func calendar_and_forecast_follow_the_world_seed(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	session.start_new_game(rules)
	test.expect_equal(session.get_season_name(), "春", "The normal timeline begins in spring")
	test.expect_equal(session.get_day_of_season(), 1, "The normal timeline begins on the first seasonal day")
	test.expect_equal(session.get_weather_text(), "晴", "The starting day's weather is stable for the default world seed")
	test.expect_equal(session.get_forecast_text(), "阴", "Tomorrow's forecast is visible before sleeping")
	session.sleep()
	test.expect_equal(session.get_day_of_season(), 2, "Sleeping advances the seasonal calendar")
	test.expect_equal(session.get_weather_text(), "阴", "Sleeping applies the forecast as the next day's weather")

static func legacy_snapshots_receive_a_safe_weather_state(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = GAME_SESSION_SCRIPT.new()
	var legacy_snapshot := {
		"version": 1,
		"day": 2,
		"minute_of_day": 360,
		"stamina": 80,
	}
	test.expect_true(session.restore_snapshot(rules, legacy_snapshot), "A version-one session snapshot remains loadable")
	test.expect_equal(session.get_weather_text(), "阴", "A legacy snapshot derives stable weather from the default seed")
