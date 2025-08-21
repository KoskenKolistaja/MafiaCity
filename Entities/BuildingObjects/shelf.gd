extends Node3D

const TYPE = "shelf"

var id : int

var building_id

var shelf_positions: Array = [false,false,false,false]



func _ready():
	update_visual()



func action():
	
	BuildingManager.rpc_id(1,"request_fill_shelf",id)



@rpc("authority","reliable")
func update_array(array):
	shelf_positions = array
	update_visual()


func is_empty():
	var returned = true
	for item in shelf_positions:
		if item:
			returned = false
	return returned


func npc_picked_item(npc):
	
	var index = shelf_positions.find(true)
	
	if index < 0:
		push_error("No items in shelf")
		return
	
	shelf_positions[index] = false
	
	npc.item_picked("This will include item later")


func update_visual():
	if shelf_positions[0]:
		$Position1/Product.show()
	else:
		$Position1/Product.hide()
	if shelf_positions[1]:
		$Position2/Product.show()
	else:
		$Position2/Product.hide()
	if shelf_positions[2]:
		$Position3/Product.show()
	else:
		$Position3/Product.hide()
	if shelf_positions[3]:
		$Position4/Product.show()
	else:
		$Position4/Product.hide()
