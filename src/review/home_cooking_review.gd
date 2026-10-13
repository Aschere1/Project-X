extends Node2D

@onready var home_region: HomeRegion = $HomeRegion


func _ready() -> void:
	# Visual QA only: display a populated formal cooking filter without writing a save.
	home_region.player.global_position = Vector2(304.0, 176.0)
	home_region.inventory_controller.add_item(&"turnip", 1)
	home_region.inventory_controller.add_item(&"pond_smelt", 1)
	home_region.inventory_controller.add_item(&"egg", 1)
	home_region.cooking_controller.cycle_ingredient_filter()
	home_region.cooking_controller.cycle_ingredient_filter()
	home_region.cooking_controller.cycle_ingredient_filter()
	home_region._open_cooking_panel()
	print("HOME_COOKING_REVIEW_READY")
