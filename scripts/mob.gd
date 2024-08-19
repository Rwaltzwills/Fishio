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
	
	#randomize mob type/color
	randomize()
	var types = ["shark","manta"]
	cur_type = types[randi_range(0,types.size()-1)]
	
	match cur_type:
		"shark":
			var color_arr = [Vector2(0,0),Vector2(554,0),Vector2(1108,0),Vector2(1674,0)]
			color_index = randi_range(0,color_arr.size()-1)
			
			sprite.texture = load("res://graphics/sprites/sharks.png")
			sprite.region_rect = Rect2(color_arr[color_index].x,color_arr[color_index].y,544,953)
		"manta":
			var color_arr = [Vector2(0,0),Vector2(708,0),Vector2(0,504),Vector2(708,504)]
			color_index = randi_range(0,color_arr.size()-1)
			
			sprite.texture = load("res://graphics/sprites/mantaray.png")
			sprite.region_rect = Rect2(color_arr[color_index].x,color_arr[color_index].y,708,504)
	
	if eating_size > Settings.small_fish_size:
		$CollisionShape2D.scale = eating_size*Settings.scale_size
	$Debug_Size.text = str(eating_size)
	base_scale = $CollisionShape2D.scale
	dire = collider.rotation

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
			area.emit_signal("take_hit")
