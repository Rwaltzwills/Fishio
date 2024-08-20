extends VBoxContainer

var points_good : bool = false
var time_good : bool = false

var game_scene = preload("res://scenes//testing.tscn")
signal select_mode
@onready var viewport_size = get_viewport().size

func _ready() -> void:
	$"Custom Play Button".disabled = true
	var menu_size = get_size()
	set_position(Vector2(viewport_size.x / 2 - menu_size.x / 2, viewport_size.y / 2 - menu_size.y / 2))
	select_mode.connect(Settings.new_game_parameters)

func _process(delta: float) -> void:
	if points_good and time_good:
		$"Custom Play Button".disabled = false
	else:
		$"Custom Play Button".disabled = true


func _on_goal_entry_text_changed(new_text: String) -> void:
	points_good = check_input(new_text)

func _on_seconds_entry_text_changed(new_text: String) -> void:
	time_good = check_input(new_text)

func check_input(text: String) -> bool:
	# Interpret entry as int. 0 catches non-valid entries as well.
	if text.to_int() > 0:
		return true
	else:
		return false


func _on_play_button_pressed() -> void:
	print(str("Goal: ", $Goal/Goal_Entry.text.to_int()))
	print(str("Seconds: ", $Seconds/Seconds_Entry.text.to_int()))
	emit_signal("select_mode",$Goal/Goal_Entry.text.to_int(),0,$Seconds/Seconds_Entry.text.to_int())
	print(Settings.POINTS_GOAL)
	print(Settings.TIMER_SECONDS)
	get_tree().change_scene_to_packed(game_scene)
