extends SceneTree

const START_SCENE_PATH := "res://scenes/startup/apocalypse_start.tscn"
const SHELTER_SCENE_PATH := "res://scenes/world/apocalypse_shelter.tscn"
const HOUSE_INTERIOR_SCENE_PATH := "res://scenes/world/apocalypse_house_interior.tscn"
const REGION_MAP_SCENE_PATH := "res://scenes/world/apocalypse_region_map.tscn"
const MARKET_SCENE_PATH := "res://scenes/reviews/apocalypse_market_review.tscn"
const WAREHOUSE_SCENE_PATH := "res://scenes/reviews/apocalypse_warehouse_review.tscn"
const OUTPUT_DIRECTORY := "res://tmp/apocalypse_e2e_capture"

var _failures: Array[String] = []
var _capture_paths: Array[String] = []


func _init() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var output_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	_check(output_error == OK, "Create the visual E2E output directory")

	var apocalypse_run: Variant = root.get_node_or_null("ApocalypseRun")
	_check(apocalypse_run != null, "Find the shared ApocalypseRun autoload")
	if apocalypse_run == null:
		_finish()
		return

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	await _capture("01_start_new_game")

	var entry := current_scene as Control
	var new_game_button := entry.get_node_or_null("Margin/Panel/VBox/Buttons/NewGameButton") as Button
	var confirmation := entry.get_node_or_null("Margin/Panel/VBox/NewGameConfirmation") as Control
	var confirm_button := entry.get_node_or_null("Margin/Panel/VBox/NewGameConfirmation/VBox/Buttons/Confirm") as Button
	_check(new_game_button != null and confirm_button != null and confirmation != null, "Find the authored new-game controls")
	if new_game_button == null or confirm_button == null or confirmation == null:
		_finish()
		return
	new_game_button.pressed.emit()
	await process_frame
	_check(confirmation.visible, "Show the overwrite confirmation before starting a new run")
	await _capture("02_new_game_confirmation")

	confirm_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	await _capture("03_shelter_new_game")

	var shelter_gate := current_scene.get_node_or_null("Canvas/MapHotspots/Gate") as Button
	_check(shelter_gate != null, "Find the authored shelter gate hotspot")
	if shelter_gate != null:
		shelter_gate.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	await _capture("04_county_map")

	var market_marker := current_scene.get_node_or_null("HUD/LocationMarkers/Market") as Button
	_check(market_marker != null, "Find the authored county-market marker")
	if market_marker != null:
		market_marker.pressed.emit()
	await _wait_for_scene(MARKET_SCENE_PATH)
	await _capture("05_market_entry")

	var counter := current_scene.get_node_or_null("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/MarketCounter") as Button
	var search_action := current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction") as Button
	var take_all := current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll") as Button
	var exit_market := current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	var search_state := current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	_check(counter != null and search_action != null and take_all != null and exit_market != null and search_state != null, "Find the authored market search controls")
	if counter != null and search_action != null:
		counter.pressed.emit()
		search_action.pressed.emit()
	await process_frame
	_check(search_state != null and search_state.text == "部分搜索 · 已显露 1/2", "Reveal the first market-counter item")
	await _capture("06_market_first_search")
	if take_all != null:
		take_all.pressed.emit()
	await process_frame
	await _capture("07_market_loot_taken")
	if exit_market != null:
		exit_market.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	await _capture("08_county_map_after_autosave")

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	var continue_button := current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after the isolated autosave")
	await _capture("09_start_continue_available")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	await _capture("10_shelter_restored")

	shelter_gate = current_scene.get_node_or_null("Canvas/MapHotspots/Gate") as Button
	if shelter_gate != null:
		shelter_gate.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	market_marker = current_scene.get_node_or_null("HUD/LocationMarkers/Market") as Button
	if market_marker != null:
		market_marker.pressed.emit()
	await _wait_for_scene(MARKET_SCENE_PATH)
	search_state = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	_check(search_state != null and search_state.text == "部分搜索 · 已显露 1/2", "Restore the market-counter search state after Continue")
	await _capture("11_market_state_restored")

	exit_market = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	if exit_market != null:
		exit_market.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	var shelter_marker := current_scene.get_node_or_null("HUD/LocationMarkers/Shelter") as Button
	_check(shelter_marker != null, "Find the authored return-to-shelter marker")
	if shelter_marker != null:
		shelter_marker.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	await _capture("12_shelter_returned")

	shelter_gate = current_scene.get_node_or_null("Canvas/MapHotspots/Gate") as Button
	if shelter_gate != null:
		shelter_gate.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	var industrial_marker := current_scene.get_node_or_null("HUD/LocationMarkers/Industrial") as Button
	_check(industrial_marker != null, "Find the authored industrial-warehouse marker")
	if industrial_marker != null:
		industrial_marker.pressed.emit()
	await _wait_for_scene(WAREHOUSE_SCENE_PATH)
	await _capture("13_warehouse_entry")

	var loading_bay := current_scene.get_node_or_null("Margin/RootVBox/Body/ScenePanel/SceneVBox/HotspotGrid/LoadingBay") as Button
	search_action = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchAction") as Button
	take_all = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/TakeAll") as Button
	var exit_warehouse := current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	search_state = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	_check(loading_bay != null and search_action != null and take_all != null and exit_warehouse != null and search_state != null, "Find the authored warehouse search controls")
	if loading_bay != null and search_action != null:
		loading_bay.pressed.emit()
		search_action.pressed.emit()
	if take_all != null:
		take_all.pressed.emit()
	await process_frame
	_check(search_state != null and search_state.text == "部分搜索 · 已显露 1/2", "Reveal and take the first warehouse loading-bay item")
	await _capture("14_warehouse_first_search")
	if exit_warehouse != null:
		exit_warehouse.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	continue_button = current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after the warehouse autosave")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	shelter_gate = current_scene.get_node_or_null("Canvas/MapHotspots/Gate") as Button
	if shelter_gate != null:
		shelter_gate.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	industrial_marker = current_scene.get_node_or_null("HUD/LocationMarkers/Industrial") as Button
	if industrial_marker != null:
		industrial_marker.pressed.emit()
	await _wait_for_scene(WAREHOUSE_SCENE_PATH)
	search_state = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/SearchState") as Label
	_check(search_state != null and search_state.text == "部分搜索 · 已显露 1/2", "Restore the warehouse loading-bay search state after Continue")
	await _capture("15_warehouse_state_restored")

	exit_warehouse = current_scene.get_node_or_null("Margin/RootVBox/Body/SearchPanel/SearchVBox/Exit") as Button
	if exit_warehouse != null:
		exit_warehouse.pressed.emit()
	await _wait_for_scene(REGION_MAP_SCENE_PATH)
	shelter_marker = current_scene.get_node_or_null("HUD/LocationMarkers/Shelter") as Button
	if shelter_marker != null:
		shelter_marker.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	await _capture("16_warehouse_returned")

	var main_house := current_scene.get_node_or_null("Canvas/MapHotspots/MainHouse") as Button
	_check(main_house != null, "Find the authored main-house hotspot for campaign rest")
	if main_house != null:
		main_house.pressed.emit()
	var rest_button := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	_check(rest_button != null, "Find the authored overnight-rest action")
	if rest_button != null:
		rest_button.pressed.emit()
		rest_button.pressed.emit()
		rest_button.pressed.emit()
	await process_frame
	_check(apocalypse_run.get_active_session().get_day() == 4, "Reach the deterministic first-raid dawn through authored rest actions")
	await _capture("17_first_raid_settlement")

	var feature_close := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/CloseButton") as Button
	if feature_close != null:
		feature_close.pressed.emit()
	if main_house != null:
		main_house.pressed.emit()
	rest_button = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	if rest_button != null:
		rest_button.pressed.emit()
	await process_frame
	var campaign_event_modal := current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	var power_choice := current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/PowerChoice") as Button
	var rooftop_choice := current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/RooftopChoice") as Button
	var campaign_event_result := current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/Result") as Label
	var campaign_event_close := current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/CloseButton") as Button
	_check(campaign_event_modal != null and campaign_event_modal.visible, "Open the authored pending day-five event modal")
	_check(power_choice != null and power_choice.disabled, "Show the five-power listening choice as unavailable in the unpowered E2E run")
	_check(rooftop_choice != null and not rooftop_choice.disabled, "Keep the rooftop fallback available")
	await _capture("18_day_five_event_pending")
	if rooftop_choice != null:
		rooftop_choice.pressed.emit()
	await process_frame
	_check(campaign_event_result != null and campaign_event_result.visible, "Show the authored day-five event result")
	_check(campaign_event_result != null and campaign_event_result.text.contains("疲劳和压力各上升 1 级"), "Explain the applied rooftop consequences")
	await _capture("19_day_five_event_resolved")
	if campaign_event_close != null:
		campaign_event_close.pressed.emit()
	await process_frame
	var campaign_objective := current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	_check(campaign_objective != null and campaign_objective.text.contains("第5日事件已处理"), "Advance the shelter objective after resolving the day-five event")
	await _capture("20_day_five_shelter_updated")

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	continue_button = current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after the day-five event autosave")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	campaign_event_modal = current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	campaign_objective = current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	var restored_event: Dictionary = apocalypse_run.get_active_session().get_campaign_snapshot().get("day_five_event", {})
	_check(StringName(restored_event.get("state", "")) == &"resolved", "Restore the resolved day-five event state after Continue")
	_check(campaign_event_modal != null and not campaign_event_modal.visible, "Do not reopen an already resolved day-five event")
	_check(campaign_objective != null and campaign_objective.text.contains("屋顶观察"), "Restore the selected day-five outcome on the shelter board")
	await _capture("21_day_five_state_restored")

	main_house = current_scene.get_node_or_null("Canvas/MapHotspots/MainHouse") as Button
	if main_house != null:
		main_house.pressed.emit()
	rest_button = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	if rest_button != null:
		rest_button.pressed.emit()
	await process_frame
	campaign_event_modal = current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	power_choice = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/PowerChoice") as Button
	rooftop_choice = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/RooftopChoice") as Button
	campaign_event_result = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/Result") as Label
	campaign_event_close = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/CloseButton") as Button
	_check(apocalypse_run.get_active_session().get_day() == 6, "Reach the authored day-six event through shelter rest")
	_check(campaign_event_modal != null and campaign_event_modal.visible, "Open the authored pending day-six event modal")
	_check(power_choice != null and StringName(power_choice.get_meta("choice_id", "")) == &"recover_hanging_pack", "Reuse the first generic event button for hanging-pack recovery")
	_check(power_choice != null and power_choice.text.contains("饮用水 ×2"), "Disclose the day-six recovery reward before selection")
	_check(rooftop_choice != null and StringName(rooftop_choice.get_meta("choice_id", "")) == &"abandon_hanging_pack", "Reuse the second generic event button for safe abandonment")
	await _capture("22_day_six_event_pending")
	if power_choice != null:
		power_choice.pressed.emit()
	await process_frame
	_check(campaign_event_result != null and campaign_event_result.visible, "Show the authored day-six event result")
	_check(campaign_event_result != null and campaign_event_result.text.contains("家园仓储获得饮用水 ×2"), "Explain the applied day-six reward")
	await _capture("23_day_six_event_resolved")
	if campaign_event_close != null:
		campaign_event_close.pressed.emit()
	await process_frame
	campaign_objective = current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	_check(campaign_objective != null and campaign_objective.text.contains("第6日事件已处理"), "Advance the shelter objective after resolving the day-six event")
	await _capture("24_day_six_shelter_updated")

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	continue_button = current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after the day-six event autosave")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	campaign_event_modal = current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	campaign_objective = current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	var restored_day_six_event: Dictionary = apocalypse_run.get_active_session().get_campaign_snapshot().get("day_six_event", {})
	_check(StringName(restored_day_six_event.get("state", "")) == &"resolved", "Restore the resolved day-six event state after Continue")
	_check(campaign_event_modal != null and not campaign_event_modal.visible, "Do not reopen an already resolved day-six event")
	_check(campaign_objective != null and campaign_objective.text.contains("系绳回收悬包"), "Restore the selected day-six outcome on the shelter board")
	_check(apocalypse_run.get_active_session().get_container_item_quantity(&"home_storage", &"water") >= 2, "Restore the recovered hanging-pack water after Continue")
	await _capture("25_day_six_state_restored")

	main_house = current_scene.get_node_or_null("Canvas/MapHotspots/MainHouse") as Button
	if main_house != null:
		main_house.pressed.emit()
	rest_button = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureTertiaryAction") as Button
	if rest_button != null:
		rest_button.pressed.emit()
	await process_frame
	campaign_event_modal = current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	power_choice = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/PowerChoice") as Button
	rooftop_choice = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/RooftopChoice") as Button
	campaign_event_result = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/Result") as Label
	campaign_event_close = current_scene.get_node_or_null("Canvas/CampaignEventModal/Panel/VBox/CloseButton") as Button
	_check(apocalypse_run.get_active_session().get_day() == 7, "Reach the authored day-seven event through shelter rest")
	_check(campaign_event_modal != null and campaign_event_modal.visible, "Open the authored pending day-seven event modal")
	_check(power_choice != null and StringName(power_choice.get_meta("choice_id", "")) == &"repair_shelter_tarp", "Reuse the first generic event button for tarp repair")
	_check(power_choice != null and power_choice.disabled, "Disable tarp repair when no wire is available")
	_check(power_choice != null and power_choice.text.contains("没有电线"), "Explain why tarp repair is unavailable")
	_check(rooftop_choice != null and StringName(rooftop_choice.get_meta("choice_id", "")) == &"move_shelter_supplies", "Reuse the second generic event button for manual supply relocation")
	_check(rooftop_choice != null and rooftop_choice.text.contains("疲劳 +1，压力 +1"), "Disclose the day-seven manual condition costs")
	await _capture("26_day_seven_event_pending")
	if rooftop_choice != null:
		rooftop_choice.pressed.emit()
	await process_frame
	_check(campaign_event_result != null and campaign_event_result.visible, "Show the authored day-seven event result")
	_check(campaign_event_result != null and campaign_event_result.text.contains("疲劳和压力各上升 1 级"), "Explain the applied day-seven condition costs")
	await _capture("27_day_seven_event_resolved")
	if campaign_event_close != null:
		campaign_event_close.pressed.emit()
	await process_frame
	campaign_objective = current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	_check(campaign_objective != null and campaign_objective.text.contains("第7日事件已处理"), "Advance the shelter objective after resolving the day-seven event")
	await _capture("28_day_seven_shelter_updated")

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	continue_button = current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after the day-seven event autosave")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	campaign_event_modal = current_scene.get_node_or_null("Canvas/CampaignEventModal") as Control
	campaign_objective = current_scene.get_node_or_null("Canvas/HUD/CampaignObjective/Objective") as Label
	var restored_day_seven_event: Dictionary = apocalypse_run.get_active_session().get_campaign_snapshot().get("day_seven_event", {})
	_check(StringName(restored_day_seven_event.get("state", "")) == &"resolved", "Restore the resolved day-seven event state after Continue")
	_check(campaign_event_modal != null and not campaign_event_modal.visible, "Do not reopen an already resolved day-seven event")
	_check(campaign_objective != null and campaign_objective.text.contains("徒手转移物资"), "Restore the selected day-seven outcome on the shelter board")
	await _capture("29_day_seven_state_restored")

	var chicken_coop := current_scene.get_node_or_null("Canvas/MapHotspots/ChickenCoop") as Button
	if chicken_coop != null:
		chicken_coop.pressed.emit()
	await process_frame
	var feature_modal := current_scene.get_node_or_null("Canvas/FeatureModal") as Control
	var feature_title := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/Title") as Label
	var feature_description := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/Description") as Label
	var feature_action := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureAction") as Button
	feature_close = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/CloseButton") as Button
	_check(feature_modal != null and feature_modal.visible, "Open the chicken-coop facility panel from its authored shelter hotspot")
	_check(feature_title != null and feature_title.text.contains("鸡棚"), "Render the authored chicken-coop facility title")
	_check(feature_description != null and feature_description.text.contains("鸡群 ×4"), "Render the persistent chicken-group overview")
	_check(feature_action != null and feature_action.text.contains("整理鸡棚"), "Expose the daily chicken-coop maintenance action")
	await _capture("30_chicken_coop_pending")
	if feature_action != null:
		feature_action.pressed.emit()
	await process_frame
	_check(feature_description != null and feature_description.text.contains("今天已完成巡检和整理"), "Refresh the chicken-coop panel after maintenance")
	await _capture("31_chicken_coop_serviced")
	if feature_close != null:
		feature_close.pressed.emit()

	var livestock_pens := current_scene.get_node_or_null("Canvas/MapHotspots/LivestockPens") as Button
	if livestock_pens != null:
		livestock_pens.pressed.emit()
	await process_frame
	feature_title = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/Title") as Label
	feature_description = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/Description") as Label
	feature_action = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureAction") as Button
	feature_close = current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/CloseButton") as Button
	_check(feature_title != null and feature_title.text.contains("三联牲畜棚"), "Open the shared cattle-sheep-pig facility panel")
	_check(feature_description != null and feature_description.text.contains("黄牛 ×1") and feature_description.text.contains("山羊 ×1") and feature_description.text.contains("猪 ×1"), "List the three livestock pens in one shared facility panel")
	if feature_action != null:
		feature_action.pressed.emit()
	await process_frame
	_check(feature_description != null and feature_description.text.contains("今天已完成巡检和整理"), "Refresh the shared livestock facility after maintenance")
	await _capture("32_livestock_pens_serviced")
	if feature_close != null:
		feature_close.pressed.emit()

	main_house = current_scene.get_node_or_null("Canvas/MapHotspots/MainHouse") as Button
	if main_house != null:
		main_house.pressed.emit()
	await process_frame
	var house_entry := current_scene.get_node_or_null("Canvas/FeatureModal/Panel/VBox/FeatureQuaternaryAction") as Button
	_check(house_entry != null and house_entry.visible and house_entry.text.contains("进入主屋室内"), "Expose the saved main-house interior from the established home panel")
	if house_entry != null:
		house_entry.pressed.emit()
	await _wait_for_scene(HOUSE_INTERIOR_SCENE_PATH)
	var interior_hotspots := current_scene.get_node_or_null("MapHotspots") as Control
	var interior_status := current_scene.get_node_or_null("HUD/StatusPanel/VBox/Status") as Label
	_check(interior_hotspots != null and interior_hotspots.get_child_count() == 5, "Open the authored static house interior with five editable facility hotspots")
	_check(interior_status != null and interior_status.text.contains("主屋"), "Render the shared-session house status inside the interior")
	await _capture("33_house_interior")
	var interior_exit := current_scene.get_node_or_null("MapHotspots/Exit") as Button
	if interior_exit != null:
		interior_exit.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)

	apocalypse_run.reset_active_session()
	await _open_scene(START_SCENE_PATH)
	continue_button = current_scene.get_node_or_null("Margin/Panel/VBox/Buttons/ContinueButton") as Button
	_check(continue_button != null and not continue_button.disabled, "Offer Continue after safe-zone facility maintenance autosaves")
	if continue_button != null:
		continue_button.pressed.emit()
	await _wait_for_scene(SHELTER_SCENE_PATH)
	_check(StringName(apocalypse_run.get_active_session().get_shelter_facility_snapshot(&"chicken_coop").get("status", "")) == &"serviced_today", "Restore the serviced chicken-coop state after Continue")
	_check(StringName(apocalypse_run.get_active_session().get_shelter_facility_snapshot(&"livestock_pens").get("status", "")) == &"serviced_today", "Restore the serviced livestock-pens state after Continue")
	await _capture("34_shelter_facilities_restored")

	_finish()


