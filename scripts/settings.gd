extends Node

@export var POINTS_GOAL = 1000
@export var TIMER_MINUTES = 0
@export var TIMER_SECONDS = 5

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

func newMapping(action, key) -> void:
	# Allows us to erase upon a new mapping, since we're only expecting one input per
	# action we can just go ahead and grab the first member of the array returned by
	# action_get_events()
	InputMap.action_erase_event(action,InputMap.action_get_events(action)[0])
	if key != null:
		InputMap.action_add_event(action,key) 
	# DEBUG: Save to local storage

func newGameParameters(points, minutes, seconds):
	POINTS_GOAL = points
	TIMER_MINUTES = minutes
	TIMER_SECONDS = seconds
