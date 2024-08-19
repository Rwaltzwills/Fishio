extends Control

@export var rebind_control_buttons_scene = preload("res://scenes//control_rebind_button.tscn")
@export var easy_points = 10
@export var easy_minutes = 1
@export var easy_seconds = 0
@export var medium_points = 15
@export var medium_minutes = 0
@export var medium_seconds = 45
@export var hard_points = 20
@export var hard_minutes = 0
@export var hard_seconds = 45

var game_scene = preload("res://scenes//testing.tscn")
var wobbler = preload("res://scenes//wobbler.tscn")
var actions = {"Up swim":tr("SWIM_UP"), 
				"Left swim":tr("SWIM_LEFT"), "Right swim":tr("SWIM_RIGHT"),
				"Transition":tr("TRANSITION")}
				# Removed "Transition_Up":tr("SWIM BACK UP")
var is_remapping = false
var action_to_remap = null
var button_to_remap = null

signal assign_control
signal select_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	var controls_menu = $"Controls Menu"
	
	# Make the control buttons as per actions variable
	for b in actions:
		var rebind_control_button = rebind_control_buttons_scene.instantiate()
		var action_label = rebind_control_button.find_child("Action Label")
		var input_label = rebind_control_button.find_child("Input Label")
		
		action_label.text = actions[b]
		# Since only one action per input, we can just use the first member of the array
		var action_event = InputMap.action_get_events(b)
		if action_event.size() == 1:
			input_label.text = action_event[0].as_text() 
		else:
			input_label.text = "N/A"
		
		controls_menu.add_child(rebind_control_button)
		rebind_control_button.custom_minimum_size = rebind_control_button.find_child("MarginContainer").size
		rebind_control_button.pivot_offset = Vector2(rebind_control_button.custom_minimum_size.x/2,rebind_control_button.custom_minimum_size.y/2)
		rebind_control_button.add_child(wobbler.instantiate())
		rebind_control_button.hidden_value = b
		rebind_control_button.pressed.connect(assign_controls.bind(rebind_control_button))

	$"Controls Menu".move_child($"Controls Menu/BackButton",-1)
	assign_control.connect(Settings.new_mapping)
	select_mode.connect(Settings.new_game_parameters)

# For remapping controls
func assign_controls(button):
	# Check for remap state
	if !is_remapping:
		is_remapping = true
		button.find_child("Input Label").text = "...?"
		action_to_remap = button.hidden_value
		button_to_remap = button

# Used to capture the input on remapping state
func _input(event: InputEvent) -> void:
	var controls_children = $"Controls Menu".get_children()
	var do_remap = false # Set as true once remap conditions fulfilled
	# Check for remap state
	if is_remapping:
		if event is InputEventKey: 
			var new_mapping = event.as_text_key_label()
			do_remap = true
			
			# Check for any other actions that use this control
			for c in controls_children:
				var input_label = c.find_child("Input Label")
				if input_label != null and input_label.text == new_mapping:
					do_remap = false
			
			if do_remap:
				emit_signal("assign_control", action_to_remap, event)
			
			# Assign button's text to new control
			button_to_remap.find_child("Input Label").text = InputMap.action_get_events(action_to_remap)[0].as_text()
			# TO-DO: Handle swim up
			is_remapping = false
			action_to_remap = null
			button_to_remap = null
			

func _on_play_button_pressed():
	$AnimationPlayer.play("In-Game/Open Game Modes")

func _on_quit_button_pressed():
	get_tree().quit()

func open_settings() -> void:
	$AnimationPlayer.play("In-Game/Open Settings")

func close_settings() -> void:
	$AnimationPlayer.play("In-Game/Close Settings") 

func open_controls() -> void:
	$AnimationPlayer.play("In-Game/Open Controls")  

func close_controls() -> void:
	$AnimationPlayer.play("In-Game/Close Controls")

func _on_easy_pressed() -> void:
	emit_signal("select_mode",easy_points,easy_minutes,easy_seconds)
	get_tree().change_scene_to_packed(game_scene)

func _on_medium_pressed() -> void:
	emit_signal("select_mode",medium_points,medium_minutes,medium_seconds)
	get_tree().change_scene_to_packed(game_scene)

func _on_hard_pressed() -> void:
	emit_signal("select_mode",hard_points,hard_minutes,hard_seconds)
	get_tree().change_scene_to_packed(game_scene)

func _on_button_pressed() -> void:
	$AnimationPlayer.play("In-Game/Close Game Modes")
