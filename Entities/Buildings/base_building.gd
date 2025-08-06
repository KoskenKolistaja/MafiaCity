extends Node3D

var building_id
var owner_id = null




func _ready():
	if multiplayer.is_server():
		set_id()



func attempt_buy_building():
	request_buy_building.rpc_id(1)

@rpc("any_peer","reliable")
func request_buy_building():
	var sender_id = multiplayer.get_remote_sender_id()
	
	if not owner_id:
		pass

func client_confirm_purchase():
	pass


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
