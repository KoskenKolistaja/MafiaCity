extends NavigationRegion3D



func _ready():
	print("Spawner path: ", get_path())
	print("World exists? ", has_node("MultiplayerSpawner"))
