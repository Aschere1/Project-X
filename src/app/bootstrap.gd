extends Control

const EXPECTED_VIEWPORT_SIZE := Vector2i(480, 270)


func _ready() -> void:
	var configured_size := Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)),
		int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)),
	)

	assert(
		configured_size == EXPECTED_VIEWPORT_SIZE,
		"Pixel viewport must remain 480x270, got %s" % configured_size,
	)
	print("PROJECT_X_BOOT_OK viewport=%s" % configured_size)

