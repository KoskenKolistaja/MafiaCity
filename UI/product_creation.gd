extends Panel

var product_type = 0





# Contains logic for product creation requests to server





func attempt_product_creation():
	if is_product_creation_valid():
		
		var product_name = get_full_name()
		ProductManager.rpc_id(1, "request_create_product", product_name, product_type)
		self.hide()











# ----------------------------- UTILITY FUNCTIONS -------------------------------------


func get_full_name():
	var general_name = null
	
	match product_type:
		0:
			general_name = $MarginContainer/VBoxContainer/HBoxContainer2/FoodOptionButton.text
		1:
			general_name = $MarginContainer/VBoxContainer/HBoxContainer2/UtilityOptionButton.text
		2:
			general_name = $MarginContainer/VBoxContainer/HBoxContainer2/GadgetOptionButton.text
	
	
	var full_name = $MarginContainer/VBoxContainer/HBoxContainer2/ProductNameEdit.text + " " + general_name
	
	return full_name


func is_product_creation_valid():
	var validity = true
	
	var full_name = get_full_name()
	
	if not $MarginContainer/VBoxContainer/HBoxContainer2/ProductNameEdit.text:
		validity = false
		show_error(Vector2.ZERO,"Product has no name!")
		return validity
	if $MarginContainer/VBoxContainer/HBoxContainer2/ProductNameEdit.text.length() > 9:
		validity = false
		show_error(Vector2.ZERO,"Product name is too long!")
		return validity
	if ProductManager.is_name_taken(full_name):
		validity = false
		show_error(Vector2.ZERO,"Product name is taken!")
		return validity
	
	return validity


# ---------------------------- INTERFACE CODE -----------------------------



func show_error_ui(text):
	$ErrorPanel.show()
	$ErrorPanel/MarginContainer2/ErrorText.text = text

func show_error(placement,text):
	$ErrorPanel.global_position = get_viewport().get_visible_rect().size / 2
	$ErrorPanel/MarginContainer2/ErrorText.text = text
	$ErrorPanel.show()


func _on_ok_button_pressed():
	$ErrorPanel.hide()


func _on_exit_button_pressed():
	self.hide()




func _on_create_pressed():
	attempt_product_creation()

func _on_type_option_button_item_selected(index):
	match index:
		0:
			product_type = 0
			$MarginContainer/VBoxContainer/HBoxContainer2/FoodOptionButton.show()
			$MarginContainer/VBoxContainer/HBoxContainer2/UtilityOptionButton.hide()
			$MarginContainer/VBoxContainer/HBoxContainer2/GadgetOptionButton.hide()
		1:
			product_type = 1
			$MarginContainer/VBoxContainer/HBoxContainer2/FoodOptionButton.hide()
			$MarginContainer/VBoxContainer/HBoxContainer2/UtilityOptionButton.show()
			$MarginContainer/VBoxContainer/HBoxContainer2/GadgetOptionButton.hide()
		2:
			product_type = 2
			$MarginContainer/VBoxContainer/HBoxContainer2/FoodOptionButton.hide()
			$MarginContainer/VBoxContainer/HBoxContainer2/UtilityOptionButton.hide()
			$MarginContainer/VBoxContainer/HBoxContainer2/GadgetOptionButton.show()
