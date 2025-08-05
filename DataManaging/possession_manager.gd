extends Node


var buildings = {}
var fixtures = {}

var next_building_id = 1
var next_fixture_id = 1




func add_building(id,building):
	buildings[id] = {"building" : building, "owner" : null}

func add_fixture():
	pass




func get_free_building_id():
	var id = next_building_id
	next_building_id += 1
	return id

func get_free_fixture_id():
	var id = next_fixture_id
	next_fixture_id += 1
	return id
