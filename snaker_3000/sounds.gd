extends Node


func play() -> void:
	get_children().pick_random().play()
