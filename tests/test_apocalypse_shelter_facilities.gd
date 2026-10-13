class_name ApocalypseShelterFacilitiesTests
extends RefCounted

const GAME_RULES_SCRIPT = preload("res://src/domain/session/game_rules.gd")
const APOCALYPSE_SESSION_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_session.gd")


static func run(test: Variant) -> void:
	var rules := GAME_RULES_SCRIPT.new()
	var session: Variant = APOCALYPSE_SESSION_SCRIPT.new()
	session.start_new_game(rules)

	var chicken_coop: Dictionary = session.get_shelter_facility_snapshot(&"chicken_coop")
	test.expect_equal(chicken_coop.get("facility_id", &""), &"chicken_coop", "The chicken coop exposes a stable facility ID")
	test.expect_equal(chicken_coop.get("status", &""), &"needs_service", "A new chicken coop begins awaiting its daily maintenance")
	var chicken_actions: Array = chicken_coop.get("actions", [])
	test.expect_equal(chicken_actions.size(), 1, "The chicken coop exposes one focused daily maintenance action")
	test.expect_true(bool(chicken_actions[0].get("available", false)), "Chicken-coop maintenance is available at the start of the day")
	var chicken_service: Dictionary = session.perform_shelter_facility_action(&"chicken_coop", &"service")
	test.expect_true(bool(chicken_service.get("ok", false)), "Servicing the chicken coop succeeds through the shared session interface")
	test.expect_equal(session.get_clock_text(), "06:10", "Chicken-coop maintenance consumes its documented ten minutes")
	test.expect_equal(session.get_stamina(), 99, "Chicken-coop maintenance consumes one stamina")
	test.expect_equal(session.get_shelter_facility_snapshot(&"chicken_coop").get("status", &""), &"serviced_today", "Servicing updates the persistent chicken-coop status")
	var repeated_chicken_service: Dictionary = session.perform_shelter_facility_action(&"chicken_coop", &"service")
	test.expect_true(not bool(repeated_chicken_service.get("ok", true)), "The chicken coop cannot be serviced twice on one day")
	test.expect_equal(session.get_clock_text(), "06:10", "Rejected repeat maintenance does not advance time")

	var livestock: Dictionary = session.get_shelter_facility_snapshot(&"livestock_pens")
	test.expect_equal(livestock.get("facility_id", &""), &"livestock_pens", "The shared livestock shed exposes a stable facility ID")
	var livestock_animals: Array = livestock.get("animals", [])
	test.expect_equal(livestock_animals.size(), 3, "The shared livestock shed lists cattle, sheep, and pigs without three duplicate systems")
	var livestock_service: Dictionary = session.perform_shelter_facility_action(&"livestock_pens", &"service")
	test.expect_true(bool(livestock_service.get("ok", false)), "Servicing the shared livestock shed succeeds")
	test.expect_equal(session.get_clock_text(), "06:25", "Livestock-shed maintenance consumes its documented fifteen minutes")
	test.expect_equal(session.get_stamina(), 98, "Livestock-shed maintenance consumes one stamina")

	session.sleep()
	test.expect_equal(session.get_day(), 2, "Sleeping advances the shared facility calendar")
	test.expect_equal(session.get_shelter_facility_snapshot(&"chicken_coop").get("status", &""), &"needs_service", "The chicken coop is available for the next day's maintenance")
	var restored: Variant = APOCALYPSE_SESSION_SCRIPT.new()
	test.expect_true(restored.restore_snapshot(rules, session.to_snapshot()), "Shelter facility state survives an apocalypse session snapshot")
	test.expect_equal(restored.get_shelter_facility_snapshot(&"livestock_pens").get("last_service_day", -1), 1, "The restored livestock shed preserves its last completed maintenance day")

	var legacy_snapshot: Dictionary = session.to_snapshot()
	legacy_snapshot.erase("shelter_facilities")
	var legacy_restored: Variant = APOCALYPSE_SESSION_SCRIPT.new()
	test.expect_true(legacy_restored.restore_snapshot(rules, legacy_snapshot), "A pre-facilities apocalypse snapshot remains restore-compatible")
	test.expect_equal(legacy_restored.get_shelter_facility_snapshot(&"chicken_coop").get("status", &""), &"needs_service", "A legacy snapshot initializes the chicken coop as not yet serviced today")
