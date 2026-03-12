extends Control

var _test_paths: Array[String]
var _test_menu_popup: PopupMenu
var _input_method_popup: PopupMenu

var _current_test: Control

var implementations : Array[InputImplementation] = [
	preload("res://implementations/Godot.gd").new(),
	preload("res://implementations/BalloonCenter.gd").new(),
	preload("res://implementations/BalloonEdgeTowardsCenter.gd").new(),
	preload("res://implementations/BalloonEdge.gd").new()
]

var _current_implementation : InputImplementation

@onready var test_menu: MenuButton = %TestSceneMenu
@onready var test_parent: Control = %TestSceneRoot
@onready var current_test_label: Label = %CurrentTestScene
@onready var current_input_method: Label = %CurrentInputMethod
@onready var input_method_menu: MenuButton = %InputMethodMenu
@onready var print_scores: CheckButton = %PrintScores
@onready var draw_debug: CheckButton = %DrawDebug


func _ready() -> void:
	for path in DirAccess.open("res://tests/").get_files():
		_test_paths.push_back(path.trim_suffix(".remap"))
	
	_test_menu_popup = test_menu.get_popup()
	_test_menu_popup.index_pressed.connect(_on_popup_index_pressed)
	
	for path: String in _test_paths:
		_test_menu_popup.add_item(path)
	
	_input_method_popup = input_method_menu.get_popup()
	_input_method_popup.index_pressed.connect(_on_input_method_selected)
	
	for impl: InputImplementation in implementations:
		_input_method_popup.add_item(impl.friendly_name())
	
	await get_tree().process_frame
	
	_on_popup_index_pressed(_test_paths.size() - 1)
	_on_input_method_selected(0)

func _input(event: InputEvent) -> void:
	if not _current_implementation: return

	if is_ui_input(event):
		var input_dir = calculate_ui_input_dir(event)
		var control_nodes = get_control_nodes()
		var current_node = get_viewport().gui_get_focus_owner()
		_current_implementation._debug_draw_points.clear()
		var focused_control := _current_implementation._input(input_dir, control_nodes, current_node)
		if focused_control:
			queue_redraw()
			get_viewport().set_input_as_handled() # Avoid further input propagation
			focused_control.grab_focus()

func _draw() -> void:
	if _current_implementation and draw_debug.button_pressed:
		for debug_point : InputImplementation.DrawPoint in _current_implementation._debug_draw_points:
			if debug_point is InputImplementation.DrawCircle:
				draw_circle(debug_point.position, debug_point.radius, debug_point.color, false, 2)
			else:
				draw_circle(debug_point.position, 4, debug_point.color)

func _on_popup_index_pressed(index: int) -> void:
	if is_instance_valid(_current_test):
		_current_test.queue_free()
	
	var ps: PackedScene = load("res://tests/" + _test_paths[index]) as PackedScene
	
	if not is_instance_valid(ps):
		current_test_label.text = "Failed to load test at path: res://tests/" + _test_paths[index]
		return
	
	_current_test = ps.instantiate()
	
	test_parent.add_child(_current_test)
	
	_current_test.position = (test_parent.size / 2.0) - (_current_test.size / 2.0)
	
	current_test_label.text = "Current test: " + _test_paths[index]
	
	var first_button: Button = _current_test.find_child("Start")
	
	if is_instance_valid(first_button):
		first_button.grab_focus()

func _on_input_method_selected(index: int) -> void:
	if _current_implementation:
		_current_implementation._end()
	
	_current_implementation = implementations[index]
	_current_implementation._begin()
	
	# Only enable toggles on custom implementations
	print_scores.disabled = index == 0
	draw_debug.disabled = index == 0
	
	current_input_method.text = "Current method: %s" % _current_implementation.friendly_name()

func is_ui_input(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_left") or \
		event.is_action_pressed("ui_right") or \
		event.is_action_pressed("ui_up") or \
		event.is_action_pressed("ui_down") or \
		event.is_action_pressed("custom_ui_left") or \
		event.is_action_pressed("custom_ui_right") or \
		event.is_action_pressed("custom_ui_up") or \
		event.is_action_pressed("custom_ui_down")

func calculate_ui_input_dir(event: InputEvent) -> Vector2:
	var dir := Vector2.ZERO
	if event.is_action_pressed("ui_left") or event.is_action_pressed("custom_ui_left"):
		dir += Vector2.LEFT
	if event.is_action_pressed("ui_right") or event.is_action_pressed("custom_ui_right"):
		dir += Vector2.RIGHT
	if event.is_action_pressed("ui_up") or event.is_action_pressed("custom_ui_up"):
		dir += Vector2.UP
	if event.is_action_pressed("ui_down") or event.is_action_pressed("custom_ui_down"):
		dir += Vector2.DOWN
	return dir.normalized()

func get_control_nodes(root: Node = test_parent, accum : Array[Control] = []) -> Array[Control]:
	for child in root.get_children():
		if child.get_child_count() > 0:
			get_control_nodes(child, accum)
		# Only consider Control nodes
		if child is Control and \
		# Skip the currently focused control
		child != get_viewport().gui_get_focus_owner() and \
		# Include only focusable controls
		child.focus_mode != FOCUS_NONE:
			accum.push_back(child)
	return accum


func _on_print_scores_toggled(toggled_on: bool) -> void:
	if _current_implementation:
		_current_implementation._print_scores = toggled_on
