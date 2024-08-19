extends VBoxContainer

@onready var viewport_size = get_viewport().size

# Called when the node enters the scene tree for the first time.
func _ready():
	child_order_changed.connect(update_position)

func update_position():
	var menu_size = get_size()
	set_position(Vector2(viewport_size.x / 2 - menu_size.x / 2, viewport_size.y / 2 - menu_size.y / 2))
