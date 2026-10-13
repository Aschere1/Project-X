extends Node2D

const TREE_REVIEW_POSITION := Vector2(104.0, 170.0)

@onready var home_region: HomeRegion = $HomeRegion

func _ready() -> void:
	home_region.player.global_position = TREE_REVIEW_POSITION
	print("HOME_TREE_REVIEW_READY position=%s" % TREE_REVIEW_POSITION)
