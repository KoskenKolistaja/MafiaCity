extends StaticBody3D

@export var text: String






func _ready():
	var new_text = text + " " + str(get_parent().value) + "$"
	text = new_text




func action():
	get_parent().open_buy_window()
