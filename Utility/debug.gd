extends Label









func _physics_process(delta):
	
	var new_text
	
	text = "Player Dictionaries: " + str(PlayerData.player_dictionaries) + "\n" 
	
	
	
	
	
	if Input.is_action_just_pressed("open_debug"):
		if visible:
			hide()
		else:
			show()
