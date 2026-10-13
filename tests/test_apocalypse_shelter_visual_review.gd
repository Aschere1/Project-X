class_name ApocalypseShelterVisualReviewTests
extends RefCounted

const SHELTER_SCENE = preload("res://scenes/world/apocalypse_shelter.tscn")
const EXPECTED_HOTSPOTS: Dictionary = {
	"MainHouse": {"id": "main_house", "label": "主屋"},
	"ChickenCoop": {"id": "chicken_coop", "label": "鸡棚 · 日常维护"},
	"LivestockPens": {"id": "livestock_pens", "label": "三联牲畜棚 · 牛、羊、猪"},
	"StorageShed": {"id": "storage", "label": "储物棚"},
	"Workbench": {"id": "workbench", "label": "工作台"},
	"FarmBeds": {"id": "farm_beds", "label": "菜地"},
	"Gate": {"id": "gate", "label": "大门 · 外出"},
}

static func run(test: Variant) -> void:
	var shelter: Node2D = SHELTER_SCENE.instantiate() as Node2D
	test.expect_true(shelter != null, "The apocalypse shelter scene instantiates")
	if shelter == null:
		return

	var hotspots: Control = shelter.get_node("Canvas/MapHotspots") as Control
	var status_bar: PanelContainer = shelter.get_node("Canvas/HUD/BottomStatusBar") as PanelContainer
	var feature_modal: Control = shelter.get_node("Canvas/FeatureModal") as Control
	var campaign_event_modal: Control = shelter.get_node("Canvas/CampaignEventModal") as Control
	var hotspot_label: Label = shelter.get_node("Canvas/HotspotLabel") as Label
	var backpack_button: Button = shelter.get_node("Canvas/HUD/BackpackButton") as Button
	var system_menu: Control = shelter.get_node("Canvas/SystemMenu") as Control
	var warnings_group: HBoxContainer = shelter.get_node("Canvas/HUD/BottomStatusBar/BarInner/Warnings") as HBoxContainer
	var hunger_png_slot: TextureRect = shelter.get_node("Canvas/HUD/BottomStatusBar/BarInner/HungerPngSlot") as TextureRect
	var thirst_png_slot: TextureRect = shelter.get_node("Canvas/HUD/BottomStatusBar/BarInner/ThirstPngSlot") as TextureRect

	test.expect_true(hotspots != null, "The shelter exposes an editable map-hotspot layer")
	test.expect_equal(hotspots.get_child_count(), 7, "The map-hotspot layer has seven direct-entry zones")
	for node_name in EXPECTED_HOTSPOTS:
		var expected: Dictionary = EXPECTED_HOTSPOTS[node_name]
		var hotspot: Button = hotspots.get_node(String(node_name)) as Button
		test.expect_true(hotspot != null, "%s is an authored Button hotspot" % node_name)
		if hotspot == null:
			continue
		test.expect_equal(hotspot.get_meta("zone_id", ""), expected["id"], "%s keeps a stable zone id" % node_name)
		test.expect_equal(hotspot.get_meta("zone_label", ""), expected["label"], "%s keeps its player-facing label" % node_name)
		test.expect_true(hotspot.size.x > 0.0 and hotspot.size.y > 0.0, "%s has an editable clickable rectangle" % node_name)
		var normal_style := hotspot.get_theme_stylebox("normal") as StyleBoxFlat
		var hover_style := hotspot.get_theme_stylebox("hover") as StyleBoxFlat
		var pressed_style := hotspot.get_theme_stylebox("pressed") as StyleBoxFlat
		test.expect_true(normal_style != null and normal_style.bg_color.a == 0.0, "%s stays visually transparent until interaction" % node_name)
		test.expect_true(hover_style != null and hover_style.bg_color.a <= 0.08 and hover_style.border_color.a <= 0.32, "%s uses a restrained low-opacity hover state" % node_name)
		test.expect_true(pressed_style != null and pressed_style.bg_color.a <= 0.15 and pressed_style.border_color.a <= 0.56, "%s keeps the pressed state subtle instead of bright yellow" % node_name)

	test.expect_true(status_bar != null, "The shelter keeps its bottom survival-status bar")
	test.expect_true(feature_modal != null, "The shelter provides one reusable feature-entry modal")
	test.expect_true(not feature_modal.visible, "The feature-entry modal starts hidden")
	test.expect_true(campaign_event_modal != null and not campaign_event_modal.visible, "The dedicated campaign-event modal is authored and starts hidden")
	test.expect_true(hotspot_label != null, "The shelter displays a hover label for the active hotspot")
	test.expect_true(not hotspot_label.visible, "The hotspot label starts hidden")
	test.expect_true(backpack_button != null and backpack_button.text == "背包 [B]", "The shelter exposes a compact B-key backpack entry")
	test.expect_true(system_menu != null and not system_menu.visible, "The compact Esc system menu starts hidden")
	test.expect_equal(hotspot_label.get_theme_font_size("font_size"), 9, "The hotspot label uses the compact map-label size")
	test.expect_true(hotspot_label.get_theme_color("font_color").r < 0.9, "The hotspot label uses a muted map color instead of bright yellow")
	test.expect_true(warnings_group != null, "The status bar retains warning slots")
	test.expect_true(hunger_png_slot != null and not hunger_png_slot.visible, "The hunger art slot remains available for a later UI pass")
	test.expect_true(thirst_png_slot != null and not thirst_png_slot.visible, "The thirst art slot remains available for a later UI pass")

	test.expect_true(not shelter.has_node("Canvas/Collision"), "The static home map no longer carries collision boxes")
	test.expect_true(not shelter.has_node("Canvas/HUD/AvatarMover"), "The map no longer shows a permanent moving player avatar")
	test.expect_true(not shelter.has_node("Canvas/HUD/ZoneIndicators"), "The map no longer relies on proximity indicators")
	test.expect_true(ResourceLoader.exists("res://scenes/world/apocalypse_region_map.tscn"), "The gate keeps its saved county-map destination")
	test.expect_true(ResourceLoader.exists("res://scenes/world/apocalypse_house_interior.tscn"), "The main house keeps its saved static interior destination")
	test.expect_true(ResourceLoader.exists("res://assets/art/apocalypse/characters/survivor_avatar.png"), "The survivor portrait asset is retained for inventory and dialogue UI")
	test.expect_true(ResourceLoader.exists("res://assets/art/apocalypse/shelter/apocalypse_shelter.png"), "The shelter keeps its authored map texture")
	test.expect_true(ResourceLoader.exists("res://assets/art/apocalypse/ui/frames/status_bar.png"), "The shelter keeps its authored bottom status-bar frame")

	var shelter_script_source: String = shelter.get_script().get_source_code() if shelter.get_script() != null else ""
	test.expect_true(shelter_script_source.contains("_route_hotspot"), "The script routes every map click through one hotspot seam")
	test.expect_true(shelter_script_source.contains("HOTSPOT_ZONE_IDS"), "The hotspot router validates stable zone ids")
	test.expect_true(not shelter_script_source.contains("Input.get_vector"), "The shelter no longer reads movement input")
	test.expect_true(not shelter_script_source.contains("CollisionShape2D"), "The shelter no longer derives interaction from collision shapes")
	test.expect_true(not shelter_script_source.contains("_move_avatar"), "The shelter no longer moves an avatar around the map")

	shelter.free()
