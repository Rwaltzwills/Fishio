extends CanvasLayer


# Called when the node enters the scene tree for the first time.
var Points_format = "%02d"
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_gained_size() -> void:
	$Points.text = Points_format % (int($Points.text) + 1) # Replace with function body.
