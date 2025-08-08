extends Panel


var company_id

var total_amount = 0

var total_value = 0




func _ready():
	$VBoxContainer/HBoxContainer/SpinBox.max_value = CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id)
	
	
	if company_id == null:
		push_warning("No company_id at stock sale window!")
		return
	
	var company = CompanyManager.companies[company_id]
	
	$VBoxContainer/CompanyName.text = company.name
	
	var share_numbers = str(CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id)) + "/" + str(CompanyManager.get_total_shares(company_id))
	
	var share_value = CompanyManager.get_share_value(company_id)
	
	
	$VBoxContainer/OwnedStocks.text = "Owned Stocks: " + share_numbers
	
	$VBoxContainer/StockValue.text = "Stock Value: " + str(share_value)
	
	$VBoxContainer/Total.text = "Total: " + str(total_value) + "🪙"
	



func change_total_price(stock_amount):
	var company = CompanyManager.companies[company_id]
	var share_value = CompanyManager.get_share_value(company_id)
	total_value = stock_amount * share_value
	
	$VBoxContainer/Total.text = "Total: " + str(total_value) + "🪙"
	
	if total_value == 0:
		$SellButton.disabled = true
	else:
		$SellButton.disabled = false

func _on_spin_box_value_changed(value):
	value = clamp(value,0,CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id))
	
	total_amount = value
	
	if value > 50:
		$VBoxContainer/Warning.show()
	else:
		$VBoxContainer/Warning.hide()
	
	change_total_price(value)




func _on_exit_button_pressed():
	self.queue_free()


func _on_sell_button_pressed():
	CompanyManager.rpc_id(1,"request_sell_shares",company_id,total_amount,multiplayer.get_unique_id())
	self.queue_free()
