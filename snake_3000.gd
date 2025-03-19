@tool
extends CharacterBody3D
class_name Snake3000

@export var initial_size: int = 3: set = _set_initial_size
func _set_initial_size(value: int):
	if value == initial_size:
		return
	initial_size = max(value, 1)
	_setup_segments()

func _get_direction():
	if not _input_buffer.is_empty():
		return _input_buffer.pop_front()
	
	var keys = _pressed_actions.keys()
	if not keys.is_empty():
		return _actions_map[keys.front()]
	
	return null


var _input_buffer = []
var _pressed_actions = {}

const _actions_map: Dictionary[String, Vector3] = {
	"move_north": Vector3.FORWARD,
	"move_south": Vector3.BACK,
	"move_west": Vector3.LEFT,
	"move_east": Vector3.RIGHT,
	"move_up": Vector3.UP,
	"move_down": Vector3.DOWN,
}


var _segments: Array[Node3D] = []


func _input(event):
	for action in _actions_map.keys():
		if event.is_action_pressed(action):
			_pressed_actions[action] = null
			_input_buffer.append(_actions_map[action])
			_movement_loop(_move)
		if event.is_action_released(action):
			_pressed_actions.erase(action)


func _movement_loop(handle_movement: Callable):
	if not $Timer.is_stopped():
		return
		
	var direction = _get_direction()
	
	if not direction:
		return
		
	handle_movement.call(direction)
	$Timer.start()
	await $Timer.timeout
	_movement_loop(handle_movement)


func _move(direction: Vector3):
	direction =  direction.rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)
	
	position += direction
	
	direction = direction.rotated(Vector3.UP, rotation.y)
	
	var back = _segments.pop_back()
	back.position = -direction
	
	for segment in _segments:
		segment.position -= direction
		
	_segments.push_front(back)


func _ready():
	_disable_process(Engine.is_editor_hint())
	_setup_segments()


func _setup_segments():
	for segment in _segments:
		segment.queue_free()
	
	_segments.clear()
	
	for i in range(initial_size - 1):
		_create_segment()


func _physics_process(delta):
	if not is_on_floor():
		velocity = velocity + get_gravity() * delta
		
	move_and_slide()


func _create_segment():
	var segment = CollisionShape3D.new()
	_segments.append(segment)
	segment.shape = BoxShape3D.new()

	var model = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	model.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())
	
	box_mesh.material = material
	
	segment.add_child(model)
	add_child(segment)
	
	segment.position = Vector3(0, 0, 1) * (_segments.size())


func grow():
	_create_segment();


func _disable_process(value: bool):
	process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_ALWAYS
