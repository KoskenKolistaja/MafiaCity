class_name Company
extends Resource

enum CompanyType {SHOP}

var name: String
var id: int
var value: float
var money: float
var type: CompanyType
var owner_id: int
var shareholders: Dictionary # could also be a reference or name


func to_dict():
	return {
		"name": name,
		"id": id,
		"value": value,
		"type": type,
		"owner_id" : owner_id,
		"shareholders": shareholders
	}

func from_dict(data: Dictionary):
	name = data.get("name", "")
	id = data.get("id", -1)
	value = data.get("value",0.0)
	money = data.get("money",0.0)
	type = data.get("type", CompanyType.SHOP)
	owner_id = data.get("owner_id", -1)
	shareholders = data.get("shareholders", {})
