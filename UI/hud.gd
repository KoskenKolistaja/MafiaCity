extends Control

@export var estate_buy_window: PackedScene
@export var furniture_placer: PackedScene

var info_text = ["Hello!"]


var building_id


func _ready():
	hide()




func spawn_furniture_placer():
	var furniture_placer_instance = furniture_placer.instantiate()
	var world = get_tree().get_first_node_in_group("world")
	
	var building_dictionary = PossessionManager.buildings[building_id]
	var building = building_dictionary["building"]
	
	print(building.global_position)
	
	furniture_placer_instance.building_id = building_id
	world.add_child(furniture_placer_instance)
	furniture_placer_instance.global_position = building.global_position



func set_building_id(id):
	building_id = id

func show_sidebar():
	$SideBar/AnimationPlayer.play("Show")

func hide_sidebar():
	$SideBar/AnimationPlayer.play("Hide")






func update_data():
	if not PossessionManager.player_money.has(multiplayer.get_unique_id()):
		push_error("Player money not found!")
		return
	
	var money = PossessionManager.player_money[multiplayer.get_unique_id()]
	$OptionButton.clear()
	
	$OptionButton.add_item("Personal Account: " + format_money(money))
	
	
	var companies_owned  = CompanyManager.get_companies_by_owner(multiplayer.get_unique_id())
	
	for company in companies_owned:
		var company_name = company.name
		
		$OptionButton.add_item(company.name + ": " + format_money(company.money))




func format_money(amount: float) -> String:
	var integer_part := int(abs(amount))
	var decimal_part := int((abs(amount) - integer_part) * 100)
	
	# Format integer part with spaces
	var str_int := str(integer_part)
	var formatted := ""
	while str_int.length() > 3:
		formatted = " " + str_int.substr(str_int.length() - 3, 3) + formatted
		str_int = str_int.substr(0, str_int.length() - 3)
	formatted = str_int + formatted
	
	# Add decimal part (always show 2 digits)
	formatted += "." + str(decimal_part).pad_zeros(2)
	
	# Add negative sign if needed
	if amount < 0:
		formatted = "-" + formatted
	
	return formatted + " $"












@rpc("authority","reliable")
func add_info(exported_string: String):
	info_text.append(exported_string)
	
	
	
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

func _on_animation_player_animation_finished(_anim_name):
	if info_text:
		info_panel_next()


func _on_building_edit_button_pressed():
	spawn_furniture_placer()
