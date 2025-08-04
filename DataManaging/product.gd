class_name Product
extends Resource

enum ProductType { FOOD, UTILITY, GADGET }

var name: String
var id: int
var price: int
var type: ProductType
var influence: int
var owner_id: int # could also be a reference or name


func to_dict():
	return {
		"name": name,
		"id": id,
		"price": price,
		"type": type,
		"influence": influence,
		"owner_id": owner_id
	}

func from_dict(data: Dictionary):
	name = data.get("name", "")
	id = data.get("id", -1)
	price = data.get("price",10)
	type = data.get("type", ProductType.FOOD)
	influence = data.get("influence", 0)
	owner_id = data.get("owner_id", -1)
