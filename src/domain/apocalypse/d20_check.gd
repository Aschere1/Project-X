class_name D20Check
extends RefCounted

const MAJOR_FAILURE := &"major_failure"
const FAILURE_FORWARD := &"failure_forward"
const COSTLY_SUCCESS := &"costly_success"
const SUCCESS := &"success"
const MAJOR_SUCCESS := &"major_success"

const MINIMUM_ROLL := 1
const MAXIMUM_ROLL := 20
const MAJOR_SUCCESS_MARGIN := 5
const FAILURE_FORWARD_MARGIN := -2

func resolve(natural_roll: int, difficulty: int, modifier: int = 0) -> Dictionary:
	assert(natural_roll >= MINIMUM_ROLL and natural_roll <= MAXIMUM_ROLL, "A D20 roll must be between 1 and 20.")
	assert(difficulty > 0, "A D20 check requires a positive difficulty.")

	var total := natural_roll + modifier
	var outcome_id := _get_outcome_id(natural_roll, total - difficulty)
	return {
		"natural_roll": natural_roll,
		"difficulty": difficulty,
		"modifier": modifier,
		"total": total,
		"outcome_id": outcome_id,
		"is_success": _is_success(outcome_id),
		"outcome_text": get_outcome_text(outcome_id),
	}

func get_outcome_text(outcome_id: StringName) -> String:
	match outcome_id:
		MAJOR_FAILURE:
			return "重大失败"
		FAILURE_FORWARD:
			return "失败推进"
		COSTLY_SUCCESS:
			return "代价成功"
		SUCCESS:
			return "成功"
		MAJOR_SUCCESS:
			return "重大成功"
		_:
			return "未知结果"

func _get_outcome_id(natural_roll: int, margin: int) -> StringName:
	if natural_roll == MINIMUM_ROLL:
		return MAJOR_FAILURE
	if natural_roll == MAXIMUM_ROLL:
		return MAJOR_SUCCESS
	if margin >= MAJOR_SUCCESS_MARGIN:
		return MAJOR_SUCCESS
	if margin >= 1:
		return SUCCESS
	if margin == 0:
		return COSTLY_SUCCESS
	if margin >= FAILURE_FORWARD_MARGIN:
		return FAILURE_FORWARD
	return MAJOR_FAILURE

func _is_success(outcome_id: StringName) -> bool:
	return outcome_id == COSTLY_SUCCESS or outcome_id == SUCCESS or outcome_id == MAJOR_SUCCESS
