extends Area2D

signal gained_size
signal take_hit

@onready var _animation_player = $AnimationPlayer

@export var SPEED = 300.0
@export var eating_size = 1
@export var y_scale_when_eating = 1.5
@export var x_scale_when_eating = 1.5
var velocity
var screen_size = get_viewport_rect().size

func _ready() -> void:
	velocity = Vector2(0,0)

func _physics_process(delta: float) -> void:
	# Handle swimming
	# Get the input direction
	velocity = Vector2(0,0) # reset velocity # DEBUG: Should we have velocity slowly go towards 0 to simulate swimming?
	var direction_lr := Input.get_axis("Left swim", "Right swim") # Left/Right # DEBUG: Change these to actions vice the animation names
	var direction_ud := Input.get_axis("Up swim", "Down swim") # Up/down # DEBUG: Change these to actions vice the animation names
	
	# Get velocity
	if direction_lr:
		velocity.x = direction_lr * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction_ud:
		velocity.y = direction_ud * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
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
	# position = position.clamp(Vector2.ZERO, screen_size) # DEBUG: Define screen size

func _process(delta: float) -> void:
	pass

func changeSize() -> void:
	self.eating_size += 1
	# DEBUG: play size change animation
	$Sprite2D.scale = Vector2(x_scale_when_eating, y_scale_when_eating)
	emit_signal("gained_size")

func _on_body_entered(body: Node2D) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	print(body)
	if "eating_size" in body:
		if self.eating_size > body.eating_size:
			changeSize()
			body.queue_free()
			# DEBUG: play eating animation
		else:
			pass # TO-DO: Decide on instakill or a health system related to size

# Actions needed
# - Handle swimming - Debug 
# - Eating/getting eaten on collision
# - Handle size changes - Debug
# - Lunge?
