extends Panel

var building_id

var slots = {}

var selected_payment

func _ready():
	update_options()
	update_payment_options(0)
	
	if not building_id:
		push_warning("No building_id found!")


func update_options():
	var my_companies = CompanyManager.get_companies_by_owner(multiplayer.get_unique_id())
	
	slots.clear()
	$VBoxContainer/BuyForOptions.clear()
	
	$VBoxContainer/BuyForOptions.add_item("Personal use",0)
	
	for company in my_companies:
		slots[$VBoxContainer/BuyForOptions.size] = company.id
		
		$VBoxContainer/BuyForOptions.add_item(company.name,$VBoxContainer/BuyForOptions.size)
	
	

func update_payment_options(index):
	$VBoxContainer/PaymentOptions.clear()
	
	$VBoxContainer/BuyForOptions.add_item("Personal account: " + str(PossessionManager.player_money[multiplayer.get_unique_id()]),0)
	
	if not slots:
		return
	var company_id = slots[index]
	var company = CompanyManager.companies[company_id]
	var company_money = company.money
	
	$VBoxContainer/PaymentOptions.add_item(company.name + ": " + str(company_money) + "$")


func _on_buy_for_options_item_selected(index):
	update_payment_options(index)
	


func attempt_buy_estate():
	pass




func _on_exit_button_pressed():
	queue_free()


func _on_buy_button_pressed():
	attempt_buy_estate()
