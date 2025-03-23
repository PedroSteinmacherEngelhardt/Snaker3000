extends MultiMeshInstance3D

@export var blades_per_tile = 500
@export var position_variance = .5
@export var scale_variance = 0.5


func populate_grass(grass_positions):
	var instance_transforms = []
	
	for base_pos in grass_positions:
		for _a in range(blades_per_tile):
			var random_offset = Vector3(
				randf_range(-position_variance, position_variance),
				0,
				randf_range(-position_variance, position_variance)
			)
			var world_pos = base_pos + random_offset
			
			var rotation = Basis()
			rotation = rotation.rotated(Vector3.UP, randf_range(0, TAU))
			rotation = rotation.rotated(Vector3.RIGHT, randf_range(-0.2, 0.2))
			rotation = rotation.rotated(Vector3.FORWARD, randf_range(-0.2, 0.2))
			
			var transform = Transform3D(rotation, world_pos)
			transform = transform.scaled(scale)
			
			instance_transforms.append(transform)
	
	multimesh.instance_count = instance_transforms.size()
	for i in range(instance_transforms.size()):
		multimesh.set_instance_transform(i, instance_transforms[i])
