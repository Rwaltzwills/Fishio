extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = get_popup()
	popup.id_pressed.connect(_on_menu_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_button_pressed(id : int) -> void:
	match id:
		0: TranslationServer.set_locale("en")
		1: TranslationServer.set_locale("th")
