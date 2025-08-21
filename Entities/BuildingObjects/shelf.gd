extends Node3D

const TYPE = "shelf"

var id : int

var building_id

var shelf_positions: Array = [false,false,false,false]



func _ready():
	update_visual()



func action():
	
	BuildingManager.rpc_id(1,"request_fill_shelf",id)



func update_array(array):
	shelf_positions = array
	update_visual()



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
