extends Node3D

const TYPE = "shelf"

var building_id






func action():
	BuildingManager.rpc_id(1,"request_fill_shelf")
