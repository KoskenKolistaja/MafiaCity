extends Node


var player_dictionaries = {}

var index = 1



func add_data(id):
	player_dictionaries[id] = {"name": "<noname>" , "index" : index}
	index += 1



func set_player_name(id,string_name):
	player_dictionaries[id]["name"] = string_name
