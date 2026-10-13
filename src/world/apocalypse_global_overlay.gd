class_name ApocalypseGlobalOverlay
extends CanvasLayer

signal inventory_changed

const BACKPACK_ID := &"backpack"
const ITEM_CATALOG_SCRIPT = preload("res://src/domain/apocalypse/apocalypse_item_catalog.gd")
const ACTION_USE := 1
const ACTION_EQUIP := 2
const ACTION_UNEQUIP := 3
const ACTION_SPLIT_HALF := 4
const ACTION_SPLIT_CUSTOM := 5
const ACTION_INSPECT := 6
const MENU_WIDTH := 132
const FONT_SIZE := 8

@onready var backpack_button: Button = $BackpackButton
@onready var inventory_modal: Control = $InventoryModal
@onready var equipment_status: Label = $InventoryModal/Panel/VBox/EquipmentStatus
@onready var weight_label: Label = $InventoryModal/Panel/VBox/Weight
@onready var inventory_grid: ApocalypseInventoryGridView = $InventoryModal/Panel/VBox/Items
@onready var inventory_status: Label = $InventoryModal/Panel/VBox/Status
@onready var inventory_close_button: Button = $InventoryModal/Panel/VBox/CloseButton
@onready var system_menu: Control = $SystemMenu
@onready var system_status: Label = $SystemMenu/Panel/VBox/Status
@onready var continue_button: Button = $SystemMenu/Panel/VBox/ContinueButton
@onready var system_backpack_button: Button = $SystemMenu/Panel/VBox/BackpackButton
@onready var save_button: Button = $SystemMenu/Panel/VBox/SaveButton

var _context_menu: PopupMenu
var _split_dialog: ConfirmationDialog
var _split_amount: SpinBox
var _inspect_dialog: AcceptDialog
var _context_instance_id: StringName = &""

func _ready() -> void:
	backpack_button.pressed.connect(open_backpack)
	inventory_close_button.pressed.connect(close_backpack)
	inventory_grid.item_activated.connect(_on_item_activated)
	inventory_grid.item_context_requested.connect(_on_item_context_requested)
	inventory_grid.item_drop_requested.connect(_on_item_drop_requested)
	continue_button.pressed.connect(close_system_menu)
	system_backpack_button.pressed.connect(_open_backpack_from_system_menu)
	save_button.pressed.connect(_save_from_system_menu)
	_setup_context_controls()
	inventory_modal.visible = false
	system_menu.visible = false

func handle_input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if inventory_modal.visible:
			close_backpack()
		elif system_menu.visible:
			close_system_menu()
		else:
			open_system_menu()
		return true
	if event.is_action_pressed("open_inventory"):
		if system_menu.visible:
			close_system_menu()
		if inventory_modal.visible:
			close_backpack()
		else:
			open_backpack()
		return true
	if event.is_action_pressed("save_game") and system_menu.visible:
		_save_from_system_menu()
		return true
	return false

func open_backpack() -> void:
	_refresh_inventory()
	inventory_status.text = "拖动整理格子；单击查看，右键使用、装备或拆分。"
	inventory_modal.visible = true

func close_backpack() -> void:
	if _context_menu != null:
		_context_menu.hide()
	inventory_modal.visible = false

func open_system_menu() -> void:
	system_status.text = "系统菜单已打开"
	system_menu.visible = true
	continue_button.grab_focus()

func close_system_menu() -> void:
	system_menu.visible = false

func is_backpack_open() -> bool:
	return inventory_modal.visible

func is_system_menu_open() -> bool:
	return system_menu.visible

