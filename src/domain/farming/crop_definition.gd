class_name CropDefinition
extends Resource

@export var crop_id: StringName
@export var display_name := "未命名作物"
@export var seed_item_id: StringName
@export var harvest_item_id: StringName
@export_range(1, 28, 1) var days_to_mature := 3
@export_range(1, 99, 1) var harvest_amount := 1
@export_range(0, 28, 1) var regrow_days := 0
