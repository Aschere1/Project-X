class_name CookingController
extends Node

signal cooking_state_changed()
signal cooked(message: String)

const ENGINE_SCRIPT = preload("res://src/domain/cooking/cooking_engine.gd")
const NOTEBOOK_SCRIPT = preload("res://src/domain/cooking/cooking_notebook.gd")
const COOKWARE_IDS: Array[StringName] = [&"board", &"pan", &"pot", &"oven"]
const INGREDIENT_FILTER_IDS: Array[StringName] = [&"all", &"farm", &"forage", &"fishing", &"animal"]

@export var inventory_controller_path: NodePath
@export var game_clock_path: NodePath
@onready var inventory_controller: InventoryController = get_node_or_null(inventory_controller_path) as InventoryController
@onready var game_clock: GameClockController = get_node_or_null(game_clock_path) as GameClockController

var notebook: CookingNotebook
var cookware_index := 0
var ingredient_index := 0
var ingredient_filter_index := 0
var main_ingredient_ids: Array[StringName] = []
var seasoning_id: StringName

func _ready() -> void:
	assert(inventory_controller != null, "CookingController requires an InventoryController path.")
	assert(game_clock != null, "CookingController requires a GameClockController path.")
	notebook = NOTEBOOK_SCRIPT.new()

func cycle_cookware() -> void:
	cookware_index = (cookware_index + 1) % COOKWARE_IDS.size()
	cooking_state_changed.emit()

func cycle_ingredient() -> void:
	var available := _get_cookable_item_ids()
	if not available.is_empty():
		ingredient_index = (ingredient_index + 1) % available.size()
	cooking_state_changed.emit()

func cycle_ingredient_filter() -> void:
	ingredient_filter_index = (ingredient_filter_index + 1) % INGREDIENT_FILTER_IDS.size()
	ingredient_index = 0
	cooking_state_changed.emit()

func add_current_ingredient() -> void:
	var item_id := get_current_ingredient_id()
	if item_id == &"" or main_ingredient_ids.size() >= 4:
		return
	if main_ingredient_ids.count(item_id) >= inventory_controller.inventory.count_item(item_id):
		return
	main_ingredient_ids.append(item_id)
	cooking_state_changed.emit()

func set_current_seasoning() -> void:
	var item_id := get_current_ingredient_id()
	var definition := inventory_controller.item_catalog.get_item(item_id)
	if definition != null and definition.is_seasoning:
		seasoning_id = item_id
		cooking_state_changed.emit()

func clear_selection() -> void:
	main_ingredient_ids.clear()
	seasoning_id = &""
	cooking_state_changed.emit()

func cook() -> void:
	if game_clock.session.get_stamina() < 3:
		cooked.emit("体力不足，无法完成料理；组合已保留。")
		return
	var required := _get_required_amounts()
	for item_id in required:
		if inventory_controller.inventory.count_item(item_id) < required[item_id]:
			cooked.emit("食材数量不足，组合已保留。")
			return
	var profile := _build_cooking_profile(required)
	var outcome: Dictionary = ENGINE_SCRIPT.resolve(get_current_cookware_id(), main_ingredient_ids, seasoning_id, profile["quality_values"], profile["rarity_values"])
	var output_id := StringName(outcome["item_id"])
	var output_quality := int(outcome["quality_tier"])
	if not inventory_controller.can_add_item(output_id, 1, output_quality):
		cooked.emit("背包没有空间，无法完成料理。")
		return
	for item_id in required:
		inventory_controller.remove_item(item_id, required[item_id])
	inventory_controller.add_item(output_id, 1, output_quality)
	game_clock.session.consume_stamina(3)
	game_clock.session.advance_minutes(15)
	game_clock.emit_clock_state()
	notebook.record(get_current_cookware_id(), main_ingredient_ids, seasoning_id, output_id, output_quality, int(outcome["rarity_tier"]), bool(outcome["is_signature"]))
	var signature_prefix := "招牌 " if bool(outcome["is_signature"]) else ""
	cooked.emit("制作%s%s%s：%s" % [signature_prefix, inventory_controller.get_quality_suffix(output_quality), outcome["display_name"], outcome["message"]])
	clear_selection()

