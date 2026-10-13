class_name ApocalypseDaySevenEventVisualReviewTests
extends RefCounted

const SHELTER_SCENE = preload("res://scenes/world/apocalypse_shelter.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")


static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The day-seven event uses the shared apocalypse run seam")
	if apocalypse_run == null:
		return
	apocalypse_run.start_new_session()
	var shelter := SHELTER_SCENE.instantiate() as Node2D
	test.expect_true(shelter != null, "The shelter instantiates for the day-seven event path")
	if shelter == null:
		return
	scene_tree.root.add_child(shelter)
	var main_house := shelter.get_node("Canvas/MapHotspots/MainHouse") as Button
	var rest_button := shelter.get_node("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	var feature_close := shelter.get_node("Canvas/FeatureModal/Panel/VBox/CloseButton") as Button
	var event_modal := shelter.get_node("Canvas/CampaignEventModal") as Control
	var event_title := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Title") as Label
	var event_kicker := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Kicker") as Label
	var first_choice := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/PowerChoice") as Button
	var second_choice := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/RooftopChoice") as Button
	var event_result := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Result") as Label
	var event_close := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/CloseButton") as Button
	var campaign_objective := shelter.get_node("Canvas/HUD/CampaignObjective/Objective") as Label
	main_house.pressed.emit()
	rest_button.pressed.emit()
	rest_button.pressed.emit()
	rest_button.pressed.emit()
	feature_close.pressed.emit()
	main_house.pressed.emit()
	rest_button.pressed.emit()
	second_choice.pressed.emit()
	event_close.pressed.emit()
	main_house.pressed.emit()
	rest_button.pressed.emit()
	first_choice.pressed.emit()
	event_close.pressed.emit()
	main_house.pressed.emit()
	rest_button.pressed.emit()
	test.expect_equal(apocalypse_run.get_active_session().get_day(), 7, "The authored shelter flow reaches day seven")
	test.expect_true(event_modal.visible, "The pending day-seven event automatically opens the shared event modal")
	test.expect_equal(event_title.text, "松动的仓储雨棚", "The shared event modal renders the day-seven title")
	test.expect_equal(StringName(first_choice.get_meta("choice_id", "")), &"repair_shelter_tarp", "The first generic event button stores the authored repair choice ID")
	test.expect_equal(StringName(second_choice.get_meta("choice_id", "")), &"move_shelter_supplies", "The second generic event button stores the authored manual choice ID")
	test.expect_true(first_choice.disabled, "The repair choice is disabled when no wire is available")
	test.expect_true(first_choice.text.contains("没有电线"), "The disabled repair choice explains its missing material")
	test.expect_true(second_choice.text.contains("疲劳 +1，压力 +1"), "The manual choice discloses its condition costs before selection")
	second_choice.pressed.emit()
	test.expect_true(event_kicker.text.contains("事件已处理 · 后果已结算"), "The resolved day-seven header no longer describes the event as pending")
	test.expect_true(event_result.visible and event_result.text.contains("疲劳和压力各上升 1 级"), "The shared event result explains the manual relocation costs")
	test.expect_true(campaign_objective.text.contains("第7日事件已处理"), "The shelter objective advances to the resolved day-seven event")
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
	var save_result: Dictionary = repository.load_slot("auto_1")
	test.expect_true(bool(save_result.get("ok", false)), "Resolving the day-seven event writes the shared apocalypse autosave")
	if bool(save_result.get("ok", false)):
		var saved_campaign: Dictionary = save_result["snapshot"]["campaign"]
		test.expect_equal(saved_campaign["day_seven_event_state"], &"resolved", "The autosave preserves the resolved day-seven state")
		test.expect_equal(saved_campaign["day_seven_event_result"]["choice_id"], &"move_shelter_supplies", "The autosave preserves the stable manual choice ID")
	if shelter.get_parent() != null:
		shelter.get_parent().remove_child(shelter)
	shelter.free()
