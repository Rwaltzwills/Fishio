extends AnimationPlayer



func _ready() -> void:
	var parent = get_parent()
	parent.connect('visibility_changed',start_timer)
	if parent.visible:
		start_timer()
		

func start_timer():
	var parent = get_parent()
	$DelayTimer.start(randf_range(.1,.75))
	
	if parent.is_connected("visibility_changed", start_timer):
		parent.disconnect('visibility_changed',start_timer)
	parent.connect('visibility_changed',stop_anim)

func stop_anim():
	var parent = get_parent()
	parent.disconnect('visibility_changed',stop_anim)
	parent.connect('visibility_changed',start_timer)

func _on_delay_timer_timeout() -> void:
	self.play("Wobbles/Wobbles")
