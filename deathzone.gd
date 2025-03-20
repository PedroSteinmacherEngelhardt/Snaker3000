extends Area3D

signal player_is_ded

func _on_body_entered(body: Node3D) -> void:
	if body is Snaker3000:
		player_is_ded.emit()
		body.got_dunked()
