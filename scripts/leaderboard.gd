extends MarginContainer

@onready var rows = $VBoxContainer/content/ScrollContainer/rows

var row = preload("res://scenes/leaderboard_entry.tscn")

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://fishioleaderboard.dailitation.xyz/api/get/top")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var body_str = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		# TODO: Alert about failed request
		print("Failed to fetch leaderboard: {result} {code} {message}".format({
			"result": result,
			"code": response_code,
			"message": body_str
		}))
		return
	
	print(body_str)
	var entries = JSON.parse_string(body_str)
	# [ { Id: int, Name: string, Score: int, Time: int, Date: int } ]
	
	for i in range(entries.size()):
		var entry = entries[i]
		var table_entry = row.instantiate()
		table_entry.set_information(i + 1, entry)
		rows.add_child(table_entry)
