tool

extends Spatial


signal terrain_changed()
signal input_terrain_event()

onready var terrain_model = get_node("TerrainStaticBody/TerrainMeshInstance/TerrainModel")
onready var terrain_instance = get_node("TerrainStaticBody/TerrainMeshInstance")
onready var terrain_body = get_node("TerrainStaticBody")

export(int) var map_size = 24

func _ready():
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")
	terrain_body.connect("input_event", self, "_on_terrain_input")
	
	var offset = -map_size / 2
	var offset_vector = Vector3(offset, 0, offset)
	
	terrain_instance.translate(offset_vector)

func _on_terrain_input(camera, event, mouse_pos, mouse_normal, shape_idx):
	emit_signal("input_terrain_event", camera, event, mouse_pos, mouse_normal, shape_idx)

func _on_terrain_changed(height_map):
	emit_signal("terrain_changed")
	
func deform(x, y, delta_height):
	terrain_model.deform(x, y, delta_height)
