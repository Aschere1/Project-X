class_name D20CheckTests
extends RefCounted

const D20_CHECK_SCRIPT = preload("res://src/domain/apocalypse/d20_check.gd")

static func run(test: Variant) -> void:
	var check: Variant = D20_CHECK_SCRIPT.new()

	var natural_one: Dictionary = check.resolve(1, 7, 12)
	test.expect_equal(natural_one["outcome_id"], &"major_failure", "Natural one is always a major failure")
	test.expect_true(not natural_one["is_success"], "Natural one cannot succeed through modifiers")

	var natural_twenty: Dictionary = check.resolve(20, 19, -4)
	test.expect_equal(natural_twenty["outcome_id"], &"major_success", "Natural twenty is always a major success")
	test.expect_true(natural_twenty["is_success"], "Natural twenty always succeeds")

	var failure_forward: Dictionary = check.resolve(10, 11)
	test.expect_equal(failure_forward["outcome_id"], &"failure_forward", "A near miss advances the situation with a cost")
	test.expect_true(not failure_forward["is_success"], "Failure forward is not a clean success")

	var costly_success: Dictionary = check.resolve(11, 11)
	test.expect_equal(costly_success["outcome_id"], &"costly_success", "Meeting the difficulty exactly is a costly success")
	test.expect_true(costly_success["is_success"], "Costly success completes the attempted action")

	var success: Dictionary = check.resolve(13, 11)
	test.expect_equal(success["outcome_id"], &"success", "Beating the difficulty is a normal success")

	var major_success: Dictionary = check.resolve(16, 11)
	test.expect_equal(major_success["outcome_id"], &"major_success", "Beating the difficulty by five is a major success")
	test.expect_equal(major_success["total"], 16, "The result exposes the public total for UI and logs")
