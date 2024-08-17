extends CenterContainer

var game_scene = preload("res://scenes/testing.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(game_scene)


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
