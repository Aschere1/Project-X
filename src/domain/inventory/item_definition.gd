class_name ItemDefinition
extends Resource

@export var item_id: StringName
@export var display_name := "未命名物品"
@export_multiline var description := ""
@export_range(1, 999, 1) var maximum_stack_size := 99
@export var is_seed := false
@export var is_cookable := false
@export var is_seasoning := false
@export_enum("farm", "forage", "fishing", "animal", "other") var ingredient_source: String = "other"
@export_range(1, 3, 1) var default_quality := 1
@export_range(0, 2, 1) var rarity_tier := 0
