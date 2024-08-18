extends Node

@export var mob_scenes: Array[PackedScene] = []
@export var target: Node2D
@export var spawn_area_radius: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial_mobs = mob_scenes
	
	while initial_mobs.size() > 0:
		var new_mob = randi() % initial_mobs.size()
		var new_pos = target.position+(Vector2.RIGHT*spawn_area_radius).rotated(randf_range(0,PI))
		var m = initial_mobs[new_mob].instantiate()
		m.position = new_pos
		get_parent().add_child.call_deferred(m)
		initial_mobs.remove_at(new_mob)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass

func repositionMob(body) -> void:
	var new_pos = target.position+(Vector2.RIGHT*spawn_area_radius).rotated(randf_range(0,PI))
	body.position = new_pos 
	if "onDeath" in body:
		body.onDeath()
