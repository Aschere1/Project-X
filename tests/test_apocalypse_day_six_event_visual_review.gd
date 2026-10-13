class_name ApocalypseDaySixEventVisualReviewTests
extends RefCounted

const SHELTER_SCENE = preload("res://scenes/world/apocalypse_shelter.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")


static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The day-six event uses the shared apocalypse run seam")
	if apocalypse_run == null:
		return
	apocalypse_run.start_new_session()
	var shelter := SHELTER_SCENE.instantiate() as Node2D
	test.expect_true(shelter != null, "The shelter instantiates for the day-six event path")
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
	test.expect_equal(apocalypse_run.get_active_session().get_day(), 6, "The authored shelter flow reaches day six")
	test.expect_true(event_modal.visible, "The pending day-six event automatically opens the shared event modal")
	test.expect_equal(event_title.text, "屋檐外的悬包", "The shared event modal renders the day-six title")
	test.expect_equal(StringName(first_choice.get_meta("choice_id", "")), &"recover_hanging_pack", "The first generic event button stores the authored recovery choice ID")
	test.expect_equal(StringName(second_choice.get_meta("choice_id", "")), &"abandon_hanging_pack", "The second generic event button stores the authored abandonment choice ID")
	test.expect_true(first_choice.text.contains("饮用水 ×2"), "The recovery button discloses its inventory reward before selection")
	test.expect_true(first_choice.text.contains("疲劳 +1，压力 +1"), "The recovery button discloses its condition costs before selection")
	test.expect_true(second_choice.text.contains("不获得物资"), "The safe button discloses that the hanging-pack supplies will be lost")
	var water_before: int = apocalypse_run.get_active_session().get_container_item_quantity(&"home_storage", &"water")
	first_choice.pressed.emit()
	test.expect_true(event_kicker.text.contains("事件已处理 · 后果已结算"), "The resolved event header no longer describes the event as pending")
	test.expect_true(event_result.visible and event_result.text.contains("家园仓储获得饮用水 ×2"), "The shared event result explains the recovered supplies")
	test.expect_true(campaign_objective.text.contains("第6日事件已处理"), "The shelter objective advances to the resolved day-six event")
	test.expect_equal(apocalypse_run.get_active_session().get_container_item_quantity(&"home_storage", &"water"), water_before + 2, "The visual day-six path writes its reward to shared home storage")
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
	var save_result: Dictionary = repository.load_slot("auto_1")
	test.expect_true(bool(save_result.get("ok", false)), "Resolving the day-six event writes the shared apocalypse autosave")
	if bool(save_result.get("ok", false)):
		var saved_campaign: Dictionary = save_result["snapshot"]["campaign"]
		test.expect_equal(saved_campaign["day_six_event_state"], &"resolved", "The autosave preserves the resolved day-six state")
		test.expect_equal(saved_campaign["day_six_event_result"]["choice_id"], &"recover_hanging_pack", "The autosave preserves the stable recovery choice ID")
	if shelter.get_parent() != null:
		shelter.get_parent().remove_child(shelter)
	shelter.free()