func _open_scene(scene_path: String) -> void:
	var error := change_scene_to_file(scene_path)
	_check(error == OK, "Open scene %s" % scene_path)
	await _wait_for_scene(scene_path)


func _wait_for_scene(scene_path: String, frame_limit: int = 120) -> void:
	for _frame in range(frame_limit):
		await process_frame
		if current_scene != null and current_scene.scene_file_path == scene_path:
			await process_frame
			return
	_failures.append("Timed out waiting for scene: %s" % scene_path)


func _capture(step_name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	_check(image != null and not image.is_empty(), "Capture rendered frame %s" % step_name)
	if image == null or image.is_empty():
		return
	var relative_path := "%s/%s.png" % [OUTPUT_DIRECTORY, step_name]
	var absolute_path := ProjectSettings.globalize_path(relative_path)
	var save_error := image.save_png(absolute_path)
	_check(save_error == OK, "Save rendered frame %s" % step_name)
	if save_error == OK:
		_capture_paths.append(absolute_path)
		print("APOCALYPSE_E2E_CAPTURE step=%s path=%s" % [step_name, absolute_path])


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("APOCALYPSE_E2E_CAPTURE_PASSED captures=%d" % _capture_paths.size())
		quit(0)
		return
	for failure in _failures:
		push_error("APOCALYPSE_E2E_CAPTURE_FAILED: %s" % failure)
	print("APOCALYPSE_E2E_CAPTURE_FAILED count=%d captures=%d" % [_failures.size(), _capture_paths.size()])
	quit(1)
