tool

extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
onready var terrain_utils = get_node("TerrainUtils")
var terrain_shader
var mesh_tool

var vertex_array
var index_array
var uv2_array
var uv_array

const Corner = {
	NORTH = Vector2(0, 0),
	EAST = Vector2(1, 0),
	WEST = Vector2(0, 1),
	SOUTH = Vector2(1, 1)
}

func _ready():
	generate_terrain()

	mesh_tool = MeshDataTool.new()
	mesh_tool.create_from_surface(mesh, 0)

	mesh_tool.set_material(terrain_material)

	

	terrain_model.connect("terrain_changed", self, "_terrain_changed")
	terrain_model.deform(4, 4, 3)
	terrain_model.deform(4, 4, -2)
	
	mesh_tool.commit_to_surface(mesh)
	
#	terrain_model.deform(4, 4, 1)
#	terrain_model.deform(6, 6, 1)
#	terrain_model.deform(6, 5, 1)
#	terrain_model.deform(5, 6, 1)
	
#	terrain_model.deform(4, 4, 1)
#	terrain_model.deform(3, 3, 1)
#	terrain_model.deform(3, 4, 1)
#	terrain_model.deform(4, 3, 1)

func _get_vertex_idx(tile_x, tile_y, corner):
	if tile_y > 0:
		var a = 0
		
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var width = width_tiles + 1
	var height = height_tiles + 1
	
	var index = 0
	
	index += tile_x + corner.x
	index += width * tile_y + corner.y * width
	
	return index

func _get_middle_idx(tile_x, tile_y):
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var width = width_tiles + 1
	var height = height_tiles + 1
	
	# index into the middle vertex region of the vertex array
	var middle_vertex_index = tile_x + tile_y * width_tiles
	var index = width * height + middle_vertex_index
	
	return index

func _generate_vertex_array():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var width = width_tiles + 1
	var height = height_tiles + 1
	var middle_vertices = width_tiles * height_tiles
	
	var vertices_size = width * height + middle_vertices
	var vertices = PoolVector3Array()
	var uv2s = PoolVector2Array()
	var uvs = PoolVector2Array()
	
	vertices.resize(vertices_size)
	uv2s.resize(vertices_size)
	uvs.resize(vertices_size)
	
	var dim = terrain_model.map_dimension
	
	var north_corner_idx = _get_vertex_idx(0, 0, Corner.NORTH)
	var south_corner_idx = _get_vertex_idx(dim, dim, Corner.SOUTH)
	
	uvs[north_corner_idx] = Vector2(1, 1)
	uvs[south_corner_idx] = Vector2(1, 1)
	
	
	var i = 0
	
	var outer = Vector2(0, 0)
	var inner = Vector2(1, 1)
	
	for y in range(height):
		for x in range(width):
			vertices[i] = Vector3(x, 0, y)
			uv2s[i] = outer
			i += 1
			
	for y in range(height_tiles):
		for x in range(width_tiles):
			vertices[i] = Vector3(x + 0.5, 0, y + 0.5)
			uv2s[i] = inner
			i += 1

#	for y in range(height_tiles):
#		for x in range(width_tiles):
#			var north_idx = _get_vertex_idx(x, y, Corner.NORTH)
#			var south_idx = _get_vertex_idx(x + 1, y + 1, Corner.SOUTH)
#			var east_idx = _get_vertex_idx(x + 1, y, Corner.EAST)
#			var west_idx = _get_vertex_idx(x, y + 1, Corner.WEST)
#			var middle_idx = _get_middle_idx(x, y)
#
#			uvs[north_idx] = Corner.SOUTH * Vector2(x, y)
#			uvs[south_idx] = Corner.NORTH * Vector2(x, y)
#			uvs[east_idx] = Corner.EAST * Vector2(x, y)
#			uvs[west_idx] = Corner.WEST * Vector2(x, y)
#			uvs[middle_idx] = Vector2(0.5, 0.5) * Vector2(x, y)
#
#			print(north_idx)
#			print(south_idx)
#			print(east_idx)
#			print(west_idx)
	
	
			
	vertex_array = vertices
	uv2_array = uv2s
	uv_array = uvs
	
