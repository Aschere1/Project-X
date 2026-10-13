class_name WorldCollisionTests
extends RefCounted

const INTERACTABLE_SCENE = preload("res://scenes/world/grid_interactable.tscn")
const FARM_PLOT_SCENE = preload("res://scenes/world/farm_plot.tscn")
const WORLD_SCENE = preload("res://scenes/world/movement_playground.tscn")
const CHICKEN_COOP_SCENE = preload("res://scenes/world/chicken_coop.tscn")

static func run(test: Variant) -> void:
	var interactable := INTERACTABLE_SCENE.instantiate()
	test.expect_true(interactable is StaticBody2D, "An interactable facility uses a static collision body")
	var facility_shape := interactable.get_node_or_null("CollisionShape2D") as CollisionShape2D
	test.expect_true(facility_shape != null and facility_shape.shape != null, "An interactable facility has a collision shape")
	test.expect_true(interactable.blocks_movement, "Facilities block player movement by default")
	test.expect_equal(interactable.area_id, &"outdoor", "Facilities belong to the outdoor area by default")
	interactable.free()

	var farm_plot := FARM_PLOT_SCENE.instantiate()
	test.expect_true(farm_plot is StaticBody2D, "A farm plot retains the shared static-body contract")
	var farm_shape := farm_plot.get_node_or_null("CollisionShape2D") as CollisionShape2D
	test.expect_true(farm_shape != null and farm_shape.shape != null, "A farm plot has an explicit collision shape to configure")
	test.expect_true(not farm_plot.blocks_movement, "Farm plots deliberately remain walkable")
	farm_plot.free()

	var world := WORLD_SCENE.instantiate()
	var camera := world.get_node("Player/Camera2D") as Camera2D
	test.expect_true(camera != null and camera.enabled, "The player owns an enabled camera for the full-size spring farm")
	var spring_collision := world.get_node("SpringFarmCollision") as StaticBody2D
	test.expect_true(spring_collision != null and spring_collision.get_child_count() >= 9, "The spring farm defines coarse building and water collisions")
	var player_sprite := world.get_node("Player/Sprite2D") as Sprite2D
	test.expect_true(player_sprite != null and player_sprite.texture != null, "The player scene exposes a pixel-art visual without changing its collision body")
	var animated_player_sprite := world.get_node("Player/AnimatedSprite2D") as AnimatedSprite2D
	test.expect_true(animated_player_sprite != null, "The player scene has a dedicated optional animated visual node")
	var player := world.get_node("Player") as PlayerController
	test.expect_equal(player.get_walk_animation_name_for_facing(Vector2.DOWN), &"walk_down", "Downward movement selects the downward walk animation")
	test.expect_equal(player.get_walk_animation_name_for_facing(Vector2.UP), &"walk_up", "Upward movement selects the upward walk animation")
	test.expect_equal(player.get_walk_animation_name_for_facing(Vector2.LEFT), &"walk_side", "Horizontal movement shares the side walk animation")
	test.expect_true(player.should_flip_walk_sprite(Vector2.LEFT), "The source side frames are mirrored only when walking left")
	test.expect_true(not player.should_flip_walk_sprite(Vector2.RIGHT), "The source side frames already face right")
	for node_path in ["CookingCounter", "LetterBox", "HomeEntrance", "ForageMeadow", "ForageHedge", "FishingPond"]:
		var visual_interactable := world.get_node(node_path) as GridInteractable
		test.expect_true(visual_interactable != null and visual_interactable.visual_texture != null, "%s has a replaceable visual texture" % node_path)
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(world)
	var expects_private_map := ResourceLoader.exists("res://assets/private/mineral_town_spring_farm/spring_farm.png")
	test.expect_equal(world.is_spring_farm_backdrop_active(), expects_private_map, "The spring farm activates exactly when its private backdrop is available")
	test.expect_equal(camera.limit_right, 1024 if expects_private_map else 480, "The outdoor camera limit matches the active visual world")
	var home_entrance := world.get_node("HomeEntrance") as GridInteractable
	test.expect_equal(home_entrance.grid_cell, Vector2i(14, 7) if expects_private_map else Vector2i(9, 7), "The home interaction moves to the private map doorway without changing the fallback layout")
	var cooking_counter := world.get_node("CookingCounter") as GridInteractable
	var fishing_pond := world.get_node("FishingPond") as GridInteractable
	var field_plot_in_world := world.get_node("FieldPlot") as FarmPlot
	test.expect_true(home_entrance.is_gameplay_enabled(), "The visible map doorway remains interactive")
	test.expect_equal(cooking_counter.is_gameplay_enabled(), not expects_private_map, "The old outdoor cooking placeholder is disabled when the spring map has no visible counterpart")
	test.expect_equal(fishing_pond.is_gameplay_enabled(), not expects_private_map, "The old fishing placeholder is disabled when the spring map has no visible counterpart")
	test.expect_true(field_plot_in_world != null and (not expects_private_map or field_plot_in_world.is_gameplay_enabled()), "The visible field remains an active farm plot")
	world.restore_area_and_player_position(&"home_interior", Vector2(240.0, 166.0))
	test.expect_equal(camera.limit_right, 480, "The camera returns to fixed viewport limits inside the home")
	world.free()

	var chicken_coop := CHICKEN_COOP_SCENE.instantiate()
	var chicken_roof := chicken_coop.get_node("Roof") as Sprite2D
	test.expect_true(chicken_roof != null and chicken_roof.texture != null, "The chicken coop composes a taller visual over its one-cell collision footprint")
	chicken_coop.free()
