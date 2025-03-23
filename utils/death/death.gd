extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		SceneTransition.change_scene(get_parent().get_path())
