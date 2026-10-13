class_name ApocalypseEntryTests
extends RefCounted

const APOCALYPSE_RUN_SCRIPT = preload("res://src/app/apocalypse_run.gd")
const START_SCENE = preload("res://scenes/startup/apocalypse_start.tscn")

static func run(test: Variant) -> void:
	var save_root := "user://apocalypse_entry_tests_%d" % Time.get_ticks_usec()
	var run: Variant = APOCALYPSE_RUN_SCRIPT.new(save_root)
	var missing_summary: Dictionary = run.get_continue_summary()
	test.expect_true(not bool(missing_summary.get("available", false)), "The entry seam disables continue when no autosave exists")
	test.expect_equal(missing_summary.get("source"), &"new_game", "A missing autosave reports a new-game source")
	var new_game_result: Dictionary = run.start_new_session_and_save()
	test.expect_true(bool(new_game_result.get("ok", false)), "Confirming a new game writes the shared autosave")
	var saved_summary: Dictionary = run.get_continue_summary()
	test.expect_true(bool(saved_summary.get("available", false)), "A saved new game becomes available to continue")
	test.expect_equal(saved_summary.get("day"), 1, "A new-game entry summary starts on day one")
	test.expect_equal(saved_summary.get("clock_text"), "06:00", "A new-game entry summary keeps the baseline clock")
	var restored_run: Variant = APOCALYPSE_RUN_SCRIPT.new(save_root)
	var continued_session: Variant = restored_run.continue_session()
	test.expect_equal(continued_session.get_day(), 1, "Continue restores the saved first day")
	test.expect_equal(restored_run.get_restore_status().get("source"), &"auto_save", "Continue marks the restored source explicitly")

	var entry: Control = START_SCENE.instantiate() as Control
	test.expect_true(entry != null, "The new-game/continue entry scene instantiates")
	if entry == null:
		return
	var continue_button: Button = entry.get_node("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	var new_game_button: Button = entry.get_node("Margin/Panel/VBox/Buttons/NewGameButton") as Button
	var confirmation: Control = entry.get_node("Margin/Panel/VBox/NewGameConfirmation") as Control
	test.expect_true(continue_button != null and new_game_button != null, "The entry scene exposes separate continue and new-game actions")
	test.expect_true(confirmation != null and not confirmation.visible, "The overwrite confirmation starts hidden in the authored scene")
	if continue_button != null and new_game_button != null:
		test.expect_equal(continue_button.text, "继续游戏", "Continue keeps the player-facing action text")
		test.expect_equal(new_game_button.text, "开始新游戏", "New game keeps the player-facing action text")
		test.expect_equal(continue_button.get_theme_font_size("font_size"), 8, "The entry buttons use the compact apocalypse UI font size")
	entry.free()
	run.free()
	restored_run.free()
