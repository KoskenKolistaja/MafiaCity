extends HBoxContainer


@export var stock_listing: PackedScene





func initialize():
	var companies = CompanyManager.companies
	var market_companies = companies.duplicate()
	
	var earlier_listings = $Panel2/MarginContainer/Panel/ScrollContainer/StockList.get_children()
	
	if earlier_listings:
		for item in earlier_listings:
			item.queue_free()
	
	
	for company in companies:
		if not company.shareholders.has("market"):
			market_companies.erase(company)
	
	for company in market_companies:
		spawn_listing(company.id)
	


func spawn_listing(company_id):
	var listing_instance = stock_listing.instantiate()
	$Panel2/MarginContainer/Panel/ScrollContainer/StockList.add_child(listing_instance)
	listing_instance.initialize(company_id)
