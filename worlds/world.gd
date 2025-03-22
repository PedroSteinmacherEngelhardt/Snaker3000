extends Node3D

@export var world_name: String = "Base World"
signal world_completed(world_name: String);


var _replaceble_cells = {
	2: "res://scenes/grow!.tscn"
}


func _ready():
	_replace_gridmap()
	%Snaker3000.connect("died",_on_snaker_3000_died)


func _replace_gridmap():
	for cell in %GridMap.get_used_cells():
		var tile = %GridMap.get_cell_item(cell)
		if tile in _replaceble_cells:
			var scene = load(_replaceble_cells[tile]).instantiate()
			add_child(scene)
			scene.position = %GridMap.to_global(cell) + Vector3(0.5, 0.5, 0.5)
			%GridMap.set_cell_item(cell, -1)


func _on_death_body_entered(maybeASnaker3000):
	if maybeASnaker3000 is Snaker3000:
		var snaker3000 = maybeASnaker3000
		snaker3000.kill()


func _on_exit_body_entered(maybeASnaker3000):
	if maybeASnaker3000 is Snaker3000:
		world_completed.emit(world_name)
		var snaker3000 = maybeASnaker3000
		snaker3000.kill()


func _on_snaker_3000_died():
	%Snaker3000.position = %Spawn.position
	%Snaker3000.velocity = Vector3.ZERO
