class_name ApocalypseHouseInteriorVisualReviewTests
extends RefCounted

const HOUSE_INTERIOR_SCENE = preload("res://scenes/world/apocalypse_house_interior.tscn")

const EXPECTED_HOTSPOTS: Dictionary = {
	"Bed": "bed",
	"MedicalCorner": "medical_corner",
	"IndoorWorkbench": "indoor_workbench",
	"EmergencyPower": "emergency_power",
	"Exit": "exit",
}


static func run(test: Variant) -> void:
	var house := HOUSE_INTERIOR_SCENE.instantiate() as Control
	test.expect_true(house != null, "The static apocalypse house interior instantiates")
	if house == null:
		return
	var illustration := house.get_node("InteriorIllustration") as TextureRect
	var hotspots := house.get_node("MapHotspots") as Control
	var status_panel := house.get_node("HUD/StatusPanel") as PanelContainer
	test.expect_true(illustration != null and illustration.texture != null, "The house interior uses its authored local illustration")
	test.expect_true(hotspots != null, "The house interior keeps an editable hotspot layer")
	if hotspots != null:
		test.expect_equal(hotspots.get_child_count(), 5, "The house interior exposes five saved facility hotspots")
		for node_name in EXPECTED_HOTSPOTS:
			var hotspot := hotspots.get_node(String(node_name)) as Button
			test.expect_true(hotspot != null, "%s is an authored interior hotspot" % node_name)
			if hotspot != null:
				test.expect_equal(hotspot.get_meta("zone_id", ""), EXPECTED_HOTSPOTS[node_name], "%s keeps a stable interior zone id" % node_name)
				test.expect_true(hotspot.size.x > 0.0 and hotspot.size.y > 0.0, "%s keeps an editable click rectangle" % node_name)
	test.expect_true(status_panel != null, "The interior has a saved status panel instead of generated overlay UI")
	test.expect_true(house.get_node_or_null("GlobalOverlay") != null, "The interior reuses the shared backpack and system-menu overlay")
	test.expect_true(not house.has_node("AvatarMover"), "The interior remains a static clickable presentation without a persistent avatar")
	house.free()
