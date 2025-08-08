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
	$Panel3/OwnedAmount.text = "Owned: " + share_numbers


func _on_buy_button_pressed():
	buy()


func _on_sell_button_pressed():
	sell()



func sell():
	CompanyManager.request_sell_shares.rpc(company_id,$SpinBox.value,multiplayer.get_unique_id())


func buy():
	CompanyManager.request_buy_shares.rpc(company_id,$SpinBox.value,multiplayer.get_unique_id())
	
	print("Buy button pressed!")
