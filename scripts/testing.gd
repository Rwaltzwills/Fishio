extends Node2D

var timer
var timer_label
var timer_label_format = "%02d"
var main_menu = preload("res://scenes/main_menu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = $"Game Timer"
	timer_label = $"In-game UI".find_child("Timer Label")
	
	timer.start(Settings.TIMER_MINUTES*60+Settings.TIMER_SECONDS)
	$"UI Update Timer".start(1)
	timer_label.text = timer_label_format % floor(timer.time_left)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_collided(body) -> void:
	$"Mob Spwaner".repositionMob(body) # Replace with function body.


func _on_ui_update_timer_timeout() -> void:
	var time_left = floor(timer.time_left)
	timer_label.text = timer_label_format % time_left # DEBUG: Worried a little this may lead to inaccurate times?
	$"UI Update Timer".start(1)
	
func game_over():
	# TO-DO: Leaderboard, game over screen, buttons to play again or go to main menu
	get_tree().change_scene_to_packed(main_menu) # DEBUG: Why is this giving an error and not swapping?
