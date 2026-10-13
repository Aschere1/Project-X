class_name HomeInterior
extends Node2D

@export var movement_bounds := Rect2(88.0, 80.0, 304.0, 130.0)
@export var entry_position := Vector2(248.0, 196.0)
@export var exit_position := Vector2(248.0, 196.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(480.0, 270.0)), Color("252b2b"), true)
	draw_rect(Rect2(72.0, 62.0, 336.0, 166.0), Color("7b5b43"), true)
	draw_rect(Rect2(80.0, 70.0, 320.0, 150.0), Color("d2ad77"), true)
	for x in range(96, 400, 16):
		draw_line(Vector2(x, 70.0), Vector2(x, 220.0), Color("bd9567"), 1.0)
	for y in range(86, 220, 16):
		draw_line(Vector2(80.0, y), Vector2(400.0, y), Color("bd9567"), 1.0)
	draw_rect(Rect2(94.0, 86.0, 78.0, 34.0), Color("75543d"), true)
	draw_rect(Rect2(98.0, 90.0, 70.0, 26.0), Color("e2d0aa"), true)
	draw_rect(Rect2(316.0, 88.0, 60.0, 42.0), Color("6a4a35"), true)
	draw_rect(Rect2(320.0, 92.0, 52.0, 34.0), Color("a17a52"), true)
