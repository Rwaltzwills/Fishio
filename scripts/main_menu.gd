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

@onready var Effects_list = {
	"Clicking": preload("res://Sound/SFX/UI_MENU/CLICKINGSELECTING_1.wav"),
	"Typing": preload("res://Sound/SFX/UI_MENU/TYPINGKEY NOISE 1_1.wav"),
	"Start Game": preload("res://Sound/SFX/UI_MENU/START GAME_1.wav")
}

@onready var Musics_List = [preload("res://Sound/Music/Layer 1 (Shallow Waters)/Section A.mp3"),
							preload("res://Sound/Music/Layer 1 (Shallow Waters)/Section B.mp3"),
							preload("res://Sound/Music/Layer 1 (Shallow Waters)/Section C.mp3"),
							preload("res://Sound/Music/Layer 2 (Middle-Deep waters)/Section A (Middle-Deep).mp3"),
							preload("res://Sound/Music/Layer 2 (Middle-Deep waters)/Section B (Middle-Deep).mp3"),
							preload("res://Sound/Music/Layer 2 (Middle-Deep waters)/Section C (Middle-Deep).mp3"),
							preload("res://Sound/Music/Layer 3 (Deepest waters)/Section A (Deepest).mp3"),
							preload("res://Sound/Music/Layer 3 (Deepest waters)/Section B (Deepest).mp3"),
							preload("res://Sound/Music/Layer 3 (Deepest waters)/Section C (Deepest).mp3"),]

var game_scene = preload("res://scenes//testing.tscn")
var wobbler = preload("res://scenes//wobbler.tscn")
var actions = {
	"Up swim":"SWIM_UP", 
	"Left swim":"SWIM_LEFT", 
	"Right swim":"SWIM_RIGHT",
	"Transition":"TRANSITION"
}
# Removed "Transition_Up":tr("SWIM BACK UP")
var is_remapping = false
var action_to_remap = null
var button_to_remap = null

var Museum_Music_Selection = 0

signal assign_control
signal select_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	var controls_menu = $"Controls Menu"
	# TO-DO: Add signal to retranslate?
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
		rebind_control_button.hidden_value = b
		rebind_control_button.pressed.connect(assign_controls.bind(rebind_control_button))

	$"Controls Menu".move_child($"Controls Menu/BackButton",-1)
	assign_control.connect(Settings.new_mapping)
	select_mode.connect(Settings.new_game_parameters)
	
	# Itch.io Authentication
	$ItchRequests.request_completed.connect(_on_itch_request_complete)
	
	if OS.has_feature("pc"):
		var itch_api_key = OS.get_environment("ITCHIO_API_KEY")
		if itch_api_key != "":
			$ItchRequests.request("https://itch.io/api/1/jwt/me", [ "Authorization: Bearer %s" % itch_api_key ])

	# Initial positions
	$AnimationPlayer.play("In-Game/Initial Settings")
	
	# Handle sounds
	var children = get_children()
	for c in children:
		var sub_children = c.get_children()
		for c2 in sub_children:
			if c2 is Button:
				c2.pressed.connect(play_clicking_sounds)
				c2.pivot_offset = Vector2(c2.size.x/2,c2.size.y/2)
	
	$"Custom Game Modes/GridContainer/Seconds_Entry".text_changed.connect(play_typing_sounds)
	$"Custom Game Modes/GridContainer/Goal_Entry".text_changed.connect(play_typing_sounds)

func _on_itch_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error requesting player profile information!")
		return
	
	var data = JSON.parse_string(body.get_string_from_utf8())
	var player_name: String
	
	if data["user"].has("display_name"):
		player_name = data["user"]["display_name"]
	else:
		player_name = data["user"]["username"]
	
	Globals.player_info = {
		"id": data["user"]["id"],
		"name": player_name
	}
	Globals.is_signed_in = true
	
	$ItchButton.hide()
	$PlayerName.show()
	$PlayerName.text = Globals.player_info["name"]

func play_clicking_sounds():
	$Effects.stream = Effects_list["Clicking"]
	$Effects.pitch_scale = randf_range(0.9, 1.1)
	$Effects.play()

func play_typing_sounds(_new_text):
	$Effects.stream = Effects_list["Typing"]
	$Effects.pitch_scale = randf_range(0.9, 1.1)
	$Effects.play()

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
	$Music.stop()
	get_tree().change_scene_to_packed(game_scene)

func _on_medium_pressed() -> void:
	emit_signal("select_mode",medium_points,medium_minutes,medium_seconds)
	$Music.stop()
	get_tree().change_scene_to_packed(game_scene)

func _on_hard_pressed() -> void:
	emit_signal("select_mode",hard_points,hard_minutes,hard_seconds)
	$Music.stop()
	get_tree().change_scene_to_packed(game_scene)

func _on_gamemode_back_button_pressed():
	$AnimationPlayer.play("In-Game/Close Game Modes")

func _on_itch_button_pressed():
	$ItchButton.hide()
	OS.shell_open("https://itch.io/user/oauth?client_id=9eeba42d69bfbc45e30323ef8de3e534&scope=profile%3Ame&response_type=token&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob")
	$SignInDialog.show()

func _on_api_key_continue_button_pressed():
	var api_key = $SignInDialog/MarginContainer/VBoxContainer/KeyInput.text
	$ItchRequests.request("https://itch.io/api/1/key/me", [ "Authorization: Bearer %s" % api_key ])
	$SignInDialog.hide()

func _on_api_key_cancel_button_pressed():
	$ItchButton.show()
	$SignInDialog.hide()

func _on_custom_button_pressed() -> void:
	$AnimationPlayer.play("In-Game/Open Custom")


func _on_custom_back_button_pressed() -> void:
	$AnimationPlayer.play("In-Game/Close Custom")


func _on_credits_button_pressed() -> void:
	$AnimationPlayer.play("In-Game/Open Museum")


func _on_close_museum() -> void:
	$AnimationPlayer.play("In-Game/Close Museum")


func _on_play_music_button_pressed() -> void:
	var music_tween = get_tree().create_tween()
	music_tween.tween_property($Music, "volume_db", -80, 0.4)
	# $Music.volume_db.lerp = $Music.volume_db.lerp(-80, 0.1)
	$Music/SongSwapTimer.one_shot = true
	$Music/SongSwapTimer.start(0.5)
	


func _on_song_swap_timer_timeout() -> void:
	$Music.volume_db = 0
	$Music.stream = Musics_List[Museum_Music_Selection]
	$Music.play()


func _on_music_selection_item_selected(index: int) -> void:
	Museum_Music_Selection = index
