extends Control
class_name MinigameInterface

# THE ONLY CONTRACT THE HOST WORKSHOP NEEDS.
# The minigame does not know what the host does with output materials.
signal minigame_finished(result: Dictionary)
var config: Dictionary = {}
var running := false
var paused := false

func start(config_override: Dictionary = {}) -> void:
	if not config_override.is_empty():
		config = config_override.duplicate(true)
	running = true
	paused = false

func pause() -> void:
	paused = true

func resume() -> void:
	paused = false

func get_score() -> int:
	return 0
