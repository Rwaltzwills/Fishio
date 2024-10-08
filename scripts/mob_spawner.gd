extends Node

var mob_scenes = []
@export var target: Node2D
@export var spawn_area_radius: float = 1
var mob_group
var player = null

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func reposition_mob(body) -> void:
	var new_pos = target.position+(Vector2.RIGHT*spawn_area_radius).rotated(randf_range(0,PI))
	body.position = new_pos 
	if "onDeath" in body:
		body.onDeath()

func spawn_enemies() -> void:
	var initial_mobs = mob_scenes
	
	while initial_mobs.size() > 0:
		var new_mob = randi() % initial_mobs.size()
		var new_pos = target.position+(Vector2.RIGHT*spawn_area_radius).rotated(randf_range(0,PI))
		var m = initial_mobs[new_mob][0].instantiate()
		m.position = new_pos
		m.eating_size = initial_mobs[new_mob][1]
		mob_group.add_child.call_deferred(m)
		m.player = player
		m.player_base_scale = player.base_scale
		initial_mobs.remove_at(new_mob)
