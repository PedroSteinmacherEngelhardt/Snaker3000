@tool
extends CharacterBody3D
class_name Snake3000

@export var initial_size: int = 3: set = _set_initial_size
func _set_initial_size(value: int):
	if value == initial_size:
		return
	initial_size = max(value, 1)
	_setup_segments()

var _segments: Array[Node3D] = []

func _validate_movement(direction) -> bool:
	if $Head.global_transform.basis.z.is_equal_approx(direction):
		return false
	if direction == Vector3.UP and not is_on_floor():
		return false
		
	return true

func _move(direction: Vector3):
	direction =  direction.rotated(Vector3.UP, get_viewport().get_camera_3d().rotation.y)
	
	if not _validate_movement(direction):
		return 
	
	position += direction
	
	$Head.look_at(direction + position, Vector3.UP if abs(direction) != Vector3.UP else Vector3.LEFT)
	
	direction = direction.rotated(Vector3.UP, rotation.y)
	
	var back = _segments.pop_back()
	back.position = -direction
	
	for segment in _segments:
		segment.position -= direction
		
	_segments.push_front(back)


func _ready():
	_disable_process(Engine.is_editor_hint())
	$CustomInput.on_movement.connect(_move)
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
