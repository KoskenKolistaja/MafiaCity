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


@rpc("reliable","any_peer","call_local")
func request_create_product(exported_name, type):
	
	print("requested product creation")
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	print(exported_name)
	
	if ProductManager.is_name_taken(exported_name):
		print("Name taken")
		client_product_create_failed.rpc_id(sender_id,"Name already in use")
		return

	if not (type in Product.ProductType.values()):
		print("Invalid product type")
		client_product_create_failed.rpc_id(sender_id,"Invalid product type")
		return
	
	print("Got trough checks!")
	
	# Passed checks – create product
	
	
	var new_product = Product.new()
	new_product.name = exported_name
	new_product.id = ProductManager.products.size()
	new_product.price = default_prices[type]
	new_product.type = type
	new_product.influence = 1
	new_product.owner_id = sender_id
	
	add_product(new_product)
	client_product_created.rpc(new_product.to_dict())
	
	get_tree().call_group("updatable","update_data")


@rpc("any_peer","reliable")
func client_product_created(data: Dictionary):
	var product = Product.new()
	product.from_dict(data)
	add_product(product)
	print("Multiplayer ID: " + str(multiplayer.get_unique_id()) + " Product Array: " + str(ProductManager.products)  )
	
	get_tree().call_group("updatable","update_data")



@rpc("any_peer","call_local")
func client_product_create_failed(reason: String):
	var hud = get_tree().get_first_node_in_group("hud")
	hud.add_info(reason)



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

func is_name_taken(exported_name: String) -> bool:
	
	for product in products:
		if product.name.to_lower() == exported_name.to_lower():
			return true
	return false
