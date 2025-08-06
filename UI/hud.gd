extends Control

@export var estate_buy_window: PackedScene


var info_text = ["Game Started"]


func add_info(exported_string: String):
	info_text.append(exported_string)
	
	
	print("went here")
	
	if not $InfoPanel/AnimationPlayer.is_playing():
		info_panel_next()


func spawn_estate_buy_window(id,price):
	var window_instance = estate_buy_window.instantiate()
	window_instance.building_id = id
	window_instance.building_price = price
	add_child(window_instance)


func info_panel_next():
	$InfoPanel/Label.text = info_text[0]
	$InfoPanel/AnimationPlayer.play("ShowInfo")
	info_text.remove_at(0)

func _on_animation_player_animation_finished(anim_name):
	if info_text:
		info_panel_next()
