extends CharacterBody2D

#mob variables
var cur_state = "idle"

var move_speed = 50
var turn_speed = 1

var angular_velocity = float(0)
var acceleration = float(8)

var default_size = 1
var target_size = 1

var target = null

@onready var collider = get_node("CollisionShape2D")
@onready var sprite = get_node("CollisionShape2D/Sprite2D")
@onready var detect = get_node("CollisionShape2D/detect")

func _ready() -> void:
	
	target_size = round(randf_range(0.8,2)*10)/10
	default_size = target_size

func _physics_process(_delta: float) -> void:
	
	#state machine
	match cur_state:
		"idle":
			state_idle()
		"run":
			state_run()
		"chase":
			state_chase()
	
	#fix over/under rotation
	if collider.rotation_degrees < 0:
		collider.rotation_degrees += 360
	elif collider.rotation_degrees > 360:
		collider.rotation_degrees -= 360
	
	#flip sprite direction
	if collider.rotation_degrees < 180:
		sprite.scale.y = 1
	else:
		sprite.scale.y = -1
	
	for body in detect.get_overlapping_bodies():
		if body.is_in_group("is_player"):
			target = body
			if target.collider.scale >= collider.scale:
				cur_state = "run"
			else:
				cur_state = "chase"
	
	#apply movement
	move_and_slide()
	
	#resize
	collider.scale = lerp(collider.scale,Vector2.ONE*target_size,0.1)

func state_idle():
	
	#stop moving
	velocity = velocity.move_toward(Vector2.ZERO,acceleration/2)

func  state_run():
	
	#run away from target
	if is_instance_valid(target):
		var dire = target.global_position-global_position
		var angle = dire.angle()*180/PI
		
		collider.rotation = lerp_angle(collider.rotation,deg_to_rad(angle+270),0.1)
		velocity = velocity.move_toward(-collider.transform.y*move_speed,acceleration)
		
		if global_position.distance_to(target.global_position) >= 256:
			cur_state = "idle"

func state_chase():
	
	#chase target
	if is_instance_valid(target):
		var dire = global_position-target.global_position
		var angle = dire.angle()*180/PI
		
		collider.rotation = lerp_angle(collider.rotation,deg_to_rad(angle+270),0.1)
		velocity = velocity.move_toward(-collider.transform.y*move_speed,acceleration)
		
		if global_position.distance_to(target.global_position) >= 256:
			cur_state = "idle"
