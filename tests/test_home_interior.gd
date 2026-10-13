class_name HomeInteriorTests
extends RefCounted

const HOME_INTERIOR_SCENE = preload("res://scenes/world/home_interior.tscn")

static func run(test: Variant) -> void:
	var interior: Variant = HOME_INTERIOR_SCENE.instantiate()
	test.expect_true(interior is Node2D, "The home interior is a reusable scene node")
	test.expect_true(interior.movement_bounds.has_point(interior.entry_position), "The interior entry point stays within indoor movement bounds")
	test.expect_true(interior.movement_bounds.has_point(interior.exit_position), "The interior exit point stays within indoor movement bounds")
	interior.free()
