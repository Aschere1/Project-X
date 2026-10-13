extends Node2D

const TILESET_PATH := "res://assets/private/super_retro_world_farming/Tilesets/Super_Retro_Tilesets.tres"

@onready var layers: Array[TileMapLayer] = [
	$Dirt,
	$Road,
	$Water,
	$DirtWater,
	$Fence,
]

func _ready() -> void:
	var tile_set := load(TILESET_PATH) as TileSet
	assert(tile_set != null, "Super Retro terrain review requires the private TileSet.")
	for layer in layers:
		layer.tile_set = tile_set
	_paint_block($Dirt, Rect2i(1, 1, 9, 9), 0, 0)
	_paint_block($Road, Rect2i(12, 1, 9, 9), 0, 2)
	_paint_block($Water, Rect2i(23, 1, 9, 9), 4, 0)
	_paint_block($DirtWater, Rect2i(1, 12, 9, 9), 5, 0)
	_paint_block($Fence, Rect2i(12, 12, 9, 9), 3, 0)
	print("SUPER_RETRO_TERRAIN_REVIEW_READY")

func _paint_block(layer: TileMapLayer, rect: Rect2i, terrain_set: int, terrain: int) -> void:
	var cells: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			cells.append(Vector2i(x, y))
	layer.set_cells_terrain_connect(cells, terrain_set, terrain, true)
