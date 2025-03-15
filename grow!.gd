extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.add_box()
		queue_free()
