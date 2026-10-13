class_name FarmSoilVisualReviewTests
extends RefCounted

const REVIEW_SCENE = preload("res://scenes/reviews/farm_soil_visual_review.tscn")

static func run(test: Variant) -> void:
	var review := REVIEW_SCENE.instantiate() as Node2D
	test.expect_true(review != null, "The editable five-cell soil review scene instantiates")
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(review)
	for entry in [
		["Untouched", "untouched"],
		["DryTilled", "dry_tilled"],
		["WetTilled", "wet_tilled"],
		["DryCrop", "dry_crop"],
		["WetCrop", "wet_crop"],
	]:
		var plot := review.get_node(entry[0]) as FarmPlot
		test.expect_true(plot != null and plot.editor_preview_state == entry[1], "%s stores its soil preview state in the scene Inspector" % entry[0])
	if review != null:
		review.free()
