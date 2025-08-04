extends Control



func _ready():
	print(multiplayer.get_unique_id())


func _on_shut_down_button_pressed():
	get_tree().quit()


func _on_products_button_pressed():
	$CompanyOptions.show()


func _on_start_button_pressed():
	var panel_visible = $Panel/OpenPanel.visible
	
	
	if not panel_visible:
		$Panel/OpenPanel.show()
	else:
		$Panel/OpenPanel.hide()
	

func _on_open_panel_focus_exited():
	$Panel/OpenPanel.hide()
