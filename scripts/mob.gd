extends CharacterBody2D

#mob variables
var cur_type = "shark"
var color_index = 0

var cur_action = "idle"

var dire = 0
var player = null
var zooming_out = false
var player_base_scale
var base_scale

@export var eating_size = 0
@export var SPEED = 100

@onready var collider = get_node("CollisionShape2D")
@onready var sprite = get_node("CollisionShape2D/Sprite2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# make shader unique for unique color
	$CollisionShape2D/Sprite2D.set_material($CollisionShape2D/Sprite2D.get_material().duplicate(true))
	# randomizing type
	randomize_type()
	
	if eating_size > Settings.same_fish_size:
		$CollisionShape2D.scale = eating_size*Settings.scale_size
	$Debug_Size.text = str(eating_size)
	base_scale = $CollisionShape2D.scale
	dire = collider.rotation
	
	# Scale speed on size
	if eating_size != 2:
		SPEED = SPEED/(Settings.scale_speed*eating_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# handle resizing
	if zooming_out:
		$CollisionShape2D.scale = $CollisionShape2D.scale.lerp(base_scale - Vector2(4,4), Settings.zoom_out_speed)
		if $CollisionShape2D.scale.x <= base_scale.x - 3:
			base_scale = $CollisionShape2D.scale
			zooming_out = false
	
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

func randomize_type() -> void:
	#randomize mob type/color
	randomize()
	var types = ["guppy","manta","shark"]
	if self.eating_size > Settings.same_fish_size:
		types.pop_front()
	else:
		types.pop_back()
		
	cur_type = types[randi_range(0,types.size()-1)] # TO-DO: Guppies small
	
	match cur_type: # TO-DO: Type change here
		"shark":
			sprite.texture = load("res://graphics/sprites/Shark_normalized.png")
		"manta":
			sprite.texture = load("res://graphics/sprites/Manta_normalized.png")
		"guppy":
			sprite.texture = load("res://graphics/sprites/Guppy_normalized.png")
	
	var rand_hue = float(randi() % 3)/2.0/3.2
	$CollisionShape2D/Sprite2D.material.set_shader_parameter("Shift_Hue", rand_hue)


func on_death() -> void:
	cur_action = "Idle"
	$Debug_State.text = "idle"

func _on_detect_area_entered(area: Area2D) -> void:
	if area.is_in_group("is_player"):
		if eating_size > area.eating_size:
			cur_action = "chase"
			$Debug_State.text = "chase"
		else:
			cur_action = "run"
			$Debug_State.text = "run"

func _on_detect_area_exited(area: Area2D) -> void:
	if area.is_in_group("is_player"):
		cur_action = "idle"
		$Debug_State.text = "idle"

func _on_action_timeout() -> void:
	if cur_action == "idle":
		dire = Vector2(randf(),randf()).angle()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("is_player"):
		if eating_size > area.eating_size:
			area.handle_damage()
