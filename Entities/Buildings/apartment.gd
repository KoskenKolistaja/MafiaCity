extends Node3D


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		$AnimationPlayer.play("fade_out")

func _on_area_3d_body_exited(body):
	$AnimationPlayer.play("fade_in")


func _ready():
	if multiplayer.is_server():
		$Timer.start()


func _on_timer_timeout():

	print("Timer ran out!")

	var shelf = get_shelf_with_product()

	if not shelf:
		return
	
	var world = get_tree().get_first_node_in_group("world")
	
	var npc = preload("res://Entities/NPC/npc.tscn")
	var npc_instance = npc.instantiate()
	npc_instance.global_position = $SpawnPosition.global_position
	npc_instance.apartment = self
	npc_instance.target_shelf = shelf
	world.spawn_npc(npc_instance)

func get_shelf_with_product():
	var fixtures = get_tree().get_nodes_in_group("fixture")
	var shelfs = fixtures.filter(func(f): return f.TYPE == "shelf")

	var returned_shelf = null

	for shelf in shelfs:
		if not shelf.is_empty():
			returned_shelf = shelf
			break

	return returned_shelf
