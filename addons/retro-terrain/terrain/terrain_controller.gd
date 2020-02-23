tool

extends Spatial


signal terrain_changed()

onready var terrain_model = get_node("TerrainMeshInstance/TerrainModel")
onready var terrain_instance = get_node("TerrainMeshInstance")

export(int) var map_size = 24

func _ready():
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")
	
	var offset = -map_size / 2
	var offset_vector = Vector3(offset, 0, offset)
	
	terrain_instance.translate(offset_vector)

func _on_terrain_changed(height_map):
	emit_signal("terrain_changed")
	
func deform(x, y, delta_height):
	terrain_model.deform(x, y, delta_height)
