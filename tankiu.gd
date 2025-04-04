extends World

@onready var snaker_3000: Snaker3000 = %Snaker3000
@onready var camera_anchor: Node3D = $camera_anchor

var angle = 0
var radius = 4

var last_pos := Vector3.ZERO

func _ready() -> void:
	snaker_3000.pause = true
	update_snake_position()
	
	%BACK_TO_START.grab_focus()
	super()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_south"):
		var focus := get_viewport().gui_get_focus_owner()
		focus.find_next_valid_focus().grab_focus()
	elif Input.is_action_just_pressed("move_north"):
		var focus := get_viewport().gui_get_focus_owner()
		focus.find_prev_valid_focus().grab_focus()


func update_snake_position():
	var x = sin(angle) * radius
	var z = cos(angle) * radius
	var pos = Vector3(x,0,z).snapped(Vector3.ONE)
	
	angle += .1
	
	if pos == last_pos:
		update_snake_position()
		return
		
	snaker_3000._move(pos - snaker_3000._segments[0].global_position)
	last_pos = pos
	
	await get_tree().create_timer(0.2).timeout
	
	update_snake_position()


func _process(delta: float) -> void:
	camera_anchor.rotation.y -= delta * 0.2


func _on_back_to_start_button_up():
	SceneTransition.change_scene("res:// menu.tscn")
