extends CanvasLayer

@onready var pause_menu = get_node("pause_menu")
@onready var cur_scene = get_tree().current_scene

# Called when the node enters the scene tree for the first time.
var Points_format = "%02d"
func _ready() -> void:
	
	pause_menu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#toggle pause  menu
	if Input.is_action_just_pressed("Pause"):
		pause_menu.visible = !pause_menu.visible
		
		#toggle processes
		for node in get_tree().get_nodes_in_group("can_pause"):
			if pause_menu.visible == true:
				node.set_process(false)
				node.set_physics_process(false)
				cur_scene.set_pause(true)
			else:
				node.set_process(true)
				node.set_physics_process(true)
				cur_scene.set_pause(false)

func _on_player_gained_size() -> void:
	$Points.text = Points_format % (int($Points.text) + 1) # TO-DO: Scale by layer
