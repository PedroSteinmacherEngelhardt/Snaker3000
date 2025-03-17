@tool

class_name SuneikoTreisMill
extends CharacterBody3D

var points = []
var size = 1

@export var camera: Camera
@export var initial_size : int = 1
@onready var spawnpoint := global_position

var material = preload("res://snakegame/new_standard_material_3d.tres")

func _ready():
	spawn()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var direction = Vector3.ZERO
	if Input.is_action_just_pressed("left"):
		direction.x += 1
	elif Input.is_action_just_pressed("right"):
		direction.x -= 1
	elif Input.is_action_just_pressed("forward"):
		direction.z += 1
	elif Input.is_action_just_pressed("backward"):
		direction.z -= 1
	elif Input.is_action_just_pressed("space"):
		direction.y +=1
	elif Input.is_action_just_pressed("shift"):
		direction.y -=1
	
	direction = -direction.rotated(Vector3.UP, camera.rotation.y).normalized()
	direction.y *=-1
	
	if direction:
		if will_collide_if_moved(points[0].global_position + direction):
			camera.add_trauma(.5)
		else:
			move_body()
			points[0].global_position += direction


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
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
	
	if points.size() > 0:
		spawnpoint = points[points.size() - 1].global_position
	var pos = spawnpoint - (size * direction)
	
	#print(spawnpoint, " | ", direction, " | ", pos)
	#body.global_position = pos
	
	points.append(collision)
	add_child(collision)
	collision.add_child(body)
	collision.global_position = pos
	collision.rotation.y = camera.rotation.y
	
	
func got_dunked():
	for point in points:
		point.queue_free()
	points.clear()
	spawn()


func spawn():
	for n in range(initial_size):
		add_box()
