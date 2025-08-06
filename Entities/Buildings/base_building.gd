extends Node3D

var building_id
var owner_id = null
var value = 100.0



func _ready():
	if multiplayer.is_server():
		set_id()


func update_owner(id):
	owner_id = id
	
	$Label3D.text = str(owner_id)
	
	$Label3D.modulate = Color(0,1,0)
	
	$BuyBlock.queue_free()

func open_buy_window():
	var hud = get_tree().get_first_node_in_group("hud")
	
	hud.spawn_estate_buy_window(building_id,value)



func set_id():
	var id = PossessionManager.get_free_building_id()
	
	building_id = id
	set_id_for_client.rpc(id)
	
	PossessionManager.add_building(id,self)
	$Label3D.text = str(building_id)

@rpc("any_peer","reliable")
func set_id_for_client(id):
	building_id = id
	PossessionManager.add_building(id,self)
	$Label3D.text = str(building_id)

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		
		
		if body.player_id == multiplayer.get_unique_id():
			fade_out()


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		if body.player_id == multiplayer.get_unique_id():
			fade_in()






func fade_out():
	$AnimationPlayer.play("fade_out")



func fade_in():
	$AnimationPlayer.play("fade_in")
