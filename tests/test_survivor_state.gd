class_name SurvivorStateTests
extends RefCounted

const SURVIVOR_STATE_SCRIPT = preload("res://src/domain/apocalypse/survivor_state.gd")

static func run(test: Variant) -> void:
	var survivor: Variant = SURVIVOR_STATE_SCRIPT.new()
	survivor.start_new_game({"fitness": 1, "knowledge": -1})

	test.expect_equal(survivor.get_attribute(&"fitness"), 1, "A background can provide a fitness modifier")
	test.expect_equal(survivor.get_attribute(&"knowledge"), -1, "A background can provide a knowledge weakness")
	test.expect_equal(survivor.get_attribute(&"observation"), 0, "Unspecified attributes start at zero")
	test.expect_equal(survivor.get_health(), 100, "A new survivor starts at full health")
	test.expect_equal(survivor.get_condition_level(&"hunger"), 0, "A new survivor starts without hunger pressure")

	test.expect_equal(survivor.change_condition(&"hunger", 2), 2, "Condition changes return the resulting tier")
	test.expect_equal(survivor.change_condition(&"hunger", 5), 3, "Condition tiers are capped at critical")
	test.expect_equal(survivor.change_condition(&"hunger", -2), 1, "Condition pressure can be reduced")

	test.expect_equal(survivor.apply_damage(35), 35, "Damage reports the amount applied")
	test.expect_equal(survivor.get_health(), 65, "Damage reduces health")
	test.expect_equal(survivor.heal(10), 10, "Healing reports the amount restored")
	test.expect_equal(survivor.get_health(), 75, "Healing restores health without exceeding the maximum")

	test.expect_true(survivor.add_injury(&"bleeding"), "A new injury is recorded")
	test.expect_true(not survivor.add_injury(&"bleeding"), "The same injury is not duplicated")
	test.expect_true(survivor.has_injury(&"bleeding"), "Recorded injuries are queryable")

	test.expect_equal(survivor.add_infection_risk(25), 25, "Infection risk accumulates internally")
	test.expect_equal(survivor.get_infection_hint(), "可能暴露", "The player receives a broad infection hint")
	test.expect_equal(survivor.add_infection_risk(35), 60, "Additional exposure advances hidden infection progress")
	test.expect_equal(survivor.get_infection_hint(), "出现异常症状", "Symptoms become more explicit as infection progresses")

	var restored: Variant = SURVIVOR_STATE_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(survivor.to_snapshot()), "Survivor state restores from a pure snapshot")
	test.expect_equal(restored.get_health(), 75, "Restored state keeps health")
	test.expect_equal(restored.get_attribute(&"fitness"), 1, "Restored state keeps attributes")
	test.expect_true(restored.has_injury(&"bleeding"), "Restored state keeps injuries")
	test.expect_equal(restored.get_infection_hint(), "出现异常症状", "Restored state keeps the observable infection hint")
