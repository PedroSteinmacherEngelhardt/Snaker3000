@tool
extends CharacterBody3D

var points = []
var size = 1

@export var spawnpoint : Node3D
@export var camera: Camera

var material = preload("res://snakegame/new_standard_material_3d.tres")


func _get_direction():
	var pressed_actions = _pressed_actions.keys()
	return null if pressed_actions.is_empty() else _actions_map[pressed_actions.front()]


func _ready():
	_disable_process(Engine.is_editor_hint())
	add_box()
	add_box()
	add_box()


var _pressed_actions: = {}

const _actions_map: Dictionary[String, Vector3] = {
	"move_north": Vector3.FORWARD,
	"move_south": Vector3.BACK,
	"move_west": Vector3.LEFT,
	"move_east": Vector3.RIGHT,
	"move_up": Vector3.UP,
	"move_down": Vector3.DOWN,
}


var _is_moving: bool = false


func _input(event):
	for action in _actions_map.keys():
		if event.is_action_pressed(action):
			_pressed_actions[action] = null
			_input_buffer.append(_actions_map[action])
			_start_movement(_move)
		if event.is_action_released(action):
			_pressed_actions.erase(action)


var _input_buffer = []


func _start_movement(handle_movement: Callable):
	if _is_moving:
		return
	
	_is_moving = true
	
	if $Timer.is_stopped():
		var direction = _get_direction()
		if not direction:
			_is_moving = false
			return
		
		handle_movement.call(direction)
		
		$Timer.start()
		
	while not _input_buffer.is_empty() or not _pressed_actions.is_empty():
		await $Timer.timeout
		if not _input_buffer.is_empty():
			handle_movement.call(_input_buffer.pop_back())
		else:
			var direction = _get_direction()
			if not direction:
				break
				
			handle_movement.call(direction)
		
		$Timer.start()
		
	_is_moving = false


func _move(direction: Vector3):
	if will_collide_if_moved(points[0].global_position + direction):
		camera.add_trauma(.5)
	else:
		move_body()
		points[0].global_position += direction


func _physics_process(delta):
	if not is_on_floor():
		velocity = velocity + get_gravity() * delta
		
	move_and_slide()


func move_body():
	for i in range(points.size()-1, 0, -1):
			points[i].global_position = points[i-1].global_position


func will_collide_if_moved(new_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	
	var box = BoxShape3D.new()
	box.size *= Vector3.ONE * .99
	query.shape = box
	
	var rotation = Basis().rotated(Vector3.UP, camera.rotation.y)
	query.transform = Transform3D(rotation, new_position)
	
	var results = space_state.intersect_shape(query)
	
	return results.size() > 0


func add_box():
	var box : BoxMesh = BoxMesh.new()
	box.size = Vector3.ONE * size
	
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.disabled = false
	
	var body := MeshInstance3D.new()
	body.mesh = box
	body.material_override = material
	
	var direction = Vector3(1,0,0).rotated(Vector3.UP, camera.rotation.y).normalized()
	if points.size() > 2:
		direction = points[points.size() - 1].global_position.direction_to(points[points.size() - 2].global_position)
	
	var init_pos = global_position
	if points.size() > 0:
		init_pos = points[points.size() - 1].global_position
	var pos = init_pos - (size * direction)
	
	#print(init_pos, " | ", direction, " | ", pos)
	#body.global_position = pos
	
	points.append(collision)
	add_child(collision)
	collision.add_child(body)
	collision.global_position = pos
	collision.rotation.y = camera.rotation.y


func _disable_process(value: bool):
	process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_ALWAYS
