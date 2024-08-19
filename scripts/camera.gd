extends Camera2D

#camera variables
var target_1 = null
var target_2 = null

func _ready() -> void:
	
	target_1 = get_parent()
	set_as_top_level(true)

func _process(_delta: float) -> void:
	
	#move camera to target/s
	if is_instance_valid(target_1):
		var t1 = target_1.global_position
		var t2 = get_global_mouse_position()
		
		if is_instance_valid(target_2):
			t2 = target_2.global_position
		
		global_position = lerp(global_position,(t1+t2)/2,0.1)
