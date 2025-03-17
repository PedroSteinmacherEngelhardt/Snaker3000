extends Area3D

signal player_is_ded

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_is_ded.emit()
