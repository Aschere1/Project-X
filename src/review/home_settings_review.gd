extends Node2D

@onready var home_region: HomeRegion = $HomeRegion

func _ready() -> void:
	home_region._open_settings()
	print("HOME_SETTINGS_REVIEW_READY")
