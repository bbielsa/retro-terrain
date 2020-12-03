tool

extends MeshInstance

export(ShaderMaterial) var terrain_material = null

onready var terrain_controller = get_node("../../")
onready var terrain_model = get_node("../../TerrainModel")
onready var terrain_utils = get_node("TerrainUtils")
onready var terrain_shape = get_node("../TerrainCollisionShape")

onready var terrain_chunk = get_node("..")

onready var chunk_size = terrain_controller.chunk_size
onready var chunk_id = terrain_chunk.chunk_id

var terrain_shader
var mesh_tool

var height_map

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
	_init_mesh()
	_init_vertex_index()
	
	generate_terrain()
	_update_terrain()

	connect("input_event", self, "_on_area_input_event")

	terrain_controller.connect("chunk_changed", self, "_chunk_changed")
	print("connected")

func _init_mesh():
	mesh_tool = MeshDataTool.new()
	mesh_tool.create_from_surface(mesh, 0)
	
	var texture = load("res://demo/assets/texture/texture_atlas.png")
	texture.flags = 0
	terrain_material.set_shader_param("texture_atlas", texture)
	
	mesh_tool.set_material(terrain_material)
	mesh_tool.commit_to_surface(mesh)

	terrain_shape.shape = mesh.create_trimesh_shape()

func _get_tile_vertex_indices(x, y):
	var middle_idx = vertex_index[y][x]["middle"]
	var north_idx = vertex_index[y][x]["corners"][0]
	var east_idx = vertex_index[y][x]["corners"][1]
	var south_idx = vertex_index[y][x]["corners"][2]
	var west_idx = vertex_index[y][x]["corners"][3]
	
	return {
		middle = middle_idx,
		north = north_idx,
		east = east_idx,
		south = south_idx,
		west = west_idx	
	}

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
	var width_tiles = 8
	var height_tiles = 8
	var width = width_tiles + 1
	var height = height_tiles + 1
	var middle_vertices = width_tiles * height_tiles
	
	var vertices_size = width_tiles * height_tiles * 5
	var vertices = PoolVector3Array()
	var uv2s = PoolVector2Array()
	var uvs = PoolVector2Array()
	
	vertices.resize(vertices_size)
	uv2s.resize(vertices_size)
	uvs.resize(vertices_size)
	
	var dim = 8

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
			
			var tex_uv = _get_tile_uvs(2)
			
			
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
	var width_tiles = 8
	var height_tiles = 8
	
	index_array = PoolIntArray()
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			var tile_indices = _get_tile_vertex_indices(x, y)
			
			var middle_idx = tile_indices.middle	
			var north_idx = tile_indices.north
			var east_idx = tile_indices.east
			var south_idx = tile_indices.south
			var west_idx = tile_indices.west
			
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
	var chunk_x = chunk_id % 2
	var chunk_y = floor(chunk_id / 2)
	
	var world_x = chunk_x * 8 + vector.x
	var world_y = chunk_y * 8 + vector.y
	
	return terrain_model.get_vertex_height(world_x, world_y)

func _get_middle_vertex_height(x, y):
	var chunk_x = chunk_id % 2
	var chunk_y = floor(chunk_id / 2)
	
	var world_x = chunk_x * 8 + x
	var world_y = chunk_y * 8 + y
	
	return terrain_utils.get_middle_vertex_height(world_x, world_y)

func _update_terrain_timed():
	var start_time = OS.get_ticks_msec()
	
	_update_terrain()
	
	var end_time = OS.get_ticks_msec()
	var elapsed_time = end_time - start_time
	
	print("Terrain recalculation took " + str(elapsed_time) + "ms")

func _get_chunk_bounds(chunk_x, chunk_y, chunk_size):
	pass

func _chunk_changed(modified_chunks, modified_vertices, height_map):
	if not chunk_id in modified_chunks:
		return

	self.height_map = _get_heightmap_for_chunk(chunk_id, height_map)
	_update_terrain_timed()

func _get_heightmap_for_chunk(chunk_id, height_map):
	var chunk_x = chunk_id % 2
	var chunk_y = floor(chunk_id / 2)
	
	var start_x = chunk_x * chunk_size
	var start_y = chunk_x * chunk_size
	
	var chunk_heightmap = []
	
	var y = 0
	var x = 0
	
	for map_y in range(start_y, start_y + chunk_size + 1):
		chunk_heightmap.append([])
		x = 0
		for map_x in range(start_x, start_x + chunk_size + 1):
			chunk_heightmap[y].append(height_map[map_y][map_x])
			x += 1
		y += 1
		
	return chunk_heightmap

func _set_tile(tile_id, x, y):
	var tile_uv = _get_tile_uvs(1)
	var tile_indices = _get_tile_vertex_indices(x, y)

	mesh_tool.set_vertex_uv(tile_indices.north, tile_uv[1])
	mesh_tool.set_vertex_uv(tile_indices.east, tile_uv[2])
	mesh_tool.set_vertex_uv(tile_indices.south, tile_uv[3])
	mesh_tool.set_vertex_uv(tile_indices.west, tile_uv[4])
	mesh_tool.set_vertex_uv(tile_indices.middle, tile_uv[0])

func _update_terrain():
	var dimension = chunk_size
	var height = 8
	var width = 8

	for y in range(0, height):
		for x in range(0, width):
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
			var middle_height = _get_middle_vertex_height(x, y)
			
			var new_north_vertex = _vector2_with_height(north_vertex, north_height)
			var new_east_vertex = _vector2_with_height(east_vertex, east_height)
			var new_west_vertex = _vector2_with_height(west_vertex, west_height)
			var new_south_vertex = _vector2_with_height(south_vertex, south_height)
			var new_middle_vertex = _vector2_with_height(middle_vertex, middle_height)
			
			var tile_indices = _get_tile_vertex_indices(x, y)
			
			var middle_idx = tile_indices.middle
			var north_idx = tile_indices.north
			var east_idx = tile_indices.east
			var south_idx = tile_indices.south
			var west_idx = tile_indices.west
			
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
