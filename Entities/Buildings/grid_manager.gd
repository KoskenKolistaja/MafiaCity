extends Node3D

var cell_size
var building_size = Vector2(3,3)








func world_to_grid(world_pos: Vector3, building_origin: Vector3) -> Vector2i:
	var local_x = world_pos.x - building_origin.x
	var local_z = world_pos.z - building_origin.z
	return Vector2i(
		floor(local_x / cell_size.x),
		floor(local_z / cell_size.y)
	)

func grid_to_world(grid_pos: Vector2i, building_origin: Vector3) -> Vector3:
	return Vector3(
		building_origin.x + grid_pos.x * cell_size.x + cell_size.x / 2,
		building_origin.y,
		building_origin.z + grid_pos.y * cell_size.y + cell_size.y / 2
	)
