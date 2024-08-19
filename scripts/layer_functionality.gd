extends Node

@export var current_layer = 1
signal changed_layer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_layer(current_enemies, player, mob_spawner, new_enemy_list) -> void:
	# TO-DO: Pause
	# TO-DO: Transition anim
	
	# Reset enemies
	for e in current_enemies:
		e.queue_free()
	
	# Reset size
	player.changeSize(Settings.same_fish_size)
	
	# Respawn enemies
	mob_spawner.mob_scenes= new_enemy_list
	mob_spawner.spawnEnemies()
	
	# Add to points multiplier
	Settings.POINTS_MULTIPLIER = round(Settings.POINTS_MULTIPLIER*1.5)
	
	# TO-DO: Unpause
	
	emit_signal("changed_layer")
