extends Level

@export var player : Player
@export var spawnpoint : Node3D


func _on_deathzone_player_is_ded() -> void:
	player.global_position = spawnpoint.global_position
