class_name PlayerMovementTests
extends RefCounted

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")

static func run(test: Variant) -> void:
	test.expect_true(InputMap.has_action(PlayerController.ACTION_SPRINT), "Sprint is a named input action rather than a hardcoded key")
	var sprint_events := InputMap.action_get_events(PlayerController.ACTION_SPRINT)
	var sprint_key := sprint_events[0] as InputEventKey
	test.expect_true(sprint_key != null and sprint_key.keycode == KEY_SHIFT, "The default sprint action is bound to the Shift key")
	var player := PLAYER_SCENE.instantiate() as PlayerController
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
	var body_shape := player.get_node("CollisionShape2D") as CollisionShape2D
	test.expect_equal(body_shape.position, Vector2(0, 3), "The player collision is explicitly anchored at the feet, not centered on the full sprite")
	var body_rectangle := body_shape.shape as RectangleShape2D
	test.expect_equal(body_rectangle.size, Vector2(12, 10), "The player collider only covers the lower walking body")

	test.expect_equal(player.get_move_speed(false), 80.0, "Walking keeps the baseline movement speed")
	test.expect_equal(player.get_move_speed(true), 120.0, "Holding sprint raises movement speed by the configured multiplier")
	test.expect_equal(player.get_walk_animation_speed_scale(false), 1.0, "Walking keeps the baseline animation speed")
	test.expect_equal(player.get_walk_animation_speed_scale(true), 1.35, "Sprinting also increases the walk animation rate")
	test.expect_true(player.get_move_speed(true) > player.get_move_speed(false), "Sprint speed is always faster than normal walking")

	var animated_sprite := player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	for animation_name in [PlayerController.WALK_DOWN_ANIMATION, PlayerController.WALK_UP_ANIMATION, PlayerController.WALK_SIDE_ANIMATION]:
		test.expect_equal(animated_sprite.sprite_frames.get_frame_count(animation_name), 3, "%s uses one three-frame farmer variant instead of crossing into the adjacent skin palette" % animation_name)
	player._update_walk_visual(false)
	test.expect_equal(animated_sprite.frame, 1, "Stopping uses the centered idle frame rather than freezing on a walking pose")
	test.expect_true(not animated_sprite.is_playing(), "The idle farmer is paused instead of continuing the walk cycle")

	player.free()
