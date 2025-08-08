extends Node3D

@export var player_scene: PackedScene



func _ready():
	
	if multiplayer.is_server():
		
		PossessionManager.init_player_money()
		
		await get_tree().create_timer(1).timeout
		print(PlayerData.player_dictionaries)
		
		spawn_players()
	
	await get_tree().create_timer(2).timeout
	print(str(PlayerData.player_dictionaries) + " " + str(multiplayer.get_unique_id()) + " Printed from world script")


func spawn_players():
	
	var all = multiplayer.get_peers()
	
	all.append(1)
	
	for item in all:
		var player_instance = player_scene.instantiate()
		player_instance.name = str(item)
		player_instance.player_id = item
		$WorldObjects.call_deferred("add_child",player_instance,true)
		player_instance.global_position = Vector3(randf_range(-3,3),0,randf_range(-3,3))
