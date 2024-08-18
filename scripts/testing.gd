extends Node2D

#game variables
var timer
var timer_label
var timer_label_format = "%02d"
var main_menu_path = "res://scenes/main_menu.tscn"

var cur_time = float()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = $"Game Timer"
	timer_label = $"In-game UI".find_child("Timer Label")
	
	timer.start(Settings.TIMER_MINUTES*60+Settings.TIMER_SECONDS)
	$"UI Update Timer".start(1)
	timer_label.text = timer_label_format % floor(timer.time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(timer.time_left)
	pass

func _on_player_collided(body) -> void:
	$"Mob Spwaner".repositionMob(body) # Replace with function body.

func _on_ui_update_timer_timeout() -> void:
	
	if !timer.is_stopped():
		var time_left = floor(timer.time_left)
		timer_label.text = timer_label_format % time_left # DEBUG: Worried a little this may lead to inaccurate times?
	$"UI Update Timer".start(1)

func set_pause(toggle):
	
	#toggle pause
	if toggle == true:
		if !timer.is_stopped():
			cur_time = timer.time_left
			timer.stop()
	else:
		timer.start(cur_time)

func game_over():
	# TO-DO: Leaderboard, game over screen, buttons to play again or go to main menu
	get_tree().change_scene_to_file(main_menu_path) # DEBUG: Why is this giving an error and not swapping?
