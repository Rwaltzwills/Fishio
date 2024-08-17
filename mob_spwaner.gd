extends Node


# Called when the node enters the scene tree for the first time.
var spawner_pos = []
@export var mob_scenes: Array[PackedScene] = []
var children
@export var target: Node2D
func _ready() -> void:
	children = get_children()
	var initial_mobs = mob_scenes
	for c in children:
		spawner_pos.append(c.position-target.position)
		
		# Randomly spawns mobs on the markers at player spawn
		if initial_mobs.size() > 0:
			var new_mob = randi() % initial_mobs.size()
			var m = initial_mobs[new_mob].instantiate()
			m.position = c.position
			get_parent().add_child.call_deferred(m)
			initial_mobs.remove_at(new_mob)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var i = 0
	for c in children:
		c.position = spawner_pos[i] + target.position
		i = i+1

func repositionMob(body) -> void:
	var new_pos = get_children()[randi() % get_children().size()]
	body.position.x = new_pos.position.x 
	body.position.y = new_pos.position.y
	if "onDeath" in body:
		body.onDeath()