func _refresh_inventory() -> void:
	var session := _get_session()
	inventory_grid.set_inventory(BACKPACK_ID, session.get_container_snapshot(BACKPACK_ID))
	weight_label.text = "负重 %d/%d" % [session.get_container_total_weight(BACKPACK_ID), session.get_container_maximum_weight(BACKPACK_ID)]
	var equipped: Dictionary = session.get_equipped_weapon_snapshot()
	equipment_status.text = "主武器：%s · 近战伤害 %d%s" % [
		String(equipped.get("display_name", "空手")),
		int(equipped.get("damage", 2)),
		" · 体力 %d · 噪声 %d" % [int(equipped.get("stamina_cost", 0)), int(equipped.get("noise", 0))] if StringName(equipped.get("item_id", "")) != &"" else "",
	]

func _on_item_activated(container_id: StringName, instance_id: StringName) -> void:
	if container_id != BACKPACK_ID:
		return
	_context_instance_id = instance_id
	var item := _get_item(instance_id)
	if not item.is_empty():
		_show_item_details(item)

func _on_item_context_requested(container_id: StringName, instance_id: StringName, screen_position: Vector2i) -> void:
	if container_id != BACKPACK_ID:
		return
	var item := _get_item(instance_id)
	if item.is_empty():
		return
	_context_instance_id = instance_id
	_context_menu.clear()
	var item_id := StringName(item["item_id"])
	var use_text := ITEM_CATALOG_SCRIPT.get_use_menu_text(item_id)
	if not use_text.is_empty():
		_context_menu.add_item(use_text, ACTION_USE)
	if ITEM_CATALOG_SCRIPT.is_weapon(item_id):
		var equipped: Dictionary = _get_session().get_equipped_weapon_snapshot()
		var is_equipped := StringName(equipped.get("instance_id", "")) == instance_id
		_context_menu.add_item("卸下主武器" if is_equipped else "装备为主武器", ACTION_UNEQUIP if is_equipped else ACTION_EQUIP)
	if int(item.get("quantity", 1)) >= 2:
		_context_menu.add_separator()
		_context_menu.add_item("拆分一半", ACTION_SPLIT_HALF)
		_context_menu.add_item("拆分指定数量…", ACTION_SPLIT_CUSTOM)
	_context_menu.add_separator()
	_context_menu.add_item("查看详情", ACTION_INSPECT)
	_context_menu.popup(Rect2i(screen_position, Vector2i(MENU_WIDTH, 1)))
	_context_menu.size = Vector2i(MENU_WIDTH, _context_menu.size.y)

func _on_context_action(action_id: int) -> void:
	var item := _get_item(_context_instance_id)
	if item.is_empty():
		inventory_status.text = "物品已不存在。"
		return
	var session := _get_session()
	var result: Dictionary = {}
	match action_id:
		ACTION_USE:
			result = session.use_item_in_container(BACKPACK_ID, _context_instance_id)
		ACTION_EQUIP:
			result = session.equip_weapon(_context_instance_id)
		ACTION_UNEQUIP:
			result = session.unequip_weapon()
		ACTION_SPLIT_HALF:
			_finish_inventory_change(session.split_item_stack(BACKPACK_ID, _context_instance_id, max(1, int(item.get("quantity", 1)) / 2)), "物品堆已拆分。", "没有空格或数量无效。")
			return
		ACTION_SPLIT_CUSTOM:
			_show_split_dialog(int(item.get("quantity", 1)))
			return
		ACTION_INSPECT:
			_show_item_details(item)
			return
	if not bool(result.get("ok", false)):
		inventory_status.text = String(result.get("message", "操作没有变化。"))
		return
	_finish_inventory_change(true, String(result.get("message", "操作完成。")), "操作失败。")

func _on_item_drop_requested(source_container_id: StringName, instance_id: StringName, target_container_id: StringName, target_cell: Vector2i) -> void:
	if source_container_id != BACKPACK_ID or target_container_id != BACKPACK_ID:
		inventory_status.text = "外出时只能整理随身背包。"
		return
	var moved: bool = _get_session().move_item_in_container(BACKPACK_ID, instance_id, target_cell.x, target_cell.y)
	_finish_inventory_change(moved, "已移动到背包格 (%d,%d)。" % [target_cell.x + 1, target_cell.y + 1], "该格无法放置，物品保持原位。")

