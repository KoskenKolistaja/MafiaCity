extends HBoxContainer

var company_id





func initialize(exported_id):
	company_id = exported_id
	update_data()


func update_data():
	var company = CompanyManager.companies[company_id]
	$Panel/CompanyName.text = company.name
	$Panel2/StockValue.text = str(CompanyManager.get_share_value(company_id))+"🪙"
	var share_numbers = str(CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id)) + "/" + str(CompanyManager.get_total_shares(company_id))
	$Panel3/OwnedAmount.text = share_numbers
	
	if CompanyManager.companies[company_id].shareholders.is_empty():
		return
	
	print("These are coming from id: " + str(multiplayer.get_unique_id()))
	print(CompanyManager.companies[company_id].shareholders.is_empty())
	print(CompanyManager.companies[company_id].shareholders)
	$Panel4/AvailableAmount.text = str(int(CompanyManager.companies[company_id].shareholders[0]))
	
	if not CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id):
		$SellButton.disabled = true
	

func _on_buy_button_pressed():
	buy()


func _on_sell_button_pressed():
	sell()



func sell():
	CompanyManager.rpc_id(1,"request_sell_shares",company_id,$SpinBox.value,multiplayer.get_unique_id())


func buy():
	CompanyManager.rpc_id(1,"request_buy_shares",company_id,$SpinBox.value,multiplayer.get_unique_id())
