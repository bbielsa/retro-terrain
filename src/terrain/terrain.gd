extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
var multi_mesh_instance
var theta = 0
var loaded = false
var test_tile_mesh

func _ready():
	terrain_model.deform(0, 0, 1)
	terrain_model.deform(4, 4, 2)
	terrain_model.deform(4, 4, -2)
	terrain_model.print_map()
