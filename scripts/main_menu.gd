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
var actions = {"Down swim":tr("SWIM DOWN"), "Up swim":tr("SWIM UP"), 
				"Left swim":tr("SWIM LEFT"), "Right swim":tr("SWIM RIGHT"),
				"Transition":tr("TRANSITION"), "Transition_Up":tr("SWIM BACK UP")}
var is_remapping = false
var action_to_remap = null
var button_to_remap = null

signal assign_control
signal select_mode

# Called when the node enters the scene tree for the first time.
func _ready():
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
		
		
		$"Controls Menu".add_child(rebind_control_button)
		rebind_control_button.custom_minimum_size = rebind_control_button.find_child("MarginContainer").size
		rebind_control_button.pivot_offset = Vector2(rebind_control_button.custom_minimum_size.x/2,rebind_control_button.custom_minimum_size.y/2)
		rebind_control_button.add_child(wobbler.instantiate())
		rebind_control_button.hidden_value = b
		rebind_control_button.pressed.connect(AssignControls.bind(rebind_control_button))
		# DEBUG: Move new button up in scene controls
	
	assign_control.connect(Settings.newMapping)
	select_mode.connect(Settings.newGameParameters)

func AssignControls(button):
	if !is_remapping:
		is_remapping = true
		button.find_child("Input Label").text = "...?"
		action_to_remap = button.hidden_value
		button_to_remap = button

func _input(event: InputEvent) -> void:
	var controls_children = $"Controls Menu".get_children()
	var do_remap = false
	if is_remapping:
		if event is InputEventKey: # DEBUG: Add controller support?
			var new_mapping = event.as_text_key_label()
			do_remap = true
			
			for c in controls_children:
				var input_label = c.find_child("Input Label")
				if input_label != null and input_label.text == new_mapping:
					do_remap = false
			
			if do_remap:
				emit_signal("assign_control", action_to_remap, event)
				
			button_to_remap.find_child("Input Label").text = InputMap.action_get_events(action_to_remap)[0].as_text()
			# TO-DO: Handle swim up
			is_remapping = false
			action_to_remap = null
			button_to_remap = null
			

func _on_play_button_pressed():
	$AnimationPlayer.play("In-Game/Open Game Modes")

func _on_quit_button_pressed():
	get_tree().quit()

func Open_Settings() -> void:
	$AnimationPlayer.play("In-Game/Open Settings")

func Close_Settings() -> void:
	$AnimationPlayer.play("In-Game/Close Settings") 

func Open_Controls() -> void:
	$AnimationPlayer.play("In-Game/Open Controls")  

func Close_Controls() -> void:
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
