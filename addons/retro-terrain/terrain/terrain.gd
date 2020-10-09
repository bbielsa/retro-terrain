tool

extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_model = get_node("TerrainModel")
onready var terrain_utils = get_node("TerrainUtils")
onready var terrain_shape = get_node("../TerrainCollisionShape")

var terrain_shader
var mesh_tool

var vertex_array
var index_array
var uv2_array
var uv_array

var vertex_index

const Corner = {
	NORTH = Vector2(0, 0),
	EAST = Vector2(1, 0),
	WEST = Vector2(0, 1),
	SOUTH = Vector2(1, 1)
}

const Corner3 = {
	NORTH = Vector3(0, 0, 0),
	EAST = Vector3(1, 0, 0),
	WEST = Vector3(0, 0, 1),
	SOUTH = Vector3(1, 0, 1)	
}

func _ready():
	_init_vertex_index()
	
	generate_terrain()

	mesh_tool = MeshDataTool.new()
	mesh_tool.create_from_surface(mesh, 0)
	
	var texture = load("res://demo/assets/texture/texture_atlas.png")
	texture.flags = 0
	terrain_material.set_shader_param("texture_atlas", texture)
	
	mesh_tool.set_material(terrain_material)
	mesh_tool.commit_to_surface(mesh)

	terrain_shape.shape = mesh.create_trimesh_shape()

	terrain_model.connect("terrain_changed", self, "_terrain_changed_timed")
	connect("input_event", self, "_on_area_input_event")

func _init_vertex_index():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	
	vertex_index = []
	
	for y in range(height_tiles):
		vertex_index.append([])
		
		for x in range(width_tiles):
			vertex_index[y].append([])
			
			vertex_index[y][x] = {"corners": [null, null, null, null], "middle": null}

func _get_tile_uvs(tile_idx):
	var tiles_x = 2
	var tiles_y = 2
	
	var x = tile_idx % tiles_x
	var y = floor(tile_idx / tiles_y)
	
	var tile_w = Vector2(1.0, 0.0)
	var tile_h = Vector2(0.0, 1.0)
	var tile_m = Vector2(0.5, 0.5)
	var origin = Vector2(x, y)
	
	var m = origin + tile_m
	var n = origin
	var e = origin + tile_w
	var s = origin + tile_w + tile_h
	var w = origin + tile_h
	
	return [
		m / tiles_x,
		n / tiles_x,
		e / tiles_x,
		s / tiles_x,
		w / tiles_x
	]

func _generate_vertex_array():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	var width = width_tiles + 1
	var height = height_tiles + 1
	var middle_vertices = width_tiles * height_tiles
	
	var vertices_size = width * height * 5
	var vertices = PoolVector3Array()
	var uv2s = PoolVector2Array()
	var uvs = PoolVector2Array()
	
	vertices.resize(vertices_size)
	uv2s.resize(vertices_size)
	uvs.resize(vertices_size)
	
	var dim = terrain_model.map_dimension

	var i = 0
	
	var outer = Vector2(0, 0)
	var inner = Vector2(1, 1)
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			vertex_index[y][x]["middle"] = i
			
			vertex_index[y][x]["corners"][0] = i + 1
			vertex_index[y][x]["corners"][1] = i + 2
			vertex_index[y][x]["corners"][2] = i + 3
			vertex_index[y][x]["corners"][3] = i + 4
			
			var origin = Vector3(x, 0, y)
			
			vertices[i] = Vector3(x + 0.5, 0, y + 0.5)
			vertices[i + 1] = origin + Corner3.NORTH
			vertices[i + 2] = origin + Corner3.EAST
			vertices[i + 3] = origin + Corner3.SOUTH
			vertices[i + 4] = origin + Corner3.WEST
			
			uv2s[i] = inner
			uv2s[i + 1] = outer
			uv2s[i + 2] = outer
			uv2s[i + 3] = outer
			uv2s[i + 4] = outer
				
			
			var tex_uv = _get_tile_uvs(0)
			
			if x > 10 and y > 10 and x < 15 and y < 15:
				tex_uv = _get_tile_uvs(3)
			
			uvs[i] = tex_uv[0]
			uvs[i + 1] = tex_uv[1]
			uvs[i + 2] = tex_uv[2]
			uvs[i + 3] = tex_uv[3]
			uvs[i + 4] = tex_uv[4]

			i += 5

	vertex_array = vertices
	uv2_array = uv2s
	uv_array = uvs
	
func _calculate_indices():
	var width_tiles = terrain_model.map_dimension
	var height_tiles = terrain_model.map_dimension
	
	index_array = PoolIntArray()
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			var middle_idx = vertex_index[y][x]["middle"]		
			var north_idx = vertex_index[y][x]["corners"][0]
			var east_idx = vertex_index[y][x]["corners"][1]
			var south_idx = vertex_index[y][x]["corners"][2]
			var west_idx = vertex_index[y][x]["corners"][3]
			
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
	
func _vector2_with_height(vector, height):
	return Vector3(vector.x, height / 2.0, vector.y)
	
func _get_height_with_vector2(vector):
	return terrain_model.get_vertex_height(vector.x, vector.y)
	
func _terrain_changed_timed(height_map):
	var start_time = OS.get_ticks_msec()
	
	_terrain_changed(height_map)
	
	var end_time = OS.get_ticks_msec()
	var elapsed_time = end_time - start_time
	
	print("Terrain recalculation took " + str(elapsed_time) + "ms")

func _terrain_changed(height_map):
	var dimension = terrain_model.map_dimension
	var height = dimension
	var width = dimension

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
			
			var middle_idx = vertex_index[y][x]["middle"]
			var north_idx = vertex_index[y][x]["corners"][0]
			var east_idx = vertex_index[y][x]["corners"][1]
			var south_idx = vertex_index[y][x]["corners"][2]
			var west_idx = vertex_index[y][x]["corners"][3]
			
			mesh_tool.set_vertex(north_idx, new_north_vertex)
			mesh_tool.set_vertex(south_idx, new_south_vertex)
			mesh_tool.set_vertex(east_idx, new_east_vertex)
			mesh_tool.set_vertex(west_idx, new_west_vertex)
			mesh_tool.set_vertex(middle_idx, new_middle_vertex)

	for surface_idx in range(mesh.get_surface_count()):
		mesh.surface_remove(surface_idx)

	mesh_tool.commit_to_surface(self.mesh)
	#self.mesh = mesh_tool.commit()
	
	terrain_shape.shape = mesh.create_trimesh_shape()
	
#	mesh.surface_remove(1)
	
#	print("surfaces ", mesh.get_surface_count())
#	print(get_aabb())
#	print(" ")
