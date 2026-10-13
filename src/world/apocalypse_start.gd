extends Control

const SHELTER_SCENE_PATH := "res://scenes/world/apocalypse_shelter.tscn"

@onready var status_label: Label = $Margin/Panel/VBox/Status
@onready var continue_button: Button = $Margin/Panel/VBox/Buttons/ContinueButton
@onready var new_game_button: Button = $Margin/Panel/VBox/Buttons/NewGameButton
@onready var confirmation: Control = $Margin/Panel/VBox/NewGameConfirmation
@onready var confirmation_text: Label = $Margin/Panel/VBox/NewGameConfirmation/VBox/Message
@onready var confirm_button: Button = $Margin/Panel/VBox/NewGameConfirmation/VBox/Buttons/Confirm
@onready var cancel_button: Button = $Margin/Panel/VBox/NewGameConfirmation/VBox/Buttons/Cancel

var _apocalypse_run: Variant

func _ready() -> void:
	_apocalypse_run = get_node(NodePath("/root/ApocalypseRun"))
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	confirm_button.pressed.connect(_on_confirm_new_game_pressed)
	cancel_button.pressed.connect(_on_cancel_new_game_pressed)
	confirmation.visible = false
	_refresh_entry_state()
	continue_button.grab_focus()
	print("APOCALYPSE_START_READY continue=%s" % str(not continue_button.disabled))

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if confirmation.visible:
		_on_cancel_new_game_pressed()
		get_viewport().set_input_as_handled()

func _refresh_entry_state() -> void:
	var summary: Dictionary = _apocalypse_run.get_continue_summary()
	var available := bool(summary.get("available", false))
	continue_button.disabled = not available
	if available:
		status_label.text = String(summary.get("message", "已发现可继续的自动存档。"))
		if bool(summary.get("used_backup", false)):
			status_label.text += "（主档损坏，已使用备份）"
	else:
		status_label.text = String(summary.get("message", "没有可继续的自动存档。"))

func _on_continue_pressed() -> void:
	_apocalypse_run.continue_session()
	get_tree().change_scene_to_file(SHELTER_SCENE_PATH)

func _on_new_game_pressed() -> void:
	confirmation_text.text = "开始新游戏会覆盖当前自动存档。\n确认后将从第 1 日 06:00 的庇护所开始。"
	confirmation.visible = true
	confirm_button.grab_focus()

func _on_confirm_new_game_pressed() -> void:
	var result: Dictionary = _apocalypse_run.start_new_session_and_save()
	if not bool(result.get("ok", false)):
		confirmation_text.text = "自动存档写入失败，请稍后重试。"
		return
	get_tree().change_scene_to_file(SHELTER_SCENE_PATH)

func _on_cancel_new_game_pressed() -> void:
	confirmation.visible = false
	new_game_button.grab_focus()
