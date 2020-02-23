extends Spatial

onready var terrain_controller = get_node("Terrain")
onready var terrain_timer = get_node("Timer")

func _ready():
	terrain_controller.deform(5, 5, 2)
	terrain_controller.deform(5, 5, -1)
	terrain_controller.deform(4, 4, 1)
	
	terrain_timer.connect("timeout", self, "timeout")

func timeout():
	print("Timer timed out")
	terrain_controller.deform(6, 6, 1)
