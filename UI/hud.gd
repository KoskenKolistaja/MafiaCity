extends Control

@export var estate_buy_window: PackedScene





func spawn_estate_buy_window(id):
	var window_instance = estate_buy_window.instantiate()
	window_instance.building_id = id
	add_child(window_instance)
