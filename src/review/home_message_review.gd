extends Node2D

@onready var home_region: HomeRegion = $HomeRegion

func _ready() -> void:
	home_region._show_message("收获了普通芜菁 x1。")
	print("HOME_MESSAGE_REVIEW_READY")
