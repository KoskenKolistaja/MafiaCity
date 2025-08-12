extends Node3D

var building_id
var owner_id = null
@export var value: float = 100.0
@export var building_size = Vector2(3,3)

var cell_size = Vector2(2,2)

var fixtures = {}

func _ready():
	if multiplayer.is_server():
		set_id()

func update_data():
	update_image()


@rpc("any_peer","reliable","call_local")
func request_placement(string : String,snapped_position : Vector2i ,item_rotation):
	var sender_id = multiplayer.get_remote_sender_id()
	var price = ItemData.fixture_prices[string]
	
	
	if fixtures.has(snapped_position):
		HUD.rpc_id(sender_id,"add_info", "No room for item!")
		return
	
	
	if not PossessionManager.player_money[sender_id] >= price:
		HUD.rpc_id(sender_id,"add_info", "Not enough money for purchase!")
		return
	else:
		var new_money = PossessionManager.player_money[sender_id] - price
		
		PossessionManager.rpc("set_player_money",sender_id,new_money)
	
	var item_instance = ItemData.fixtures[string].instantiate()
	var world_position = $GridManager.grid_to_world(snapped_position)
	
	
	
	item_instance.global_position = world_position
	$Fixtures.add_child(item_instance)
	
	fixtures[snapped_position] = item_instance


func get_grid_manager():
	return $GridManager



func update_owner(id):
	owner_id = id
	
	$Label3D.text = str(owner_id)
	
	$Label3D.modulate = Color(0,1,0)
	
	$BuyBlock.queue_free()
	
	$Door.set_multiplayer_authority(owner_id)
	
	
	
	update_image()


func update_image():
	if PossessionManager.buildings[building_id]["company_id"] != null:
		
		
		var company_id = PossessionManager.buildings[building_id]["company_id"]
		var company_logo
		
		if CompanyManager.company_textures.has(company_id):
			company_logo = CompanyManager.company_textures[company_id]
			set_image(company_logo)
		else:
			set_image(preload("res://Assets/Textures/NoLogo.png"))

func set_image(new_texture):
	var material = $FrontWalls/Panel.get_active_material(0)
	
	material.albedo_texture = new_texture
	$FrontWalls/Panel.set_surface_override_material(0, material)






func set_id():
	var id = PossessionManager.get_free_building_id()
	
	building_id = id
	set_id_for_client.rpc(id)
	
	PossessionManager.add_building(id,self)
	$Label3D.text = str(building_id)

@rpc("any_peer","reliable")
func set_id_for_client(id):
	building_id = id
	PossessionManager.add_building(id,self)
	$Label3D.text = str(building_id)

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		fade_out()
		
		if owner_id == multiplayer.get_unique_id():
			HUD.set_building_id(building_id)
			HUD.show_sidebar()

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		fade_in()
		if owner_id == multiplayer.get_unique_id():
			HUD.set_building_id(null)
			HUD.hide_sidebar()




func show_walls():
	$BackWalls.show()
	$FrontWalls.show()
	$Roof.show()

func hide_walls():
	$BackWalls.hide()
	$FrontWalls.hide()
	$Roof.hide()


func fade_out():
	$AnimationPlayer.play("fade_out")



func fade_in():
	$AnimationPlayer.play("fade_in")
