@tool
extends CharacterBody3D
class_name Snaker3000

signal died()

var val_list = []
var _segments: Array[Node3D] = []
@export var initial_size: int = 3:
	set(value):
		if initial_size == value: return
		initial_size = max(1, value)
		_setup_segments()

var _should_grow: bool = false

@onready var camera: Camera = get_viewport().get_camera_3d()
var material = preload("res://snakegame/new_standard_material_3d.tres")


func grow():
	_should_grow = true


func kill():
	_setup_segments()
	died.emit()


func _ready():
	_disable_process(Engine.is_editor_hint())
	if not Engine.is_editor_hint():
		%Timer.on_timed_input.connect(_on_movement_input)
	_setup_segments()


func _on_movement_input(direction: Vector3):
	for s in _segments:
		s.global_position = (s.global_position.snapped(Vector3.ONE) * Vector3(1,0,1)) + (s.global_position * Vector3(0,1,0))
	if _should_grow == true:
		_add_segment()
		_should_grow = false
	_move(direction)


func _move(direction: Vector3):
	if will_collide_if_moved(_segments[0].global_position + direction):
		camera.add_trauma(.5)
	else:
		val_list.clear()
		val_list.resize(_segments.size())
		val_list.fill(Vector3.ZERO)
		for i in range(_segments.size() - 1, 0, -1):
			var tween := create_tween()
			tween.tween_method(move_head.bind(i), Vector3.ZERO, _segments[i - 1].global_position - _segments[i].global_position, %Timer.wait_time)
		var tween := create_tween()
		tween.tween_method(move_head.bind(0), Vector3.ZERO, direction, %Timer.wait_time)


func move_head(val, index):
	_segments[index].global_position += val - val_list[index]
	val_list[index] = val


func move_body():
	for i in range(_segments.size() - 1, 0, -1):
			_segments[i].global_position = _segments[i - 1].global_position


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


func _setup_segments():
	for segment in _segments:
		segment.queue_free()
	_segments.clear()
	for i in range(initial_size):
		_add_segment()


func _add_segment():
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3.ONE
	
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.disabled = false
	
	var body := MeshInstance3D.new()
	body.mesh = box
	body.material_override = material
	body.set_layer_mask_value(1,false)
	body.set_layer_mask_value(20,true)
	
	var direction = Vector3(1, 0, 0)
	if _segments.size() > 2:
		direction = _segments[_segments.size() - 1].global_position.direction_to(_segments[_segments.size() - 2].global_position)
	
	var init_pos = global_position
	if _segments.size() > 0:
		init_pos = _segments[_segments.size() - 1].global_position
	var pos = init_pos - direction
	
	_segments.append(collision)
	add_child(collision)
	collision.add_child(body)
	collision.global_position = pos


func _disable_process(value: bool):
	process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_ALWAYS
