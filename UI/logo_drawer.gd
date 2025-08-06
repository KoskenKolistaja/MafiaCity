extends PanelContainer

signal new_texture_accepted(image: Image)
signal closed

@onready var logo_viewport_container: SubViewportContainer = $MainMargin/ContentMargin/VBoxContainer/AspectRatioContainer/LogoViewportContainer
@onready var logo_viewport: SubViewport = %LogoViewport
@onready var brush: Sprite2D = %Brush
@onready var color_picker: ColorPickerButton = %ColorPicker
@onready var size_slider: HSlider = %SizeSlider
@onready var accept_button: Button = %AcceptButton
@onready var cancel_button: Button = %CancelButton

var _drawing := false
var _last_tex: Texture


func _ready() -> void:
	accept_button.pressed.connect(
		func():
			new_texture_accepted.emit(logo_viewport.get_texture().get_image())
			#logo_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			hide()
	)
	cancel_button.pressed.connect(
		func():
			closed.emit()
			hide()
	)
	await get_tree().process_frame
	hide()


func _process(delta: float) -> void:
	var mouse_pos: Vector2 = %LogoViewport.get_mouse_position()
	var in_area: bool = %LogoViewport.get_visible_rect().has_point(%LogoViewport.get_mouse_position())
	brush.global_position = mouse_pos
	var tex := (brush.texture as GradientTexture2D)
	tex.width = size_slider.value
	tex.height = size_slider.value
	brush.modulate = color_picker.color
	
	if in_area and Input.is_action_just_pressed("draw"):
		brush.show()
		_drawing = true
	elif _drawing and Input.is_action_just_released("draw"):
		brush.hide()
		_drawing = false


func open_logo_editor(texture: Texture):
	%Base.texture = texture
	show()
	%Base.show()
	
	#await get_tree().process_frame
	#await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	logo_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	await get_tree().process_frame
	await get_tree().process_frame
	%Base.texture = texture
	await get_tree().process_frame
	await get_tree().process_frame
	%Base.hide()
	#logo_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
