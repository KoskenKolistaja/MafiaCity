extends Panel

var product_type = 0





# Contains logic for product creation requests to server



@rpc("reliable", "any_peer", "call_local")
func request_create_product(exported_name, type, influence):
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	print(exported_name)
	
	if ProductManager.is_name_taken(exported_name):
		print("Name taken")
		client_product_create_failed.rpc("Name already in use")
		return

	if not (type in Product.ProductType.values()):
		print("Invalid product type")
		client_product_create_failed.rpc("Invalid product type")
		return
	
	# Passed checks – create product
	
	
	var new_product = Product.new()
	new_product.name = exported_name
	new_product.id = ProductManager.products.size()
	new_product.price = ProductManager.default_prices[product_type]
	new_product.type = product_type
	new_product.influence = 1
	new_product.owner_id = sender_id
	
	ProductManager.add_product(new_product)
	client_product_created.rpc(new_product.to_dict())
	
	get_parent().update_product_list()

func attempt_product_creation():
	if is_product_creation_valid():
		
		var product_name = get_full_name()
		
		rpc_id(1, "request_create_product", product_name, product_type, 1)
		self.hide()






@rpc("any_peer","reliable")
func client_product_created(data: Dictionary):
	var product = Product.new()
	product.from_dict(data)
	ProductManager.add_product(product)
	print("Multiplayer ID: " + str(multiplayer.get_unique_id()) + " Product Array: " + str(ProductManager.products)  )
	
	get_parent().update_product_list()

@rpc("any_peer","call_local")
func client_product_create_failed(reason: String):
	show_error_ui("Product creation failed: " + reason)



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
