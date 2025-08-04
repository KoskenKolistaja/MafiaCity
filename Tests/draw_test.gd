extends PanelContainer


func _ready() -> void:
	pass


func _draw() -> void:
	draw_line(Vector2(100, 100), Vector2(500, 500), Color.RED, 40)
