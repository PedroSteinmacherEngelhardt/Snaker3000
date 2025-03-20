@tool
extends Node


var _pressed_actions: Set = Set.new()
var _input_buffer: Vector3 = Vector3.ZERO

const _actions_map: Dictionary[String, Vector3] = {
	"move_north": Vector3.FORWARD,
	"move_south": Vector3.BACK,
	"move_west": Vector3.LEFT,
	"move_east": Vector3.RIGHT,
	"move_up": Vector3.UP,
	"move_down": Vector3.DOWN,
}


signal on_timed_input(direction: Vector3)


func _input(event):
	for action in _actions_map.keys():
		var direction = _actions_map[action]
		if event.is_action_pressed(action):
			_pressed_actions.append(direction)
			_input_buffer = direction
			_movement_loop()
		if event.is_action_released(action):
			_pressed_actions.remove(direction)


func _movement_loop() -> void:
	if not $Timer.is_stopped():
		return
	
	var direction: Vector3
	
	var actions = _pressed_actions.values
	if _input_buffer != Vector3.ZERO:
		direction = _input_buffer
		_input_buffer = Vector3.ZERO
	elif not actions.is_empty():
		direction = actions.front()
	else:
		return

	on_timed_input.emit(direction)
	$Timer.start(get_parent().wait_time)
	await $Timer.timeout
	_movement_loop()
