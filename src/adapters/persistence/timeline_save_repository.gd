class_name TimelineSaveRepository
extends RefCounted

const SAVE_SCHEMA_VERSION := 1
const NORMAL_TIMELINE_KIND := "normal"
const DEFAULT_ROOT_PATH := "user://saves/normal"
const VALID_SLOT_NAMES := ["slot_1", "slot_2", "slot_3", "auto_1", "auto_2", "auto_3"]

var _root_path: String
var _timeline_kind: String

func _init(root_path: String = DEFAULT_ROOT_PATH, timeline_kind: String = NORMAL_TIMELINE_KIND) -> void:
	assert(not timeline_kind.is_empty(), "A timeline repository requires a timeline kind.")
	_root_path = root_path
	_timeline_kind = timeline_kind

func save_slot(slot_name: String, snapshot: Dictionary) -> Dictionary:
	if not _is_valid_slot_name(slot_name):
		return _failure("Unknown save slot: %s" % slot_name)
	if snapshot.is_empty():
		return _failure("Cannot save an empty snapshot.")
	if not _ensure_root_directory():
		return _failure("Cannot create save directory.")

	var payload := {
		"save_schema_version": SAVE_SCHEMA_VERSION,
		"timeline_kind": _timeline_kind,
		"snapshot": snapshot,
	}
	var temporary_path := _temporary_path(slot_name)
	var temporary_file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if temporary_file == null:
		return _failure("Cannot open temporary save file.")
	temporary_file.store_string(JSON.stringify(payload))
	temporary_file.flush()
	temporary_file.close()

	var primary_path := _primary_path(slot_name)
	var backup_path := _backup_path(slot_name)
	var primary_moved_to_backup := false
	if FileAccess.file_exists(primary_path):
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(_absolute_path(backup_path))
		var backup_error := DirAccess.rename_absolute(
			_absolute_path(primary_path),
			_absolute_path(backup_path),
		)
		if backup_error != OK:
			_remove_if_present(temporary_path)
			return _failure("Cannot preserve the previous save as a backup.")
		primary_moved_to_backup = true

	var promote_error := DirAccess.rename_absolute(
		_absolute_path(temporary_path),
		_absolute_path(primary_path),
	)
	if promote_error != OK:
		if primary_moved_to_backup:
			DirAccess.rename_absolute(_absolute_path(backup_path), _absolute_path(primary_path))
		_remove_if_present(temporary_path)
		return _failure("Cannot promote the completed temporary save.")

	return {"ok": true, "slot_name": slot_name}

func load_slot(slot_name: String) -> Dictionary:
	if not _is_valid_slot_name(slot_name):
		return _failure("Unknown save slot: %s" % slot_name)

	var primary_result := _load_path(_primary_path(slot_name))
	if primary_result.get("ok", false):
		primary_result["used_backup"] = false
		return primary_result

	var backup_result := _load_path(_backup_path(slot_name))
	if backup_result.get("ok", false):
		backup_result["used_backup"] = true
		return backup_result

	return _failure("No valid save was found for %s." % slot_name)

func _load_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("Save file does not exist.")

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("Cannot open save file.")
	var serialized_payload := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(serialized_payload) != OK:
		return _failure("Save file is not valid JSON.")
	var payload_value: Variant = json.data
	if not payload_value is Dictionary:
		return _failure("Save payload must be an object.")
	var payload: Dictionary = payload_value
	var schema_version: int = int(payload.get("save_schema_version", 0))
	if schema_version != SAVE_SCHEMA_VERSION:
		return _failure("Unsupported save schema version: %d" % schema_version)
	if str(payload.get("timeline_kind", "")) != _timeline_kind:
		return _failure("Save does not belong to the requested timeline.")
	var snapshot_value: Variant = payload.get("snapshot")
	if not snapshot_value is Dictionary or snapshot_value.is_empty():
		return _failure("Save does not contain a valid snapshot.")

	return {"ok": true, "snapshot": snapshot_value}

func _ensure_root_directory() -> bool:
	return DirAccess.make_dir_recursive_absolute(_absolute_path(_root_path)) == OK

func _is_valid_slot_name(slot_name: String) -> bool:
	return slot_name in VALID_SLOT_NAMES

func _primary_path(slot_name: String) -> String:
	return _root_path.path_join("%s.json" % slot_name)

func _backup_path(slot_name: String) -> String:
	return _root_path.path_join("%s.backup.json" % slot_name)

func _temporary_path(slot_name: String) -> String:
	return _root_path.path_join("%s.temporary.json" % slot_name)

func _absolute_path(path: String) -> String:
	return ProjectSettings.globalize_path(path)

func _remove_if_present(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(_absolute_path(path))

func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}
