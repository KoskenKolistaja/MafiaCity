extends Node3D

@export var player_scene: PackedScene



func _ready():
	
	
	if multiplayer.is_server():
		
		PossessionManager.init_player_money()
		
		await get_tree().create_timer(1).timeout
		
		spawn_players()
	
	await get_tree().create_timer(0.1).timeout
	HUD.show()
	HUD.update_data()
	HUD.add_info("Game Started!")
	await get_tree().create_timer(0.1).timeout
	get_tree().root.move_child(HUD, get_tree().root.get_child_count() - 1)


func _physics_process(delta):
	Debug.text = str($WorldObjects.get_children())


func spawn_players():
	
	var all = multiplayer.get_peers()
	
	all.append(1)
	
	for item in all:
		var player_instance = player_scene.instantiate()
		player_instance.name = str(item)
		player_instance.player_id = item
		$WorldObjects.call_deferred("add_child",player_instance,true)
		player_instance.global_position = Vector3(randf_range(-3,3),0,randf_range(-3,3))


func spawn_npc(item_instance):
	$WorldObjects.call_deferred("add_child",item_instance,true)
