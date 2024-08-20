extends CanvasLayer

var main_screen = "res://scenes/main_menu.tscn"
var leaderboard_screen = "res://scenes/leaderboard.tscn"

@onready var container = $Message/VBoxContainer/HBoxContainer
@onready var viewport_size = get_viewport().size

func _ready() -> void:
	if Settings.is_leaderboard_active:
		var button = Button.new()
		button.text = tr("LEADERBOARD")
		button.pressed.connect(goto_leaderboard)
	$AudioStreamPlayer2D.play()


func goto_leaderboard():
	get_tree().change_scene_to_file(leaderboard_screen)

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_screen)
