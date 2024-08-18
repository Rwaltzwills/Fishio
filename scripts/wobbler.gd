extends AnimationPlayer



func _ready() -> void:
	var parent = get_parent()
	if parent.visible:
		startTimer()
	else:
		parent.connect('visibility_changed',startTimer)

func startTimer():
	var parent = get_parent()
	$DelayTimer.start(randf_range(.1,.75))
	parent.disconnect('visibility_changed',startTimer)
	parent.connect('visibility_changed',stopAnim)

func stopAnim():
	var parent = get_parent()
	parent.disconnect('visibility_changed',stopAnim)
	parent.connect('visibility_changed',startTimer)

func _on_delay_timer_timeout() -> void:
	self.play("Wobbles/Wobbles")
