extends Area2D

signal gained_size
signal take_hit
signal collided
signal request_transition

@onready var _animation_player = $AnimationPlayer

@export var SPEED = 300.0
@export var SPEED_FALLOFF = 30
@export var eating_size = 2
var y_scale_when_eating = Settings.scale_size.x
var x_scale_when_eating = Settings.scale_size.y
var velocity
var base_scale

func _ready() -> void:
	velocity = Vector2(0,0)
	base_scale = $Sprite2D.scale

func _physics_process(delta: float) -> void:
	# Check for transition request
	if Input.get_action_strength("Transition") > .5:
		emit_signal("request_transition")
		return
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

func _process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void: # DEBUG: Delete this. For testing purposes only.
	if event is InputEventKey:
		if event.as_text_key_label() == "Z":
			print(event.as_text_key_label())
			$Camera2D.zoom = Vector2(1,1)

func changeSize(new_size = 0) -> void:
	if new_size == 0:
		self.eating_size += 1
	else:
		self.eating_size = new_size
	# DEBUG: play size change animation
	if self.eating_size > 2:
		$Sprite2D.scale = Vector2(self.eating_size * x_scale_when_eating, self.eating_size * y_scale_when_eating)
		$CollisionShape2D.scale = Vector2(self.eating_size * x_scale_when_eating, self.eating_size * y_scale_when_eating)
	else:
		$Sprite2D.scale = base_scale
		$CollisionShape2D.scale = base_scale
	emit_signal("gained_size")

func _on_body_entered(body: Node2D) -> void:
	if "eating_size" in body:
		if self.eating_size > body.eating_size:
			changeSize()
			emit_signal("collided", body)
			# DEBUG: play eating animation
		else:
			emit_signal("take_hit") # TODO: Decide on instakill or a health system related to size
			print("took hit")

# Actions needed
# - Handle swimming - Debug 
# - Eating/getting eaten on collision
# - Handle size changes - Debug
# - Lunge?
