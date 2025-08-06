extends StaticBody3D

@export var text: String

var price = 1000





func _ready():
	var new_text = text + " " + str(price) + "$"
	text = new_text




func action():
	get_parent().open_buy_window()
