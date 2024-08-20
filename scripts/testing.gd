extends Node2D

var timer
var timer_label
var timer_label_format = "%02d"
var main_menu_path = "res://scenes/main_menu.tscn"
var shader_speed_default_a # Not working
var cur_time = float()
var Points_format = "%02d"

@export var small_fish :PackedScene
@export var same_fish :PackedScene
@export var big_fish :PackedScene
@export var biggest_fish :PackedScene
@export var minimum_small = 1
@export var minimum_same = 5
@export var minimum_big = 6
@export var minimum_biggest = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set timer
	timer = $"Game Timer"
	timer_label = $"In-game UI".find_child("Timer Label")
	timer.start(Settings.TIMER_MINUTES*60+Settings.TIMER_SECONDS)
	$"UI Update Timer".start(1)
	timer_label.text = timer_label_format % floor(timer.time_left)
	
	# Spawn initial mobs
	$"Mob Spawner".target=$Player
	var enemy_list = generate_new_enemies()
	$"Mob Spawner".mob_group = $Mobs
	$"Mob Spawner".mob_scenes = enemy_list
	$"Mob Spawner".player = $Player
	$"Mob Spawner".spawn_enemies()
	
	shader_speed_default_a = $Background/ColorRect.material.get_shader_parameter("scroll_speed")

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var ocean_background_a = $Background/ColorRect.material
	
	# Keep the background attached to the player
	move_background($Player.velocity,delta)
	
	# DEBUG: Not working :(
	# var current_shader_speed_a = ocean_background_a.get_shader_parameter("scroll_speed")
	# if $Player.velocity != Vector2(0,0):
	# 	ocean_background_a.set_shader_parameter("scroll_speed", current_shader_speed_a*$Player.velocity)
	# 	# position += move_velocity * delta
	# else:
	# 	ocean_background_a.set_shader_parameter("scroll_speed", shader_speed_default_a)
	# print(ocean_background_a.get_shader_parameter("scroll_speed"))

func _on_player_collided(body) -> void:
	$"Mob Spawner".reposition_mob(body) # Replace with function body.


func _on_ui_update_timer_timeout() -> void:
	# Every second, update the timer UI label to countdown
	var time_left = floor(timer.time_left)
	timer_label.text = timer_label_format % time_left # DEBUG: Worried a little this may lead to inaccurate times?
	$"UI Update Timer".start(1)
	
func game_over():
	# TO-DO: Leaderboard, game over screen, buttons to play again or go to main menu
	get_tree().change_scene_to_file.call_deferred(main_menu_path)
	print("game over")

func game_win() -> void:
	game_over()

func _on_player_request_transition() -> void:
	# On layer change, add new enemies
	var new_enemy_list = generate_new_enemies()
	$"Layer functionality".change_layer($Mobs.get_children(),$Player,$"Mob Spawner",new_enemy_list)

func generate_new_enemies():
	# Generate new enemies depending on what layer you're on, with smaller fish
	# becoming rarer the farther you go down
	var new_enemy_list = []
	var layer = $"Layer functionality".current_layer
	var small = 10 - layer if 10 - layer > minimum_small else 10 - layer
	var same = 7 - layer if 7 - layer > minimum_same else 7 - layer
	var big = 5 + layer if 5 + layer > minimum_big else 5 + layer
	var biggest = 3 + layer if 3 + layer > minimum_biggest else 3 + layer
	
	for i in small:
		new_enemy_list.append([small_fish,Settings.small_fish_size])
	for i in same:
		new_enemy_list.append([same_fish,Settings.same_fish_size])
	for i in big:
		new_enemy_list.append([big_fish,Settings.big_fish_size])
	for i in biggest:
		new_enemy_list.append([biggest_fish,Settings.biggest_fish_size])
	
	return new_enemy_list
	
func move_background(move_velocity: Vector2, delta: float):
	$Background.position += move_velocity * delta
	
func set_pause(toggle):
	#toggle pause
	if toggle == true:
		if !timer.is_stopped():
			cur_time = timer.time_left
			timer.stop()
		else:
			timer.start(cur_time)


func _on_player_camera_resize_request() -> void:
	# When the player needs to scale down in size, scale down all mobs too
	var children = $Mobs.get_children()
	for c in children:
		c.zooming_out = true
		c.eating_size = c.eating_size - 3
		var Debug_Label = c.find_child("Debug_Size")
		if Debug_Label != null:
			Debug_Label.text = str(c.eating_size - 3)
		if c.eating_size < -2:
			c.queue_free() # After a certain size, despawn fish to force player deeper
			


func _on_player_take_hit() -> void:
	$"In-game UI".subtract_points()