func _finish_inventory_change(ok: bool, success_text: String, failure_text: String) -> void:
	if not ok:
		inventory_status.text = failure_text
		return
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	inventory_status.text = "%s%s" % [success_text, " 已自动保存。" if bool(save_result.get("ok", false)) else " 自动保存失败。"]
	_refresh_inventory()
	inventory_changed.emit()

func _setup_context_controls() -> void:
	_context_menu = PopupMenu.new()
	_context_menu.name = "ItemContextMenu"
	_apply_popup_theme(_context_menu)
	_context_menu.id_pressed.connect(_on_context_action)
	add_child(_context_menu)
	_split_dialog = ConfirmationDialog.new()
	_split_dialog.name = "SplitDialog"
	_split_dialog.title = "拆分物品堆"
	_apply_popup_theme(_split_dialog)
	_split_dialog.confirmed.connect(_on_split_confirmed)
	_split_amount = SpinBox.new()
	_split_amount.name = "Amount"
	_split_amount.custom_minimum_size = Vector2(112, 18)
	_split_amount.step = 1
	_split_amount.allow_greater = false
	_split_amount.allow_lesser = false
	_split_dialog.add_child(_split_amount)
	add_child(_split_dialog)
	_inspect_dialog = AcceptDialog.new()
	_inspect_dialog.name = "InspectDialog"
	_inspect_dialog.title = "物品详情"
	_apply_popup_theme(_inspect_dialog)
	var details := Label.new()
	details.name = "Details"
	details.custom_minimum_size = Vector2(160, 58)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_font_size_override("font_size", FONT_SIZE)
	_inspect_dialog.add_child(details)
	add_child(_inspect_dialog)

func _show_split_dialog(quantity: int) -> void:
	if quantity < 2:
		return
	_split_amount.min_value = 1
	_split_amount.max_value = quantity - 1
	_split_amount.value = max(1, int(quantity / 2))
	_split_dialog.dialog_text = "从当前物品堆拆出多少个？"
	_split_dialog.popup_centered(Vector2i(172, 82))

func _on_split_confirmed() -> void:
	var split_ok: bool = _get_session().split_item_stack(BACKPACK_ID, _context_instance_id, int(_split_amount.value))
	_finish_inventory_change(split_ok, "物品堆已拆分。", "没有空格或数量无效。")

func _show_item_details(item: Dictionary) -> void:
	var item_id := StringName(item["item_id"])
	var details: Label = _inspect_dialog.get_node("Details") as Label
	details.text = "%s\n%s · %d/%d · 单格\n%s\n单件负重 %d" % [
		ITEM_CATALOG_SCRIPT.get_display_name(item_id),
		ITEM_CATALOG_SCRIPT.get_category(item_id),
		int(item.get("quantity", 1)),
		int(item.get("maximum_stack", 1)),
		ITEM_CATALOG_SCRIPT.get_effect_text(item_id),
		int(item.get("weight", 0)),
	]
	_inspect_dialog.popup_centered(Vector2i(184, 104))

func _apply_popup_theme(popup: Window) -> void:
	popup.add_theme_font_size_override("font_size", FONT_SIZE)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.08, 0.09, 0.96)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.50, 0.56, 0.47, 0.92)
	popup.add_theme_stylebox_override("panel", panel_style)

func _get_item(instance_id: StringName) -> Dictionary:
	for item in _get_session().get_container_items(BACKPACK_ID):
		if StringName(item.get("instance_id", "")) == instance_id:
			return item
	return {}

func _get_session() -> ApocalypseSession:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	return apocalypse_run.ensure_active_session()

func _open_backpack_from_system_menu() -> void:
	close_system_menu()
	open_backpack()

func _save_from_system_menu() -> void:
	var apocalypse_run: Variant = get_node(NodePath("/root/ApocalypseRun"))
	var save_result: Dictionary = apocalypse_run.save_active_session()
	system_status.text = "保存完成" if bool(save_result.get("ok", false)) else "保存失败"
