class_name SaveRepositoryTests
extends RefCounted

const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")

static func run(test: Variant) -> void:
	save_and_load_round_trip(test)
	load_falls_back_to_the_last_good_backup(test)
	three_manual_slots_remain_independent(test)
	disaster_timeline_uses_an_independent_kind(test)

static func save_and_load_round_trip(test: Variant) -> void:
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://project_x_save_tests")
	if not repository.has_method("save_slot"):
		test.expect_true(false, "A timeline repository can save a named slot")
		return
	var snapshot := {
		"game_session": {
			"version": 1,
			"day": 3,
			"minute_of_day": 585,
			"stamina": 72,
		},
		"world": {
			"player_position": {"x": 248.0, "y": 164.0},
		},
	}

	var save_result: Variant = repository.save_slot("slot_1", snapshot)
	test.expect_true(save_result.get("ok", false), "A normal timeline snapshot saves to a manual slot")
	if not repository.has_method("load_slot"):
		test.expect_true(false, "A timeline repository can load a named slot")
		return

	var load_result: Variant = repository.load_slot("slot_1")
	test.expect_true(load_result.get("ok", false), "A saved manual slot can be loaded")
	var loaded_snapshot: Dictionary = load_result.get("snapshot", {})
	var loaded_session: Dictionary = loaded_snapshot.get("game_session", {})
	var loaded_world: Dictionary = loaded_snapshot.get("world", {})
	var loaded_position: Dictionary = loaded_world.get("player_position", {})
	test.expect_equal(loaded_session.get("day"), 3.0, "A loaded manual slot preserves the saved day")
	test.expect_equal(loaded_session.get("minute_of_day"), 585.0, "A loaded manual slot preserves the saved time")
	test.expect_equal(loaded_session.get("stamina"), 72.0, "A loaded manual slot preserves the saved stamina")
	test.expect_equal(loaded_position.get("x"), 248.0, "A loaded manual slot preserves the player x position")
	test.expect_equal(loaded_position.get("y"), 164.0, "A loaded manual slot preserves the player y position")

static func load_falls_back_to_the_last_good_backup(test: Variant) -> void:
	var root_path := "user://project_x_save_tests"
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new(root_path)
	var first_snapshot := {"revision": "first"}
	var second_snapshot := {"revision": "second"}

	test.expect_true(repository.save_slot("slot_2", first_snapshot).get("ok", false), "The initial save establishes a primary file")
	test.expect_true(repository.save_slot("slot_2", second_snapshot).get("ok", false), "The next save preserves the previous primary as a backup")

	var corrupt_primary := FileAccess.open(root_path.path_join("slot_2.json"), FileAccess.WRITE)
	corrupt_primary.store_string("{")
	corrupt_primary.close()

	var recovered_result: Variant = repository.load_slot("slot_2")
	test.expect_true(recovered_result.get("ok", false), "A corrupt primary save falls back to a valid backup")
	test.expect_true(recovered_result.get("used_backup", false), "Backup recovery reports that the backup was used")
	var recovered_snapshot: Dictionary = recovered_result.get("snapshot", {})
	test.expect_equal(recovered_snapshot.get("revision"), "first", "Backup recovery returns the last complete snapshot")

static func three_manual_slots_remain_independent(test: Variant) -> void:
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://project_x_save_tests")
	for slot_index in range(3):
		var slot_name := "slot_%d" % (slot_index + 1)
		var snapshot := {"revision": "manual_%d" % (slot_index + 1)}
		test.expect_true(
			repository.save_slot(slot_name, snapshot).get("ok", false),
			"Manual slot %d saves independently" % (slot_index + 1),
		)

	for slot_index in range(3):
		var slot_name := "slot_%d" % (slot_index + 1)
		var load_result: Dictionary = repository.load_slot(slot_name)
		var snapshot: Dictionary = load_result.get("snapshot", {})
		test.expect_true(load_result.get("ok", false), "Manual slot %d remains readable" % (slot_index + 1))
		test.expect_equal(
			snapshot.get("revision"),
			"manual_%d" % (slot_index + 1),
			"Manual slot %d keeps its own state" % (slot_index + 1),
		)

static func disaster_timeline_uses_an_independent_kind(test: Variant) -> void:
	var root_path := "user://project_x_disaster_save_tests"
	var apocalypse_repository: Variant = SAVE_REPOSITORY_SCRIPT.new(root_path, "apocalypse")
	var snapshot := {"timeline": "apocalypse", "day": 2}
	test.expect_true(
		apocalypse_repository.save_slot("slot_1", snapshot).get("ok", false),
		"An apocalypse timeline can save to its own repository root",
	)
	var apocalypse_load: Dictionary = apocalypse_repository.load_slot("slot_1")
	test.expect_true(apocalypse_load.get("ok", false), "An apocalypse timeline can load its own save")
	test.expect_equal(apocalypse_load.get("snapshot", {}).get("timeline"), "apocalypse", "Apocalypse saves preserve their payload")

	var normal_reader: Variant = SAVE_REPOSITORY_SCRIPT.new(root_path, "normal")
	test.expect_true(
		not normal_reader.load_slot("slot_1").get("ok", false),
		"A normal timeline reader rejects an apocalypse save even at the same path",
	)
