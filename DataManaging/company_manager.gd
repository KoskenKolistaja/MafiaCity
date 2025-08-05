extends Node

var companies: Array[Company] = []

var company_textures: Dictionary

# 0 = Food 
# 1 = Utility
# 2 = Gadget


var default_prices = {
	0: 5,
	1: 10,
	2: 100
}

# Autoloaded

# This script keeps track of companies

# Updated on client also but server has authoritative "final say version"



func add_company(company: Company):
	companies.append(company)
	print("went here")
	print(companies)

func add_company_texture(texture):
	pass



# -------------------- UTILITY FUNCTIONS -----------------------


func get_companies_by_owner(owner_id: int) -> Array:
	return companies.filter(func(p): return p.owner_id == owner_id)

func calculate_influence():
	pass

func to_save_format() -> Array:
	return companies.map(func(c): return c.to_dict())

func load_from_data(data: Array):
	companies.clear()
	for d in data:
		var c = Company.new()
		c.from_dict(d)
		companies.append(c)

func is_name_taken(exported_name: String) -> bool:
	
	for company in companies:
		if company.name.to_lower() == exported_name.to_lower():
			return true
	return false
