extends Panel

var building_id
var building_price

var slots = {}



var for_company = null

var company_paying = false

func _ready():
	update_options()
	update_payment_options(null)
	
	if not building_id:
		push_warning("No building_id found!")
	
	$VBoxContainer/Price.text = str(building_price) + "$"

func update_options():
	var my_companies = CompanyManager.get_companies_by_owner(multiplayer.get_unique_id())
	
	slots.clear()
	$VBoxContainer/BuyForOptions.clear()
	
	$VBoxContainer/BuyForOptions.add_item("Personal use",0)
	
	for company in my_companies:
		slots[$VBoxContainer/BuyForOptions.item_count] = company.id
		
		$VBoxContainer/BuyForOptions.add_item(company.name,$VBoxContainer/BuyForOptions.item_count)
	
	

func update_payment_options(index):
	$VBoxContainer/PaymentOptions.clear()
	
	$VBoxContainer/PaymentOptions.add_item("Personal account: " + str(PossessionManager.player_money[multiplayer.get_unique_id()]) + "$",0)
	
	
	if not slots or not index:
		return
	
	
	var company_id = slots[index]
	var company = CompanyManager.companies[company_id]
	var company_money = company.money
	
	
	for_company = company
	
	$VBoxContainer/PaymentOptions.add_item(company.name + ": " + str(company_money) + "$")


func _on_buy_for_options_item_selected(index):
	update_payment_options(index)
	

func _on_payment_options_item_selected(index):
	if index != 0:
		company_paying = true
	else:
		company_paying = false

func attempt_buy_estate():
	var player_money = PossessionManager.player_money[multiplayer.get_unique_id()]
	
	if for_company:
		if company_paying:
			if for_company.money >= building_price:
				pass
			else:
				return
		elif player_money < building_price:
			return
	elif player_money < building_price:
		return
	
	
	if for_company:
		PossessionManager.rpc_id(1,"request_buy_building",building_id,for_company.id,company_paying)
	else:
		PossessionManager.rpc_id(1,"request_buy_building",building_id,null,company_paying)
	
	queue_free()


func _on_exit_button_pressed():
	queue_free()


func _on_buy_button_pressed():
	attempt_buy_estate()
