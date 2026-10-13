extends SceneTree

# Public apocalypse regression: no private art or archived farm presentation.
# The original test_runner.gd remains the full local regression entry point.
const TestHarness = preload("res://tests/test_harness.gd")
const SUITES: Array[Script] = [
	preload("res://tests/test_game_session.gd"),
	preload("res://tests/test_save_repository.gd"),
	preload("res://tests/test_inventory.gd"),
	preload("res://tests/test_d20_check.gd"),
	preload("res://tests/test_survivor_state.gd"),
	preload("res://tests/test_grid_container.gd"),
	preload("res://tests/test_apocalypse_session.gd"),
	preload("res://tests/test_apocalypse_shelter_facilities.gd"),
	preload("res://tests/test_apocalypse_run.gd"),
	preload("res://tests/test_apocalypse_entry.gd"),
	preload("res://tests/test_search_container.gd"),
	preload("res://tests/test_apocalypse_storage_visual_review.gd"),
	preload("res://tests/test_apocalypse_region_map_visual_review.gd"),
	preload("res://tests/test_apocalypse_market_visual_review.gd"),
	preload("res://tests/test_apocalypse_warehouse_visual_review.gd"),
	preload("res://tests/test_apocalypse_explore_visual_review.gd"),
	preload("res://tests/test_apocalypse_day_five_event_visual_review.gd"),
	preload("res://tests/test_apocalypse_day_six_event_visual_review.gd"),
	preload("res://tests/test_apocalypse_day_seven_event_visual_review.gd"),
	preload("res://tests/test_apocalypse_house_interior_visual_review.gd"),
	preload("res://tests/test_apocalypse_shelter_visual_review.gd"),
]


func _init() -> void:
	call_deferred(&"_run_tests")


func _run_tests() -> void:
	var test := TestHarness.new()
	for suite in SUITES:
		suite.run(test)
	if test.failures.is_empty():
		print("PUBLIC_REVIEW_TESTS_PASSED suites=%d assertions=%d" % [SUITES.size(), test.assertion_count])
		print("TESTS_PASSED assertions=%d" % test.assertion_count)
		quit(0)
		return
	for failure in test.failures:
		push_error("TEST_FAILED: %s" % failure)
	print("TESTS_FAILED count=%d" % test.failures.size())
	quit(1)
