tool

extends Spatial


signal terrain_changed()

onready var terrain_model = get_node("TerrainMeshInstance/TerrainModel")
onready var terrain_instance = get_node("TerrainMeshInstance")

func _ready():
	terrain_model.connect("terrain_changed", self, "_on_terrain_changed")

func _on_terrain_changed(height_map):
	emit_signal("terrain_changed")
	
func deform(x, y, delta_height):
	terrain_model.deform(x, y, delta_height)