extends Sprite2D

const LogoDrawer := preload("res://UI/logo_drawer.gd")



func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for line in _lines:
		draw_polyline(line.line, line.color, line.line_size)
	#if not _current_line.is_empty() and _current_line.size() >= 2:
		#print(_current_line)
		#draw_polyline(_current_line, %ColorPicker.color, %SizeSlider.value)



func draw_lines(lines: Array[LogoDrawer.Line]) -> void:
	_lines = lines
	queue_redraw()
