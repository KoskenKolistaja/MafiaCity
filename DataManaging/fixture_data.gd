class_name FixtureData
extends Resource

@export var type: String = ""
@export var id: int
@export var position: Vector2i
@export var rotation_degrees: Vector3 = Vector3.ZERO

func to_dict() -> Dictionary:
	return {
		"type": type,
		"id" : id,
		"position": position,
		"rotation_degrees": rotation_degrees
	}

func from_dict(data: Dictionary) -> void:
	type = data.get("type", "")
	id = data.get("id")
	position = data.get("position", Vector2i())
	rotation_degrees = data.get("rotation_degrees", Vector3.ZERO)
