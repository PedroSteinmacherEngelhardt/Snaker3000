extends Node3D
class_name World

@export var world_name: String = "Base World"
@export var blades_per_tile = 500
@export var position_variance = .5
@export var scale_variance = 0.5
signal world_completed(world_name: String);


var _replaceble_cells = {
	2: preload("res://scenes/grow!.tscn")
}


func _ready():
	_replace_gridmap()


func _replace_gridmap():
	var gridmap :GridMap= %GridMap
	var grass_positions = []
	var instance_transforms = []

	for cell in gridmap.get_used_cells():
		var tile_id = gridmap.get_cell_item(cell)
		
		if _replaceble_cells.has(tile_id):
			var scene = _replaceble_cells[tile_id].instantiate()
			add_child(scene)
			scene.position = %GridMap.to_global(cell) + Vector3(0.5, 0.5, 0.5)
			%GridMap.set_cell_item(cell, -1)
		
		elif tile_id == 1:
			var up_cell = gridmap.get_cell_item(cell + Vector3i.UP)
			if up_cell == -1 or _replaceble_cells.has(up_cell):
				var base_pos = gridmap.map_to_local(cell) + gridmap.position + Vector3(0,0.5,0)
				grass_positions.append(base_pos)
	
	%MultiMeshInstance3D.populate_grass(grass_positions)


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
	SceneTransition.change_scene(get_path())
	
