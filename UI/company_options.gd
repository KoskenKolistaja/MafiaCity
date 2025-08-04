extends Control

@export var product_button: PackedScene


var active_product_id = 0



# This script is basically only visual client-sided stuff



func update_product_list():
	
	var nodes = $MarginContainer/TabContainer/Products/HBoxContainer/ScrollContainer/ProductButtonContainer.get_children()
	
	for item in nodes:
		if item.name != "CreateNew":
			item.queue_free()
	
	var products = ProductManager.products
	
	var my_products = get_products_by_owner(products, multiplayer.get_unique_id())
	
	
	for item in my_products:
		var button_instance: Button = product_button.instantiate()
		button_instance.text = item.name + str(item.owner_id)
		button_instance.product_id = item.id
		
		button_instance.pressed.connect(_on_product_button_pressed.bind(item.id))
		
		$MarginContainer/TabContainer/Products/HBoxContainer/ScrollContainer/ProductButtonContainer.add_child(button_instance)
		$MarginContainer/TabContainer/Products/HBoxContainer/ScrollContainer/ProductButtonContainer.move_child(button_instance,0)
		print("juu")

func update_product_panel(id):
	
	active_product_id = id
	
	$MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel.show()
	
	var price_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Price
	var type_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Type
	var influence_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Influence
	var sold_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Sold
	var name_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/ProductName
	
	var type_text
	
	match ProductManager.products[id].type:
		0:
			type_text = "Food"
		1:
			type_text = "Utility"
		2:
			type_text = "Gadget"
	
	
	
	
	
	
	name_label.text = ProductManager.products[id].name
	price_label.text = "Price: " + str(ProductManager.products[id].price) + "🪙"
	type_label.text = "Type: " + type_text
	influence_label.text = "Influence: " + str(ProductManager.products[id].influence)
	sold_label.text = "Sold: 0"
	
	
	
	
	


# ----------------------- UTILITY FUNCTIONS ---------------------------------




func get_products_by_owner(list, owner_id: int) -> Array:
	return list.filter(func(p): return p.owner_id == owner_id)



func contains_non_alphanumeric(text: String) -> bool:
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z0-9]")
	return regex.search(text) != null


# ----------------------------------- INTERFACE CODE -----------------------------------





func _on_create_new_pressed():
	$ProductCreation.show()


func _on_exit_button_campaign_pressed():
	$CampaignCreation.hide()


func _on_evaluate_influence_pressed():
	var product_influence = 1.5
	var influence_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Influence
	influence_label.text =  "Influence: " + str(product_influence) 


func _on_campaign_pressed():
	$CampaignCreation.show()
	$ProductCreation.hide()


func _on_campaign_button_pressed():
	
	var influence_label = $MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/HBoxContainer/MarginContainer/VBoxContainer/Influence
	
	influence_label.text = "Influence: <not known>"


func _on_production_create_pressed():
	await get_tree().create_timer(0.1).timeout
	update_product_list()


func _on_set_price_pressed():
	pass # Replace with function body.


func _on_product_panel_exit_pressed():
	$MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel.hide()

func _on_product_button_pressed(product_id):
	print("Went here...")
	update_product_panel(product_id)


func _on_draw_logo_pressed():
	%LogoDrawer.open_logo_editor(%BrandLogo.texture.duplicate(true))


func _on_logo_drawer_new_texture_accepted(texture: Texture) -> void:
	print("New logo texture applied")
	$MarginContainer/TabContainer/Products/HBoxContainer/ProductPanel/Panel/BrandLogo.texture = texture


func _on_logo_draw_exit_button_pressed():
	$LogoDrawInterface.hide()


func _on_exit_button_pressed():
	self.hide()


func _on_product_name_edit_text_changed():
	var name_edit = $ProductCreation/MarginContainer/VBoxContainer/HBoxContainer2/ProductNameEdit
	var text = name_edit.text
	
	if contains_non_alphanumeric(text):
		$ProductCreation/Create.disabled = true
	else:
		$ProductCreation/Create.disabled = false
	
