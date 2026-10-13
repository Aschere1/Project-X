class_name ChickenCoopVisualReviewTests
extends RefCounted

const REVIEW_SCENE = preload("res://scenes/reviews/chicken_coop_visual_review.tscn")

static func run(test: Variant) -> void:
	var review := REVIEW_SCENE.instantiate() as Node2D
	test.expect_true(review != null, "The chicken coop visual review scene instantiates")
	if review == null:
		return
	test.expect_true(review.get_node("FeedCrate").texture.resource_path.contains("super_retro_world_farming"), "The coop visual review uses the Super Retro crate")
	test.expect_true(review.get_node("WaterBarrel").texture.resource_path.contains("super_retro_world_farming"), "The coop visual review uses the Super Retro barrel")
	test.expect_true(review.get_node("Hen").texture.resource_path.ends_with("starter_hen.png"), "The coop visual review uses the corrected hen")
	for prop_name in ["FeedCrate", "WaterBarrel", "FeedPot"]:
		test.expect_true(review.get_node_or_null("Collision/%sCollision" % prop_name) is CollisionShape2D, "%s has an editor-authored prop collision" % prop_name)
	review.free()
