extends PanelContainer


var _lines: Array[PackedVector2Array] = []


func _process(delta: float) -> void:
	%Brush.global_position = %LogoViewport.get_mouse_position()


func _gui_input(event: InputEvent) -> void:
	if not (
		event is InputEventMouseButton
		or event.is_pressed()
	):
		var paint := Sprite2D
