extends CanvasLayer

func change_scene(target) -> void:
	$AnimationPlayer.play("pixeleted")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	get_tree().reload_current_scene()
	$AnimationPlayer.play_backwards('pixeleted')
	

func pop():
	$Pop.play()

func die():
	$Ahhh.play()

func trilim():
	$Trim.play()


func _on_audio_stream_player_3d_finished() -> void:
	$AudioStreamPlayer3D.play()
