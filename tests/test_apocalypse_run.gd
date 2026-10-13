class_name ApocalypseRunTests
extends RefCounted

const APOCALYPSE_RUN_SCRIPT = preload("res://src/app/apocalypse_run.gd")

static func run(test: Variant) -> void:
	var save_root := "user://apocalypse_run_tests_%d" % Time.get_ticks_usec()
	var run: Variant = APOCALYPSE_RUN_SCRIPT.new(save_root)
	var first_session: Variant = run.ensure_active_session()
	var first_status: Dictionary = run.get_restore_status()
	test.expect_equal(first_status.get("source"), &"new_game", "A run starts a new session when its autosave is absent")
	test.expect_equal(first_session.get_clock_text(), "06:00", "A new run starts at the apocalypse baseline time")
	test.expect_true(first_session.place_item_in_container(&"backpack", &"water_1", &"water", 1, 1, 5), "The active run session accepts carried items before saving")
	test.expect_true(first_session.transfer_item(&"backpack", &"home_storage", &"water_1"), "The active run session can store a carried item at home before saving")
	test.expect_true(first_session.spend_action(12, 3), "The active run session advances before saving")
	var save_result: Dictionary = run.save_active_session()
	test.expect_true(bool(save_result.get("ok", false)), "An active run writes the shared apocalypse autosave")

	run.reset_active_session()
	var restored_session: Variant = run.ensure_active_session()
	var restored_status: Dictionary = run.get_restore_status()
	test.expect_equal(restored_status.get("source"), &"auto_save", "A later run restores its valid autosave")
	test.expect_equal(restored_session.get_clock_text(), "06:12", "Autosave restoration keeps the shared apocalypse clock")
	test.expect_equal(restored_session.get_container_total_weight(&"backpack"), 0, "Autosave restoration keeps the backpack empty after home storage transfer")
	test.expect_equal(restored_session.get_container_total_weight(&"home_storage"), 5, "Autosave restoration keeps the stored home item")
	run.free()
