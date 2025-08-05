extends Control


var peer = ENetMultiplayerPeer.new()

var ip = "localhost"






func _on_host_button_pressed():
	peer.create_server(2456)
	multiplayer.multiplayer_peer = peer
	PlayerData.add_data(multiplayer.get_unique_id())
	
	print("Created_server")
	
	multiplayer.peer_connected.connect(player_joined)
	$VBoxContainer/StartButton.show()


func _on_join_button_pressed():
	peer.create_client(ip,2456)
	multiplayer.multiplayer_peer = peer
	
	add_data_recursive()

func add_data_recursive():
	if multiplayer.get_peers().size() > 0:
		add_data.rpc_id(1, multiplayer.get_unique_id())
		
		if $NameEdit.text:
			request_name_change.rpc_id(1,multiplayer.get_unique_id(),$NameEdit.text)
		
	else:
		await get_tree().create_timer(0.05).timeout
		add_data_recursive()
		$AudioStreamPlayer2.play()


func player_joined(id):
	$AudioStreamPlayer.play()



@rpc("any_peer")
func add_data(id):
	PlayerData.add_data(id)


@rpc("any_peer","call_local")
func request_name_change(id,string_name):
	if multiplayer.is_server():
		PlayerData.set_player_name(id,string_name)
		update_name_list.rpc(PlayerData.player_dictionaries)

@rpc("any_peer","call_local")
func update_name_list(data_dictionary):
	if $PlayerList.get_children():
		for item in $PlayerList.get_children():
			item.queue_free()
	
	
	for item in data_dictionary:
		var label = Label.new()
		$PlayerList.add_child(label)
		
		print(data_dictionary)
		
		label.text = data_dictionary[item]["name"]




func _on_name_edit_text_changed():
	if multiplayer.get_peers().size() > 0:
		request_name_change.rpc_id(1,multiplayer.get_unique_id(),$NameEdit.text)



func _on_ip_edit_text_changed():
	ip = $VBoxContainer/IpEdit.text


func _on_start_button_pressed():
	start_for_all.rpc()
	
	#if get_tree().get_multiplayer().is_server():
		#show_start_for_all.rpc()

@rpc("any_peer","call_local")
func start_for_all():
	get_parent().spawn_game_scene()
	self.hide()

@rpc("any_peer")
func show_start_for_all():
	$VBoxContainer/StartButton.show()
