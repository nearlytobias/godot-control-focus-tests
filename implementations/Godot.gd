extends InputImplementation

## Godot default implementation. Therefore, this implementation does nothing, as
## it is the default native behavior.

func friendly_name() -> String:
	return "Godot (Default)"

func _begin() -> void:
	# Re-register default ui_X actions.
	InputMap.action_add_event("ui_left", build_key_event(KEY_LEFT))
	InputMap.action_add_event("ui_right", build_key_event(KEY_RIGHT))
	InputMap.action_add_event("ui_up", build_key_event(KEY_UP))
	InputMap.action_add_event("ui_down", build_key_event(KEY_DOWN))

func _end() -> void:
	# In order to avoid interference with custom implementation, we remove
	# the internal ui_X mappings to avoid Godot's native focus mechanism
	InputMap.action_erase_events("ui_left")
	InputMap.action_erase_events("ui_right")
	InputMap.action_erase_events("ui_up")
	InputMap.action_erase_events("ui_down")

func _input(input_dir: Vector2, nodes: Array[Control], current_node: Control) -> Control:
	# Do nothing; Godot handles it natively
	return null

func build_key_event(key: Key) -> InputEventKey:
	var event = InputEventKey.new()
	event.keycode = key
	return event
