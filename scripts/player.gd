extends Area2D

#player variables
var color_index = 0

signal gained_size
signal take_hit
signal collided
signal request_transition
signal camera_resize_request

@onready var _animation_player = $AnimationPlayer
@onready var collider = get_node("CollisionShape2D")
@onready var sprite = get_node("CollisionShape2D/Sprite2D")

@export var SPEED = 200.0
@export var SPEED_ACCEL = 4
@export var SPEED_DECEL = 2

@export var TURN_SPEED = 2
@export var TURN_ACCEL = float(0.4)
@export var TURN_DECEL = float(0.1)

@export var eating_size = 2
var y_scale_when_eating = Settings.scale_size.x
var x_scale_when_eating = Settings.scale_size.y

var velocity
var angular_velocity
var base_scale

var zooming_out = false

func _ready() -> void:
	
	#randomize color
	randomize()
	var color_arr = [Vector2(0,0),Vector2(704,0),Vector2(1416,0),Vector2(1416,0),Vector2(2080,0)]
	var color_index = randi_range(0,color_arr.size()-1)
	sprite.region_rect = Rect2(color_arr[color_index].x,color_arr[color_index].y,650,984)
	
	velocity = Vector2(0,0)
	base_scale = $CollisionShape2D.scale
	angular_velocity = 0
	$"Debug Size".text = str(eating_size)

func _physics_process(delta: float) -> void:
	# Check for transition request
	if Input.get_action_strength("Transition") > .5:
		emit_signal("request_transition")
		return
	
	if zooming_out:
		$CollisionShape2D.scale = $CollisionShape2D.scale.lerp(base_scale, Settings.zoom_out_speed)
		if $CollisionShape2D.scale == base_scale:
			zooming_out = false
	# Handle swimming
	# Get the input direction
	var direction_lr := Input.get_axis("Left swim", "Right swim") # Left/Right 
	var direction_u := Input.is_action_pressed("Up swim") # Up
	
	#move
	if direction_u:
		velocity = velocity.move_toward(-collider.transform.y*SPEED,SPEED_ACCEL)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,SPEED_DECEL)
	
	#turn
	if direction_lr != 0:
		angular_velocity = move_toward(angular_velocity,direction_lr*TURN_SPEED,TURN_ACCEL)
	else:
		angular_velocity = move_toward(angular_velocity,0,TURN_DECEL)
	
	#apply turn
	collider.rotation_degrees += angular_velocity
	
	# Choose animation based on direction
	# Debug: Add all 8 directions, different comparisons for velocity eights for animation
	#if velocity.x < 0:
		#_animation_player.play("Left swim")
	#if velocity.x > 0:
		#_animation_player.play("Right swim")
	#if velocity.y < 0:
		#_animation_player.play("Down swim")
	#if velocity.y > 0: 
		#_animation_player.play("Up swim")
	
	move(velocity, delta)

func move(move_velocity: Vector2, delta: float):
	#apply movement
	position += move_velocity * delta

func change_size(new_size = 0) -> void:
	# If no new size provided, go up one
	if new_size == 0:
		self.eating_size += 1
	else:
		self.eating_size = new_size
	# DEBUG: play size change animation
	# Might just use a signal or a lerp setting here to smoothly transition
	if self.eating_size > Settings.same_fish_size:
		collider.scale = Vector2(self.eating_size * x_scale_when_eating, self.eating_size * y_scale_when_eating)
		emit_signal("gained_size")
	else:
		collider.scale = base_scale
	
	# Check if we're getting too big for the screen, scale everything down
	if $CollisionShape2D.scale >= Vector2(5,5):
		zooming_out = true
		eating_size = Settings.same_fish_size
		collider.scale = base_scale
		emit_signal("camera_resize_request")
	
	$"Debug Size".text = str(eating_size)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if "eating_size" in body:
		if self.eating_size >= body.eating_size:
			change_size()
			emit_signal("collided", body)
			# DEBUG: play eating animation
		#else:
			#emit_signal("take_hit")

# Actions needed
# - Handle swimming - Debug 
# - Eating/getting eaten on collision
# - Handle size changes - Debug
# - Lunge?