func get_current_cookware_id() -> StringName:
	return COOKWARE_IDS[cookware_index]

func get_current_ingredient_id() -> StringName:
	var available := _get_cookable_item_ids()
	if available.is_empty():
		return &""
	ingredient_index %= available.size()
	return available[ingredient_index]

func get_current_ingredient_filter_id() -> StringName:
	return INGREDIENT_FILTER_IDS[ingredient_filter_index]

func get_state_text() -> String:
	var current := get_current_ingredient_id()
	var current_definition := inventory_controller.item_catalog.get_item(current)
	var current_name := current_definition.display_name if current_definition != null else "无"
	var source_text := _get_ingredient_source_display_name(StringName(current_definition.ingredient_source)) if current_definition != null else "无"
	var main_names: Array[String] = []
	for item_id in main_ingredient_ids:
		main_names.append(inventory_controller.item_catalog.get_item(item_id).display_name)
	var seasoning_name := inventory_controller.item_catalog.get_item(seasoning_id).display_name if seasoning_id != &"" else "无"
	var main_text := "、".join(main_names) if not main_names.is_empty() else "无"
	var source_hint := _get_ingredient_source_hint(StringName(current_definition.ingredient_source)) if current_definition != null else "当前筛选没有可用食材。"
	return "厨具：%s\n食材筛选：%s\n当前食材：%s · %s\n来源提示：%s\n主食材：%s\n调味：%s\n笔记：%d 条\n\nC 切厨具 · V 切分类 · T 切食材 · G 加入 · H 调味\nJ 烹饪（体力 3／15 分钟） · U 清空 · E 关闭" % [_get_cookware_display_name(), _get_filter_display_name(), current_name, source_text, source_hint, main_text, seasoning_name, notebook.get_entry_count()]

func get_notebook_entry_text(index: int) -> String:
	var entry := notebook.get_entry(index)
	if entry.is_empty():
		return "个人料理笔记\n\n还没有发现过的料理。\n先在料理柜台完成一次烹饪吧。\n\nN 关闭"
	var ingredient_names: Array[String] = []
	var ingredient_values: Array = entry.get("ingredient_ids", [])
	for ingredient_value in ingredient_values:
		ingredient_names.append(_get_item_display_name(StringName(str(ingredient_value))))
	var seasoning_id := StringName(str(entry.get("seasoning_id", "")))
	var seasoning_name := _get_item_display_name(seasoning_id) if seasoning_id != &"" else "无"
	var quality_tier := int(entry.get("quality_tier", Inventory.NORMAL_QUALITY))
	var rarity_tier := int(entry.get("rarity_tier", 0))
	var signature_prefix := "招牌 " if bool(entry.get("is_signature", false)) else ""
	return "个人料理笔记  %d / %d\n\n结果：%s%s%s\n品质：%s · 稀有度：%s\n厨具：%s\n主食材：%s\n调味：%s\n\nW/S 浏览 · E 装填 · N 关闭" % [index + 1, notebook.get_entry_count(), signature_prefix, inventory_controller.get_quality_suffix(quality_tier), _get_item_display_name(StringName(str(entry.get("result_item_id", "")))), inventory_controller.get_quality_name(quality_tier), _get_rarity_name(rarity_tier), _get_cookware_display_name_for(StringName(str(entry.get("cookware_id", "")))), "、".join(ingredient_names) if not ingredient_names.is_empty() else "无", seasoning_name]

