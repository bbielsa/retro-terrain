extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
var terrain_shader
var mesh_tool

var vertex_array
var index_array

func _ready():
	generate_terrain()
	
	mesh_tool = MeshDataTool.new()
	mesh_tool.create_from_surface(mesh, 0)

	mesh_tool.set_material(terrain_material)

	mesh_tool.commit_to_surface(mesh)
	
	terrain_model.connect("terrain_changed", self, "_terrain_changed")
	terrain_model.deform(4, 4, 3)
	terrain_model.deform(4, 4, -2)

	terrain_model.print_map()
	
func _generate_vertex_array():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var width = width_tiles + 1
	var height = height_tiles + 1
	var middle_vertices = width_tiles * height_tiles
	
	var vertices_size = width * height + middle_vertices
	var vertices = PoolVector3Array()
	vertices.resize(vertices_size)
	
	var i = 0
	
	for y in range(height):
		for x in range(width):
			vertices[i] = Vector3(x, 0, y)
			i += 1
			
	for y in range(height_tiles):
		for x in range(width_tiles):
			vertices[i] = Vector3(x + 0.5, 0, y + 0.5)
			i += 1
			
	vertex_array = vertices
	
func _calculate_indices():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var i = 0
	
	index_array = PoolIntArray()
	
#	index_array.push_back(0)
#	index_array.push_back(1)
#	index_array.push_back(11)
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			index_array.push_back(i)
			index_array.push_back(i + 1)
			index_array.push_back(width_tiles + 1 + i)

			i += 1
	
func generate_terrain():
	_generate_vertex_array()
	_calculate_indices()
	
	var arrays = []
	arrays.resize(9)
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	
	var terrain_mesh = ArrayMesh.new()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	set_mesh(terrain_mesh)
	
#	set_mesh(surface_tool.commit())
	
func _terrain_changed(height_map):
	print("_terrain_changed called, generating data texture")
