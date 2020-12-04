extends Spatial

onready var terrain_controller = get_node("Terrain")
onready var terrain_timer = get_node("Timer")

func _ready():
#	terrain_controller.deform(0, 0, 1)

#	terrain_controller.deform(8, 8, 3)

#	terrain_controller.deform(5, 5, 7)

	
#	terrain_controller.deform(23, 23, 1)
#	terrain_controller.deform(23, 22, 1)
#	terrain_controller.deform(22, 23, 1)
	
	
	for y in range(15):
		for x in range(15):
			terrain_controller.deform(x + 1, y + 1, 1)
	
	for y in range(16):
		for x in range(16):
			if x > 0 and x < 15 and y > 0 and y < 15:
				continue
	
			terrain_controller.set_tile(x, y, 2)

	terrain_timer.connect("timeout", self, "timeout")
#	terrain_controller.connect("input_terrain_event", self, "_input_terrain_event")
	
#func _input_terrain_event(camera, event, mouse_pos, mouse_normal, shape_idx, vertex_pos):
#	pass


func timeout():
	print("Timer timed out")
	terrain_controller.deform(6, 6, 1)
