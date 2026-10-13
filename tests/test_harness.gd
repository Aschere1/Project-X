class_name TestHarness
extends RefCounted

var failures: Array[String] = []
var assertion_count := 0

func expect_true(actual: bool, message: String) -> void:
	assertion_count += 1
	if not actual:
		failures.append(message)

func expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	assertion_count += 1
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])
