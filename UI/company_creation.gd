extends Panel

var company_type = 0



@rpc("reliable", "any_peer", "call_local")
func request_create_company(exported_name, type, influence):
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	print(exported_name)
	
	if CompanyManager.is_name_taken(exported_name):
		print("Name taken")
		client_company_create_failed.rpc_id(sender_id,"Name already in use")
		return

	if not (type in Company.CompanyType.values()):
		print("Invalid company type")
		client_company_create_failed.rpc_id(sender_id,"Invalid company type")
		return
	
	# Passed checks – create company
	
	
	var new_company = Company.new()
	new_company.name = exported_name
	new_company.id = CompanyManager.companies.size()
	new_company.value = 0
	new_company.type = company_type
	new_company.owner_id = sender_id
	new_company.shareholders[sender_id] = 100
	
	CompanyManager.add_company(new_company)
	client_company_created.rpc(new_company.to_dict())
	
	get_parent().update_company_list()

func attempt_company_creation():
	if is_company_creation_valid():
		
		var company_name = get_full_name()
		
		rpc_id(1, "request_create_company", company_name, company_type, 1)
		self.hide()






@rpc("any_peer","reliable")
func client_company_created(data: Dictionary):
	var company = Company.new()
	company.from_dict(data)
	CompanyManager.add_company(company)
	print("Multiplayer ID: " + str(multiplayer.get_unique_id()) + " Company Array: " + str(CompanyManager.companies)  )
	
	get_parent().update_company_list()

@rpc("any_peer","call_local")
func client_company_create_failed(reason: String):
	show_error_ui("Company creation failed: " + reason)
	self.show()









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
