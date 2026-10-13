extends Node2D

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var indicator_color := Color("ffe47a")
	draw_line(Vector2(-9.0, -9.0), Vector2(-3.0, -9.0), indicator_color, 1.0)
	draw_line(Vector2(-9.0, -9.0), Vector2(-9.0, -3.0), indicator_color, 1.0)
	draw_line(Vector2(9.0, -9.0), Vector2(3.0, -9.0), indicator_color, 1.0)
	draw_line(Vector2(9.0, -9.0), Vector2(9.0, -3.0), indicator_color, 1.0)
	draw_line(Vector2(-9.0, 9.0), Vector2(-3.0, 9.0), indicator_color, 1.0)
	draw_line(Vector2(-9.0, 9.0), Vector2(-9.0, 3.0), indicator_color, 1.0)
	draw_line(Vector2(9.0, 9.0), Vector2(3.0, 9.0), indicator_color, 1.0)
	draw_line(Vector2(9.0, 9.0), Vector2(9.0, 3.0), indicator_color, 1.0)
