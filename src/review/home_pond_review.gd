extends Node2D

const POND_REVIEW_POSITION := Vector2(112.0, 392.0)

@onready var home_region: HomeRegion = $HomeRegion


func _ready() -> void:
	# This scene is visual QA only. It never changes the formal scene's spawn.
	home_region.player.global_position = POND_REVIEW_POSITION
	print("HOME_POND_REVIEW_READY position=%s" % POND_REVIEW_POSITION)
