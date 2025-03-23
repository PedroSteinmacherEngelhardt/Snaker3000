extends Area3D

@export var next_scene: String


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		SceneTransition.change_scene(next_scene)
