class_name ApocalypseItemCatalog
extends RefCounted

const DEFAULT_SUPPLY_STACK := 16
const USE_ACTION_NONE := &""
const USE_ACTION_DRINK := &"drink"
const USE_ACTION_HEAL := &"heal"
const USE_ACTION_BANDAGE := &"bandage"
const SIMPLE_LOCKPICK_RECIPE_ID := &"simple_lockpick"

static func get_maximum_stack(item_id: StringName) -> int:
	match item_id:
		&"pistol", &"rifle", &"shotgun", &"melee_weapon", &"crowbar":
			return 1
		_:
			return DEFAULT_SUPPLY_STACK

static func get_category(item_id: StringName) -> String:
	match item_id:
		&"water":
			return "补给"
		&"medkit", &"bandage":
			return "医疗"
		&"clinic_key", &"simple_lockpick":
			return "任务物品"
		&"scrap_metal", &"wire":
			return "材料"
		&"fuel_can":
			return "燃料"
		&"pistol", &"rifle", &"shotgun", &"melee_weapon", &"crowbar":
			return "武器"
		_:
			return "物资"

static func get_display_name(item_id: StringName) -> String:
	match item_id:
		&"water":
			return "饮用水"
		&"medkit":
			return "急救包"
		&"bandage":
			return "绷带"
		&"clinic_key":
			return "诊所钥匙"
		&"fuel_can":
			return "燃料罐"
		&"scrap_metal":
			return "废金属"
		&"wire":
			return "电线"
		&"simple_lockpick":
			return "简易开锁工具"
		&"crowbar":
			return "撬棍"
		_:
			return String(item_id)

static func get_effect_text(item_id: StringName) -> String:
	match item_id:
		&"water":
			return "效果：口渴等级 -1"
		&"medkit":
			return "效果：生命 +25"
		&"bandage":
			return "效果：移除 1 项创伤"
		&"clinic_key":
			return "用途：开启诊所锁柜"
		&"fuel_can":
			return "效果：家园电力 +10"
		&"scrap_metal", &"wire":
			return "用途：制作简易开锁工具"
		&"simple_lockpick":
			return "用途：撬开诊所锁柜（消耗）"
		&"crowbar":
			return "近战伤害 8 · 体力消耗 6 · 噪声 1"
		_:
			return "用途：等待后续功能接入"

static func get_use_action(item_id: StringName) -> StringName:
	match item_id:
		&"water":
			return USE_ACTION_DRINK
		&"medkit":
			return USE_ACTION_HEAL
		&"bandage":
			return USE_ACTION_BANDAGE
		_:
			return USE_ACTION_NONE

static func get_use_menu_text(item_id: StringName) -> String:
	match get_use_action(item_id):
		USE_ACTION_DRINK:
			return "饮用 1"
		USE_ACTION_HEAL:
			return "使用急救包"
		USE_ACTION_BANDAGE:
			return "使用绷带"
		_:
			return ""

static func get_generator_power_value(item_id: StringName) -> int:
	match item_id:
		&"fuel_can":
			return 10
		_:
			return 0

static func is_weapon(item_id: StringName) -> bool:
	return get_category(item_id) == "武器"

static func get_weapon_stats(item_id: StringName) -> Dictionary:
	match item_id:
		&"crowbar":
			return {"damage": 8, "stamina_cost": 6, "noise": 1}
		_:
			return {}

static func get_workbench_recipe(recipe_id: StringName) -> Dictionary:
	match recipe_id:
		SIMPLE_LOCKPICK_RECIPE_ID:
			return {
				"output_item_id": &"simple_lockpick",
				"scrap_metal": 1,
				"wire": 1,
				"power_cost": 5,
				"minutes": 10,
			}
		_:
			return {}
