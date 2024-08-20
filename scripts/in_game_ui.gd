extends CanvasLayer

@onready var pause_menu = get_node("pause_menu")
@onready var cur_scene = get_tree().current_scene

var Points
var Points_format = "%02d"

signal won_game

func _ready() -> void:
	# Set initial states
	Points = 0
	$Points.text = "{points} {out_of} {goal}".format({
		"points": Points_format % Points,
		"out_of": tr("OUT_OF"),
		"goal": Settings.POINTS_GOAL
	})
	pause_menu.visible = false

func _process(_delta: float) -> void:
	
	#toggle pause menu
	if Input.is_action_just_pressed("Pause"):
		pause_menu.visible = !pause_menu.visible
		
		#toggle processes
		get_tree().paused = pause_menu.visible
		#for node in get_tree().get_nodes_in_group("can_pause"):
			#if pause_menu.visible == true:
				#node.set_process(false)
				#node.set_physics_process(false)
				#cur_scene.set_pause(true)
			#else:
				#node.set_process(true)
				#node.set_physics_process(true)
				#cur_scene.set_pause(false)

# Tracks points, updates the UI, checks for win condition
func _on_player_gained_size() -> void:
	# Update points
	Points = Points+floor(1*Settings.POINTS_MULTIPLIER)
	# Convert everything to proper text format
	$Points.text = "{points} {out_of} {goal}".format({
		"points": Points_format % Points,
		"out_of": tr("OUT_OF"),
		"goal": Settings.POINTS_GOAL
	})
	if Points >= Settings.POINTS_GOAL: # Check if won the game
		emit_signal("won_game")
	

func subtract_points() -> void:
	# Update points
	Points = Points - 1
	# Convert everything to proper text format
	$Points.text = "{points} {out_of} {goal}".format({
		"points": Points_format % Points,
		"out_of": tr("OUT_OF"),
		"goal": Settings.POINTS_GOAL
	})


func _on_resume_button_pressed():
	get_tree().paused = false
	pause_menu.visible = !pause_menu.visible

func _on_return_to_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
