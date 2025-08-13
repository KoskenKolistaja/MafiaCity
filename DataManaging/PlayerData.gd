extends Node


var player_dictionaries = {}

var index = 1


@rpc("any_peer","reliable","call_local")
func add_data(id):
	player_dictionaries[id] = {"name": "Player " + str(index) , "index" : index}
	
	var dictionary = player_dictionaries.duplicate()
	
	index += 1
	
	add_data_for_clients.rpc(dictionary)

@rpc("any_peer","call_local","reliable")
func add_data_for_clients(exported_dictionary):
	
	player_dictionaries = exported_dictionary
	


func set_player_name(id,string_name):
	set_player_name_for_clients.rpc(id,string_name)


@rpc("any_peer","reliable","call_local")
func set_player_name_for_clients(id,string_name):
	player_dictionaries[id]["name"] = string_name
