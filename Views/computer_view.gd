extends Control





func _ready():
	var player = get_tree().get_first_node_in_group("player")
	
	player.pause()


func _on_shut_down_button_pressed():
	self.queue_free()
	var player = get_tree().get_first_node_in_group("player")
	
	player.unpause()


func _on_products_button_pressed():
	$CompanyOptions.go_to_products()


func _on_companies_button_pressed():
	$CompanyOptions.go_to_companies()

func _on_start_button_pressed():
	var panel_visible = $Panel/OpenPanel.visible
	
	
	if not panel_visible:
		$Panel/OpenPanel.show()
	else:
		$Panel/OpenPanel.hide()
	

func _on_open_panel_focus_exited():
	$Panel/OpenPanel.hide()
