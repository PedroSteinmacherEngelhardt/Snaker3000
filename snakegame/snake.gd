@tool
extends CharacterBody3D

var points = []
@export var initial_size = 3: set = _set_initial_size

var should_grow = false

@onready var spawnpoint := global_position
@onready var camera: Camera = %Camera

var material = preload("res://snakegame/new_standard_material_3d.tres")


func _ready():
	_disable_process(Engine.is_editor_hint())
	_set_initial_size(initial_size)
	

func _set_initial_size(size):
	initial_size = max(1, size)
	for p in points:
		p.queue_free()
	points.clear()
	for p in initial_size:
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
			_pressed_actions[_actions_map[action]] = null
			_input_buffer.append(_actions_map[action])
			_movement_loop()
		if event.is_action_released(action):
			_pressed_actions.erase(_actions_map[action])


var _input_buffer = []


func _movement_loop() -> void:
	if not $Timer.is_stopped():
		return

	var direction: Vector3

	var actions = _pressed_actions.keys()
	if not _input_buffer.is_empty():
		direction = _input_buffer.pop_back()
	elif not actions.is_empty():
		direction = actions.front()
	else:
		return
	_move(direction)
	$Timer.start()
	await $Timer.timeout
	if should_grow:
		add_box()
	_movement_loop()

var val_list = []

func _move(direction: Vector3):
	if will_collide_if_moved(points[0].global_position + direction):
		camera.add_trauma(.5)
	else:
		val_list.clear()
		val_list.resize(points.size())
		val_list.fill(Vector3.ZERO)
		for i in range(points.size()-1, 0, -1):
			var tween := create_tween()
			tween.tween_method(move_head.bind(i), Vector3.ZERO, points[i-1].global_position - points[i].global_position, $Timer.wait_time)
		var tween := create_tween()
		tween.tween_method(move_head.bind(0), Vector3.ZERO, direction, $Timer.wait_time)



func move_head(val, index):
	points[index].global_position += val - val_list[index]
	val_list[index] = val


func move_body():
	for i in range(points.size()-1, 0, -1):
			points[i].global_position = points[i-1].global_position


func _physics_process(delta):
	if not is_on_floor():
		velocity = velocity + get_gravity() * delta * 2
		
	move_and_slide()


func will_collide_if_moved(new_position: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsShapeQueryParameters3D.new()
	
	var box = BoxShape3D.new()
	box.size *= Vector3.ONE * .40
	query.shape = box
	
	var rotation = Basis().rotated(Vector3.UP, camera.rotation.y)
	query.transform = Transform3D(rotation, new_position)
	
	var results = space_state.intersect_shape(query)
	
	return results.size() > 0


func grow():
	should_grow = true


func add_box():
	should_grow = false
	var box : BoxMesh = BoxMesh.new()
	box.size = Vector3.ONE
	
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.disabled = false
	
	var body := MeshInstance3D.new()
	body.mesh = box
	body.material_override = material
	
	var direction = Vector3(1,0,0)
	if points.size() > 2:
		direction = points[points.size() - 1].global_position.direction_to(points[points.size() - 2].global_position)
	
	var init_pos = global_position
	if points.size() > 0:
		init_pos = points[points.size() - 1].global_position
	var pos = init_pos - direction
	
	points.append(collision)
	add_child(collision)
	collision.add_child(body)
	collision.global_position = pos


func _disable_process(value: bool):
	process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_ALWAYS
