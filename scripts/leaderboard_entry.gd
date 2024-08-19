extends HBoxContainer

func set_information(rank: int, entry_data):
	$rank.text = str(rank)
	$name.text = entry_data["Name"]
	$score.text = str(entry_data["Score"])
	$time.text = str(entry_data["Time"])
	$date.text = Time.get_datetime_string_from_unix_time(entry_data["Date"], true)
