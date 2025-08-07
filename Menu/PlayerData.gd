extends Node


var player_dictionaries = {}

var index = 1



func add_data(id):
	add_data_for_clients.rpc(id)

@rpc("any_peer","call_local","reliable")
func add_data_for_clients(id):
	
	player_dictionaries[id] = {"name": "Player " + str(index) , "index" : index}
	if multiplayer.is_server():
		index += 1


func set_player_name(id,string_name):
	set_player_name_for_clients.rpc(id,string_name)


@rpc("any_peer","reliable","call_local")
func set_player_name_for_clients(id,string_name):
	player_dictionaries[id]["name"] = string_name
