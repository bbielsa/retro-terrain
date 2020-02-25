extends Spatial

onready var terrain_controller = get_node("Terrain")
onready var terrain_timer = get_node("Timer")

func _ready():
	terrain_controller.deform(5, 5, 2)
	terrain_controller.deform(5, 5, -1)
	terrain_controller.deform(4, 4, 1)
	
	terrain_timer.connect("timeout", self, "timeout")
	terrain_controller.connect("input_terrain_event", self, "_input_terrain_event")
	
func _input_terrain_event(camera, event, mouse_pos, mouse_normal, shape_idx):
	print("input terrain event")

func timeout():
	print("Timer timed out")
	terrain_controller.deform(6, 6, 1)
