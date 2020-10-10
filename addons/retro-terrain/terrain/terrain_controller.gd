tool

extends Spatial


signal terrain_changed()
signal input_terrain_event()

onready var terrain_model = get_node("TerrainStaticBody/TerrainMeshInstance/TerrainModel")
onready var terrain_instance = get_node("TerrainStaticBody/TerrainMeshInstance")
onready var terrain_body = get_node("TerrainStaticBody")

export(int) var map_size = 96


func _ready():
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")
	terrain_body.connect("input_event", self, "_on_terrain_input")

func _on_terrain_input(camera, event, mouse_pos, mouse_normal, shape_idx):
	var x = mouse_pos.x
	var y = mouse_pos.z
	var scale_x = scale.x
	var scale_y = scale.z

	var vertex_x = round(x / scale_x) + map_size / 2
	var vertex_y = round(y / scale_y) + map_size / 2
	var vertex_pos = Vector2(vertex_x, vertex_y)

	emit_signal("input_terrain_event", camera, event, mouse_pos, mouse_normal, shape_idx, vertex_pos)

func _on_terrain_changed(height_map):
	emit_signal("terrain_changed")
	
func deform(x, y, delta_height):
	terrain_model.deform(x, y, delta_height)
