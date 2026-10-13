class_name CropCatalogTests
extends RefCounted

const SPRING_CROP_CATALOG = preload("res://content/catalogs/spring_crop_catalog.tres")

static func run(test: Variant) -> void:
	var catalog: Variant = SPRING_CROP_CATALOG
	test.expect_equal(catalog.get_crop_count(), 6, "The spring crop catalog contains six first-playable crops")
	var basil: Variant = catalog.get_crop_by_seed_item_id(&"basil_seed")
	test.expect_true(basil != null, "Every configured seed resolves to a crop")
	test.expect_equal(basil.harvest_item_id, &"basil", "The seasoning crop resolves to its configured harvest")
	var strawberry: Variant = catalog.get_crop_by_seed_item_id(&"strawberry_seed")
	test.expect_equal(strawberry.regrow_days, 3, "Strawberries are configured as a repeat-harvest crop")
