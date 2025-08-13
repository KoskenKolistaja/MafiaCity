extends StaticBody3D

@export var text: String






func _ready():
	var new_text = text + " " + str(get_parent().get_value()) + "$"
	text = new_text





func action():
	var parent = get_parent()
	HUD.spawn_estate_buy_window(parent.get_building_id(),parent.get_value())
