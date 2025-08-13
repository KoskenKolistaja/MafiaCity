class_name BuildingData
extends Resource

@export var id: int = -1
@export var owner_id: int = -1
@export var company_id: int = -1
@export var value: float = 100.0
@export var building_size: Vector2i = Vector2i(3, 3)

# Key: Vector2i -> FixtureData
var fixtures: Dictionary = {}

func to_dict() -> Dictionary:
	var fixtures_dict := {}
	for k in fixtures.keys():
		fixtures_dict[k] = fixtures[k].to_dict()
	return {
		"id": id,
		"owner_id": owner_id,
		"company_id": company_id,
		"value": value,
		"building_size": building_size,
		"fixtures": fixtures_dict
	}

func from_dict(data: Dictionary) -> void:
	id = data.get("id", -1)
	owner_id = data.get("owner_id", -1)
	company_id = data.get("company_id", -1)
	value = data.get("value", 100.0)
	building_size = data.get("building_size", Vector2i(3, 3))
	fixtures.clear()
	var f: Dictionary = data.get("fixtures", {})
	for k in f.keys():
		var fd := FixtureData.new()
		fd.from_dict(f[k])
		fixtures[k] = fd 
