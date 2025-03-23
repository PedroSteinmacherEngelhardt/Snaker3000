extends Node3D
class_name World

@export var world_name: String = "Base World"
@export var blades_per_tile = 500
@export var position_variance = .5
@export var scale_variance = 0.5
signal world_completed(world_name: String);


var _replaceble_cells = {
	2: "res://scenes/grow!.tscn"
}


func _ready():
	_replace_gridmap()
	#%Snaker3000.connect("died",_on_snaker_3000_died)
	#$Death.connect("body_entered", _on_snaker_3000_died)


func _replace_gridmap():
	var gridmap = %GridMap
	var grass_positions = []
	var instance_transforms = []

	for cell in gridmap.get_used_cells():
		var tile_id = gridmap.get_cell_item(cell)
	
		if tile_id == 1:
			var base_pos = gridmap.map_to_local(cell)
			
			for _a in range(blades_per_tile):
				var random_offset = Vector3(
					randf_range(-position_variance, position_variance),
					0,
					randf_range(-position_variance, position_variance)
				)
				
				var world_pos = base_pos + random_offset + gridmap.position
				world_pos.y += 0.5
				
				var rotation = Basis()
				rotation = rotation.rotated(Vector3.UP, randf_range(0, TAU))  # Random Y rotation (yaw)
				rotation = rotation.rotated(Vector3.RIGHT, randf_range(-0.2, 0.2))  # Random X inclination (tilt forward/back)
				rotation = rotation.rotated(Vector3.FORWARD, randf_range(-0.2, 0.2))  # Random Z inclination (tilt left/right)
				
				var transform = Transform3D(rotation, world_pos)
				transform = transform.scaled(scale)
				
				instance_transforms.append(transform)
	
	var multimesh = %MultiMeshInstance3D.multimesh
	multimesh.instance_count = instance_transforms.size()
	
	for i in range(instance_transforms.size()):
		multimesh.set_instance_transform(i, instance_transforms[i])


func _on_death_body_entered(maybeASnaker3000):
	if maybeASnaker3000 is Snaker3000:
		var snaker3000 = maybeASnaker3000
		snaker3000.kill()


func _on_exit_body_entered(maybeASnaker3000):
	if maybeASnaker3000 is Snaker3000:
		world_completed.emit(world_name)
		var snaker3000 = maybeASnaker3000
		snaker3000.kill()


func _on_snaker_3000_died(body):
	print("aaaa")
	get_tree().reload_current_scene()
