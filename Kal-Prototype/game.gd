extends Node2D

var cur_time = float()
var cur_score = 0

@onready var timer = get_node("ui/timer")
@onready var score = get_node("ui/score")

func _process(delta: float) -> void:
	
	#timer
	cur_time += delta
	
	var minutes = int(cur_time / 60)
	var seconds = int(cur_time) % 60
	var milliseconds = int((cur_time-int(cur_time))*1000/10)
	
	var time_str = str(minutes).pad_zeros(2)+":"+str(seconds).pad_zeros(2)+":"+str(milliseconds).pad_zeros(2)
	
	timer.text = "TIMER: "+str(time_str)
	
	score.text = "SCORE: "+str(cur_score)
