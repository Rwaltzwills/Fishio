extends Area2D

signal gained_size
signal take_hit
signal collided

@onready var _animation_player = $AnimationPlayer

@export var SPEED = 300.0
@export var SPEED_FALLOFF = 30
@export var eating_size = 1
@export var y_scale_when_eating = 1.5
@export var x_scale_when_eating = 1.5
var velocity
var screen_size = get_viewport_rect().size # DEBUG: May need to reassign this as camera size

func _ready() -> void:
	velocity = Vector2(0,0)

func _physics_process(delta: float) -> void:
	# Handle swimming
	# Get the input direction
	var direction_lr := Input.get_axis("Left swim", "Right swim") # Left/Right 
	var direction_ud := Input.get_axis("Up swim", "Down swim") # Up/down 
	
	# Get velocity
	if direction_lr:
		velocity.x = direction_lr * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/SPEED_FALLOFF)
	if direction_ud:
		velocity.y = direction_ud * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED/SPEED_FALLOFF)
	
	# Choose animation based on direction
	# Debug: Add all 8 directions, different comparisons for velocity eights for animation
	if velocity.x < 0:
		_animation_player.play("Left swim")
	if velocity.x > 0:
		_animation_player.play("Right swim")
	if velocity.y < 0:
		_animation_player.play("Down swim")
	if velocity.y > 0: 
		_animation_player.play("Up swim")
	
	move(velocity, delta)

func move(move_velocity: Vector2, delta: float):
	position += move_velocity * delta

func _process(delta: float) -> void:
	pass

func changeSize() -> void:
	self.eating_size += 1
	# DEBUG: play size change animation
	$Sprite2D.scale = Vector2($Sprite2D.scale.x * x_scale_when_eating, $Sprite2D.scale.y * y_scale_when_eating)
	$CollisionShape2D.scale = Vector2($CollisionShape2D.scale.x * x_scale_when_eating, $CollisionShape2D.scale.y * y_scale_when_eating)
	emit_signal("gained_size")

func _on_body_entered(body: Node2D) -> void:
	if "eating_size" in body:
		if self.eating_size > body.eating_size:
			changeSize()
			emit_signal("collided", body)
			# DEBUG: play eating animation
		else:
			emit_signal("take_hit") # TODO: Decide on instakill or a health system related to size

# Actions needed
# - Handle swimming - Debug 
# - Eating/getting eaten on collision
# - Handle size changes - Debug
# - Lunge?
