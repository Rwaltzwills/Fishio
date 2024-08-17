extends CharacterBody2D
@export var eating_size = 0
@export var SPEED = 150


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onDeath() -> void:
	pass
	# Reset AI
	# Pause for a short time
	# Restart AI
