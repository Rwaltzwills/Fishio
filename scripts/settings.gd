extends Node

@export var POINTS_GOAL = 1000
@export var TIMER_MINUTES = 0
@export var TIMER_SECONDS = 5
@export var POINTS_MULTIPLIER = 1.5
@export var small_fish_size = 1
@export var same_fish_size = 2
@export var big_fish_size = 5
@export var biggest_fish_size = 9
@export var scale_size = Vector2(1.00,1.00)
@export var zoom_out_speed = 0.1
@export var scale_speed = .9
@export var shallow_layers: Array[int]
@export var medium_layers: Array[int]
@export var play_short_time_stinger = 6

var is_leaderboard_active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set Default Input Keys
	# DEBUG: Saving and loading from local storage
	var input = InputEventKey.new()
	input.keycode = KEY_S
	InputMap.action_add_event("Down swim",input)
	input = InputEventKey.new()
	input.keycode = KEY_W
	InputMap.action_add_event("Up swim",input)
	input = InputEventKey.new()
	input.keycode = KEY_A
	InputMap.action_add_event("Left swim",input)
	input = InputEventKey.new()
	input.keycode = KEY_D
	InputMap.action_add_event("Right swim",input)
	input = InputEventKey.new()
	input.keycode = KEY_SPACE
	InputMap.action_add_event("Transition",input)
	input = InputEventKey.new()
	input.keycode = KEY_ESCAPE
	InputMap.action_add_event("Pause",input)

func new_mapping(action, key) -> void:
	# Allows us to erase upon a new mapping, since we're only expecting one input per
	# action we can just go ahead and grab the first member of the array returned by
	# action_get_events()
	InputMap.action_erase_event(action,InputMap.action_get_events(action)[0])
	if key != null:
		InputMap.action_add_event(action,key) 
	# DEBUG: Save to local storage

func new_game_parameters(points, minutes, seconds):
	POINTS_GOAL = points
	TIMER_MINUTES = minutes
	TIMER_SECONDS = seconds
	
func submit_highscores(Points, time_left):
	if not Globals.is_signed_in:
		return
	
	$HTTPRequest.request_completed.connect(_on_add_request_completed)
	# Send to leaderboard
	var json = JSON.stringify({
		"ItchId": Globals.player_info["id"],
		"Name": Globals.player_info["name"],
		"Score": Points,
		"Time": (Settings.TIMER_MINUTES*60+Settings.TIMER_SECONDS) - time_left
	})
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("https://fishioleaderboard.dailitation.xyz/api/add", headers, HTTPClient.METHOD_POST, json)

func _on_add_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var body_str = body.get_string_from_utf8()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		Settings.is_leaderboard_active = false
		# TODO: Alert about failed request
		print("Failed to fetch leaderboard: {result} {code} {message}".format({
			"result": result,
			"code": response_code,
			"message": body_str
		}))
		return
