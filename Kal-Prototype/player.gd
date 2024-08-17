extends CharacterBody2D

#player variables
var move_speed = 300
var turn_speed = 2

var input = Vector2.ZERO
var angular_velocity = float(0)
var acceleration = float(8)

var default_size = 1
var target_size = 1

@onready var collider = get_node("CollisionShape2D")
@onready var sprite = get_node("CollisionShape2D/Sprite2D")
@onready var hitbox = get_node("CollisionShape2D/hitbox")

@onready var game = get_tree().current_scene

func _physics_process(_delta: float) -> void:
	
	#inputs
	input.x = -int(Input.is_action_pressed("ui_left"))+int(Input.is_action_pressed("ui_right"))
	input.y = -int(Input.is_action_pressed("ui_up"))
	
	#turn
	if input.x != 0:
		angular_velocity = move_toward(angular_velocity,input.x*turn_speed,acceleration/4)
	else:
		angular_velocity = move_toward(angular_velocity,0,acceleration/8)
	
	#apply rotation
	collider.rotation_degrees += angular_velocity
	
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
	
	#move
	if input.y != 0:
		velocity = velocity.move_toward(-collider.transform.y*move_speed,acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,acceleration/2)
	
	#apply movement
	move_and_slide()
	
	#hitbox mechanics
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("is_mob"):
			target_size += 0.1
			game.cur_score += round(body.collider.scale.x*10)
			body.queue_free()
	
	#size threshold
	if target_size >= 3:
		target_size = 1
		for mob in get_tree().get_nodes_in_group("is_mob"):
			mob.target_size /= 3
	
	#resize
	collider.scale = lerp(collider.scale,Vector2.ONE*target_size,0.1)
