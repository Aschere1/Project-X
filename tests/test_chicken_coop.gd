class_name ChickenCoopTests
extends RefCounted

const COOP_SCRIPT = preload("res://src/world/chicken_coop.gd")
const CHICKEN: Resource = preload("res://content/animals/starter_chicken.tres")
const ITEM_CATALOG: Resource = preload("res://content/catalogs/starter_item_catalog.tres")

static func run(test: Variant) -> void:
	care_produces_quality_eggs_without_permanent_failure(test)
	coop_snapshots_preserve_daily_care_and_products(test)

static func care_produces_quality_eggs_without_permanent_failure(test: Variant) -> void:
	var coop: Variant = COOP_SCRIPT.new()
	coop.chicken = CHICKEN
	test.expect_true(CHICKEN.is_valid(), "The starter chicken definition is valid")
	test.expect_true(ITEM_CATALOG.get_item(CHICKEN.product_item_id) != null, "The chicken product exists in the item catalog")
	coop.advance_to_day(1)
	test.expect_true(coop.feed(1), "A chicken can be fed once per day")
	test.expect_true(not coop.feed(1), "A chicken cannot consume feed twice on the same day")
	test.expect_true(coop.pet(1), "A chicken can be petted once per day")
	test.expect_equal(coop.advance_to_day(2), 1, "A fed chicken produces one egg on the next day")
	test.expect_equal(coop.peek_next_egg_quality(), 1, "The first cared-for egg has normal quality")
	test.expect_equal(coop.get_care_streak(), 1, "Feeding and petting increase the care streak")

	for day in range(2, 4):
		coop.feed(day)
		coop.pet(day)
		coop.advance_to_day(day + 1)
	coop.take_next_egg_quality()
	coop.take_next_egg_quality()
	test.expect_equal(coop.peek_next_egg_quality(), 2, "Three consecutive full-care days produce a silver egg")
	while coop.has_pending_egg():
		coop.take_next_egg_quality()

	for day in range(4, 8):
		coop.feed(day)
		coop.pet(day)
		coop.advance_to_day(day + 1)
	for _index in range(3):
		coop.take_next_egg_quality()
	test.expect_equal(coop.peek_next_egg_quality(), 3, "Seven consecutive full-care days produce a gold egg")
	while coop.has_pending_egg():
		coop.take_next_egg_quality()

	coop.advance_to_day(9)
	test.expect_equal(coop.get_care_streak(), 0, "A missed feeding resets the care streak without harming the chicken")
	test.expect_equal(coop.get_pending_egg_count(), 0, "An unfed chicken simply skips egg production")
	test.expect_true("雨天安稳待在鸡舍里" in coop.get_status_text(9, &"rain"), "Rain keeps the chicken safely inside without a penalty")
	coop.free()

static func coop_snapshots_preserve_daily_care_and_products(test: Variant) -> void:
	var coop: Variant = COOP_SCRIPT.new()
	coop.chicken = CHICKEN
	coop.advance_to_day(1)
	coop.feed(1)
	coop.pet(1)
	coop.advance_to_day(2)
	coop.feed(2)
	var restored: Variant = COOP_SCRIPT.new()
	restored.chicken = CHICKEN
	test.expect_true(restored.restore_snapshot(coop.to_snapshot()), "A chicken coop restores a valid pure-data snapshot")
	test.expect_true(restored.is_fed_today(2), "Restored chicken care keeps today's feeding state")
	test.expect_equal(restored.get_care_streak(), 1, "Restored chicken care keeps its streak")
	test.expect_equal(restored.get_pending_egg_count(), 1, "Restored chicken care keeps uncollected eggs")
	var invalid_snapshot := {"version": 1, "tracked_day": 2, "care_streak": 1, "pending_egg_qualities": [4]}
	test.expect_true(not restored.restore_snapshot(invalid_snapshot), "A chicken coop rejects invalid egg quality data")
	coop.free()
	restored.free()
