extends Node
class_name CustomInput


signal on_movement(direction: Vector3)

var _input_buffer = []
var _pressed_actions = Set.new()


const _actions_map: Dictionary[String, Vector3] = {
	"move_north": Vector3.FORWARD,
	"move_south": Vector3.BACK,
	"move_west": Vector3.LEFT,
	"move_east": Vector3.RIGHT,
	"move_up": Vector3.UP,
	"move_down": Vector3.DOWN,
}

func _input(event):
	for action in _actions_map.keys():
		var direction = _actions_map[action]
		if event.is_action_pressed(action):
			_pressed_actions.append(direction)
			_input_buffer.append(direction)
			_movement_loop()
		if event.is_action_released(action):
			_pressed_actions.remove(direction)


func _movement_loop() -> void:
	if not $Timer.is_stopped():
		return
	
	var direction: Vector3
	
	var actions = _pressed_actions.values
	if not _input_buffer.is_empty():
		direction = _input_buffer.pop_front()
	elif not actions.is_empty():
		direction = actions.front()
	else:
		return

	on_movement.emit(direction)
	$Timer.start()
	await $Timer.timeout
	_movement_loop()