func _calculate_indices():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	
	index_array = PoolIntArray()
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			var middle_idx = _get_middle_idx(x, y)			
			var north_idx = _get_vertex_idx(x, y, Corner.NORTH)
			var south_idx = _get_vertex_idx(x, y, Corner.SOUTH)
			var east_idx = _get_vertex_idx(x, y, Corner.EAST)
			var west_idx = _get_vertex_idx(x, y, Corner.WEST)
			
			#
			# N        E
			#  |------|
			#  |\  1 /|
			#  | \  / |
			#  |4 \/ 2|
			#  |  /\  |
			#  | / 3\ |
			#  |/____\|
			# W        S
			#
			
			# triangle 1
			index_array.push_back(north_idx)
			index_array.push_back(east_idx)
			index_array.push_back(middle_idx)
			
			# triangle 2
			index_array.push_back(east_idx)
			index_array.push_back(south_idx)
			index_array.push_back(middle_idx)
			
			# triangle 3
			index_array.push_back(south_idx)
			index_array.push_back(west_idx)
			index_array.push_back(middle_idx)
			
			# triangle 4
			index_array.push_back(west_idx)
			index_array.push_back(north_idx)
			index_array.push_back(middle_idx)

func generate_terrain():
	_generate_vertex_array()
	_calculate_indices()
	
	var arrays = []
	
	arrays.resize(Mesh.ARRAY_MAX)
	
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_TEX_UV2] = uv2_array
	
	var terrain_mesh = ArrayMesh.new()
	terrain_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	set_mesh(terrain_mesh)
	
func _deform_terrain(vertices):
	pass
	
func _vector2_with_height(vector, height):
	return Vector3(vector.x, height / 2.0, vector.y)
	
func _get_height_with_vector2(vector):
	return terrain_model.get_vertex_height(vector.x, vector.y)
	
func _terrain_changed(height_map):
	print("_terrain_changed called, modifying terrain")
	terrain_model.print_map()
	
	var dimension = terrain_model.map_dimension
	var height = dimension
	var width = dimension
	
#	mesh_tool.create_from_surface(mesh, 0)
	
	for y in range(height):
		for x in range(width):
			var tile_vertex = Vector2(x, y)
			
			var north_vertex = tile_vertex
			var east_vertex = tile_vertex + Corner.EAST
			var west_vertex = tile_vertex + Corner.WEST
			var south_vertex = tile_vertex + Corner.SOUTH
			var middle_vertex = tile_vertex + Vector2(0.5, 0.5)

			var north_height = _get_height_with_vector2(north_vertex)
			var east_height = _get_height_with_vector2(east_vertex)
			var west_height = _get_height_with_vector2(west_vertex)
			var south_height = _get_height_with_vector2(south_vertex)
			var middle_height = terrain_utils.get_middle_vertex_height(x, y)
			
			var new_north_vertex = _vector2_with_height(north_vertex, north_height)
			var new_east_vertex = _vector2_with_height(east_vertex, east_height)
			var new_west_vertex = _vector2_with_height(west_vertex, west_height)
			var new_south_vertex = _vector2_with_height(south_vertex, south_height)
			var new_middle_vertex = _vector2_with_height(middle_vertex, middle_height)
			
			var middle_idx = _get_middle_idx(x, y)			
			var north_idx = _get_vertex_idx(x, y, Corner.NORTH)
			var south_idx = _get_vertex_idx(x, y, Corner.SOUTH)
			var east_idx = _get_vertex_idx(x, y, Corner.EAST)
			var west_idx = _get_vertex_idx(x, y, Corner.WEST)
		
			if x == 4 && y == 4:
				var test = height_map[y][x]
				north_height = test
				
				print("4,4 height: ", test)
				print("new_north:  ", new_north_vertex)
				print("north_idx:  ", north_idx)
		
			mesh_tool.set_vertex(north_idx, new_north_vertex)
			mesh_tool.set_vertex(south_idx, new_south_vertex)
			mesh_tool.set_vertex(east_idx, new_east_vertex)
			mesh_tool.set_vertex(west_idx, new_west_vertex)
			mesh_tool.set_vertex(middle_idx, new_middle_vertex)
			
#	mesh_tool.commit_to_surface(mesh)
	print(" ")
