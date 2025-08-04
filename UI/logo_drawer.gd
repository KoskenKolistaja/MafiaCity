extends PanelContainer

class Line:
	var line: PackedVector2Array
	var color: Color
	var line_size: int
	
	func _init(_line: PackedVector2Array, _color: Color, _line_size: int) -> void:
		line = _line
		color= _color
		line_size = _line_size

@onready var viewport_drawer: Sprite2D = %ViewportDrawer
@onready var logo_viewport_container: SubViewportContainer = $MainMargin/ContentMargin/VBoxContainer/AspectRatioContainer/LogoViewportContainer

var _lines: Array[Line] = []
var _drawing := false
var _current_line: PackedVector2Array


func _process(delta: float) -> void:
	var mouse_pos: Vector2 = %LogoViewport.get_mouse_position()
	var in_area := logo_viewport_container.get_rect().has_point(get_viewport().get_mouse_position())
	%Brush.global_position = mouse_pos
	
	if in_area and Input.is_action_just_pressed("draw"):
		_current_line = PackedVector2Array([mouse_pos])
		_drawing = true
	elif _drawing and Input.is_action_just_released("draw"):
		_current_line.append(mouse_pos)
		if _current_line.size() >= 2:
			_lines.append(
				Line.new(
					_current_line,
					%ColorPicker.color,
					%SizeSlider.value,
				)
			)
		_current_line = PackedVector2Array()
		viewport_drawer.draw_lines(_lines)
		_drawing = false
	elif _drawing and not in_area:
		_current_line.append(mouse_pos)
		if _current_line.size() >= 2:
			_lines.append(
				Line.new(
					_current_line,
					%ColorPicker.color,
					%SizeSlider.value,
				)
			)
		_current_line = PackedVector2Array()
		viewport_drawer.draw_lines(_lines)
		_drawing = false
	elif _drawing and Input.is_action_pressed("draw"):
		if mouse_pos.distance_to(_current_line[-1]) > 1:
			_current_line.append(mouse_pos)
		if _current_line.size() > 2:
			_lines.append(
				Line.new(
					_current_line,
					%ColorPicker.color,
					%SizeSlider.value,
				)
			)
			viewport_drawer.draw_lines(_lines)
			await get_tree().process_frame
			_lines.pop_back()
