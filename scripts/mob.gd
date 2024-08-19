extends CharacterBody2D

#mob variables
var cur_action = "idle"

var dire = 0
var player = null

@export var eating_size = 0
@export var SPEED = 100

@onready var collider = get_node("CollisionShape2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if eating_size > 1:
		$CollisionShape2D.scale = eating_size*Settings.scale_size
	
	dire = collider.rotation
	player = get_node_or_null("../Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	
	#turn
	if is_instance_valid(player):
		if cur_action == "chase":
			dire = (player.global_position-global_position).angle()
		elif cur_action == "run":
			dire = (player.global_position-global_position).angle()+deg_to_rad(180)
	
	#apply turn
	collider.rotation = lerp_angle(collider.rotation,dire,0.1)
	
	#move
	if cur_action != "idle":
		velocity = velocity.move_toward(collider.transform.x*SPEED,1)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,1)
	
	#apply movement
	move_and_slide()

func on_death() -> void:
	pass
	# Reset AI
	# Pause for a short time
	# Restart AI

func _on_detect_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("is_player"):
		if eating_size > area.eating_size:
			cur_action = "chase"
		else:
			cur_action = "run"

func _on_detect_area_exited(area: Area2D) -> void:
	
	if area.is_in_group("is_player"):
		cur_action = "idle"
