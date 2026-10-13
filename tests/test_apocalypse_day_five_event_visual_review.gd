class_name ApocalypseDayFiveEventVisualReviewTests
extends RefCounted

const SHELTER_SCENE = preload("res://scenes/world/apocalypse_shelter.tscn")
const SAVE_REPOSITORY_SCRIPT = preload("res://src/adapters/persistence/timeline_save_repository.gd")


static func run(test: Variant) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var apocalypse_run := scene_tree.root.get_node_or_null("ApocalypseRun")
	test.expect_true(apocalypse_run != null, "The day-five event uses the shared apocalypse run seam")
	if apocalypse_run == null:
		return
	apocalypse_run.start_new_session()
	var shelter := SHELTER_SCENE.instantiate() as Node2D
	test.expect_true(shelter != null, "The shelter with its authored campaign-event modal instantiates")
	if shelter == null:
		return
	scene_tree.root.add_child(shelter)
	var canvas := shelter.get_node("Canvas") as CanvasLayer
	var main_house := shelter.get_node("Canvas/MapHotspots/MainHouse") as Button
	var feature_modal := shelter.get_node("Canvas/FeatureModal") as Control
	var rest_button := shelter.get_node("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	var feature_close := shelter.get_node("Canvas/FeatureModal/Panel/VBox/CloseButton") as Button
	var event_modal := shelter.get_node("Canvas/CampaignEventModal") as Control
	var event_title := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Title") as Label
	var event_description := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Description") as Label
	var power_choice := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/PowerChoice") as Button
	var rooftop_choice := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/RooftopChoice") as Button
	var event_result := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/Result") as Label
	var event_close := shelter.get_node("Canvas/CampaignEventModal/Panel/VBox/CloseButton") as Button
	var campaign_objective := shelter.get_node("Canvas/HUD/CampaignObjective/Objective") as Label
	test.expect_true(not event_modal.visible, "The campaign-event modal starts hidden before day five")
	test.expect_equal(event_modal.get_index(), canvas.get_child_count() - 1, "The campaign-event modal is authored above every shelter overlay")
	test.expect_true(event_description.autowrap_mode != TextServer.AUTOWRAP_OFF, "The authored event description wraps inside the fixed shelter viewport")
	main_house.pressed.emit()
	test.expect_true(feature_modal.visible and rest_button.visible, "The authored main-house panel exposes overnight rest")
	rest_button.pressed.emit()
	rest_button.pressed.emit()
	rest_button.pressed.emit()
	test.expect_equal(apocalypse_run.get_active_session().get_day(), 4, "Three authored rest actions reach the first-raid dawn")
	feature_close.pressed.emit()
	main_house.pressed.emit()
	rest_button.pressed.emit()
	test.expect_equal(apocalypse_run.get_active_session().get_day(), 5, "The next authored rest action reaches day five")
	test.expect_true(event_modal.visible, "The pending day-five event automatically opens its dedicated modal")
	test.expect_equal(event_title.text, "断续的无线电信号", "The event modal renders the domain-authored title")
	test.expect_true(power_choice.disabled, "The five-power choice is visibly disabled when the shelter has no power")
	test.expect_true(not rooftop_choice.disabled, "The rooftop fallback remains available without power")
	test.expect_true(not event_close.visible, "A pending event cannot be closed before a choice")
	var escape_event := InputEventAction.new()
	escape_event.action = &"ui_cancel"
	escape_event.pressed = true
	shelter.call("_unhandled_input", escape_event)
	test.expect_true(event_modal.visible, "Esc cannot dismiss an unresolved campaign event")
	rooftop_choice.pressed.emit()
	test.expect_true(event_result.visible and event_result.text.contains("疲劳和压力各上升 1 级"), "The chosen event result explains its applied consequences")
	test.expect_true(not power_choice.visible and not rooftop_choice.visible, "Resolved event choices leave the result as the single focus")
	test.expect_true(event_close.visible, "The resolved event exposes an explicit return-to-shelter action")
	test.expect_true(campaign_objective.text.contains("第5日事件已处理"), "The shelter objective board advances after event resolution")
	var survivor: Dictionary = apocalypse_run.get_active_session().get_survivor_snapshot()
	test.expect_equal(survivor["condition_levels"]["fatigue"], 1, "The visual event path applies the rooftop fatigue consequence")
	test.expect_equal(survivor["condition_levels"]["stress"], 1, "The visual event path applies the rooftop stress consequence")
	var repository: Variant = SAVE_REPOSITORY_SCRIPT.new("user://saves/apocalypse_review", "apocalypse")
	var save_result: Dictionary = repository.load_slot("auto_1")
	test.expect_true(bool(save_result.get("ok", false)), "Resolving the day-five event writes the shared apocalypse autosave")
	if bool(save_result.get("ok", false)):
		var saved_campaign: Dictionary = save_result["snapshot"]["campaign"]
		test.expect_equal(saved_campaign["day_five_event_state"], &"resolved", "The autosave preserves the resolved event state")
		test.expect_equal(saved_campaign["day_five_event_result"]["choice_id"], &"rooftop_watch", "The autosave preserves the selected stable choice ID")
	if shelter.get_parent() != null:
		shelter.get_parent().remove_child(shelter)
	shelter.free()
