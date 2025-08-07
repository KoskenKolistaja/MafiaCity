extends Panel


var company_id

var total_value = 0




func _ready():
	if not company_id:
		push_warning("No company_id at stock sale window!")
		return
	
	var company = CompanyManager.companies[company_id]
	
	$VBoxContainer/CompanyName.text = company.name
	
	var share_numbers = str(CompanyManager.get_total_shares(company_id)) + "/" + str(CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id))
	
	$VBoxContainer/OwnedStocks.text = "Owned Stocks: " + share_numbers
	
	$VBoxContainer/StockValue.text = "Stock Value: " + str(company.value)
	
	$VBoxContainer/Total.text = "Total: " + str(total_value) + "$"
	



func change_total_price(stock_amount):
	var company = CompanyManager.companies[company_id]
	var share_value = company.value/CompanyManager.get_total_shares(company_id)
	total_value = stock_amount * share_value
	
	$VBoxContainer/Total.text = "Total: " + str(total_value) + "$"
	
	if total_value == 0:
		$SellButton.disabled = true
	else:
		$SellButton.disabled = false

func _on_spin_box_value_changed(value):
	value = clamp(value,0,CompanyManager.get_owned_shares(multiplayer.get_unique_id(),company_id))
	
	
	change_total_price(value)




func _on_exit_button_pressed():
	self.queue_free()
