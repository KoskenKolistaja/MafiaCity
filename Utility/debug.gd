extends Label





func _ready():
	autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	
	# Make sure anchors fill the screen
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0



func _physics_process(delta):
	
	#var new_text
	#
	#text = "Player Dictionaries: " + str(PlayerData.player_dictionaries) + "\n" 
	
	
	
	
	
	if Input.is_action_just_pressed("open_debug"):
		if visible:
			hide()
		else:
			show()
