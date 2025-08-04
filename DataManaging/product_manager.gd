extends Node

var products: Array[Product] = []

var product_textures: Dictionary

# 0 = Food 
# 1 = Utility
# 2 = Gadget


var default_prices = {
	0: 5,
	1: 10,
	2: 100
}

# Autoloaded

# This script keeps track of products

# Updated on client also but server has authoritative "final say version"



func add_product(product: Product):
	products.append(product)

func add_product_texture(texture):
	pass



# -------------------- UTILITY FUNCTIONS -----------------------


func get_products_by_owner(owner_id: int) -> Array:
	return products.filter(func(p): return p.owner_id == owner_id)

func calculate_influence():
	pass

func to_save_format() -> Array:
	return products.map(func(p): return p.to_dict())

func load_from_data(data: Array):
	products.clear()
	for d in data:
		var p = Product.new()
		p.from_dict(d)
		products.append(p)

func is_name_taken(name: String) -> bool:
	for product in products:
		if product.name == name:
			return true
	return false
