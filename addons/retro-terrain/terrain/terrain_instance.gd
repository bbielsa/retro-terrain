tool
extends MeshInstance


onready var size = 96

# Called when the node enters the scene tree for the first time.
func _ready():
	var vertices = PoolVector3Array()
	
	var tile_vertices_size = (size + 1) * (size + 1)
	var middle_vertices_size = size * size
	var vertices_size = tile_vertices_size
	
	vertices.resize(vertices_size)
	
	var i = 0
	
	for y in range(size + 1):
		for x in range(size + 1):
			vertices[i] = Vector3(x, 0, y)
			i += 1
	
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	self.mesh = arr_mesh

func _calculate_indices():
	var width_tiles = size
	var height_tiles = size
	
	var index_array = PoolIntArray()
	
	for y in range(height_tiles):
		for x in range(width_tiles):
			var middle_idx = _get_middle_idx(x, y)			
			var north_idx = y * size + x
			var south_idx = (y + 1) * size + x + 1
			var east_idx = y * size + x + 1
			var west_idx = (y + 1) * size + x
			
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

	return index_array
