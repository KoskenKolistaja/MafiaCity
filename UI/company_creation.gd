extends Panel

var company_type = 0





func attempt_company_creation():
	if is_company_creation_valid():
		
		
		var company_name = get_full_name()
		
		CompanyManager.rpc_id(1,"request_create_company",company_name,0)
		self.hide()
















func is_company_creation_valid():
	var validity = true
	
	var full_name = get_full_name()
	
	if not $MarginContainer/VBoxContainer/HBoxContainer2/CompanyNameEdit.text:
		validity = false
		show_error(Vector2.ZERO,"Company has no name!")
		return validity
	if $MarginContainer/VBoxContainer/HBoxContainer2/CompanyNameEdit.text.length() > 9:
		validity = false
		show_error(Vector2.ZERO,"Company name is too long!")
		return validity
	if CompanyManager.is_name_taken(full_name):
		validity = false
		show_error(Vector2.ZERO,"Company name is taken!")
		return validity
	
	return validity

func show_error_ui(text):
	$ErrorPanel.show()
	$ErrorPanel/MarginContainer2/ErrorText.text = text

func show_error(placement,text):
	$ErrorPanel.global_position = get_viewport().get_visible_rect().size / 2
	$ErrorPanel/MarginContainer2/ErrorText.text = text
	$ErrorPanel.show()



func get_full_name():
	var general_name = null
	
	general_name = $MarginContainer/VBoxContainer/HBoxContainer2/GeneralNameOptionButton.text
	
	
	var full_name = $MarginContainer/VBoxContainer/HBoxContainer2/CompanyNameEdit.text + " " + general_name
	
	return full_name


func _on_exit_button_pressed():
	self.hide()


func _on_create_pressed():
	attempt_company_creation()


func _on_ok_button_pressed():
	$ErrorPanel.hide()
