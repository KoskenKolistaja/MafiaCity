extends StaticBody3D


@export var text: String
@export var computer_view: PackedScene






func action():
	var world = get_tree().get_first_node_in_group("world")
	
	var pc_view_instance = computer_view.instantiate()
	
	world.add_child(pc_view_instance)