func load_notebook_entry(index: int) -> bool:
	var entry := notebook.get_entry(index)
	if entry.is_empty():
		return false
	var cookware_id := StringName(str(entry.get("cookware_id", "")))
	var target_cookware_index := COOKWARE_IDS.find(cookware_id)
	var ingredient_values: Variant = entry.get("ingredient_ids", [])
	if target_cookware_index < 0 or not ingredient_values is Array or ingredient_values.size() > 4:
		return false
	var restored_ingredients: Array[StringName] = []
	for ingredient_value in ingredient_values:
		var ingredient_id := StringName(str(ingredient_value))
		if ingredient_id == &"" or inventory_controller.item_catalog.get_item(ingredient_id) == null:
			return false
		restored_ingredients.append(ingredient_id)
	var restored_seasoning := StringName(str(entry.get("seasoning_id", "")))
	if restored_seasoning != &"" and inventory_controller.item_catalog.get_item(restored_seasoning) == null:
		return false
	cookware_index = target_cookware_index
	main_ingredient_ids = restored_ingredients
	seasoning_id = restored_seasoning
	cooking_state_changed.emit()
	return true

func to_snapshot() -> Dictionary:
	return notebook.to_snapshot()

func restore_snapshot(snapshot: Dictionary) -> bool:
	return notebook.restore_snapshot(snapshot)

func _get_cookable_item_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for stack in inventory_controller.inventory.get_stacks():
		var item_id := StringName(stack["item_id"])
		var definition := inventory_controller.item_catalog.get_item(item_id)
		if definition != null and definition.is_cookable and _matches_ingredient_filter(definition):
			result.append(item_id)
	return result

func _matches_ingredient_filter(definition: ItemDefinition) -> bool:
	var filter_id := get_current_ingredient_filter_id()
	return filter_id == &"all" or StringName(definition.ingredient_source) == filter_id

func _get_filter_display_name() -> String:
	match get_current_ingredient_filter_id():
		&"farm": return "农田"
		&"forage": return "采集"
		&"fishing": return "钓鱼"
		&"animal": return "动物"
		_: return "全部"

func _get_ingredient_source_display_name(source_id: StringName) -> String:
	match source_id:
		&"farm": return "农田"
		&"forage": return "采集"
		&"fishing": return "钓鱼"
		&"animal": return "动物"
		_: return "其他"

func _get_ingredient_source_hint(source_id: StringName) -> String:
	match source_id:
		&"farm": return "收获农田作物；雨天会自动浇水。"
		&"forage": return "草地蘑菇标记处每天可采集一次。"
		&"fishing": return "池塘上岸木牌处每天最多钓三次。"
		&"animal": return "照料鸡舍后可在产蛋日取得。"
		_: return "通过探索或后续系统获得。"

func _get_cookware_display_name() -> String:
	return _get_cookware_display_name_for(get_current_cookware_id())

func _get_cookware_display_name_for(cookware_id: StringName) -> String:
	match cookware_id:
		&"board": return "案板"
		&"pan": return "平底锅"
		&"pot": return "汤锅"
		&"oven": return "烤箱"
		_: return "未知厨具"

func _get_item_display_name(item_id: StringName) -> String:
	var definition := inventory_controller.item_catalog.get_item(item_id)
	return definition.display_name if definition != null else "未知物品"

func _get_rarity_name(rarity_tier: int) -> String:
	match rarity_tier:
		2: return "珍稀"
		1: return "少见"
		_: return "普通"

func _get_required_amounts() -> Dictionary[StringName, int]:
	var amounts: Dictionary[StringName, int] = {}
	for item_id in main_ingredient_ids:
		amounts[item_id] = amounts.get(item_id, 0) + 1
	if seasoning_id != &"":
		amounts[seasoning_id] = amounts.get(seasoning_id, 0) + 1
	return amounts

func _build_cooking_profile(required: Dictionary[StringName, int]) -> Dictionary:
	var quality_values: Array[int] = []
	var rarity_values: Array[int] = []
	for item_id in required:
		var quantity: int = required[item_id]
		quality_values.append_array(inventory_controller.inventory.get_item_quality_values(item_id, quantity))
		var definition := inventory_controller.item_catalog.get_item(item_id)
		for _index in quantity:
			rarity_values.append(definition.rarity_tier if definition != null else 0)
	return {"quality_values": quality_values, "rarity_values": rarity_values}
